local R, C, L, DB = unpack(select(2, ...))
if not C["buff"].enable then return end

buttonsize = 30         -- Buff Size
spacing = 4             -- Buff Spacing
buffsperrow = 16        -- Buffs Per Row
growthvertical = 1      -- Growth Direction. 1 = down, 2 = up
growthhorizontal = 1    -- Growth Direction. 1 = left, 2 = right

local buffholder = CreateFrame("Frame", "Buffs", UIParent)
buffholder:Height(buttonsize)
buffholder:Width(buttonsize)
buffholder:SetFrameStrata("BACKGROUND")
buffholder:SetClampedToScreen(true)
buffholder:SetAlpha(0)
buffholder:Point("TOPRIGHT", UIParent, "TOPRIGHT", -14, -35)
R.CreateMover(buffholder, "BuffMover", L["Buff锚点"], true)
local debuffholder = CreateFrame("Frame", "Debuffs", UIParent)
debuffholder:Height(buttonsize)
debuffholder:Width(buttonsize)
debuffholder:SetFrameStrata("BACKGROUND")
debuffholder:SetClampedToScreen(true)
debuffholder:SetAlpha(0)
debuffholder:Point("TOPRIGHT", UIParent, "TOPRIGHT", -14, -125)
R.CreateMover(debuffholder, "DebuffMover", L["Debuff锚点"], true)
local enchantholder = CreateFrame("Frame", "TempEnchants", UIParent)
enchantholder:Height(buttonsize - 8)
enchantholder:Width(buttonsize - 8)
enchantholder:SetFrameStrata("BACKGROUND")
enchantholder:SetClampedToScreen(true)
enchantholder:SetAlpha(0)
enchantholder:Point("TOPLEFT", Minimap, "BOTTOMLEFT", 0, -30)
R.CreateMover(enchantholder, "WeaponEnchantMover", L["武器附魔锚点"], true)

local function makeitgrow(button, index, anchor, framekind)
    for i = 1, BUFF_ACTUAL_DISPLAY do 
        if growthvertical == 1 then
			if growthhorizontal == 1 then
				if index == ((buffsperrow*i)+1) then _G[button..index]:Point("TOPRIGHT", anchor, "TOPRIGHT", 0, -(buttonsize+spacing+4)*i) end
			else
				if index == ((buffsperrow*i)+1) then _G[button..index]:Point("TOPLEFT", anchor, "TOPLEFT", 0, -(buttonsize+spacing+4)*i) end
			end
        else
			if growthhorizontal == 1 then
				if index == ((buffsperrow*i)+1) then _G[button..index]:Point("TOPRIGHT", anchor, "TOPRIGHT", 0, (buttonsize+spacing+4)*i) end
			else
				if index == ((buffsperrow*i)+1) then _G[button..index]:Point("TOPLEFT", anchor, "TOPLEFT", 0, (buttonsize+spacing+4)*i) end
			end
        end
    end
    if growthhorizontal == 1 and framekind ~= 3 then
        _G[button..index]:Point("RIGHT", _G[button..(index-1)], "LEFT", -(spacing+4), 0)
    else
        _G[button..index]:Point("LEFT", _G[button..(index-1)], "RIGHT", (spacing+4), 0)
    end
end

local function StyleBuffs(button, index, framekind, anchor)
	local buff = button..index
    _G[buff.."Icon"]:SetTexCoord(.1, .9, .1, .9)
    _G[buff.."Icon"]:SetDrawLayer("OVERLAY")
    _G[buff]:ClearAllPoints()
    _G[buff]:CreateShadow("Default", 2, 4)
    
	_G[buff.."Count"]:ClearAllPoints()
	_G[buff.."Count"]:Point("TOPRIGHT", 2, 2)
    _G[buff.."Count"]:SetDrawLayer("OVERLAY")
    
	_G[buff.."Duration"]:ClearAllPoints()
	_G[buff.."Duration"]:Point("CENTER", _G[buff], "BOTTOM", 2, -1)
    _G[buff.."Duration"]:SetDrawLayer("OVERLAY")
    
    if framekind == 3 then
    	_G[buff.."Count"]:SetFont(C["media"].cdfont, 10, "OUTLINE")
    	_G[buff.."Duration"]:SetFont(C["media"].cdfont, 10, "OUTLINE")
    	_G[buff]:Height(buttonsize - 8)
		_G[buff]:Width(buttonsize - 8)
    else
		_G[buff.."Count"]:SetFont(C["media"].cdfont, 14, "OUTLINE")
   		_G[buff.."Duration"]:SetFont(C["media"].cdfont, 14, "OUTLINE")
   		_G[buff]:Height(buttonsize)
		_G[buff]:Width(buttonsize)
	end
	
	if _G[buff.."Border"] then 
		_G[buff.."Border"]:SetTexture("Interface\\AddOns\\!RayUI\\media\\iconborder")
		_G[buff.."Border"]:SetTexCoord(0.03, 0.97, 0.03, 0.97)
		_G[buff.."Border"]:Point("TOPLEFT", -1, 1)
		_G[buff.."Border"]:Point("BOTTOMRIGHT", 1, -1)
		if framekind == 3 then _G[buff.."Border"]:Hide() end
	end
    if framekind == 2 then
		local dtype = select(5, UnitDebuff("player",index))
		if (dtype ~= nil) then
			color = DebuffTypeColor[dtype]
		else
			color = DebuffTypeColor["none"]
		end
		_G[buff.."Border"]:SetVertexColor(color.r * 0.6, color.g * 0.6, color.b * 0.6, 1)
	end
    
    if index == 1 then _G[buff]:Point("CENTER", anchor, "CENTER", 0, 0) end
    if index ~= 1 then
		makeitgrow(button, index, _G[button..1], framekind)
	end
end

local function UpdateBuff()
    for i = 1, BUFF_ACTUAL_DISPLAY do
        StyleBuffs("BuffButton", i, 1, buffholder)
    end
    for i = 1, BuffFrame.numEnchants do
        StyleBuffs("TempEnchant", i, 3, enchantholder)
    end
end
local function UpdateDebuff(buttonName, index)
    StyleBuffs(buttonName, index, 2, debuffholder)
end

local  function formatTime(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", floor(s/day + 0.5)), s % day
	elseif s >= hour then
		return format("%dh", floor(s/hour + 0.5)), s % hour
	elseif s >= minute then
		return format("%dm", floor(s/minute + 0.5)), s % minute
	elseif s >= minute / 12 then
		return floor(s + 0.5), (s * 100 - floor(s * 100))/100
	end
	return format("%d", s), (s * 100 - floor(s * 100))/100
end

local function updateTime(button, timeLeft)
	local duration = _G[button:GetName().."Duration"]
	if SHOW_BUFF_DURATIONS == "1" and timeLeft then
		duration:SetText(formatTime(timeLeft))
		if timeLeft<60 then
			duration:SetTextColor(0.8, 0, 0)
		end
	end
end

hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", UpdateBuff)
hooksecurefunc("DebuffButton_UpdateAnchors", UpdateDebuff)
hooksecurefunc("AuraButton_UpdateDuration", updateTime)
SetCVar("consolidateBuffs", 0)