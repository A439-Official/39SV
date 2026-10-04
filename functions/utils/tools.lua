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

function binary_search(array, value, key)
    if #array == 0 then
        return nil
    end
    local low, high = 1, #array
    while low <= high do
        local mid = math.floor((low + high) / 2)
        local current = key and array[mid][key] or array[mid]

        if current < value then
            low = mid + 1
        else
            high = mid - 1
        end
    end
    if low <= #array then
        local current = key and array[low][key] or array[low]
        if current == value then
            return low
        else
            if low - 1 >= 1 then
                return low - 1
            else
                return nil
            end
        end
    else
        return #array
    end
end

function deepcopy(orig)
    local copies = {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            return copies[orig]
        end
        copy = {}
        copies[orig] = copy
        for key, value in next, orig, nil do
            copy[deepcopy(key, copies)] = deepcopy(value, copies)
        end
        setmetatable(copy, deepcopy(getmetatable(orig), copies))
    else
        copy = orig
    end
    return copy
end

function deepcompare(t1, t2)
    local ty1 = type(t1)
    local ty2 = type(t2)
    if ty1 ~= ty2 then
        return false
    end
    if ty1 ~= 'table' and ty2 ~= 'table' then
        return t1 == t2
    end
    local mt = getmetatable(t1)
    for k1, v1 in pairs(t1) do
        local v2 = t2[k1]
        if v2 == nil or not deepcompare(v1, v2) then
            return false
        end
    end
    for k2, v2 in pairs(t2) do
        local v1 = t1[k2]
        if v1 == nil then
            return false
        end
    end

    return true
end

function isNaN(x)
    return type(x) == "number" and x ~= x
end

function to_f32(x)
    if x == 0 then
        return 0
    end
    local _, exp = math.frexp(x)
    local step = 2 ^ (exp - 24)
    return math.floor(x / step + 0.5) * step
end
