function style()
    local miku = {57 / 255, 197 / 255, 187 / 255}
    local color_1 = {15 / 255, 20 / 255, 25 / 255, 255 / 255}
    local color_2 = {20 / 255, 25 / 255, 30 / 255, 245 / 255}
    local color_3 = join_tables(miku, {100 / 255})
    local color_4 = {25 / 255, 35 / 255, 40 / 255, 255 / 255}
    local color_5 = {35 / 255, 45 / 255, 50 / 255, 255 / 255}
    local color_6 = {45 / 255, 55 / 255, 60 / 255, 255 / 255}
    local color_7 = {20 / 255, 25 / 255, 30 / 255, 255 / 255}
    local color_8 = join_tables(miku, {255 / 255})
    local color_9 = join_tables(miku, {180 / 255})
    local color_10 = {70 / 255, 210 / 255, 200 / 255, 255 / 255}
    local color_11 = {30 / 255, 40 / 255, 45 / 255, 255 / 255}
    local color_12 = join_tables(miku, {150 / 255})
    local color_13 = join_tables(miku, {200 / 255})
    local color_14 = join_tables(miku, {80 / 255})
    local color_15 = join_tables(miku, {120 / 255})
    local color_16 = join_tables(miku, {160 / 255})
    local color_17 = {240 / 255, 240 / 255, 240 / 255, 255 / 255}

    imgui.PushStyleColor(imgui_col.WindowBg, color_1)
    imgui.PushStyleColor(imgui_col.PopupBg, color_2)
    imgui.PushStyleColor(imgui_col.Border, color_3)
    imgui.PushStyleColor(imgui_col.FrameBg, color_4)
    imgui.PushStyleColor(imgui_col.FrameBgHovered, color_5)
    imgui.PushStyleColor(imgui_col.FrameBgActive, color_6)
    imgui.PushStyleColor(imgui_col.TitleBg, color_7)
    imgui.PushStyleColor(imgui_col.TitleBgActive, color_8)
    imgui.PushStyleColor(imgui_col.TitleBgCollapsed, color_9)
    imgui.PushStyleColor(imgui_col.CheckMark, color_8)
    imgui.PushStyleColor(imgui_col.SliderGrab, color_8)
    imgui.PushStyleColor(imgui_col.SliderGrabActive, color_10)
    imgui.PushStyleColor(imgui_col.Button, color_11)
    imgui.PushStyleColor(imgui_col.ButtonHovered, color_12)
    imgui.PushStyleColor(imgui_col.ButtonActive, color_13)
    imgui.PushStyleColor(imgui_col.Tab, color_4)
    imgui.PushStyleColor(imgui_col.TabHovered, color_3)
    imgui.PushStyleColor(imgui_col.TabActive, color_8)
    imgui.PushStyleColor(imgui_col.Header, color_14)
    imgui.PushStyleColor(imgui_col.HeaderHovered, color_15)
    imgui.PushStyleColor(imgui_col.HeaderActive, color_16)
    imgui.PushStyleColor(imgui_col.Separator, color_3)
    imgui.PushStyleColor(imgui_col.Text, color_17)
    imgui.PushStyleColor(imgui_col.TextSelectedBg, color_3)
    imgui.PushStyleColor(imgui_col.ScrollbarGrab, color_12)
    imgui.PushStyleColor(imgui_col.ScrollbarGrabHovered, color_13)
    imgui.PushStyleColor(imgui_col.ScrollbarGrabActive, color_10)
    imgui.PushStyleColor(imgui_col.PlotLines, color_8)
    imgui.PushStyleColor(imgui_col.PlotLinesHovered, color_10)
    imgui.PushStyleColor(imgui_col.PlotHistogram, color_8)
    imgui.PushStyleColor(imgui_col.PlotHistogramHovered, color_10)
    imgui.PushStyleColor(imgui_col.TableHeaderBg, color_15)
    imgui.PushStyleVar(imgui_style_var.FrameRounding, 4.0)
    imgui.PushStyleVar(imgui_style_var.GrabRounding, 4.0)
    imgui.PushStyleVar(imgui_style_var.WindowRounding, 8.0)
    imgui.PushStyleVar(imgui_style_var.PopupRounding, 8.0)
    imgui.PushStyleVar(imgui_style_var.ScrollbarRounding, 9.0)
    imgui.PushStyleVar(imgui_style_var.ItemSpacing, {ui.spacing, ui.spacing})
end
