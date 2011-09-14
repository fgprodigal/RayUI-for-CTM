local R, C, DB = unpack(select(2, ...))

local topinfo= {}
local botinfo= {}
local LastUpdate = 1
for i = 1,8 do
	if i == 1 then
		 topinfo[i] = CreateFrame("Frame", "BottomInfoBar", UIParent)
		topinfo[i]:CreatePanel("Transparent", 400, 10, "BOTTOM", UIParent, "BOTTOM", 0, 5)
	elseif i == 2 then
		topinfo[i] = CreateFrame("Frame", "TopInfoBar"..i-1, UIParent)
		topinfo[i]:CreatePanel("Transparent", 80, 10, "TOPLEFT", UIParent, "TOPLEFT", 10, -10)
	else
		topinfo[i] = CreateFrame("Frame", "TopInfoBar"..i-1, UIParent)
		topinfo[i]:CreatePanel("Transparent", 80, 10, "LEFT", topinfo[i-1], "RIGHT", 5, 0)
	end
	
	if i~= 1 then
		topinfo[i].Status = CreateFrame("StatusBar", "TopInfoBarStatus"..i, topinfo[i])
		topinfo[i].Status:SetFrameLevel(12)
		topinfo[i].Status:SetStatusBarTexture(C["media"].normal)
		topinfo[i].Status:SetMinMaxValues(0, 100)
		topinfo[i].Status:SetStatusBarColor(0, 0.4, 1, 0.6)
		topinfo[i].Status:Point("TOPLEFT", topinfo[i], "TOPLEFT", 2, -2)
		topinfo[i].Status:Point("BOTTOMRIGHT", topinfo[i], "BOTTOMRIGHT", -2, 2)
		topinfo[i].Status:SetValue(100)
		
		topinfo[i].Text = topinfo[i].Status:CreateFontString(nil, "OVERLAY")
		topinfo[i].Text:SetFont(C["media"].font, C["media"].fontsize, C["media"].fontflag)
		topinfo[i].Text:Point("CENTER", topinfo[i], "CENTER", 0, -4)
		topinfo[i].Text:SetShadowColor(0, 0, 0, 0.4)
		topinfo[i].Text:SetShadowOffset(R.mult, -R.mult)
	end
	topinfo[i]:SetAlpha(0)
end

-- for i = 1,3 do
	-- if i == 1 then
		-- botinfo[i] = CreateFrame("Frame", "BottomInfoBar"..i, UIParent)
		-- botinfo[i]:CreatePanel("Transparent", 80, 10, "BOTTOMLEFT", UIParent, "BOTTOM", -200, 5)
	-- else
		-- botinfo[i] = CreateFrame("Frame", "BottomInfoBar"..i, UIParent)
		-- botinfo[i]:CreatePanel("Transparent", 80, 10, "LEFT", botinfo[i-1], "RIGHT", 80, 0)
	-- end
	
	-- botinfo[i].Status = CreateFrame("StatusBar", "BottomLeftInfoBarStatus"..i, botinfo[i])
	-- botinfo[i].Status:SetFrameLevel(12)
	-- botinfo[i].Status:SetStatusBarTexture(C["media"].normal)
	-- botinfo[i].Status:SetMinMaxValues(0, 100)
	-- botinfo[i].Status:SetStatusBarColor(0, 0.4, 1, 0.6)
	-- botinfo[i].Status:Point("TOPLEFT", botinfo[i], "TOPLEFT", 2, -2)
	-- botinfo[i].Status:Point("BOTTOMRIGHT", botinfo[i], "BOTTOMRIGHT", -2, 2)
	-- botinfo[i].Status:SetValue(0)
	
	-- botinfo[i].Text = botinfo[i].Status:CreateFontString(nil, "OVERLAY")
	-- botinfo[i].Text:SetFont(C["media"].font, C["media"].fontsize, C["media"].fontflag)
	-- botinfo[i].Text:Point("CENTER", botinfo[i], "CENTER", 0, 7)
	-- botinfo[i].Text:SetShadowColor(0, 0, 0, 0.4)
	-- botinfo[i].Text:SetShadowOffset(1.25, -1.25)
	
	-- botinfo[i].showed = false
	-- botinfo[i].timer = 0
	-- botinfo[i]:SetScript("OnShow", function(self)
		-- self.timer = 0
		-- self.showed = false
		-- self:SetAlpha(0)
		-- self:SetScript("OnUpdate", function(self, elasped)
			-- self.timer = self.timer + elasped
			-- self:SetAlpha(self.timer)
			-- if self.timer>0.5 then self.showed = true end
		-- end)
	-- end)
	-- botinfo[i]:Hide()
