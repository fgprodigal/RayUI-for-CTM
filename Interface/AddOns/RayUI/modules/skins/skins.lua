local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local S = R:NewModule("Skins", "AceEvent-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
S.modName = L["插件美化"]

S.SkinFuncs = {}
S.SkinFuncs["RayUI"] = {}

local alpha = .65 -- controls the backdrop opacity (0 = invisible, 1 = solid)

S["media"] = {
	["checked"] = "Interface\\AddOns\\RayUI\\media\\CheckButtonHilight",
	["classcolours"] = {
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
}

S["media"].DefGradient = {"VERTICAL", 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2}

local r, g, b = S["media"].classcolours[R.myclass].r, S["media"].classcolours[R.myclass].g, S["media"].classcolours[R.myclass].b

function S:GetOptions()
	local options = {
		skadagroup = {
			order = 5,
			type = "group",
			name = L["Skada"],
			guiInline = true,
			args = {
				skada = {
					order = 1,
					name = L["启用"],
					type = "toggle",
				},
				skadaposition = {
					order = 2,
					name = L["固定Skada位置"],
					type = "toggle",
					disabled = function() return not S.db.skada end,
				},
			},
		},
		dbmgroup = {
			order = 6,
			type = "group",
			name = L["DBM"],
			guiInline = true,
			args = {
				dbm = {
					order = 1,
					name = L["启用"],
					type = "toggle",
				},
				dbmposition = {
					order = 2,
					name = L["固定DBM位置"],
					type = "toggle",
					disabled = function() return not S.db.dbm end,
				},
			},
		},
		ace3group = {
			order = 7,
			type = "group",
			name = L["ACE3控制台"],
			guiInline = true,
			args = {
				ace3 = {
					order = 1,
					name = L["启用"],
					type = "toggle",
				},
			},
		},
		acpgroup = {
			order = 8,
			type = "group",
			name = L["ACP"],
			guiInline = true,
			args = {
				acp = {
					order = 1,
					name = L["启用"],
					type = "toggle",
				},
			},
		},
		atlaslootgroup = {
			order = 9,
			type = "group",
			name = L["Atlasloot"],
			guiInline = true,
			args = {
				atlasloot = {
					order = 1,
					name = L["启用"],
					type = "toggle",
				},
			},
		},
		bigwigsgroup = {
			order = 10,
			type = "group",
			name = L["BigWigs"],
			guiInline = true,
			args = {
				bigwigs = {
					order = 1,
					name = L["启用"],
					type = "toggle",
				},
			},
		},
	}
	return options
end

function S:CreateBD(f, a)
	if not f then return end
	f:SetBackdrop({
		bgFile = S["media"].backdrop, 
		edgeFile = S["media"].backdrop, 
		edgeSize = R.mult, 
	})
	f:SetBackdropColor(0, 0, 0, a or alpha)
	f:SetBackdropBorderColor(0, 0, 0)
end

function S:CreateBG(frame)
	if not frame then return end
	local f = frame
	if frame:GetObjectType() == "Texture" then f = frame:GetParent() end

	local bg = f:CreateTexture(nil, "BACKGROUND")
	bg:Point("TOPLEFT", frame, -1, 1)
	bg:Point("BOTTOMRIGHT", frame, 1, -1)
	bg:SetTexture(S["media"].backdrop)
	bg:SetVertexColor(0, 0, 0)
	
	return bg
end

function S:CreateSD(parent, size, r, g, b, alpha, offset)
	if not parent then return end
	local sd = CreateFrame("Frame", nil, parent)
	sd.size = size or 5
	sd.size = sd.size - 5
	sd.offset = offset or 0
	sd:Point("TOPLEFT", parent, -sd.size - 1 - sd.offset, sd.size + 1 + sd.offset)
	sd:Point("BOTTOMRIGHT", parent, sd.size + 1 + sd.offset, -sd.size - 1 - sd.offset)
	sd:CreateShadow()
	sd.shadow:SetBackdropBorderColor(r or 0, g or 0, b or 0)
	sd.border:SetBackdropBorderColor(r or 0, g or 0, b or 0)
	sd:SetAlpha(alpha or 1)
end

function S:CreatePulse(frame, speed, mult, alpha)
	if not frame then return end
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
	if not f then return end
	f:SetBackdropColor(r, g, b, .1)
	f:SetBackdropBorderColor(r, g, b)
	S:CreatePulse(f.glow)
end

local function StopGlow(f)
	if not f then return end
	f:SetBackdropColor(0, 0, 0, 0)
	f:SetBackdropBorderColor(0, 0, 0)
	f.glow:SetScript("OnUpdate", nil)
	f.glow:SetAlpha(0)
end

function S:Reskin(f, noGlow)
	if not f then return end
	f:SetNormalTexture("")
	f:SetHighlightTexture("")
	f:SetPushedTexture("")
	f:SetDisabledTexture("")

	local name = f:GetName()

	if name then
		local left = _G[name.."Left"]
		local middle = _G[name.."Middle"]
		local right = _G[name.."Right"]

		if left then left:SetAlpha(0) end
		if middle then middle:SetAlpha(0) end
		if right then right:SetAlpha(0) end
	end

	S:CreateBD(f, .0)

	local tex = f:CreateTexture(nil, "BACKGROUND")
	tex:SetPoint("TOPLEFT")
	tex:SetPoint("BOTTOMRIGHT")
	tex:SetTexture(S["media"].backdrop)
	tex:SetGradientAlpha(unpack(S["media"].DefGradient))

	if not noGlow then
		f.glow = CreateFrame("Frame", nil, f)
		f.glow:SetBackdrop({
			edgeFile = R["media"].glow,
			edgeSize = R:Scale(5),
		})
		f.glow:Point("TOPLEFT", -6, 6)
		f.glow:Point("BOTTOMRIGHT", 6, -6)
		f.glow:SetBackdropBorderColor(r, g, b)
		f.glow:SetAlpha(0)

		f:HookScript("OnEnter", StartGlow)
		f:HookScript("OnLeave", StopGlow)
	end
end

function S:CreateTab(f)
	if not f then return end
	f:DisableDrawLayer("BACKGROUND")

	local bg = CreateFrame("Frame", nil, f)
	bg:Point("TOPLEFT", 9, -3)
	bg:Point("BOTTOMRIGHT", -9, 0)
	bg:SetFrameLevel(f:GetFrameLevel()-1)
	S:CreateBD(bg)

	f:SetHighlightTexture(S["media"].backdrop)
	local hl = f:GetHighlightTexture()
	hl:Point("TOPLEFT", 10, -4)
	hl:Point("BOTTOMRIGHT", -10, 1)
	hl:SetVertexColor(r, g, b, .25)
end

function S:ReskinScroll(f)
	if not f then return end
	local frame = f:GetName()

	if _G[frame.."Track"] then _G[frame.."Track"]:Hide() end
	if _G[frame.."BG"] then _G[frame.."BG"]:Hide() end
	if _G[frame.."Top"] then _G[frame.."Top"]:Hide() end
	if _G[frame.."Middle"] then _G[frame.."Middle"]:Hide() end
	if _G[frame.."Bottom"] then _G[frame.."Bottom"]:Hide() end

	local bu = _G[frame.."ThumbTexture"]
	bu:SetAlpha(0)
	bu:Width(17)

	bu.bg = CreateFrame("Frame", nil, f)
	bu.bg:Point("TOPLEFT", bu, 0, -2)
	bu.bg:Point("BOTTOMRIGHT", bu, 0, 4)
	S:CreateBD(bu.bg, 0)

	local tex = f:CreateTexture(nil, "BACKGROUND")
	tex:Point("TOPLEFT", bu.bg)
	tex:Point("BOTTOMRIGHT", bu.bg)
	tex:SetTexture(S["media"].backdrop)
	tex:SetGradientAlpha(unpack(S["media"].DefGradient))

	local up = _G[frame.."ScrollUpButton"]
	local down = _G[frame.."ScrollDownButton"]

	up:Width(17)
	down:Width(17)
	
	S:Reskin(up)
	S:Reskin(down)
	
	up:SetDisabledTexture(S["media"].backdrop)
	local dis1 = up:GetDisabledTexture()
	dis1:SetVertexColor(0, 0, 0, .3)
	dis1:SetDrawLayer("OVERLAY")
	
	down:SetDisabledTexture(S["media"].backdrop)
	local dis2 = down:GetDisabledTexture()
	dis2:SetVertexColor(0, 0, 0, .3)
	dis2:SetDrawLayer("OVERLAY")

	local uptex = up:CreateTexture(nil, "ARTWORK")
	uptex:SetTexture("Interface\\AddOns\\RayUI\\media\\arrow-up-active")
	uptex:Size(8, 8)
	uptex:SetPoint("CENTER")
	uptex:SetVertexColor(1, 1, 1)

	local downtex = down:CreateTexture(nil, "ARTWORK")
	downtex:SetTexture("Interface\\AddOns\\RayUI\\media\\arrow-down-active")
	downtex:Size(8, 8)
	downtex:SetPoint("CENTER")
	downtex:SetVertexColor(1, 1, 1)
end

function S:ReskinDropDown(f)
	if not f then return end
	local frame = f:GetName()

	local left = _G[frame.."Left"]
	local middle = _G[frame.."Middle"]
	local right = _G[frame.."Right"]

	if left then left:SetAlpha(0) end
	if middle then middle:SetAlpha(0) end
	if right then right:SetAlpha(0) end

	local down = _G[frame.."Button"]

	down:ClearAllPoints()
	down:Point("TOPRIGHT", -18, -4)
	down:Point("BOTTOMRIGHT", -18, 8)
	down:SetWidth(19)

	S:Reskin(down)
	
	down:SetDisabledTexture(S["media"].backdrop)
	local dis = down:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .3)
	dis:SetDrawLayer("OVERLAY")
	dis:SetAllPoints(down)

	local downtex = down:CreateTexture(nil, "ARTWORK")
	downtex:SetTexture("Interface\\AddOns\\RayUI\\media\\arrow-down-active")
	downtex:SetSize(8, 8)
	downtex:SetPoint("CENTER")
	downtex:SetVertexColor(1, 1, 1)

	local bg = CreateFrame("Frame", nil, f)
	bg:Point("TOPLEFT", 16, -4)
	bg:Point("BOTTOMRIGHT", -18, 8)
	bg:SetFrameLevel(f:GetFrameLevel()-1)
	S:CreateBD(bg, 0)

	local tex = bg:CreateTexture(nil, "BACKGROUND")
	tex:SetPoint("TOPLEFT")
	tex:SetPoint("BOTTOMRIGHT")
	tex:SetTexture(S["media"].backdrop)
	tex:SetGradientAlpha(unpack(S["media"].DefGradient))
end

function S:ReskinClose(f, a1, p, a2, x, y)
	if not f then return end
	f:Size(17, 17)

	if not a1 then
		f:Point("TOPRIGHT", -4, -4)
	else
		f:ClearAllPoints()
		f:Point(a1, p, a2, x, y)
	end

	f:SetNormalTexture("")
	f:SetHighlightTexture("")
	f:SetPushedTexture("")
	f:SetDisabledTexture("")

	S:CreateBD(f, 0)

	local tex = f:CreateTexture(nil, "BACKGROUND")
	tex:SetPoint("TOPLEFT")
	tex:SetPoint("BOTTOMRIGHT")
	tex:SetTexture(S["media"].backdrop)
	tex:SetGradientAlpha(unpack(S["media"].DefGradient))

	local text = f:CreateFontString(nil, "OVERLAY")
	text:SetFont(R["media"].pxfont, R.mult*10, "OUTLINE,MONOCHROME")
	text:Point("CENTER", 2, 1)
	text:SetText("x")

	f:HookScript("OnEnter", function(self) text:SetTextColor(1, .1, .1) end)
 	f:HookScript("OnLeave", function(self) text:SetTextColor(1, 1, 1) end)
end

function S:ReskinInput(f, height, width)
	if not f then return end
	local frame = f:GetName()
	_G[frame.."Left"]:Hide()
	if _G[frame.."Middle"] then _G[frame.."Middle"]:Hide() end
	if _G[frame.."Mid"] then _G[frame.."Mid"]:Hide() end
	_G[frame.."Right"]:Hide()
	S:CreateBD(f, 0)

	local tex = f:CreateTexture(nil, "BACKGROUND")
	tex:SetPoint("TOPLEFT")
	tex:SetPoint("BOTTOMRIGHT")
	tex:SetTexture(S["media"].backdrop)
	tex:SetGradientAlpha(unpack(S["media"].DefGradient))

	if height then f:Height(height) end
	if width then f:Width(width) end
end

function S:ReskinArrow(f, direction)
	if not f then return end
	f:Size(18, 18)
	S:Reskin(f)
	
	f:SetDisabledTexture(S["media"].backdrop)
	local dis = f:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .3)
	dis:SetDrawLayer("OVERLAY")

	local tex = f:CreateTexture(nil, "ARTWORK")
	tex:Size(8, 8)
	tex:SetPoint("CENTER")
	
	if direction == 1 then
		tex:SetTexture("Interface\\AddOns\\RayUI\\media\\arrow-left-active")
	elseif direction == 2 then
		tex:SetTexture("Interface\\AddOns\\RayUI\\media\\arrow-right-active")
	end
