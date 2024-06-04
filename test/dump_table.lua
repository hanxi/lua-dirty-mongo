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
    local hasElements = false
    for k, v in pairs(t) do
        hasElements = true
        local keyString = type(k) == "string" and string.format("[%q]", k) or "[" .. tostring(k) .. "]"
        local nextPath = path .. "." .. tostring(k)
        -- 追加键和值
        output = output .. nextIndent .. keyString .. " = " .. dump_table(v, nextIndent, visited, nextPath) .. ",\n"
    end

    if hasElements then
        output = output:sub(1, -2) -- 移除最后一个逗号和换行
    end

    output = output .. "\n" .. indent .. "}"

    -- 如果路径为root，说明递归回到了最顶层，清除visited记录
    if path == "root" then
        for k in pairs(visited) do visited[k] = nil end
    end
    return output
end

return dump_table
