------------------------------------------------------
-- MEDIA & CONFIG ------------------------------------
------------------------------------------------------
local R, C = unpack(RayUI)
local font = { C["media"].font, 13, "THINOUTLINE" }
------------------------------------------------------
-- INITIAL FRAME CREATION ----------------------------
------------------------------------------------------
stAddonManager = CreateFrame("Frame", "stAddonManager", UIParent)
stAddonManager:SetFrameStrata("HIGH")
stAddonManager.header = CreateFrame("Frame", "stAddonmanager_Header", stAddonManager)

stAddonManager.header:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
stAddonManager:SetPoint("TOP", stAddonManager.header, "TOP", 0, 0)

------------------------------------------------------
-- FUNCTIONS -----------------------------------------
------------------------------------------------------
function stAddonManager:UpdateAddonList(queryString)
	local addons = {}
	for i=1, GetNumAddOns() do
		local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
		local lwrTitle, lwrName = strlower(title), strlower(name)
		if (queryString and (strfind(lwrTitle,strlower(queryString)) or strfind(lwrName,strlower(queryString)))) or (not queryString) then
			addons[i] = {}
			addons[i].name = name
			addons[i].title = title
			addons[i].notes = notes
			addons[i].enabled = enabled
		end
	end
	return addons
end

local function LoadWindow()
	if not stAddonManager.Loaded then
		local window = stAddonManager
		local header = window.header
		
		tinsert(UISpecialFrames,window:GetName());
		
		window:SetSize(400,350)
		header:SetSize(400,20)
		
		R.CreateBD(window)
		R.CreateSD(window)
		R.CreateBD(header)
		
		header:EnableMouse(true)
		header:SetMovable(true)
		header:SetScript("OnMouseDown", function(self) self:StartMoving() end)
		header:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
		
		local hTitle = stAddonManager.header:CreateFontString(nil, "OVERLAY")
		hTitle:SetFont(unpack(font))
		hTitle:SetPoint("CENTER")
		hTitle:SetText("|cff00aaffst|rAddonManager")
		header.title = hTitle 

		local close = CreateFrame("Button", nil, header)
		close:SetPoint("RIGHT", header, "RIGHT", 0, 0)
		close:SetFrameLevel(header:GetFrameLevel()+2)
		close:SetSize(20, 20)
		close.text = close:CreateFontString(nil, "OVERLAY")
		close.text:SetFont(unpack(font))
		close.text:SetText("x")
		close.text:SetPoint("CENTER", close, "CENTER", 0, 0)
		close:SetScript("OnEnter", function(self) self.text:SetTextColor(0/255, 170/255, 255/255) end)
		close:SetScript("OnLeave", function(self) self.text:SetTextColor(255/255, 255/255, 255/255) end)
		close:SetScript("OnClick", function() window:Hide() end)
		header.close = close
		
		addonListBG = CreateFrame("Frame", window:GetName().."_ScrollBackground", window)
		addonListBG:SetPoint("TOPLEFT", header, "TOPLEFT", 10, -50)
		addonListBG:SetWidth(window:GetWidth()-20)
		addonListBG:SetHeight(window:GetHeight()-60)
		R.CreateBD(addonListBG)
		
		--Create scroll frame (God damn these things are a pain)
		local scrollFrame = CreateFrame("ScrollFrame", window:GetName().."_ScrollFrame", window, "UIPanelScrollFrameTemplate")
		scrollFrame:SetPoint("TOPLEFT", addonListBG, "TOPLEFT", 0, -2)
		scrollFrame:SetWidth(addonListBG:GetWidth()-25)
		scrollFrame:SetHeight(addonListBG:GetHeight()-5)
		R.ReskinScroll(_G[window:GetName().."_ScrollFrameScrollBar"])
		scrollFrame:SetFrameLevel(window:GetFrameLevel()+1)
		
		scrollFrame.Anchor = CreateFrame("Frame", window:GetName().."_ScrollAnchor", scrollFrame)
		scrollFrame.Anchor:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, -3)
		scrollFrame.Anchor:SetWidth(window:GetWidth()-40)
		scrollFrame.Anchor:SetHeight(scrollFrame:GetHeight())
		scrollFrame.Anchor:SetFrameLevel(scrollFrame:GetFrameLevel()+1)
		scrollFrame:SetScrollChild(scrollFrame.Anchor)
	
		--Load up addon information
		stAddonManager.AllAddons = stAddonManager:UpdateAddonList()
		stAddonManager.FilteredAddons = stAddonManager:UpdateAddonList()
		stAddonManager.showEnabled = true
		stAddonManager.showDisabled = true
		
		stAddonManager.Buttons = {}
		
		--Create initial list
		for i, addon in pairs(stAddonManager.AllAddons) do
			local button = CreateFrame("Frame", nil, scrollFrame.Anchor)
			button:SetFrameLevel(scrollFrame.Anchor:GetFrameLevel() + 1)
			button:SetSize(16, 16)
			R.CreateBD(button)
			if addon.enabled then
				button:SetBackdropColor(0/255, 170/255, 255/255)
			end
			
			if i == 1 then
				button:SetPoint("TOPLEFT", scrollFrame.Anchor, "TOPLEFT", 5, -5)
			else
				button:SetPoint("TOP", stAddonManager.Buttons[i-1], "BOTTOM", 0, -5)
			end
			button.text = button:CreateFontString(nil, "OVERLAY")
			button.text:SetFont(unpack(font))
			button.text:SetJustifyH("LEFT")
			button.text:SetPoint("LEFT", button, "RIGHT", 8, 0)
			button.text:SetPoint("RIGHT", scrollFrame.Anchor, "RIGHT", 0, 0)
			button.text:SetText(addon.title)
			
			button:SetScript("OnEnter", function(self)
				--tooltip stuff
			end)
			
			button:SetScript("OnMouseDown", function(self)
				if addon.enabled then
					self:SetBackdropColor(unpack(C["media"].backdropcolor))
					DisableAddOn(addon.name)
					addon.enabled = false
				else
					self:SetBackdropColor(0/255, 170/255, 255/255)
					EnableAddOn(addon.name)
					addon.enabled = true
				end
			end)
			
			stAddonManager.Buttons[i] = button
		end
		
		local function UpdateList(AddonsTable)
			--Start off by hiding all of the buttons
			for _, b in pairs(stAddonManager.Buttons) do b:Hide() end
			
			local bIndex = 1
			for i, addon in pairs(AddonsTable) do
				local button = stAddonManager.Buttons[bIndex]
				button:Show()
				if addon.enabled then
					button:SetBackdropColor(0/255, 170/255, 255/255)
				else
					button:SetBackdropColor(unpack(C["media"].backdropcolor))
				end
				
				button:SetScript("OnMouseDown", function(self)
					if addon.enabled then
						self:SetBackdropColor(unpack(C["media"].backdropcolor))
						DisableAddOn(addon.name)
						addon.enabled = false
					else
						self:SetBackdropColor(0/255, 170/255, 255/255)
						EnableAddOn(addon.name)
						addon.enabled = true
					end
				end)
				
				button.text:SetText(addon.title)
				bIndex = bIndex+1
			end
		end
		
		--Search Bar
		local searchBar = CreateFrame("EditBox", window:GetName().."_SearchBar", window)
		searchBar:SetFrameLevel(window:GetFrameLevel()+1)
		searchBar:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 10, -5)
		searchBar:SetWidth(300)
		searchBar:SetHeight(20)
		R.CreateBD(searchBar)
		searchBar:SetFont(unpack(font))
		searchBar:SetText("Search")
		searchBar:SetAutoFocus(false)
		searchBar:SetTextInsets(3, 0, 0 ,0)
		searchBar:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
		searchBar:SetScript("OnEscapePressed", function(self) searchBar:SetText("Search") UpdateList(stAddonManager.AllAddons) searchBar:ClearFocus() end)
		searchBar:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
		searchBar:SetScript("OnTextChanged", function(self, input)
			if input then
				stAddonManager.FilteredAddons = stAddonManager:UpdateAddonList(self:GetText())
				UpdateList(stAddonManager.FilteredAddons)
			end
		end)
		
		local sbClear = CreateFrame("Button", nil, searchBar)
		sbClear:SetPoint("RIGHT", searchBar, "RIGHT", 0, 0)
		sbClear:SetFrameLevel(searchBar:GetFrameLevel()+2)
		sbClear:SetSize(20, 20)
		sbClear.text = sbClear:CreateFontString(nil, "OVERLAY")
		sbClear.text:SetFont(unpack(font))
		sbClear.text:SetText("x")
		sbClear.text:SetPoint("CENTER", sbClear, "CENTER", 0, 0)
		sbClear:SetScript("OnEnter", function(self) self.text:SetTextColor(0/255, 170/255, 255/255) end)
		sbClear:SetScript("OnLeave", function(self) self.text:SetTextColor(255/255, 255/255, 255/255) end)
		sbClear:SetScript("OnClick", function(self) searchBar:SetText("Search") UpdateList(stAddonManager.AllAddons) searchBar:ClearFocus() end)
		searchBar.clear = sbClear

		local reloadButton = CreateFrame("Button", window:GetName().."_ReloadUIButton", window)
		reloadButton:SetPoint("LEFT", searchBar, "RIGHT", 5, 0)
		reloadButton:SetWidth(window:GetWidth()-25-searchBar:GetWidth())
		reloadButton:SetHeight(searchBar:GetHeight())
		reloadButton.text = reloadButton:CreateFontString(nil, "OVERLAY")
		reloadButton.text:SetPoint("CENTER")
		reloadButton.text:SetFont(unpack(font))
		reloadButton.text:SetText("ReloadUI")
		reloadButton:SetScript("OnEnter", function(self) self.text:SetTextColor(0/255, 170/255, 255/255) end)
		reloadButton:SetScript("OnLeave", function(self) self.text:SetTextColor(255/255, 255/255, 255/255) end)
		reloadButton:SetScript("OnClick", function(self)
			if InCombatLockdown() then return end
			ReloadUI()
		end)
		R.CreateBD(reloadButton)
		
		stAddonManager.Loaded = true
	else
		stAddonManager:Show()
	end
