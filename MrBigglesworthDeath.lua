-- Addon Name  : MrBigglesworthDeath 
-- Notes:      : Displays who killed Mr Bigglesworth, Kul'Thuzad's cat in Naxxramas to chat frame 1
-- and plays ominous thunder in case the player missed chat.


--local L = MrBigglesworthDeathLocalization
local L
if GetLocale() == "enUS" then
	L = {
		MBD_INSTRUCTIONS = "Slash commands are /mrbigglesworthdeath or /mbd followed by\n\tsound on\nsound off\ndefault\nor a chat type (say, yell, raid, party, guild)",
		SOUNDON = "sound on",
		SOUNDOFF = "sound off",
		DEFAULT = "default",
		MBD_SOUNDON_MSSG = "MrBigglesworthDeath: Thunder sound on.",
		MBD_SOUNDOFF_MSSG = "MrBigglesworthDeath: Thunder sound off.",
		MBD_DEFAULT_MSSG = "MrBigglesworthDeath reverted back to default of thunder sound on and RAID chat.",
		DEATH_MESSAGE = " %s killed %s, May he Rest In Peace.",
		MBD_CHAT_OUTPUT = "Using %s chat type.",
		SAY = "say",
		RAID = "raid",
		YELL = "yell",
		PARTY = "party",
		GUILD = "guild",
	}
elseif GetLocale() == "deDE" then
	L = {
		DEATH_MESSAGE = "%s hat %s gekillt, Möge er In Frieden ruhen.",
		DEFAULT = "standard",
		GUILD = "gilde",
		MBD_CHAT_OUTPUT = "Nutze %s chat typ.",
		MBD_DEFAULT_MSSG = "MrBigglesworthDeath wurde auf die Standardeinstellungen \"Donner sound an\" und \"Raid chat\" zurückgesetzt",
		MBD_INSTRUCTIONS = [=[Slash Kommandos sind /mrbigglesworthdeath oder /mbd gefolgt von 
sound an
sound aus
standard
oder einen chat typ (sagen, schreien, raid, party, gilde)]=],
		MBD_SOUNDOFF_MSSG = "MrBigglesworthDeath: Donner sound aus",
		MBD_SOUNDON_MSSG = "MrBigglesworthDeath: Donner sound an",
		PARTY = "party",
		RAID = "raid",
		SAY = "sagen",
		SOUNDOFF = "sound aus",
		SOUNDON = "sound an",
		YELL = "schreien"
	}
end

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
		sound = true,
        chat = "RAID",
	}

--[[
	Saved Variables DB Format --For Reference.
	MrBigglesworthDeathDB = {
		[TooName] = { opt },
]]--


function addon:ADDON_LOADED(event, addon)
	if addon == "MrBigglesworthDeath" then
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
		--print(L.MBD_SOUNDON_MSSG)
	else
		--print(L.MBD_SOUNDOFF_MSSG)
	end
    --print(L.MBD_CHAT_OUTPUT:format(self.settings.chat))
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
            
    elseif text == L.SAY then
        opt.chat = "SAY"
        print(L.MBD_CHAT_OUTPUT:format(opt.chat))
            
    elseif text == L.RAID then
        opt.chat = "RAID"            
        print(L.MBD_CHAT_OUTPUT:format(opt.chat))
            
    elseif text == L.PARTY then
        opt.chat = "PARTY"            
        print(L.MBD_CHAT_OUTPUT:format(opt.chat))
            
    elseif text == L.GUILD then
        opt.chat = "GUILD"            
        print(L.MBD_CHAT_OUTPUT:format(opt.chat))
            
    elseif text == L.YELL then
        opt.chat = "YELL"            
        print(L.MBD_CHAT_OUTPUT:format(opt.chat))

	elseif text == L.DEFAULT then
		MrBigglesworthDeathDB[UnitName("player")] = CopyTable(defaults)
		addon.settings = MrBigglesworthDeathDB[UnitName("player")]
		print(L.MBD_DEFAULT_MSSG)
	else
		-- display instructions
		print(L.MBD_INSTRUCTIONS)
   	end
end

function addon.COMBAT_LOG_EVENT_UNFILTERED(self, event, timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, ...)
	if subevent == "PARTY_KILL" then
		local _, _, _, _, _, npcId = strsplit("-", destGUID)
		if tonumber(npcId) == 16998 then
			SendChatMessage(string.format(L.DEATH_MESSAGE, sourceName, destName), self.settings.chat)
            if self.settings.sound then
				PlaySoundFile("Interface\\AddOns\\MrBigglesworthDeath\\Sounds\\thunder.mp3", "Master")
			end
		end
	end
end
