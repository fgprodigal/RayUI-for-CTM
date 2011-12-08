local R, C, L, DB = unpack(select(2, ...))
local AddOnName = ...

local function LoadSkin()
	R.SetBD(GossipFrame, 6, -15, -26, 64)
	GossipFramePortrait:Hide()
	GossipFrameGreetingPanel:DisableDrawLayer("BACKGROUND")
	GossipFrameGreetingPanel:DisableDrawLayer("ARTWORK")
	
	GreetingText:SetTextColor(1, 1, 1)
	GreetingText.SetTextColor = R.dummy

	R.Reskin(GossipFrameGreetingGoodbyeButton)
	R.ReskinScroll(GossipGreetingScrollFrameScrollBar)
	R.ReskinClose(GossipFrameCloseButton, "TOPRIGHT", GossipFrame, "TOPRIGHT", -30, -20)
	hooksecurefunc("GossipFrameUpdate", function()
		for i=1, NUMGOSSIPBUTTONS do
			local text = _G["GossipTitleButton" .. i]:GetText()
			if text then
				text = string.gsub(text,"|cFF0008E8","|cFF0080FF")
				_G["GossipTitleButton" .. i]:SetText(text)
			end
		end
	end)

	R.SetBD(ItemTextFrame, 16, -8, -28, 62)
	ItemTextFrame:DisableDrawLayer("BORDER")
	
	ItemTextPageText:SetTextColor(1, 1, 1)
	ItemTextPageText.SetTextColor = R.dummy

	R.ReskinArrow(ItemTextPrevPageButton, 1)
	R.ReskinArrow(ItemTextNextPageButton, 2)
	ItemTextPrevPageButton:GetRegions():Hide()
	ItemTextNextPageButton:GetRegions():Hide()
	ItemTextFrame:GetRegions():Hide()
	ItemTextScrollFrameMiddle:Hide()
	ItemTextScrollFrameTop:Hide()
	ItemTextScrollFrameBottom:Hide()
	R.ReskinClose(ItemTextCloseButton, "TOPRIGHT", ItemTextFrame, "TOPRIGHT", -32, -12)
end

tinsert(R.SkinFuncs[AddOnName], LoadSkin)