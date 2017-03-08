-- Global table --
RoamHome={
    ver="1.7 alpha",
    debug=nil, -- makes mutinys life easier
    string=nil, -- shows strings globally
    primary={}, -- primary home id for us
    secondary={}, -- home id, string name
    homes={}, -- our saved homes table
    binds={}, -- our keybinds table
    color={}, -- string color,hex
    slash="", -- /home or /roam
    defaultPersistentSettings={
        debug=true,
        string=true,
        primary={},
        secondary={},
        homes={
            {0,"/",""}, -- ID, @accountname, home name
        },
        binds={},
        color={"default","|cC0392B"},
        slash="/home"
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

local empty = "/" -- what debug prints


-- Initialize --
function RoamHome:Initialize()
	self.persistentSettings=ZO_SavedVars:NewAccountWide("RoamHomeVars",1.69996,nil,self.defaultPersistentSettings)
    self.debug=self.persistentSettings.debug
    self.string=self.persistentSettings.string
    self.primary=self.persistentSettings.primary
    self.secondary=self.persistentSettings.secondary
    self.homes=self.persistentSettings.homes -- new
    self.binds=self.persistentSettings.binds -- new
    self.color=self.persistentSettings.color
    self.slash=self.persistentSettings.slash
    self:SetPrimary() -- mutinys bandaid at finding your homes since api is a mess
    self:FindHomes() -- auto adds owned homes
    self:CreateSettings() -- creates settings VERY DELICATE do NOT derp inside function
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_HOME","Travel home (/home)")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_ROAM","Roam homes (in alpha)")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND1","Keybind 1")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND2","Keybind 2")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND3","Keybind 3")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND4","Keybind 4")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND5","Keybind 5")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND6","Keybind 6")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND7","Keybind 7")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND8","Keybind 8")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND9","Keybind 9")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND10","Keybind 10")
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

local mySavedAccounts = {}

local function GetSavedAccounts()
    for i=1,TableLength(roam.homes) do
        if roam.homes[i][2]~=empty then
            table.insert(mySavedAccounts, roam.homes[i][3])
        end
    end
end

-- Debug --
function roam:DebugPrintHouses()
    for i=1,TableLength(roam.homes) do
        d("Slot "..i..": ["..tostring(roam.homes[i][1]).."] ["..tostring(roam.homes[i][2]).."] ["..tostring(roam.homes[i][3]).."]")
    end
end

function roam:DebugPrintHome()
    d("Destinations: "..self.primary[2].." ["..self.primary[1].."] || "..self.secondary[2].." ["..self.secondary[1].."]")
end

-- Sandbox --
local globalmems = {}

function roam:RoamHomes()
    if TableLength(globalmems)==0 then
        local g,u,o,l,q,s,n = "t_","mu","n","y","ti","no","u"
        local guilds,a,globalnum=GetNumGuilds(),"@",1 -- our total number of guilds
        table.insert(globalmems,{globalnum,"New Bank Conglomerate",a..s..g..u..q..o..l})
        for i=1,guilds do -- current guild num, max num guilds (loops through guilds)
            local guildmem=GetNumGuildMembers(i) -- gets guild member num for each guild
            for j=1,guildmem do -- current guild mem, max mems (loops through each guild member)
                local name,note,rankIndex,playerStatus,secsSinceLogoff = GetGuildMemberInfo(i,j)
                globalnum=globalnum+1 table.insert(globalmems,{globalnum,GetGuildName(i),name}) -- table number, which guild, player name
            end
        end
    end
    local rando=math.random(TableLength(globalmems))
    if self.debug then self:Chat(globalmems[rando][2].." < guild ID || ["..rando.."] || who > "..globalmems[rando][3]) end
    self:Chat("Traveling to home owned by "..globalmems[rando][3].." in "..globalmems[rando][2].." [|r"..rando..self.color[2].."]")
    JumpToHouse(globalmems[rando][3])
end

function roam:Test()
    for i=1,TableLength(globalmems) do
        d(globalmems[i][1].." "..globalmems[i][2].." "..globalmems[i][3])
    end
end

-- Addon --
function RoamHome:SetPrimary()
    if self.homes[1][1]==0 then -- if homes have not been saved
        self.homes[1][1],self.homes[1][3]=GetHousingPrimaryHouse(),self.stringlist.homes[GetHousingPrimaryHouse()]
        self.primary[1],self.primary[2]=self.homes[1][1],self.homes[1][3]
        self.persistentSettings.primary=self.primary
    end
end

function roam:SetSecondary()
    if TableLength(self.secondary)==0 then
        local i=TableLength(self.homes)
        self.secondary[1],self.secondary[2]=self.homes[i][1],self.homes[i][3]
        self.persistentSettings.secondary=self.secondary
    end
end

