local R, C, L, DB = unpack(select(2, ...))
if not C["tooltip"].enable then return end

CreateFrame('Frame', 'Needy', UIParent)

Needy:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)
Needy:RegisterEvent('MODIFIER_STATE_CHANGED')

if TinyTip then
    TinyTip.HookOnTooltipSetUnit(GameTooltip, Needy.UPDATE_MOUSEOVER_UNIT)
else
    Needy:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
end

function Needy:INSPECT_ACHIEVEMENT_READY()
    self:UnregisterEvent('INSPECT_ACHIEVEMENT_READY')
	self.line:SetFont(GameTooltipTextLeft3:GetFont())
    self.line:SetText()

    if GameTooltip:GetUnit() == self.unit then
        local stats, text = {}, ''

        stats.TotalAchievemen = tonumber(GetComparisonAchievementPoints()) or 0
            text = text .. '|cFFF1C502成就点数:  |cFFFFFFFF' .. stats.TotalAchievemen

        if text ~= '' then
			self.line:SetFont(GameTooltipTextLeft3:GetFont())
            self.line:SetText(text)
        end
    end

    GameTooltip:Show()

    if not UnitName('mouseover') then
        GameTooltip:FadeOut()
    end

    ClearAchievementComparisonUnit()

    if _G.GearScore then
        _G.GearScore:RegisterEvent('INSPECT_ACHIEVEMENT_READY')
    end

    if Elite then
        Elite:RegisterEvent('INSPECT_ACHIEVEMENT_READY')
    end

    if AchievementFrameComparison then
        AchievementFrameComparison:RegisterEvent('INSPECT_ACHIEVEMENT_READY')
    end

    self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
end

function Needy:MODIFIER_STATE_CHANGED()
    if arg1 == 'LCTRL' or arg1 == 'RCTRL' then
        if self.line and UnitName('mouseover') == self.unit then
            self:UPDATE_MOUSEOVER_UNIT(true)
        end
    end
end

function Needy:UPDATE_MOUSEOVER_UNIT(refresh)
    if not refresh then
        self.unit, self.line = nil, nil
    end

    if (UnitAffectingCombat('player')) or UnitIsDead('player') or not UnitExists('mouseover')
    or not UnitIsPlayer('mouseover') or not UnitIsConnected('mouseover') or UnitIsDead('mouseover') then
        return
    end

    self.unit = UnitName('mouseover')

    local text = '\n正在查询成就..'

    if refresh then
		self.line:SetFont(GameTooltipTextLeft3:GetFont())
        self.line:SetText(text)
    else
        GameTooltip:AddLine(text)
        self.line = _G['GameTooltipTextLeft' .. GameTooltip:NumLines()]
    end

    GameTooltip:Show()

    if _G.GearScore then
        _G.GearScore:UnregisterEvent('INSPECT_ACHIEVEMENT_READY')
    end

    if Elite then
        Elite:UnregisterEvent('INSPECT_ACHIEVEMENT_READY')
    end

    if AchievementFrameComparison then
        AchievementFrameComparison:UnregisterEvent('INSPECT_ACHIEVEMENT_READY')
    end

    self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT')
    self:RegisterEvent('INSPECT_ACHIEVEMENT_READY')

    SetAchievementComparisonUnit('mouseover')
end

