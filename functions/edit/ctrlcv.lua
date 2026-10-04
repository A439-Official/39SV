local CLIPBOARD_FORMAT = "39sv-cb-1"

function ui_edit_copyandpaste()
    imgui.TextWrapped(i18n("edit_ctrlcv_copied_svs") .. tostring(#vars.copiedSVs))
    if button(i18n("edit_ctrlcv_copy"), (ui.width - ui.spacing) / 2) then
        local count = copySVs()
        vars.settings.clipboard = format_clipboard(vars.copiedSVs)
        print(i18n("edit_ctrlcv_copied_svs") .. tostring(count))
    end
    imgui.SameLine()
    if button(i18n("edit_ctrlcv_paste"), (ui.width - ui.spacing) / 2) then
        if #vars.copiedSVs > 0 then
            pasteSVs(vars.startTime)
        else
            print("W!" .. i18n("edit_ctrlcv_empty"))
        end
    end

    if button(i18n("edit_ctrlcv_clear")) then
        vars.copiedSVs = {}
        vars.settings.clipboard = ""
        print(i18n("edit_ctrlcv_cleared"))
    end
end

function copySVs()
    vars.copiedSVs = {}
    local count = 0
    for _, sv in ipairs(get_all_sv()) do
        if sv.StartTime >= vars.startTime and sv.StartTime < vars.stopTime then
            table.insert(vars.copiedSVs, {
                time = sv.StartTime - vars.startTime,
                multiplier = sv.Multiplier
            })
            count = count + 1
        elseif sv.StartTime >= vars.stopTime then
            break
        end
    end
    return count
end

function pasteSVs(time)
    if #vars.copiedSVs == 0 then
        return {}
    end

    local times = {}
    if #state.SelectedHitObjects > 0 then
        for _, note in ipairs(state.SelectedHitObjects) do
            if not_has(times, note.StartTime) then
                table.insert(times, note.StartTime)
            end
        end
        table.sort(times)
    else
        table.insert(times, time)
    end

    local svs = {}
    for i = 1, #times do
        for _, cached in ipairs(vars.copiedSVs) do
            table.insert(svs, utils.CreateScrollVelocity(times[i] + cached.time, cached.multiplier))
        end
    end

    if #svs > 0 then
        add_sv_batch(svs)
    end
    return svs
end

function format_clipboard(svs)
    if #svs == 0 then
        return ""
    end
    local lines = {}
    for _, sv in ipairs(svs) do
        table.insert(lines, tostring(sv.time) .. " " .. tostring(sv.multiplier))
    end
    return CLIPBOARD_FORMAT .. "\n" .. table.concat(lines, "\n")
end

function load_clipboard()
    local svs = {}
    local data = vars.settings.clipboard
    if type(data) == "string" then
        for line in data:gmatch("[^\r\n]+") do
            local t, m = line:match("^(%S+)%s+(%S+)$")
            if t and m then
                table.insert(svs, {
                    time = tonumber(t) or 0,
                    multiplier = tonumber(m) or 1
                })
            end
        end
    end
    vars.copiedSVs = svs
    return svs
end
