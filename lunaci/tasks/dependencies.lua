-- LunaCI dependency task
-- Part of the LuaDist project - http://luadist.org
-- Author: Martin Srank, hello@smasty.net
-- License: MIT

module("lunaci.tasks.dependencies", package.seeall)


local check_lua_version = function(err)
    return err:match("No suitable candidate for package \"lua[^%w][^\"]*\" found")
        or err:match("Package lua[^%w].* needed, but")
end


-- Dependency resolving task.
local check_package_dependencies = function(package, target, deploy_dir, manifest)
    local config = require "lunaci.config"
    local pl = require "pl.import_into"()
    local DependencySolver = require "rocksolver.DependencySolver"
    local const = require "rocksolver.constraints"

    local plat, err = package:supports_platform(config.platform)
    if not plat then
        return config.STATUS_PLATFORM, err .. "\nSupported platforms: " .. table.concat(package.platforms, ", "), false
    end

    -- Add target to manifest as a virtual package
    local manifest = pl.tablex.deepcopy(manifest)
    manifest.packages["lua"] = {[target.compatibility] = {}}

    local solver = DependencySolver(manifest, config.platform)
    local deps, err = solver:resolve_dependencies(tostring(package))

    if err then
        if check_lua_version(err) then
            return config.STATUS_LUA_VER, "Package does not support \"" .. target.compatibility .. "\".\n" .. err, false
        end
        return config.STATUS_FAIL, "Error resolving dependencies for package " .. package .. ":\n" .. err, false
    end

    local has_deps = false
    local out = "Resolved dependencies for package " .. package .. ": "
    for _, dep in pairs(deps) do
        -- Do not print self as a dependency
        if dep ~= package then
            out = out .. "\n- " .. tostring(dep)
            has_deps = true
        end
    end

    if not has_deps then
        out = out .. "None"
    end

    return config.STATUS_OK, out, true
end


return check_package_dependencies
