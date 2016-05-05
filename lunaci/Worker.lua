-- LunaCI task worker
-- Part of the LuaDist project - http://luadist.org
-- Author: Martin Srank, hello@smasty.net
-- License: MIT


local log = require "lunaci.log"
local utils = require "lunaci.utils"
local config = require "lunaci.config"
local PackageReport = require "lunaci.PackageReport"

local Package = require "rocksolver.Package"

local pl = require "pl.import_into"()


-- Class definition and constructor.
local Worker = {}
Worker.__index = Worker
setmetatable(Worker, {
__call = function(self, name, versions, manifest)
    pl.utils.assert_string(1, name)
    pl.utils.assert_arg(2, versions, "table")
    pl.utils.assert_arg(3, manifest, "table")
    local self = setmetatable({}, Worker)

    self.package_name = name
    self.package_versions = versions
    self.manifest = manifest
    self.report = PackageReport(name)

    return self
end
})


-- Run the worker on all the given targets and tasks.
function Worker:run(targets, tasks)
    pl.utils.assert_arg(1, targets, "table")
    pl.utils.assert_arg(2, tasks, "table")

    for version, spec in pl.tablex.sort(self.package_versions, utils.sortVersions) do
        local package = self:get_package(self.package_name, version, spec)

        for _, target in pairs(targets) do
            self:run_target(package, target, tasks)
        end

        -- Clean package version deploy dir
        pl.dir.rmtree(pl.path.join(config.deploy_dir, ("%s-%s"):format(package.name, version)))
    end
end


-- Run tasks for the package on a given target.
function Worker:run_target(package, target, tasks)
    pl.utils.assert_arg(1, package, "table")
    pl.utils.assert_arg(2, target, "table")
    pl.utils.assert_arg(3, tasks, "table")

    log:debug("Running target %s on %s", target.name, package)

    local deploy_dir = self:prepare_target(package, target)

    local continue = true
    for _, task in pairs(tasks) do
        if not continue then
            self.report:add_output(package, target, task, config.STATUS_SKIP, "Task chain ended.")
        else
            local ok, success, output, cont = pcall(task.call, package, target, deploy_dir, self.manifest)

            if ok then
                -- Task run without runtime errors
                self.report:add_output(package, target, task, success, output)

                -- Task finished unsuccessfully - task chain should end
                if not cont then
                    continue = false
                end
            else
                -- Runtime error while running the task
                local msg = "Error running task: " .. success -- success contains lua error message
                log:error(msg)
                self.report:add_output(package, target, task, config.STATUS_INT, msg)
            end
        end
    end

    self:cleanup_target(deploy_dir, package, target)
end


function Worker:prepare_target(package, target)
    local path = pl.path

    local target_base = path.basename(target.deploy_dir)
    local deploy_dir = path.join(config.deploy_dir, ("%s-%s"):format(package.name, package.version), target_base)
    log:debug("Deploy directory: " .. deploy_dir)
    utils.force_makepath(deploy_dir)

    -- Copy target base deploy dir
    local ok, code, out, err = utils.copydir(target.deploy_dir, pl.path.dirname(deploy_dir))
    if not ok then
        error("Could not copy target base deploy directory " .. target.deploy_dir .. ": " .. err)
    end

    return deploy_dir
end


function Worker:cleanup_target(deploy_dir, package, target)
    return pl.dir.rmtree(deploy_dir)
end


-- Ge the PackageReport with the output from the runs.
function Worker:get_report()
    return self.report
end


-- TODO use LuaDist for this when it's ready
function Worker:get_package(name, version, spec)
    local path = pl.path

    local tmp_dir = path.join(config.tmp_dir, "rockspecs")
    pl.dir.makepath(tmp_dir)

    local rockspec_filename = name .. "-" .. version .. ".rockspec"
    local remote_url = ("https://raw.githubusercontent.com/LuaDist2/%s/%s/%s"):format(name, version, rockspec_filename)
    local rockspec_path = path.join(tmp_dir, rockspec_filename)

    -- Download rockspec from GitHub
    if not path.exists(rockspec_path) then
        local ok, code, out, err = utils.dir_exec(tmp_dir, ("curl -fksSL '%s'"):format(remote_url))

        if not ok then
            log:error("Could not download rockspec for %s-%s", name, version)
            return Package(name, version, spec)
        end

        pl.file.write(rockspec_path, out)
    end

    -- Load rockspec from file
    local contents = pl.file.read(rockspec_path)
    local lines = pl.stringx.splitlines(contents)

    -- Remove possible hashbangs
    for i, line in ipairs(lines) do
        if line:match("^#!.*") then
            table.remove(lines, i)
        end
    end

    -- Load rockspec file as table
    local rockspec = pl.pretty.load(pl.stringx.join("\n", lines), nil, false)

    if type(rockspec) ~= 'table' then
        log:warn("Corrupted rockspec file: %s", rockspec_path)

        return Package(name, version, spec)
    end

    return Package.from_rockspec(rockspec)
end


return Worker
