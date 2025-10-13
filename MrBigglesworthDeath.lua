-- Addon Name: MrBigglesworthDeath
-- Notes: Displays who killed Mr. Bigglesworth in Naxxramas and plays thunder.
-- Author: @project-author@
-- Date: @project-date-iso@

-- SendChatMessage() API is exclusive to WoW Classic. Mists of Pandaria and Retail use C_ChatInfo.SendChatMessage().
local SendChatMessage = SendChatMessage or C_ChatInfo.SendChatMessage

-- Localization fallback
local L = setmetatable({}, {__index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end})

local locale = GetLocale()
if locale == "deDE" then
	--@localization(locale="deDE", format="lua_additive_table")@
elseif locale == "esES" or locale == "esMX" then
	--@localization(locale="esES", format="lua_additive_table")@
elseif locale == "frFR" then
	--@localization(locale="frFR", format="lua_additive_table")@
elseif locale == "itIT" then
	--@localization(locale="itIT", format="lua_additive_table")@
elseif locale == "koKR" then
	--@localization(locale="koKR", format="lua_additive_table")@
elseif locale == "ptBR" then
	--@localization(locale="ptBR", format="lua_additive_table")@
elseif locale == "ruRU" then
	--@localization(locale="ruRU", format="lua_additive_table")@
elseif locale == "zhCN" then
	--@localization(locale="zhCN", format="lua_additive_table")@
elseif locale == "zhTW" then
	--@localization(locale="zhTW", format="lua_additive_table")@
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

function frame:OnEvent(_, ...)
	-- Only track inside Naxxramas
	local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
	if instanceID ~= 533 then return end

	-- Get combat log event info
	local _, subevent, _, _, sourceName, _, _, destGUID, destName = ...

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
end

frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function(self, event)
	self:OnEvent(event, CombatLogGetCurrentEventInfo())
end)