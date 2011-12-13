local R, C, L, DB = unpack(select(2, ...))

local holder = CreateFrame('Frame', nil, UIParent)
holder:Point('TOP', UIParent, 'TOP', 0, -150)
holder:Size(ExtraActionBarFrame:GetSize())
ExtraActionBarFrame:SetParent(holder)
ExtraActionBarFrame:ClearAllPoints()
ExtraActionBarFrame:SetPoint('CENTER', holder, 'CENTER')
UIPARENT_MANAGED_FRAME_POSITIONS.ExtraActionBarFrame = nil
UIPARENT_MANAGED_FRAME_POSITIONS.PlayerPowerBarAlt.extraActionBarFrame = nil
UIPARENT_MANAGED_FRAME_POSITIONS.CastingBarFrame.extraActionBarFrame = nil

R.CreateMover(holder, 'BossButton', 'BossButton', true)