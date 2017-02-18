-- Global table --
RoamHome={
    ver=1.3,
    debug=nil, -- makes mutinys life easier
    primary="", -- primary home for us
    primaryzone="", -- where that house is located
    secondary="", -- second home for us
    secondaryzone="",
    string=nil, -- shows strings globally
    color="", -- string color
    hex="", -- string hex
    hstring="", -- /home or /roam
    pdisplay="", -- what displays as primary home in settings
    sdisplay="", -- what displays as secondary home
    savedhousestrings={}, -- saved (nick)names for houses
    savedhouseids={"",""}, -- where jumpto() goes (id or @accn)
    primaryid=true, -- is it an @accn or id
    secondaryid=true,
    defaultPersistentSettings={
        debug=false,
        primary=GetHousingPrimaryHouse(),
        primaryzone="",
        secondary="",
        secondaryzone="",
        string=true,
        color="default",
        hex="|cC0392B",
        hstring="/home",
        pdisplay="Primary Home",
        sdisplay="Free Apartment",
        savedhousestrings={"Primary Home","Free Apartment"},
        savedhouseids={GetHousingPrimaryHouse(),""},           
        primaryid=true,
        secondaryid=true
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
function RoamHome:Initialize() -- holy hell I need to shorten this
	self.persistentSettings=ZO_SavedVars:NewAccountWide("RoamHomeVars",self.ver,nil,self.defaultPersistentSettings)
    self.debug=self.persistentSettings.debug
    self.primary=self.persistentSettings.primary
    self.primaryzone=self.persistentSettings.primaryzone
    self.secondary=self.persistentSettings.secondary
    self.secondaryzone=self.persistentSettings.secondaryzone
    self.string=self.persistentSettings.string
    self.color=self.persistentSettings.color
    self.hex=self.persistentSettings.hex
    self.hstring=self.persistentSettings.hstring
    self.pdisplay=self.persistentSettings.pdisplay
    self.sdisplay=self.persistentSettings.sdisplay
    self.savedhousestrings=self.persistentSettings.savedhousestrings
    self.savedhouseids=self.persistentSettings.savedhouseids
    self.primaryid=self.persistentSettings.primaryid
    self.secondaryid=self.persistentSettings.secondaryid
    self:FindApartment()
    self:CreateSettings() -- creates settings VERY DELICATE do NOT derp inside function
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

-- Addon --
function RoamHome:JumpHome(id)
    local totalhouses,location,numid=TableLength(self.stringlist.homes),GetCurrentZoneHouseId(),tonumber(id)
    if (id=="") then -- if where not specified
        if self.primary~=location then
            if self.primaryid then
                self:Chat("Traveling to primary home "..self.stringlist.homes[self.primary])
                RequestJumpToHouse(self.primary) -- now we home             
            else
                self:Chat("Traveling to home owned by "..self.primary)
                RequestJumpToHouse(self.primary)
            end
        else
            if self.secondaryid then
                self:Chat("Traveling to secondary home "..self.stringlist.homes[self.secondary])
                RequestJumpToHouse(self.secondary) -- now we home             
            else
                self:Chat("Traveling to secondary home owned by "..self.secondary)
                RequestJumpToHouse(self.secondary)
            end
        end
    else
        if (numid<=totalhouses) then
            self:Chat("Traveling via home ID to "..self.stringlist.homes[numid])
            RequestJumpToHouse(numid)
        else self:Chat("Could not find house ID to jump to") end
    end
end

function RoamHome:FindApartment(arg) -- done ?
    local alliance=tonumber(GetUnitAlliance("player"))
    if (self.secondary=="" or arg=="secondary") then
        if alliance==1 then roam.secondary=1 end
        if alliance==2 then roam.secondary=3 end
        if alliance==3 then roam.secondary=2 end
        roam.sdisplay="Free Apartment"
        roam.persistentSettings.secondary=roam.secondary
        roam.persistentSettings.sdisplay=roam.sdisplay
        if roam.debug then roam:Chat("Roam Home set secondary home to "..roam.secondary) end
    elseif (arg=="primary") then
        if alliance==1 then roam.primary=1 end
        if alliance==2 then roam.primary=3 end
        if alliance==3 then roam.primary=2 end
        roam.pdisplay="Free Apartment"
        roam.persistentSettings.primary=roam.primary
        roam.persistentSettings.pdisplay=roam.pdisplay
        if roam.debug then roam:Chat("Roam Home set primary home to "..roam.primary) end
    else return end
end

-- Settings --
local friendcache=""
local friendnamecache=""

function RoamHome:SaveFriend() -- save cache to table
    if friendcache=="" then return end
    table.insert(self.savedhouseids, friendcache)
    if friendnamecache=="" then
        table.insert(self.savedhousestrings, friendcache)
    else table.insert(self.savedhousestrings, friendnamecache) end
    ReloadUI()
end

function RoamHome:SelectHome(value,id)
    if (id=="primary") then
        if (value=="Primary Home") then
            self.primary=GetHousingPrimaryHouse()
            self.persistentSettings.primary=self.primary
            self.pdisplay="Primary home"
            self.persistentSettings.pdisplay=self.pdisplay
            self.primaryid=true
            self.persistentSettings.primaryid=self.primaryid
            if self.debug then self:Chat("Roam Home set primary home to "..self.primary.." & display to "..self.pdisplay) end
        elseif (value=="Free Apartment") then
            self:FindApartment("primary")
            self.primaryid=true
            self.persistentSettings.primaryid=self.primaryid
            if self.debug then self:Chat("Roam Home forced roam:FindApartment primary") end
        else
            self.primaryid=false -- is not a homeid (@account)
            self.persistentSettings.primaryid=self.primaryid
            self.primary=value
            self.persistentSettings.primary=self.primary
            self.pdisplay=self.primary
            self.persistentSettings.pdisplay=self.pdisplay
            if self.debug then self:Chat("Roam Home set primary home to "..self.primary.." & display to "..self.pdisplay) end
        end
    elseif (id=="secondary") then
        if (value=="Primary Home") then
            self.secondary=GetHousingPrimaryHouse()
            self.persistentSettings.secondary=self.secondary
            self.sdisplay="Primary home"
            self.persistentSettings.sdisplay=self.sdisplay
            self.secondaryid=true
            self.persistentSettings.secondaryid=self.secondaryid
            if self.debug then self:Chat("Roam Home set secondary home to "..self.secondary.." & display to "..self.sdisplay) end
        elseif (value=="Free Apartment") then
            self:FindApartment("secondary")
            self.secondaryid=true
            self.persistentSettings.secondaryid=self.secondaryid
            if self.debug then self:Chat("Roam Home forced roam:FindApartment secondary") end
        else
            self.secondaryid=false -- is not a homeid (@account)
            self.persistentSettings.secondaryid=self.secondaryid
            self.secondary=value
            self.persistentSettings.secondary=self.secondary
            self.sdisplay=self.secondary
            self.persistentSettings.sdisplay=self.sdisplay
            if self.debug then self:Chat("Roam Home set secondary home to "..self.secondary.." & display to "..self.sdisplay) end
        end
    end
end

function RoamHome:StringSettings(value) -- is complete
    if value==true or value==false then
        self.string=not self.string
        self.persistentSettings.string=self.string
        if self.debug then self:Chat("Roam Home toggled chat: "..tostring(self.string)) end
    else 
        self.color=value
        self.persistentSettings.color=self.color
        self.hex=self.stringlist.colors[value]
        self.persistentSettings.hex=self.hex
        if self.debug then self:Chat("Roam Home changed color to "..value) end
    end
end

function RoamHome:CommandSettings(value, who) -- format done needs to be completed
    if (who=="home") then
        self.hstring=value
        self.persistentSettings.hstring=self.hstring
        if self.debug then self:Chat("Roam Home changed "..who.." command to "..value) end
    end
end

function RoamHome_JumpHome() -- needed for hotkey
    roam:JumpHome()
end

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
            type = "header", -- DISPLAY SETTINGS
            name = "|cC0392BDisplay|r settings",
            width = "full",
            },
         [2] = {
            type = "checkbox",
            name = "Show destination in chat window",
            tooltip = "",
            width = "half",
            getFunc = function() return self.string end,
            setFunc = function(value) self:StringSettings(value) end,
            },
         [3] = {
            type = "dropdown",
            name = "Message color",
            tooltip = "",
            choices = {"default","red","green","blue","cyan","magenta","yellow","orange","purple","pink","brown","white","black","gray",},
            width = "half",
            getFunc = function() return self.color end,
            setFunc = function(value) self:StringSettings(value) end,
            },
         [4] = {
            type = "header", -- START HOME SETTINGS --
            name = "|cC0392BHome|r settings",
            width = "full",
            },
         [5] = {
            type = "dropdown",
            name = "Slash commands",
            tooltip = "",
            choices = {"/home","/roam"},
            width = "full",
            getFunc = function() return self.hstring end,
            setFunc = function(value) self:CommandSettings(value, "home") end,
            },
         [6] = {
            type = "dropdown",
            name = "Primary home",
            tooltip = "Select home to travel to with /home",
            width = "half",
            choices = self.savedhousestrings,
            getFunc = function() return self.pdisplay end,
            setFunc = function(value) self:SelectHome(value, "primary") end,
            },
         [7] = {
            type = "dropdown",
            name = "   Secondary home",
            tooltip = "Select home to travel to with /home",
            width = "half",
            choices = self.savedhousestrings,
            getFunc = function() return self.sdisplay end,
            setFunc = function(value) self:SelectHome(value, "secondary") end,
            },
         [8] = {
            type = "submenu",
            name = "Add homes",
            tooltip = "",
            width = "full",
            controls= { -- START FRIEND SETTINGS --
               [1] = {
                    type = "header",
                    name = "|cC0392BFriends|r",
                    width = "full",           
                    },
               [2] = {
                    type = "dropdown",
                    name = "@accountname",
                    tooltip = "",
                    choices = myFriendsOptions,
                    width = "full",
                    getFunc = function() return end,
                    setFunc = function(value) friendcache=value end,                
                    },
                [3] = {
                    type = "editbox",
                    name = "Nickname (optional)",
                    tooltip = "Save a name to access this home later",
                    width = "full",
                    getFunc = function() return end,
                    setFunc = function(value) friendnamecache=value end,
                    },
                [4] = {
                    type = "button",
                    name = "Save home",
                    tooltip = "This will reload the UI",
                    width = "full",
                    func = function() return self:SaveFriend() end,
                    },
               [5] = {
                    type = "header",
                    name = "|cC0392BEveryone|r",
                    width = "half",           
                    },
               [6] = {
                    type = "editbox",
                    name = "@accountname",
                    tooltip = "",
                    width = "full",
                    getFunc = function() return end,
                    setFunc = function(value) end,                
                    },
                [7] = {
                    type = "editbox",
                    name = "Nickname (optional)",
                    tooltip = "Save a name to access this home later",
                    width = "full",
                    getFunc = function() return end,
                    setFunc = function(value) end,
                    },
                [8] = {
                    type = "button",
                    name = "Save home",
                    tooltip = "This will reload the UI",
                    width = "full",
                    func = function() return end,
                    },
                },
        },
    }
    LAM:RegisterOptionControls("RoamHome", optionsData)
	LAM:RegisterAddonPanel("RoamHome", panelData)
end

-- Game hooks --
SLASH_COMMANDS["/test"]=function(id) d("primary: "..roam.primary.."  secondary: "..roam.secondary) end
SLASH_COMMANDS["/home"]=function(id) roam:JumpHome(id) end
SLASH_COMMANDS["/friend"]=function(id) roam:JumpAccountHome(id,"friend") end
SLASH_COMMANDS["/guild"]=function(id) roam:JumpAccountHome(id,"guild") end
SLASH_COMMANDS["/homedebug"]=function(id) roam.debug=not roam.debug roam:Chat("Roam Home debug: "..tostring(roam.debug)) roam.persistentSettings.debug=roam.debug end


EVENT_MANAGER:RegisterForEvent("RoamHome_OnLoaded",EVENT_ADD_ON_LOADED,function() roam:Initialize() end)