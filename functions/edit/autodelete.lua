function ui_edit_autodelete()
    if button("Apply") then
        local asvs, arsvs, artps = autodelete()

        local batchActions = {}
        if #arsvs > 0 then
            table.insert(batchActions, utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, arsvs))
        end
        if #asvs > 0 then
            table.insert(batchActions, utils.CreateEditorAction(action_type.AddScrollVelocityBatch, asvs))
        end
        if #artps > 0 then
            table.insert(batchActions, utils.CreateEditorAction(action_type.RemoveTimingPointBatch, artps))
        end
        if #batchActions > 0 then
            actions.PerformBatch(batchActions)
        end
    end
end

function autodelete()
    local rsvs, rtps, svs, lsv, ltp = {}, {}, {}, nil, nil
    for _, sv in ipairs(map.ScrollVelocities) do
        if _ ~= 1 then
            -- if sv == lsv then
            --     if not_has(rsvs, sv) then
            --         table.insert(rsvs, lsv)
            --         if not_has(svs, sv) then
            --             table.insert(svs, sv)
            --         end
            --     end
            -- else
            if sv.StartTime == lsv.StartTime then
                if not_has(rsvs, sv) then
                    table.insert(rsvs, lsv)
                end
            end
            --     if sv.Multiplier == lsv.Multiplier and math.abs(sv.StartTime - lsv.StartTime) < 1 then
            --         if not_has(rsvs, sv) then
            --             table.insert(rsvs, lsv)
            --         end
            --     end
            -- end
        end
        lsv = sv
    end
    for _, tp in ipairs(map.TimingPoints) do
        if _ ~= 1 and tp.StartTime == ltp.StartTime then
            if not_has(rtps, tp) then
                table.insert(rtps, ltp)
            end
        end
        ltp = tp
    end
    print("Remove SV Count: " .. #rsvs - #svs .. "\n TimingPoint Count: " .. #rtps)
    return svs, rsvs, rtps
end
