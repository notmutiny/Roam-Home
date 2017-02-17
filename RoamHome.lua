-- Global table --
RoamHome={
    ver=0.7,
    debug=nil,
    primary=nil,
    primaryz="",
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
    savedhousestrings={"Default home","Current location"},
    savedhouseids={"",""},
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
        guild="",
        guild2="",
        gstring="/guild",
        hstring="/home",
        pdisplay="Default home",
        sdisplay="Default home",
        savedhousestrings={"Default home","Current location"},
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
    self.pdisplay=self.persistentSettings.pdisplay
    self.secondary=self.persistentSettings.secondary
    self.sdisplay=self.persistentSettings.sdisplay
    self:FindApartment() -- mutinys bandaid for determining where default apartment is
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
    self.savedhousestrings=self.persistentSettings.savedhousestrings
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
function roam:JumpHome(id)
    local totalhouses,location=TableLength(self.stringlist.homes),GetCurrentZoneHouseId()
    if (id=="") then -- if where not specified
        if (self.primary~=location) then -- we aint home yet nigga
            self:Chat("Traveling to primary home ")--..self.stringlist.homes[self.primary])
            RequestJumpToHouse(self.primary) -- now we home
        else
            self:Chat("Traveling to secondary home ")--..self.stringlist.homes[self.secondary])
            RequestJumpToHouse(self.secondary) end
    else
        local numid = tonumber(id) -- someone specified which house they want to go to
            if (numid<=totalhouses) then
                self:Chat("Traveling via ID to home "..self.stringlist.homes[numid])
                RequestJumpToHouse(numid)
            else self:Chat("Could not find house ID to jump to")
        end
    end
end

function roam:JumpAccountHome(id, who)
    if (who=="friend") then
        if (id=="" or id=="1") then
            if self.friend=="" then
                self:Chat("Please enter the home owners name after /friend")
                self:Chat("Remember @ if account name (eg /friend @name)")
            else
                self:Chat("Traveling to friend home owned by "..self.friend)
                JumpToHouse(self.friend)
            end
        elseif (id=="2") then
            if self.friend2=="" then
                self:Chat("Please set up this command in Roam Home settings")
            else
                self:Chat("Traveling to friend home owned by "..self.friend2)
                JumpToHouse(self.friend2)
            end
        else
            self.friend=id
            self.persistentSettings.friend=self.friend
            self:Chat("Account saved! Now you can just use /friend to jump")
        end
    elseif (who=="guild") then
        if (id=="" or id=="1") then
            if self.guild=="" then
                self:Chat("Please enter the home owners name after /guild")
                self:Chat("Remember @ if account name (eg /guild @name)")
            else
                self:Chat("Traveling to guild home owned by "..self.guild)
                JumpToHouse(self.guild)
            end
        elseif (id=="2") then
            if self.guild2=="" then
                self:Chat("Please set up this command in Roam Home settings")
            else
                self:Chat("Traveling to guild home owned by "..self.guild2)
                JumpToHouse(self.guild2)
            end
        else
            self.guild=id
            self.persistentSettings.guild=self.guild
            self:Chat("Account saved! Now you can just use /guild to jump")
        end
    end
end

function RoamHome:FindApartment(arg)
    if (self.secondary==nil or arg=="force") then
        local alliance=tonumber(GetUnitAlliance("player"))
        if alliance==1 then roam.secondary=1 end
        if alliance==2 then roam.secondary=3 end
        if alliance==3 then roam.secondary=2 end
        roam.sdisplay="Free apartment"
        roam.persistentSettings.sdisplay=roam.sdisplay
    else self:Chat("findapartment() could not save") end
    if self.debug then self:Chat("Roam Home set secondary home to "..self.secondary) end
end

-- Settings functions --
function RoamHome:SaveHome(value, id)
    if (value=="Current location") then
        if (id=="1") then
            self.primary=GetCurrentZoneHouseId()
            self.persistentSettings.primary=self.primary
            self.pdisplay=self.stringlist.homes[self.primary]
            self.persistentSettings.pdisplay=self.pdisplay
            if self.debug then self:Chat("Roam Home set primary home to "..self.primary.." & display to "..self.pdisplay) end
        elseif (id=="2") then
            self.secondary=GetCurrentZoneHouseId()
            self.persistentSettings.secondary=self.secondary
            self.sdisplay=self.stringlist.homes[self.secondary]
            self.persistentSettings.sdisplay=self.sdisplay
            if self.debug then self:Chat("Roam Home set secondary home to "..self.secondary.." & display to "..self.sdisplay) end
        end
    else
        if (id=="1") then
            self.primary=GetHousingPrimaryHouse()
            self.persistentSettings.primary=self.primary
            self.pdisplay="Primary home"
            self.persistentSettings.pdisplay=self.pdisplay
        elseif (id=="2") then
            self:FindApartment("force")
            self.sdisplay="Free apartment"
            self.persistentSettings.sdisplay=self.sdisplay
        end
    end
end

function RoamHome:SaveCustomLocation(value)
    table.insert(self.savedhousestrings, value)
    table.insert(self.savedhouseids, GetCurrentZoneHouseId())
    self.persistentSettings.savedhousestrings=self.savedhousestrings
    self.persistentSettings.savedhouseids=self.savedhouseids
