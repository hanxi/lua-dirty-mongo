-- Auto generate from test/schema.proto

local schema_base = require("schema_base")
local number = schema_base.number
local integer = schema_base.integer
local string = schema_base.string
local boolean = schema_base.boolean

local map_string_string, map_string_string_type = {}, {}
local map_integer_integer, map_integer_integer_type = {}, {}
local map_integer_item, map_integer_item_type = {}, {}
local arr_integer, arr_integer_type = {}, {}
local arr_item, arr_item_type = {}, {}
local item, item_type = {}, {}
local user, user_type = {}, {}

setmetatable(map_string_string_type, {
    __tostring = function()
        return "schema_map_string_string"
    end,
})
map_string_string._check_k = schema_base.check_k_func(string)
map_string_string._check_kv = schema_base.check_kv_func(string, string)
setmetatable(map_string_string, {
    __metatable = map_string_string_type,
    __index = function(t, k)
        return string
    end,
})

setmetatable(map_integer_integer_type, {
    __tostring = function()
        return "schema_map_integer_integer"
    end,
})
map_integer_integer._check_k = schema_base.check_k_func(integer)
map_integer_integer._check_kv = schema_base.check_kv_func(integer, integer)
setmetatable(map_integer_integer, {
    __metatable = map_integer_integer_type,
    __index = function(t, k)
        return integer
    end,
})

setmetatable(map_integer_item_type, {
    __tostring = function()
        return "schema_map_integer_item"
    end,
})
map_integer_item._check_k = schema_base.check_k_func(integer)
map_integer_item._check_kv = schema_base.check_kv_func(integer, item)
setmetatable(map_integer_item, {
    __metatable = map_integer_item_type,
    __index = function(t, k)
        return item
    end,
})

setmetatable(arr_integer_type, {
    __tostring = function()
        return "schema_arr_integer"
    end,
})
arr_integer._check_k = schema_base.check_k_func(integer)
arr_integer._check_kv = schema_base.check_kv_func(integer, integer)
setmetatable(arr_integer, {
    __metatable = arr_integer_type,
    __index = function(t, k)
        return integer
    end,
})

setmetatable(arr_item_type, {
    __tostring = function()
        return "schema_arr_item"
    end,
})
arr_item._check_k = schema_base.check_k_func(integer)
arr_item._check_kv = schema_base.check_kv_func(integer, item)
setmetatable(arr_item, {
    __metatable = arr_item_type,
    __index = function(t, k)
        return item
    end,
})

setmetatable(item_type, {
    __tostring = function()
        return "schema_item"
    end,
})
item.item_id = integer
item.props = map_integer_integer
item.list = arr_integer
item.ss = map_string_string
item.can = boolean
item._check_k = schema_base.check_k
item._check_kv = schema_base.check_kv
setmetatable(item, {
    __metatable = item_type,
})

setmetatable(user_type, {
    __tostring = function()
        return "schema_user"
    end,
})
user.user_id = integer
user.name = string
user.item = item
user.items = arr_item
user.mitems = map_integer_item
user._check_k = schema_base.check_k
user._check_kv = schema_base.check_kv
setmetatable(user, {
    __metatable = user_type,
})

return {
    map_string_string = map_string_string,
    map_integer_integer = map_integer_integer,
    map_integer_item = map_integer_item,
    arr_integer = arr_integer,
    arr_item = arr_item,
    item = item,
    user = user,
}
