-- Global table --
RoamHome={
    ver=1.397,
    debug=nil, -- makes mutinys life easier
    string=nil, -- shows strings globally
    primary="", -- primary home id for us
    primestring="", -- settings string to load
    secondary="", -- second home id for us
    secondstring="", -- settings string to load
    homes={}, -- our saved homes table
    binds={}, -- our keybinds table
    color={}, -- string color,hex
    slash="", -- /home or /roam
    primaryid=true, -- is it an @accn or id DEL
    secondaryid=true, -- DEL
    defaultPersistentSettings={
        debug=false,
        primary=nil,
        primestring="",
        secondary=nil,
        secondstring=nil,
        homes={
            {nil,nil,""}, -- ID, @accountname, home name
            {nil,nil,""},
        },
        binds={
            bind1="",
            bind2="",
            bind3="",
            bind4="",
            bind5="",
        },
        string=true,
        color={"default","|cC0392B"},
        slash="/home",
        pdisplay="Primary Home",
        sdisplay="Free Apartment",   
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
            magenta="|cff00ff",
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
function RoamHome:Initialize() -- holey moley I need to shorten this
	self.persistentSettings=ZO_SavedVars:NewAccountWide("RoamHomeVars",self.ver,nil,self.defaultPersistentSettings)
    self.debug=self.persistentSettings.debug
    self.primary=self.persistentSettings.primary
    self.primestring=self.persistentSettings.primestring
    self.secondary=self.persistentSettings.secondary
    self.secondstring=self.persistentSettings.secondstring
    self.homes=self.persistentSettings.homes -- new
    self.string=self.persistentSettings.string
    self.color=self.persistentSettings.color
    self.slash=self.persistentSettings.slash
    self.savedhousestrings=self.persistentSettings.savedhousestrings
    self.savedhouseids=self.persistentSettings.savedhouseids
    self.primaryid=self.persistentSettings.primaryid
    self.secondaryid=self.persistentSettings.secondaryid
    self.binds=self.persistentSettings.binds -- new
    self:CleanStringsUpdate()
    self:CreateSettings() -- creates settings VERY DELICATE do NOT derp inside function
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_HOME","Travel home (/home)")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND1","Keybind 1")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND2","Keybind 2")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND3","Keybind 3")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND4","Keybind 4")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND5","Keybind 5")
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

local function GetFriendsList()
    local f=GetNumFriends()
    for i=1,f do -- loops through friends 
        table.insert(myFriendsOptions, tostring(GetFriendInfo(i)))
    end
end

local mySavedHomes = {}

local function GetSavedHomes() -- new
    for i=1,TableLength(roam.homes) do
        table.insert(mySavedHomes, roam.homes[i][3])
    end
end

-- Addon --
function RoamHome:JumpHome(id) -- new
    local totalhouses,location,numid,nump,nums=TableLength(self.stringlist.homes),GetCurrentZoneHouseId(),tonumber(id),tonumber(self.primary),tonumber(self.secondary)
    if (id=="") then -- if where not specified
        for i=1,TableLength(self.homes) do
            if self.homes[i][3]==self.primestring then -- loads all table data
                if self.homes[i][1]~=location then -- if were not at primary
                    self:Chat("Traveling to primary home "..self.homes[i][3])
                    if nump~=nil then RequestJumpToHouse(self.homes[i][1])
                    else JumpToHouse(self.homes[i][2]) end
                    return
                else
                    if self.primestring==self.secondstring then return end
                    for j=1,TableLength(self.homes) do
                        if self.homes[j][3]==self.secondstring then -- loads all table data                
                            self:Chat("Traveling to secondary home "..self.homes[j][3])
                            if nums~=nil then RequestJumpToHouse(self.homes[j][1])
                            else JumpToHouse(self.homes[j][2]) end
                            return
                        end
                    end
                end
            end
        end
    elseif (numid~=nil and numid<=totalhouses) then
        self:Chat("Traveling via home ID to "..self.stringlist.homes[numid])
        RequestJumpToHouse(numid)
    else self:Chat("Could not find home ID to travel to") end
end

