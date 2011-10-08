local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, _, name)
	f:UnregisterEvent("ADDON_LOADED")
	f:SetScript("OnEvent", nil)
end)

local function addLine(self,id,isItem)
	self:AddLine(" ")
	if isItem then
		if select(8, GetItemInfo(id)) and select(8, GetItemInfo(id)) >1 then
			self:AddDoubleLine("|cFFCA3C3C堆叠数:|r","|cffffffff"..select(8, GetItemInfo(id)))
		end
		self:AddDoubleLine("|cFFCA3C3C物品ID:|r","|cffffffff"..id)
	else
		self:AddDoubleLine("|cFFCA3C3C技能ID:|r","|cffffffff"..id)
	end
	self:Show()
end

--------------------------------------------------------------------
-- SpellID's by Silverwind
-- http://wow.curseforge.com/addons/spellid/
--------------------------------------------------------------------
--[[
hooksecurefunc(GameTooltip, "SetUnitBuff", function(self,...)
	local id = select(11, UnitBuff(...))
	if id then
		self:AddLine("|cFFCA3C3C"..ID.."|r".." "..id)
		self:Show()
	end
end)

hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self,...)
	local id = select(11, UnitDebuff(...))
	if id then
		self:AddLine("|cFFCA3C3C"..ID.."|r".." "..id)
		self:Show()
	end
end)
--]]
hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
	local id = select(11, UnitAura(...))
	local caster = select (8, UnitAura(...))
	if id then
		self:AddLine(" ")
		if caster ~= nil then
			self:AddLine(UnitName(caster))
		end
		self:AddDoubleLine("|cFFCA3C3C技能ID:|r","|cffffffff"..id)
		self:Show()
	end
end)

hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
	local id = tonumber(link:match("spell:(%d+)"))
	if id then addLine(ItemRefTooltip,id) end
end)

GameTooltip:HookScript("OnTooltipSetSpell", function(self)
	local id = select(3,self:GetSpell())
	if id then addLine(self,id) end
end)

-- Item Hooks -----------------------------------------------------------------
hooksecurefunc("SetItemRef", function(link, ...)
	local id = tonumber(link:match("spell:(%d+)"))
	if id then addLine(ItemRefTooltip,id) end
end)

local function attachItemTooltip(self)
	local link = select(2,self:GetItem())
	if not link then return end
	local id = select(3,strfind(link, "^|%x+|Hitem:(%-?%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%-?%d+):(%-?%d+)"))
	if id then addLine(self,id,true) end
end

GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip3:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip3:HookScript("OnTooltipSetItem", attachItemTooltip)