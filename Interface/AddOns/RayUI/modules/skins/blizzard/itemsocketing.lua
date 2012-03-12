local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local S = R:GetModule("Skins")

local function LoadSkin()
	S:SetBD(ItemSocketingFrame, 12, -8, -2, 24)
	select(2, ItemSocketingFrame:GetRegions()):Hide()
	ItemSocketingFramePortrait:Hide()
	ItemSocketingScrollFrameTop:SetAlpha(0)
	ItemSocketingScrollFrameBottom:SetAlpha(0)
	ItemSocketingSocket1Left:SetAlpha(0)
	ItemSocketingSocket1Right:SetAlpha(0)
	ItemSocketingSocket2Left:SetAlpha(0)
	ItemSocketingSocket2Right:SetAlpha(0)
	S:Reskin(ItemSocketingSocketButton)
	ItemSocketingSocketButton:ClearAllPoints()
	ItemSocketingSocketButton:SetPoint("BOTTOMRIGHT", ItemSocketingFrame, "BOTTOMRIGHT", -10, 28)
	S:ReskinClose(ItemSocketingCloseButton, "TOPRIGHT", ItemSocketingFrame, "TOPRIGHT", -6, -12)
	S:ReskinScroll(ItemSocketingScrollFrameScrollBar)
	
	for i = 1, MAX_NUM_SOCKETS  do
		local button = _G["ItemSocketingSocket"..i]
		button:StyleButton()
	end
end

S:RegisterSkin("Blizzard_ItemSocketingUI", LoadSkin)