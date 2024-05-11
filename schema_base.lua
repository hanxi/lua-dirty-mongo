local schema_base = {}

local number_type = setmetatable({}, {
    __tostring = function()
        return "schema_number"
    end,
})
schema_base.number = setmetatable({}, {
    __metatable = number_type,
})

local string_type = setmetatable({}, {
    __tostring = function()
        return "schema_string"
    end,
})
schema_base.string = setmetatable({}, {
    __metatable = string_type,
})

local boolean_type = setmetatable({}, {
    __tostring = function()
        return "schema_boolean"
    end,
})
schema_base.boolean = setmetatable({}, {
    __metatable = boolean_type,
})

local function _check_k_tp(k, need_tp)
    local tp = type(k)
    local real_tp
    if tp == "number" then
        real_tp = number_type
    elseif tp == "string" then
        real_tp = string_type
    else
        return false
    end
    if getmetatable(need_tp) ~= real_tp then
        print("not equal k type. need_tp:", getmetatable(need_tp), ", real_tp:", real_tp, ", k:", k, debug.traceback())
        return false
    end
    return true
end

local function _check_v_tp(v, need_tp)
    local tp = type(v)
    local real_tp
    if tp == "number" then
        real_tp = number_type
    elseif tp == "string" then
        real_tp = string_type
    elseif tp == "boolean" then
        real_tp = boolean_type
    elseif tp == "table" then
        real_tp = getmetatable(v)
    end
    if getmetatable(need_tp) ~= real_tp then
        print("not equal v type. need_tp:", getmetatable(need_tp), ", real_tp:", real_tp, ", v:", v, debug.traceback())
        return false
    end
    return true
end

function schema_base.check_k_func(need_tp)
    return function(self, k)
        return _check_k_tp(k, need_tp)
    end
end

function schema_base.check_kv_func(k_need_tp, v_need_tp)
    return function(self, k, v)
        if not _check_k_tp(k, k_need_tp) then
            return false
        end

        if not _check_v_tp(v, v_need_tp) then
            return false
        end
        return true
    end
end

function schema_base.check_k(self, k)
    local schema = self[k]
    if not schema then
        print("not exist key:", k, debug.traceback())
        return false
    end
    return true
end

function schema_base.check_kv(self, k, v)
    local schema = self[k]
    if not schema then
        print("not exist key:", k, debug.traceback())
        return false
    end

    if not _check_v_tp(v, schema) then
        return false
    end
    return true
end

return schema_base