-- end

-- FPS
topinfo[2].Text:SetText("FPS: 0")
topinfo[2].Status:SetScript("OnUpdate", function(self, elapsed)
	LastUpdate = LastUpdate - elapsed
	
	if LastUpdate < 0 then
		self:SetMinMaxValues(0, 60)
		local value = floor(GetFramerate())
		local max = GetCVar("MaxFPS")
		self:SetValue(value)
		topinfo[2].Text:SetText("FPS: "..value)
		if value<10 then
			self:SetStatusBarColor(1, 0, 0, 0.6)
		elseif value<30 then
			self:SetStatusBarColor(1, 1, 0, 0.6)
		else
			self:SetStatusBarColor(0, 0.4, 1, 0.6)
		end
		LastUpdate = 1
	end
end)

-- MS 
topinfo[3].Text:SetText("MS: 0")
topinfo[3].Status:SetScript("OnUpdate", function(self, elapsed)
	LastUpdate = LastUpdate - elapsed
	
	if LastUpdate < 0 then
		self:SetMinMaxValues(0, 1000)
		local value = (select(3, GetNetStats()))
		local max = 1000
		self:SetValue(value)
		topinfo[3].Text:SetText("MS: "..value)			
		if value>799 then
			self:SetStatusBarColor(1, 0, 0, 0.6)
		elseif value>299 then
			self:SetStatusBarColor(1, 1, 0, 0.6)
		else
			self:SetStatusBarColor(0, 0.4, 1, 0.6)
		end
		
		LastUpdate = 1
	end
end)

-- MEMORY
local f = topinfo[4]

local Stat = CreateFrame("Frame", nil, f)
Stat:EnableMouse(true)
Stat:SetFrameStrata("BACKGROUND")
Stat:SetFrameLevel(4)
Stat:ClearAllPoints()
Stat:SetAllPoints(f)

local int = 10
local StatusBar = f.Status
local Text = f.Text
local bandwidthString = "%.2f Mbps"
local percentageString = "%.2f%%"
local homeLatencyString = "%d ms"
local kiloByteString = "%d KB"
local megaByteString = "%.2f MB"

local function formatMem(memory)
	local mult = 10^1
	if memory > 999 then
		local mem = ((memory/1024) * mult) / mult
		return string.format(megaByteString, mem)
	else
		local mem = (memory * mult) / mult
		return string.format(kiloByteString, mem)
	end
end

local memoryTable = {}

