local schema_base = require "schema_base"
local number = schema_base.number
local str = schema_base.str

local item_type
local map_number_number_type
local map_str_str_type
local map_number_item_type
local arr_item_type

local item
local map_number_number
local map_str_str
local map_number_item
local user_type
local user
local arr_item

item_type = setmetatable({}, { __tostring = function() return "schema_item" end })
item = {
	item_id = number,
	_check_k = schema_base.check_k,
	_check_kv = schema_base.check_kv,
}
setmetatable(item, {
	__metatable = item_type,
})

user_type = setmetatable({}, { __tostring = function() return "schema_user" end })
user = {
	user_id = number,
	item = item,
	name = str,
	_check_k = schema_base.check_k,
	_check_kv = schema_base.check_kv,
}
setmetatable(user, {
	__metatable = user_type,
})

map_number_number_type = setmetatable({}, { __tostring = function() return "schema_map_number_number" end })
map_number_number = {
	_check_k = schema_base.check_k_func(number),
	_check_kv = schema_base.check_kv_func(number, number),
}
setmetatable(map_number_number, {
	__metatable = map_number_number_type,
})

map_str_str_type = setmetatable({}, { __tostring = function() return "schema_map_str_str" end })
map_str_str = {
	_check_k = schema_base.check_k_func(str),
	_check_kv = schema_base.check_kv_func(str, str),
}
setmetatable(map_str_str, {
	__metatable = map_str_str_type,
})

map_number_item_type = setmetatable({}, { __tostring = function() return "schema_map_number_item" end })
map_number_item = {
	_check_k = schema_base.check_k_func(number),
	_check_kv = schema_base.check_kv_func(number, item),
}
setmetatable(map_number_item, {
	__metatable = map_number_item_type,
})

arr_item_type = setmetatable({}, { __tostring = function() return "schema_arr_item" end })
arr_item = {
	_check_k = schema_base.check_k_func(number),
	_check_kv = schema_base.check_kv_func(number, item),
}
setmetatable(arr_item, {
	__metatable = arr_item_type,
})


return {
	number            = number,
	str               = str,
	item              = item,
	map_number_number = map_number_number,
	map_str_str       = map_str_str,
	map_number_item   = map_number_item,
	user_type         = user_type,
	user              = user,
	arr_item          = arr_item,
}
