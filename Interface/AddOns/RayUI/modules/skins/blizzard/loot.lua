local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local S = R:GetModule("Skins")

local function LoadSkin()
	if not(IsAddOnLoaded("Butsu") or IsAddOnLoaded("LovelyLoot") or IsAddOnLoaded("XLoot")) then
		local slotsize = 36
		lootSlots = {}
		local anchorframe = CreateFrame("Frame", "ItemLoot", UIParent)
		anchorframe:SetSize(200, 15)
		anchorframe:SetPoint("TOPLEFT", 300, -300)
		-- if UIMovableFrames then tinsert(UIMovableFrames, anchorframe) end

		local function OnClick(self)
			if IsModifiedClick() then
				HandleModifiedItemClick(GetLootSlotLink(self.id))
			else
				StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
				LootFrame.selectedSlot = self.id
				LootFrame.selectedQuality = self.quality
				LootFrame.selectedItemName = self.text:GetText()
				LootSlot(self.id)
			end
		end

		local function OnEnter(self)
			if LootSlotIsItem(self.id) then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetLootItem(self.id)
				CursorUpdate(self)
			end
		end

		local function OnLeave(self)
			GameTooltip:Hide()
			ResetCursor()
		end

		local function CreateLootSlot(self, id)
			local slot = CreateFrame("Button", nil, self)
			slot:SetPoint("TOPLEFT", 3, -20 - (id - 1) * (slotsize + 5))
			slot:SetSize(slotsize, slotsize)
			slot:SetBackdrop({
					bgFile = R["media"].blank, 
					insets = { left = -R.mult, right = -R.mult, top = -R.mult, bottom = -R.mult }
				})
			slot:StyleButton()
			slot.texture = slot:CreateTexture(nil, "BORDER")
			slot.texture:Point("TOPLEFT", 2, -2)
			slot.texture:Point("BOTTOMRIGHT", -2, 2)
			slot.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			slot.text = slot:CreateFontString(nil, "OVERLAY")
			slot.text:SetFont(R["media"].font, R["media"].fontsize, R["media"].fontflag)
			slot.text:SetPoint("LEFT", slot, "RIGHT", 4, 0)
			slot.text:SetPoint("RIGHT", slot:GetParent(), "RIGHT", -4, 0)
			slot.text:SetJustifyH("LEFT")
			slot.glow = CreateFrame("Frame", nil, slot)
			slot.glow:SetAllPoints()
			slot.glow:CreateBorder()
			slot.count = slot:CreateFontString(nil, "OVERLAY")
			slot.count:SetFont(R["media"].font, R["media"].fontsize, R["media"].fontflag)
			slot.count:SetPoint("BOTTOMRIGHT", 0, 0)
			slot.quest = slot:CreateFontString(nil, "OVERLAY")
			slot.quest:SetFont(R["media"].pxfont, 30, R["media"].fontflag)
			slot.quest:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
			slot.quest:SetShadowOffset(R.mult, -R.mult)
			slot.quest:SetShadowColor(0, 0, 0)
			slot.quest:SetPoint("TOPRIGHT", 2, 6)
			slot:SetScript("OnClick", OnClick)
			slot:SetScript("OnEnter", OnEnter)
			slot:SetScript("OnLeave", OnLeave)
			slot:Hide()
			return slot
		end

		local function GetLootSlot(self, id)
			if not lootSlots[id] then 
				lootSlots[id] = CreateLootSlot(self, id)
			end
			return lootSlots[id]
		end

		local function UpdateLootSlot(self, id)
			local lootSlot = GetLootSlot(self, id)
			local texture, item, quantity, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(id)
			local color = ITEM_QUALITY_COLORS[quality]
			lootSlot.quality = quality
			lootSlot.id = id
			lootSlot.texture:SetTexture(texture)
			lootSlot.text:SetText(item)
			lootSlot.text:SetTextColor(color.r, color.g, color.b)
			if quantity > 1 then
				lootSlot.count:SetText(quantity)
				lootSlot.count:Show()
			else
				lootSlot.count:Hide()
			end
			if isActive == false then
				lootSlot.quest:SetText("!")
			else
				lootSlot.quest:SetText("")
			end
			local glow = lootSlot.glow
			if quality and quality > 1 then
				glow:SetAllPoints()
				glow:SetBackdropBorderColor(color.r, color.g, color.b)
				lootSlot:SetBackdropColor(0, 0, 0)
			else
				glow:SetBackdropBorderColor(0, 0, 0)
				glow:Point("TOPLEFT", 1, -1)
				glow:Point("BOTTOMRIGHT", -1, 1)
				lootSlot:SetBackdropColor(0, 0, 0, 0)
			end
			if R:IsItemUnusable(GetLootSlotLink(id)) or locked then
				lootSlot.texture:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
			else
				lootSlot.texture:SetVertexColor(1, 1, 1)
			end		
			lootSlot:Show()
		end

		local function OnEvent(self, event, ...)
			if event == "LOOT_OPENED" then
				local autoLoot = ...
				self:Show()
				if UnitExists("target") and UnitIsDead("target") then
					self.title:SetText(UnitName("target"))
				else
					self.title:SetText(ITEMS)
				end
				local numLootItems = GetNumLootItems()
				self:SetHeight(numLootItems * (slotsize + 5) + 20)
				if GetCVar("lootUnderMouse") == "1" then
					local x, y = GetCursorPosition()
					x = x / self:GetEffectiveScale()
					y = y / self:GetEffectiveScale()
					local posX = x - 15
					local posY = y + 32
					if posY < 350 then
						posY = 350
					end
					self:ClearAllPoints()
					self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", posX, posY)
					self:GetCenter()
					self:Raise()
				end
				for i = 1, numLootItems do
					UpdateLootSlot(self, i)
				end
				if not self:IsShown() then
					CloseLoot(autoLoot == 0)
				end
			elseif event == "LOOT_SLOT_CLEARED" then
				local slotId = ...
				if not self:IsShown() then return end
				if slotId > 0 then
					if lootSlots[slotId] then
						lootSlots[slotId]:Hide()
					end
				end
			elseif event == "LOOT_SLOT_CHANGED" then
				local slotId = ...
				UpdateLootSlot(self, slotId)
			elseif event == "LOOT_CLOSED" then
				StaticPopup_Hide("LOOT_BIND")
				for i, v in pairs(lootSlots) do
					v:Hide()
				end
				self:Hide()
			elseif event == "OPEN_MASTER_LOOT_LIST" then
				ToggleDropDownMenu(1, nil, GroupLootDropDown, lootSlots[LootFrame.selectedSlot], 0, 0)
			elseif event == "UPDATE_MASTER_LOOT_LIST" then
				UIDropDownMenu_Refresh(GroupLootDropDown)
			end
		end


		local loot = CreateFrame("Frame", nil, UIParent)
		loot:SetScript("OnEvent", OnEvent)
		loot:RegisterEvent("LOOT_OPENED")
		loot:RegisterEvent("LOOT_SLOT_CLEARED")
		loot:RegisterEvent("LOOT_SLOT_CHANGED")
		loot:RegisterEvent("LOOT_CLOSED")
		loot:RegisterEvent("OPEN_MASTER_LOOT_LIST")
		loot:RegisterEvent("UPDATE_MASTER_LOOT_LIST")
		LootFrame:UnregisterAllEvents()
		
		S:CreateBD(loot)
		loot:SetWidth(200)
		loot:SetPoint("TOP", anchorframe, 0, 0)
		loot:SetFrameStrata("HIGH")
		loot:SetToplevel(true)
		loot:EnableMouse(true)
		loot:SetMovable(true)
		loot:RegisterForDrag("LeftButton")
		loot:SetScript("OnDragStart", function(self) self:StartMoving() self:SetUserPlaced(false) end)
		loot:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
		loot.title = loot:CreateFontString(nil, "OVERLAY")
		loot.title:SetFont(R["media"].font, R["media"].fontsize, R["media"].fontflag)
		loot.title:SetPoint("TOPLEFT", 3, -4)
		loot.title:SetPoint("TOPRIGHT", -16, -4)
		loot.title:SetJustifyH("LEFT")
		loot.button = CreateFrame("Button", nil, loot)
		loot.button:SetPoint("TOPRIGHT")
		loot.button:SetSize(20, 20)
		S:ReskinClose(loot.button)
		loot.button:SetScript("OnClick", function()
			CloseLoot()
		end)
	end
end

S:RegisterSkin("RayUI", LoadSkin)