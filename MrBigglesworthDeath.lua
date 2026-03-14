-- Addon Name: MrBigglesworthDeath
-- Notes: Displays who killed Mr. Bigglesworth in Naxxramas and plays thunder.
-- Author: @project-author@
-- Date: @project-date-iso@

------------------------------------------------------------
-- Localized globals (minor performance improvement)
------------------------------------------------------------

local GetLocale = GetLocale
local GetInstanceInfo = GetInstanceInfo
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local PlaySoundFile = PlaySoundFile
local tonumber = tonumber
local format = string.format
local UnitNameFromGUID = UnitNameFromGUID

------------------------------------------------------------
-- Localization fallback
------------------------------------------------------------

local L = setmetatable({}, {
	__index = function(t, k)
		local v = tostring(k)
		rawset(t, k, v)
		return v
	end
})

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

------------------------------------------------------------
-- Constants
------------------------------------------------------------

local NAXXRAMAS_ID = 533
local MR_BIGGLESWORTH_ID = 16998
local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

------------------------------------------------------------
-- State
------------------------------------------------------------

local frame = CreateFrame("Frame")

------------------------------------------------------------
-- Classic CLEU control
------------------------------------------------------------

local function EnableCLEU()
	if not frame:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED") then
		frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

local function DisableCLEU()
	if frame:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED") then
		frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

------------------------------------------------------------
-- Retail PARTY_KILL control
------------------------------------------------------------

local function EnablePK()
	if not frame:IsEventRegistered("PARTY_KILL") then
		frame:RegisterEvent("PARTY_KILL")
	end
end

local function DisablePK()
	if frame:IsEventRegistered("PARTY_KILL") then
		frame:UnregisterEvent("PARTY_KILL")
	end
end

------------------------------------------------------------
-- Instance detection
------------------------------------------------------------

local function CheckInstance()

	local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
	if not instanceID then return end

	if instanceID == NAXXRAMAS_ID then
		if isRetail then
			EnablePK()
		else
			EnableCLEU()
		end
	else
		if isRetail then
			DisablePK()
		else
			DisableCLEU()
		end
	end

end

------------------------------------------------------------
-- Retail kill handler
------------------------------------------------------------

local function HandlePartyKill(_, attackerGUID, targetGUID)

	local npcID = tonumber(targetGUID:match("-(%d+)-"))
	if npcID ~= MR_BIGGLESWORTH_ID then
		return	end

	local killer = UnitNameFromGUID(attackerGUID) or UNKNOWN
	local destName = UnitNameFromGUID(targetGUID) or "Mr. Bigglesworth"

	local channel = IsInRaid() and "RAID"
		or IsInGroup() and "PARTY"
		or "SAY"

	C_ChatInfo.SendChatMessage(
		format(L["%s killed %s, May he Rest In Peace."], killer, destName), channel
	)

	PlaySoundFile(
		"Interface/AddOns/MrBigglesworthDeath/Media/Sounds/thunder.ogg", "Master"
	)

	DisablePK()

end

------------------------------------------------------------
-- Classic combat log handler
------------------------------------------------------------

local function HandleCombatLog()

	local _, subevent, _, _, sourceName, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()

	if subevent ~= "SPELL_DAMAGE"
		and subevent ~= "SPELL_PERIODIC_DAMAGE"
		and subevent ~= "RANGE_DAMAGE"
		and subevent ~= "SWING_DAMAGE"
		and subevent ~= "ENVIRONMENTAL_DAMAGE" then
	return	end

	local npcID = destGUID and tonumber(destGUID:match("^Creature%-%d+%-%d+%-%d+%-(%d+)%-%d+$"))
	if npcID ~= MR_BIGGLESWORTH_ID then
		return
	end

	local overkill

	if subevent == "SWING_DAMAGE" then
		overkill = select(13, CombatLogGetCurrentEventInfo())
	else
		overkill = select(16, CombatLogGetCurrentEventInfo())
	end

	if not (overkill and overkill > 0) then
		return
	end

	local channel = IsInRaid() and "RAID"
		or IsInGroup() and "PARTY"
		or "SAY"

	C_ChatInfo.SendChatMessage(
		format(L["%s killed %s, May he Rest In Peace."], sourceName, destName), channel
	)

	PlaySoundFile(
		"Interface/AddOns/MrBigglesworthDeath/Media/Sounds/thunder.ogg", "Master"
	)

	DisableCLEU()

end

------------------------------------------------------------
-- Event dispatcher
------------------------------------------------------------

frame:SetScript("OnEvent", function(self, event, ...)

	if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
		CheckInstance()
		return
	end

	if isRetail and event == "PARTY_KILL" then
		HandlePartyKill(event, ...)
	elseif not isRetail and event == "COMBAT_LOG_EVENT_UNFILTERED" then
		HandleCombatLog()
	end

end)

------------------------------------------------------------
-- Event registration
------------------------------------------------------------

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")