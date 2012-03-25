local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local S = R:GetModule("Skins")

local function LoadSkin()
	----AchievementAlertFrame_ShowAlert(50)  测试位置
	local AchievementHolder = CreateFrame("Frame", "AchievementHolder", UIParent)
	AchievementHolder:SetWidth(180)
	AchievementHolder:SetHeight(20)
	AchievementHolder:SetPoint("CENTER", UIParent, "CENTER", 0, 170)

	local function AchievementMove(self, event, ...)
		local previousFrame
		for i=1, MAX_ACHIEVEMENT_ALERTS do
			local aFrame = _G["AchievementAlertFrame"..i]
			if _G["AchievementAlertFrame"..i.."Unlocked"] then
				_G["AchievementAlertFrame"..i.."Unlocked"]:SetTextColor(1,1,1)
			end
			if ( aFrame ) then
				aFrame:ClearAllPoints()
				if ( previousFrame and previousFrame:IsShown() ) then
					aFrame:SetPoint("TOP", previousFrame, "BOTTOM", 0, -10)
				else
					aFrame:SetPoint("TOP", AchievementHolder, "BOTTOM")
				end
				previousFrame = aFrame
			end
		end
		
	end

	hooksecurefunc("AchievementAlertFrame_FixAnchors", AchievementMove)

	hooksecurefunc("DungeonCompletionAlertFrame_FixAnchors", function()
		for i=MAX_ACHIEVEMENT_ALERTS, 1, -1 do
			local aFrame = _G["AchievementAlertFrame"..i]
			if ( aFrame and aFrame:IsShown() ) then
				DungeonCompletionAlertFrame1:ClearAllPoints()
				DungeonCompletionAlertFrame1:SetPoint("TOP", aFrame, "BOTTOM", 0, -10)
				return
			end		
			DungeonCompletionAlertFrame1:ClearAllPoints()	
			DungeonCompletionAlertFrame1:SetPoint("TOP", AchievementHolder, "BOTTOM")
		end
	end)

	local achieveframe = CreateFrame("Frame")
	achieveframe:RegisterEvent("ACHIEVEMENT_EARNED")
	achieveframe:SetScript("OnEvent", function(self, event, ...) AchievementMove(self, event, ...) end)
	
	S:SetBD(DungeonCompletionAlertFrame1, 6, -14, -6, 6)

	DungeonCompletionAlertFrame1DungeonTexture:SetDrawLayer("ARTWORK")
	DungeonCompletionAlertFrame1DungeonTexture:SetTexCoord(.02, .98, .02, .98)
	S:CreateBG(DungeonCompletionAlertFrame1DungeonTexture)

	for i = 2, 6 do
		select(i, DungeonCompletionAlertFrame1:GetRegions()):Hide()
	end

	hooksecurefunc("DungeonCompletionAlertFrame_ShowAlert", function()
		for i = 1, 3 do
			local bu = _G["DungeonCompletionAlertFrame1Reward"..i]
			if bu and not bu.reskinned then
				local ic = _G["DungeonCompletionAlertFrame1Reward"..i.."Texture"]
				_G["DungeonCompletionAlertFrame1Reward"..i.."Border"]:Hide()

				ic:SetTexCoord(.08, .92, .08, .92)
				S:CreateBG(ic)

				bu.rekinned = true
			end
		end
		for i = 2, 6 do
			select(i, DungeonCompletionAlertFrame1:GetRegions()):Hide()
		end
	end)
	
	--Guild Alert
	--/run GuildChallengeAlertFrame_ShowAlert(3, 2, 5)
	hooksecurefunc("GuildChallengeAlertFrame_FixAnchors", function()
		local aFrame
		for i=MAX_ACHIEVEMENT_ALERTS, 1, -1 do
			if _G["AchievementAlertFrame"..i] and _G["AchievementAlertFrame"..i]:IsShown() then
				aFrame = _G["AchievementAlertFrame"..i]
			end
		end
		
		if DungeonCompletionAlertFrame1:IsShown() then
			aFrame = DungeonCompletionAlertFrame1
		end
		
		if aFrame == nil then
			aFrame = AchievementHolder
		end
		
		GuildChallengeAlertFrame:ClearAllPoints()
		if pos == "TOP" then
			GuildChallengeAlertFrame:SetPoint("TOP", aFrame, "BOTTOM", 0, -10)
		else
			GuildChallengeAlertFrame:SetPoint("BOTTOM", aFrame, "TOP", 0, 10)
		end
	end)
	
	for i=1, GuildChallengeAlertFrame:GetNumRegions() do
		local region = select(i, GuildChallengeAlertFrame:GetRegions()) 
		if region and region:GetObjectType() == "Texture" and not region:GetName() then
			region:SetTexture(nil)
		end
	end
	
	S:SetBD(GuildChallengeAlertFrame)
	GuildChallengeAlertFrame:Height(65)
end

S:RegisterSkin("RayUI", LoadSkin)