end

SLASH_STADDONMANAGER1, SLASH_STADDONMANAGER2, SLASH_STADDONMANAGER3 = "/staddonmanager", "/stam", "/staddon"
SlashCmdList["STADDONMANAGER"] = LoadWindow

local gmbAddOns = CreateFrame("Button", "GameMenuButtonAddOns", GameMenuFrame, "GameMenuButtonTemplate")
gmbAddOns:SetSize(GameMenuButtonMacros:GetWidth(), GameMenuButtonMacros:GetHeight())
GameMenuFrame:SetHeight(GameMenuFrame:GetHeight()+GameMenuButtonMacros:GetHeight());
GameMenuButtonLogout:SetPoint("TOP", gmbAddOns, "BOTTOM", 0, -2)
gmbAddOns:SetPoint("TOP", GameMenuButtonMacros, "BOTTOM", 0, -2)
gmbAddOns:SetText("|cff00aaffst|rAddonManager")
gmbAddOns:SetScript("OnClick", function()
	HideUIPanel(GameMenuFrame);
	LoadWindow()
end)

R.Reskin(gmbAddOns)
local font = {GameMenuButtonMacros:GetFontString():GetFont()}
local shadow = {GameMenuButtonMacros:GetFontString():GetShadowOffset()}
gmbAddOns:GetFontString():SetFont(unpack(font))
gmbAddOns:GetFontString():SetShadowOffset(unpack(shadow))