local function RebuildAddonList(self)
	local addOnCount = GetNumAddOns()
	if (addOnCount == #memoryTable) then return end
	memoryTable = {}
	for i = 1, addOnCount do
		memoryTable[i] = { i, select(2, GetAddOnInfo(i)), 0, IsAddOnLoaded(i) }
	end
	self:SetAllPoints(f)
end

local function UpdateMemory()
	UpdateAddOnMemoryUsage()
	local addOnMem = 0
	local totalMemory = 0
	for i = 1, #memoryTable do
		addOnMem = GetAddOnMemoryUsage(memoryTable[i][1])
		memoryTable[i][3] = addOnMem
		totalMemory = totalMemory + addOnMem
	end
	table.sort(memoryTable, function(a, b)
		if a and b then
			return a[3] > b[3]
		end
	end)
	return totalMemory
end

local function UpdateMem(self, t)
	int = int - t
	
	if int < 0 then
		RebuildAddonList(self)
		local total = UpdateMemory()
		Text:SetText(formatMem(total))
		StatusBar:SetMinMaxValues(0,10000)
		StatusBar:SetValue(total)
		if total>8000 then
			StatusBar:SetStatusBarColor(1, 0, 0, 0.6)
		elseif total>5000 then
			StatusBar:SetStatusBarColor(1, 1, 0, 0.6)
		else
			StatusBar:SetStatusBarColor(0, 0.4, 1, 0.6)
		end
		int = 10
	end
end

Stat:SetScript("OnMouseDown", function(self) collectgarbage("collect") end)
Stat:SetScript("OnUpdate", UpdateMem)
Stat:SetScript("OnEnter", function(self)
	local bandwidth = GetAvailableBandwidth()
	local home_latency = select(3, GetNetStats()) 
	local anchor, panel, xoff, yoff = "ANCHOR_BOTTOMRIGHT", self, 0, 0
	GameTooltip:SetOwner(panel, anchor, xoff, yoff)
	GameTooltip:ClearLines()
	
	GameTooltip:AddDoubleLine("本地延迟: ", string.format(homeLatencyString, home_latency), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)
	
	if bandwidth ~= 0 then
		GameTooltip:AddDoubleLine("带宽: " , string.format(bandwidthString, bandwidth),0.69, 0.31, 0.31,0.84, 0.75, 0.65)
		GameTooltip:AddDoubleLine("下载: " , string.format(percentageString, GetDownloadedPercentage() *100),0.69, 0.31, 0.31, 0.84, 0.75, 0.65)
		GameTooltip:AddLine(" ")
	end
	local totalMemory = UpdateMemory()
	GameTooltip:AddDoubleLine("总共内存使用: ", formatMem(totalMemory), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)
	GameTooltip:AddLine(" ")
	for i = 1, #memoryTable do
		if (memoryTable[i][4]) then
			local red = memoryTable[i][3] / totalMemory
			local green = 1 - red
			GameTooltip:AddDoubleLine(memoryTable[i][2], formatMem(memoryTable[i][3]), 1, 1, 1, red, green + .5, 0)
		end						
	end
	GameTooltip:Show()
end)
Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)
UpdateMem(Stat, 10)

-- DURABILITY
local Slots = {
		[1] = {1, "头部", 1000},
		[2] = {3, "肩部", 1000},
		[3] = {5, "胸部", 1000},
		[4] = {6, "腰部", 1000},
		[5] = {9, "手腕", 1000},
		[6] = {10, "手", 1000},
		[7] = {7, "腿部", 1000},
		[8] = {8, "脚", 1000},
		[9] = {16, "主手", 1000},
		[10] = {17, "副手", 1000},
		[11] = {18, "远程", 1000}
	}
local tooltipString = "%d %%"
topinfo[5].Status:SetScript("OnEvent", function(self)
	local Total = 0
	local current, max
	
	for i = 1, 11 do
		if GetInventoryItemLink("player", Slots[i][1]) ~= nil then
			current, max = GetInventoryItemDurability(Slots[i][1])
			if current then 
				Slots[i][3] = current/max
				Total = Total + 1
			end
		end
	end
	table.sort(Slots, function(a, b) return a[3] < b[3] end)
	local value = floor(Slots[1][3]*100)

	self:SetMinMaxValues(0, 100)
	self:SetValue(value)
	topinfo[5].Text:SetText(DURABILITY..": "..value.."%")
	if value<10 then
		self:SetStatusBarColor(1, 0, 0, 0.6)
	elseif value<30 then
		self:SetStatusBarColor(1, 1, 0, 0.6)
	else
		self:SetStatusBarColor(0, 0.4, 1, 0.6)
	end
end)
topinfo[5].Status:SetScript("OnEnter", function(self)
	if not InCombatLockdown() then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, 0)
		GameTooltip:ClearLines()
		for i = 1, 11 do
			if Slots[i][3] ~= 1000 then
				green = Slots[i][3]*2
				red = 1 - green
				GameTooltip:AddDoubleLine(Slots[i][2], format(tooltipString, floor(Slots[i][3]*100)), 1 ,1 , 1, red + 1, green, 0)
			end
		end
		GameTooltip:Show()
	end
