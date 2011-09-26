-----------------------------------------------------------
-- InterfaceOptionPage-1.0.lua
-----------------------------------------------------------
-- A simple function set for implementing Blizzard Interface Option style option
-- pages and common GUI option elements.
--
-----------------------------------------------------------
-- Sample Usage:
-----------------------------------------------------------
--
-- page = UICreateInterfaceOptionPage("name", "title" [, "subTitle" [, "categoryParent"]])
-- page:AnchorToTopLeft(control [, xOffset, yOffset])
-- page:AddCombatDisableItem(control)
-- page:Open()

-- slider = page:CreateSlider("text", minVal, maxVal [, step [, "valueFormat" [, disableInCombat]]])
-- slider.OnSliderInit = function(self) return someValue end
-- slider.OnSliderChanged = function(self, value) end

-- combo = page:CreateComboBox("text" [, horizontal [, disableInCombat]])
-- combo:AddLine(text, value)
-- combo:SetSelection(value [, noNotify])
-- combo.OnComboInit = function(self) return someValue end
-- combo.OnComboChanged = function(self, value) end

-- pressButton = page:CreatePressButton("text" [, disableInCombat])

-- multiGroup = page:CreateMultiSelectionGroup("title" [, horizontal])
-- multiGroup:AddButton("text", value [, disableInCombat])
-- multiGroup.OnCheckInit = function(self, value) return someValue end
-- multiGroup.OnCheckChanged = function(self, value, checked) end

-- singleGroup = page:CreateSingleSelectionGroup("title" [, horizontal])
-- singleGroup:AddButton("text", value [, disableInCombat])
-- singleGroup.OnCheckInit = function(self, value) return value == someValue end
-- singleGroup.OnSelectionChanged = function(self, value) end

-----------------------------------------------------------

local type = type
local error = error
local CreateFrame = CreateFrame
local ipairs = ipairs
local tinsert = tinsert
local format = format
local getglobal = getglobal
local hooksecurefunc = hooksecurefunc
local CloseDropDownMenus = CloseDropDownMenus
local InterfaceOptions_AddCategory = InterfaceOptions_AddCategory
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory
local _G = _G

local MAJOR_VERSION = 1
local MINOR_VERSION = 4

-- To prevent older libraries from over-riding newer ones...
if type(UICreateInterfaceOptionPage_IsNewerVersion) == "function" and not UICreateInterfaceOptionPage_IsNewerVersion(MAJOR_VERSION, MINOR_VERSION) then return end

local GUID = "{FF87CB54-703B-432B-A8E3-1DF612BFC3D0}"
local frame = _G[GUID]
if not frame then
	frame = CreateFrame("Frame")	
	_G[GUID] = frame
	frame.items = {}
	frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	frame:RegisterEvent("PLAYER_REGEN_ENABLED")
end

local function SafeCall(func, ...)
	if type(func) == "function" then
		return true, func(...)
	end
end

frame:SetScript("OnEvent", function(self, event)
	local key = event == "PLAYER_REGEN_DISABLED" and "Disable" or "Enable"
	local item
	for _, item in ipairs(self.items) do
		SafeCall(item[key], item)
	end	
end)

local function ClearAndHook(self, script, func)
	self:SetScript(script, nil)
	self:HookScript(script, func)
end

local function AddCombatDisableItem(self, item)
	tinsert(frame.items, item)
end

local function GetNextControlName(self, prefix)
	self.subControlId = (self.subControlId or 0) + 1
	return format("%s_%s_%d", self:GetName(), prefix or "SubControl", self.subControlId)
end

local function SubControl_OnShow(self)
	if not self.initShown then
		self.initShown = 1
		SafeCall(self.OnInitShow, self)
	end
end

local function SubControl_OnEnter(self)
	local hasTitle = type(self.tooltipTitle) == "string"
	local hasText = type(self.tooltipText) == "string"
	if hasTitle or hasText then
		GameTooltip:ClearLines()
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		if hasTitle then
			GameTooltip:AddLine(self.tooltipTitle)
		end

		if hasText then
			GameTooltip:AddLine(self.tooltipText, 1, 1, 1, 1)
		end
		GameTooltip:Show()
	end
end

local function SubControl_OnLeave(self)
	GameTooltip:Hide()
end

