module("lunaci.tasks.require", package.seeall)


local require_modules = function(package, target, deploy_dir, manifest)
    local utils = require "lunaci.utils"
    local config = require "lunaci.config"
    local tablex = require "pl.tablex"
    local stringio = require "pl.stringio"

    local modules = package.spec.build and package.spec.build.modules or {}

    local output = stringio.create()
    local fail = false
    for mod in tablex.sort(modules) do
        local ok = utils.dir_exec(deploy_dir, "bin/lua -e 'require \"" .. mod .. "\"'")
        output:writef("  %s\t %s\n", (ok and "OK" or "FAIL"), mod)
        if not ok then fail = true end
    end

    return fail and config.STATUS_FAIL or config.STATUS_OK, output:value(), not fail

end


return require_modules
