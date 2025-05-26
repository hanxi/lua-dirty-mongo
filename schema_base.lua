local tointeger = math.tointeger
local sformat = string.format

local schema_base = {}

local number_type = setmetatable({}, {
    __tostring = function()
        return "schema_number"
    end,
})
schema_base.number = setmetatable({}, {
    __metatable = number_type,
})

local integer_type = setmetatable({}, {
    __tostring = function()
        return "schema_integer"
    end,
})
schema_base.integer = setmetatable({}, {
    __metatable = integer_type,
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
    local need_tp_mt =  getmetatable(need_tp)
    if need_tp_mt == integer_type then
        if (type(k) ~= "number") or (tointeger(k) == nil) then
            error(sformat("not equal k type. need integer, real: %s, k: %s, need_tp: %s", type(k), tostring(k), tostring(need_tp_mt)))
        end
        return
    elseif need_tp_mt == string_type then
        if type(k) ~= "string" then
            error(sformat("not equal k type. need string, real: %s, k: %s, need_tp: %s", type(k), tostring(k), tostring(need_tp_mt)))
            return false
        end
        return
    end
    error(sformat("not support need_tp type: %s, k: %s", tostring(need_tp_mt), tostring(k)))
end

local function _check_v_tp(v, need_tp)
    local need_tp_mt = getmetatable(need_tp)
    if need_tp_mt == integer_type then
        if (type(v) ~= "number") or (tointeger(v) == nil) then
            error(sformat("not equal v type. need integer, real: %s, v: %s, need_tp: %s", type(v), tostring(v), tostring(need_tp_mt)))
        end
        return
    elseif need_tp_mt == number_type then
        if type(v) ~= "number" then
            error(sformat("not equal v type. need number, real: %s, v: %s, need_tp: %s", type(v), tostring(v), tostring(need_tp_mt)))
        end
        return
    elseif need_tp_mt == string_type then
        if type(v) ~= "string" then
            error(sformat("not equal v type. need string, real: %s, v: %s, need_tp: %s", type(v), tostring(v), tostring(need_tp_mt)))
        end
        return
    elseif need_tp_mt == boolean_type then
        if type(v) ~= "boolean" then
            error(sformat("not equal v type. need boolean, real: %s, v: %s, need_tp: %s", type(v), tostring(v), tostring(need_tp_mt)))
        end
        return
    end
    if getmetatable(v) ~= need_tp_mt then
        error(sformat("not equal v type. need_tp: %s, real_tp: %s, v: %s", tostring(need_tp_mt), tostring(getmetatable(v)), tostring(v)))
    end
end

function schema_base.check_k_func(need_tp)
    return function(self, k)
        _check_k_tp(k, need_tp)
    end
end

function schema_base.check_kv_func(k_need_tp, v_need_tp)
    return function(self, k, v)
        _check_k_tp(k, k_need_tp)
        _check_v_tp(v, v_need_tp)
    end
end

function schema_base.check_k(self, k)
    local schema = self[k]
    if not schema then
        error(sformat("not exist key: %s", k))
    end
end

function schema_base.check_kv(self, k, v)
    local schema = self[k]
    if not schema then
        error(sformat("not exist key: %s", k))
    end

    _check_v_tp(v, schema)
end

return schema_base