local function CreateSubControl(self, frameType, text, template, disableInCombat)
	local frame = CreateFrame(frameType, self:GetNextControlName(frameType), self, template)
	frame.text = getglobal(frame:GetName().."Text")

	if text then
		if frame.text then
			frame.text:SetText(text)
		else
			SafeCall(frame.SetText, frame, text)
		end
	end

	if disableInCombat then
		AddCombatDisableItem(self, frame)
	end
	
	ClearAndHook(frame, "OnShow", SubControl_OnShow)	
	ClearAndHook(frame, "OnEnter", SubControl_OnEnter)
	ClearAndHook(frame, "OnLeave", SubControl_OnLeave)
	return frame
end

local function CreatePressButton(self, text, disableInCombat)
	local button = CreateSubControl(self, "Button", text, "UIPanelButtonTemplate", disableInCombat)
	button:SetWidth(80)
	button:SetHeight(21)
	return button
end

local function CheckButton_Text_OnSetText(self)
	self:GetParent():SetHitRectInsets(0, -self:GetWidth(), 0, 0)
end

local function CheckButton_OnEnable(self)
	self.text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
end

local function CheckButton_OnDisable(self)
	self.text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
end

local function CheckButton_OnClick(self)	
	SafeCall(self.OnClick, self, self:GetChecked())
end

local function CreateCheckButton(self, text, disableInCombat)
	local button = CreateSubControl(self, "CheckButton", text, "InterfaceOptionsCheckButtonTemplate", disableInCombat)
	hooksecurefunc(button.text, "SetText", CheckButton_Text_OnSetText)
	button.text:SetText(text)
	button:SetScript("OnClick", nil)
	hooksecurefunc(button, "Enable", CheckButton_OnEnable)
	hooksecurefunc(button, "Disable", CheckButton_OnDisable)
	return button
end

local function CheckGroup_OnInitShow(self)
	local valid, value = SafeCall(self.group.OnCheckInit, self.group, self.value, self)
	if valid then
		self:SetChecked(value)
	end
end

local function CheckGroup_OnClick(self)
	SafeCall(self.group.OnCheckChanged, self.group, self.value, self:GetChecked(), self)
end

local function CheckGroup_GetButton(self, idx)
	if type(idx) ~= "number" or idx < 1 then
		return self[-1]
	end
	return self.buttons[idx] or self[-1]
end


local function CheckGroup_AddButton(self, text, value, disableInCombat)
	local button = CreateCheckButton(self:GetParent(), text, disableInCombat)
	button.group = self
	button.value = value
	tinsert(self.buttons, button)
	button.OnInitShow = CheckGroup_OnInitShow
	button:HookScript("OnClick", CheckGroup_OnClick)	

	local anchor = self[-1]
	if anchor and self.horiz then
		anchor = anchor.text
	end

	if anchor then				
		button:SetPoint(self.horiz and "LEFT" or "TOPLEFT", anchor, self.horiz and "RIGHT" or "BOTTOMLEFT", self.horiz and 12 or 0, 0)
	else
		button:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -6)
	end
			
	tinsert(self, button)
	self[-1] = button			
	return button
end

local function CreateMultiSelectionGroup(self, title, horizontal)
	local group = self:CreateFontString(GetNextControlName(self, "FontString"), "ARTWORK", "GameFontNormalLeft")
	group:SetText(title)
	group.buttons = {}
	group.horiz = horizontal
	group.AddButton = CheckGroup_AddButton
	group.GetButton = CheckGroup_GetButton
	return group
end

local function SingleGroup_OnCheckChanged(self, value, checked, button)
	if checked then
		local other, changed
		for _, other in ipairs(self.buttons) do
			if other ~= button and other:GetChecked() then
				other:SetChecked(nil)
				changed = 1
			end
		end

		if changed then
			SafeCall(self.OnSelectionChanged, self, value, button)
		end				
	else
		button:SetChecked(1)
	end
end

local function CreateSingleSelectionGroup(self, ...)
	local group = CreateMultiSelectionGroup(self, ...)
	group.OnCheckChanged = SingleGroup_OnCheckChanged
	return group
end

local function Slider_InitShow(self)
	local valid, value = SafeCall(self.OnSliderInit, self)
	if value then
		local func = self.OnSliderChanged
		self.OnSliderChanged = nil
		self:SetValue(value)
		self.OnSliderChanged = func
	end
end

local function Slider_OnValueChanged(self, value)
	self.value:SetText(format(self.valueFormat, value))
	SafeCall(self.OnSliderChanged, self, value)
end