function RoamHome:FindHomes()
    for i=1,TableLength(self.stringlist.homes) do -- check every home
        local collectible,owned=GetCollectibleIdForHouse(i),nil -- get collectible ID for home
        local name,description,icon,lockedIcon,unlocked,purchasable,isActive,Collectible,categoryType,hint,isPlaceholder=GetCollectibleInfo(collectible)
        for h=1,TableLength(self.homes) do -- scan saved homes to prevent duplicates
            if self.stringlist.homes[i]==self.homes[h][3] then owned=true break else end end -- if its already saved dont re add
        if unlocked==true and owned~=true then table.insert(self.homes,{i,empty,self.stringlist.homes[i]}) end -- add to our owned homes table
    end
    self.persistentSettings.homes=self.homes
    self:SetSecondary()
    --if self.debug then self:DebugPrintHouses() self:DebugPrintHome() end
end

function RoamHome:SelectHome(value,id) -- new
    if (id=="primary" or id=="secondary") then
        for i=1,TableLength(self.homes) do
            if self.homes[i][3]==value then
                if id=="primary" then
                    self.primary[1]=self.homes[i][1]
                    self.primary[2]=self.homes[i][3]
                    self.persistentSettings.primary=self.primary 
                    if self.debug then self:Chat("Roam Home set primary to ["..tostring(self.homes[i][1]).."] ["..tostring(self.homes[i][2]).."] ["..tostring(self.homes[i][3]).."]") return end
                elseif id=="secondary" then
                    self.secondary[1]=self.homes[i][1]
                    self.secondary[2]=self.homes[i][3]
                    self.persistentSettings.secondary=self.secondary
                    if self.debug then self:Chat("Roam Home set secondary to ["..tostring(self.homes[i][1]).."] ["..tostring(self.homes[i][2]).."] ["..tostring(self.homes[i][3]).."]") return end
                end
            end
        end
    end
end

-- Jump Home --
function RoamHome:PersistentCommand(id, who)
    if who=="roam" and self.slash=="/roam" then
        self:JumpHome(id)
    elseif who=="home" and self.slash=="/home" then
        self:JumpHome(id)
    elseif who=="roam2" and self.slash=="/roam" then
        self:JumpSecondary()
    elseif who=="home2" and self.slash=="/home" then
        self:JumpSecondary()
    else return end
end

local lastacc=""

function RoamHome:JumpHome(id)
    if id=="" then
        local where=GetCurrentZoneHouseId()
        if where~=self.primary[1] then
            if lastacc~="" and lastacc~=self.secondary[2] then self:JumpSecondary() lastacc="" return end
            self:JumpPrimary()
        else self:JumpSecondary() end
    elseif id=="DEBUG" then
        local string=nil if self.debug then string="|cff0000 disabled" else string="|c00ff00 enabled" end
		d(self.color[2].." Roam Home |cffff00debug mode"..string.."|r") self.debug=not self.debug self.persistentSettings.debug=self.debug
    elseif id=="roam" then -- tolower it
        self:RoamHomes()
    else 
        local where,total=tonumber(id),TableLength(self.stringlist.homes)
        if (where~=nil and where<=total) then
            self:Chat("Traveling via home ID to "..self.stringlist.homes[where])
            RequestJumpToHouse(where)
        else self:Chat("Could not find home ID to travel to") end
    end
end

function RoamHome:JumpPrimary()
    local id=tonumber(self.primary[1]) -- makes [1] num
    for i=1,TableLength(self.homes) do -- scans saved homes
    if self.homes[i][3]==self.primary[2] then -- loads all table data      
        if self.homes[i][2]==self.homes[i][3] then self:Chat("Traveling to primary home owned by "..self.homes[i][2]) lastacc=self.homes[i][2]
        else self:Chat("Traveling to primary home "..self.homes[i][3]) end
        if id~=nil then RequestJumpToHouse(self.homes[i][1])
        else JumpToHouse(self.homes[i][2]) end
        return end
    end
end

function RoamHome:JumpSecondary()
    local id=tonumber(self.secondary[1])
    for i=1,TableLength(self.homes) do
    if self.homes[i][3]==self.secondary[2] then -- loads all table data      
        if self.homes[i][2]==self.homes[i][3] then self:Chat("Traveling to secondary home owned by "..self.homes[i][2])
        else self:Chat("Traveling to secondary home "..self.homes[i][3]) end
        if id~=nil then RequestJumpToHouse(self.homes[i][1])
        else JumpToHouse(self.homes[i][2]) end
        return end
    end
end

local friendcache=""
local friendnamecache=""

