local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local CH = R:GetModule("Chat")

local isMoving = false
local hasNew = false
local timeout = 0
local whentoshow={
		"say", "emote", "text_emote", "yell", "loot",
		"monster_emote", "monster_party", "monster_say", "monster_whisper", "monster_yell",
		"party", "party_leader", "party_guide",
		"whisper", "system", "channel",
		"guild", "officer",
		"battleground", "battleground_leader",
		"raid", "raid_leader", "raid_warning",	
		"bn_whisper",
		"bn_inline_toast_alert",
		"bn_inline_toast_broadcast",
}
local channelNumbers = {
	[1] = true,
	[2] = true,
	[3]  = true,
	[4]  = true,
}
CH.Updater = CreateFrame("Frame")
CH.ChatIn = true

function CH:SetUpAnimGroup(self)
	self.anim = self:CreateAnimationGroup("Flash")
	self.anim.fadein = self.anim:CreateAnimation("ALPHA", "FadeIn")
	self.anim.fadein:SetChange(1)
	self.anim.fadein:SetOrder(2)

	self.anim.fadeout = self.anim:CreateAnimation("ALPHA", "FadeOut")
	self.anim.fadeout:SetChange(-1)
	self.anim.fadeout:SetOrder(1)
end

function CH:Flash(self, duration)
	if not self.anim then
		CH:SetUpAnimGroup(self)
	end

	self.anim.fadein:SetDuration(duration)
	self.anim.fadeout:SetDuration(duration)
	self.anim:Play()
end

function CH:StopFlash(self)
	if self.anim then
		self.anim:Finish()
	end
end

function CH:MoveOut()
	local nowwidth = 15
	local all = .7
	local allwidth = CH.db.width
	CH.ChatIn = false
	CH.Updater:SetScript("OnUpdate",function(self,elapsed)	
		if nowwidth > -CH.db.width then
			isMoving = true
			nowwidth = nowwidth-allwidth/(all/0.2)/8
			ChatBG:ClearAllPoints()			
			ChatBG:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",nowwidth,30)
		else
			isMoving = false
			ChatBG:ClearAllPoints()
			ChatBG:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",-CH.db.width - 2,30)
			self:SetScript("OnUpdate", nil)
		end
	end)
	UIFrameFadeOut(ChatBG, .7, 1, 0)
	ChatFrame1EditBox:Hide()
end

function CH:MoveIn()
	local nowwidth = -CH.db.width
	local all = .7  ---all time
	local allwidth = CH.db.width
	CH.ChatIn = true
	CH.Updater:SetScript("OnUpdate",function(self,elapsed)	
		if nowwidth <15 then
			isMoving = true
			nowwidth = nowwidth+allwidth/(all/0.2)/8
			ChatBG:ClearAllPoints()			
			ChatBG:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",nowwidth,30)
		else
			isMoving = false
			ChatBG:ClearAllPoints()
			ChatBG:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",15,30)
			self:SetScript("OnUpdate", nil)
		end
	end)
	UIFrameFadeIn(ChatBG, .7, 0, 1)
end

function CH:ToggleChat()
	timeout = 0
	if CH.ChatIn == true then
		CH:MoveOut()
	else
		CH:MoveIn()
	end
end

function CH:OnEvent(event, ...)
	if(event == "CHAT_MSG_CHANNEL" and channelNumbers and not channelNumbers[select(8,...)]) then return end
	timeout = 0
	if CH.ChatIn == false then
		if isMoving then
			isMoving = false
			CH.Updater:SetScript("OnUpdate", nil)
		end
		ChatBG:ClearAllPoints()
		ChatBG:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",15,30)
		UIFrameFadeIn(ChatBG, .7, 0, 1)
		CH.ChatIn = true
		hasNew = false
	end
end

function CH:OnUpdate()
	timeout = timeout + 1
	if timeout>CH.db.autohidetime and CH.ChatIn == true and not ChatFrame1EditBox:IsShown() and not InCombatLockdown() then
		CH:MoveOut()
	end
end

function CH:AutoHide()
	if not self.db.autoshow then
		self:SetUpAnimGroup(RayUIBottomInfoBar.shadow)
		local function CheckWhisperWindows(self, event)
			local chat = self:GetName()
			if chat == "ChatFrame1" and CH.ChatIn == false then
				if event == "CHAT_MSG_WHISPER" then
					hasNew = true
					ChatToggle:SetAlpha(1)
					ChatToggle.shadow:SetBackdropBorderColor(ChatTypeInfo["WHISPER"].r,ChatTypeInfo["WHISPER"].g,ChatTypeInfo["WHISPER"].b, 1)
				elseif event == "CHAT_MSG_BN_WHISPER" then
					hasNew = true
					ChatToggle:SetAlpha(1)
					ChatToggle.shadow:SetBackdropBorderColor(ChatTypeInfo["BN_WHISPER"].r,ChatTypeInfo["BN_WHISPER"].g,ChatTypeInfo["BN_WHISPER"].b, 1)
				end
				ChatToggle:SetScript("OnUpdate", function(self)
					if not CH.ChatIn then
						CH:Flash(self.shadow, 1)
					else
						CH:StopFlash(self.shadow)
						self:SetScript('OnUpdate', nil)
						self.shadow:SetBackdropBorderColor(R["media"].backdropcolor) 
						self:SetAlpha(0)
						hasNew = false
					end
				end)
			end
		end
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", CheckWhisperWindows)	
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", CheckWhisperWindows)
	else
		for _, event in pairs(whentoshow) do
			if(not event:match("[A-Z]")) then
				event = "CHAT_MSG_"..event:upper()
			end
			self:RegisterEvent(event, "OnEvent")
		end
		self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
	end
	local ChatToggle = CreateFrame("Frame", "ChatToggle", UIParent)
	ChatToggle:CreatePanel("Default", 15, 140, "BOTTOMLEFT",UIParent,"BOTTOMLEFT", 0,30)
	ChatToggle:SetAlpha(0)
	ChatToggle:SetScript("OnEnter",function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
		GameTooltip:ClearLines()
		if CH.ChatIn then
			GameTooltip:AddLine(L["点击隐藏聊天栏"])
		else
			GameTooltip:AddLine(L["点击显示聊天栏"])
		end
		if not hasNew then
			UIFrameFadeIn(self, 0.5, self:GetAlpha(), 1)
		else
			GameTooltip:AddLine(L["有新的悄悄话"])
		end		
		GameTooltip:Show()
	end)
	ChatToggle:SetScript("OnLeave",function(self)
		if not hasNew then
			UIFrameFadeOut(self, 0.5, self:GetAlpha(), 0)
		end
		GameTooltip:Hide()
	end)
	ChatToggle:SetScript("OnMouseDown", function(self, btn)
		if btn == "LeftButton" then
			CH:ToggleChat()
		end
	end)
	ChatFrame1EditBox:HookScript("OnShow", function(self)
		timeout = 0
		if CH.ChatIn == false then
			if isMoving then
				isMoving = false
				CH.Updater:SetScript("OnUpdate", nil)
			end
			ChatBG:ClearAllPoints()
			ChatBG:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",15,30)
			UIFrameFadeIn(ChatBG, .7, 0, 1)
			CH.ChatIn = true
			hasNew = false
		end
	end)
	ChatFrame1EditBox:HookScript("OnHide", function(self)
		timeout = 0
	end)
	if self.db.autohide then
		self:ScheduleRepeatingTimer("OnUpdate", 1)
	end
end