local R, C, L, DB = unpack(select(2, ...))

local Stat = CreateFrame("Frame")
Stat:EnableMouse(true)
Stat:SetFrameStrata("BACKGROUND")
Stat:SetFrameLevel(3)

local Text  = BottomInfoBar:CreateFontString(nil, "OVERLAY")
Text:SetFont(C["media"].font, C["media"].fontsize, C["media"].fontflag)
Text:SetShadowOffset(1.25, -1.25)
Text:SetShadowColor(0, 0, 0, 0.4)
Text:SetPoint("BOTTOMLEFT", BottomInfoBar, "TOPLEFT", 10, -3)
Text:SetText(NONE..TALENTS)
Stat:SetParent(Text:GetParent())

local talentString = string.join("", "|cffFFFFFF%s:|r %d/%d/%d")
local spec = LibStub("Tablet-2.0")

local TalentInfo = {}
local function SpecChangeClickFunc(self, ...)
	if ... then
		if GetActiveTalentGroup() == ... then return end
	end
	
	if GetNumTalentGroups() > 1 then
		local NewTG = GetActiveTalentGroup() == 1 and 2 or 1
		
		-- if NewTG == 1 then
			-- if dbc.specgear.primary > 0 then
				-- EquipmentManager_EquipSet(GetEquipmentSetInfo(dbc.specgear.primary))
			-- end
		-- else
			-- if dbc.specgear.secondary > 0 then
				-- EquipmentManager_EquipSet(GetEquipmentSetInfo(dbc.specgear.secondary))
			-- end
		-- end
		
		SetActiveTalentGroup(NewTG)
	end
end

local function SpecAddTalentGroupLineToCat(self, cat, talentGroup)
	resSizeExtra = 2
	
	local ActiveColor = {0, 0.9, 0}
	local InactiveColor = {0.9, 0.9, 0.9}
	local PrimaryTreeColor = {0.8, 0.8, 0.8}
	local OtherTreeColor = {0.8, 0.8, 0.8}
	
	local IsPrimary = GetActiveTalentGroup()
	local maxPrimaryTree = GetPrimaryTalentTree()
	
	local line = {}
	for i = 1, 4 do
		local SpecColor = (IsPrimary == talentGroup) and ActiveColor or InactiveColor
		local TreeColor = ((IsPrimary == talentGroup) and (maxPrimaryTree == i - 1)) and PrimaryTreeColor or OtherTreeColor
		if i == 1 then
			line["text"] = talentGroup == 1 and PRIMARY or SECONDARY
			line["justify"] = "LEFT"
			line["size"] = 11 + resSizeExtra
			line["textR"] = SpecColor[1]
			line["textG"] = SpecColor[2]
			line["textB"] = SpecColor[3]
			line["hasCheck"] = true
			line["checked"] = IsPrimary == talentGroup
			line["isRadio"] = true
			line["func"] = function() SpecChangeClickFunc(self, talentGroup) end
			line["customwidth"] = 130
		elseif i == 2 then
			line["text"..i] = TalentInfo[talentGroup][1].points
			line["justify"..i] = "CENTER"
			line["text"..i.."R"] = TreeColor[1]
			line["text"..i.."G"] = TreeColor[2]
			line["text"..i.."B"] = TreeColor[3]
			line["customwidth"..i] = 20
		elseif i == 3 then
			line["text"..i] = TalentInfo[talentGroup][2].points
			line["justify"..i] = "CENTER"
			line["text"..i.."R"] = TreeColor[1]
			line["text"..i.."G"] = TreeColor[2]
			line["text"..i.."B"] = TreeColor[3]
			line["customwidth"..i] = 20
		elseif i == 4 then
			line["text"..i] = TalentInfo[talentGroup][3].points
			line["justify"..i] = "CENTER"
			line["text"..i.."R"] = TreeColor[1]
			line["text"..i.."G"] = TreeColor[2]
			line["text"..i.."B"] = TreeColor[3]
			line["customwidth"..i] = 20
		end
	end
	cat:AddLine(line)
end

