local addon, ns = ...
local cargBags = ns.cargBags

local m_Bags = cargBags:NewImplementation("m_Bags")	-- Let the magic begin!
m_Bags:RegisterBlizzard() -- register the frame for use with BLizzard's ToggleBag()-functions
--local m_Bags = cargBags:GetImplementation("m_Bags")

-- A highlight function styles the button if they match a certain condition
local function highlightFunction(button, match)
	button:SetAlpha(match and 1 or 0.1)
end

local f = {}
function m_Bags:OnInit()
	-- The filters control which items go into which container
	local INVERTED = -1 -- with inverted filters (using -1), everything goes into this bag when the filter returns false

	local onlyBags =		function(item) return item.bagID >= 0 and item.bagID <= 4 and not cargBags.itemKeys["setID"](item) end
	local onlySets =		function(item) return cargBags.itemKeys["setID"](item) end
	local onlyBank =		function(item) return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11 end
	local onlyRareEpics =	function(item) return item.rarity and item.rarity > 3 end
	local onlyEpics =		function(item) return item.rarity and item.rarity > 3 end
	local hideJunk =		function(item) return not item.rarity or item.rarity > 0 end
	local hideEmpty =		function(item) return item.texture ~= nil end

	local MyContainer = m_Bags:GetContainerClass()
	
	-- Bagpack
	f.main = MyContainer:New("Main", {
			Columns = 10,
			Scale = 1,
			Bags = "backpack+bags",
			Movable = true,
	})
	f.main:SetFilter(onlyBags, true)
	f.main:SetPoint("BOTTOMRIGHT", -20*f.main.Settings.Scale, 215*f.main.Settings.Scale) -- bagpack position

	-- Bank frame and bank bags
	f.bank = MyContainer:New("Bank", {
			Columns = 12,
			Scale = f.main.Settings.Scale,
			Bags = "bankframe+bank",
	})
	f.bank:SetFilter(onlyBank, true) -- Take only items from the bank frame
	f.bank:SetPoint("BOTTOMRIGHT", f.main,"BOTTOMLEFT", -25*f.main.Settings.Scale, 0) -- bank frame position
	f.bank:Hide() -- Hide at the beginning
	
	f.sets = MyContainer:New("ItemSets", {Columns = 10, Scale = 1, Bags = "backpack+bags"})
	f.sets:SetFilter(onlySets, true)
	f.sets:SetPoint("BOTTOMLEFT", f.main,"TOPLEFT", 0, 5*f.main.Settings.Scale)
end

-- Bank frame toggling
function m_Bags:OnBankOpened()
	self:GetContainer("Bank"):Show()
end

function m_Bags:OnBankClosed()
	self:GetContainer("Bank"):Hide()
end

