local Class = require("lib.Class")
local Vector2 = Class:derive("Vector2")

function Vector2:new(x,y)
    self.x = x or 0
    self.y = y or 0
end

--Calculates the magnitude of the vector
function Vector2:mag()
    return math.sqrt(self.x*self.x + self.y*self.y)
end

--Multiplies vector by a scalar number
function Vector2:mult(val)
    return Vector2(self.x * val, self.y * val)
end

--Divides vector by a scalar number
function Vector2:div(val)
    assert(val ~= 0, "parameter val must not be 0")
    return Vector2(self.x / val, self.y / val)
end


function Vector2.add(v1, v2)
    return Vector2(v1.x + v2.x, v1.y + v2.y)
end

function Vector2.sub(v1, v2)
    return Vector2(v1.x - v2.x, v1.y - v2.y)
end

--Calculates the unit vector of this vector
function Vector2:unit()
    local mag = self:mag()
    return Vector2(self.x / mag, self.y / mag)
end

return Vector2