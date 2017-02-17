-- Global table --
RoamHome={
    ver=0.7,
    debug=nil,
    primary=nil,
    secondary=nil,
    string=nil,
    color="",
    hex="",
    friend="",
    friend2="",
    fstring="",
    guild="",
    guild2="",
    gstring="",
    hstring="",
    pdisplay="",
    sdisplay="",
    defaultPersistentSettings={
        debug=false,
        primary=GetHousingPrimaryHouse(),
        secondary=nil,
        string=true,
        color="default",
        hex="|cC0392B",
        friend="",
        friend2="",
        fstring="/friend",
        gstring="/guild",
        hstring="/home",
        pdisplay="",
        sdisplay="",
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
    self.debug=self.persistentSettings.debug
    self.primary=self.persistentSettings.primary
    self.pdisplay=self.persistentSettings.pdisplay
    self.secondary=self.persistentSettings.secondary
    self.sdisplay=self.persistentSettings.sdisplay
    self:FindApartment()
    self.string=self.persistentSettings.string
    self.color=self.persistentSettings.color
    self.hex=self.persistentSettings.hex
    self.friend=self.persistentSettings.friend
    self.friend2=self.persistentSettings.friend2
    self.fstring=self.persistentSettings.fstring
    self.guild=self.persistentSettings.guild
    self.guild2=self.persistentSettings.guild2
    self.gstring=self.persistentSettings.gstring
    self.hstring=self.persistentSettings.hstring
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

-- Addon --
function roam:JumpHome(id)
    local totalhouses,location=TableLength(self.stringlist.homes),GetCurrentZoneHouseId()
    if (not id or id=="") then
        if (self.primary~=location) then
            self:Chat("Traveling to primary home "..self.stringlist.homes[self.primary])
            RequestJumpToHouse(self.primary)
        else
            self:Chat("Traveling to secondary home "..self.stringlist.homes[self.secondary])
            RequestJumpToHouse(self.secondary) end
    else
        local numid = tonumber(id)
            if (numid<=totalhouses) then
                self:Chat("Traveling to "..self.stringlist.homes[numid])
                RequestJumpToHouse(numid)
            else self:Chat("Could not find house ID to jump to") end
    end
end

function RoamHome:FindApartment(arg)
    if (self.secondary==nil or arg=="force") then
        local alliance=tonumber(GetUnitAlliance("player"))
        if alliance==1 then roam.secondary=1 end
        if alliance==2 then roam.secondary=3 end
        if alliance==3 then roam.secondary=2 end
    else self:Chat("findapartment() could not save") end
    if self.debug then self:Chat("Roam Home set secondary home to "..self.secondary) end
end

-- Settings functions --
function RoamHome:SaveHome1(value)
    if (value=="default") then
        self.primary=GetHousingPrimaryHouse()
        self.persistentSettings.primary=self.primary
        self.pdisplay="default"
        self.persistentSettings.pdisplay=self.pdisplay
        if self.debug then self:Chat("Roam Home set primary home to "..self.primary.." & display to "..self.pdisplay) end
    else
        self.primary=value
        self.persistentSettings.primary=self.primary
        self.pdisplay=self.primary
        self.persistentSettings.pdisplay=self.pdisplay
        if self.debug then self:Chat("Roam Home set primary home to "..self.primary.." & display to "..self.pdisplay) end
    end
end

function RoamHome:SaveHome2(value)
    if (value=="default") then    
        self.FindApartment("force")
        self.sdisplay="default"
        self.persistentSettings.sdisplay=self.sdisplay
        if self.debug then self:Chat("Roam Home forced FindApartment() & display set to "..self.sdisplay) end
    else
        self.secondary=value
        self.persistentSettings.secondary=self.secondary
        self.sdisplay=self.secondary
        self.persistentSettings.sdisplay=self.sdisplay
        if self.debug then self:Chat("Roam Home set secondary home to "..self.secondary.." & display set to "..self.sdisplay) end
    end
end

function RoamHome:StringSettings(value)
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

function RoamHome:CommandSettings(value, who)
    if (who=="friend") then
        SLASH_COMMANDS[db.self.fstring]=nil
        self.fstring=value
        self.persistentSettings.fstring=self.fstring
    elseif (who=="guild") then
        self.gstring=value
        self.persistentSettings.gstring=self.gstring end
    if self.debug then self:Chat("Roam Home changed "..who.." command to "..value) end
end

function RoamHome:HouseSettings(value, who)
    if (who=="friend" or who=="friend2") then
        if (who=="friend") then
            self.friend=value
            self.persistentSettings.friend=self.friend
        else
            self.friend2=value
            self.persistentSettings.friend2=self.friend2 end
    elseif (who=="guild" or who=="guild2") then
        if (who=="guild") then
            self.guild=value
            self.persistentSettings.guild=self.guild
        else
            self.guild2=value
            self.persistentSettings.guild2=self.guild2 end end               
    if self.debug then self:Chat("Roam Home changed "..who.." to "..value) end
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
            },
         [4] = {
            type = "header",
            name = "|cC0392BHouse|r settings",
            width = "full",
            },
         [5] = {
            type = "editbox",
            name = "Primary home",
            tooltip = "Type default for your primary house or use @accountname",
            width = "half",
            getFunc = function() return self.pdisplay end,
            setFunc = function(value) self:SaveHome1(value) end,
            },
         [6] = {
            type = "editbox",
            name = "Secondary home",
            tooltip = "Type default for your free apartment or type @accountname",
            width = "half",
            getFunc = function() return self.sdisplay end,
            setFunc = function(value) self:SaveHome2(value) end,
            },
         [7] = {
            type = "submenu",
            name = "Friends saved homes",
            tooltip = "Save friends houses to jump to",
            width = "full",
            controls= {
               [1] = { -- starts friends menu --
                    type = "dropdown",
                    name = "Slash commands",
                    tooltip = "",
                    choices = {"/friend","/roamf","/homef"},
                    width = "full",
                    getFunc = function() return self.fstring end,
                    setFunc = function(value) self:CommandSettings(value, "friend") end,                
                    },
               [2] = {
                    type = "dropdown",
                    name = "Primary",
                    tooltip = "",
                    choices = myFriendsOptions,
                    width = "half",
                    getFunc = function() return self.friend end,
                    setFunc = function(value) self:HouseSettings(value, "friend") end,
                    },
               [3] = {
                    type = "dropdown",
                    name = "Secondary",
                    tooltip = "",
                    choices = myFriendsOptions,
                    width = "half",
                    getFunc = function() return self.friend2 end,
                    setFunc = function(value) self:HouseSettings(value, "friend2") end,
                    },
               [4] = {
                    type = "header",
                    name = "Coming soon :)",
                    width = "full",           
                    },
                [5] = {
                    type = "button",
                    name = "Add friend",
                    tooltip = "hello",
                    width = "half",
                    func = function() return end,
                    },
                [6] = {
                    type = "button",
                    name = "Remove friend",
                    tooltip = "hello",
                    width = "half",
                    func = function() return end,
                    },
            },
        },
         [8] = {  -- start guild dropdown
            type = "submenu",
            name = "Guild saved homes",
            tooltip = "Save guild homes to jump to",
            width = "full",
            controls= {
               [1] = {
                    type = "dropdown",
                    name = "Slash commands",
                    tooltip = "",
                    choices = {"/guild","/roamg","/homeg"},
                    width = "full",
                    getFunc = function() return self.gstring end,
                    setFunc = function(value) self:CommandSettings(value, "guild") end,                
                    },
               [2] = {
                    type = "editbox",
                    name = "Primary",
                    tooltip = "",
                    width = "half",
                    getFunc = function() return self.guild end,
                    setFunc = function(value) self:HouseSettings(value, "guild") end,
                    },
               [3] = {
                    type = "editbox",
                    name = "Secondary",
                    tooltip = "",
                    width = "half",
                    getFunc = function() return self.guild2 end,
                    setFunc = function(value) self:HouseSettings(value, "guild2") end,
                    },
               [4] = {
                    type = "header",
                    name = "Coming soon :)",
                    width = "full",           
                    },
                [5] = {
                    type = "button",
                    name = "Add friend",
                    tooltip = "hello",
                    width = "half",
                    func = function() return end,
                    },
                [6] = {
                    type = "button",
                    name = "Remove friend",
                    tooltip = "hello",
                    width = "half",
                    func = function() return end,
                    },
            },
        }
    }
    LAM:RegisterOptionControls("RoamHome", optionsData)
	LAM:RegisterAddonPanel("RoamHome", panelData)
end

-- Game hooks --
SLASH_COMMANDS["/home"]=function(id) roam:JumpHome() end
SLASH_COMMANDS["/string"]=function(id) d(tostring(roam.string)) end -- ?
SLASH_COMMANDS["/homedebug"]=function(id) roam.debug=not roam.debug roam:Chat("Roam Home debug: "..tostring(roam.debug)) roam.persistentSettings.debug=roam.debug end


EVENT_MANAGER:RegisterForEvent("RoamHome_OnLoaded",EVENT_ADD_ON_LOADED,function() roam:Initialize() end)