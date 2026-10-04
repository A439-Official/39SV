function ui_add_shutter()
    ui_value()

    imgui.SetNextItemWidth(ui.width)
    _, vars.shutterRatio = imgui.SliderFloat("##ShutterRatio", vars.shutterRatio, 0, 1)
    tooltip(i18n("add_shutter_ratio"))

    imgui.SetNextItemWidth(ui.width)
    _, vars.shutterSV1Speed = imgui.InputFloat("##ShutterSV1Speed", vars.shutterSV1Speed)
    tooltip(i18n("add_shutter_sv1speed"))

    imgui.Separator()

    if button(i18n("add_shutter_apply")) then
        if #state.SelectedHitObjects > 1 then
            local times = {}
            for _, note in ipairs(state.SelectedHitObjects) do
                if not_has(times, note.StartTime) then
                    table.insert(times, note.StartTime)
                end
            end
            table.sort(times)
            for i = 1, #times - 1 do
                if vars.addSSF then
                    add_shutter_ssf(times[i], times[i + 1], vars.shutterRatio, vars.shutterSV1Speed,
                        i == #times - 1 and vars.finalSVMode or 0, vars.finalSV)
                else
                    add_shutter_sv(times[i], times[i + 1], vars.shutterRatio, vars.shutterSV1Speed,
                        i == #times - 1 and vars.finalSVMode or 0, vars.finalSV)
                end
            end
        else
            if vars.addSSF then
                add_shutter_ssf(vars.startTime, vars.stopTime, vars.shutterRatio, vars.shutterSV1Speed,
                    vars.finalSVMode, vars.finalSV)
            else
                add_shutter_sv(vars.startTime, vars.stopTime, vars.shutterRatio, vars.shutterSV1Speed, vars.finalSVMode,
                    vars.finalSV)
            end
        end
    end
end

function add_shutter_sv(starttime, endtime, ratio, speed, fmode, finalSV)
    local svs = {}
    if starttime >= endtime or count == 0 then
        return {}
    end
    table.insert(svs, utils.CreateScrollVelocity(starttime, speed))
    table.insert(svs, utils.CreateScrollVelocity(starttime + (endtime - starttime) * ratio,
        (1 - speed * ratio) / (1 - ratio)))
    if fmode > 0 then
        if fmode == 1 then
            table.insert(svs, utils.CreateScrollVelocity(endtime, get_sv(endtime)))
        elseif fmode == 2 then
            table.insert(svs, utils.CreateScrollVelocity(endtime, stop))
        elseif fmode == 3 then
            table.insert(svs, utils.CreateScrollVelocity(endtime, finalSV))
        end
    end
    add_sv_batch(svs)
end

function add_shutter_ssf(starttime, endtime, ratio, speed, fmode, finalSV)
    local ssfs = {}
    if starttime >= endtime or count == 0 then
        return
    end
    table.insert(ssfs, utils.CreateScrollSpeedFactor(starttime, get_ssf(starttime)))
    table.insert(ssfs, utils.CreateScrollSpeedFactor(starttime + vars.offset, speed))
    table.insert(ssfs, utils.CreateScrollSpeedFactor(starttime + (endtime - starttime) * ratio - vars.offset,
        (1 - speed * ratio) / (1 - ratio)))
    if fmode > 0 then
        table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime, stop))
        if fmode == 1 then
            table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime, get_ssf(endtime)))
        elseif fmode == 2 then
            table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime, stop))
        elseif fmode == 3 then
            table.insert(ssfs, utils.CreateScrollSpeedFactor(endtime, finalSV))
        end
    end
    add_ssf_batch(ssfs)
end

