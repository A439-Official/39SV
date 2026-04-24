function ui_options()
    imgui.SetNextItemWidth(ui.width)
    local langIndex = vars.lang == "English" and 0 or 1
    local _, newLangIndex = imgui.Combo("##Language", langIndex, {"English", "Chinese"}, 2)
    if _ then
        vars.lang = newLangIndex == 0 and "English" or "Chinese"
    end
    tooltip("ui_options_language")

    if imgui.Checkbox("Compatibility Mode", vars.compatibilityMode) then
        vars.compatibilityMode = not vars.compatibilityMode
        vars.offset = vars.compatibilityMode and 1 or 2 ^ -6
    end
    tooltip("ui_options_compatibility")
end
