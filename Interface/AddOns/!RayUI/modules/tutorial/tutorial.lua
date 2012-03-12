local R, C, L, DB = unpack(select(2, ...))
local ADDON_NAME = ...

local function CreateTutorialFrame(name, parent, width, height, text)
	local frame = CreateFrame("Frame", name, parent, "GlowBoxTemplate")
	frame:SetSize(width, height)	
	frame:SetFrameStrata("FULLSCREEN_DIALOG")

	local arrow = CreateFrame("Frame", nil, frame, "GlowBoxArrowTemplate")
	arrow:SetPoint("TOP", frame, "BOTTOM", 0, 4)

	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetJustifyH("CENTER")
	frame.text:SetSize(width - 20, height - 20)
	frame.text:SetFontObject(GameFontHighlightLeft)
	frame.text:SetPoint("CENTER")
	frame.text:SetText(text)
	frame.text:SetSpacing(4)

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", 6, 6)
	R.ReskinClose(close)
	
	return frame
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event)
	if not R.SavePath.RayUIConfigTutorial then
		local tutorial1 = CreateTutorialFrame("RayUIConfigTutorial", GameMenuFrame, 220, 100, L["點擊進入RayUI控制台。\n請仔細研究每一項設置的作用。"])
		tutorial1:SetPoint("BOTTOM", RayUIConfigButton, "TOP", 0, 15)
	end
	f:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)