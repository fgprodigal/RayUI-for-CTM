local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.SetBD(GMSurveyFrame, 0, 0, -32, 4)
	R.CreateBD(GMSurveyCommentFrame, .25)
	for i = 1, 11 do
		R.CreateBD(_G["GMSurveyQuestion"..i], .25)
	end

	for i = 1, 11 do
		select(i, GMSurveyFrame:GetRegions()):Hide()
	end
	GMSurveyHeaderLeft:Hide()
	GMSurveyHeaderRight:Hide()
	GMSurveyHeaderCenter:Hide()
	GMSurveyScrollFrameTop:SetAlpha(0)
	GMSurveyScrollFrameMiddle:SetAlpha(0)
	GMSurveyScrollFrameBottom:SetAlpha(0)
	R.Reskin(GMSurveySubmitButton)
	R.Reskin(GMSurveyCancelButton)
	R.ReskinClose(GMSurveyCloseButton, "TOPRIGHT", GMSurveyFrame, "TOPRIGHT", -36, -4)
	R.ReskinScroll(GMSurveyScrollFrameScrollBar)
end

R.SkinFuncs["Blizzard_GMSurveyUI"] = LoadSkin