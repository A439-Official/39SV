function i18n(key)
    local currentLang = (vars and vars.lang) or "English"
    local function toHex(s)
        local parts = {}
        for i = 1, #s do
            parts[i] = string.format("%04X", string.byte(s, i))
        end
        return table.concat(parts, "|")
    end
    local langTable = langs[currentLang]
    if langTable and langTable[key] then
        return langTable[key]
    end
    if currentLang ~= "English" and langs.English and langs.English[key] then
        return langs.English[key]
    end
    return toHex(key)
end
