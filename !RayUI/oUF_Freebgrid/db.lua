local R, C, L, DB = unpack(select(2, ...))

local ADDON_NAME, ns = ...
local oUF = RayUF or ns.oUF or oUF

ns.mediapath = "Interface\\AddOns\\!RayUI\\oUF_Freebgrid\\media\\"

ns.defaults = {
    scale = 1.0,
    width = 60,
    height = 22,
    texture = "gradient",
    texturePath = C["media"].normal,
    font = "calibri",
    fontPath = C["media"].font,
    fontsize = 13,
    fontsizeEdge = 10,
    outline = "THINOUTLINE",
    solo = false,
    player = true,
    party = false,
    numCol = 5,
    numUnits = 5,
    petUnits = 5,
    MTUnits = 5,
    spacing = 8,
    orientation = "HORIZONTAL",
    porientation = "HORIZONTAL",
    horizontal = false,
    pethorizontal = false,
    MThorizontal = false,
    growth = "RIGHT",
    petgrowth = "RIGHT",
    MTgrowth = "RIGHT",
    omfChar = false,
    reversecolors = false,
    definecolors = false,
    powerbar = true,
    powerbarsize = .1,
    outsideRange = .40,
    arrow = true,
    arrowmouseover = true,
    healtext = false,
    healbar = true,
    healoverflow = true,
    healothersonly = false,
    healalpha = .40,
    roleicon = false,
    pets = false,
    MT = false,
    indicatorsize = 5,
    symbolsize = 11,
    leadersize = 12,
    aurasize = 18,
    multi = true,
    deficit = false,
    perc = false,
    actual = false,
    myhealcolor = { r = 0.0, g = 1.0, b = 0.5, a = 0.4 },
    otherhealcolor = { r = 0.0, g = 1.0, b = 0.0, a = 0.4 },
    hpcolor = { r = 0.1, g = 0.1, b = 0.1, a = 1 },
    hpbgcolor = { r = 1, g = 1, b = 1, a = .6 },
    PowercolorClass = { r = 1, g = 1, b = 1, a = 1 },
    powerbgcolor = { r = 0.33, g = 0.33, b = 0.33, a = 1 },
    powerdefinecolors = false,
    colorSmooth = false,
    gradient = { r = 1, g = 0, b = 0, a = 1 },
    tborder = true,
    fborder = true,
    afk = true,
    highlight = true,
    dispel = true,
    powerclass = C["ouf"].PowercolorClass,
    tooltip = true,
    smooth = true,
    altpower = false,
    sortName = false,
    sortClass = false,
    classOrder = "DEATHKNIGHT,DRUID,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR",
    hidemenu = false,
}

function ns.InitDB()
    _G[ADDON_NAME.."DB"] = _G[ADDON_NAME.."DB"] or {}
    ns.db = _G[ADDON_NAME.."DB"]

    for k, v in pairs(ns.defaults) do
        if(type(_G[ADDON_NAME.."DB"][k]) == 'nil') then
            _G[ADDON_NAME.."DB"][k] = v
        end
    end
end

function ns.FlushDB()
    for i,v in pairs(ns.defaults) do if ns.db[i] == v and type(ns.db[i]) ~= "table" then ns.db[i] = nil end end
end

