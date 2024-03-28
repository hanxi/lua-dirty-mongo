local function dump_table(table, indent)
    indent = indent or ""
    -- 判断table是否为空
    if table == nil then
        return "nil"
    end

    -- 判断table是否为基础类型
    if type(table) ~= "table" then
        return tostring(table)
    end

    -- 初始化输出字符串
    local output = "{\n"

    -- 遍历table中的所有键值对
    for k, v in pairs(table) do
        -- 缩进
        output = output .. indent .. "  "

        -- 转储键
        output = output .. tostring(k) .. " = "

        -- 转储值
        output = output .. dump_table(v, indent .. "  ") .. ",\n"
    end

    -- 缩进
    output = output .. indent .. "}"

    -- 返回输出字符串
    return output
end

return dump_table
