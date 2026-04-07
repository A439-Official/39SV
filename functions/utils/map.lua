function get_sv(t)
    local s = 1
    for _, sv in ipairs(map.ScrollVelocities) do
        if sv.StartTime <= t then
            s = sv.Multiplier
        else
            break
        end
    end
    return s
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
    local reverse = false
    if not t2 then
        t2 = 0
    end
    if t1 > t2 then
        t1, t2 = t2, t1
        reverse = true
    end
    local d, lt, ls = 0, t1, 1
    for _, sv in ipairs(map.ScrollVelocities) do
        if sv.StartTime > t2 then
            break
        elseif sv.StartTime > t1 then
            d = d + (sv.StartTime - lt) * ls
            lt = sv.StartTime
            ls = sv.Multiplier
        elseif sv.StartTime <= t1 then
            ls = sv.Multiplier
            lt = math.max(lt, sv.StartTime)
        end
    end
    if lt < t2 then
        d = d + (t2 - lt) * ls
    end
    if reverse then
        d = -d
    end
    return d
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

