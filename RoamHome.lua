-- Global table --
RoamHome={
    ver=0.4,
    primary="",
    guild=nil,
    friend=nil,
    houses={  -- "now this is what i'd call data-driven" ;)
        "Mara's Kiss Public House",
        "The Rosy Lion",
        "The Ebony Flask Inn",
        "Barbed Hook Private Room",
        "Sisters of the Sands Apartment",
        "Flaming Nix Deluxe Garret",
        "Black Vine Villa",
        "Cliffshade",
        "Mathiisen Manor",
        "Humblemud",
        "The Ample Domicile",
        "Stay-Moist Mansion",
        "Snugpod",
        "Bouldertree Refuge",
        "The Gorinir Estate",
        "Captain Margaux's Place",
        "Ravenhurst",
        "Gardner House",
        "Kragenhome",
        "Velothi Reverie",
        "Quondam Indorilia",
        "Moonmirth House",
        "Sleek Creek House",
        "Dawnshadow",
        "Cyrodilic Jungle House",
        "Domus Phrasticus",
        "Strident Springs Demesne",
        "Autumn's-Gate",
        "Grymharth's Woe",
        "Old Mistveil Manor",
        "Hammerdeath Bungalow",
        "Mournoth Keep",
        "Forsaken Stronghold",
        "Twin Arches",
        "House of the Silent Magnifico",
        "Hunding's Palatial Hall",
        "Serenity Falls Estate",
        "Daggerfall Overlook",
        "Ebonheart Chateau",
        "Grand Topal Hideaway",
        "Earthtear Cavern",
    },
    colors={ 			
        default="|cC0392B",

		red="|cff0000", 	
		green="|c00ff00",
		blue="|c0000ff",
		
		cyan="|c00ffff",
		magenta="c|ff00ff",
		yellow="|cffff00",
		
		orange="|cffa700",
		purple="|c8800aa",
		pink="|cffaabb",
		brown="|c554400",
		
		white="|cffffff",
		black="|c000000",
		gray="|c888888"
	},       
    colorn="",
    colorh="",
    string=true,
 	defaultPersistentSettings={
        primaryhome="",
		colorname="default",
        colorhex="|cC0392B",
        showstring=true,
		guildacc=nil,
        friendacc=nil
	},
	persistentSettings={
    }
}

local roam = RoamHome

-- Initialize --
function RoamHome:Initialize()
	self.persistentSettings=ZO_SavedVars:NewAccountWide("RoamHomeVars",self.ver,nil,self.defaultPersistentSettings)
	self.colorn=self.persistentSettings.colorname
    self.colorh=self.persistentSettings.colorhex 
    self.guild=self.persistentSettings.guildacc
    self.friend=self.persistentSettings.friendacc
    self.string=self.persistentSettings.showstring
    self:CreateSettings()
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_HOME","Jump home")
	EVENT_MANAGER:UnregisterForEvent("RoamHome_OnLoaded",EVENT_ADD_ON_LOADED)
end

-- Convienence --
local function TableLength(tab)
    if not(tab) then return 0 end
    local Result=0
    for key,value in pairs(tab)do
        Result=Result+1 end
    return Result
end

local myFriendsOptions = {}

function GetFriendsList()
    local f=GetNumFriends()
    for i=1,f do -- loops through friends 
        table.insert(myFriendsOptions, tostring(GetFriendInfo(i)))
    end
end

--[[function PrintFriends()
    local f=GetNumFriends()
    for i=1,f do
        d(myFriendsOptions[i])
    end
end

function testfriends()
    GetFriendsList()
    PrintFriends()
end]]--

-- Addon functions --
function roam:GuildHouse(who)
    if (who and who~="") then
        self.guild=who
        self.persistentSettings.guildacc=self.guild
        self:Chat("Saved! Now you can just use /guild to jump") end
    if (self.guild~=nil) then
        if self.string then self:Chat("Traveling to guild home owned by "..self.guild) end
        JumpToHouse(self.guild)
    else self:Chat("Please enter the home owners name after /guild") self:Chat("Remember @ if account name (eg /guild @name)") end
end

