function ui_edit_teleport()

    imgui.SetNextItemWidth(ui.width)
    _, vars.teleportMode = imgui.Combo("##TeleportMode", vars.teleportMode,
        {i18n("edit_teleport_below"), i18n("edit_teleport_above")}, 2)
    tooltip(i18n("edit_teleport_mode"))

    imgui.SetNextItemWidth(ui.width)
    _, vars.teleportDistance = imgui.InputFloat("##TeleportDistance", vars.teleportDistance, 1, 100)
    tooltip(i18n("edit_teleport_distance"))

    _, vars.teleportAccumulate = imgui.Checkbox(i18n("edit_teleport_accumulate"), vars.teleportAccumulate)

    imgui.Separator()

    if button(i18n("edit_teleport_apply")) then

        if #state.SelectedHitObjects > 0 then
            local times = {}
            for _, note in ipairs(state.SelectedHitObjects) do
                if not_has(times, note.StartTime) then
                    table.insert(times, note.StartTime)
                end
            end
            table.sort(times)
            if vars.teleportAccumulate then
                for i = 1, #times do
                    local time = times[i]
                    teleport(time, vars.teleportDistance * i, vars.teleportMode)
                end
            else
                for i = 1, #times do
                    local time = times[i]
                    teleport(time, vars.teleportDistance, vars.teleportMode)
                end
            end
        else
            teleport(vars.startTime, vars.teleportDistance, vars.teleportMode)
        end
    end
end

function teleport(t, d, m)
    local rsvs, svs = {}, {}
    local all_sv = get_all_sv()

    local window = vars.offset
    if not vars.settings.compatibilityMode then
        local _, exp = math.frexp(t)
        window = math.max(vars.offset, 2 ^ (exp - 23))
    end

    local starttime, endtime
    for _ = 1, 16 do
        starttime = to_f32(m == 0 and t or t - window)
        endtime = to_f32(starttime + window)
        if endtime - starttime >= window - 1e-9 then
            break
        end
        window = window * 2
    end

    local width = endtime - starttime
    if width <= 0 then
        return
    end

    local function find_first_ge(target)
        local low, high = 1, #all_sv
        local result = nil
        while low <= high do
            local mid = math.floor((low + high) / 2)
            if all_sv[mid].StartTime >= target then
                result = mid
                high = mid - 1
            else
                low = mid + 1
            end
        end
        return result
    end

    local reset = get_sv(endtime)

    local startIdx = find_first_ge(starttime)
    if startIdx then
        for i = startIdx, #all_sv do
            local sv = all_sv[i]
            if sv.StartTime > endtime then
                break
            end
            table.insert(rsvs, sv)
        end
    end

    table.insert(svs, utils.CreateScrollVelocity(starttime, (d + get_sv_distance(starttime, endtime)) / width))
    table.insert(svs, utils.CreateScrollVelocity(endtime, reset))

    remove_sv_batch(rsvs)
    add_sv_batch(svs)
end
