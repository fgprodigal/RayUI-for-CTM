local addon, ns = ...
local cfg = ns.cfg

SetCVar("consolidateBuffs",0) -- disabling consolidated buffs (temp.)
SetCVar("buffDurations",1) -- enabling buff durations
BUFFS_PER_ROW = 16
DEBUFF_MAX_DISPLAY = 16
local warningtime = 6

local GetFormattedTime = function(s)
	if s >= 86400 then
		return format('%dd', floor(s/86400 + 0.5))
	elseif s >= 3600 then
		return format('%dh', floor(s/3600 + 0.5))
	elseif s >= 60 then
		return format('%dm', floor(s/60 + 0.5))
	end
	return format('%ds', floor(s + 0.5))
end

ConsolidatedBuffs:ClearAllPoints()
ConsolidatedBuffs:Point(unpack(cfg.BUFFpos))
ConsolidatedBuffs:Size(cfg.iconsize, cfg.iconsize)
ConsolidatedBuffs.SetPoint = nil
ConsolidatedBuffsIcon:SetTexture("Interface\\Icons\\Spell_ChargePositive")
ConsolidatedBuffsIcon:SetTexCoord(0.03,0.97,0.03,0.97)
ConsolidatedBuffsIcon:Size(cfg.iconsize-2,cfg.iconsize-2)
local h = CreateFrame("Frame")
h:SetParent(ConsolidatedBuffs)
h:SetAllPoints(ConsolidatedBuffs)
h:SetFrameLevel(30)
ConsolidatedBuffsCount:SetParent(h)
ConsolidatedBuffsCount:SetPoint("BOTTOMRIGHT")
ConsolidatedBuffsCount:SetFont(cfg.font, cfg.countfontsize, "OUTLINE")
ConsolidatedBuffs:CreateShadow()

for i = 1, 3 do
	_G["TempEnchant"..i.."Border"]:Hide()
	local te 			= _G["TempEnchant"..i]
	local teicon 		= _G["TempEnchant"..i.."Icon"]
	local teduration 	= _G["TempEnchant"..i.."Duration"]
	local h = CreateFrame("Frame")
	h:SetParent(te)
	h:SetAllPoints(te)
	h:SetFrameLevel(30)
	te:Size(cfg.iconsize,cfg.iconsize)
	teicon:Point("BOTTOMRIGHT", te, -2, 2)
	teicon:SetTexCoord(.08, .92, .08, .92)
	teicon:Point("TOPLEFT", te, 2, -2)
	teduration:ClearAllPoints()
	teduration:SetParent(h)
	teduration:Point("BOTTOM", 0, cfg.timeYoffset)
	teduration:SetFont(cfg.font, cfg.timefontsize, "THINOUTLINE")
	te:CreateShadow()
end

local function CreateBuffStyle(buttonName, i, debuff)
	local buff		= _G[buttonName..i]
	local icon		= _G[buttonName..i.."Icon"]
	local border	= _G[buttonName..i.."Border"]
	local duration	= _G[buttonName..i.."Duration"]
	local count 	= _G[buttonName..i.."Count"]
	if icon and not _G[buttonName..i.."Background"] then
		local h = CreateFrame("Frame")
		h:SetParent(buff)
		h:SetAllPoints(buff)
		h:SetFrameLevel(30)
		icon:SetTexCoord(.08, .92, .08, .92)
		icon:Point("TOPLEFT", buff, 2, -2)
		icon:Point("BOTTOMRIGHT", buff, -2, 2)
		buff:Size(cfg.iconsize,cfg.iconsize)
		duration:ClearAllPoints()
		duration:SetParent(h)
		duration:Point("BOTTOM", 0, cfg.timeYoffset)
		duration:SetFont(cfg.font, cfg.timefontsize, "THINOUTLINE")
		buff:CreateShadow()
		count:SetParent(h)
		count:ClearAllPoints()
		count:SetPoint("TOPRIGHT")
		count:SetFont(cfg.font, cfg.countfontsize, "OUTLINE")
	end
	if border then 
		border:SetTexture(cfg.auratex)
		border:SetTexCoord(0.03, 0.97, 0.03, 0.97)
		border:Point("TOPLEFT",1, -1)
		border:Point("BOTTOMRIGHT",-1, 1)
	end
end