function RoamHome:CleanStringsUpdate() -- new
    local primaryid,alliance,aptnum=GetHousingPrimaryHouse(),tonumber(GetUnitAlliance("player")),nil
    if self.homes[1][3]=="" then
        self.homes[1][1]=primaryid
        self.homes[1][3]=self.stringlist.homes[primaryid]
        self.persistentSettings.homes[1]=self.homes[1]
        self.primestring=self.homes[1][3]
        self.persistentSettings.primestring=self.primestring        
        if alliance==1 then aptnum=1 end
        if alliance==2 then aptnum=3 end
        if alliance==3 then aptnum=2 end
        if self.homes[1][1]~=aptnum then
            self.homes[2][1]=aptnum
            self.homes[2][3]=self.stringlist.homes[self.homes[2][1]]
            self.persistentSettings.homes[2]=self.homes[2]
            self.secondstring=self.homes[2][3]
            self.persistentSettings.secondstring=self.secondstring
        end
    end
end

function RoamHome:Chat(msg)
    if self.string then d(self.color[2]..msg.."|r") end
end


-- Settings --

local friendcache=""
local friendnamecache=""

local homecache=""
local homenamecache=""

function RoamHome:SaveAccount() -- save cache to table
    if friendcache=="" then return end
    if friendnamecache=="" then table.insert(self.homes,{nil,friendcache,friendcache})
    else table.insert(self.homes,{nil,friendcache,friendnamecache}) end
    self.persistentSettings.homes=self.homes
    for i=1,TableLength(self.homes) do
        if self.homes[i][2]==friendcache then
            self.secondary=self.homes[i][2]
            self.secondstring=self.homes[i][3]
            self.persistentSettings.secondary=self.secondary
            self.persistentSettings.secondstring=self.secondstring
            break end
    ReloadUI() end
end

function RoamHome:SetKeybind(value, id)
    if id=="1" then
        self.binds.bind1=value
        self.persistentSettings.binds.bind1=self.binds.bind1
    elseif id=="2" then
        self.binds.bind2=value
        self.persistentSettings.binds.bind2=self.binds.bind2
    elseif id=="3" then
        self.binds.bind3=value
        self.persistentSettings.binds.bind3=self.binds.bind3
    elseif id=="4" then
        self.binds.bind4=value
        self.persistentSettings.binds.bind4=self.binds.bind4
    elseif id=="5" then
        self.binds.bind5=value
        self.persistentSettings.binds.bind5=self.binds.bind5
    else return end
end

function RoamHome:SelectHome(value,id) -- new
    if (id=="primary" or id=="secondary") then
        for i=1,TableLength(self.homes) do
            if self.homes[i][3]==value then
                if id=="primary" then
                    self.primary=self.homes[i][1]
                    self.primestring=self.homes[i][3]
                    self.persistentSettings.primary=self.primary
                    self.persistentSettings.primestring=self.primestring    
                    if self.debug then self:Chat("Roam Home set primary to ["..tostring(self.homes[i][1]).."] ["..tostring(self.homes[i][2]).."] ["..tostring(self.homes[i][3]).."]") return end
                elseif id=="secondary" then
                    self.secondary=self.homes[i][1]
                    self.secondstring=self.homes[i][3]
                    self.persistentSettings.secondary=self.secondary
                    self.persistentSettings.secondstring=self.secondstring    
                    if self.debug then self:Chat("Roam Home set secondary to ["..tostring(self.secondary).."] ["..tostring(self.homes[i][2]).."] ["..tostring(self.secondstring).."]") return end
                end
            end
        end
    end
end

function RoamHome:HomeBind() -- merge with jump home
    local location=GetCurrentZoneHouseId()
    if self.primary~=location then
        if self.primaryid then
            self:Chat("Traveling to primary home "..self.stringlist.homes[self.primary])
            RequestJumpToHouse(self.primary) -- now we home             
        else
            self:Chat("Traveling to primary home owned by "..self.primary)
            JumpToHouse(self.primary)
        end
    else
        if self.secondaryid then
            self:Chat("Traveling to secondary home "..self.stringlist.homes[self.secondary])
            RequestJumpToHouse(self.secondary)            
        else
            self:Chat("Traveling to secondary home owned by "..self.secondary)
            JumpToHouse(self.secondary)
        end
    end
end

function RoamHome:JumpBind1()
    self:Chat("Traveling to home owned by "..self.binds.bind1)
    JumpToHouse(self.binds.bind1)       
end

function RoamHome:JumpBind2()
    self:Chat("Traveling to home owned by "..self.binds.bind2)
    JumpToHouse(self.binds.bind2)      
end

function RoamHome:JumpBind3()
    self:Chat("Traveling to home owned by "..self.binds.bind3)
    JumpToHouse(self.binds.bind3)      
end

function RoamHome:JumpBind4()
    self:Chat("Traveling to home owned by "..self.binds.bind4)
    JumpToHouse(self.binds.bind4)        
