local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local AB = R:NewModule("ActionBar", "AceEvent-3.0", "AceHook-3.0")

AB.modName = L["动作条"]

function AB:GetOptions()
	local options = {
		barscale = {
			order = 5,
			name = L["动作条缩放"],
			type = "range",
			min = 0.5, max = 1.5, step = 0.01,
			isPercent = true,
		},
		petbarscale = {
			order = 6,
			name = L["宠物动作条缩放"],
			type = "range",
			min = 0.5, max = 1.5, step = 0.01,
			isPercent = true,
		},
		buttonsize = {
			order = 7,
			name = L["按键大小"],
			type = "range",
			min = 20, max = 35, step = 1,
		},
		buttonspacing = {
			order = 8,
			name = L["按键间距"],
			type = "range",
			min = 1, max = 10, step = 1,
		},
		macroname = {
			order = 9,
			name = L["显示宏名称"],
			type = "toggle",
		},
		itemcount = {
			order = 10,
			name = L["显示物品数量"],
			type = "toggle",
		},
		hotkeys = {
			order = 11,
			name = L["显示快捷键"],
			type = "toggle",
		},
		showgrid = {
			order = 12,
			name = L["显示空按键"],
			type = "toggle",
		},
		CooldownAlphaGroup = {
			order = 13,
			type = "group",
			name = L["根据CD淡出"],
			guiInline = true,
			args = {
				cooldownalpha = {
					type = "toggle",
					name = L["启用"],
					order = 1,
				},
				spacer = {
					type = 'description',
					name = '',
					desc = '',
					order = 2,
				},
				cdalpha = {
					order = 3,
					name = L["CD时透明度"],
					type = "range",
					min = 0, max = 1, step = 0.05,
					disabled = function() return not self.db.cooldownalpha end,
				},
				readyalpha = {
					order = 4,
					name = L["就绪时透明度"],
					type = "range",
					min = 0, max = 1, step = 0.05,
					disabled = function() return not self.db.cooldownalpha end,
				},
				stancealpha = {
					type = "toggle",
					name = L["姿态条"],
					order = 5,
					disabled = function() return not self.db.cooldownalpha end,
				},
			},
		},
		Bar1Group = {
			order = 14,
			type = "group",
			name = L["动作条1"],
			guiInline = true,
			args = {
				bar1fade = {
					type = "toggle",
					name = L["自动隐藏"],
					order = 1,
				},
				spacer = {
					type = 'description',
					name = '',
					desc = '',
					order = 2,
				},
			},
		},
		Bar2Group = {
			order = 15,
			type = "group",
			guiInline = true,
			name = L["动作条2"],
			args = {
				bar2fade = {
					type = "toggle",
					name = L["自动隐藏"],
					order = 1,
				},
				bar2mouseover = {
					type = "toggle",
					name = L["鼠标滑过显示"],
					order = 2,
				},
			},
		},
		Bar3Group = {
			order = 16,
			type = "group",
			guiInline = true,
			name = L["动作条3"],
			args = {
				bar3fade = {
					type = "toggle",
					name = L["自动隐藏"],
					order = 1,
				},
				bar3mouseover = {
					type = "toggle",
					name = L["鼠标滑过显示"],
					order = 2,
				},
			},
		},
		Bar4Group = {
			order = 17,
			type = "group",
			guiInline = true,
			name = L["动作条4"],
			args = {
				bar4fade = {
					type = "toggle",
					name = L["自动隐藏"],
					order = 1,
				},
				bar4mouseover = {
					type = "toggle",
					name = L["鼠标滑过显示"],
					order = 2,
				},
			},
		},
		Bar5Group = {
			order = 18,
			type = "group",
			guiInline = true,
			name = L["动作条5"],
			args = {
				bar5fade = {
					type = "toggle",
					name = L["自动隐藏"],
					order = 1,
				},
				bar5mouseover = {
					type = "toggle",
					name = L["鼠标滑过显示"],
					order = 2,
				},
			},
		},
		PetGroup = {
			order = 18,
			type = "group",
			guiInline = true,
			name = L["宠物条"],
			args = {
				petbarfade = {
					type = "toggle",
					name = L["自动隐藏"],
					order = 1,
				},
				petbarmouseover = {
					type = "toggle",
					name = L["鼠标滑过显示"],
					order = 2,
				},
			},
		},
		StanceGroup = {
			order = 20,
			type = "group",
			guiInline = true,
			name = L["姿态条"],
			args = {
				stancebarfade = {
					type = "toggle",
					name = L["自动隐藏"],
					order = 1,
				},
				stancebarmouseover = {
					type = "toggle",
					name = L["鼠标滑过显示"],
					order = 2,
				},
			},
		},
	}
	return options
