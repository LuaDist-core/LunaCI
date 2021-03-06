-- LunaCI package report representation
-- Part of the LuaDist project - http://luadist.org
-- Author: Martin Srank, hello@smasty.net
-- License: MIT


local log = require "lunaci.log"
local utils = require "lunaci.utils"

local pl = require "pl.import_into"()


-- Class definition and constructor.
local PackageReport = {}
PackageReport.__index = PackageReport
setmetatable(PackageReport, {
__call = function(self, name)
    pl.utils.assert_string(1, name)
    local self = setmetatable({}, PackageReport)
    self.name = name
    self.outputs = {}
    return self
end
})


-- Internal function.
-- Get a reference to the table for a given package, version and target.
function get_output_location(outputs, package, version, target)
    pl.utils.assert_arg(1, package, "table")
    pl.utils.assert_string(2, version)
    pl.utils.assert_arg(3, target, "table")

    if not outputs[version] then
        outputs[version] = {
            name = package.name,
            version = tostring(package.version),
            package = package,
            timestamp = os.time(),
            targets = {}
        }
    end

    idx = 0
    local targets = outputs[version].targets
    for i, trgt in ipairs(targets) do
        if pl.tablex.deepcompare(trgt.target, target) then
            idx = i
            break
        end
    end
    if idx == 0 then
        table.insert(targets, {target = target, tasks = {}})
        idx = #targets
    end

    return outputs[version].targets[idx].tasks
end


-- Add output from a task for a given package and target.
function PackageReport:add_output(package, target, task, success, output)
    pl.utils.assert_arg(1, package, "table")
    pl.utils.assert_arg(2, target, "table")
    pl.utils.assert_arg(3, task, "table")
    pl.utils.assert_string(5, output)

    local version = tostring(package.version)

    local outputs = get_output_location(self.outputs, package, version, target)
    table.insert(outputs, {name = task.name, success = success, output = output})
end


-- Returns report output.
function PackageReport:get_output()
    return self.outputs
end


-- Returns output for a given package version.
function PackageReport:get_version(ver)
    pl.utils.assert_string(1, ver)

    return self.outputs[ver]
end


-- Returns output and a version string for the latest package version.
function PackageReport:get_latest()
    local output, version
    for ver, out in pl.tablex.sort(self:get_output(), utils.sortVersions) do
        output = out
        version = ver
        break
    end

    return output, version
end


return PackageReport
