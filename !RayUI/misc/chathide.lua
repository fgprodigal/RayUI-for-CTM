local R, C, DB = unpack(select(2, ...))

----------------------------------------------------------------------
-- Setup animating chat during combat
----------------------------------------------------------------------
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

R.SetUpAnimGroup(BottomInfoBar.shadow)
local function CheckWhisperWindows(self, event)
	local chat = self:GetName()
	if chat == "ChatFrame1" and R.ChatIn == false then
		if event == "CHAT_MSG_WHISPER" then
			BottomInfoBar.shadow:SetBackdropBorderColor(ChatTypeInfo["WHISPER"].r,ChatTypeInfo["WHISPER"].g,ChatTypeInfo["WHISPER"].b, 1)
		elseif event == "CHAT_MSG_BN_WHISPER" then
			BottomInfoBar.shadow:SetBackdropBorderColor(ChatTypeInfo["BN_WHISPER"].r,ChatTypeInfo["BN_WHISPER"].g,ChatTypeInfo["BN_WHISPER"].b, 1)
		end
		BottomInfoBar:SetScript("OnUpdate", function(self)
			if not R.ChatIn then
				R.Flash(self.shadow, 0.5)
			else
				R.StopFlash(self.shadow)
				self:SetScript('OnUpdate', nil)				
				R.Delay(1, function()
					self.shadow:SetBackdropBorderColor(C["media"].backdropcolor) 
				end)
			end
		end)
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", CheckWhisperWindows)	
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", CheckWhisperWindows)

-- R.ToggleChat = function()
	-- if R.ChatIn == true then
		-- ChatBG:Hide()
		-- R.ChatIn = false
	-- else
		-- ChatBG:Show()
		-- R.ChatIn = true
	-- end
-- end

-- BottomInfoBar:SetScript("OnMouseDown", function(self, btn)
	-- if btn == "LeftButton" then
		-- R.ToggleChat()
	-- end
-- end)