-- Originally based on aBags by Alza.
local R, C, L, DB = unpack(select(2, ...))

if not C["bag"].enable then return end
--[[ Get the number of bag and bank container slots used ]]

local function CheckSlots()
	for i = 4, 1, -1 do
		if GetContainerNumSlots(i) ~= 0 then
			return i + 1
		end
	end
	return 1
end

-- [[ Local stuff ]]

local Spacing = 4
local _G = _G
local bu, con, bag, col, row
local buttons, bankbuttons = {}, {}
local firstbankopened = 1

--[[ Function to move buttons ]]

local MoveButtons = function(table, frame, columns)
	col, row = 0, 0
	for i = 1, #table do
		bu = table[i]
		bu:ClearAllPoints()
		bu:SetPoint("TOPLEFT", frame, "TOPLEFT", col * (37 + Spacing) + 3, -1 * row * (37 + Spacing) - 3)
		if(col > (columns - 2)) then
			col = 0
			row = row + 1
		else
			col = col + 1
		end
	end

	frame:SetHeight((row + (col==0 and 0 or 1)) * (37 + Spacing) + 19)
	frame:SetWidth(columns * 37 + Spacing * (columns - 1) + 6)
	col, row = 0, 0
end

--[[ Bags ]]

local holder = CreateFrame("Button", "BagsHolder", UIParent)
holder:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -28, 33)
holder:SetFrameStrata("HIGH")
holder:Hide()
R.CreateBD(holder, .6)
R.CreateSD(holder)

