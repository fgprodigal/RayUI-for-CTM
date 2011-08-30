-----------------------------------------------------
-- Credit Tukz, Elv
-----------------------------------------------------
local R, C, DB = unpack(select(2, ...))

_, R.myclass = UnitClass("player")
R.level = UnitLevel("player")
R.myname = UnitName("player")
R.myrealm = GetRealmName()
R.version = GetAddOnMetadata("!RayUI", "Version")
local noop = function() return end
R.dummy = noop
R.colors = {
	tapped = {0.55, 0.57, 0.61},
	disconnected = {0.84, 0.75, 0.65},
	power = {
		["MANA"] = {0.31, 0.45, 0.63},
		["RAGE"] = {0.78, 0.25, 0.25},
		["FOCUS"] = {0.71, 0.43, 0.27},
		["ENERGY"] = {0.65, 0.63, 0.35},
		["RUNES"] = {0.55, 0.57, 0.61},
		["RUNIC_POWER"] = {0, 0.82, 1},
		["AMMOSLOT"] = {0.8, 0.6, 0},
		["FUEL"] = {0, 0.55, 0.5},
		["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61},
		["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17},
	},
	happiness = {
		[1] = {.69,.31,.31},
		[2] = {.65,.63,.35},
		[3] = {.33,.59,.33},
	},
	runes = {
			[1] = {.69,.31,.31},
			[2] = {.33,.59,.33},
			[3] = {.31,.45,.63},
			[4] = {.84,.75,.65},
	},
	reaction = {
		[1] = { 0.78, 0.25, 0.25 }, -- Hated
		[2] = { 0.78, 0.25, 0.25 }, -- Hostile
		[3] = { 0.78, 0.25, 0.25 }, -- Unfriendly
		[4] = { 218/255, 197/255, 92/255 }, -- Neutral
		[5] = { 75/255,  175/255, 76/255 }, -- Friendly
		[6] = { 75/255,  175/255, 76/255 }, -- Honored
		[7] = { 75/255,  175/255, 76/255 }, -- Revered
		[8] = { 75/255,  175/255, 76/255 }, -- Exalted	
	},
	class = {
		["DEATHKNIGHT"] = { 196/255,  30/255,  60/255 },
		["DRUID"]       = { 255/255, 125/255,  10/255 },
		["HUNTER"]      = { 171/255, 214/255, 116/255 },
		["MAGE"]        = { 104/255, 205/255, 255/255 },
		["PALADIN"]     = { 245/255, 140/255, 186/255 },
		["PRIEST"]      = { 212/255, 212/255, 212/255 },
		["ROGUE"]       = { 255/255, 243/255,  82/255 },
		["SHAMAN"]      = {  41/255,  79/255, 155/255 },
		["WARLOCK"]     = { 148/255, 130/255, 201/255 },
		["WARRIOR"]     = { 199/255, 156/255, 110/255 },
	},
}
local classcolours = {
	["HUNTER"] = { r = 0.58, g = 0.86, b = 0.49 },
	["WARLOCK"] = { r = 0.6, g = 0.47, b = 0.85 },
	["PALADIN"] = { r = 1, g = 0.22, b = 0.52 },
	["PRIEST"] = { r = 0.8, g = 0.87, b = .9 },
	["MAGE"] = { r = 0, g = 0.76, b = 1 },
	["ROGUE"] = { r = 1, g = 0.91, b = 0.2 },
	["DRUID"] = { r = 1, g = 0.49, b = 0.04 },
	["SHAMAN"] = { r = 0, g = 0.6, b = 0.6 };
	["WARRIOR"] = { r = 0.9, g = 0.65, b = 0.45 },
	["DEATHKNIGHT"] = { r = 0.77, g = 0.12 , b = 0.23 },
}
local r, g, b = classcolours[R.myclass].r, classcolours[R.myclass].g, classcolours[R.myclass].b

RoleUpdater = CreateFrame("Frame")
local function CheckRole(self, event, unit)
	local tree = GetPrimaryTalentTree()
	local resilience
	local resilperc = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
	if resilperc > GetDodgeChance() and resilperc > GetParryChance() then
		resilience = true
	else
		resilience = false
	end
	if ((R.myclass == "PALADIN" and tree == 1) or 
	(R.myclass == "SHAMAN" and tree == 3) or 
	(R.myclass == "PRIEST" and (tree == 1 or tree == 2))) and
	resilience == false or
	(R.myclass == "DRUID" and tree == 3) then
		R.isHealer = true
	else
		R.isHealer = false
	end
	if ((R.myclass == "PALADIN" and tree == 2) or 
	(R.myclass == "WARRIOR" and tree == 3) or 
	(R.myclass == "DEATHKNIGHT" and tree == 1)) and
	resilience == false or
	(R.myclass == "DRUID" and tree == 2 and GetBonusBarOffset() == 3) then
		R.Role = "Tank"
	else
		local playerint = select(2, UnitStat("player", 4))
		local playeragi	= select(2, UnitStat("player", 2))
		local base, posBuff, negBuff = UnitAttackPower("player");
		local playerap = base + posBuff + negBuff;

		if (((playerap > playerint) or (playeragi > playerint)) and not (R.myclass == "SHAMAN" and tree ~= 1 and tree ~= 3) and not (UnitBuff("player", GetSpellInfo(24858)) or UnitBuff("player", GetSpellInfo(65139)))) or R.myclass == "ROGUE" or R.myclass == "HUNTER" or (R.myclass == "SHAMAN" and tree == 2) then
			R.Role = "Melee"
		else
			R.Role = "Caster"
		end
	end
end	
RoleUpdater:RegisterEvent("PLAYER_ENTERING_WORLD")
RoleUpdater:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
RoleUpdater:RegisterEvent("PLAYER_TALENT_UPDATE")
RoleUpdater:RegisterEvent("CHARACTER_POINTS_CHANGED")
RoleUpdater:RegisterEvent("UNIT_INVENTORY_CHANGED")
RoleUpdater:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
RoleUpdater:SetScript("OnEvent", CheckRole)
CheckRole()

local mult = 768/string.match(GetCVar("gxResolution"), "%d+x(%d+)")/C["general"].uiscale
local function scale(x)
	return mult*math.floor(x/mult+.5)
end
R.mult = mult
R.Scale = scale

local waitTable = {}
local waitFrame
function R.Delay(delay, func, ...)
	if(type(delay)~="number" or type(func)~="function") then
		return false
	end
	if(waitFrame == nil) then
		waitFrame = CreateFrame("Frame","WaitFrame", UIParent)
		waitFrame:SetScript("onUpdate",function (self,elapse)
			local count = #waitTable
			local i = 1
			while(i<=count) do
				local waitRecord = tremove(waitTable,i)
				local d = tremove(waitRecord,1)
				local f = tremove(waitRecord,1)
				local p = tremove(waitRecord,1)
				if(d>elapse) then
				  tinsert(waitTable,i,{d-elapse,f,p})
				  i = i + 1
				else
				  count = count - 1
				  f(unpack(p))
				end
			end
		end)
	end
	tinsert(waitTable,{delay,func,{...}})
	return true
end

function R.RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

function R.ShortValue(v)
	if v >= 1e6 then
		return ("%.1fm"):format(v / 1e6):gsub("%.?0+([km])$", "%1")
	elseif v >= 1e3 or v <= -1e3 then
		return ("%.1fk"):format(v / 1e3):gsub("%.?0+([km])$", "%1")
	else
		return v
	end
end

local function Size(frame, width, height)
	frame:SetSize(scale(width), scale(height or width))
end

local function Width(frame, width)
	frame:SetWidth(scale(width))
end

local function Height(frame, height)
	frame:SetHeight(scale(height))
end

local function Point(obj, arg1, arg2, arg3, arg4, arg5)
	-- anyone has a more elegant way for this?
	if type(arg1)=="number" then arg1 = scale(arg1) end
	if type(arg2)=="number" then arg2 = scale(arg2) end
	if type(arg3)=="number" then arg3 = scale(arg3) end
	if type(arg4)=="number" then arg4 = scale(arg4) end
	if type(arg5)=="number" then arg5 = scale(arg5) end

	obj:SetPoint(arg1, arg2, arg3, arg4, arg5)
end

local function CreateShadow(f, t)
	if f.shadow then return end
	
	local borderr, borderg, borderb, bordera = unpack(C["media"].bordercolor)
	local backdropr, backdropg, backdropb, backdropa = unpack(C["media"].backdropcolor)
	
	if t == "Background" then
		backdropa = 0.6
	else
		backdropa = 0
	end
	
	local shadow = CreateFrame("Frame", nil, f)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:Point("TOPLEFT", -2, 2)
	shadow:Point("BOTTOMRIGHT", 2, -2)
	shadow:Point("TOPRIGHT", 2, 2)
	shadow:Point("BOTTOMRIGHT", 2, -2)
	shadow:SetBackdrop({
	bgFile = C["media"].blank, 
	edgeFile = C["media"].glow, 
	edgeSize = scale(5),
	insets = { left = scale(4), right = scale(4), top = scale(4), bottom = scale(4) }
	})
	shadow:SetBackdropColor( backdropr, backdropg, backdropb, backdropa )
	shadow:SetBackdropBorderColor( borderr, borderg, borderb, bordera )
	f.shadow = shadow
	f.glow = shadow
end

local function SetTemplate(f, t, texture)
	f:SetBackdrop({
	  bgFile = C["media"].normal,
	})
	if t == "Transparent" then 
		f:SetBackdropColor(C["media"]["backdropcolor"][1], C["media"]["backdropcolor"][2], C["media"]["backdropcolor"][3], 0.6)
	else
		f:SetBackdropColor(unpack(C["media"].backdropcolor))
	end
	f:SetBackdropBorderColor(unpack(C["media"].bordercolor))
end

local function CreateBorder(f, r, g, b, a)
	f:SetBackdrop({
		edgeFile = C["media"].blank, 
		edgeSize = mult,
		insets = { left = -mult, right = -mult, top = -mult, bottom = -mult }
	})
	f:SetBackdropBorderColor(r or C["media"]["bordercolor"][1], g or C["media"]["bordercolor"][2], b or C["media"]["bordercolor"][3], a or C["media"]["bordercolor"][4])
end

local function StyleButton(b, c) 
	local name = b:GetName()

	local button          = _G[name]
	local icon            = _G[name.."Icon"]
	local count           = _G[name.."Count"]
	local border          = _G[name.."Border"]
	local hotkey          = _G[name.."HotKey"]
	local cooldown        = _G[name.."Cooldown"]
	local nametext        = _G[name.."Name"]
	local flash           = _G[name.."Flash"]
	local normaltexture   = _G[name.."NormalTexture"]
	local icontexture     = _G[name.."IconTexture"]

	local hover = b:CreateTexture("frame", nil, self) -- hover
	hover:SetTexture(1,1,1,0.3)
	hover:SetHeight(button:GetHeight())
	hover:SetWidth(button:GetWidth())
	hover:Point("TOPLEFT",button, 2 , -2)
	hover:Point("BOTTOMRIGHT",button, -2, 2)
	button:SetHighlightTexture(hover)

	local pushed = b:CreateTexture("frame", nil, self) -- pushed
	pushed:SetTexture(0.9,0.8,0.1,0.3)
	pushed:SetHeight(button:GetHeight())
	pushed:SetWidth(button:GetWidth())
	pushed:Point("TOPLEFT",button,2,-2)
	pushed:Point("BOTTOMRIGHT",button,-2,2)
	button:SetPushedTexture(pushed)

	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:Point("TOPLEFT",button,2,-2)
		cooldown:Point("BOTTOMRIGHT",button,-2,2)
	end

	if c then
		local checked = b:CreateTexture("frame", nil, self) -- checked
		checked:SetTexture(23/255,132/255,209/255,0.3)
		checked:SetHeight(button:GetHeight())
		checked:SetWidth(button:GetWidth())
		checked:Point("TOPLEFT",button,2,-2)
		checked:Point("BOTTOMRIGHT",button,-2,2)
		checked:SetAlpha(0.3)
		button:SetCheckedTexture(checked)
	end
end

local function CreatePanel(f, t, w, h, a1, p, a2, x, y)
	local sh = scale(h)
	local sw = scale(w)
	f:SetFrameLevel(1)
	f:SetHeight(sh)
	f:SetWidth(sw)
	f:SetFrameStrata("BACKGROUND")
	f:SetPoint(a1, p, a2, scale(x), scale(y))
	if t ~= "Transparent" then
		f:CreateShadow(t,"Background")
	else
		f:CreateShadow(t)
	end
end

local function Kill(object)
	if object.IsProtected then 
		if object:IsProtected() then
			error("Attempted to kill a protected object: <"..object:GetName()..">")
		end
	end
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	object.Show = noop
	object:Hide()
end

local function FadeIn(f)
	UIFrameFadeIn(f, .4, f:GetAlpha(), 1)
end
	
local function FadeOut(f)
	UIFrameFadeOut(f, .4, f:GetAlpha(), 0)
end

local function StripTextures(object, kill)
	for i=1, object:GetNumRegions() do
		local region = select(i, object:GetRegions())
		if region:GetObjectType() == "Texture" then
			if kill then
				region:Kill()
			else
				region:SetTexture(nil)
			end
		end
	end		
end

local function CreatePulse(frame, speed, mult, alpha)
	frame.speed = speed or .05
	frame.mult = mult or 1
	frame.alpha = alpha or 1
	frame.tslu = 0
	frame:SetScript("OnUpdate", function(self, elapsed)
		self.tslu = self.tslu + elapsed
		if self.tslu > self.speed then
			self.tslu = 0
			self:SetAlpha(self.alpha)
		end
		self.alpha = self.alpha - elapsed*self.mult
		if self.alpha < 0 and self.mult > 0 then
			self.mult = self.mult*-1
			self.alpha = 0
		elseif self.alpha > 1 and self.mult < 0 then
			self.mult = self.mult*-1
		end
	end)
end

local function StartGlow(f)
	f:SetBackdropColor(r, g, b, .1)
	f:SetBackdropBorderColor(r, g, b)
	CreatePulse(f.glow)
end

local function StopGlow(f)
	f:SetBackdropColor(0, 0, 0, 0)
	f:SetBackdropBorderColor(0, 0, 0)
	f.glow:SetScript("OnUpdate", nil)
	f.glow:SetAlpha(0)
end

local function CreateButton(f, bg, w, h, a1, p, a2, x, y)
	f:SetHeight(h)
	f:SetWidth(w)
	if bg == "Shadow" then
		f.bg = CreateFrame("Frame",nil,f)
		f.bg:Point("TOPLEFT", -1, 1)
		f.bg:Point("BOTTOMRIGHT", 1, -1)
		f.bg:CreateShadow("Background")
		f.bg:SetFrameLevel(0)
	end
	f:SetPoint(a1, p, a2, scale(x), scale(y))
	R.Reskin(f)
end

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.Size then mt.Size = Size end
	if not object.Point then mt.Point = Point end
	if not object.SetTemplate then mt.SetTemplate = SetTemplate end
	if not object.CreatePanel then mt.CreatePanel = CreatePanel end
	if not object.CreateShadow then mt.CreateShadow = CreateShadow end
	if not object.Kill then mt.Kill = Kill end
	if not object.StyleButton then mt.StyleButton = StyleButton end
	if not object.Width then mt.Width = Width end
	if not object.Height then mt.Height = Height end
	if not object.FadeIn then mt.FadeIn = FadeIn end
	if not object.FadeOut then mt.FadeOut = FadeOut end
	if not object.CreateBorder then mt.CreateBorder = CreateBorder end
	if not object.StripTextures then mt.StripTextures = StripTextures end
	if not object.CreateButton then mt.CreateButton = CreateButton end
	if not object.StartGlow then mt.StartGlow = StartGlow end
	if not object.StopGlow then mt.StopGlow = StopGlow end
end
local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())
object = EnumerateFrames()
while object do
	if not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end

local RayUIOnLogon = CreateFrame("Frame")
RayUIOnLogon:RegisterEvent("PLAYER_ENTERING_WORLD")
RayUIOnLogon:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	Advanced_UIScaleSlider:Kill()
	Advanced_UseUIScale:Kill()
	SetCVar("useUiScale", 1)
	SetCVar("uiScale", C["general"].uiscale)
end)