-- 物品等级
local Quality = {
	[500] = {
		["Red"] = { ["A"] = 0.94, ["B"] = 400, ["C"] = 0.0006, ["D"] = 1 },
		["Green"] = { ["A"] = 0.47, ["B"] = 400, ["C"] = 0.0047, ["D"] = -1 },
		["Blue"] = { ["A"] = 0, ["B"] = 0, ["C"] = 0, ["D"] = 0 },
	},
	[400] = {
		["Red"] = { ["A"] = 0.94, ["B"] = 300, ["C"] = 0.0006, ["D"] = 1 },
		["Green"] = { ["A"] = 0.47, ["B"] = 300, ["C"] = 0.0047, ["D"] = -1 },
		["Blue"] = { ["A"] = 0, ["B"] = 0, ["C"] = 0, ["D"] = 0 },
	},
	[300] = {
		["Red"] = { ["A"] = 0.69, ["B"] = 200, ["C"] = 0.0025, ["D"] = 1 },
		["Green"] = { ["A"] = 0.28, ["B"] = 200, ["C"] = 0.0019, ["D"] = 1 },
		["Blue"] = { ["A"] = 0.97, ["B"] = 200, ["C"] = 0.0096, ["D"] = -1 },
	},
	[200] = {
		["Red"] = { ["A"] = 0.0, ["B"] = 100, ["C"] = 0.0069, ["D"] = 1 },
		["Green"] = { ["A"] = 0.5, ["B"] = 100, ["C"] = 0.0022, ["D"] = -1 },
		["Blue"] = { ["A"] = 1, ["B"] = 100, ["C"] = 0.0003, ["D"] = -1 },
	},
	[100] = {
		["Red"] = { ["A"] = 0.12, ["B"] = 0, ["C"] = 0.0012, ["D"] = -1 },
		["Green"] = { ["A"] = 1, ["B"] = 0, ["C"] = 0.0050, ["D"] = -1 },
		["Blue"] = { ["A"] = 0, ["B"] = 0, ["C"] = 0.01, ["D"] = 1 },
	},
}

function GetItemScore(iLink) 
   local _, _, itemRarity, itemLevel, _, _, _, _, itemEquip = GetItemInfo(iLink);
   if (IsEquippableItem(iLink)) then 
      if not   (itemLevel > 1) and (itemRarity > 1) then 
      return 0;
      end
   end
   return itemLevel;
end

function GetPlayerScore(unit) 
   local ilvl, ilvlAdd, equipped = 0, 0, 0;
   if (UnitIsPlayer(unit)) then
      local _, targetClass = UnitClass(unit);
      for i = 1, 18 do 
         if (i ~= 4) then
            local iLink = GetInventoryItemLink(unit, i);
            if (iLink) then
               ilvlAdd = GetItemScore(iLink);
               ilvl = ilvl + ilvlAdd;
               equipped = equipped + 1;
            end
         end
      end
   end
   ClearInspectPlayer(); 
   return floor(ilvl / equipped);
end

function GetQuality(ItemScore)
	if ( ItemScore > 499 ) then ItemScore = 499; end
	local Red = 0.1; local Blue = 0.1; local Green = 0.1
   	if not ( ItemScore ) then return 0, 0, 0 end
	for i = 0,5 do
		if ( ItemScore > i * 100 ) and ( ItemScore <= ( ( i + 1 ) * 100 ) ) then
		    local Red = Quality[( i + 1 ) * 100].Red["A"] + (((ItemScore - Quality[( i + 1 ) * 100].Red["B"])*Quality[( i + 1 ) * 100].Red["C"])*Quality[( i + 1 ) * 100].Red["D"])
            local Blue = Quality[( i + 1 ) * 100].Green["A"] + (((ItemScore - Quality[( i + 1 ) * 100].Green["B"])*Quality[( i + 1 ) * 100].Green["C"])*Quality[( i + 1 ) * 100].Green["D"])
            local Green = Quality[( i + 1 ) * 100].Blue["A"] + (((ItemScore - Quality[( i + 1 ) * 100].Blue["B"])*Quality[( i + 1 ) * 100].Blue["C"])*Quality[( i + 1 ) * 100].Blue["D"])
			--if not ( Red ) or not ( Blue ) or not ( Green ) then return 0.1, 0.1, 0.1, nil; end
			return Red, Green, Blue
		end
	end
return 0.1, 0.1, 0.1
end

function SetUnit() 
   local _, unit = GameTooltip:GetUnit();
   local unitilvl = 0;
   if not (unit) or not (UnitIsPlayer(unit)) or not (CanInspect(unit)) then
      return;
   elseif (UnitIsUnit(unit,"player")) then 
      unitilvl = GetPlayerScore("player");
   elseif not (InspectFrame and InspectFrame:IsShown()) then 
NotifyInspect(unit); unitilvl = GetPlayerScore(unit);
   end

   if (unitilvl > 1) then 
		local Red, Blue, Green = GetQuality(unitilvl)
		GameTooltip:AddLine("物品等级: "..unitilvl,Red, Green, Blue);
end
end
GameTooltip:HookScript("OnTooltipSetUnit",SetUnit)
