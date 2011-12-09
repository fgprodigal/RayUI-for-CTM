local R, C, L, DB = unpack(select(2, ...))
local AddOnName = ...

local function LoadSkin()
	R.SetBD(TradeFrame, 10, -12, -30, 52)
	TradeFrameRecipientPortrait:Hide()
	TradeFramePlayerPortrait:Hide()
	for i = 3, 6 do
		select(i, TradeFrame:GetRegions()):Hide()
	end	
	R.Reskin(TradeFrameTradeButton)
	R.Reskin(TradeFrameCancelButton)
	R.ReskinClose(TradeFrameCloseButton, "TOPRIGHT", TradeFrame, "TOPRIGHT", -34, -16)

	-- Trade Button
	for i = 1,MAX_TRADE_ITEMS do
		for _, j in pairs({"TradePlayerItem", "TradeRecipientItem"}) do
			local tradeItemButton = _G[j..i.."ItemButton"]			
			if not tradeItemButton.reskinned then
				_G[j..i.."ItemButtonIconTexture"]:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				_G[j..i.."NameFrame"]:SetTexture(nil)

				if not tradeItemButton.nameframe then
					local nameframe = CreateFrame("Frame", nil, _G[j..i])
					nameframe:Point("TOPLEFT", _G[j..i.."NameFrame"], 11, -14)
					nameframe:Point("BOTTOMRIGHT", _G[j..i.."NameFrame"], -10, 14)
					nameframe:SetFrameLevel(_G[j..i]:GetFrameLevel())
					nameframe:SetFrameStrata(_G[j..i]:GetFrameStrata())
					R.CreateBD(nameframe)
					tradeItemButton.nameframe = nameframe
				end

				if tradeItemButton.SetHighlightTexture and not tradeItemButton.hover then
					local hover = tradeItemButton:CreateTexture("frame", nil, self)
					hover:SetTexture(1, 1, 1, 0.3)
					hover:Point('TOPLEFT', 0, -0)
					hover:Point('BOTTOMRIGHT', -0, 0)
					tradeItemButton.hover = hover
					tradeItemButton:SetHighlightTexture(hover)
				end
				
				if tradeItemButton.SetPushedTexture and not tradeItemButton.pushed then
					local pushed = tradeItemButton:CreateTexture("frame", nil, self)
					pushed:SetTexture(0.9, 0.8, 0.1, 0.3)
					pushed:Point('TOPLEFT', 0, -0)
					pushed:Point('BOTTOMRIGHT', -0, 0)
					tradeItemButton.pushed = pushed
					tradeItemButton:SetPushedTexture(pushed)
				end
				
				if tradeItemButton.SetCheckedTexture and not tradeItemButton.checked then
					local checked = tradeItemButton:CreateTexture("frame", nil, self)
					checked:SetTexture(23/255,132/255,209/255,0.5)
					checked:Point('TOPLEFT', 0, -0)
					checked:Point('BOTTOMRIGHT', -0, 0)
					tradeItemButton.checked = checked
					tradeItemButton:SetCheckedTexture(checked)
				end
				
				local cooldown = _G[tradeItemButton:GetName().."Cooldown"]
				if cooldown then
					cooldown:ClearAllPoints()
					cooldown:Point('TOPLEFT', 0, -0)
					cooldown:Point('BOTTOMRIGHT', -0, 0)
				end
				
				if not tradeItemButton.border then
					local border = CreateFrame("Frame", nil, tradeItemButton)
					border:Point("TOPLEFT", -1, 1)
					border:Point("BOTTOMRIGHT", 1, -1)
					border:SetFrameStrata("BACKGROUND")
					border:SetFrameLevel(0)
					tradeItemButton.border = border
					tradeItemButton.border:CreateBorder()
				end
				tradeItemButton:SetNormalTexture("")
				tradeItemButton:SetFrameStrata("HIGH")
				tradeItemButton.reskinned = true
			end
		end
	end
	R.ReskinInput(TradePlayerInputMoneyFrameGold)
	R.ReskinInput(TradePlayerInputMoneyFrameSilver)
	TradePlayerInputMoneyFrameSilver:ClearAllPoints()
	TradePlayerInputMoneyFrameSilver:Point("LEFT", TradePlayerInputMoneyFrameGold, "RIGHT", 1, 0)
	R.ReskinInput(TradePlayerInputMoneyFrameCopper)
	TradePlayerInputMoneyFrameCopper:ClearAllPoints()
	TradePlayerInputMoneyFrameCopper:Point("LEFT", TradePlayerInputMoneyFrameSilver, "RIGHT", 1, 0)
	
	-- item glow
	if not ItemGlowTooltip then
		local tooltip = CreateFrame("GameTooltip", "ItemGlowTooltip", UIParent, "GameTooltipTemplate")
		tooltip:SetOwner( UIParent, "ANCHOR_NONE" )
	end

	local function TooltipCanUse(tooltip)
		local l = { "TextLeft", "TextRight" }
		local n = tooltip:NumLines()
		if n > 5 then n = 5 end
		for i = 2, n do
			for _, v in pairs( l ) do
				local obj = _G[string.format( "%s%s%s", tooltip:GetName( ), v, i )]
				if obj and obj:IsShown( ) then
					local txt = obj:GetText( )
					local r, g, b = obj:GetTextColor( )
					local c = string.format( "%02x%02x%02x", r * 255, g * 255, b * 255 )
					if c == "fe1f1f" then
						if txt ~= ITEM_DISENCHANT_NOT_DISENCHANTABLE then
							return false
						end
					end
				end
			end
		end

		return true
	end

	local function UpdateGlow(button, id)
		local quality, texture, link, _
		local quest = _G[button:GetName().."IconQuestTexture"]
		local icontexture = _G[button:GetName().."IconTexture"]
		if(id) then
			_, link, quality, _, _, _, _, _, _, texture = GetItemInfo(id)
		end

		local glow = button.glow
		if(not glow) then
			button.glow = glow
			glow = CreateFrame("Frame", nil, button)
			glow:Point("TOPLEFT", -1, 1)
			glow:Point("BOTTOMRIGHT", 1, -1)
			glow:CreateBorder()
			button.glow = glow
		end

		if(texture) then
			local r, g, b
			ItemGlowTooltip:ClearLines()
			ItemGlowTooltip:SetHyperlink(link)
			
			-- if IsItemUnusable(link) then
			if not TooltipCanUse(ItemGlowTooltip) and not button:GetName():find("Inspect") then
				icontexture:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
			else
				icontexture:SetVertexColor(1, 1, 1)
			end	
			if quest and quest:IsShown() then
				r, g, b = 1, 0, 0
			else
				r, g, b = GetItemQualityColor(quality)
				if (quality <=1 ) then r, g, b = 0, 0, 0 end
			end
			glow:SetBackdropBorderColor(r, g, b)
			glow:Show()
		else
			glow:Hide()
		end
	end

	hooksecurefunc("TradeFrame_UpdatePlayerItem", function(id)
		local link = GetTradePlayerItemLink(id)
		local button = _G["TradePlayerItem"..id.."ItemButton"]
		local icontexture = _G["TradePlayerItem"..id.."ItemButtonIconTexture"]
		local glow = button.glow
		if(not glow) then
			button.glow = glow
			glow = CreateFrame("Frame", nil, button)
			glow:Point("TOPLEFT", -1, 1)
			glow:Point("BOTTOMRIGHT", 1, -1)
			glow:CreateBorder()
			button.glow = glow
		end
		if(link) then
			local r, g, b
			local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(link)
			ItemGlowTooltip:ClearLines()
			ItemGlowTooltip:SetHyperlink(link)
			
			-- if IsItemUnusable(link) then
			if not TooltipCanUse(ItemGlowTooltip) then
				icontexture:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
			else
				icontexture:SetVertexColor(1, 1, 1)
			end		
			r, g, b = GetItemQualityColor(quality)
			if (quality <=1 ) then r, g, b = 0, 0, 0 end
			glow:SetBackdropBorderColor(r, g, b)
			glow:Show()
		else
			glow:Hide()
		end
	end)

	hooksecurefunc("TradeFrame_UpdateTargetItem", function(id)
		local link = GetTradeTargetItemLink(id)
		local button = _G["TradeRecipientItem"..id.."ItemButton"]
		local icontexture = _G["TradeRecipientItem"..id.."ItemButtonIconTexture"]
		local glow = button.glow
		if(not glow) then
			button.glow = glow
			glow = CreateFrame("Frame", nil, button)
			glow:Point("TOPLEFT", -1, 1)
			glow:Point("BOTTOMRIGHT", 1, -1)
			glow:CreateBorder()
			button.glow = glow
		end
		if(link) then
			local r, g, b
			local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(link)
			ItemGlowTooltip:ClearLines()
			ItemGlowTooltip:SetHyperlink(link)
			
			-- if IsItemUnusable(link) then
			if not TooltipCanUse(ItemGlowTooltip) then
				icontexture:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
			else
				icontexture:SetVertexColor(1, 1, 1)
			end		
			r, g, b = GetItemQualityColor(quality)
			if (quality <=1 ) then r, g, b = 0, 0, 0 end
			glow:SetBackdropBorderColor(r, g, b)
			glow:Show()
		else
			glow:Hide()
		end
	end)
end

tinsert(R.SkinFuncs[AddOnName], LoadSkin)