end)
topinfo[5].Status:SetScript("OnLeave", function() GameTooltip:Hide() end)
topinfo[5].Status:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
topinfo[5].Status:RegisterEvent("MERCHANT_SHOW")
topinfo[5].Status:RegisterEvent("PLAYER_ENTERING_WORLD")

local infoshow = CreateFrame("Frame")
infoshow:RegisterEvent("PLAYER_ENTERING_WORLD")
infoshow:SetScript("OnEvent", function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		for i=1,#topinfo do
			R.Delay((3+i*0.6),function()
				UIFrameFadeIn(topinfo[i], 1, 0, 1)
			end)
		end
		UIParent:SetAlpha(0)
		R.Delay(3, function() UIFrameFadeIn(UIParent,2,0,1) end)
end)

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
}

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
			local frame = CreateFrame("Frame", "CurrencyData"..id, UIParent)
			frame:CreatePanel("Transparent", 120, 10, "CENTER", UIParent, "CENTER", 0, 0)
			frame:EnableMouse(true)
			frame:Hide()

			frame.Status = CreateFrame("StatusBar", "CurrencyDataStatus"..id, frame)
			frame.Status:SetFrameLevel(12)
			frame.Status:SetStatusBarTexture(C["media"].normal)
			frame.Status:SetMinMaxValues(0, max)
			frame.Status:SetValue(amount)
			frame.Status:SetStatusBarColor(0, 0.4, 1, 0.6)
			frame.Status:Point("TOPLEFT", frame, "TOPLEFT", 2, -2)
			frame.Status:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)

			frame.Text = frame.Status:CreateFontString(nil, "OVERLAY")
			frame.Text:SetFont(C["media"].font, C["media"].fontsize, C["media"].fontflag)
			frame.Text:Point("CENTER", frame, "CENTER", 0, 2)
			frame.Text:Width(frame:GetWidth() - 4)
			frame.Text:SetShadowColor(0, 0, 0)
			frame.Text:SetShadowOffset(1.25, -1.25)
			frame.Text:SetText(format("%s / %s", amount, max))
				
			frame.IconBG = CreateFrame("Frame", "CurrencyDataIconBG"..id, frame)
			frame.IconBG:CreatePanel(nil, 20, 20, "BOTTOMLEFT", frame, "BOTTOMRIGHT", 3, -10)
			frame.Icon = frame.IconBG:CreateTexture(nil, "ARTWORK")
			frame.Icon:Point("TOPLEFT", frame.IconBG, "TOPLEFT", 2, -2)
			frame.Icon:Point("BOTTOMRIGHT", frame.IconBG, "BOTTOMRIGHT", -2, 2)
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
			frame:Point("TOPLEFT", topinfo[8], "BOTTOMLEFT", 0, -13)
		else
			frame:Point("TOP", CurrencyData[key-1], "BOTTOM", 0, -13)
		end
	end
end

local function ModifiedBackdrop(self)
	self:SetBackdropColor(unpack(C["media"].backdropcolor))
	self:SetBackdropBorderColor(unpack(R.colors.class[R.myclass]))
end

local function OriginalBackdrop(self)
	self:SetBackdropColor(unpack(C["media"].backdropcolor))
	self:SetBackdropBorderColor(unpack(C["media"].backdropcolor))
end

local toggle = CreateFrame("Frame", nil, topinfo[8])
toggle:EnableMouse(true)
toggle:SetFrameStrata("BACKGROUND")
toggle:SetFrameLevel(4)
toggle:ClearAllPoints()
toggle:SetAllPoints(topinfo[8])
toggle:EnableMouse(true)