local SpecSection = {}
local function Spec_UpdateTablet(self)
	resSizeExtra = 2
	local Cols, lineHeader
	
	local numTalentGroups = GetNumTalentGroups()
	
	if numTalentGroups > 1 then
		wipe(SpecSection)
	
		-- Spec Category
		SpecSection["specs"] = {}
		SpecSection["specs"].cat = spec:AddCategory()
		SpecSection["specs"].cat:AddLine("text", R.RGBToHex(1, 0.8, 0)..TALENTS, "size", 10 + resSizeExtra, "textR", 1, "textG", 1, "textB", 1)
		
		-- Talent Cat
		Cols = {
			" ",
			string.format("|T%s:%d:%d:%d:%d|t", TalentInfo[1][1].icon or "", 16 + resSizeExtra, 16 + resSizeExtra, 0, 4),
			string.format("|T%s:%d:%d:%d:%d|t", TalentInfo[1][2].icon or "", 16 + resSizeExtra, 16 + resSizeExtra, 0, 4),
			string.format("|T%s:%d:%d:%d:%d|t", TalentInfo[1][3].icon or "", 16 + resSizeExtra, 16 + resSizeExtra, 0, 4),
		}
		SpecSection["specs"].talentCat = spec:AddCategory("columns", #Cols)
		lineHeader = R.MakeTabletHeader(Cols, 10 + resSizeExtra, 12, {"LEFT", "CENTER", "CENTER", "CENTER"})
		SpecSection["specs"].talentCat:AddLine(lineHeader)
		R.AddBlankTabLine(SpecSection["specs"].talentCat, 1)
		
		-- Primary Talent line
		SpecAddTalentGroupLineToCat(self, SpecSection["specs"].talentCat, 1)
		
		-- Secondary Talent line
		SpecAddTalentGroupLineToCat(self, SpecSection["specs"].talentCat, 2)
	end
	
	-- Hint
	if numTalentGroups > 1 then
		spec:SetHint(L["<点击> 切换天赋."])
	end
end

local function Spec_OnEnter(self)
	if InCombatLockdown() then return end
	-- Register spec
	if not spec:IsRegistered(self) then
		spec:Register(self,
			"children", function()
				Spec_UpdateTablet(self)
			end,
			"point", function()
				return "BOTTOMLEFT"
			end,
			"relativePoint", function()
				return "TOPLEFT"
			end,
			"maxHeight", 500,
			"clickable", true,
			"hideWhenEmpty", true
		)
	end
	
	if spec:IsRegistered(self) then
		-- spec appearance
		spec:SetColor(self, 0, 0, 0)
		spec:SetTransparency(self, .6)
		spec:SetFontSizePercent(self, 1)
		
		-- Open
		spec:Open(self)
		
	--	HideOtherGraphs(self)
	end
end

local function Spec_Update(self)
	resSizeExtra = 12
	
	-- Talent Info
	wipe(TalentInfo)
	local numTalentGroups = GetNumTalentGroups()
	for i = 1, numTalentGroups do
		TalentInfo[i] = {}
		for t = 1, 3 do
			local _, _, _, talentIcon, pointsSpent = GetTalentTabInfo(t, false, false, i)
			TalentInfo[i][t] = {
				points = pointsSpent,
				icon = talentIcon,
			}
		end
	end
	
	local active = GetActiveTalentGroup(false, false)
	if GetPrimaryTalentTree(false, false, active) and select(2, GetTalentTabInfo(GetPrimaryTalentTree(false, false, active))) then
		Text:SetFormattedText(talentString, select(2, GetTalentTabInfo(GetPrimaryTalentTree(false, false, active))), TalentInfo[active][1].points, TalentInfo[active][2].points, TalentInfo[active][3].points)
	end
	
	-- Refresh Tablet
	if not self.hidden then
		if spec:IsRegistered(self) then
			if Tablet20Frame:IsShown() then
				spec:Refresh(self)
			end
		end
	end
end

Stat:SetScript("OnEnter", Spec_OnEnter)

local function OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end

	-- Setup Talents Tooltip
	self:SetAllPoints(Text)

	Spec_Update(self)
end

Stat:RegisterEvent("PLAYER_ENTERING_WORLD");
Stat:RegisterEvent("CHARACTER_POINTS_CHANGED");
Stat:RegisterEvent("PLAYER_TALENT_UPDATE");
Stat:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
Stat:SetScript("OnEvent", OnEvent)

Stat:SetScript("OnMouseDown", function()
	local active = GetActiveTalentGroup(false, false)
	SetActiveTalentGroup(active == 1 and 2 or 1)
end)