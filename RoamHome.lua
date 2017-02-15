-- Global table --
RoamHome={
    ver=0.2,
    primary="",
    guild=nil,
 	defaultPersistentSettings={
        primaryhome="",
		guildacc=""
	},
	persistentSettings={}
}

local roam = RoamHome
local hcache = nil -- home cache

-- Initialize --
function RoamHome:Initialize()
	self.persistentSettings=ZO_SavedVars:NewAccountWide("RoamHomeVars",self.ver,nil,self.defaultPersistentSettings)
    self.guild=self.persistentSettings.guildacc
	EVENT_MANAGER:UnregisterForEvent("RoamHome_OnLoaded",EVENT_ADD_ON_LOADED)
end

-- Convienence --
function roam:CurrentLoc()
    self.loc = GetPlayerLocationName()
end

-- Addon functions --
function roam:GuildHouse(who)
    if (who and who~="") then
        self.guild=who
        self.persistentSettings.guildacc=self.guild end
    if self.guild ~= nil then
        d("Jumping to guild house owned by "..self.guild)
        JumpToHouse(self.guild)
    else d("Please enter the house owners name after /guild")d("Remember @ if account name (eg /guild @not_mutiny)") end
end

function roam:JumpHome()
    self.primary=GetHousingPrimaryHouse()
    local location=GetCurrentZoneHouseId()
    if self.primary~=location then
        d("Jumping to primary house")
        RequestJumpToHouse(self.primary)
    else d("Jumping to default house") d("DEV NOTE: only works for AD currently - see ESOUI post pls") RequestJumpToHouse(1) end
end

-- Game hooks --
SLASH_COMMANDS["/guild"]=function(who) roam:GuildHouse(who) end
SLASH_COMMANDS["/home"]=function() roam:JumpHome() end
SLASH_COMMANDS["/homed"]=function() d("self.primary "..tostring(roam.primary).."  - self.guild "..tostring(roam.guild)) end
SLASH_COMMANDS["/homeid"]=function() d(GetCurrentZoneHouseId()) end

EVENT_MANAGER:RegisterForEvent("RoamHome_OnLoaded",EVENT_ADD_ON_LOADED,function() roam:Initialize() end)