topinfo[8].Text:SetText("货币")
topinfo[8].Status:SetValue(0)
toggle:SetScript("OnMouseDown", function(self)
	for _, frame in pairs(CurrencyData) do
		if frame and frame:IsShown() then
			frame:Hide()
		else
			frame:Show()
		end
	end
end)

local updater = CreateFrame("Frame")
updater:RegisterEvent("PLAYER_HONOR_GAIN")	
updater:SetScript("OnEvent", updateCurrency)
hooksecurefunc("BackpackTokenFrame_Update", updateCurrency)

UIParent:SetScript("OnShow", function(self)
		UIFrameFadeIn(UIParent, 1, 0, 1)
	end)

-----------------------------------------------------
-- ChatBackground
-----------------------------------------------------
SetCVar("chatStyle", "classic")

local chatpr = CreateFrame("Frame", "ChatBG", UIParent)
chatpr:SetSize(1,1)
chatpr:SetFrameStrata("BACKGROUND")
chatpr:SetFrameLevel(0)
GeneralDockManager:SetParent(chatpr)

for i=1,NUM_CHAT_WINDOWS do
	local chatbg = CreateFrame("Frame",nil , _G["ChatFrame"..i])
	chatbg:SetPoint("TOPLEFT", -2, 2)
	chatbg:SetPoint("BOTTOMRIGHT", 2, -4)
	chatbg:CreateShadow("Background")

	local ebParts = {'Left', 'Mid', 'Right'}
	for _, ebPart in ipairs(ebParts) do
		_G['ChatFrame'..i..'EditBoxFocus'..ebPart]:SetTexture(0, 0, 0, 0)
		_G['ChatFrame'..i..'EditBoxFocus'..ebPart].SetTexture = function() return end
	end
	local chatebbg = CreateFrame("Frame",nil , _G["ChatFrame"..i.."EditBox"])
	chatebbg:SetPoint("TOPLEFT", -2, -5)
	chatebbg:SetPoint("BOTTOMRIGHT", 2, 4)
	chatebbg:CreateShadow("Background")
	chatebbg.bd = CreateFrame("Frame",nil , chatebbg)
	chatebbg.bd:SetPoint("TOPLEFT", 2, -2)
	chatebbg.bd:SetPoint("BOTTOMRIGHT", -2, 2)
	chatebbg.bd:CreateBorder()
	_G["ChatFrame"..i.."EditBoxLanguage"]:Kill()
	
	hooksecurefunc("ChatEdit_UpdateHeader", function()
			local type = _G["ChatFrame"..i.."EditBox"]:GetAttribute("chatType")
			if ( type == "CHANNEL" ) then
			local id = GetChannelName(_G["ChatFrame"..i.."EditBox"]:GetAttribute("channelTarget"))
				if id == 0 then
					chatebbg.bd:SetBackdropBorderColor(unpack(C["media"].bordercolor))
				else
					chatebbg.bd:SetBackdropBorderColor(ChatTypeInfo[type..id].r,ChatTypeInfo[type..id].g,ChatTypeInfo[type..id].b)
				end
			else
				chatebbg.bd:SetBackdropBorderColor(ChatTypeInfo[type].r,ChatTypeInfo[type].g,ChatTypeInfo[type].b)
			end
		end)
end

--公会挑战框
GuildChallengeAlertFrame:Kill()

-----------------------------------------------------
-- MinimapBackground
-----------------------------------------------------
Minimap.bg = CreateFrame("Frame", nil, Minimap)
Minimap.bg:SetPoint("TOPLEFT", -2, 2)
Minimap.bg:SetPoint("BOTTOMRIGHT", 2, -2)
Minimap.bg:CreateShadow("Background")