end

function RoamHome:JumpBind5()
    self:Chat("Traveling to home owned by "..self.binds.bind5)
    JumpToHouse(self.binds.bind5)         
end

function RoamHome:ChangeCommand(value)
    self.slash=value
    self.persistentSettings.slash = self.slash
end

function RoamHome:PersistentCommand(id, who)
    if who=="roam" and self.slash=="/roam" then
        self:JumpHome(id)
    elseif who=="home" and self.slash=="/home" then
        self:JumpHome(id)
    else return end
end

function RoamHome:StringSettings(value) -- is complete
    if value==true or value==false then
        self.string=not self.string
        self.persistentSettings.string=self.string
        if self.debug then self:Chat("Roam Home toggled chat: "..tostring(self.string)) end
    else 
        self.color[1]=value
        self.color[2]=self.stringlist.colors[value]
        self.persistentSettings.color=self.color
        if self.debug then self:Chat("Roam Home changed color to "..value) end
    end
end

function RoamHome:CommandSettings(value, who)
    if (who=="home") then
        self.slash=value
        self.persistentSettings.slash=self.slash
        if self.debug then self:Chat("Roam Home changed "..who.." command to "..value) end
    end
end

function RoamHome_JumpHome() -- needed for hotkey
    roam:HomeBind()
end

function RoamHome_JumpBind1() -- needed for hotkey
    roam:JumpBind1()
end

function RoamHome_JumpBind2() -- needed for hotkey
    roam:JumpBind2()
end

function RoamHome_JumpBind3() -- needed for hotkey
    roam:JumpBind3()
end

function RoamHome_JumpBind4() -- needed for hotkey
    roam:JumpBind4()
end

function RoamHome_JumpBind5() -- needed for hotkey
    roam:JumpBind5()
end

