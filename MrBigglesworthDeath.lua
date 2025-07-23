-- Addon Name: MrBigglesworthDeath
-- Notes: Displays who killed Mr. Bigglesworth in Naxxramas and plays thunder.
-- Project Author: @project-author@
-- File Author: @file-author@

-- Localization fallback
local L = setmetatable({}, {__index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end})

if GetLocale() == "deDE" then
	L["%s killed %s, May he Rest In Peace."] = "%s hat %s gekillt, Möge er In Frieden ruhen."
end

if GetLocale() == "esES" or GetLocale() == "esMX" then
	L["%s killed %s, May he Rest In Peace."] = "% s mató a% s, que descanse en paz."
end

if GetLocale() == "frFR" then
	L["%s killed %s, May he Rest In Peace."] = "%s a tué %s, qu'il repose en paix."
end

if GetLocale() == "itIT" then
	L["%s killed %s, May he Rest In Peace."] = "%s ucciso %s, possa riposare in pace."
end

if GetLocale() == "koKR" then
	L["%s killed %s, May he Rest In Peace."] = "%s 살해 %s, 그는 평화롭게 휴식을 취할 수 있습니다."
end

if GetLocale() == "ptBR" then
	L["%s killed %s, May he Rest In Peace."] = "%s matou %s, que descanse em paz."
end

if GetLocale() == "ruRU" then
	L["%s killed %s, May he Rest In Peace."] = "%s убил %s, пусть он пухом."
end

if GetLocale() == "zhCN" then
	L["%s killed %s, May he Rest In Peace."] = "%s 杀死了％s，愿他安息。"
end

if GetLocale() == "zhTW" then
	L["%s killed %s, May he Rest In Peace."] = "％s 殺死了％s，願他安息。"
end

-- Event filtering
local damageTypes = {
	["SPELL_DAMAGE"] = 16,
	["SPELL_PERIODIC_DAMAGE"] = 16,
	["RANGE_DAMAGE"] = 16,
	["SWING_DAMAGE"] = 13,
	["ENVIRONMENTAL_DAMAGE"] = 14
}

-- Create event frame
local frame = CreateFrame("Frame")

frame:SetScript("OnEvent", function(_, _, ...)
    -- Only track inside Naxxramas
    local _, subevent, _, _, sourceName, _, _, destGUID, destName = ...
    local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()

    if instanceID ~= 533 then return end

    local overkillIndex = damageTypes[subevent]
    if not overkillIndex then return end

    local overkill = select(overkillIndex, ...)
    if overkill and overkill > 0 then
        local npcID = tonumber(select(6, strsplit("-", destGUID)))
        if npcID == 16998 then
            local channel = IsInRaid() and "RAID" or IsInGroup() and "PARTY" or "SAY"
            SendChatMessage(format(L["%s killed %s, May he Rest In Peace."], sourceName, destName), channel)
            PlaySoundFile("Interface/AddOns/MrBigglesworthDeath/Media/Sounds/thunder.ogg", "Master")
            frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end
    end
end)

frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")