end

function S:ReskinCheck(f)
	if not f then return end
	f:SetNormalTexture("")
	f:SetPushedTexture("")
	f:SetHighlightTexture(S["media"].backdrop)
	local hl = f:GetHighlightTexture()
	hl:Point("TOPLEFT", 5, -5)
	hl:Point("BOTTOMRIGHT", -5, 5)
	hl:SetVertexColor(r, g, b, .2)

	local tex = f:CreateTexture(nil, "BACKGROUND")
	tex:Point("TOPLEFT", 5, -5)
	tex:Point("BOTTOMRIGHT", -5, 5)
	tex:SetTexture(S["media"].backdrop)
	tex:SetGradientAlpha(unpack(S["media"].DefGradient))
	
	local bd = CreateFrame("Frame", nil, f)
	bd:Point("TOPLEFT", tex, -1, 1)
	bd:Point("BOTTOMRIGHT", tex, 1, -1)
	bd:SetFrameLevel(f:GetFrameLevel()-1)
	S:CreateBD(bd, 0)
end

function S:ReskinSlider(f)
	if not f then return end
	f:SetBackdrop(nil)
	f.SetBackdrop = R.dummy

	local bd = CreateFrame("Frame", nil, f)
	bd:Point("TOPLEFT", 1, -2)
	bd:Point("BOTTOMRIGHT", -1, 3)
	bd:SetFrameStrata("BACKGROUND")
	bd:SetFrameLevel(f:GetFrameLevel()-1)
	S:CreateBD(bd, 0)

	local tex = bd:CreateTexture(nil, "BACKGROUND")
	tex:SetPoint("TOPLEFT")
	tex:SetPoint("BOTTOMRIGHT")
	tex:SetTexture(S["media"].backdrop)
	tex:SetGradientAlpha(unpack(S["media"].DefGradient))

	local slider = select(4, f:GetRegions())
	slider:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	slider:SetBlendMode("ADD")
