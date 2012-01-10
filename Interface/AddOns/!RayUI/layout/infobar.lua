local R, C, L, DB = unpack(select(2, ...))
local ADDON_NAME = ...

R.InfoBarStatusColor = {{1, 0, 0}, {1, 1, 0}, {0, 0.4, 1}}

local infobar= {}
local LastUpdate = 1
for i = 1,8 do
	if i == 1 then
		infobar[i] = CreateFrame("Frame", "BottomInfoBar", UIParent)
		infobar[i]:CreatePanel("Default", 400, 6, "BOTTOM", UIParent, "BOTTOM", 0, 10)
	elseif i == 2 then
		infobar[i] = CreateFrame("Frame", "TopInfoBar"..i-1, UIParent)
		infobar[i]:CreatePanel("Default", 80, 6, "TOPLEFT", UIParent, "TOPLEFT", 10, -10)
	else
		infobar[i] = CreateFrame("Frame", "TopInfoBar"..i-1, UIParent)
		infobar[i]:CreatePanel("Default", 80, 6, "LEFT", infobar[i-1], "RIGHT", 9, 0)
	end
	
	if i~= 1 then
		infobar[i].Status = CreateFrame("StatusBar", "TopInfoBarStatus"..i, infobar[i])
		infobar[i].Status:SetFrameLevel(12)
		infobar[i].Status:SetStatusBarTexture(C["media"].normal)
		infobar[i].Status:SetMinMaxValues(0, 100)
		infobar[i].Status:SetStatusBarColor(unpack(R.InfoBarStatusColor[3]))
		infobar[i].Status:SetAllPoints()
		infobar[i].Status:SetValue(100)
		
		infobar[i].Text = infobar[i].Status:CreateFontString(nil, "OVERLAY")
		infobar[i].Text:SetFont(C["media"].font, C["media"].fontsize, C["media"].fontflag)
		infobar[i].Text:Point("CENTER", infobar[i], "CENTER", 0, -4)
		infobar[i].Text:SetShadowColor(0, 0, 0, 0.4)
		infobar[i].Text:SetShadowOffset(R.mult, -R.mult)
	end
	infobar[i]:SetAlpha(0)
end

local infoshow = CreateFrame("Frame")
infoshow:RegisterEvent("PLAYER_ENTERING_WORLD")
infoshow:SetScript("OnEvent", function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		for i=1,#infobar do
			R.Delay((3+i*0.6),function()
				UIFrameFadeIn(infobar[i], 1, 0, 1)
			end)
		end
		if C["general"].logo then
			R.Delay(5,function() UIFrameFadeIn(RayUILogo, 1, 0, 1) end)
			R.Delay(8,function() UIFrameFadeOut(RayUILogo, 1, 1, 0) end)
			R.Delay(10,function() RayUILogo:Hide() RayUILogo=nil collectgarbage("collect") end)
		else
			R.Delay(5,function() collectgarbage("collect") end)
		end
end)

UIParent:SetScript("OnShow", function(self)
		UIFrameFadeIn(UIParent, 1, 0, 1)
	end)

--公会挑战框
GuildChallengeAlertFrame:Kill()


--实名好友弹窗位置
BNToastFrame:HookScript("OnShow", function(self)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 15, 240)
end)

if C["general"].logo then
	local logo = CreateFrame("Frame", "RayUILogo", UIParent)
	logo:SetScale(.9)
	logo:Hide()
	logo:SetSize(512,302)
	logo:SetPoint("CENTER", 0, 0)
	logo.shadow = CreateFrame("Frame", nil, logo)
	logo.shadow:SetPoint("TOPLEFT", -9, 6)
	logo.shadow:SetPoint("BOTTOMRIGHT", 9, -7)
	logo.shadow:SetBackdrop({
		bgFile = C.media.blank, 
		edgeFile = C.media.glow, 
		edgeSize = 12,
		insets = { left = 10, right = 10, top = 10, bottom = 10 }
		})
	logo.shadow:SetFrameStrata("BACKGROUND")
	logo.shadow:SetFrameLevel(1)
	logo.shadow:SetBackdropColor( 0, 0, 0 )
	logo.shadow:SetBackdropBorderColor( 0, 0, 0 )
	logo.logo = logo:CreateTexture(nil,"OVERLAY")
	logo.logo:SetPoint("CENTER", 0, 0)
	logo.logo:SetTexture("Interface\\AddOns\\!RayUI\\media\\logo")

	logo.text = logo:CreateFontString(nil, "OVERLAY")
	logo.text:SetFont(C.media.font, 20, "NONE")
	logo.text:SetTextColor(.2, .2, .2)
	logo.text:SetPoint("BOTTOM", 0, 20)
	logo.text:SetJustifyH("CENTER")
	logo.text:SetText("欢迎使用RayUI")

	logo.version = logo:CreateFontString(nil, "OVERLAY")
	logo.version:SetFont(C.media.font, 14, "NONE")
	logo.version:SetTextColor(.35, .35, .35)
	logo.version:SetPoint("BOTTOMRIGHT", -25, 15)
	logo.version:SetJustifyH("RIGHT")
	logo.version:SetText("v "..R.version)
end