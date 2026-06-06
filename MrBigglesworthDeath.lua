-- Addon Name: MrBigglesworthDeath
-- Notes: Displays who killed Mr. Bigglesworth in Naxxramas and plays thunder.
-- Author: @project-author@
-- Date: @project-date-iso@

------------------------------------------------------------
-- Localized globals (minor performance improvement)
------------------------------------------------------------

local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local GetLocale = GetLocale
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local PlaySoundFile = PlaySoundFile
local SendChatMessage = C_ChatInfo.SendChatMessage
local UNKNOWN = UNKNOWN
local UnitNameFromGUID = UnitNameFromGUID

local format = string.format
local rawset = rawset
local select = select
local setmetatable = setmetatable
local strsplit = strsplit
local tonumber = tonumber
local tostring = tostring

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
elseif locale == "esES" then
	--@localization(locale="esES", format="lua_additive_table")@
elseif locale == "esMX" then
	--@localization(locale="esMX", format="lua_additive_table")@
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
local SOUND_FILE = "Interface/AddOns/MrBigglesworthDeath/Media/Sounds/thunder.ogg"

---@type boolean
---@flavor-narrows retail
local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

------------------------------------------------------------
-- State
------------------------------------------------------------

local frame = CreateFrame("Frame")

------------------------------------------------------------
-- Event control
------------------------------------------------------------

local function EnablePartyKill()
	if not frame:IsEventRegistered("PARTY_KILL") then
		frame:RegisterEvent("PARTY_KILL")
	end
end

local function DisablePartyKill()
	if frame:IsEventRegistered("PARTY_KILL") then
		frame:UnregisterEvent("PARTY_KILL")
	end
end

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
-- Shared helpers
------------------------------------------------------------

---@param guid string?
---@return number?
local function GetNPCIDFromGUID(guid)
	if not guid then return nil end

	local unitType, _, _, _, _, npcID = strsplit("-", guid)
	if unitType ~= "Creature" and unitType ~= "Vehicle" then
		return nil
	end

	return tonumber(npcID)
end

---@return string
local function GetChatChannel()
	return IsInRaid() and "RAID"
	or IsInGroup() and "PARTY"
	or "SAY"
end

---@param killer string?
---@param destName string?
local function AnnounceDeath(killer, destName)
	SendChatMessage(
		format(L["%s killed %s, May he Rest In Peace."], killer or UNKNOWN, destName or "Mr. Bigglesworth"),
		GetChatChannel()
	)

	PlaySoundFile(SOUND_FILE, "Master")
end

------------------------------------------------------------
-- Instance detection
------------------------------------------------------------

local function CheckInstance()
	local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()

	if instanceID == NAXXRAMAS_ID then
		if isRetail then
			EnablePartyKill()
		else
			EnableCLEU()
		end
	else
		if isRetail then
			DisablePartyKill()
		else
			DisableCLEU()
		end
	end
end

------------------------------------------------------------
-- Retail kill handler
------------------------------------------------------------

---@param attackerGUID string
---@param targetGUID string
local function HandlePartyKill(attackerGUID, targetGUID)
	local npcID = GetNPCIDFromGUID(targetGUID)
	if npcID ~= MR_BIGGLESWORTH_ID then return end

	local killer = UnitNameFromGUID(attackerGUID) or UNKNOWN
	local destName = UnitNameFromGUID(targetGUID) or "Mr. Bigglesworth"

	AnnounceDeath(killer, destName)
	DisablePartyKill()
end

------------------------------------------------------------
-- Classic combat log handler
------------------------------------------------------------

local HandleCombatLog

if not isRetail then
	local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo

	function HandleCombatLog()
		local _, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()

		if subevent ~= "SPELL_DAMAGE"
			and subevent ~= "SPELL_PERIODIC_DAMAGE"
			and subevent ~= "RANGE_DAMAGE"
			and subevent ~= "SWING_DAMAGE"
			and subevent ~= "ENVIRONMENTAL_DAMAGE" then
		return end

		local npcID = GetNPCIDFromGUID(destGUID)
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

		local killer = sourceName or (sourceGUID and UnitNameFromGUID(sourceGUID)) or UNKNOWN
		AnnounceDeath(killer, destName)
		DisableCLEU()
	end
end

------------------------------------------------------------
-- Event dispatcher
------------------------------------------------------------

frame:SetScript("OnEvent", function(_, event, ...)
	if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
		CheckInstance()
		return
	end

	if isRetail and event == "PARTY_KILL" then
		local attackerGUID, targetGUID = ...
		HandlePartyKill(attackerGUID, targetGUID)
	elseif not isRetail and event == "COMBAT_LOG_EVENT_UNFILTERED" and HandleCombatLog then
		HandleCombatLog()
	end
end)

------------------------------------------------------------
-- Event registration
------------------------------------------------------------

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")