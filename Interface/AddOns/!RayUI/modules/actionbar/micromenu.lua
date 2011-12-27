local R, C, L, DB = unpack(select(2, ...))

  --get the config values
  local barcfg = C["actionbar"].micromenu

  local NUM_MICRO = 12

  if not barcfg.disable then

    local bar = CreateFrame("Frame","RayUIMicroMenu",UIParent, "SecureHandlerStateTemplate")
    bar:SetWidth(NUM_MICRO*25.2+20)
    bar:SetHeight(50)
    bar:SetPoint(barcfg.pos.a1,barcfg.pos.af,barcfg.pos.a2,barcfg.pos.x,barcfg.pos.y)

    if barcfg.testmode then
      bar:SetBackdrop(cfg.backdrop)
      bar:SetBackdropColor(1,0.8,1,0.6)
    end
    bar:SetScale(C["actionbar"].barscale)

    

    --mircro menu
    local MicroButtons = {
      CharacterMicroButton,
      SpellbookMicroButton,
      TalentMicroButton,
      AchievementMicroButton,
      QuestLogMicroButton,
      GuildMicroButton,
      PVPMicroButton,
      LFDMicroButton,
      EJMicroButton,
      RaidMicroButton,
      HelpMicroButton,
      MainMenuMicroButton,
    }

    local function movebuttons()
      for _, f in pairs(MicroButtons) do
        f:SetParent(bar)
      end
      CharacterMicroButton:ClearAllPoints();
      CharacterMicroButton:SetPoint("BOTTOMLEFT", 10, 5)
    end

    movebuttons()

    local switcher = -1

    local function lighton(alpha)
      for _, f in pairs(MicroButtons) do
        f:SetAlpha(alpha)
        switcher = alpha
      end
    end

    if barcfg.showonmouseover then

      bar:EnableMouse(true)
      bar:SetScript("OnEnter", function(self) lighton(1) end)
      bar:SetScript("OnLeave", function(self) lighton(0) end)
      for _, f in pairs(MicroButtons) do
        f:SetAlpha(0)
        f:HookScript("OnEnter", function(self) lighton(1) end)
        f:HookScript("OnLeave", function(self) lighton(0) end)
      end

      bar:RegisterEvent("PLAYER_ENTERING_WORLD")

      --fix for the talent button display while micromenu onmouseover
      local function RayUITalentButtonAlphaFunc(self,alpha)
        if switcher ~= alpha then
          switcher = 0
          self:SetAlpha(0)
        end
      end

      hooksecurefunc(TalentMicroButton, "SetAlpha", RayUITalentButtonAlphaFunc)

    end

    bar:SetScript("OnEvent", function(self,event)
      if event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
        if not InCombatLockdown() then
          movebuttons()
        end
      elseif event == "PLAYER_ENTERING_WORLD" then
        lighton(0)
      end
    end)

    bar:RegisterEvent("PLAYER_TALENT_UPDATE")
    bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

end