end

function S:SetBD(f, x, y, x2, y2)
	if not f then return end
	local bg = CreateFrame("Frame", nil, f)
	if not x then
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT")
	else
		bg:Point("TOPLEFT", x, y)
		bg:Point("BOTTOMRIGHT", x2, y2)
	end
	bg:SetFrameLevel(0)
	S:CreateBD(bg)
	S:CreateSD(bg)
	f:HookScript("OnShow", function()
		bg:SetFrameLevel(0)
	end)
end

function S:RegisterSkin(name, loadFunc)
	if name == 'RayUI' then
		tinsert(self.SkinFuncs["RayUI"], loadFunc)
	else
		self.SkinFuncs[name] = loadFunc
	end
end

function S:ADDON_LOADED(event, addon)
	if IsAddOnLoaded("Skinner") or IsAddOnLoaded("Aurora") or addon == "RayUI" then return end
	if self.SkinFuncs[addon] then
		self.SkinFuncs[addon]()
		self.SkinFuncs[addon] = nil
	end
end

function S:PLAYER_ENTERING_WORLD(event, addon)
	if IsAddOnLoaded("Skinner") or IsAddOnLoaded("Aurora") then return end
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	for t, skinfunc in pairs(self.SkinFuncs["RayUI"]) do
		if skinfunc then
			skinfunc()
		end
	end
	wipe(self.SkinFuncs["RayUI"])
end

function S:Initialize()
	S["media"].backdrop = R["media"].normal
	for addon, loadFunc in pairs(self.SkinFuncs) do
		if addon ~= "RayUI" then
			if IsAddOnLoaded(addon) then
				loadFunc()
				self.SkinFuncs[addon] = nil
			end
		end
	end

	S:RegisterEvent("ADDON_LOADED")
	S:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function S:Info()
	return L["|cff7aa6d6Ray|r|cffff0000U|r|cff7aa6d6I|r插件美化模块."]
end

R:RegisterModule(S:GetName())