--New Mail Check
local checkmail = CreateFrame("Frame")
checkmail:RegisterEvent("ADDON_LOADED")
checkmail:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
checkmail:RegisterEvent("UPDATE_PENDING_MAIL")
checkmail:RegisterEvent("PLAYER_ENTERING_WORLD")
checkmail:SetScript("OnEvent", function(self, event, addon)
	local inv = CalendarGetNumPendingInvites()
	local mail = HasNewMail()
	if inv > 0 and mail then -- New invites and mail
		Minimap.bg.glow:SetBackdropBorderColor(1, .5, 0)
		Minimap.bg:StartGlow()
	elseif inv > 0 and not mail then -- New invites and no mail
		Minimap.bg.glow:SetBackdropBorderColor(1, 30/255, 60/255)
		Minimap.bg:StartGlow()
	elseif inv==0 and mail then -- No invites and new mail
		Minimap.bg.glow:SetBackdropBorderColor(0, 1, 0)
		Minimap.bg:StartGlow()
	else -- None of the above
		Minimap.bg:StopGlow()
		Minimap.bg.glow:SetAlpha(1)
		Minimap.bg.glow:SetBackdropBorderColor(unpack(C["media"].bordercolor))
	end
end)

--实名好友弹窗位置
BNToastFrame:HookScript("OnShow", function(self)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", ChatFrame1Tab, "TOPLEFT", 0, 0)
end)

local AchievementHolder = CreateFrame("Frame", "AchievementHolder", UIParent)
AchievementHolder:SetWidth(180)
AchievementHolder:SetHeight(20)
AchievementHolder:SetPoint("CENTER", UIParent, "CENTER", 0, 170)

local pos = "TOP"

function AchievementMove(self, event, ...)
	local previousFrame
	for i=1, MAX_ACHIEVEMENT_ALERTS do
		local aFrame = _G["AchievementAlertFrame"..i]
		if ( aFrame ) then
			aFrame:ClearAllPoints()
			if pos == "TOP" then
				if ( previousFrame and previousFrame:IsShown() ) then
					aFrame:SetPoint("TOP", previousFrame, "BOTTOM", 0, -10)
				else
					aFrame:SetPoint("TOP", AchievementHolder, "BOTTOM")
				end
			else
				if ( previousFrame and previousFrame:IsShown() ) then
					aFrame:SetPoint("BOTTOM", previousFrame, "TOP", 0, 10)
				else
					aFrame:SetPoint("BOTTOM", AchievementHolder, "TOP")	
				end			
			end
			
			previousFrame = aFrame
		end
	end
	
end

hooksecurefunc("AchievementAlertFrame_FixAnchors", AchievementMove)

hooksecurefunc("DungeonCompletionAlertFrame_FixAnchors", function()
	for i=MAX_ACHIEVEMENT_ALERTS, 1, -1 do
		local aFrame = _G["AchievementAlertFrame"..i]
		if ( aFrame and aFrame:IsShown() ) then
			DungeonCompletionAlertFrame1:ClearAllPoints()
			if pos == "TOP" then
				DungeonCompletionAlertFrame1:SetPoint("TOP", aFrame, "BOTTOM", 0, -10)
			else
				DungeonCompletionAlertFrame1:SetPoint("BOTTOM", aFrame, "TOP", 0, 10)
			end
			
			return
		end
		
		DungeonCompletionAlertFrame1:ClearAllPoints()	
		if pos == "TOP" then
			DungeonCompletionAlertFrame1:SetPoint("TOP", AchievementHolder, "BOTTOM")
		else
			DungeonCompletionAlertFrame1:SetPoint("BOTTOM", AchievementHolder, "TOP")
		end
	end
end)

local achieveframe = CreateFrame("Frame")
achieveframe:RegisterEvent("ACHIEVEMENT_EARNED")
achieveframe:SetScript("OnEvent", function(self, event, ...) AchievementMove(self, event, ...) end)

-- local test = CreateFrame("Button",nil,UIParent)
-- test:CreateButton("Shadow", 200, 10, "CENTER", UIParent, "CENTER", 0, 0)