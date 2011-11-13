-----------------------------------------------------
-- Credit Tukz, Elv
-----------------------------------------------------
local R, C, L, DB = unpack(select(2, ...))

R.resolution = GetCVar('gxResolution')
R.screenheight = tonumber(string.match(R.resolution, "%d+x(%d+)"))
R.screenwidth = tonumber(string.match(R.resolution, "(%d+)x+%d"))

local classcolors = {
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
local r, g, b = classcolors[R.myclass].r, classcolors[R.myclass].g, classcolors[R.myclass].b

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
	if (R.myclass == "PALADIN" and tree == 1) or (R.myclass == "SHAMAN" and tree == 3) or (R.myclass == "PRIEST" and (tree == 1 or tree == 2)) or (R.myclass == "DRUID" and tree == 3) then
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

function R.UIScale()
	R.lowversion = false

	if R.screenwidth < 1600 then
			R.lowversion = true
	elseif R.screenwidth >= 3840 or (UIParent:GetWidth() + 1 > R.screenwidth) then
		local width = R.screenwidth
		local height = R.screenheight
	
		-- because some user enable bezel compensation, we need to find the real width of a single monitor.
		-- I don't know how it really work, but i'm assuming they add pixel to width to compensate the bezel. :P

		-- HQ resolution
		if width >= 9840 then width = 3280 end                   	                -- WQSXGA
		if width >= 7680 and width < 9840 then width = 2560 end                     -- WQXGA
		if width >= 5760 and width < 7680 then width = 1920 end 	                -- WUXGA & HDTV
		if width >= 5040 and width < 5760 then width = 1680 end 	                -- WSXGA+

		-- adding height condition here to be sure it work with bezel compensation because WSXGA+ and UXGA/HD+ got approx same width
		if width >= 4800 and width < 5760 and height == 900 then width = 1600 end   -- UXGA & HD+

		-- low resolution screen
		if width >= 4320 and width < 4800 then width = 1440 end 	                -- WSXGA
		if width >= 4080 and width < 4320 then width = 1360 end 	                -- WXGA
		if width >= 3840 and width < 4080 then width = 1224 end 	                -- SXGA & SXGA (UVGA) & WXGA & HDTV
		
		-- yep, now set Elvui to lower reso if screen #1 width < 1600
		if width < 1600 then
			R.lowversion = true
		end
		
		-- register a constant, we will need it later for launch.lua
		R.eyefinity = width
	end

	if R.lowversion == true then
		R.ResScale = 0.9
	else
		R.ResScale = 1
	end
end
R.UIScale()

local mult = 768/string.match(GetCVar("gxResolution"), "%d+x(%d+)")/C["general"].uiscale
local function scale(x)
	return mult*math.floor(x/mult+.5)
end
R.mult = mult
R.Scale = scale

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

local function CreateShadow(f, t, offset, thickness, texture)
	if f.shadow then return end
	
	local borderr, borderg, borderb, bordera = unpack(C["media"].bordercolor)
	local backdropr, backdropg, backdropb, backdropa = unpack(C["media"].backdropcolor)
	
	if t == "Background" then
		backdropa = 0.6
	else
		backdropa = 0
	end
	
	local shadow = CreateFrame("Frame", nil, f)
	if f:GetFrameLevel() - 1 >= 0 then
		shadow:SetFrameLevel(f:GetFrameLevel() - 1)
	else
		shadow:SetFrameLevel(0)
	end
	if offset and type(offset) == "number" then
		offset = scale(offset)
		shadow:Point("TOPLEFT", -3*R.ResScale - offset, 3*R.ResScale + offset)
		shadow:Point("BOTTOMRIGHT", 3*R.ResScale + offset, -3*R.ResScale - offset)
	else
		shadow:Point("TOPLEFT", -3*R.ResScale, 3*R.ResScale)
		shadow:Point("BOTTOMRIGHT", 3*R.ResScale, -3*R.ResScale)
	end
	local thick = 4
	if type(thickness) == "number" then
		thick = thickness
	end
	shadow:SetBackdrop({
	bgFile = texture and C["media"].normal or C["media"].blank, 
	edgeFile = C["media"].glow, 
	edgeSize = scale(thick + 1),
	insets = { left = scale(thick), right = scale(thick), top = scale(thick), bottom = scale(thick) }
	})
	shadow:SetBackdropColor( backdropr, backdropg, backdropb, backdropa )
	shadow:SetBackdropBorderColor( borderr, borderg, borderb, bordera )
	f.shadow = shadow
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

	local hover = b:CreateTexture(nil, "OVERLAY") -- hover
	hover:SetTexture(1,1,1,0.3)
	hover:SetHeight(button:GetHeight())
	hover:SetWidth(button:GetWidth())
	hover:Point("TOPLEFT",button, 2 , -2)
	hover:Point("BOTTOMRIGHT",button, -2, 2)
	button:SetHighlightTexture(hover)

	local pushed = b:CreateTexture(nil, "OVERLAY") -- pushed
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
		local checked = b:CreateTexture(nil, "OVERLAY") -- checked
		checked:SetTexture(23/255,132/255,209/255,0.5)
		checked:SetHeight(button:GetHeight())
		checked:SetWidth(button:GetWidth())
		checked:Point("TOPLEFT",button,2,-2)
		checked:Point("BOTTOMRIGHT",button,-2,2)
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
		f:CreateShadow("Background")
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
	object.Show = function() return end
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
	if f.shadow then
		CreatePulse(f.shadow)
	else
		CreatePulse(f.glow)
	end
end

local function StopGlow(f)
	f:SetBackdropColor(0, 0, 0, 0)
	f:SetBackdropBorderColor(0, 0, 0)
	if f.shadow then
		f.shadow:SetScript("OnUpdate", nil)
		f.shadow:SetAlpha(0)
	else
		f.glow:SetScript("OnUpdate", nil)
		f.glow:SetAlpha(0)
	end
end

local function CreateButton(f, bg, w, h, a1, p, a2, x, y)
	f:SetHeight(h)
	f:SetWidth(w)
	if bg == "Shadow" then
		f:CreateShadow("Background", 1)
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