-- [file name]: clone.lua
local function clone(obj, seen)
    if type(obj) ~= "table" then
        return obj
    end
    
    seen = seen or {}
    if seen[obj] then
        return seen[obj]
    end
    
    local new_table = {}
    seen[obj] = new_table
    
    for key, value in pairs(obj) do
        new_table[key] = clone(value, seen)
    end
    
    return new_table
end

return clone