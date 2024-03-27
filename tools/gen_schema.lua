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

-- 直接载入schema (这么写只是方便, 生产环境推荐使用 protoc.new() 接口)
assert(protoc:load(content))

for name, basename, type in pb.types() do
	if name:match(".google.*") == nil then
		print(name, basename, type)
		for field_name, _, type, _, flag  in pb.fields(name)  do
			print("fields", field_name, type, flag)
		end
	end
end
