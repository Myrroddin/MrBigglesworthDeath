-- Addon Name  : MrBigglesworthDeath
-- Notes:      : Displays who killed Mr Bigglesworth, Kul'Thuzad's cat in Naxxramas to chat frame 1
-- and plays ominous thunder in case the player missed chat.
-- Date: @project-date-iso@

-- localize the addon. we don't need to specify enUS as that is the default
local L = setmetatable({}, {__index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end})

if GetLocale() == "deDE" then
	--@localization(locale="deDE", format="lua_additive_table")@
	return
end

if GetLocale() == "esES" or GetLocale() == "esMX" then
	--@localization(locale="esES", format="lua_additive_table")@
	return
end

if GetLocale() == "frFR" then
	--@localization(locale="frFR", format="lua_additive_table")@
	return
end

if GetLocale() == "itIT" then
	--@localization(locale="itIT", format="lua_additive_table")@
	return
end

if GetLocale() == "koKR" then
	--@localization(locale="koKR", format="lua_additive_table")@
	return
end

if GetLocale() == "ptBR" then
	--@localization(locale="ptBR", format="lua_additive_table")@
	return
end

if GetLocale() == "ruRU" then
	--@localization(locale="ruRU", format="lua_additive_table")@
	return
end

if GetLocale() == "zhCN" then
	--@localization(locale="zhCN", format="lua_additive_table")@
	return
end

if GetLocale() == "zhTW" then
	--@localization(locale="zhTW", format="lua_additive_table")@
	return
end

local spelldamage = {
	["SPELL_DAMAGE"] = true,
	["SPELL_PERIODIC_DAMAGE"] = true,
	["RANGE_DAMAGE"] = true,
}

local f = CreateFrame("Frame")

function f:OnEvent(event, ...)
	--[===[@non-debug@
	if not IsInInstance() then return end -- we aren't in an instance
	local instanceID = select(8, GetInstanceInfo())
	if instanceID ~= 533 then return end -- the instance is not Naxxramas
	--@end-non-debug@]===]

	local _, subevent, _, _, sourceName, _, _, destGUID, destName = ...
	local overkill
	if spelldamage[subevent] then
		overkill = select(16, ...)
	elseif subevent == "SWING_DAMAGE" then
		overkill = select(13, ...)
	elseif subevent == "ENVIRONMENTAL_DAMAGE" then
		overkill = select(14, ...)
	else
		return
	end

	if overkill > 0 then
		local npcID = select(6, strsplit("-", destGUID))
		if tonumber(npcID) == 16998 then
			SendChatMessage(format(L["%s killed %s, May he Rest In Peace."], sourceName, destName), IsInRaid() and "RAID" or IsInGroup() and "PARTY" or "SAY")
			PlaySoundFile("Interface/AddOns/MrBigglesworthDeath/Media/Sounds/thunder.ogg", "Master")
			f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end
end

f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", function(self, event)
	self:OnEvent(event, CombatLogGetCurrentEventInfo())
end)