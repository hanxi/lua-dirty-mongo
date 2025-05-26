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
--print(content)  -- 输出文件内容，或进行进一步处理

local pb = require("pb")
local protoc = require("protoc")
local tinsert = table.insert
local tconcat = table.concat
local sformat = string.format

-- 直接载入schema
assert(protoc:load(content))

function interp(s, tab)
    return (s:gsub("($%b{})", function(w)
        return tab[w:sub(3, -2)] or w
    end))
end

local head = sformat(
    [[
-- Auto generate from %s

local schema_base = require("schema_base")
local number = schema_base.number
local integer = schema_base.integer
local string = schema_base.string
local boolean = schema_base.boolean

]],
    filename
)

local defines = {}

local tmpl_message = [[
setmetatable(${name}_type, {
    __tostring = function()
        return "schema_${name}"
    end,
})
${fields_str}
${name}._check_k = schema_base.check_k
${name}._check_kv = schema_base.check_kv
setmetatable(${name}, {
    __metatable = ${name}_type,
})
]]

local tmpl_map = [[
setmetatable(map_${kv_type}_type, {
    __tostring = function()
        return "schema_map_${kv_type}"
    end,
})
map_${kv_type}._check_k = schema_base.check_k_func(${key_type})
map_${kv_type}._check_kv = schema_base.check_kv_func(${key_type}, ${value_type})
setmetatable(map_${kv_type}, {
    __metatable = map_${kv_type}_type,
    __index = function(t, k)
        return ${value_type}
    end,
})
]]

local tmpl_arr = [[
setmetatable(arr_${value_type}_type, {
    __tostring = function()
        return "schema_arr_${value_type}"
    end,
})
arr_${value_type}._check_k = schema_base.check_k_func(integer)
arr_${value_type}._check_kv = schema_base.check_kv_func(integer, ${value_type})
setmetatable(arr_${value_type}, {
    __metatable = arr_${value_type}_type,
    __index = function(t, k)
        return ${value_type}
    end,
})
]]

local returns = {}
tinsert(returns, "return {")

local bodys = {}

local type2name = {
    int32 = "integer",
    uint32 = "integer",
    int64 = "integer",
    uint64 = "integer",
    double = "number",
    float = "number",
    bool = "boolean",
    string = "string",
}

local map2name = {}
local maps = {}
for name, basename, type in pb.types() do
    if name:match(".google.*") == nil then
        if type == "map" then
            local _, _, key_type = pb.field(name, "key")
            if key_type:sub(1, 1) == "." then
                key_type = key_type:sub(2)
            end
            key_type = type2name[key_type] or key_type
            local _, _, value_type = pb.field(name, "value")
            if value_type:sub(1, 1) == "." then
                value_type = value_type:sub(2)
            end
            value_type = type2name[value_type] or value_type
            local kv_type = sformat("%s_%s", key_type, value_type)
            map2name[name] = kv_type
            if not maps[kv_type] then
                maps[kv_type] = true
                tinsert(bodys, interp(tmpl_map, { key_type = key_type, value_type = value_type, kv_type = kv_type }))
                tinsert(defines, sformat("local map_%s, map_%s_type = {}, {}", kv_type, kv_type))
                tinsert(returns, sformat("    map_%s = map_%s,", kv_type, kv_type))
            end
        end
    end
end

local arrs = {}
for name, basename, type in pb.types() do
    if name:match(".google.*") == nil then
        if type == "message" then
            local fields = {}
            for field_name, _, type, _, flag in pb.fields(name) do
                local tp_name = type:gsub("^%.", "")
                field_type = type2name[tp_name] or tp_name
                if flag ~= "optional" and not arrs[field_type] and not map2name[type] then
                    arrs[field_type] = true
                    tinsert(bodys, interp(tmpl_arr, { value_type = field_type }))
                    tinsert(defines, sformat("local arr_%s, arr_%s_type = {}, {}", field_type, field_type))
                    tinsert(returns, sformat("    arr_%s = arr_%s,", field_type, field_type))
                end
            end
        end
    end
end

for name, basename, type in pb.types() do
    if name:match(".google.*") == nil then
        print("message", name, basename, type)
        if type == "message" then
            tinsert(defines, sformat("local %s, %s_type = {}, {}", basename, basename))
            tinsert(returns, sformat("    %s = %s,", basename, basename))

            local fields = {}
            for field_name, _, type, _, flag in pb.fields(name) do
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
                tinsert(fields, sformat("%s.%s = %s", basename, field_name, field_type))
            end
            local fields_str = tconcat(fields, "\n")
            tinsert(bodys, interp(tmpl_message, { name = basename, fields_str = fields_str }))
        end

        for field_name, _, type, _, flag in pb.fields(name) do
            print("fields", field_name, type, flag)
        end
    end
end
tinsert(returns, "}")

local ret_content = head
    .. tconcat(defines, "\n")
    .. "\n\n"
    .. tconcat(bodys, "\n")
    .. "\n"
    .. tconcat(returns, "\n")
    .. "\n"
--print("=============")
--print(ret_content)

-- 写入文件内容
local outfilename = arg[2]

-- 检查文件名是否提供
if not outfilename then
    print("No out file provided")
    return
end

-- 打开文件
local outfile = io.open(outfilename, "w")

-- 检查文件是否成功打开
if not outfile then
    print("Cannot open file: " .. outfilename)
    return
end

-- 读取文件内容
local content = outfile:write(ret_content)
outfile:close()

print(sformat("succ generate file from %s to %s", filename, outfilename))