function RoamHome:CreateSettings()
    GetFriendsList()
    GetSavedHomes()
    local LAM=LibStub("LibAddonMenu-2.0")
    local defaultSettings={}
    local panelData = {
	    type = "panel",
	    name = "Roam Home",
	    displayName = self.color[2].."Roam Home",
	    author = "mutiny",
        version = tostring(self.ver),
		registerForDefaults = true,
    slashCommand = "/roamhome"
    }
    local optionsData = {
        [1] = {
            type = "header", -- DISPLAY SETTINGS
            name = self.color[2].."Display|r settings",
            width = "full",
            },
         [2] = {
            type = "checkbox", 
            name = "Show destination in chat window",
            width = "half",
            getFunc = function() return self.string end,
            setFunc = function(value) self:StringSettings(value) end,
            },
         [3] = {
            type = "dropdown",
            name = "Message color",
            choices = {"default","red","green","blue","cyan","magenta","yellow","orange","purple","pink","brown","white","gray"},
            width = "half",
            getFunc = function() return self.color[1] end,
            setFunc = function(value) self:StringSettings(value) end,
            },
         [4] = {
            type = "header", -- START HOME SETTINGS --
            name = self.color[2].."Home|r settings",
            width = "full",
            },
         [5] = {
            type = "dropdown",
            name = "Slash command",
            choices = {"/home","/roam"},
            width = "full",
            getFunc = function() return self.slash end,
            setFunc = function(value) self:CommandSettings(value, "home") end,
            },
        [6] = {
            type = "divider",
            width = "full",           
            },
         [7] = {
            type = "dropdown",
            name = " Primary destination",
            width = "half",
            choices = mySavedHomes,
            getFunc = function() return self.primestring end,
            setFunc = function(value) self:SelectHome(value, "primary") end,
            },
         [8] = {
            type = "dropdown",
            name = " Secondary destination",
            --warning = "Only works if primary is set to first "..self.slash,
            width = "half",
            choices = mySavedHomes,
            getFunc = function() return self.secondstring end,
            setFunc = function(value) self:SelectHome(value, "secondary") end,
            },
         [9] = {
            type = "submenu",
            name = "Add homes",
            width = "full",
            controls= { -- START FRIEND SETTINGS --
                [1] = {
                    type = "description",
                    text = " Save homes to the dropdown menus above. This submenu will be later revised.",
                    width = "full",           
                    },
               [2] = {
                    type = "header",
                    name = " "..self.color[2].."Accounts",
                    width = "full",           
                    },
               [3] = {
                    type = "dropdown",
                    name = " Select from friends",
                    sort = "name-up",
                    choices = myFriendsOptions,
                    width = "full",
                    getFunc = function() return end,
                    setFunc = function(value) friendcache=value end,                
                    },
                [4] = {
                    type = "editbox",
                    name = " ... or type @accname",
                    width = "full",
                    getFunc = function() return end,
                    setFunc = function(value) friendcache=value end,
                    },
                [5] = {
                    type = "divider",
                    width = "half",           
                    },
                [6] = {
                    type = "editbox",
                    name = " Nickname (optional)",
                    --disabled=true,
                    width = "full",
                    getFunc = function() return end,
                    setFunc = function(value) friendnamecache=value end,
                    },
                [7] = {
                    type = "button",
                    name = "Save home",
                    warning = "This will reload the UI",
                    width = "full",
                    func = function() self:SaveAccount() end,
                    },
               [8] = {
                    type = "header", -- START PERSONALS --
                    name = " "..self.color[2].."Personals",
                    width = "full",           
                    },
               [9] = {
                    type = "dropdown",
                    name = " Select from homes",
                    sort = "name-up",
                    choices = self.stringlist.homes,
                    width = "full",
                    getFunc = function() return end,
                    setFunc = function(value) homecache=value end,                
                    },
               [10] = {
                    type = "editbox",
                    name = " ... or type home ID",
                    width = "full",
                    getFunc = function() return end,
                    setFunc = function(value) homecache=value end,                
                    },
                [11] = {
                    type = "divider",
                    width = "half",           
                    },
                [12] = {
                    type = "editbox",
                    name = " Nickname (optional)",
                    disabled=true,
                    width = "full",
                    getFunc = function() return end,
                    setFunc = function(value) homenamecache=value end,
                    },
                [13] = {
                    type = "button",
                    name = "Save home",
                    warning = "This will reload the UI",
                    width = "full",
                    func = function() self:SaveAnyone() end,
                    },
                },
         },
         [10] = {
            type = "submenu",
            name = "Edit keybinds",
            width = "full",
            controls= {
                [1] = {
                    type = "description",
                    text = " Set your keybinds home destinations. Save keybinds in control settings.",
                    width = "full",           
                    },
               [2] = {
                    type = "header",
                    name = " "..self.color[2].."Destinations",
                    width = "half",            
                    },
                [3] = {
                    type = "editbox",
                    name = " Keybind 1",
                    tooltip = "@accountname",
                    width = "half",
                    getFunc = function() return self.binds.bind1 end,
                    setFunc = function(value) self:SetKeybind(value, "1") end,
                    },
                [4] = {
                    type = "editbox",
                    name = " Keybind 2",
                    tooltip = "@accountname",
                    width = "half",
                    getFunc = function() return self.binds.bind2 end,
                    setFunc = function(value) self:SetKeybind(value, "2") end,
                    },
                [5] = {
                    type = "editbox",
                    name = " Keybind 3",
                    tooltip = "@accountname",
                    width = "half",
                    getFunc = function() return self.binds.bind3 end,
                    setFunc = function(value) self:SetKeybind(value, "3") end,
                    },
                [6] = {
                    type = "editbox",
                    name = " Keybind 4",
                    tooltip = "@accountname",
                    width = "half",
                    getFunc = function() return self.binds.bind4 end,
                    setFunc = function(value) self:SetKeybind(value, "4") end,
                    },
                [7] = {
                    type = "editbox",
                    name = " Keybind 5",
                    tooltip = "@accountname",
                    width = "half",
                    getFunc = function() return self.binds.bind5 end,
                    setFunc = function(value) self:SetKeybind(value, "5") end,
                    },
            },
        }
    }
    LAM:RegisterOptionControls("RoamHome", optionsData)
	LAM:RegisterAddonPanel("RoamHome", panelData)
end

-- Game hooks --
--SLASH_COMMANDS["/test"]=function(id) d("primary: "..roam.primary.."  secondary: "..roam.secondary) end
SLASH_COMMANDS["/homedebug"]=function(id) roam.debug=not roam.debug roam:Chat("Roam Home debug: "..tostring(roam.debug)) roam.persistentSettings.debug=roam.debug end

SLASH_COMMANDS["/home"]=function(id) roam:PersistentCommand(id, "home") end
SLASH_COMMANDS["/roam"]=function(id) roam:PersistentCommand(id, "roam") end

SLASH_COMMANDS["/test"]=function(id) roam:GetSavedHomes() end

EVENT_MANAGER:RegisterForEvent("RoamHome_OnLoaded",EVENT_ADD_ON_LOADED,function() roam:Initialize() end)