local function OverrideBuffAnchors()
	local buttonName = "BuffButton" -- c
	local buff, previousBuff, aboveBuff;
	local numBuffs = 0;
	local slack = BuffFrame.numEnchants
	if ( BuffFrame.numConsolidated > 0 ) then
		slack = slack + 1;	
	end
	for i=1, BUFF_ACTUAL_DISPLAY do
		CreateBuffStyle(buttonName, i, false)
		local buff = _G[buttonName..i]
		if not ( buff.consolidated ) then	
			numBuffs = numBuffs + 1
			i = numBuffs + slack
			buff:ClearAllPoints()
			if ( (i > 1) and (mod(i, BUFFS_PER_ROW) == 1) ) then
 				if ( i == BUFFS_PER_ROW+1 ) then
					buff:Point("TOP", ConsolidatedBuffs, "BOTTOM", 0, -10)
				else
					buff:Point("TOP", aboveBuff, "BOTTOM", 0, -10)
				end
				aboveBuff = buff; 
			elseif ( i == 1 ) then
				buff:Point(unpack(cfg.BUFFpos))
			else
				if ( numBuffs == 1 ) then
					local  mh, _, _, oh, _, _, te = GetWeaponEnchantInfo()
					if mh and oh and te and not UnitHasVehicleUI("player") then
						buff:Point("TOPRIGHT", TempEnchant3, "TOPLEFT", -cfg.spacing, 0);
					elseif ((mh and oh) or (mh and te) or (oh and te)) and not UnitHasVehicleUI("player") then
						buff:Point("TOPRIGHT", TempEnchant2, "TOPLEFT", -cfg.spacing, 0);
					elseif ((mh and not oh and not te) or (oh and not mh and not te) or (te and not mh and not oh)) and not UnitHasVehicleUI("player") then
						buff:Point("TOPRIGHT", TempEnchant1, "TOPLEFT", -cfg.spacing, 0)
					else
						buff:Point("TOPRIGHT", ConsolidatedBuffs, "TOPLEFT", -cfg.spacing, 0);
					end
				else
					buff:Point("RIGHT", previousBuff, "LEFT", -cfg.spacing, 0);
				end
			end
			previousBuff = buff
		end		
	end
end

local function OverrideDebuffAnchors(buttonName, i)
	CreateBuffStyle(buttonName, i, true)
	local color
	local buffName = buttonName..i
	local dtype = select(5, UnitDebuff("player",i))   
	local debuffSlot = _G[buffName.."Border"]
	local debuff = _G[buttonName..i];
	debuff:ClearAllPoints()
	if i == 1 then
		debuff:Point(unpack(cfg.DEBUFFpos))
	else
		debuff:Point("RIGHT", _G[buttonName..(i-1)], "LEFT", -cfg.spacing, 0)
	end
	if (dtype ~= nil) then
		color = DebuffTypeColor[dtype]
	else
		color = DebuffTypeColor["none"]
	end
	if debuffSlot then debuffSlot:SetVertexColor(color.r * 0.6, color.g * 0.6, color.b * 0.6, 1) end
end

-- fixing the consolidated buff container sizes because the default formula is just SHIT!
local z = 0.79 -- 37 : 28 // 30 : 24 -- dasdas;djal;fkjl;jkfsfoi !!!! meaningfull comments we all love them!!11
local function OverrideConsolidatedBuffsAnchors()
	ConsolidatedBuffsTooltip:SetWidth(min(BuffFrame.numConsolidated * cfg.iconsize * z + 18, 4 * cfg.iconsize * z + 18));
    ConsolidatedBuffsTooltip:SetHeight(floor((BuffFrame.numConsolidated + 3) / 4 ) * cfg.iconsize * z + CONSOLIDATED_BUFF_ROW_HEIGHT * z);
end

function UpdateFlash(self, elapsed)
	local index = self:GetID();
	if ( self.timeLeft < warningtime ) then
		self:SetAlpha(BuffFrame.BuffAlphaValue);
	else
		self:SetAlpha(1.0);
	end
end

local UpdateDuration = function(auraButton, timeLeft)
	local duration = auraButton.duration
	if SHOW_BUFF_DURATIONS == "1" and timeLeft then
		duration:SetFormattedText(GetFormattedTime(timeLeft))
		if timeLeft < BUFF_DURATION_WARNING_TIME then
			duration:SetVertexColor(1, 0, 0)
		end
		duration:Show()
	else
		duration:Hide()
	end
end
hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", OverrideBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", OverrideDebuffAnchors)
hooksecurefunc("ConsolidatedBuffs_UpdateAllAnchors", OverrideConsolidatedBuffsAnchors)
hooksecurefunc("AuraButton_OnUpdate", UpdateFlash)
hooksecurefunc("AuraButton_UpdateDuration", UpdateDuration)