-- Addon Name: MrBigglesworthDeath
-- Notes: Displays who killed Mr. Bigglesworth in Naxxramas and plays thunder.
-- Author: @project-author@
-- Date: @project-date-iso@

------------------------------------------------------------
-- Localized globals (minor performance improvement)
------------------------------------------------------------

local CreateFrame = CreateFrame
local format = string.format
local GetInstanceInfo = GetInstanceInfo
local GetLocale = GetLocale
local GetNumGroupMembers = GetNumGroupMembers
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local issecretvalue = issecretvalue
local PlaySoundFile = PlaySoundFile
local rawset = rawset
local SendChatMessage = C_ChatInfo.SendChatMessage
local setmetatable = setmetatable
local strsplit = strsplit
local tonumber = tonumber
local tostring = tostring
local UnitGUID = UnitGUID
local UnitName = UnitName
local UnitNameFromGUID = UnitNameFromGUID
local UnitTokenFromGUID = UnitTokenFromGUID
local UNKNOWN = UNKNOWN

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

------------------------------------------------------------
-- Shared helpers
------------------------------------------------------------
local function IsReadable(value)
	return not issecretvalue or not issecretvalue(value)
end

local function NameFromUnit(unit, guid)
	local unitGUID = UnitGUID(unit)
	if issecretvalue and issecretvalue(unitGUID) then return nil end
	if unitGUID == guid then
		local name = UnitName(unit)
		if IsReadable(name) then return name end
	end
end

local function GetNameFromGUID(guid)
	if not IsReadable(guid) or not guid then return nil end

	if UnitNameFromGUID then
		local name = UnitNameFromGUID(guid)
		if IsReadable(name) and name then return name end
	end

	if UnitTokenFromGUID then
		local unit = UnitTokenFromGUID(guid)
		if IsReadable(unit) and unit then
			local name = NameFromUnit(unit, guid)
			if name then return name end
		end
	end

	for _, unit in ipairs({ "player", "pet", "target", "focus", "mouseover" }) do
		local name = NameFromUnit(unit, guid)
		if name then return name end
	end

	local inRaid = IsInRaid()
	local prefix = inRaid and "raid" or "party"
	-- Party tokens exclude the player; raid tokens include the player.
	local count = GetNumGroupMembers() - (inRaid and 0 or 1)
	for i = 1, count do
		local name = NameFromUnit(prefix .. i, guid) or NameFromUnit(prefix .. "pet" .. i, guid)
		if name then return name end
	end

	-- The player cache can resolve a killer after their unit token is gone.
	if strsplit("-", guid) == "Player" then
		local _, _, _, _, _, name = GetPlayerInfoByGUID(guid)
		if IsReadable(name) then return name end
	end
end

local function GetNPCIDFromGUID(guid)
	if not guid then return nil end

	local unitType, _, _, _, _, npcID = strsplit("-", guid)
	if unitType ~= "Creature" and unitType ~= "Vehicle" then
		return nil
	end

	return tonumber(npcID)
end
local function GetChatChannel()
	return IsInRaid() and "RAID"
	or IsInGroup() and "PARTY"
	or "SAY"
end
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
		EnablePartyKill()
	else
		DisablePartyKill()
	end
end

------------------------------------------------------------
-- Kill handler
------------------------------------------------------------
local function HandlePartyKill(attackerGUID, targetGUID)
	-- Restricted identities cannot be inspected to identify Mr. Bigglesworth.
	if issecretvalue and (issecretvalue(attackerGUID) or issecretvalue(targetGUID)) then
		return
	end

	local npcID = GetNPCIDFromGUID(targetGUID)
	if npcID ~= MR_BIGGLESWORTH_ID then return end

	local killer = GetNameFromGUID(attackerGUID) or UNKNOWN
	local destName = GetNameFromGUID(targetGUID) or "Mr. Bigglesworth"

	AnnounceDeath(killer, destName)
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