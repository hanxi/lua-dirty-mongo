-- 测试命令 lua tools/gen_schema.lua test/schema.proto test/schema.lua

-- 获取脚本所在的完整路径
local script_path = arg[0]

-- 检测路径是否完整
if script_path:match(".+%.lua") then
  -- 如果 arg[0] 包含 .lua 后缀，尝试获取完整路径
  script_path = debug.getinfo(1).source:sub(2)
else
  -- 如果 arg[0] 不含后缀，可能是在命令行直接调用
  if script_path:match("(.+)/[^/]+$") then
    script_path = script_path:match("(.+)/[^/]+$")
  else
    script_path = "."
  end
end

-- 从脚本路径中提取目录
local script_directory = script_path:match("(.*/)") or "./"

-- 将脚本所在目录添加到 package.cpath
package.cpath = package.cpath .. ";" .. script_directory .. "?.so;" .. script_directory .. "?.dll"
package.path = package.path .. ";" .. script_directory .. "lua-protobuf/?.lua"

print(package.cpath) -- 输出修改后的 cpath，用于调试
print(package.path) -- 输出修改后的 path，用于调试


-- 读取 proto 文件内容
local filename = arg[1]

-- 检查文件名是否提供
if not filename then
  print("No .proto file provided")
  return
end

-- 打开文件
local file = io.open(filename, "r")

-- 检查文件是否成功打开
if not file then
  print("Cannot open file: " .. filename)
  return
end

-- 读取文件内容
local content = file:read("*all")
file:close()

-- 处理文件内容
print(content)  -- 输出文件内容，或进行进一步处理


local pb = require "pb"
local protoc = require "protoc"
local tinsert = table.insert
local tconcat = table.concat
local sformat = string.format

-- 直接载入schema (这么写只是方便, 生产环境推荐使用 protoc.new() 接口)
assert(protoc:load(content))

local head = [[
local schema_base = require "schema_base"
local number = schema_base.number
local string = schema_base.string
local boolean = schema_base.boolean

]]

local defines = {}

local tmpl_message = [[
%s_type = setmetatable({}, { __tostring = function() return "schema_%s" end })
item = {
%s
    _check_k = schema_base.check_k,
    _check_kv = schema_base.check_kv,
}
setmetatable(%s, {
    __metatable = %s_type,
})
]]

local tmpl_map = [[
map_number_item_type = setmetatable({}, { __tostring = function() return "schema_map_number_item" end })
map_number_item = {
	_check_k = schema_base.check_k_func(number),
	_check_kv = schema_base.check_kv_func(number, item),
}
setmetatable(map_number_item, {
	__metatable = map_number_item_type,
})
]]

local bodys = {}

local type2name = {
	int32 = "number",
	uint32 = "number",
	int64 = "number",
	uint64 = "number",
	double = "number",
	float = "number",
	bool = "boolean",
	string = "string",
}

local map2name = {}
for name, basename, type in pb.types() do
	if name:match(".google.*") == nil then
		if type == "map" then
			local _, _, key_type = pb.field(name, "key")
			key_type = type2name[key_type] or key_type
			local _, _, value_type = pb.field(name, "key")
			value_type = type2name[value_type] or value_type
			map2name[name] = sformat("%s_%s", key_type, value_type)

			tinsert(bodys, )
		end
	end
end

for name, basename, type in pb.types() do
	if name:match(".google.*") == nil then
		print(name, basename, type)
		if type == "message" then
			tinsert(defines, sformat("local %s, %s_type", basename, basename))

			local fields = {}
			for field_name, _, type, _, flag  in pb.fields(name)  do
				print("fields", field_name, type, flag)
				local tp_name = type:gsub("^%.", "")
				local field_type
				if flag == "optional" then
					field_type = type2name[tp_name] or tp_name
				else
					if map2name[type] then
						field_type = sformat("map_%s", map2name[type])
					else
						field_type = sformat("arr_%s", type2name[tp_name] or tp_name)
					end
				end
				tinsert(fields, sformat("    %s = %s,", field_name, field_type))
			end
			local fields_str = tconcat(fields, "\n")
			tinsert(bodys, sformat(tmpl_message, basename, basename, fields_str, basename, basename))
		end

		for field_name, _, type, _, flag  in pb.fields(name)  do
			print("fields", field_name, type, flag)
		end
	end
end

local ret = head .. tconcat(defines, "\n") .. "\n\n" .. tconcat(bodys, "\n")
print("=============")
print(ret)
