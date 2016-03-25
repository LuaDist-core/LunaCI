module("lunaci", package.seeall)

local config = require "lunaci.config"
local utils = require "lunaci.utils"
local log = require "lunaci.log"
local Manager = require "lunaci.Manager"

local pl = require "pl.import_into"()


function fetch_manifest()
    log:info("Fetching manifest")

    if pl.path.exists(config.manifest.file) then
        return pl.pretty.read(pl.file.read(config.manifest.file))
    end

    local ok, err = utils.git_clone(config.manifest.repo, config.manifest.path)
    if not ok then return nil, err end

    if not pl.path.exists(config.manifest.file) then
        return nil, "Manifest file '" .. config.manifest.file .. "' not found."
    end

    return pl.pretty.read(pl.file.read(config.manifest.file))
end



--local manifest, err = fetch_manifest()
local manifest = pl.pretty.read(pl.file.read(config.manifest.file .. ".test"))
if not manifest then
    error(err)
end

local manager = Manager(manifest, config.ci_targets)


local task_check_deps = require "lunaci.tasks.dependencies"

manager:add_task("Dependencies", task_check_deps)


manager:process_packages()

pl.pretty.dump(manager.output)
