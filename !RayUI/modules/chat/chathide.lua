local R, C, L, DB = unpack(select(2, ...))
if not C["chat"].enable then return end

----------------------------------------------------------------------
-- Setup animating chat during combat
----------------------------------------------------------------------
local hasNew = false
local whentoshow={
		"say", "emote", "text_emote", "yell", 
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

R.ChatIn = true
R.SetUpAnimGroup = function(self)
	self.anim = self:CreateAnimationGroup("Flash")
	self.anim.fadein = self.anim:CreateAnimation("ALPHA", "FadeIn")
	self.anim.fadein:SetChange(1)
	self.anim.fadein:SetOrder(2)

	self.anim.fadeout = self.anim:CreateAnimation("ALPHA", "FadeOut")
	self.anim.fadeout:SetChange(-1)
	self.anim.fadeout:SetOrder(1)
end

R.Flash = function(self, duration)
	if not self.anim then
		R.SetUpAnimGroup(self)
	end

	self.anim.fadein:SetDuration(duration)
	self.anim.fadeout:SetDuration(duration)
	self.anim:Play()
end

R.StopFlash = function(self)
	if self.anim then
		self.anim:Finish()
	end
end

if not C["chat"].autoshow then
	R.SetUpAnimGroup(BottomInfoBar.shadow)
	local function CheckWhisperWindows(self, event)
		local chat = self:GetName()
		if chat == "ChatFrame1" and R.ChatIn == false then
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
				if not R.ChatIn then
					R.Flash(self.shadow, 1)
				else
					R.StopFlash(self.shadow)
					self:SetScript('OnUpdate', nil)				
					-- R.Delay(1, function()
					self.shadow:SetBackdropBorderColor(C["media"].backdropcolor) 
					self:SetAlpha(0)
					hasNew = false
					-- end)
				end
			end)
		end
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", CheckWhisperWindows)	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", CheckWhisperWindows)
end

local ChatToggle = CreateFrame("Frame", "ChatToggle", UIParent)
ChatToggle:CreatePanel("Default", 15, 140, "BOTTOMLEFT",UIParent,"BOTTOMLEFT", 0,30)
ChatToggle:SetAlpha(0)
ChatToggle:SetScript("OnEnter",function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
	GameTooltip:ClearLines()
	if R.ChatIn then
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

local LockToggle = false

function MoveOut()
	local nowwidth = 0
	local all = .7  ---all time
	local allwidth = C["chat"].width
	local finished = false
	local Updater = CreateFrame("Frame")	
	Updater:SetScript("OnUpdate",function(self,elapsed)	
		if nowwidth > -C["chat"].width then
			LockToggle = true
			nowwidth = nowwidth-allwidth/(all/0.2)/8
			ChatBG:ClearAllPoints()			
			ChatBG:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",nowwidth,30);	
		elseif not finished then
			LockToggle = false
			finished = true
			R.ChatIn = false
			ChatBG:ClearAllPoints()
			ChatBG:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",-C["chat"].width,30);	
		end
	end)
	UIFrameFadeOut(ChatBG, .7, 1, 0)
end

function MoveIn()
	local nowwidth = -C["chat"].width
	local all = .7  ---all time
	local allwidth = C["chat"].width
	local finished = false
	local Updater = CreateFrame("Frame")	
	Updater:SetScript("OnUpdate",function(self,elapsed)	
		if nowwidth <15 then
			LockToggle = true
			nowwidth = nowwidth+allwidth/(all/0.2)/8
			ChatBG:ClearAllPoints()			
			ChatBG:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",nowwidth,30);	
		elseif not finished then
			LockToggle = false
			finished = true
			R.ChatIn = true
			ChatBG:ClearAllPoints()
			ChatBG:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",15,30);	
		end
	end)
	UIFrameFadeIn(ChatBG, .7, 0, 1)
end

local timeout = 0

R.ToggleChat = function()
	timeout = 0
	if R.ChatIn == true then
		MoveOut()
	else
		MoveIn()
	end
end

ChatToggle:SetScript("OnMouseDown", function(self, btn)
	if btn == "LeftButton" and not LockToggle then
		R.ToggleChat()
	end
end)

local ChatAutoHide = CreateFrame("Frame")

if C["chat"].autoshow then	
	for _, event in pairs(whentoshow) do
		if(not event:match("[A-Z]")) then
			event = "CHAT_MSG_"..event:upper()
		end
		ChatAutoHide:RegisterEvent(event)
	end
	ChatAutoHide:RegisterEvent("PLAYER_REGEN_DISABLED")
	ChatAutoHide:SetScript("OnEvent", function(self, event, ...)
		if(event == "CHAT_MSG_CHANNEL" and channelNumbers and not channelNumbers[select(8,...)]) then return end
		timeout = 0
		if R.ChatIn == false then
			ChatBG:ClearAllPoints()
			ChatBG:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",15,30)
			UIFrameFadeIn(ChatBG, .7, 0, 1)
			R.ChatIn = true
			hasNew = false
		end
	end)
end

if C["chat"].autohide then
	ChatAutoHide:SetScript("OnUpdate", function(self, elapsed)
		timeout = timeout + elapsed
		if timeout>C["chat"].autohidetime and R.ChatIn == true and not ChatFrame1EditBox:IsShown() and not InCombatLockdown() then
			MoveOut()
			R.ChatIn = false
		end
	end)
end

ChatFrame1EditBox:HookScript("OnShow", function(self)
	timeout = 0
	if R.ChatIn == false and not LockToggle then
		-- MoveIn()
		ChatBG:ClearAllPoints()
		ChatBG:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",15,30)
		UIFrameFadeIn(ChatBG, .7, 0, 1)
		R.ChatIn = true
		hasNew = false
	elseif LockToggle then
		self:Hide()
	end
end)

ChatFrame1EditBox:HookScript("OnHide", function(self)
	timeout = 0
end)