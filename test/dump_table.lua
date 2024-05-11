local function dump_table(t, indent, visited)
    indent = indent or ""
    visited = visited or {}

    -- 判断table是否为空
    if t == nil then
        return "nil"
    end
    -- 判断t是否为基础类型
    if type(t) ~= "table" then
        if type(t) == "string" then
            -- 为字符串值加上双引号
            return string.format("%q", t) -- 更健壮的字符串转义方式
        else
            return tostring(t)
        end
    end

    if visited[t] then
        return "<circular reference>"
    end
    visited[t] = true  -- 标记当前表为已访问

    -- 初始化输出字符串
    local output = "{\n"
    local nextIndent = indent .. "  "
    -- 遍历t中的所有键值对
    for k, v in pairs(t) do
        local keyString = type(k) == "string" and string.format("[%q]", k) or "[" .. tostring(k) .. "]"
        -- 转储键和值
        output = output .. nextIndent .. keyString .. " = " .. dump_table(v, nextIndent, visited) .. ",\n"
    end
    -- 去除最后一个逗号
    output = output:sub(1, -3) .. "\n" .. indent .. "}"
    -- 返回前取消当前表的访问标记以应对同一个表多次引用的情况
    visited[t] = nil
    return output
end

local function dump_table(t, indent, visited, path)
    indent = indent or ""
    visited = visited or {}
    path = path or "root"

    -- 判断table是否为空
    if t == nil then
        return "nil"
    end
    -- 处理非table类型
    if type(t) ~= "table" then
        if type(t) == "string" then
            -- 为字符串值加上双引号
            return string.format("%q", t)
        else
            return tostring(t)
        end
    end

    -- 检测循环引用
    if visited[t] then
        return "<circular reference to " .. visited[t] .. ">"
    end
    visited[t] = path

    -- 初始化输出字符串
    local output = "{\n"
    local nextIndent = indent .. "  "
    for k, v in pairs(t) do
        local keyString = type(k) == "string" and string.format("[%q]", k) or "[" .. tostring(k) .. "]"
        local nextPath = path .. "." .. tostring(k)
        -- 追加键和值
        output = output .. nextIndent .. keyString .. " = " .. dump_table(v, nextIndent, visited, nextPath) .. ",\n"
    end
    output = output:sub(1, -3) .. "\n" .. indent .. "}"

    -- 如果路径为root，说明递归回到了最顶层，清除visited记录
    if path == "root" then
        for k in pairs(visited) do visited[k] = nil end
    end

    return output
end

return dump_table
