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

------------------------------------------------------------
-- State
------------------------------------------------------------

local frame = CreateFrame("Frame")

------------------------------------------------------------
-- PARTY_KILL control
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

------------------------------------------------------------
-- Instance detection
------------------------------------------------------------

local function CheckInstance()
	local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()

	if instanceID == NAXXRAMAS_ID then
		EnablePartyKill()
	else
		DisablePartyKill()
	end
end

------------------------------------------------------------
-- Kill handling
------------------------------------------------------------

---@param guid string
---@return number?
local function GetNPCIDFromGUID(guid)
	return tonumber(guid:match("-(%d+)-"))
end

---@param attackerGUID string
---@param targetGUID string
local function HandlePartyKill(attackerGUID, targetGUID)
	local npcID = GetNPCIDFromGUID(targetGUID)
	if npcID ~= MR_BIGGLESWORTH_ID then return end

	local killer = UnitNameFromGUID(attackerGUID) or UNKNOWN
	local destName = UnitNameFromGUID(targetGUID) or "Mr. Bigglesworth"

	local channel = IsInRaid() and "RAID"
	or IsInGroup() and "PARTY"
	or "SAY"

	C_ChatInfo.SendChatMessage(
		format(L["%s killed %s, May he Rest In Peace."], killer, destName), channel
	)

	PlaySoundFile(SOUND_FILE, "Master")

	DisablePartyKill()
end

------------------------------------------------------------
-- Event dispatcher
------------------------------------------------------------

frame:SetScript("OnEvent", function(_, event, ...)
	if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
		CheckInstance()
		return
	end

	if event == "PARTY_KILL" then
		local attackerGUID, targetGUID = ...
		HandlePartyKill(attackerGUID, targetGUID)
	end
end)

------------------------------------------------------------
-- Event registration
------------------------------------------------------------

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")