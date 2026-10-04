function get_all_sv()
    if vars.cacheSVs == nil then
        vars.cacheSVs = {}
        for _, sv in ipairs(map.ScrollVelocities) do
            table.insert(vars.cacheSVs, sv)
        end
        return vars.cacheSVs
    else
        return vars.cacheSVs
    end
end

function clear_sv_cache()
    vars.cacheSVSearch = {}
    vars.cacheSVs = nil
    vars.cacheSVsDirty = false
end

function get_all_ssf()
    if vars.cacheSSFs == nil then
        vars.cacheSSFs = {}
        for _, ssf in ipairs(map.ScrollSpeedFactors) do
            table.insert(vars.cacheSSFs, ssf)
        end
        return vars.cacheSSFs
    else
        return vars.cacheSSFs
    end
end

function clear_ssf_cache()
    vars.cacheSSFs = nil
    vars.cacheSSFDirty = false
end

function add_ssf_batch(ssfs)
    if vars.cacheSSFs == nil then
        get_all_ssf()
    end
    local index = {}
    for i, ssf in ipairs(vars.cacheSSFs) do
        index[ssf.StartTime] = i
    end

    for _, ssf in ipairs(ssfs) do
        local idx = index[ssf.StartTime]

        if idx then
            vars.cacheSSFs[idx] = ssf
        else
            table.insert(vars.cacheSSFs, ssf)
            index[ssf.StartTime] = #vars.cacheSSFs
        end
    end

    table.sort(vars.cacheSSFs, function(a, b)
        return a.StartTime < b.StartTime
    end)

    vars.cacheSSFDirty = true
end

function remove_ssf_batch(ssfs)
    if vars.cacheSSFs == nil then
        get_all_ssf()
    end
    local remove_times = {}
    for _, ssf in ipairs(ssfs) do
        remove_times[ssf.StartTime] = true
    end

    local new_ssfs = {}
    for _, ssf in ipairs(vars.cacheSSFs) do
        if not remove_times[ssf.StartTime] then
            table.insert(new_ssfs, ssf)
        end
    end

    vars.cacheSSFs = new_ssfs
    vars.cacheSSFDirty = true
end

