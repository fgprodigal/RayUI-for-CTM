local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.SetBD(VoidStorageFrame, 20, 0, 0, 20)
	VoidStorageBorderFrame:DisableDrawLayer("BORDER")
	VoidStorageDepositFrame:DisableDrawLayer("BACKGROUND")
	VoidStorageDepositFrame:DisableDrawLayer("BORDER")
	VoidStorageWithdrawFrame:DisableDrawLayer("BACKGROUND")
	VoidStorageWithdrawFrame:DisableDrawLayer("BORDER")
	VoidStorageCostFrame:DisableDrawLayer("BACKGROUND")
	VoidStorageCostFrame:DisableDrawLayer("BORDER")
	VoidStorageStorageFrame:DisableDrawLayer("BACKGROUND")
	VoidStorageStorageFrame:DisableDrawLayer("BORDER")
	VoidStorageFrameMarbleBg:Hide()
	select(2, VoidStorageFrame:GetRegions()):Hide()
	VoidStorageFrameLines:Hide()
	VoidStorageBorderFrameTitleBg:Hide()
	VoidStorageBorderFrameTopLeftCorner:Hide()
	VoidStorageBorderFrameTopBorder:Hide()
	VoidStorageBorderFrameTopRightCorner:Hide()
	VoidStorageBorderFrameTopEdge:Hide()
	VoidStorageBorderFrameHeader:Hide()
	VoidStorageStorageFrameLine1:Hide()
	VoidStorageStorageFrameLine2:Hide()
	VoidStorageStorageFrameLine3:Hide()
	VoidStorageStorageFrameLine4:Hide()
	select(12, VoidStorageDepositFrame:GetRegions()):Hide()
	select(12, VoidStorageWithdrawFrame:GetRegions()):Hide()

	for i = 1, 9 do
		local bu1 = _G["VoidStorageDepositButton"..i]
		local bu2 = _G["VoidStorageWithdrawButton"..i]

		_G["VoidStorageDepositButton"..i.."Bg"]:Hide()
		_G["VoidStorageWithdrawButton"..i.."Bg"]:Hide()

		_G["VoidStorageDepositButton"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
		_G["VoidStorageWithdrawButton"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)

		local bg1 = CreateFrame("Frame", nil, bu1)
		bg1:SetPoint("TOPLEFT", -1, 1)
		bg1:SetPoint("BOTTOMRIGHT", 1, -1)
		bg1:SetFrameLevel(bu1:GetFrameLevel()-1)
		R.CreateBD(bg1, .25)

		local bg2 = CreateFrame("Frame", nil, bu2)
		bg2:SetPoint("TOPLEFT", -1, 1)
		bg2:SetPoint("BOTTOMRIGHT", 1, -1)
		bg2:SetFrameLevel(bu2:GetFrameLevel()-1)
		R.CreateBD(bg2, .25)
	end

	for i = 1, 80 do
		local bu = _G["VoidStorageStorageButton"..i]

		_G["VoidStorageStorageButton"..i.."Bg"]:Hide()
		_G["VoidStorageStorageButton"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)

		local bg = CreateFrame("Frame", nil, bu)
		bg:SetPoint("TOPLEFT", -1, 1)
		bg:SetPoint("BOTTOMRIGHT", 1, -1)
		bg:SetFrameLevel(bu:GetFrameLevel()-1)
		R.CreateBD(bg, .25)
	end

	R.Reskin(VoidStoragePurchaseButton)
	R.Reskin(VoidStorageHelpBoxButton)
	R.Reskin(VoidStorageTransferButton)
	R.ReskinClose(VoidStorageBorderFrameCloseButton)
	R.ReskinInput(VoidItemSearchBox)
end

R.SkinFuncs["Blizzard_VoidStorageUI"] = LoadSkin