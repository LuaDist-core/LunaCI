-- LunaCI build task
-- Part of the LuaDist project - http://luadist.org
-- Author: Martin Srank, hello@smasty.net
-- License: MIT

module("lunaci.tasks.build", package.seeall)


local build_package = function(package, target, deploy_dir, manifest)
    local config = require "lunaci.config"
    local utils = require "lunaci.utils"

    local ok, code, out, err = utils.dir_exec(deploy_dir, "bin/lua lib/lua/luadist.lua install '" .. package .. "'")

    local msg = "Output:\n" .. out .. "\n"
    if not ok then
        msg = msg .. ("\nError:\n%s\nExit code: %d\n"):format(err, code)
    end

    if code == 1 then
        return config.STATUS_INT, "Manifest retrieval failed.\n" .. msg, false
    elseif code == 3 then
        return config.STATUS_INT, "Package download failed.\n" .. msg, false
    elseif code == 4 then
        return config.STATUS_FAIL, "Installation of requested package failed.\n" .. msg, false
    elseif code == 5 then
        return config.STATUS_DEP, "Installation of a dependency failed.\n" .. msg, false
    else
        return config.STATUS_FAIL, msg, false
    end


    return config.STATUS_OK, msg, true
end


return build_package
