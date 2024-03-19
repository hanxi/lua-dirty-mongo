local number_type = setmetatable({}, { __tostring = function() return "schema_number" end })
local number = setmetatable({}, {
	__metatable = number_type,
})

local str_type = setmetatable({}, { __tostring = function() return "schema_str" end })
local str = setmetatable({}, {
	__metatable = str_type,
})

local function _check_kv(self, k, v)
	if v == nil then
		return true
	end
	local schema = self[k]
	if not schema then
		print("check_kv", k, v)
		return false
	end
	local tp = type(v)
	print("check_kv", tp)
	if tp == "number" then
		print("check_kv", getmetatable(schema), number_type)
		return getmetatable(schema) == number_type
	elseif tp == "string" then
		print("check_kv", getmetatable(schema), str_type)
		return getmetatable(schema) == str_type
	elseif tp == "table" then
		print("check_kv", getmetatable(schema), getmetatable(v))
		return getmetatable(schema) == getmetatable(v)
	end
	return false
end

local item_type = setmetatable({}, { __tostring = function() return "schema_item" end })
local item = {
	item_id = number,
	_check_kv = _check_kv,
}
setmetatable(item, {
	__metatable = item_type,
})

local user_type = setmetatable({}, { __tostring = function() return "schema_user" end })
local user = {
	user_id = number,
	item = item,
	name = str,
	_check_kv = _check_kv,
}
setmetatable(user, {
	__metatable = user_type,
})

return {
	number = number,
	item = item,
	user = user,
}
