-- Addon Name  : MrBigglesworthDeath
-- Notes:      : Displays who killed Mr Bigglesworth, Kul'Thuzad's cat in Naxxramas to chat frame 1
-- and plays ominous thunder in case the player missed chat.
-- Date: $Date$

local locales = {
	enUS = {
		["DEATH_MESSAGE"] = " %s killed %s, May he Rest In Peace.",
	},
	deDE = --@localization(locale="deDE", format="lua_table")@
	frFR = --@localization(locale="frFR", format="lua_table")@
	esES = --@localization(locale="esES", format="lua_table")@
	esMX = --@localization(locale="esES", format="lua_table")@
	itIT = --@localization(locale="itIT", format="lua_table")@
	koKR = --@localization(locale="koKR", format="lua_table")@
	ptBR = --@localization(locale="ptBR", format="lua_table")@
	ruRU = --@localization(locale="ruRU", format="lua_table")@
	zhCN = --@localization(locale="zhCN", format="lua_table")@
	zhTW = --@localization(locale="zhTW", format="lua_table")@
}

local L = setmetatable(locales[GetLocale()] or locales.enUS, {__index = function(t, k)
	local v = rawget(locales.enUS, k) or k
	rawset(t, k, v)
	return v
end})

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
			SendChatMessage(format(L.DEATH_MESSAGE, sourceName, destName), IsInRaid() and "RAID" or IsInGroup() and "PARTY" or "SAY")
			PlaySoundFile("Interface/AddOns/MrBigglesworthDeath/Sounds/thunder.ogg", "Master")
			f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end
end

f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", function(self, event)
	self:OnEvent(event, CombatLogGetCurrentEventInfo())
end)