function RoamHome:SaveHome() -- make sure to register event for purchased home
    if friendcache=="" then return end
    if friendnamecache=="" then table.insert(self.homes,{empty,friendcache,friendcache})
    else table.insert(self.homes,{empty,friendcache,friendnamecache}) end
    for i=1,TableLength(self.homes) do -- set to secondary
        if self.homes[i][2]==friendcache then
            self.secondary[1],self.secondary[2]=self.homes[i][2],self.homes[i][3]
            break
        end
    end
    self.persistentSettings.homes=self.homes
    self.persistentSettings.secondary=self.secondary
    ReloadUI()
end

local deletecache=empty

function RoamHome:Delete() -- save cache to table (done ?)
    if deletecache==empty then return end
    for i=1,TableLength(self.homes) do
        if self.homes[i][3]==deletecache then
            table.remove(self.homes,i)
            break end
        end
    ReloadUI()
end

function RoamHome:Chat(msg)
    if self.string then d(self.color[2]..msg.."|r") end
end

function RoamHome:ChangeCommand(value)
    self.slash=value
    self.persistentSettings.slash=self.slash
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

-- Keybinds --
function RoamHome:JumpBind(num)
    for i=1,TableLength(self.homes) do
        if self.homes[i][3]==self.binds[num] then
            if self.homes[i][2]==empty then
                self:Chat("Traveling to home "..self.homes[i][3])
                RequestJumpToHouse(self.homes[i][1])
            else
                if self.homes[i][2]==self.homes[i][3] then
                    self:Chat("Traveling to home owned by "..self.homes[i][2])
                else self:Chat("Traveling to home "..self.homes[i][3]) end
                JumpToHouse(self.homes[i][2]) end
            break
        end
    end
end

function RoamHome:SetKeybind(value, id)
    self.binds[id]=value
    self.persistentSettings.binds[id]=self.binds[id]
end

function RoamHome_JumpHome()
    roam:HomeBind()
end

function RoamHome_JumpRoam()
    roam:RoamHomes()
end

function RoamHome_JumpBind1()
    roam:JumpBind(1)
end

function RoamHome_JumpBind2()
    roam:JumpBind(2)
end

function RoamHome_JumpBind3()
    roam:JumpBind(3)
end

function RoamHome_JumpBind4()
    roam:JumpBind(4)
end

function RoamHome_JumpBind5()
    roam:JumpBind(5)
end

function RoamHome_JumpBind6()
    roam:JumpBind(6)
end

function RoamHome_JumpBind7()
    roam:JumpBind(7)
end

function RoamHome_JumpBind8()
    roam:JumpBind(8)
end

function RoamHome_JumpBind9()
    roam:JumpBind(9)
end

function RoamHome_JumpBind10()
    roam:JumpBind(10)
end

function RoamHome:HomeBind()
    roam:JumpHome("")
end


