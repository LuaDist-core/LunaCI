module("lunaci.Manager", package.seeall)

local log = require "lunaci.log"
local Worker = require "lunaci.Worker"

local pl = require "pl.import_into"()


local Manager = {}
Manager.__index = Manager

setmetatable(Manager, {
    __call = function (class, ...)
        return class.new(...)
    end,
})

function Manager.new(manifest, targets)
    local self = setmetatable({}, Manager)

    self.manifest = manifest
    self.targets = targets or {}
    self.tasks = {}
    self.output = {}

    return self
end


-- Provides fluent interface
function Manager:add_task(name, func)
    table.insert(self.tasks, {name = name, call = func})

    return self
end


function Manager:get_packages()
    return pl.tablex.sort(self.manifest.packages)
end


function Manager:process_packages()
    for name, versions in self:get_packages() do
        local worker = Worker(name, versions, self.manifest)
        worker:run(self.targets, self.tasks)

        local output = worker:get_output()
        self.output[name] = output
        -- send to templating (setup in constructor)
    end
end


return Manager
