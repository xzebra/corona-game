
local Class = {}
Class.__index = Class

--Default implementation
function Class:new() end

--Create a new Class type from our base class
function Class:derive(class_type)
    assert(class_type ~= nil, "parameter class_type must not be nil")
    assert(type(class_type) == "string", "parameter class_type must be a string")
    local cls = {}
    cls["__call"] = Class.__call
    cls.type = class_type
    cls.__index = cls
    cls.super = self
    setmetatable(cls, self)
    return cls
end

--Check if the instance is a sub-class of the given type
function Class:is(class)
    assert(class ~= nil, "parameter class must not be nil")
    assert(type(class) == "table", "parameter class must be of Type Class")
    local metatable = getmetatable(self)
    while metatable do
        if metatable == class then return true end
        metatable = getmetatable(metatable)
    end
    return false
end

function Class:is_type(class_type)
    assert(class_type ~= nil, "parameter class_type must not be nil")
    assert(type(class_type) == "string", "parameter class_type must be a string")
    local base = self
    while base do
        if base.type == class_type then return true end
        base = base.super
    end
    return false
end

function Class:__call(...)
    local inst = setmetatable({}, self)
    inst:new(...)
    return inst
end

function Class:get_type()
    return self.type
end

return Class