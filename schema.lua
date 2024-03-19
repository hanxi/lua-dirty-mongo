local number_type = setmetatable({}, { __tostring = function() return "schema_number" end })
local number = setmetatable({}, {
	__metatable = number_type,
})

local str_type = setmetatable({}, { __tostring = function() return "schema_str" end })
local str = setmetatable({}, {
	__metatable = str_type,
})

local function _check_k(self, k)
	local schema = self[k]
	if not schema then
		print("not exist key:", k, debug.traceback())
		return false
	end
	return true
end

local function _check_kv(self, k, v)
	if v == nil then
		return true
	end

	local schema = self[k]
	if not schema then
		print("not exist key:", k, debug.traceback())
		return false
	end

	local tp = type(v)
	local real_tp
	if tp == "number" then
		real_tp = number_type
	elseif tp == "string" then
		real_tp = str_type
	elseif tp == "table" then
		real_tp = getmetatable(v)
	end
	if getmetatable(schema) ~= real_tp then
		print("not equal type. key:", k, ", need_tp:", getmetatable(schema), ", real_tp:", real_tp, debug.traceback())
		return false
	end
	return true
end

local item_type = setmetatable({}, { __tostring = function() return "schema_item" end })
local item = {
	item_id = number,
	_check_k = _check_k,
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
	_check_k = _check_k,
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