function sync_ssf_cache()
    if vars.cacheSSFs == nil or not vars.cacheSSFDirty then
        return
    end

    local added = {}
    local removed = {}

    local original = {}
    for _, ssf in ipairs(map.ScrollSpeedFactors) do
        original[ssf.StartTime] = ssf.Multiplier
    end

    local cached = {}
    for _, ssf in ipairs(vars.cacheSSFs) do
        cached[ssf.StartTime] = ssf.Multiplier
    end

    for _, ssf in ipairs(map.ScrollSpeedFactors) do
        local newMultiplier = cached[ssf.StartTime]
        if newMultiplier == nil then
            table.insert(removed, ssf)
        elseif math.abs(newMultiplier - ssf.Multiplier) > 0.0001 then
            table.insert(removed, ssf)
            table.insert(added, utils.CreateScrollSpeedFactor(ssf.StartTime, newMultiplier))
        end
    end

    for _, ssf in ipairs(vars.cacheSSFs) do
        if original[ssf.StartTime] == nil then
            table.insert(added, ssf)
        end
    end

    local batchActions = {}

    if #removed > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.RemoveScrollSpeedFactorBatch, removed))
        print("Removed " .. #removed .. " ssf")
    end
    if #added > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.AddScrollSpeedFactorBatch, added))
        print("Added " .. #added .. " ssf")
    end
    if #batchActions > 0 then
        actions.PerformBatch(batchActions)
    end

    vars.cacheSSFDirty = false
end

function get_all_tp()
    if vars.cacheTPs == nil then
        vars.cacheTPs = {}
        for _, tp in ipairs(map.TimingPoints) do
            table.insert(vars.cacheTPs, tp)
        end
        return vars.cacheTPs
    else
        return vars.cacheTPs
    end
end

function clear_tp_cache()
    vars.cacheTPs = nil
    vars.cacheTPsDirty = false
end

function add_tp_batch(tps)
    if vars.cacheTPs == nil then
        get_all_tp()
    end
    local index = {}
    for i, tp in ipairs(vars.cacheTPs) do
        index[tp.StartTime] = i
    end

    for _, tp in ipairs(tps) do
        local idx = index[tp.StartTime]

        if idx then
            vars.cacheTPs[idx] = tp
        else
            table.insert(vars.cacheTPs, tp)
            index[tp.StartTime] = #vars.cacheTPs
        end
    end

    table.sort(vars.cacheTPs, function(a, b)
        return a.StartTime < b.StartTime
    end)

    vars.cacheTPsDirty = true
end

function remove_tp_batch(tps)
    if vars.cacheTPs == nil then
        get_all_tp()
    end
    local remove_times = {}
    for _, tp in ipairs(tps) do
        remove_times[tp.StartTime] = true
    end

    local new_tps = {}
    for _, tp in ipairs(vars.cacheTPs) do
        if not remove_times[tp.StartTime] then
            table.insert(new_tps, tp)
        end
    end

    vars.cacheTPs = new_tps
    vars.cacheTPsDirty = true
end

function sync_tp_cache()
    if vars.cacheTPs == nil or not vars.cacheTPsDirty then
        return
    end

    local added = {}
    local removed = {}

    local original = {}
    for _, tp in ipairs(map.TimingPoints) do
        original[tp.StartTime] = tp.Bpm
    end

    local cached = {}
    for _, tp in ipairs(vars.cacheTPs) do
        cached[tp.StartTime] = tp.Bpm
    end

    for _, tp in ipairs(map.TimingPoints) do
        local newBpm = cached[tp.StartTime]
        if newBpm == nil then
            table.insert(removed, tp)
        elseif math.abs(newBpm - tp.Bpm) > 0.0001 then
            table.insert(removed, tp)
            table.insert(added, utils.CreateTimingPoint(tp.StartTime, newBpm))
        end
    end

    for _, tp in ipairs(vars.cacheTPs) do
        if original[tp.StartTime] == nil then
            table.insert(added, tp)
        end
    end

    local batchActions = {}

    if #removed > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.RemoveTimingPointBatch, removed))
        print("Removed " .. #removed .. " tp")
    end
    if #added > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.AddTimingPointBatch, added))
        print("Added " .. #added .. " tp")
    end
    if #batchActions > 0 then
        actions.PerformBatch(batchActions)
    end

    vars.cacheTPsDirty = false
end

function add_sv_batch(svs)
    if vars.cacheSVs == nil then
        get_all_sv()
    end
    local index = {}
    for i, sv in ipairs(vars.cacheSVs) do
        index[sv.StartTime] = i
    end

    for _, sv in ipairs(svs) do
        local idx = index[sv.StartTime]

        if idx then
            vars.cacheSVs[idx] = sv
        else
            table.insert(vars.cacheSVs, sv)
            index[sv.StartTime] = #vars.cacheSVs
        end
    end

    table.sort(vars.cacheSVs, function(a, b)
        return a.StartTime < b.StartTime
    end)

    vars.cacheSVsDirty = true
    vars.cacheSVSearch = {}
end

function remove_sv_batch(svs)
    if vars.cacheSVs == nil then
        get_all_sv()
    end
    local remove_times = {}
    for _, sv in ipairs(svs) do
        remove_times[sv.StartTime] = true
    end

    local new_svs = {}
    for _, sv in ipairs(vars.cacheSVs) do
        if not remove_times[sv.StartTime] then
            table.insert(new_svs, sv)
        end
    end

    vars.cacheSVs = new_svs
    vars.cacheSVsDirty = true
    vars.cacheSVSearch = {}
end

function sync_sv_cache()
    if vars.cacheSVs == nil or not vars.cacheSVsDirty then
        return
    end

    local added = {}
    local removed = {}

    local original = {}
    for _, sv in ipairs(map.ScrollVelocities) do
        original[sv.StartTime] = sv.Multiplier
    end

    local cached = {}
    for _, sv in ipairs(vars.cacheSVs) do
        cached[sv.StartTime] = sv.Multiplier
    end

    for _, sv in ipairs(map.ScrollVelocities) do
        local newMultiplier = cached[sv.StartTime]
        if newMultiplier == nil then
            table.insert(removed, sv)
        elseif math.abs(newMultiplier - sv.Multiplier) > 0.0001 then
            table.insert(removed, sv)
            table.insert(added, utils.CreateScrollVelocity(sv.StartTime, newMultiplier))
        end
    end

    for _, sv in ipairs(vars.cacheSVs) do
        if original[sv.StartTime] == nil then
            table.insert(added, sv)
        end
    end

    local batchActions = {}

    if #removed > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, removed))
        print("Removed " .. #removed .. " sv")
    end
    if #added > 0 then
        table.insert(batchActions, utils.CreateEditorAction(action_type.AddScrollVelocityBatch, added))
        print("Added " .. #added .. " sv")
    end
    if #batchActions > 0 then
        actions.PerformBatch(batchActions)
    end

    vars.cacheSVsDirty = false
end

function get_sv(t)
    local sv = get_all_sv()
    if #sv == 0 then
        return 1
    end
    if sv[1].StartTime > t then
        return 1
    end
    local idx = sv_search(t)
    return sv[idx].Multiplier or 1
end

function get_bpm(t)
    local tp = get_all_tp()
    local lb
    for _, tp in ipairs(tp) do
        if tp.StartTime <= t then
            lb = tp.Bpm
        else
            break
        end
    end
    return lb or tp[1].Bpm
end

function get_ssf(t)
    local ssf = get_all_ssf()
    if #ssf == 0 then
        return 1
    end
    if t <= ssf[1].StartTime then
        return 1
    end
    for i = 1, #ssf - 1 do
        local current = ssf[i]
        local next = ssf[i + 1]
        if t >= current.StartTime and t <= next.StartTime then
            local ratio = (t - current.StartTime) / (next.StartTime - current.StartTime)
            return current.Multiplier + (next.Multiplier - current.Multiplier) * ratio
        end
    end
    return ssf[#ssf].Multiplier
end

function get_sv_distance(t1, t2)
    if not t2 then
        t2 = 0
    end

    -- Handle reverse direction: swap and negate
    if t2 < t1 then
        return -get_sv_distance(t2, t1)
    end

    local sv = get_all_sv()
    if #sv == 0 then
        return t2 - t1
    end

    -- Find the SV index at or before t1
    local idx = sv_search(t1)
    if not idx then
        return t2 - t1
    end

    local distance = 0
    local current_time = t1
    local current_mult = sv[idx].Multiplier or 1

    -- Iterate forward from idx through SV points until t2
    for i = idx, #sv do
        local sv_point = sv[i]
        local sv_time = sv_point.StartTime

        -- Skip SV points at or before t1, only update multiplier
        if sv_time <= t1 then
            current_mult = sv_point.Multiplier or 1
        else
            if sv_time > t2 then
                break
            end

            distance = distance + (sv_time - current_time) * current_mult
            current_time = sv_time
            current_mult = sv_point.Multiplier or 1
        end
    end

    -- Add remaining distance from last SV point to t2
    distance = distance + (t2 - current_time) * current_mult

    return distance
end

function has_hitobject_at(t)
    for _, h in ipairs(map.HitObjects) do
        if h.StartTime == t or h.EndTime == t then
            return true
        end
    end
    return false
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

function sv_search(t)
    local sv = get_all_sv()

    if #sv == 0 then
        return nil
    end

    local cache = vars.cacheSVSearch

    if cache[t] then
        return cache[t]
    end

    local low = 1
    local high = #sv
    local result = 1

    while low <= high do
        local mid = math.floor((low + high) / 2)
        local current = sv[mid].StartTime

        if current <= t then
            result = mid
            low = mid + 1
        else
            high = mid - 1
        end
    end

    cache[t] = result

    return result
end
