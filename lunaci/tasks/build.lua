module("lunaci.tasks.build", package.seeall)


-- Basic implementation. Needs better output handling.
local build_package = function(package, target, deploy_dir, manifest)
    local config = require "lunaci.config"
    local utils = require "lunaci.utils"

    local ok, code, out, err = utils.dir_exec(deploy_dir, "bin/lua lib/lua/luadist.lua install '" .. package .. "'")

    if not ok then
        local msg = ("Exit code: %d\nSTDOUT:\n%s\n\nSTDERR:\n%s\n"):format(code, out, err)
        return config.STATUS_FAIL, msg, false
    end

    return config.STATUS_OK, out, true
end


return build_package
