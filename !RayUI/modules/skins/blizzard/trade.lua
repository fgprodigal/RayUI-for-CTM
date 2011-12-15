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
				
				tradeItemButton:StyleButton()
				tradeItemButton:GetHighlightTexture():SetAllPoints()
				tradeItemButton:GetPushedTexture():SetAllPoints()
				
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
				tradeItemButton:SetBackdrop({
					bgFile = C["media"].blank, 
					insets = { left = -R.mult, right = -R.mult, top = -R.mult, bottom = -R.mult }
				})
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
		button:SetBackdropColor(0, 0, 0, 0)
		if(link) then
			local r, g, b
			local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(link)

			if R.IsItemUnusable(link) then
				icontexture:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
			else
				icontexture:SetVertexColor(1, 1, 1)
			end
			r, g, b = GetItemQualityColor(quality)
			if (quality <=1 ) then
				r, g, b = 0, 0, 0
				icontexture:SetAllPoints()
				button:SetBackdropColor(0, 0, 0, 0)
			else
				icontexture:Point("TOPLEFT", 1, -1)
				icontexture:Point("BOTTOMRIGHT", -1, 1)
				button:SetBackdrop({
					bgFile = C["media"].blank, 
					insets = { left = -R.mult, right = -R.mult, top = -R.mult, bottom = -R.mult }
				})
				button:SetBackdropColor(0, 0, 0)
			end
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
		button:SetBackdropColor(0, 0, 0, 0)
		if(link) then
			local r, g, b
			local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(link)

			if R.IsItemUnusable(link) then
				icontexture:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
			else
				icontexture:SetVertexColor(1, 1, 1)
			end		
			r, g, b = GetItemQualityColor(quality)
			if (quality <=1 ) then
				r, g, b = 0, 0, 0
				icontexture:SetAllPoints()
			else
				icontexture:Point("TOPLEFT", 1, -1)
				icontexture:Point("BOTTOMRIGHT", -1, 1)
				button:SetBackdrop({
					bgFile = C["media"].blank, 
					insets = { left = -R.mult, right = -R.mult, top = -R.mult, bottom = -R.mult }
				})
				button:SetBackdropColor(0, 0, 0)
			end
			glow:SetBackdropBorderColor(r, g, b)
			glow:Show()
		else
			glow:Hide()
		end
	end)
end

tinsert(R.SkinFuncs[AddOnName], LoadSkin)