local function Slider_OnEnable(self)
	self.text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	self.value:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	self.low:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	self.high:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
end

local function Slider_OnDisable(self)
	self.text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	self.value:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	self.low:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	self.high:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
end

local function CreateSlider(self, text, minVal, maxVal, step, valueFormat, disableInCombat)
	local slider = CreateSubControl(self, "Slider", text, "OptionsSliderTemplate", disableInCombat)
	slider:SetWidth(200)
	slider:SetMinMaxValues(minVal or 0, maxVal or 1)
	slider:SetValueStep(step or 1)
	slider.valueFormat = type(valueFormat) == "string" and valueFormat or "%d"

	slider.text:SetJustifyH("LEFT")
	slider.text:SetJustifyV("BOTTOM")
	slider.text:ClearAllPoints()
	slider.text:SetPoint("BOTTOMLEFT", slider, "TOPLEFT")
	slider.text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	slider.value = slider:CreateFontString(slider:GetName().."Value", "ARTWORK", "GameFontGreen")
	slider.value:SetJustifyH("RIGHT")
	slider.value:SetJustifyV("BOTTOM")
	slider.value:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT")

	slider.low = getglobal(slider:GetName().."Low")
	slider.high = getglobal(slider:GetName().."High")	
	slider.low:SetText(format(slider.valueFormat, minVal or 0))
	slider.high:SetText(format(slider.valueFormat, maxVal or 1))
	
	hooksecurefunc(slider, "Enable", Slider_OnEnable)
	hooksecurefunc(slider, "Disable", Slider_OnDisable)

	slider.OnInitShow = Slider_InitShow
	ClearAndHook(slider, "OnValueChanged", Slider_OnValueChanged)

	return slider
end

local function ValuesEqual(value1, value2)
	return type(value1) == type(value2) and value1 == value2
end

local function ComboBox_AddLine(self, text, value)
	tinsert(self.dropdown.lines, { text = text, value = value})
end

local function ComboBox_OnSelect(_, self, line, noNotify)
	self.dropdown.text:SetText(line.text)
	self.value = line.value
	if not noNotify then
		SafeCall(self.OnComboChanged, self, line.value, line.text)
	end
end

local function ComboBox_SetSelection(self, value, noNotify)
	local line
	for _, line in ipairs(self.dropdown.lines) do
		if ValuesEqual(line.value, value) then
			ComboBox_OnSelect(_, self, line, noNotify)
			return
		end
	end
end

local function Dropdown_InitFunc(self)
	local parent = self:GetParent()
	local i
	for i = 1, #(self.lines) do
		local line = self.lines[i]
		UIDropDownMenu_AddButton({ text = line.text, checked = ValuesEqual(parent.value, line.value), func = ComboBox_OnSelect, arg1 = parent, arg2 = line })
	end
end

local function ComboBox_InitShow(self)
	local valid, value = SafeCall(self.OnComboInit, self)
	if valid then
		ComboBox_SetSelection(self, value, 1)
	end
end

local function ComboBox_Enable(self)
	UIDropDownMenu_EnableDropDown(self.dropdown)
end

local function ComboBox_Disable(self)	
	UIDropDownMenu_DisableDropDown(self.dropdown)
	CloseDropDownMenus()
end

local function ComboBox_IsEnabled(self)
	UIDropDownMenu_IsEnabled(self.dropdown)
end

