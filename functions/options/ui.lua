function ui_options()
    if imgui.Checkbox("Compatibility Mode", vars.compatibilityMode) then
        vars.compatibilityMode = not vars.compatibilityMode
        vars.offset = vars.compatibilityMode and 1 or 2 ^ -5
    end
    tooltip("Provide support for sv of osu!mania, malody, etc")
end