end

function AB:HideBlizz()
	MainMenuBar:SetScale(0.00001)
	MainMenuBar:EnableMouse(false)
	VehicleMenuBar:SetScale(0.00001)
	VehicleMenuBar:EnableMouse(false)

	local FramesToHide = {
		MainMenuBar,
		MainMenuBarArtFrame,
		BonusActionBarFrame,
		VehicleMenuBar,
		PossessBarFrame,
	}

	for _, f in pairs(FramesToHide) do
		if f:GetObjectType() == "Frame" then
			f:UnregisterAllEvents()
		end
		if f ~= MainMenuBar then --patch 4.0.6 fix found by tukz
			f:HookScript("OnShow", function(s) s:Hide(); end)
			f:Hide()
		end
		f:SetAlpha(0)
	end

	-- code by tukz/evl22
	-- fix main bar keybind not working after a talent switch. :X
	hooksecurefunc("TalentFrame_LoadUI", function()
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	end)
end

function AB:Initialize()
	self:HideBlizz()
	SetCVar("alwaysShowActionBars", 0)
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Kill()
	if self.db.showgrid == true then
		ActionButton_HideGrid = R.dummy
		for i = 1, 12 do
			local button = _G[format("ActionButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("BonusActionButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("MultiBarRightButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("MultiBarBottomRightButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("MultiBarLeftButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("MultiBarBottomLeftButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("PetActionButton%d", i)]
			if button then
				button:SetAttribute("showgrid", 1)
				ActionButton_ShowGrid(button)
			end
		end
	end
	for i = 1, 5 do
		AB["CreateBar"..i]()
	end
	self:CreateBarPet()
	self:CreateStanceBar()
	self:CreateBarTotem()
	self:CreateVehicleExit()
	self:CreateExtraButton()
	self:CreateCooldown()
	self:LoadKeyBinder()
	self:CreateRangeDisplay()
	self:EnableAutoHide()

	self:SecureHook("ActionButton_ShowOverlayGlow", "UpdateOverlayGlow")
	self:SecureHook("ActionButton_UpdateHotkeys", "UpdateHotkey")
	self:SecureHook("ActionButton_Update", "Style")
	self:SecureHook("ActionButton_UpdateFlyout", "StyleFlyout")
	self:SecureHook("ShapeshiftBar_Update", "StyleShift")
	self:SecureHook("ShapeshiftBar_UpdateState", "StyleShift")
	self:SecureHook("PetActionBar_Update", "StylePet")
end

function AB:Info()
	return L["|cff7aa6d6Ray|r|cffff0000U|r|cff7aa6d6I|r头像模块."]
end

function AB:UpdateHotkey(button, actionButtonType)
	local hotkey = _G[button:GetName() .. 'HotKey']
	local text = hotkey:GetText()

	text = string.gsub(text, '(s%-)', 'S')
	text = string.gsub(text, '(a%-)', 'A')
	text = string.gsub(text, '(c%-)', 'C')
	text = string.gsub(text, '(Mouse Button )', 'M')
	text = string.gsub(text, '(滑鼠按鍵)', 'M')
	text = string.gsub(text, '(鼠标按键)', 'M')
	text = string.gsub(text, KEY_BUTTON3, 'M3')
	text = string.gsub(text, '(Num Pad )', 'N')
	text = string.gsub(text, KEY_PAGEUP, 'PU')
	text = string.gsub(text, KEY_PAGEDOWN, 'PD')
	text = string.gsub(text, KEY_SPACE, 'SpB')
	text = string.gsub(text, KEY_INSERT, 'Ins')
	text = string.gsub(text, KEY_HOME, 'Hm')
	text = string.gsub(text, KEY_DELETE, 'Del')
	text = string.gsub(text, KEY_MOUSEWHEELUP, 'MwU')
	text = string.gsub(text, KEY_MOUSEWHEELDOWN, 'MwD')

	if hotkey:GetText() == _G['RANGE_INDICATOR'] then
		hotkey:SetText('')
	else
		hotkey:SetText(text)
	end
end

function AB:Style(button, totem, flyout)
	local name = button:GetName()

	if name:match("MultiCast") then return end

	local action = button.action
	local Icon = _G[name.."Icon"]
	local Count = _G[name.."Count"]
	local Flash	 = _G[name.."Flash"]
	local HotKey = _G[name.."HotKey"]
	local Border  = _G[name.."Border"]
	local Btname = _G[name.."Name"]
	local normal  = _G[name.."NormalTexture"]
	local normal2 = button:GetNormalTexture()
	local cooldown = _G[name .. "Cooldown"]

	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:SetAllPoints(button)
	end

	if Flash then Flash:SetTexture(nil) end
	if normal then normal:SetTexture(nil) end
	if normal2 then normal2:SetTexture(nil) end
	if Border then Border:Kill() end

	if Count then
		Count:ClearAllPoints()
		Count:SetPoint("BOTTOMRIGHT", 0, R:Scale(2))
		Count:SetFont(R["media"].pxfont, R.mult*10, "OUTLINE,MONOCHROME")
	end

	if _G[name..'FloatingBG'] then
		_G[name..'FloatingBG']:Kill()
	end

	if not button.equipped then
		local equipped = button:CreateTexture(nil, "OVERLAY")
		equipped:SetTexture(R["media"].blank)
		equipped:SetVertexColor(0, 1, 0, 0.2)
		equipped:SetGradientAlpha("VERTICAL", 0, 1, 0, 0, 0, 1, 0, .3)
		equipped:SetAllPoints()
		equipped:Hide()
		button.equipped = equipped
	end

	if action and IsEquippedAction(action) then
		if not button.equipped:IsShown() then
			button.equipped:Show()
		end
	else
		if button.equipped:IsShown() then
			button.equipped:Hide()
		end
	end

	if button.styled then return end

	if Btname then
		if AB.db.macroname ~= true then
			Btname:SetText("")
			Btname:Hide()
			Btname.Show = R.dummy
		end
	end

	if not button.shadow then
		if not totem then
			if not flyout then
				button:SetWidth(AB.db.buttonsize)
				button:SetHeight(AB.db.buttonsize)
			end

			button:CreateShadow("Background")
		end

		if Icon then
			Icon:SetTexCoord(.08, .92, .08, .92)
			Icon:SetAllPoints()
		end
	end

	if HotKey then
		HotKey:ClearAllPoints()
		HotKey:SetPoint("TOPRIGHT", 0, 0)
		HotKey:SetFont(R["media"].pxfont, R.mult*10, "OUTLINE,MONOCHROME")
		HotKey:SetShadowColor(0, 0, 0, 0.3)
		HotKey.ClearAllPoints = R.dummy
		HotKey.SetPoint = R.dummy
		if not AB.db.hotkeys == true then
			HotKey:SetText("")
			HotKey:Hide()
			HotKey.Show = R.dummy
		end
	end

	if normal then
		normal:ClearAllPoints()
		normal:SetPoint("TOPLEFT")
		normal:SetPoint("BOTTOMRIGHT")
	end

	if not flyout then
		Icon.SetVertexColor = function(self,r,g,b)
			self:SetGradient("VERTICAL",r*.345,g*.345,b*.345,r,g,b)
		end
		Icon:SetVertexColor(1, 1, 1)
	else
		Icon:SetGradient("VERTICAL",.345,.345,.345,1,1,1)
	end

	button:StyleButton(true)

	button.styled = true
end

function AB:StyleSmallButton(normal, button, icon, name, pet)
	local Flash	 = _G[name.."Flash"]

	button:SetNormalTexture("")
	button.SetNormalTexture = R.dummy
	button:StyleButton(true)

	icon.SetVertexColor = function(self,r,g,b)
		self:SetGradient("VERTICAL",r*.345,g*.345,b*.345,r,g,b)
	end
	icon:SetVertexColor(1, 1, 1)

	Flash:SetTexture(1, 1, 1, 0.3)

	if not button.shadow then
		button:CreateShadow("Background")
	end

	icon:SetTexCoord(.08, .92, .08, .92)
	icon:ClearAllPoints()
	if pet then
		if AB.db.buttonsize < 30 then
			local autocast = _G[name.."AutoCastable"]
			autocast:SetAlpha(0)
		end
		local shine = _G[name.."Shine"]
		shine:Size(AB.db.buttonsize, AB.db.buttonsize)
		shine:ClearAllPoints()
		shine:SetPoint("CENTER", button, 0, 0)
		icon:SetAllPoints()
	else
		icon:SetAllPoints()
	end

	if normal then
		normal:ClearAllPoints()
		normal:SetPoint("TOPLEFT")
		normal:SetPoint("BOTTOMRIGHT")
	end
end

function AB:StyleShift()
	for i=1, NUM_SHAPESHIFT_SLOTS do
		local name = "ShapeshiftButton"..i
		local button  = _G[name]
		local icon  = _G[name.."Icon"]
		local normal  = _G[name.."NormalTexture"]
		AB:StyleSmallButton(normal, button, icon, name)
	end
end

function AB:StylePet()
	for i=1, NUM_PET_ACTION_SLOTS do
		local name = "PetActionButton"..i
		local button  = _G[name]
		local icon  = _G[name.."Icon"]
		local normal  = _G[name.."NormalTexture2"]
		AB:StyleSmallButton(normal, button, icon, name, true)
	end
end

local buttons = 0
local function SetupFlyoutButton()
	for i=1, buttons do
		if _G["SpellFlyoutButton"..i] then
			_G["SpellFlyoutButton"..i.."Icon"]:SetGradient("VERTICAL",.345,.345,.345,1,1,1)
			AB:Style(_G["SpellFlyoutButton"..i], nil, true)
			_G["SpellFlyoutButton"..i]:StyleButton(true)
		end
	end
end
SpellFlyout:HookScript("OnShow", SetupFlyoutButton)

function AB:StyleFlyout(button)
	if not button.FlyoutBorder then return end
	button.FlyoutBorder:SetAlpha(0)
	button.FlyoutBorderShadow:SetAlpha(0)

	SpellFlyoutHorizontalBackground:SetAlpha(0)
	SpellFlyoutVerticalBackground:SetAlpha(0)
	SpellFlyoutBackgroundEnd:SetAlpha(0)

	for i=1, GetNumFlyouts() do
		local x = GetFlyoutID(i)
		local _, _, numSlots, isKnown = GetFlyoutInfo(x)
		if isKnown then
			buttons = numSlots
			break
		end
	end

	--Change arrow direction depending on what bar the button is on
	local arrowDistance
	if ((SpellFlyout and SpellFlyout:IsShown() and SpellFlyout:GetParent() == button) or GetMouseFocus() == button) then
		arrowDistance = 5
	else
		arrowDistance = 2
	end

	if button:GetParent() and button:GetParent():GetParent() and button:GetParent():GetParent():GetName() and button:GetParent():GetParent():GetName() == "SpellBookSpellIconsFrame" then
		return
	end

	if button:GetAttribute("flyoutDirection") ~= nil then
		local point, _, _, _, _ = button:GetPoint()

		if strfind(point, "TOP") then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("LEFT", button, "LEFT", -arrowDistance, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 270)
			if not InCombatLockdown() then button:SetAttribute("flyoutDirection", "LEFT") end
		else
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("TOP", button, "TOP", 0, arrowDistance)
			SetClampedTextureRotation(button.FlyoutArrow, 0)
			if not InCombatLockdown() then button:SetAttribute("flyoutDirection", "UP") end
		end
	end
end

function AB:UpdateOverlayGlow(button)
	if button.overlay and button.shadow then
		button.overlay:SetParent(button)
		button.overlay:ClearAllPoints()
		button.overlay:SetAllPoints(button.shadow)
		button.overlay.ants:ClearAllPoints()
		button.overlay.ants:SetPoint("TOPLEFT", button.shadow, "TOPLEFT", -2, 2)
		button.overlay.ants:SetPoint("BOTTOMRIGHT", button.shadow, "BOTTOMRIGHT", 2, -2)
		button.overlay.outerGlow:SetPoint("TOPLEFT", button.shadow, "TOPLEFT", -2, 2)
		button.overlay.outerGlow:SetPoint("BOTTOMRIGHT", button.shadow, "BOTTOMRIGHT", 2, -2)
	end
end

R:RegisterModule(AB:GetName())