-- Class: ItemButton appearencence classification
local MyButton = m_Bags:GetItemButtonClass()
MyButton:Scaffold("Default")
function MyButton:OnUpdate(item)
	-- color the border based on bag type
	local bagType = (select(2, GetContainerNumFreeSlots(self.bagID)));
	-- ammo / soulshards
	if(bagType and (bagType > 0 and bagType < 8)) then
		self.Border:SetVertexColor(0.85, 0.85, 0.35, 1);
	-- profession bags
	elseif(bagType and bagType > 4) then
		self.Border:SetVertexColor(0.1, 0.65, 0.1, 1);
	-- normal bags
	else
		self.Border:SetVertexColor(.7, .7, .7, .9);
	end
	-- _G[self:GetName().."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
end

--	Class: BagButton is the template for all buttons on the BagBar
local BagButton = m_Bags:GetClass("BagButton", true, "BagButton")
-- We color the CheckedTexture golden, not bright yellow
function BagButton:OnCreate()
	self:GetCheckedTexture():SetVertexColor(0.3, 0.9, 0.9, 0.5)
end

-- Class: Container (Serves as a base for all containers/bags)
-- Fetch our container class that serves as a basis for all our containers/bags

local UpdateDimensions = function(self)
	local width, height = self:LayoutButtons("grid", self.Settings.Columns, 3, 6, -5)
	--local width, height = self:GetWidth(), self:GetHeight()
	local margin = 40			-- Normal margin space for infobar
	if self.BagBar and self.BagBar:IsShown() then
		margin = margin + 40	-- Bag button space
	end
	self:SetHeight(height + margin)
end

local MyContainer = m_Bags:GetContainerClass()
function MyContainer:OnContentsChanged()
	-- sort our buttons based on the slotID
	self:SortButtons("bagSlot")
	-- Order the buttons in a layout, ("grid", columns, spacing, xOffset, yOffset) or ("circle", radius (optional), xOffset, yOffset)
	local width, height = self:LayoutButtons("grid", self.Settings.Columns, 3, 6, -5)
	self:SetSize(width + 12, height + 12)
	if (self.UpdateDimensions) then self:UpdateDimensions() end -- Update the bag's height
	if self.name == "ItemSets" then
		local width, height = self:LayoutButtons("grid", self.Settings.Columns, 3, 6, -25)
		self:SetSize(width + 12, height + 32)
	end
	
	if m_BagsItemSets:GetHeight()<33 then -- dirty.... but works so whatever
		f.sets:Hide()
	else
		f.sets:Show()
	end 
end

-- OnCreate is called every time a new container is created 
function MyContainer:OnCreate(name, settings)
	settings = settings or {}
    self.Settings = settings
	self.UpdateDimensions = UpdateDimensions
	
	self:EnableMouse(true)

	self:SetBackdrop{
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 10, edgeSize = 8,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	}
	self:SetBackdropColor(0, 0, 0, 0.9)
	self:SetBackdropBorderColor(0, 0, 0, 0.8)

	self:SetParent(settings.Parent or m_Bags)
	self:SetFrameStrata("HIGH")

	if(settings.Movable) then
		self:SetMovable(true)
		self:RegisterForClicks("LeftButton", "RightButton");
	    self:SetScript("OnMouseDown", function()
		self:ClearAllPoints() 
		self:StartMoving()
	    end)
		self:SetScript("OnMouseUp",  self.StopMovingOrSizing)
	end

	settings.Columns = settings.Columns or 10
	self:SetScale(settings.Scale or 1)
	
	if not (name == "ItemSets") then -- don't need all that junk on "other" sections
		-- Creating infoFrame which serves as a basic bar for information and extra buttons
		local infoFrame = CreateFrame("Button", nil, self)
		infoFrame:SetPoint("BOTTOMLEFT", 60, 0)
		infoFrame:SetWidth(220)
		infoFrame:SetHeight(32)

		-- Plugin: TagDisplay
		-- This one shows currencies, ammo and - most important - money!
		local tagDisplay = self:SpawnPlugin("TagDisplay", "[money]", infoFrame)
		tagDisplay:SetFontObject("NumberFontNormal")
		tagDisplay:SetFont("Fonts\\ZYKai_T.ttf", 14)
		tagDisplay:SetPoint("RIGHT", infoFrame,"RIGHT",0,0)
		
		-- Plugin: BagBar
		local bagBar = self:SpawnPlugin("BagBar", settings.Bags)
		bagBar:SetSize(bagBar:LayoutButtons("grid", 7))
		bagBar:SetScale(0.75)
		bagBar.highlightFunction = highlightFunction -- from above, optional, used when hovering over bag buttons
		bagBar.isGlobal = true -- This would make the hover-effect apply to all containers instead of the current one
		bagBar:Hide()
		self.BagBar = bagBar
		
		-- positioning our BagBar
		bagBar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 10, 46)
		
		-- Plugin: SearchBar
		local searchText = infoFrame:CreateFontString(nil, "OVERLAY")
		searchText:SetPoint("LEFT", infoFrame, "LEFT", 0, 0)
		searchText:SetFont("Fonts\\ZYKai_T.ttf", 14)
		searchText:SetText("搜索") -- our searchbar comes up when we click on infoFrame

		local search = self:SpawnPlugin("SearchBar", infoFrame)
		search.highlightFunction = highlightFunction -- same as above, only for search
		search.isGlobal = true -- This would make the search apply to all containers instead of just this one
		search:SetPoint("LEFT", infoFrame,"LEFT", 0, 0)
		
		-- creating button for toggling BagBar on and off
		self:UpdateDimensions()
		local bagToggle = CreateFrame("CheckButton", nil, self)
		bagToggle:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
		bagToggle:SetWidth(40)
		bagToggle:SetHeight(20)
		bagToggle:SetPoint("BOTTOMLEFT",3,7)
		bagToggle:SetScript("OnClick", function()
			if(self.BagBar:IsShown()) then
				self.BagBar:Hide()
			else
				self.BagBar:Show()
			end
				self:UpdateDimensions()
		end)
		local bagToggleText = bagToggle:CreateFontString(nil, "OVERLAY")
		bagToggleText:SetPoint("CENTER", bagToggle)
		bagToggleText:SetFontObject(GameFontNormalSmall)
		bagToggleText:SetFont("Fonts\\ZYKai_T.TTF", 14)
		bagToggleText:SetText("背包")
		
		-- Jpack Button --
		local JpackButton = CreateFrame("Button", nil, self)
		JpackButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
		JpackButton:SetWidth(70)
		JpackButton:SetHeight(20)
		JpackButton:SetPoint("BOTTOMRIGHT",-40,8)
		JpackButton:SetScript("OnClick", function() JPack:Pack() end)
		local JpackButtonText = JpackButton:CreateFontString(nil, "OVERLAY")
		JpackButtonText:SetPoint("CENTER", JpackButton)
		JpackButtonText:SetFontObject(GameFontNormalSmall)
		JpackButtonText:SetFont("Fonts\\ZYKai_T.TTF", 14)
		JpackButtonText:SetText("整理背包")

		-- CloseButton --
		local closebutton = CreateFrame("Button", nil, self)
		closebutton:SetFrameLevel(30)
		closebutton:SetPoint("BOTTOMRIGHT", -5, 9)
		closebutton:SetSize(20,14)
		
		local closebtex =	"Interface\\AddOns\\m_Bags\\media\\black-close"
		local close = closebutton:CreateTexture(nil, "ARTWORK")
		close:SetTexture(closebtex)
		close:SetTexCoord(0, .7, 0, 1)
		close:SetAllPoints(closebutton)
		close:SetVertexColor(0.5, 0.5, 0.4)
	
		closebutton:SetScript( "OnLeave", function() close:SetVertexColor(0.5, 0.5, 0.4) end )
		closebutton:SetScript( "OnEnter", function() close:SetVertexColor(0.7, 0.2, 0.2) end )
		closebutton:SetScript( "OnClick", function(self) 
			if m_Bags:AtBank() and self.name == "Bank" then 
				CloseBankFrame() 
			else 
				CloseAllBags() 
			end 
		end)
		
 	elseif name == "ItemSets" then
		setname = self:CreateFontString(nil,"OVERLAY")
		setname:SetPoint("TOPLEFT", self, "TOPLEFT",5,-5)
		setname:SetFont("Fonts\\ZYKai_T.TTF", 14, "THINOUTLINE")
		setname:SetText(string.format(EQUIPMENT_SETS,' ')) 
	end
end

