module("lunaci.Worker", package.seeall)

local log = require "lunaci.log"
local utils = require "lunaci.utils"
local config = require "lunaci.config"
local PackageReport = require "lunaci.PackageReport"

local Package = require "rocksolver.Package"

local pl = require "pl.import_into"()


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
    end
end


-- Run tasks for the package on a given targets.
function Worker:run_target(package, target, tasks)
    pl.utils.assert_arg(1, package, "table")
    pl.utils.assert_arg(2, target, "table")
    pl.utils.assert_arg(3, tasks, "table")

    local continue = true
    for _, task in pairs(tasks) do
        if not continue then
            self.report:add_output(package, target, task, config.STATUS_NA, "Task chain ended.")
        else
            local ok, success, output, cont = pcall(task.call, package, target, self.manifest)

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
end


-- Ge the PackageReport with the output from the runs.
function Worker:get_report()
    return self.report
end


-- TODO use LuaDist2 for this when it's ready
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
    if lines[1]:match("^#!.*") then
        table.remove(lines, 1)
    end

    -- Load rockspec file as table
    local rockspec = pl.pretty.load(pl.stringx.join("\n", lines), nil, false)

    return Package.from_rockspec(rockspec)
end


return Worker
