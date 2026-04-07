function split(s, d)
    d = d or "\n"
    local r, f = {}, 1
    local dp, dp2
    while true do
        dp, dp2 = s:find(d, f, true)
        if not dp then
            table.insert(r, s:sub(f))
            break
        end
        table.insert(r, s:sub(f, dp - 1))
        f = dp2 + 1
    end
    return r
end

function paramNumber(text, x)
    if not text then
        return 0
    end

    -- 分离参数列表和序列字符串
    local params_str, seq_str
    local pipe_pos = text:find("|")
    if pipe_pos then
        params_str = text:sub(1, pipe_pos - 1)
        seq_str = text:sub(pipe_pos + 1)
    else
        params_str = text
        seq_str = "+"
    end

    -- 解析原始参数
    local raw_params = split(params_str, ",")
    local n = #raw_params
    if n == 0 then
        return 0
    end

    local num_params = {}
    for i = 1, n do
        num_params[i] = tonumber(raw_params[i])
        if not num_params[i] then
            return 0
        end
    end

    -- 镜像函数
    local function mirror(params)
        local m = #params
        if m == 1 then
            return {params[1]}
        elseif m == 2 then
            return {params[2], params[1]}
        elseif m == 4 then
            local p1x, p1y, p2x, p2y = params[1], params[2], params[3], params[4]
            return {1 - p2x, 1 - p2y, 1 - p1x, 1 - p1y}
        elseif m == 6 then
            local s, e, p1x, p1y, p2x, p2y = params[1], params[2], params[3], params[4], params[5], params[6]
            return {e, s, 1 - p2x, 1 - p2y, 1 - p1x, 1 - p1y}
        else
            return params
        end
    end

    -- 解析序列
    local seq_chars = {}
    for i = 1, #seq_str do
        seq_chars[i] = seq_str:sub(i, i)
    end
    local num_segments = #seq_chars
    if num_segments == 0 then
        num_segments = 1
        seq_chars = {"+"}
    end

    -- 预计算每个区间的参数
    local segment_params = {}
    for i = 1, num_segments do
        if seq_chars[i] == '+' then
            segment_params[i] = num_params
        elseif seq_chars[i] == '-' then
            segment_params[i] = mirror(num_params)
        else
            segment_params[i] = num_params
        end
    end

    -- 确定区间索引和局部进度 t
    local seg_idx
    local t
    if x >= 1 then
        seg_idx = num_segments
        t = 1
    else
        seg_idx = math.floor(x * num_segments) + 1
        if seg_idx > num_segments then
            seg_idx = num_segments
        end
        -- 区间长度 = 1 / num_segments
        local start = (seg_idx - 1) / num_segments
        t = (x - start) * num_segments
    end

    local params = segment_params[seg_idx]
    local m = #params

    if m == 1 then
        return params[1]
    elseif m == 2 then
        local start, finish = params[1], params[2]
        return start + (finish - start) * t
    elseif m == 4 then
        local p1x, p1y, p2x, p2y = params[1], params[2], params[3], params[4]
        return bezier(t, p1x, p1y, p2x, p2y)
    elseif m == 6 then
        local s, e, p1x, p1y, p2x, p2y = params[1], params[2], params[3], params[4], params[5], params[6]
        return s + (e - s) * bezier(t, p1x, p1y, p2x, p2y)
    else
        return 0
    end
end