function roam:FriendHouse(who)
    if (who and who~="") then
        self.friend=who
        self.persistentSettings.friendacc=self.friend
        self:Chat("Saved! Now you can just use /friend to jump") end
    if (self.friend~=nil) then
        if self.string then self:Chat("Traveling to "..self.friend.."'s primary home") end
        JumpToHouse(self.friend)
    else self:Chat("Please enter the home owners name after /friend") self:Chat("Remember @ if account name (eg /friend @name)") end
end

function roam:JumpHome(id)
    self.primary=GetHousingPrimaryHouse()
    local totalhouses,location,alliance,sall=TableLength(roam.houses),GetCurrentZoneHouseId(),tonumber(GetUnitAlliance("player")),""
    if (not id or id=="") then
        if (self.primary~=location) then
            if self.string then self:Chat("Traveling to primary home "..roam.houses[self.primary]) end
            RequestJumpToHouse(self.primary)
        else
            if alliance==1 then sall=roam.houses[1] RequestJumpToHouse(1)
            elseif alliance==2 then sall=roam.houses[3] RequestJumpToHouse(3)
            elseif alliance==3 then sall=roam.houses[2] RequestJumpToHouse(2) end
            if self.string then self:Chat("Traveling to room at "..sall) end end
    else
        local numid = tonumber(id)
            if (numid<=totalhouses) then
                if self.string then d("Traveling to "..roam.houses[numid]) end
                RequestJumpToHouse(numid)
            else self:Chat("Could not find house ID to jump to")
        end
    end
end

function roam:Chat(msg)
    d(self.colorh..msg.."|r")
end

-- Settings functions --
function RoamHome_JumpHome()
    roam:JumpHome()
end

function roam:DisableStrings(value)
    self.string=not self.string
    self.persistentSettings.showstring=self.string
end

function roam:ChangeStringColor(value)
    self.colorn=value
    self.persistentSettings.colorname=self.colorn
    self.colorh=self.colors[value]
    self.persistentSettings.colorhex=self.colorh
end

-- Settings --
function RoamHome:CreateSettings()
    GetFriendsList()
    local LAM=LibStub("LibAddonMenu-2.0")
    local defaultSettings={}
    local panelData = {
	    type = "panel",
	    name = "Roam Home",
	    displayName = "|c641E16Roam |cC0392BHome|r",
	    author = "mutiny",
        version = tostring(self.ver),
		registerForDefaults = true,
    slashCommand = "/roam"
    }
    local optionsData = {  
         [1] = {
            type = "header",
            name = "Display settings",
            width = "full",
            },
         [2] = {
            type = "checkbox",
            name = "Show destination in chat window",
            tooltip = "Does not hide system messages (default on)",
            width = "half",
            getFunc = function() return self.string end,
            setFunc = function(value) roam:DisableStrings(value) end,
            },
         [3] = {
            type = "dropdown",
            name = "Message color",
            tooltip = "You can choose any color (on this list)",
            choices = {"default","red","green","blue","cyan","magenta","yellow","orange","purple","pink","brown","white","black","gray",},
            width = "half",
            getFunc = function() return self.colorn end,
            setFunc = function(value) roam:ChangeStringColor(value) end,
            },
         [4] = {
            type = "header",
            name = "Friends Settings -- coming soon",
            width = "full",
            },
         [5] = {
            type = "dropdown",
            name = "Friends list",
            tooltip = "You can choose any color (on this list)",
            choices = myFriendsOptions,
            width = "half",
            getFunc = function() return end,
            setFunc = function(value) end,
            },
    }
    LAM:RegisterOptionControls("RoamHome", optionsData)
	LAM:RegisterAddonPanel("RoamHome", panelData)
end

-- Game hooks --
SLASH_COMMANDS["/guild"]=function(who) roam:GuildHouse(who) end
SLASH_COMMANDS["/friend"]=function(who) roam:FriendHouse(who) end
SLASH_COMMANDS["/home"]=function(id) roam:JumpHome(id) end
SLASH_COMMANDS["/f"]=function(id) testfriends() end


SLASH_COMMANDS["/guildpurge"]=function() roam.guild=nil roam.persistentSettings.guildacc=roam.guild end -- for fast debug
SLASH_COMMANDS["/homedebug"]=function() d("self.primary "..tostring(roam.primary).."  - self.guild "..tostring(roam.guild)) end -- for fast debug

EVENT_MANAGER:RegisterForEvent("RoamHome_OnLoaded",EVENT_ADD_ON_LOADED,function() roam:Initialize() end)