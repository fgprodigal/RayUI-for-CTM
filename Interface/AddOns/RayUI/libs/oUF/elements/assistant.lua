--[[ Element: Assistant Icon
 Toggles visibility of `self.Assistant` based on the units raid officer status.

 Widget

 Assistant - Any UI widget.

 Notes

 The default assistant icon will be applied if the UI widget is a texture and
 doesn't have a texture or color defined.

 Examples

   -- Position and size
   local Assistant = self:CreateTexture(nil, "OVERLAY")
   Assistant:SetSize(16, 16)
   Assistant:SetPoint('TOP', self)
   
   -- Register it with oUF
   self.Assistant = Assistant

 Hooks

 Override(self) - Used to completely override the internal update function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.
]]

local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event)
	local assistant = self.Assistant

	if(assistant.PreUpdate) then
		assistant:PreUpdate()
	end

	local unit = self.unit
	local isAssistant = UnitInRaid(unit) and UnitIsRaidOfficer(unit) and not UnitIsPartyLeader(unit)
	if(isAssistant) then
		assistant:Show()
	else
		assistant:Hide()
	end

	if(assistant.PostUpdate) then
		return assistant:PostUpdate(isAssistant)
	end
end

local Path = function(self, ...)
	return (self.Assistant.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self)
	local assistant = self.Assistant
	if(assistant) then
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", Path, true)

		if(assistant:IsObjectType"Texture" and not assistant:GetTexture()) then
			assistant:SetTexture[[Interface\GroupFrame\UI-Group-AssistantIcon]]
		end

		assistant.__owner = self
		assistant.ForceUpdate = ForceUpdate

		return true
	end
end

local Disable = function(self)
	local assistant = self.Assistant
	if(assistant) then
		self:UnregisterEvent("PARTY_MEMBERS_CHANGED", Path)
	end
end

oUF:AddElement('Assistant', Path, Enable, Disable)
