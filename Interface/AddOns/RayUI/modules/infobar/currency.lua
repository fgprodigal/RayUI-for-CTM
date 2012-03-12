local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local IF = R:GetModule("InfoBar")

local function LoadCurrency()
	local infobar = _G["RayUITopInfoBar7"]
	local Status = infobar.Status
	infobar.Text:SetText(CURRENCY)
	Status:SetValue(0)

	RayUIData.Class = RayUIData.Class or {}
	RayUIData.Class[R.myrealm] = RayUIData.Class[R.myrealm] or {}
	RayUIData.Class[R.myrealm][R.myname] = R.myclass
	RayUIData.Gold = RayUIData.Gold or {}
	RayUIData.Gold[R.myrealm] = RayUIData.Gold[R.myrealm] or {}

	local function formatMoney(money, icon)
		local gold = floor(math.abs(money) / 10000)
		local silver = mod(floor(math.abs(money) / 100), 100)
		local copper = mod(floor(math.abs(money)), 100)
		if gold ~= 0 then
			if icon then
				return format(GOLD_AMOUNT_TEXTURE.." "..SILVER_AMOUNT_TEXTURE.." "..COPPER_AMOUNT_TEXTURE, gold, 0, 0, silver, 0, 0, copper, 0, 0)
			else
				return format("%s".."|cffffd700g|r".." %s".."|cffc7c7cfs|r".." %s".."|cffeda55fc|r", gold, silver, copper)
			end
		elseif silver ~= 0 then
			if icon then
				return format(SILVER_AMOUNT_TEXTURE.." "..COPPER_AMOUNT_TEXTURE, silver, 0, 0, copper, 0, 0)
			else
				return format("%s".."|cffc7c7cfs|r".." %s".."|cffeda55fc|r", silver, copper)
			end
		else
			if icon then
				return format(COPPER_AMOUNT_TEXTURE, copper, 0, 0)
			else
				return format("%s".."|cffeda55fc|r", copper)
			end
		end
	end

	local function ShowMoney(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		local total = 0
		local realmlist = RayUIData.Gold[R.myrealm]
		for k, v in pairs(realmlist) do
			total = total + v
		end
		GameTooltip:AddDoubleLine(R.myrealm, formatMoney(total, true), nil, nil, nil, 1, 1, 1)
		GameTooltip:AddLine(" ")
		for k, v in pairs(realmlist) do
			local class = RayUIData.Class[R.myrealm][k]
			if v >= 10000 then
				GameTooltip:AddDoubleLine(k, formatMoney(v, true), RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b, 1, 1, 1)
			end
		end
		GameTooltip:Show()
	end

	local function OnEvent(self, event)
		if event == "PLAYER_HONOR_GAIN" then
			updateCurrency()
		else
			local money	= GetMoney()		
			infobar.Text:SetText(formatMoney(money))
			self:SetAllPoints(infobar)		
			RayUIData.Gold[R.myrealm][R.myname] = money
			
			local total = 0
			local realmlist = RayUIData.Gold[R.myrealm]
			for k, v in pairs(realmlist) do
				total = total + v
			end
			if total > 0 then
				Status:SetMinMaxValues(0, total)
				Status:SetValue(money)
				Status:SetStatusBarColor(unpack(IF.InfoBarStatusColor[3]))
			end
		end
	end

	Status:RegisterEvent("PLAYER_MONEY")
	Status:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
	Status:RegisterEvent("SEND_MAIL_COD_CHANGED")
	Status:RegisterEvent("PLAYER_TRADE_MONEY")
	Status:RegisterEvent("TRADE_MONEY_CHANGED")
	Status:RegisterEvent("PLAYER_ENTERING_WORLD")
	Status:RegisterEvent("PLAYER_HONOR_GAIN")
	Status:SetScript("OnEnter", ShowMoney)
	Status:SetScript("OnLeave", GameTooltip_Hide)
	Status:SetScript("OnEvent", OnEvent)

	-- CURRENCY DATA BARS
	local CurrencyData = {}
	local tokens = {
		{61, 250},	 -- Dalaran Jewelcrafter's Token
		{81, 250},	 -- Dalaran Cooking Award
		{241, 250},	 -- Champion Seal
		{361, 200},  -- Illustrious Jewelcrafter's Token
		{390, 3000}, -- Conquest Points
		{391, 2000},  -- Tol Barad Commendation
		{392, 4000}, -- Honor Points
		{395, 4000}, -- Justice Points
		{396, 4000}, -- Valor Points
		{402, 10},	 -- Chef's Award 
		{416, 300}, -- Mark of the World Tree
		{515, 2000}, --Darkmoon Prize Ticket
		{614, 2000}, --Mote of Darkness
		{615, 2000}, --Essence of Corrupted Deathwing
	}

	local currencyParent = CreateFrame("Frame", nil, UIParent)
	currencyParent:SetSize(1,1)
	currencyParent:Point("TOP", infobar, "BOTTOM", 0, -13)
	currencyParent:SetAlpha(0)
	currencyParent:Hide()

	local function updateCurrency()
		if CurrencyData[1] then
			for i = 1, getn(CurrencyData) do
				CurrencyData[i]:Kill()
			end
			wipe(CurrencyData) 
		end

		for i, v in ipairs(tokens) do
			local id, max = unpack(v)
			local name, amount, icon = GetCurrencyInfo(id)

			if name and amount > 0 then
				local frame = CreateFrame("Frame", "CurrencyData"..id, currencyParent)
				frame:CreatePanel("Default", 120, 20, "CENTER", currencyParent, "CENTER", 0, 0)
				frame:EnableMouse(true)

				frame.Status = CreateFrame("StatusBar", "CurrencyDataStatus"..id, frame)
				frame.Status:SetFrameLevel(12)
				frame.Status:SetStatusBarTexture(R["media"].normal)
				frame.Status:SetMinMaxValues(0, max)
				frame.Status:SetValue(amount)
				frame.Status:SetStatusBarColor(0, 0.4, 1)
				frame.Status:SetAllPoints()

				frame.Text = frame.Status:CreateFontString(nil, "OVERLAY")
				frame.Text:SetFont(R["media"].font, R["media"].fontsize, R["media"].fontflag)
				frame.Text:Point("CENTER", frame, "CENTER", 0, 0)
				frame.Text:Width(frame:GetWidth() - 4)
				frame.Text:SetShadowColor(0, 0, 0)
				frame.Text:SetShadowOffset(1.25, -1.25)
				frame.Text:SetText(format("%s / %s", amount, max))
					
				frame.IconBG = CreateFrame("Frame", "CurrencyDataIconBG"..id, frame)
				frame.IconBG:CreatePanel(nil, 20, 20, "RIGHT", frame, "LEFT", -7, 0)
				frame.Icon = frame.IconBG:CreateTexture(nil, "ARTWORK")
				frame.Icon:Point("TOPLEFT", frame.IconBG, "TOPLEFT", 0, 0)
				frame.Icon:Point("BOTTOMRIGHT", frame.IconBG, "BOTTOMRIGHT", 0, 0)
				frame.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				frame.Icon:SetTexture("Interface\\Icons\\"..icon)

				frame:SetScript("OnEnter", function(self) frame.Text:SetText(format("%s", name)) end)
				frame:SetScript("OnLeave", function(self) frame.Text:SetText(format("%s / %s", amount, max)) end)
				
				tinsert(CurrencyData, frame)
			end
		end
		
		for key, frame in ipairs(CurrencyData) do
			frame:ClearAllPoints()
			if key == 1 then
				frame:Point("TOP", currencyParent, "TOP", 0, 0)
			else
				frame:Point("TOP", CurrencyData[key-1], "BOTTOM", 0, -9)
			end
		end
	end

	Status:SetScript("OnMouseDown", function(self)
		if currencyParent:IsShown() then
			local fadeInfo = {};
			fadeInfo.mode = "OUT";
			fadeInfo.timeToFade = 0.5;
			fadeInfo.finishedFunc = function() currencyParent:Hide() end
			fadeInfo.startAlpha = currencyParent:GetAlpha()
			fadeInfo.endAlpha = 0
			UIFrameFade(currencyParent, fadeInfo)
		else
			currencyParent:Show()
			UIFrameFadeIn(currencyParent, 0.5, currencyParent:GetAlpha(), 1)
		end
	end)

	hooksecurefunc("BackpackTokenFrame_Update", updateCurrency)
end

IF:RegisterInfoText("Currency", LoadCurrency)