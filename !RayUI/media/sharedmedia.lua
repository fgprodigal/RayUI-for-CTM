local R, C, DB = unpack(select(2, ...))
local LSM = LibStub("LibSharedMedia-3.0")

if LSM == nil then return end

LSM:Register("statusbar","RayUI Normal", [[Interface\AddOns\!RayUI\media\statusbar.tga]])
LSM:Register("border", "RayUI GlowBorder", [[Interface\AddOns\!RayUI\media\glowTex.tga]])
-- LSM:Register("background","RayUI Blank", [[Interface\AddOns\!RayUI\media\blank.tga]])
LSM:Register("background","RayUI Blank", [[Interface\ChatFrame\ChatFrameBackground.blp]])
LSM:Register("sound","RayUI Warning", [[Interface\AddOns\!RayUI\media\warning.mp3]])

-------------------------------
-- Load Shared Media Settings
-------------------------------
C["media"].font = LSM:Fetch("font", C["media"].font)
C["media"].dmgfont = LSM:Fetch("font", C["media"].dmgfont)
C["media"].normal = LSM:Fetch("statusbar", C["media"].normal)
C["media"].glow = LSM:Fetch("border", C["media"].glow)
C["media"].blank = LSM:Fetch("background", C["media"].blank)
C["media"].warning = LSM:Fetch("sound", C["media"].warning)