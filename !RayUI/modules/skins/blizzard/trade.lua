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
end

tinsert(R.SkinFuncs[AddOnName], LoadSkin)