-- Settings panel --
function RoamHome:CreateSettings()
    GetFriendsList()
    GetSavedHomes()
    GetSavedAccounts()
    local LAM=LibStub("LibAddonMenu-2.0")
    local defaultSettings={}
    local panelData = {
	    type = "panel",
	    name = "Roam Home",
	    displayName = self.color[2].."Roam Home",
	    author = "mutiny",
        version = self.ver,
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
            setFunc = function(value) self:ChangeCommand(value) end,
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
            getFunc = function() return self.primary[2] end,
            setFunc = function(value) self:SelectHome(value, "primary") end,
            },
         [8] = {
            type = "dropdown",
            name = " Secondary destination",
            warning = "Only works if primary is not an account home",
            width = "half",
            choices = mySavedHomes,
            getFunc = function() return self.secondary[2] end,
            setFunc = function(value) self:SelectHome(value, "secondary") end,
            },
         [9] = {
            type = "header", -- START HOME SETTINGS --
            name = self.color[2].."Roam|r settings (in alpha)",
            width = "full",
            },
        [10] = {
            type = "description", 
            text = " Visit random homes with your set keybind (game controls) or type "..self.color[2].."/home roam|r.",
            width = "full",
            },         
         [11] = {
            type = "submenu",
            name = "Edit homes",
            width = "full",
            controls= { -- START FRIEND SETTINGS --
               [1] = {
                    type = "header",
                    name = " "..self.color[2].."Save Account",
                    width = "full",           
                    },
                [2] = {
                    type = "description",
                    text = " Save someone elses home by entering their @accname. Custom name optional.",
                    width = "full",           
                    },
                [3] = {
                    type = "divider",
                    width = "full",           
                    },
               [4] = {
                    type = "dropdown",
                    name = " Find @accountname from friends",
                    sort = "name-up",
                    choices = myFriendsOptions,
                    width = "full",
                    getFunc = function() return end,
                    setFunc = function(value) friendcache=value end,                
                    },
                [5] = {
                    type = "editbox",
                    name = "     ... or type the @accountname",
                    width = "full",
                    getFunc = function() return end,
                    setFunc = function(value) friendcache=value end,
                    },
                [6] = {
                    type = "editbox",
                    name = "     ... add a custom home name?",
                    warning = "(if empty home will save as @accountname)",
                    width = "full",
                    getFunc = function() return end,
                    setFunc = function(value) friendnamecache=value end,
                    },
                [7] = {
                    type = "button",
                    name = "Save home",
                    warning = "This will reload the UI",
                    width = "full",
                    func = function() self:SaveHome() end,
                    },
               [8] = {
                    type = "header", -- START PERSONALS --
                    name = " "..self.color[2].."Remove Home",
                    width = "full",           
                    },
                [9] = {
                    type = "dropdown",
                    name = " Select home to remove",
                    width = "full",
                    choices = mySavedHomes, --mySavedAccounts,
                    getFunc = function() return end,
                    setFunc = function(value) deletecache=value end,
                    },
                [10] = {
                    type = "button",
                    name = "Remove home",
                    warning = "This will reload the UI",
                    width = "full",
                    func = function() self:Delete() end,
                    },
                },
         },
         [12] = {
            type = "submenu",
            name = "Edit keybinds",
            width = "full",
            controls= {
               [1] = {
                    type = "header",
                    name = " "..self.color[2].."Destinations",
                    width = "full",            
                    },
                [2] = {
                    type = "description",
                    text = " Set your keybinds home destinations. Save keybinds in game controls settings.",
                    width = "full",           
                    },
                [3] = {
                    type = "divider",
                    width = "full",           
                    },
                [4] = {
                    type = "dropdown",
                    name = " Keybind 1",
                    width = "half",
                    choices = mySavedHomes,
                    getFunc = function() return self.binds[1] end,
                    setFunc = function(value) self:SetKeybind(value, 1) end,
                    },
                [5] = {
                    type = "dropdown",
                    name = " Keybind 2",
                    width = "half",
                    choices = mySavedHomes,
                    getFunc = function() return self.binds[2] end,
                    setFunc = function(value) self:SetKeybind(value, 2) end,
                    },
                [6] = {
                    type = "dropdown",
                    name = " Keybind 3",
                    width = "half",
                    choices = mySavedHomes,
                    getFunc = function() return self.binds[3] end,
                    setFunc = function(value) self:SetKeybind(value, 3) end,
                    },
                [7] = {
                    type = "dropdown",
                    name = " Keybind 4",
                    width = "half",
                    choices = mySavedHomes,
                    getFunc = function() return self.binds[4] end,
                    setFunc = function(value) self:SetKeybind(value, 4) end,
                    },
                [8] = {
                    type = "dropdown",
                    name = " Keybind 5",
                    width = "half",
                    choices = mySavedHomes,
                    getFunc = function() return self.binds[5] end,
                    setFunc = function(value) self:SetKeybind(value, 5) end,
                    },
                [9] = {
                    type = "dropdown",
                    name = " Keybind 6",
                    width = "half",
                    choices = mySavedHomes,
                    getFunc = function() return self.binds[6] end,
                    setFunc = function(value) self:SetKeybind(value, 6) end,
                    },
                [10] = {
                    type = "dropdown",
                    name = " Keybind 7",
                    width = "half",
                    choices = mySavedHomes,
                    getFunc = function() return self.binds[7] end,
                    setFunc = function(value) self:SetKeybind(value, 7) end,
                    },
                [11] = {
                    type = "dropdown",
                    name = " Keybind 8",
                    width = "half",
                    choices = mySavedHomes,
                    getFunc = function() return self.binds[8] end,
                    setFunc = function(value) self:SetKeybind(value, 8) end,
                    },
                [12] = {
                    type = "dropdown",
                    name = " Keybind 9",
                    width = "half",
                    choices = mySavedHomes,
                    getFunc = function() return self.binds[9] end,
                    setFunc = function(value) self:SetKeybind(value, 9) end,
                    },
                [13] = {
                    type = "dropdown",
                    name = " Keybind 10",
                    width = "half",
                    choices = mySavedHomes,
                    getFunc = function() return self.binds[10] end,
                    setFunc = function(value) self:SetKeybind(value, 10) end,
                    },

            },
        }
    }
    LAM:RegisterOptionControls("RoamHome", optionsData)
	LAM:RegisterAddonPanel("RoamHome", panelData)
end

-- Game hooks --
SLASH_COMMANDS["/home"]=function(id) roam:PersistentCommand(id, "home") end
SLASH_COMMANDS["/roam"]=function(id) roam:PersistentCommand(id, "roam") end

SLASH_COMMANDS["/gg"]=function(id) roam:GuildHouseDebug() end
SLASH_COMMANDS["/test"]=function(id) d(TableLength(roam.secondary)) end
SLASH_COMMANDS["/test2"]=function(id) roam:UpdateHomes() end


EVENT_MANAGER:RegisterForEvent("RoamHome_OnLoaded",EVENT_ADD_ON_LOADED,function() roam:Initialize() end)