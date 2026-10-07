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

    plus_sv(starttime, endtime, d / width)
end
