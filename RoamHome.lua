-- Global table --
RoamHome={
    ver=0.7,
    primary=nil,
    secondary=nil,
    string=nil,
    color="",
    hex="",
    defaultPersistentSettings={
        primary=GetHousingPrimaryHouse(),
        secondary=nil,
        string=true,
        color="default",
        hex="|cC0392B"
    },
	persistentSettings={ },
    stringlist={
        homes={ -- "now this is what i'd call data-driven" ;)
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
        }
    }
}

local roam = RoamHome

-- Initialize --
function RoamHome:Initialize()
	self.persistentSettings=ZO_SavedVars:NewAccountWide("RoamHomeVars",self.ver,nil,self.defaultPersistentSettings)
    self.primary=self.persistentSettings.primary
    self.secondary=self.persistentSettings.secondary
    self.string=self.persistentSettings.string
    self.color=self.persistentSettings.color
    self.hex=self.persistentSettings.hex
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

function RoamHome:Chat(msg)
    if self.string then d(self.hex..msg.."|r") end
end
-- Settings functions --
function RoamHome:StringSettings(value)
    if value==true or value==false then
        self.string=not self.string
        self.persistentSettings.string=self.string
        self:Chat("toggled chat")
    else 
        self.color=value
        self.persistentSettings.color=self.color
        self.hex=self.stringlist.colors[value]
        self.persistentSettings.hex=self.hex
        self:Chat("color changed to "..value)
    end
    --self.string=not self.string
    --self.persistentSettings.string=self.string
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
            name = "|cC0392BDisplay|r settings",
            width = "full",
            },
         [2] = {
            type = "checkbox",
            name = "Show destination in chat window",
            tooltip = "(default on)",
            width = "half",
            getFunc = function() return self.string end,
            setFunc = function(value) self:StringSettings(value) end,
            },
         [3] = {
            type = "dropdown",
            name = "Message color",
            tooltip = "You can choose any color (on this list)",
            choices = {"default","red","green","blue","cyan","magenta","yellow","orange","purple","pink","brown","white","black","gray",},
            width = "half",
            getFunc = function() return self.color end,
            setFunc = function(value) self:StringSettings(value) end,
            }
        }
    LAM:RegisterOptionControls("RoamHome", optionsData)
	LAM:RegisterAddonPanel("RoamHome", panelData)
end


SLASH_COMMANDS["/home"]=function(id) roam:Chat(tostring(roam.string)) end
SLASH_COMMANDS["/string"]=function(id) d(tostring(roam.string)) end


EVENT_MANAGER:RegisterForEvent("RoamHome_OnLoaded",EVENT_ADD_ON_LOADED,function() roam:Initialize() end)