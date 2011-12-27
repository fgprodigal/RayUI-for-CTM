local R, C, L, DB = unpack(select(2, ...))
local AddOnName = ...

local function LoadSkin()
	local r, g, b = C.Aurora.classcolours[R.myclass].r, C.Aurora.classcolours[R.myclass].g, C.Aurora.classcolours[R.myclass].b
	R.ReskinCheck(TokenFramePopupInactiveCheckBox)
	R.ReskinCheck(TokenFramePopupBackpackCheckBox)
	R.ReskinClose(TokenFramePopupCloseButton)
	TokenFramePopupCorner:Hide()
	TokenFramePopup:SetPoint("TOPLEFT", TokenFrame, "TOPRIGHT", 1, -28)
	TokenFrame:HookScript("OnShow", function()
		for i=1, GetCurrencyListSize() do
			local button = _G["TokenFrameContainerButton"..i]

			if button and not button.reskinned then
				button.highlight:SetPoint("TOPLEFT", 1, 0)
				button.highlight:SetPoint("BOTTOMRIGHT", -1, 0)
				button.highlight.SetPoint = R.dummy
				button.highlight:SetTexture(r, g, b, .2)
				button.highlight.SetTexture = R.dummy
				button.categoryMiddle:SetAlpha(0)	
				button.categoryLeft:SetAlpha(0)	
				button.categoryRight:SetAlpha(0)

				if button.icon and button.icon:GetTexture() then
					button.icon:SetTexCoord(.08, .92, .08, .92)
					R.CreateBG(button.icon)
				end
				button.reskinned = true
			end
		end
	end)
end

tinsert(R.SkinFuncs[AddOnName], LoadSkin)