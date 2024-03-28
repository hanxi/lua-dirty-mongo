local schema_base = require("schema_base")
local number = schema_base.number
local string = schema_base.string
local boolean = schema_base.boolean

local map_string_string, map_string_string_type
local map_number_number, map_number_number_type
local arr_number, arr_number_type
local arr_item, arr_item_type
local item, item_type
local user, user_type

map_string_string_type = setmetatable({}, {
    __tostring = function()
        return "schema_map_string_string"
    end,
})
map_string_string = {
    _check_k = schema_base.check_k_func(string),
    _check_kv = schema_base.check_kv_func(string, string),
}
setmetatable(map_string_string, {
    __metatable = map_string_string_type,
})

map_number_number_type = setmetatable({}, {
    __tostring = function()
        return "schema_map_number_number"
    end,
})
map_number_number = {
    _check_k = schema_base.check_k_func(number),
    _check_kv = schema_base.check_kv_func(number, number),
}
setmetatable(map_number_number, {
    __metatable = map_number_number_type,
})

arr_number_type = setmetatable({}, {
    __tostring = function()
        return "schema_arr_number"
    end,
})
arr_number = {
    _check_k = schema_base.check_k_func(number),
    _check_kv = schema_base.check_kv_func(number, number),
}
setmetatable(arr_number, {
    __metatable = arr_number_type,
})

arr_item_type = setmetatable({}, {
    __tostring = function()
        return "schema_arr_item"
    end,
})
arr_item = {
    _check_k = schema_base.check_k_func(number),
    _check_kv = schema_base.check_kv_func(number, item),
}
setmetatable(arr_item, {
    __metatable = arr_item_type,
})

item_type = setmetatable({}, {
    __tostring = function()
        return "schema_item"
    end,
})
item = {
    item_id = number,
    props = map_number_number,
    list = arr_number,
    ss = map_string_string,
    _check_k = schema_base.check_k,
    _check_kv = schema_base.check_kv,
}
setmetatable(item, {
    __metatable = item_type,
})

user_type = setmetatable({}, {
    __tostring = function()
        return "schema_user"
    end,
})
user = {
    user_id = number,
    name = string,
    item = item,
    items = arr_item,
    mitems = map_number_number,
    _check_k = schema_base.check_k,
    _check_kv = schema_base.check_kv,
}
setmetatable(user, {
    __metatable = user_type,
})

return {
    map_string_string = map_string_string,
    map_number_number = map_number_number,
    arr_number = arr_number,
    arr_item = arr_item,
    item = item,
    user = user,
}
