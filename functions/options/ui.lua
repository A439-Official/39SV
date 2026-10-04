function ui_options()
    imgui.SetNextItemWidth(ui.width)
    local langIndex = vars.settings.lang == "English" and 0 or 1
    local _, newLangIndex = imgui.Combo("##Language", langIndex, {"English", "Chinese"}, 2)
    if _ then
        vars.settings.lang = newLangIndex == 0 and "English" or "Chinese"
    end
    tooltip(i18n("options_ui_language"))
    if imgui.Checkbox(i18n("options_ui_compatibility_checkbox"), vars.settings.compatibilityMode) then
        vars.settings.compatibilityMode = not vars.settings.compatibilityMode
    end
    tooltip(i18n("options_ui_compatibility"))

    if button(i18n("options_ui_compatibility_check")) then
        local negativeTimes = {}
        for _, sv in ipairs(map.ScrollVelocities) do
            if sv.Multiplier < 0 then
                table.insert(negativeTimes, sv.StartTime)
            end
        end
        if #negativeTimes > 0 then
            print(i18n("options_ui_compatibility_check_result") .. #negativeTimes)
            for _, t in ipairs(negativeTimes) do
                print(t)
            end
        else
            print(i18n("options_ui_compatibility_check_result") .. "0")
        end
    end
end
