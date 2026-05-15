function get_sv(t)
    local index = binary_search(map.ScrollVelocities, t, "StartTime")
    return index and map.ScrollVelocities[index].Multiplier or 1
end

function get_bpm(t)
    local lb
    for _, tp in ipairs(map.TimingPoints) do
        if tp.StartTime <= t then
            lb = tp.Bpm
        else
            break
        end
    end
    return lb or map.TimingPoints[1].Bpm
end

function get_ssf(t)
    if #map.ScrollSpeedFactors == 0 then
        return 1
    end
    if t <= map.ScrollSpeedFactors[1].StartTime then
        return 1
    end
    for i = 1, #map.ScrollSpeedFactors - 1 do
        local current = map.ScrollSpeedFactors[i]
        local next = map.ScrollSpeedFactors[i + 1]
        if t >= current.StartTime and t <= next.StartTime then
            local ratio = (t - current.StartTime) / (next.StartTime - current.StartTime)
            return current.Multiplier + (next.Multiplier - current.Multiplier) * ratio
        end
    end
    return map.ScrollSpeedFactors[#map.ScrollSpeedFactors].Multiplier
end

function get_sv_distance(t1, t2)
    if not t2 then
        t2 = 0
    end
    if #vars.cacheSVDists == 0 then
        local lt, d, ls = map.ScrollVelocities[1].StartTime, 0, 1
        for _, sv in ipairs(map.ScrollVelocities) do
            d = d + (sv.StartTime - lt) * ls
            lt = sv.StartTime
            ls = sv.Multiplier
            table.insert(vars.cacheSVDists, {sv.StartTime, d, sv.Multiplier})
        end
    end
    local d1, d2 = nil, nil

    local function get_distance(t, index)
        if index == 1 then
            return t - vars.cacheSVDists[1][1]
        else
            local lt, ld, ls = unpack(vars.cacheSVDists[index])
            return ld + (t - lt) * ls
        end
    end

    local i1 = binary_search(vars.cacheSVDists, t1, 1)
    if i1 then
        d1 = get_distance(t1, i1)
    end

    local i2 = binary_search(vars.cacheSVDists, t2, 1)
    if i2 then
        d2 = get_distance(t2, i2)
    end
    return d2 - d1
end

function select_time(t)
    for _, h in ipairs(map.HitObjects) do
        if math.abs(h.StartTime - t) < 1 then
            return h.StartTime
        end
    end
    for _, h in ipairs(map.HitObjects) do
        if math.abs(h.EndTime - t) < 1 then
            return h.EndTime
        end
    end
    return t
end

