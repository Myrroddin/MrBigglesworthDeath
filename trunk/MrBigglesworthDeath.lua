-- Addon Name  : MrBigglesworthDeath 
-- Notes:      : Displays who killed Mr Bigglesworth, Kul'Thuzad's cat in Naxxramas to chat frame 1
-- and plays ominous thunder in case the player missed chat.


--local L = MrBigglesworthDeathLocalization
local L = GetLocale() == "enUS" and {
	MBD_INSTRUCTIONS = "Slash commands are /mrbigglesworthdeath or /mbd followed by \"sound on\" or \"sound off\" or \"default\" without the quotes.",
	SOUNDON = "sound on",
	SOUNDOFF = "sound off",
	DEFAULT = "default",
	MBD_SOUNDON_MSSG = "MrBigglesworthDeath: Thunder sound on.",
	MBD_SOUNDOFF_MSSG = "MrBigglesworthDeath: Thunder sound off.",
	MBD_DEFAULT_MSSG = "MrBigglesworthDeath reverted back to default of thunder sound on.",
	DEATH_MESSAGE = " %s killed %s, May he Rest In peace",
	}

MrBigglesworthDeath = {}
local addon = MrBigglesworthDeath
local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(frame, event, ...)
	if type(addon[event]) == "function" then
		addon[event](addon, event, ...)
	end
end)
addon.frame = frame
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")


local defaults = {
		sound = true
	}

--[[
	Saved Variables DB Format --For Reference.
	MrBigglesworthDeathDB = {
		[TooName] = { opt },
]]--


function addon:ADDON_LOADED(event, arg1)
	if arg1 == "MrBigglesworthDeath" then
		SlashCmdList["MRBIGGLESWORTHDEATH"] = self.SlashHandler
		SLASH_MRBIGGLESWORTHDEATH1 = "/mrbigglesworthdeath"
		SLASH_MRBIGGLESWORTHDEATH2 = "/mbd"
	end
end

function addon:VARIABLES_LOADED()
	local playerName, first = UnitName("player")
	MrBigglesworthDeathDB = MrBigglesworthDeathDB or {}
	
	if not MrBigglesworthDeathDB[playerName] then
		first = true
	end
	
	MrBigglesworthDeathDB[playerName] = MrBigglesworthDeathDB[playerName] or CopyTable(defaults)
	
	self.settings = MrBigglesworthDeathDB[playerName]

	if first then
		print(L.MBD_INSTRUCTIONS)
	end
	if self.settings.sound then
		print(L.MBD_SOUNDON_MSSG)
	else
		print(L.MBD_SOUNDOFF_MSSG)
	end

end

function addon.SlashHandler(text)
	text = string.lower(text)
	local opt = addon.settings
	if text == L.SOUNDON then

			opt.sound = true
			print(L.MBD_SOUNDON_MSSG)

	elseif text == L.SOUNDOFF then

			opt.sound = false
			print(L.MBD_SOUNDOFF_MSSG)

	elseif text == L.DEFAULT then
		MrBigglesworthDeathDB[UnitName("player")] = CopyTable(defaults)
		addon.settings = MrBigglesworthDeathDB[UnitName("player")]
		print(L.MBD_DEFAULT_MSSG)
	else
		-- display instructions
		print(L.MBD_INSTRUCTIONS)
   	end
	addon.settings = opt --Really redundant, but just to make sure things get moved back
end

local function isMrBigglesworth(guid) -- function to convert hex value of Mr Bigglesworth to decimal
	local mobid = tonumber(guid:sub(9, 12), 16)
	if mobid == 16998  then -- MrBiggleworth is MobID 16998, Deeprun Rat is 13016 (debug test)
		return true
	end
end

function addon.COMBAT_LOG_EVENT_UNFILTERED(self, event , ...)
	local combatEvent = select(2, ...)
	if combatEvent == "PARTY_KILL" then
		local sourceName = select(4, ...)
		local destGUID, destName = select(6, ...)

		if isMrBigglesworth(destGUID) then
			local msg = string.format(L.DEATH_MESSAGE, sourceName, destName )
			SendChatMessage(msg)
            if self.settings.sound then
				PlaySoundFile("Interface\\AddOns\\MrBigglesworthDeath\\Sounds\\thunder.wav")
			end
		end
	end
end