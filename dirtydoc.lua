local next = next
local setmetatable = setmetatable
local getmetatable = getmetatable
local type = type
local rawset = rawset
local table = table

local dirtydoc = {}
local NULL = setmetatable({} , { __tostring = function() return "NULL" end })	-- nil
dirtydoc.null = NULL
local tracedoc_type = setmetatable({}, { __tostring = function() return "DIRTYDOC" end })
local tracedoc_len = setmetatable({} , { __mode = "kv" })


local function doc_len(doc)
	return #doc._stage
end

local function doc_next(doc, k)
	return next(doc._stage, k)
end

local function doc_pairs(doc)
	return pairs(doc._stage)
end

local function doc_ipairs(doc)
	return ipairs(doc._stage)
end

local function doc_unpack(doc, i, j)
	return table.unpack(doc._stage, i, j)
end

local function doc_concat(doc, sep, i, j)
	return table.concat(doc._stage, sep, i, j)
end

local function mark_dirty(doc)
	if not doc._dirty then
		doc._dirty = true
		local parent = doc._parent
		while parent do
			if parent._dirty then
				break
			end
			parent._dirty = true
			parent = parent._parent
		end
	end
end

local function doc_change_value(doc, k, v)
	if doc._schema ~= nil then
		if not doc._schema:_check_kv(k, v) then
			print("err doc_change_value", getmetatable(doc._schema), k, v, debug.traceback())
		end
	end
	if v ~= doc[k] then
		doc._changed_keys[k] = true -- mark changed (even nil)
		doc._changed_values[k] = doc._stage[k] -- lastversion value
		doc._stage[k] = v -- current value
		mark_dirty(doc)
	end
end

local function doc_change_recursively(doc, k, v)
	local lv = doc._stage[k]
	if getmetatable(lv) ~= tracedoc_type then
		lv = doc._changed_values[k]
		local schema = doc._schema and doc._schema[k]
		if getmetatable(lv) ~= tracedoc_type then
			-- last version is not a table, new a empty one
			lv = dirtydoc.new(nil, schema)
		else
			-- this version is clear first (not a dirtydoc), deepcopy lastversion one
			lv = dirtydoc.new(lv, schema)
		end

		if schema ~= nil and (not doc._schema:_check_kv(k, v._schema)) then
			print("err doc_change_recursively", k, v, getmetatable(v._schema), debug.traceback())
		end
		lv._parent = doc
		doc._stage[k] = lv
	end
	local keys = {}
	for k in pairs(lv) do
		keys[k] = true
	end
	-- deepcopy v
	for k,v in pairs(v) do
		lv[k] = v
		keys[k] = nil
	end
	-- clear keys not exist in v
	for k in pairs(keys) do
		lv[k] = nil
	end
	-- don't cache sub table into changed fields
	doc._changed_values[k] = nil
	doc._changed_keys[k] = nil
	lv._all_dirty = true
end

local function doc_change(doc, k, v)
	local recursively = false
	if type(v) == "table" then
		local vt = getmetatable(v)
		recursively = vt == nil or vt == tracedoc_type
	end

	if recursively then
		doc_change_recursively(doc, k, v)
	elseif doc[k] ~= v then
		doc_change_value(doc, k, v)
	end
end

-- refer to table.insert()
local function doc_insert(doc, index, v)
	local len = dirtydoc.len(doc)
	if v == nil then
		v = index
		index = len + 1
	end

	for i = len, index, -1 do
		doc[i + 1] = doc[i]
	end
	doc[index] = v
end

-- refer to table.remove()
local function doc_remove(doc, index)
	local len = dirtydoc.len(doc)
	index = index or len

	local v = doc[index]
	doc[index] = nil -- trig a clone of doc._lastversion[index] in doc_change()

	for i = index + 1, len do
		doc[i - 1] = doc[i]
	end	
	doc[len] = nil

	return v
end

dirtydoc.len = doc_len
dirtydoc.next = doc_next
dirtydoc.pairs = doc_pairs
dirtydoc.ipairs = doc_ipairs
dirtydoc.unpack = doc_unpack
dirtydoc.concat = doc_concat
dirtydoc.insert = doc_insert
dirtydoc.remove = doc_remove

function dirtydoc.new(init, schema)
	local doc_stage = {}
	local doc = {
		_dirty = false,
		_all_dirty = false,
		_parent = false,
		_changed_keys = {},
		_changed_values = {},
		_stage = doc_stage,
		_schema = schema,
	}
	setmetatable(doc, {
		__index = doc_stage, 
		__newindex = doc_change,
		__pairs = doc_pairs,
		__ipairs = doc_ipairs,
		__len = doc_len,
		__metatable = tracedoc_type,	-- avoid copy by ref
	})
	if init then
		for k,v in pairs(init) do
			-- deepcopy v
			if getmetatable(v) == tracedoc_type then
				doc[k] = dirtydoc.new(v)
			else
				doc[k] = v
			end
		end
	end
	return doc
end

function dirtydoc.check_type(doc)
	if type(doc) ~= "table" then return false end
	local mt = getmetatable(doc)
	return mt == tracedoc_type
end

local function _commit_mongo(doc, result, prefix)
	doc._dirty = false
	local changed_keys = doc._changed_keys
	local changed_values = doc._changed_values
	local stage = doc._stage
	local dirty = false
	if next(changed_keys) ~= nil then
		dirty = true
		for k in next, changed_keys do
			local v, lv = stage[k], changed_values[k]
			changed_keys[k] = nil
			changed_values[k] = nil
			if result then
				local key = prefix and prefix .. k or tostring(k)
				if v == nil then
					result["$unset"][key] = NULL
				else
					result["$set"][key] = v
				end
				result._n = result._n + 1
			end
		end
	end
	for k, v in pairs(stage) do
		if getmetatable(v) == tracedoc_type and v._dirty then
			if result then
				local key = prefix and prefix .. k or tostring(k)
				local change
				if v._all_dirty then
					change = _commit_mongo(v)
				else
					local n = result._n
					_commit_mongo(v, result, key .. ".")
					if n ~= result._n then
						change = true
					end
				end
				if change then
					if result["$set"][key] == nil and v._all_dirty then
						result["$set"][key] = v
						result._n = result._n + 1
					end
					dirty = true
				end

				v._all_dirty = false
			else
				local change = _commit_mongo(v)
				dirty = dirty or change
			end
		end
	end
	return result or dirty
end

function dirtydoc.commit_mongo(doc)
	local result = {
		["$set"] = {},
		["$unset"] = {},
		_n = 0,
	}
    local dirty = _commit_mongo(doc, result)
	result._n = nil
	return dirty, result
end

return dirtydoc
