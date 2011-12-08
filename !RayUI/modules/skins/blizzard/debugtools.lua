local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	ScriptErrorsFrame:SetScale(UIParent:GetScale())
	ScriptErrorsFrame:SetSize(386, 274)
	ScriptErrorsFrame:DisableDrawLayer("OVERLAY")
	ScriptErrorsFrameTitleBG:Hide()
	ScriptErrorsFrameDialogBG:Hide()
	R.CreateBD(ScriptErrorsFrame)
	R.CreateSD(ScriptErrorsFrame)
	
	R.CreateBD(EventTraceFrame)
	R.CreateSD(EventTraceFrame)
	R.ReskinClose(EventTraceFrameCloseButton)
	select(1, EventTraceFrameScroll:GetRegions()):Hide()
	local bu = select(2, EventTraceFrameScroll:GetRegions())
	bu:SetAlpha(0)
	bu:Width(17)

	bu.bg = CreateFrame("Frame", nil, EventTraceFrame)
	bu.bg:Point("TOPLEFT", bu, 0, 0)
	bu.bg:Point("BOTTOMRIGHT", bu, 0, 0)
	R.CreateBD(bu.bg, 0)

	local tex = EventTraceFrame:CreateTexture(nil, "BACKGROUND")
	tex:Point("TOPLEFT", bu.bg)
	tex:Point("BOTTOMRIGHT", bu.bg)
	tex:SetTexture(C.Aurora.backdrop)
	tex:SetGradientAlpha("VERTICAL", 0, 0, 0, .3, .35, .35, .35, .35)
	
	FrameStackTooltip:SetScale(UIParent:GetScale())
	FrameStackTooltip:SetBackdrop(nil)

	local bg = CreateFrame("Frame", nil, FrameStackTooltip)
	bg:SetPoint("TOPLEFT")
	bg:SetPoint("BOTTOMRIGHT")
	bg:SetFrameLevel(FrameStackTooltip:GetFrameLevel()-1)
	R.CreateBD(bg, .6)

	R.ReskinClose(ScriptErrorsFrameClose)
	R.ReskinScroll(ScriptErrorsFrameScrollFrameScrollBar)
	R.Reskin(select(4, ScriptErrorsFrame:GetChildren()))
	R.Reskin(select(5, ScriptErrorsFrame:GetChildren()))
	R.Reskin(select(6, ScriptErrorsFrame:GetChildren()))
	
	local texs = {
		"TopLeft",
		"TopRight",
		"Top",
		"BottomLeft",
		"BottomRight",
		"Bottom",
		"Left",
		"Right",
		"TitleBG",
		"DialogBG",
	}
	
	for i=1, #texs do
		_G["ScriptErrorsFrame"..texs[i]]:SetTexture(nil)
		_G["EventTraceFrame"..texs[i]]:SetTexture(nil)
	end
end

R.SkinFuncs["Blizzard_DebugTools"] = LoadSkin