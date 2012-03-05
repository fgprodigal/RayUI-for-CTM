local R, C, L, DB = unpack(select(2, ...))

local f = CreateFrame("Frame")

function f:PLAYER_ENTERING_WORLD()
	if UnitIsAFK("player") then
		SendChatMessage("","AFK")
	end
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")

f:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)