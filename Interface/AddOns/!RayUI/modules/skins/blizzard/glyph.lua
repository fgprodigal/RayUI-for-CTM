local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	local r, g, b = C.Aurora.classcolours[R.myclass].r, C.Aurora.classcolours[R.myclass].g, C.Aurora.classcolours[R.myclass].b
	GlyphFrameBackground:Hide()
	GlyphFrameSideInset:DisableDrawLayer("BACKGROUND")
	GlyphFrameSideInset:DisableDrawLayer("BORDER")
	GlyphFrameClearInfoFrameIcon:Point("TOPLEFT", 1, -1)
	GlyphFrameClearInfoFrameIcon:Point("BOTTOMRIGHT", -1, 1)
	R.CreateBD(GlyphFrameClearInfoFrame)
	GlyphFrameClearInfoFrameIcon:SetTexCoord(.08, .92, .08, .92)

	for i = 1, 3 do
		_G["GlyphFrameHeader"..i.."Left"]:Hide()
		_G["GlyphFrameHeader"..i.."Middle"]:Hide()
		_G["GlyphFrameHeader"..i.."Right"]:Hide()

	end

	for i = 1, 12 do
		local bu = _G["GlyphFrameScrollFrameButton"..i]
		local ic = _G["GlyphFrameScrollFrameButton"..i.."Icon"]

		local bg = CreateFrame("Frame", nil, bu)
		bg:SetPoint("TOPLEFT", 38, -2)
		bg:SetPoint("BOTTOMRIGHT", 0, 2)
		bg:SetFrameLevel(bu:GetFrameLevel()-1)
		R.CreateBD(bg, .25)

		_G["GlyphFrameScrollFrameButton"..i.."Name"]:SetParent(bg)
		_G["GlyphFrameScrollFrameButton"..i.."TypeName"]:SetParent(bg)
		bu:StyleButton()
		select(3, bu:GetRegions()):SetAlpha(0)
		select(4, bu:GetRegions()):SetAlpha(0)

		local check = select(2, bu:GetRegions())
		check:SetPoint("TOPLEFT", 39, -3)
		check:SetPoint("BOTTOMRIGHT", -1, 3)
		check:SetTexture(C.Aurora.backdrop)
		check:SetVertexColor(r, g, b, .2)

		R.CreateBG(ic)

		ic:SetTexCoord(.08, .92, .08, .92)
	end

	R.ReskinInput(GlyphFrameSearchBox)
	R.ReskinScroll(GlyphFrameScrollFrameScrollBar)
	R.ReskinDropDown(GlyphFrameFilterDropDown)
end

R.SkinFuncs["Blizzard_GlyphUI"] = LoadSkin