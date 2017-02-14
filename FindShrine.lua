-- Global table --
FindShrine={
	ver=0.1,
	loc=nil,
	primary=nil
}

local find = FindShrine
local hcache = nil

-- Initialize function --
function FindShrine:Initialize()
	self.primary=GetHousingPrimaryHouse()
	EVENT_MANAGER:UnregisterForEvent("FindShrine_OnLoaded",EVENT_ADD_ON_LOADED)
end

-- Convienence functions --
function FindShrine:CurrentLoc() -- finds your current zone
    self.loc = GetPlayerLocationName() -- saves to variable
end

-- Addon variables --
function FindShrine:StartZoneScan()
	local zone=GetUnitZone("player")
	d(zone)
end	

function FindShrine:StartGuildScan()
	local guild=3 -- determines which guild # we scan (temp to get it workin)
	local n = GetNumGuildMembers(guild) -- checks how many players are in that guild
	local unitTag = GetGroupUnitTagByIndex(i) 
	for i=1,n do -- loops 1 to total number of guild members (can set it to online members for further optimization)
		local name,note,rankIndex,playerStatus,secsSinceLogoff = GetGuildMemberInfo(guild,i) -- saves all character data for that slot
		if playerStatus ~= PLAYER_STATUS_OFFLINE then
			local hasChar,charName,zoneName,classtype,alliance = GetGuildMemberCharacterInfo(3,i)
			JumpToGuildMember(charName)
			d(charName..zoneName) end
	end
end

function FindShrine:JumpHome(id)
	local currenthouse=GetCurrentZoneHouseId()
	if self.primary~=currenthouse then
		RequestJumpToHouse(self.primary)
	else RequestJumpToHouse(1) end
end
	
--	d(self.primary)

-- Game hooks --
SLASH_COMMANDS["/home"]=function() FindShrine:JumpHome(id) end -- gonna bind that to a configurable key
SLASH_COMMANDS["/homef"]=function() d(GetCurrentZoneHouseId()) end

SLASH_COMMANDS["/find"]=function() FindShrine:StartGuildScan() end
SLASH_COMMANDS["/zone"]=function() FindShrine:StartZoneScan() end
SLASH_COMMANDS["//"]=function() ReloadUI() end -- fast /reloadui for mutiny

EVENT_MANAGER:RegisterForEvent("FindShrine_OnLoaded",EVENT_ADD_ON_LOADED,function() find:Initialize() end)

-- Saved snips --
--[[local numGuild = GetNumGuilds() -- saves how many guilds we are in -- saved for later
]]--

-- JumpToGuildMember(string name) -- use for fast travling
-- JUMP_TO_PLAYER_RESULT_GENERIC_FAILURE ? ^

-- GetUnitZone("player") find zone ?