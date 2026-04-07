function join_tables(t1, t2, deduplicate)
    if deduplicate == nil then
        deduplicate = true
    end
    local result = {}
    local time_index = {}
    if deduplicate then
        for i, v in ipairs(t1) do
            if type(v) == "userdata" and v.StartTime then
                time_index[v.StartTime] = #result + 1
                table.insert(result, v)
            else
                table.insert(result, v)
            end
        end
        for i, v in ipairs(t2) do
            if type(v) == "userdata" and v.StartTime then
                if time_index[v.StartTime] then
                    result[time_index[v.StartTime]] = v
                else
                    time_index[v.StartTime] = #result + 1
                    table.insert(result, v)
                end
            else
                table.insert(result, v)
            end
        end
    else
        for i, v in ipairs(t1) do
            table.insert(result, v)
        end
        for i, v in ipairs(t2) do
            table.insert(result, v)
        end
    end
    return result
end

function switch(x, a, b)
    if x then
        return a
    else
        return b
    end
end

function diff(array1, array2)
    local result = {}
    local lookup = {}
    for i = 1, #array2 do
        lookup[array2[i]] = true
    end
    for i = 1, #array1 do
        if not lookup[array1[i]] then
            table.insert(result, array1[i])
        end
    end
    return result
end

function not_has(t, v)
    for _, v2 in pairs(t) do
        if v2 == v then
            return false
        end
    end
    return true
end

function indexof(t, v)
    for i, v2 in ipairs(t) do
        if v2 == v then
            return i
        end
    end
    return -1
end

function max(t)
    local max_v = t[1]
    for i = 2, #t do
        if t[i] > max_v then
            max_v = t[i]
        end
    end
    return max_v
end

function min(t)
    local min_v = t[1]
    for i = 2, #t do
        if t[i] < min_v then
            min_v = t[i]
        end
    end
    return min_v
end