local function CreateComboBox(self, text, horizontal, disableInCombat)
	local frame = CreateSubControl(self, "Frame", nil, nil, disableInCombat)
	frame:EnableMouse(true)
	frame:SetWidth(160)
	frame:SetHeight(26)
	frame:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, insets = {left = 5, right = 5, top = 5, bottom = 5 }})
	frame:SetBackdropBorderColor(0.75, 0.75, 0.75, 0.75)	

	local dropdown = CreateFrame("Frame", frame:GetName().."Dropdown", frame, "UIDropDownMenuTemplate")
	dropdown:SetAllPoints(frame)
	local name = dropdown:GetName()
	getglobal(name.."Left"):Hide()
	getglobal(name.."Middle"):Hide()
	getglobal(name.."Right"):Hide()

	local button = getglobal(name.."Button")
	button:ClearAllPoints()
	button:SetPoint("RIGHT")

	dropdown.text = getglobal(name.."Text")
	dropdown.text:SetJustifyH("LEFT")
	dropdown.text:ClearAllPoints()
	dropdown.text:SetPoint("LEFT", 8, 0)
	dropdown.text:SetPoint("RIGHT", -26, 0)	

	frame.dropdown = dropdown
	frame.text = frame:CreateFontString(name.."Label", "ARTWORK", "GameFontNormalLeft")
	frame.text:SetText(text)
	if type(horizontal) == "number" and horizontal > 10 then
		frame.text:SetWidth(horizontal)
	end

	if horizontal then
		frame.text:SetPoint("RIGHT", frame, "LEFT", -2, 0)
	else
		frame.text:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 2)
	end

	dropdown.lines = {}
	dropdown.displayMode = "MENU"
	dropdown.point, dropdown.relativeTo, dropdown.relativePoint, dropdown.xOffset, dropdown.yOffset = "TOPLEFT", frame, "BOTTOMLEFT", 0, 3
	UIDropDownMenu_Initialize(dropdown, Dropdown_InitFunc)

	frame.OnInitShow = ComboBox_InitShow
	frame.AddLine = ComboBox_AddLine
	frame.SetSelection = ComboBox_SetSelection
	frame.Enable = ComboBox_Enable
	frame.Disable = ComboBox_Disable
	frame.IsEnabled = ComboBox_IsEnabled
	return frame
end

local function AnchorToTopLeft(self, control, xOffset, yOffset)
	if type(control) == "table" and type(control.ClearAllPoints) == "function" then
		control:ClearAllPoints()
		control:SetPoint("TOPLEFT", self, "TOPLEFT", 16 + (xOffset or 0), -70 + (yOffset or 0))
	end
end

function UICreateInterfaceOptionPage(name, title, subTitle, categoryParent)
	if type(name) ~= "string" then
		error(format("bad argument #1 to 'UICreateInterfaceOptionPage' (string expected, got %s)", type(name)))
		return
	end	

	if type(title) ~= "string" then
		error(format("bad argument #2 to 'UICreateInterfaceOptionPage' (string expected, got %s)", type(title)))
		return
	end

	if subTitle ~= nil and type(subTitle) ~= "string" then
		error(format("bad argument #3 to 'UICreateInterfaceOptionPage' (nil or string expected, got %s)", type(subTitle)))
		return
	end

	if categoryParent ~= nil and type(categoryParent) ~= "string" then
		error(format("bad argument #4 to 'UICreateInterfaceOptionPage' (nil or string expected, got %s)", type(categoryParent)))
		return
	end

	local page = CreateFrame("Frame", name)
	page:Hide()	
		
	page.title = page:CreateFontString(name.."Title", "ARTWORK", "GameFontNormalLargeLeft")
	page.title:SetText(title)
	page.title:SetJustifyV("TOP")
	page.title:SetPoint("TOPLEFT", page, "TOPLEFT", 16, -16)

	page.subTitle = page:CreateFontString(name.."SubTitle", "ARTWORK", "GameFontHighlightSmallLeftTop")	
	page.subTitle:SetPoint("TOPLEFT", page.title, "BOTTOMLEFT", 0, -8)	
	page.subTitle:SetPoint("BOTTOMRIGHT", page, "TOPRIGHT", -16, -120)
	page.subTitle:SetNonSpaceWrap(true)
	page.subTitle:SetText(subTitle)

	-- Inject to Blizzard UI option
	page.name = title
	page.parent = categoryParent
	InterfaceOptions_AddCategory(page)

	page:HookScript("OnShow", SubControl_OnShow)
	page.GetNextControlName = GetNextControlName
	page.CreateSubControl = CreateSubControl
	page.CreatePressButton = CreatePressButton
	page.CreateCheckButton = CreateCheckButton
	page.CreateMultiSelectionGroup = CreateMultiSelectionGroup	
	page.CreateSingleSelectionGroup = CreateSingleSelectionGroup
	page.CreateSlider = CreateSlider
	page.CreateComboBox = CreateComboBox
	page.AnchorToTopLeft = AnchorToTopLeft
	page.Open = InterfaceOptionsFrame_OpenToCategory
	page.AddCombatDisableItem = AddCombatDisableItem
	
	return page
end

-- Provides version check
function UICreateInterfaceOptionPage_IsNewerVersion(major, minor)
	if type(major) ~= "number" or type(minor) ~= "number" then
		return false
	end

	if major > MAJOR_VERSION then
		return true
	elseif major < MAJOR_VERSION then
		return false
	else -- major equal, check minor
		return minor > MINOR_VERSION
	end
end