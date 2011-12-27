local R, C, L, DB = unpack(select(2, ...))
local AddOnName = ...

local int = 10
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
	self:SetAllPoints(TopInfoBar3)
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
		TopInfoBar3.Text:SetText(formatMem(total))
		TopInfoBar3.Status:SetMinMaxValues(0,10000)
		TopInfoBar3.Status:SetValue(total)
		local r, g, b = R.ColorGradient(total/10000, R.InfoBarStatusColor[3][1], R.InfoBarStatusColor[3][2], R.InfoBarStatusColor[3][3], 
																R.InfoBarStatusColor[2][1], R.InfoBarStatusColor[2][2], R.InfoBarStatusColor[2][3],
																R.InfoBarStatusColor[1][1], R.InfoBarStatusColor[1][2], R.InfoBarStatusColor[1][3])
		TopInfoBar3.Status:SetStatusBarColor(r, g, b)
		int = 10
	end
end

local Stat = CreateFrame("Frame", nil, TopInfoBar3)
Stat:EnableMouse(true)
Stat:SetFrameStrata(TopInfoBar3:GetFrameStrata())
Stat:SetFrameLevel(TopInfoBar3:GetFrameLevel() + 5)
Stat:ClearAllPoints()
Stat:SetAllPoints(TopInfoBar3)

Stat:SetScript("OnMouseDown", function(self)
	UpdateAddOnMemoryUsage()
	local before = gcinfo()
	collectgarbage()
	UpdateAddOnMemoryUsage()
	DEFAULT_CHAT_FRAME:AddMessage(format(GetAddOnMetadata(AddOnName, "Title")..": %s %s",L["共释放内存"],formatMem(before - gcinfo())))
end)
Stat:SetScript("OnUpdate", UpdateMem)
Stat:SetScript("OnEnter", function(self)
	local bandwidth = GetAvailableBandwidth()
	local home_latency = select(3, GetNetStats()) 
	local anchor, panel, xoff, yoff = "ANCHOR_BOTTOMRIGHT", self, 0, 0
	GameTooltip:SetOwner(panel, anchor, xoff, yoff)
	GameTooltip:ClearLines()
	
	GameTooltip:AddDoubleLine(L["本地延迟"]..": ", string.format(homeLatencyString, home_latency), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)
	
	if bandwidth ~= 0 then
		GameTooltip:AddDoubleLine(L["带宽"]..": " , string.format(bandwidthString, bandwidth),0.69, 0.31, 0.31,0.84, 0.75, 0.65)
		GameTooltip:AddDoubleLine(L["下载"]..": " , string.format(percentageString, GetDownloadedPercentage() *100),0.69, 0.31, 0.31, 0.84, 0.75, 0.65)
		GameTooltip:AddLine(" ")
	end
	local totalMemory = UpdateMemory()
	GameTooltip:AddDoubleLine(L["总共内存使用"]..": ", formatMem(totalMemory), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)
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