end

function RoamHome:SaveHomeName(value, id)
    if (id=="1") then
        table.insert(self.savedhousestrings, value)
        d("inserted "..value.." into table")
        self.persistentSettings.savedhousestrings=self.savedhousestrings
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

function RoamHome_JumpHome()
    roam:JumpHome()
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
            name = "|cC0392BHouse|r settings",
            width = "full",
            },
         [5] = {
            type = "dropdown",
            name = "Primary home",
            tooltip = "",
            width = "half",
            choices = self.savedhousestrings,
            getFunc = function() return self.pdisplay end,
            setFunc = function(value) self:SaveHome(value, "1") end,
            },
         [6] = {
            type = "editbox",
            name = "Save name",
            tooltip = "Input a home to travel to with /guild",
            width = "half",
            getFunc = function() return end,
            setFunc = function(value) self:SaveCustomLocation(value, "1") end,
            },
         [7] = {
            type = "dropdown",
            name = "Secondary home",
            tooltip = "",
            width = "half",
            choices = self.savedhousestrings,
            getFunc = function() return self.sdisplay end,
            setFunc = function(value) self:SaveHome(value, "2") end,
            },
         [8] = {
            type = "editbox",
            name = "Save name",
            tooltip = "Input a home to travel to with /guild",
            width = "half",
            getFunc = function() return end,
            setFunc = function(value) end,
            },
         [9] = {
            type = "submenu",
            name = "Friends saved homes",
            tooltip = "",
            width = "full",
            controls= {
               [1] = { -- starts friends menu --
                    type = "dropdown",
                    name = "Slash commands",
                    tooltip = "custom DISABLED FOR 0.7 am soz",
                    choices = {"/friend","/roamf","/homef"},
                    width = "full",
                    getFunc = function() return self.fstring end,
                    setFunc = function(value) self:CommandSettings(value, "friend") end,                
                    },
               [2] = {
                    type = "dropdown",
                    name = "Primary",
                    tooltip = "Select a home to travel to with /friend",
                    choices = myFriendsOptions,
                    width = "half",
                    getFunc = function() return self.friend end,
                    setFunc = function(value) self:HouseSettings(value, "friend") end,
                    },
               [3] = {
                    type = "dropdown",
                    name = "Secondary",
                    tooltip = "Select a home to travel to with /friend 2",
                    choices = myFriendsOptions,
                    width = "half",
                    getFunc = function() return self.friend2 end,
                    setFunc = function(value) self:HouseSettings(value, "friend2") end,
                    },
               [4] = {
                    type = "header",
                    name = "",
                    width = "full",           
                    },
                [5] = {
                    type = "button",
                    name = "Add friend",
                    tooltip = "Coming soon :)",
                    width = "half",
                    func = function() return end,
                    },
                [6] = {
                    type = "button",
                    name = "Remove friend",
                    tooltip = "Coming soon :)",
                    width = "half",
                    func = function() return end,
                    },
            },
        },
         [10] = {  -- start guild dropdown
            type = "submenu",
            name = "Guild saved homes",
            tooltip = "",
            width = "full",
            controls= {
               [1] = {
                    type = "dropdown",
                    name = "Slash commands",
                    tooltip = "custom DISABLED FOR 0.7 am soz",
                    choices = {"/guild","/roamg","/homeg"},
                    width = "full",
                    getFunc = function() return self.gstring end,
                    setFunc = function(value) self:CommandSettings(value, "guild") end,                
                    },
               [2] = {
                    type = "editbox",
                    name = "Primary",
                    tooltip = "Input a home to travel to with /guild",
                    width = "half",
                    getFunc = function() return self.guild end,
                    setFunc = function(value) self:HouseSettings(value, "guild") end,
                    },
               [3] = {
                    type = "editbox",
                    name = "Secondary",
                    tooltip = "Input a home to travel to with /guild 2",
                    width = "half",
                    getFunc = function() return self.guild2 end,
                    setFunc = function(value) self:HouseSettings(value, "guild2") end,
                    },
               [4] = {
                    type = "header",
                    name = "",
                    width = "full",           
                    },
                [5] = {
                    type = "button",
                    name = "Add member",
                    tooltip = "Coming soon :)",
                    width = "half",
                    func = function() return end,
                    },
                [6] = {
                    type = "button",
                    name = "Remove member",
                    tooltip = "Coming soon :)",
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
SLASH_COMMANDS["/test"]=function(id) d(TableLength(roam.savedhousestrings)) end
SLASH_COMMANDS["/home"]=function(id) roam:JumpHome(id) end
SLASH_COMMANDS["/friend"]=function(id) roam:JumpAccountHome(id,"friend") end
SLASH_COMMANDS["/guild"]=function(id) roam:JumpAccountHome(id,"guild") end
SLASH_COMMANDS["/homedebug"]=function(id) roam.debug=not roam.debug roam:Chat("Roam Home debug: "..tostring(roam.debug)) roam.persistentSettings.debug=roam.debug end


EVENT_MANAGER:RegisterForEvent("RoamHome_OnLoaded",EVENT_ADD_ON_LOADED,function() roam:Initialize() end)