local ReanchorButtons = function()
	table.wipe(buttons)
	for f = 1, CheckSlots() do
		con = "ContainerFrame"..f
		bag = _G[con]
		if not bag.reskinned then
			bag:EnableMouse(false)
			_G[con.."CloseButton"]:Hide()
			_G[con.."PortraitButton"]:EnableMouse(false)

			for i = 1, 7 do
				select(i, bag:GetRegions()):SetAlpha(0)
			end

			bag.reskinned = true
		end

		for i = GetContainerNumSlots(f-1), 1, -1  do
			bu = _G[con.."Item"..i]
			if not bu.reskinned then
				if bu.SetHighlightTexture and not bu.hover then
					local hover = bu:CreateTexture("frame", nil, self)
					hover:SetTexture(1, 1, 1, 0.3)
					hover:Point('TOPLEFT', 0, -0)
					hover:Point('BOTTOMRIGHT', -0, 0)
					bu.hover = hover
					bu:SetHighlightTexture(hover)
				end
				
				if bu.SetPushedTexture and not bu.pushed then
					local pushed = bu:CreateTexture("frame", nil, self)
					pushed:SetTexture(0.9, 0.8, 0.1, 0.3)
					pushed:Point('TOPLEFT', 0, -0)
					pushed:Point('BOTTOMRIGHT', -0, 0)
					bu.pushed = pushed
					bu:SetPushedTexture(pushed)
				end
				
				if bu.SetCheckedTexture and not bu.checked then
					local checked = bu:CreateTexture("frame", nil, self)
					checked:SetTexture(23/255,132/255,209/255,0.5)
					checked:Point('TOPLEFT', 0, -0)
					checked:Point('BOTTOMRIGHT', -0, 0)
					bu.checked = checked
					bu:SetCheckedTexture(checked)
				end
				
				local cooldown = _G[bu:GetName().."Cooldown"]
				if cooldown then
					cooldown:ClearAllPoints()
					cooldown:Point('TOPLEFT', 0, -0)
					cooldown:Point('BOTTOMRIGHT', -0, 0)
				end
				
				if not bu.border then
					local border = CreateFrame("Frame", nil, bu)
					border:Point("TOPLEFT", -1, 1)
					border:Point("BOTTOMRIGHT", 1, -1)
					border:SetFrameStrata("BACKGROUND")
					border:SetFrameLevel(0)
					bu.border = border
					bu.border:CreateBorder()
				end
				bu:SetNormalTexture("")
				bu:SetFrameStrata("HIGH")
				_G[con.."Item"..i.."Count"]:SetFont(C.media.font, C.media.fontsize, C.media.fontflag)
				_G[con.."Item"..i.."Count"]:ClearAllPoints()
				_G[con.."Item"..i.."Count"]:SetPoint("BOTTOMRIGHT", bu, 0, 0)
				_G[con.."Item"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
				_G[con.."Item"..i.."IconQuestTexture"]:SetAlpha(0)
				bu.reskinned = true
			end
			tinsert(buttons, bu)
		end
	end
	MoveButtons(buttons, holder, CheckSlots() + 4)
	holder:Show()
end

local money = _G["ContainerFrame1MoneyFrame"]
money:SetFrameStrata("DIALOG")
money:SetParent(holder)
money:ClearAllPoints()
money:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", 12, 2)

--[[ Bank ]]

local bankholder = CreateFrame("Button", "BagsBankHolder", UIParent)
bankholder:SetFrameStrata("HIGH")
bankholder:Hide()
R.CreateBD(bankholder, .6)
R.CreateSD(bankholder)

local ReanchorBankButtons = function()
	table.wipe(bankbuttons)
	for i = 1, 28 do
		bu = _G["BankFrameItem"..i]
		if not bu.reskinned then
			if bu.SetHighlightTexture and not bu.hover then
				local hover = bu:CreateTexture("frame", nil, self)
				hover:SetTexture(1, 1, 1, 0.3)
				hover:Point('TOPLEFT', 0, -0)
				hover:Point('BOTTOMRIGHT', -0, 0)
				bu.hover = hover
				bu:SetHighlightTexture(hover)
			end
			
			if bu.SetPushedTexture and not bu.pushed then
				local pushed = bu:CreateTexture("frame", nil, self)
				pushed:SetTexture(0.9, 0.8, 0.1, 0.3)
				pushed:Point('TOPLEFT', 0, -0)
				pushed:Point('BOTTOMRIGHT', -0, 0)
				bu.pushed = pushed
				bu:SetPushedTexture(pushed)
			end
			
			if bu.SetCheckedTexture and not bu.checked then
				local checked = bu:CreateTexture("frame", nil, self)
				checked:SetTexture(23/255,132/255,209/255,0.5)
				checked:Point('TOPLEFT', 0, -0)
				checked:Point('BOTTOMRIGHT', -0, 0)
				bu.checked = checked
				bu:SetCheckedTexture(checked)
			end
			
			local cooldown = _G[bu:GetName().."Cooldown"]
			if cooldown then
				cooldown:ClearAllPoints()
				cooldown:Point('TOPLEFT', 0, -0)
				cooldown:Point('BOTTOMRIGHT', -0, 0)
			end
			
			if not bu.border then
				local border = CreateFrame("Frame", nil, bu)
				border:Point("TOPLEFT", -1, 1)
				border:Point("BOTTOMRIGHT", 1, -1)
				border:SetFrameStrata("BACKGROUND")
				border:SetFrameLevel(0)
				bu.border = border
				bu.border:CreateBorder()
			end
			bu:SetNormalTexture("")
			bu:SetFrameStrata("HIGH")
			_G["BankFrameItem"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
			_G["BankFrameItem"..i.."Count"]:SetFont(C.media.font, C.media.fontsize, C.media.fontflag)
			_G["BankFrameItem"..i.."Count"]:ClearAllPoints()
			_G["BankFrameItem"..i.."Count"]:SetPoint("BOTTOMRIGHT", bu, 0, 0)
			_G["BankFrameItem"..i.."IconQuestTexture"]:SetAlpha(0)
			bu.reskinned = true
		end
		tinsert(bankbuttons, bu)
	end

	if(firstbankopened==1) then
		_G["BankFrame"]:EnableMouse(false)
		_G["BankCloseButton"]:Hide()

		for f = 1, 5 do
			select(f, _G["BankFrame"]:GetRegions()):SetAlpha(0)
		end
		bankholder:SetPoint("BOTTOMRIGHT", "BagsHolder", "BOTTOMLEFT", -10 , 0)
		firstbankopened = 0
	end

	for f = CheckSlots() + 1, CheckSlots() + GetNumBankSlots() + 1, 1 do
		con = "ContainerFrame"..f
		bag = _G[con]
		if not bag.reskinned then
			bag:EnableMouse(false)
			bag:SetScale(1)
			bag.SetScale = R.dummy
			_G[con.."CloseButton"]:Hide()
			_G[con.."PortraitButton"]:EnableMouse(false)

			for i = 1, 7 do
				select(i, bag:GetRegions()):SetAlpha(0)
			end
			bag.reskinned = true
		end

		for i = GetContainerNumSlots(f-1), 1, -1  do
			bu = _G[con.."Item"..i]
			if not bu.reskinned then
				bu:SetNormalTexture("")
				bu:SetPushedTexture("")
				bu:SetFrameStrata("HIGH")
				_G[con.."Item"..i.."Count"]:SetFont(C.media.font, C.media.fontsize, C.media.fontflag)
				_G[con.."Item"..i.."Count"]:ClearAllPoints()
				_G[con.."Item"..i.."Count"]:SetPoint("BOTTOMRIGHT", bu, 0, 0)
				_G[con.."Item"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
				_G[con.."Item"..i.."IconQuestTexture"]:SetAlpha(0)
				bu.reskinned = true
			end
			tinsert(bankbuttons, bu)
		end
	end
	MoveButtons(bankbuttons, bankholder, CheckSlots() + 8)
	bankholder:Show()
end

local money = _G["BankFrameMoneyFrame"]
money:SetFrameStrata("DIALOG")
money:ClearAllPoints()
money:SetPoint("BOTTOMRIGHT", bankholder, "BOTTOMRIGHT", 12, 2)

--[[ Misc. frames ]]

_G["BankFramePurchaseInfo"]:Hide()
_G["BankFramePurchaseInfo"].Show = R.dummy

local BankBagButtons = {
	BankFrameBag1, 
	BankFrameBag2, 
	BankFrameBag3, 
	BankFrameBag4, 
	BankFrameBag5, 
	BankFrameBag6, 
	BankFrameBag7,
}

local BagButtons = {
	MainMenuBarBackpackButton,
	CharacterBag0Slot, 
	CharacterBag1Slot, 
	CharacterBag2Slot, 
	CharacterBag3Slot, 
}

local bankbagholder = CreateFrame("Frame", nil, BankFrame)
bankbagholder:SetSize(289, 43)
bankbagholder:SetPoint("BOTTOM", bankholder, "TOP", 0, -1)
R.CreateBD(bankbagholder, .6)
bankbagholder:SetAlpha(0)

bankbagholder:SetScript("OnEnter", function(self)
	self:SetAlpha(1)
	for _, g in pairs(BankBagButtons) do
		g:SetAlpha(1)
	end
end)
bankbagholder:SetScript("OnLeave", function(self)
	self:SetAlpha(0)
	for _, g in pairs(BankBagButtons) do
		g:SetAlpha(0)
	end
end)

local bagholder = CreateFrame("Frame", nil, ContainerFrame1)
bagholder:SetSize(130, 35)
bagholder:SetPoint("BOTTOM", holder, "TOP", 0, -1)

bagholder:SetScript("OnEnter", function(self)
	for _, g in pairs(BagButtons) do
		g:SetAlpha(1)
	end
end)
bagholder:SetScript("OnLeave", function(self)
	for _, g in pairs(BagButtons) do
		g:SetAlpha(0)
	end
end)

for i = 1, 7 do
	local bag = _G["BankFrameBag"..i]
	local ic = _G["BankFrameBag"..i.."IconTexture"]
	_G["BankFrameBag"..i.."HighlightFrame"]:Hide()

	bag:SetParent(bankholder)
	bag:ClearAllPoints()

	if i == 1 then
		bag:SetPoint("BOTTOM", bankholder, "TOP", -123, 2)
	else
		bag:SetPoint("LEFT", _G["BankFrameBag"..i-1], "RIGHT", 4, 0)
	end

	bag:SetNormalTexture("")
	bag:SetPushedTexture("")

	ic:SetTexCoord(.08, .92, .08, .92)
	
	bag:SetAlpha(0)
	bag:HookScript("OnEnter", function(self)
		bankbagholder:SetAlpha(1)
		for _, g in pairs(BankBagButtons) do
			g:SetAlpha(1)
		end
	end)
	bag:HookScript("OnLeave", function(self)
		bankbagholder:SetAlpha(0)
		for _, g in pairs(BankBagButtons) do
			g:SetAlpha(0)
		end
	end)
end

for i = 0, 3 do
	local bag = _G["CharacterBag"..i.."Slot"]
	local ic = _G["CharacterBag"..i.."SlotIconTexture"]

	bag:SetParent(holder)
	bag:ClearAllPoints()

	if i == 0 then
		bag:SetPoint("BOTTOM", holder, "TOP", -66, 3)
	else
		bag:SetPoint("LEFT", _G["CharacterBag"..(i-1).."Slot"], "RIGHT", 1, 0)
	end

	bag:SetNormalTexture("")
	bag:SetCheckedTexture("")
	bag:SetPushedTexture("")

	ic:SetTexCoord(.08, .92, .08, .92)
	ic:SetPoint("TOPLEFT", 1, -1)
	ic:SetPoint("BOTTOMRIGHT", -1, 1)
	R.CreateBD(bag)

	bag:SetAlpha(0)
	bag:HookScript("OnEnter", function(self)
		for _, g in pairs(BagButtons) do
			g:SetAlpha(1)
		end
	 end)
	bag:HookScript("OnLeave", function(self)
		for _, g in pairs(BagButtons) do
			g:SetAlpha(0)
		end
	end)
end
MainMenuBarBackpackButton:SetParent(holder)
MainMenuBarBackpackButton:ClearAllPoints()
MainMenuBarBackpackButton:SetPoint("BOTTOMLEFT", CharacterBag3Slot, "BOTTOMRIGHT", 1, 0)
MainMenuBarBackpackButton:SetAlpha(0)
MainMenuBarBackpackButton:SetNormalTexture("")
MainMenuBarBackpackButton:SetCheckedTexture("")
MainMenuBarBackpackButton:SetPushedTexture("")
MainMenuBarBackpackButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
MainMenuBarBackpackButtonIconTexture:SetPoint("TOPLEFT", 1, -1)
MainMenuBarBackpackButtonIconTexture:SetPoint("BOTTOMRIGHT", -1, 1)
R.CreateBD(MainMenuBarBackpackButton)
MainMenuBarBackpackButton:HookScript("OnEnter", function(self)
	for _, g in pairs(BagButtons) do
		g:SetAlpha(1)
	end
 end)
MainMenuBarBackpackButton:HookScript("OnLeave", function(self)
	for _, g in pairs(BagButtons) do
		g:SetAlpha(0)
	end
end)

local moneytext = {"ContainerFrame1MoneyFrameGoldButtonText", "ContainerFrame1MoneyFrameSilverButtonText", "ContainerFrame1MoneyFrameCopperButtonText", "BankFrameMoneyFrameGoldButtonText", "BankFrameMoneyFrameSilverButtonText", "BankFrameMoneyFrameCopperButtonText", "BackpackTokenFrameToken1Count", "BackpackTokenFrameToken2Count", "BackpackTokenFrameToken3Count"}

for i = 1, 9 do
	_G[moneytext[i]]:SetFont(C.media.font, C.media.fontsize, C.media.fontflag)
end

--[[ Show & Hide functions etc ]]

tinsert(UISpecialFrames, bankholder)
tinsert(UISpecialFrames, holder)

local CloseBags = function()
	bankholder:Hide()
	holder:Hide()
	for i = 0, 11 do
		CloseBag(i)
	end
end

local CloseBags2 = function()
	bankholder:Hide()
	holder:Hide()
	CloseBankFrame()
end

local OpenBags = function()
	for i = 0, 11 do
		OpenBag(i)
	end
end

local ToggleBags = function()
	if(IsBagOpen(0)) then
		CloseBankFrame()
		CloseBags()
	else
		OpenBags()
	end
end

for i = 1, 5 do
	local bag = _G["ContainerFrame"..i]
	hooksecurefunc(bag, "Show", ReanchorButtons)
	hooksecurefunc(bag, "Hide", CloseBags2)
	bag.SetScale = R.dummy
end
hooksecurefunc(BankFrame, "Show", function()
	OpenBags()
	ReanchorBankButtons()
end)
hooksecurefunc(BankFrame, "Hide", CloseBags)

ToggleBackpack = ToggleBags
OpenAllBags = OpenBags
OpenBackpack = OpenBags
CloseAllBags = CloseBags

-- [[ Currency ]]

BackpackTokenFrame:GetRegions():Hide()
BackpackTokenFrameToken1:ClearAllPoints()
BackpackTokenFrameToken1:SetPoint("BOTTOMLEFT", holder, "BOTTOMLEFT", 80, 2)
for i = 1, 3 do
	local bu = _G["BackpackTokenFrameToken"..i]
	local ic = _G["BackpackTokenFrameToken"..i.."Icon"]
	_G["BackpackTokenFrameToken"..i.."Count"]:SetShadowOffset(0, 0)

	bu:SetFrameStrata("DIALOG")
	ic:SetDrawLayer("OVERLAY")
	ic:SetTexCoord(.08, .92, .08, .92)

	R.CreateBG(ic)
end

-- [[ Search ]]

editbox = CreateFrame("EditBox", nil, holder)
editbox:SetHeight(13)
editbox:SetPoint("TOPLEFT", holder, "BOTTOMLEFT", 0, -5)
editbox:SetPoint("TOPRIGHT", holder, "BOTTOMRIGHT", 0, -5)
editbox:SetAutoFocus(false)
editbox:SetFont(C.media.font, C.media.fontsize, C.media.fontflag)
editbox:SetText(L["点击查找..."])
editbox:SetJustifyH("CENTER")
R.CreateBD(editbox, .6)
R.CreateSD(editbox)
editbox:SetAlpha(0)

local SearchUpdate = function(str, table)
	str = string.lower(str)

	for _, b in ipairs(table) do
		if b:GetParent() == BankFrame then
			b.id = GetContainerItemID(-1, b:GetID())
		else
			b.id = GetContainerItemID(b:GetParent():GetID(), b:GetID())
		end
		if b.id then
			 b.name, _, _, _, _, _, _, _, b.slot = GetItemInfo(b.id)
			if b.slot then b.slot = _G[b.slot] end
		end
		if not b.name then
			b:SetAlpha(.2)
			b.glow:SetAlpha(0)
		elseif not string.find(string.lower(b.name), str, 1, true) and not (b.slot and string.find(string.lower(b.slot), str)) then
			SetItemButtonDesaturated(b, 1, 1, 1, 1)
			b:SetAlpha(.2)
			b.glow:SetAlpha(0)
		else
			SetItemButtonDesaturated(b, 0, 1, 1, 1)
			b:SetAlpha(1)
			b.glow:SetAlpha(1)
		end
	end
end

local HideSearch = function()
	editbox:SetAlpha(0)
end

local Reset = function(self)
	self:ClearFocus()
	for _, b in ipairs(buttons) do
		b:SetAlpha(1)
		b.glow:SetAlpha(1)
		SetItemButtonDesaturated(b, 0, 1, 1, 1)
	end
	for _, b in ipairs(bankbuttons) do
		b:SetAlpha(1)
		b.glow:SetAlpha(1)
		SetItemButtonDesaturated(b, 0, 1, 1, 1)
	end
	self:SetAlpha(0)
	self:SetScript("OnLeave", HideSearch)
	self:SetText(L["点击查找..."])
end

local text

local UpdateSearch = function(self, t)
	if t == true then
		text = self:GetText()
		SearchUpdate(text, buttons)
		if BankFrame:IsShown() then SearchUpdate(text, bankbuttons) end
	end
end

editbox:SetScript("OnEscapePressed", Reset)
editbox:SetScript("OnEnterPressed", Reset)
editbox:SetScript("OnTextChanged", UpdateSearch)
editbox:SetScript("OnEditFocusGained", function(self)
	self:HighlightText()
	self:SetScript("OnLeave", nil)
end)

editbox:SetScript("OnEnter", function(self)
	self:SetAlpha(1)
end)
editbox:SetScript("OnLeave", HideSearch)

-- Jpack Button --
local JpackButton = CreateFrame("Button", nil, holder)
JpackButton:SetWidth(70)
JpackButton:SetHeight(15)
JpackButton:SetPoint("BOTTOMLEFT", 3, 2)
JpackButton:SetScript("OnMouseUp", function(self, btn)
		if(btn=="RightButton") then
			JPack:Pack(nil, 1)
		elseif(btn=="LeftButton") then
			JPack:Pack(nil, 2)
		end
	end)
JpackButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT", -10, 0)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L["左键点击逆序整理，右键点击正序整理"])
		GameTooltip:Show()
	end)
JpackButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
R.Reskin(JpackButton)
local JpackButtonText = JpackButton:CreateFontString(nil, "OVERLAY")
JpackButtonText:SetPoint("CENTER", JpackButton)
JpackButtonText:SetFontObject(GameFontNormalSmall)
JpackButtonText:SetFont(C.media.font, C.media.fontsize)
JpackButtonText:SetText(L["整理背包"])

holder:SetMovable(true)
holder:RegisterForDrag("LeftButton")
holder:SetScript("OnDragStart", function(self) self:StartMoving() end)
holder:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
		
for i = 0, 3 do
	_G["CharacterBag"..i.."Slot"]:HookScript("OnEnter", function(self)
		for _, b in ipairs(buttons) do
			if b:GetParent():GetID() == i then
				SetItemButtonDesaturated(b, 0, 1, 1, 1)
				b:SetAlpha(1)
				b.glow:SetAlpha(1)
			else
				SetItemButtonDesaturated(b, 1, 1, 1, 1)
				b:SetAlpha(.2)
				b.glow:SetAlpha(0)
			end
		end
	end)
	_G["CharacterBag"..i.."Slot"]:HookScript("OnLeave", function(self)
		for _, b in ipairs(buttons) do
			SetItemButtonDesaturated(b, 0, 1, 1, 1)
			b:SetAlpha(1)
			b.glow:SetAlpha(1)
		end
	end)
	_G["CharacterBag"..i.."Slot"]:SetScript("OnClick", nil)
end
for i = 1, 7 do
	_G["BankFrameBag"..i]:SetScript("OnClick", function()
		local slot, full = GetNumBankSlots()
		if (slot + 1) <= i then
			StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
		end
	end)
end
MainMenuBarBackpackButton:HookScript("OnEnter", function(self)
	for _, b in ipairs(buttons) do
		if b:GetParent():GetID() == 4 then
			SetItemButtonDesaturated(b, 0, 1, 1, 1)
			b:SetAlpha(1)
			b.glow:SetAlpha(1)
		else
			SetItemButtonDesaturated(b, 1, 1, 1, 1)
			b:SetAlpha(.2)
			b.glow:SetAlpha(0)
		end
	end
end)
MainMenuBarBackpackButton:HookScript("OnLeave", function(self)
	for _, b in ipairs(buttons) do
		SetItemButtonDesaturated(b, 0, 1, 1, 1)
		b:SetAlpha(1)
		b.glow:SetAlpha(1)
	end
end)
TradeFrame:HookScript("OnShow", function() OpenBags() end)
TradeFrame:HookScript("OnHide", function() CloseBags() end)