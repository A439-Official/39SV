function toHex(s)
    local parts = {}
    for i = 1, #s do
        parts[i] = string.format("%04X", string.byte(s, i))
    end
    return table.concat(parts, "|")
end

function fromHex(s)
    local result = {}
    for hex in s:gmatch("[^|]+") do
        table.insert(result, string.char(tonumber(hex, 16)))
    end
    return table.concat(result)
end

function i18n(key)
    local currentLang = (vars and vars.settings.lang) or "English"
    local langTable = langs[currentLang]
    if langTable and langTable[key] then
        return langTable[key]
    end
    if currentLang ~= "English" and langs.English and langs.English[key] then
        return langs.English[key]
    end
    return key
end
