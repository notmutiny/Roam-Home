-- Global table --
RoamHome={
    ver=0.3,
    primary="",
    guild=nil,
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
    string=true,
 	defaultPersistentSettings={
        primaryhome="",
        showstring=true,
		guildacc=nil
	},
	persistentSettings={
    }
}

local roam = RoamHome

-- Initialize --
function RoamHome:Initialize()
	self.persistentSettings=ZO_SavedVars:NewAccountWide("RoamHomeVars",self.ver,nil,self.defaultPersistentSettings)
    self.guild=self.persistentSettings.guildacc
    self.string=self.persistentSettings.showstring
    self:CreateSettings()
    ZO_CreateStringId("SI_BINDING_NAME_ROAMHOME", "JumpHome")
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

-- Addon functions --
function roam:GuildHouse(who)
    if (who and who~="") then
        self.guild=who
        self.persistentSettings.guildacc=self.guild
        d("Saved! Now you can just use /guild to jump") end
    if (self.guild~=nil) then
        if self.string then d("Traveling to guild house owned by "..self.guild) end
        JumpToHouse(self.guild)
    else d("Please enter the house owners name after /guild") d("Remember @ if account name (eg /guild @name)") end
end

function roam:JumpHome(id)
    self.primary=GetHousingPrimaryHouse()
    local totalhouses,location,alliance,sall=TableLength(roam.houses),GetCurrentZoneHouseId(),tonumber(GetUnitAlliance("player")),""
    if (id=="") then
        if (self.primary~=location) then
            if self.string then d("Traveling to primary home "..roam.houses[self.primary]) end
            RequestJumpToHouse(self.primary)
        else
            if alliance==1 then sall=roam.houses[1] RequestJumpToHouse(1)
            elseif alliance==2 then sall=roam.houses[3] RequestJumpToHouse(3)
            elseif alliance==3 then sall=roam.houses[2] RequestJumpToHouse(2) end
            if self.string then d("Traveling to room at "..sall) end end
    else
        local numid = tonumber(id)
            if (numid<=totalhouses) then
                if self.string then d("Traveling to "..roam.houses[numid]) end
                RequestJumpToHouse(numid)
            else d("Could not find house ID to jump to") end
    end
end

function roam:DisableStrings(value)
    self.string=not self.string
    self.persistentSettings.showstring=self.string
    d(self.string)
end

-- Settings --
function RoamHome:CreateSettings()
    local LAM=LibStub("LibAddonMenu-2.0")
    local defaultSettings={}
    local panelData = {
	    type = "panel",
	    name = "Roam Home",
	    displayName = ZO_HIGHLIGHT_TEXT:Colorize("Roam Home"),
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
            choices = {},
            width = "half",
            getFunc = function() return self.string end,
            setFunc = function(value) roam:DisableStrings(value) end,
            },
         [4] = {
            type = "header",
            name = "Friends",
            width = "full",
         },
    }
    LAM:RegisterOptionControls("RoamHome", optionsData)
	LAM:RegisterAddonPanel("RoamHome", panelData)
end

-- Game hooks --
SLASH_COMMANDS["/guild"]=function(who) roam:GuildHouse(who) end
SLASH_COMMANDS["/home"]=function(id) roam:JumpHome(id) end

SLASH_COMMANDS["/guildpurge"]=function() roam.guild=nil roam.persistentSettings.guildacc=roam.guild end -- for fast debug
SLASH_COMMANDS["/homeD"]=function() d("self.primary "..tostring(roam.primary).."  - self.guild "..tostring(roam.guild)) end -- for fast debug
SLASH_COMMANDS["/table"]=function() d(TableLength(roam.houses)) end

EVENT_MANAGER:RegisterForEvent("RoamHome_OnLoaded",EVENT_ADD_ON_LOADED,function() roam:Initialize() end)