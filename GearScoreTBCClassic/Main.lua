-- Event handling
local gearScoreFrame = CreateFrame("Frame")
gearScoreFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
gearScoreFrame:RegisterEvent("INSPECT_READY")
gearScoreFrame:RegisterEvent("PLAYER_LOGIN")

local inspectUILoaded = false

local function SetupInspectHooks()
    if InspectFrame and not inspectUILoaded then
        inspectUILoaded = true
        
        InspectFrame:HookScript("OnHide", GearScoreCalc.OnInspectFrameHide)
        
        InspectFrame:HookScript("OnShow", function()
            GearScoreCalc.OnInspectFrameShow()
            if InspectFrame.unit then
                GearScoreCalc.UpdateFrame(inspectScoreFrame, InspectFrame.unit)
            end
        end)
    end
end

gearScoreFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_LOGIN" then
        -- Character frame hook
        CharacterFrame:HookScript("OnShow", function()
            GearScoreCalc.UpdateFrame(scoreFrame, "player")
        end)
        
        -- Try to setup inspect hooks
        SetupInspectHooks()
        
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        GearScoreCalc.OnPlayerEquipmentChanged()
        
    elseif event == "INSPECT_READY" then
        -- Setup inspect hooks if not done yet (InspectFrame loads on first inspect)
        if not inspectUILoaded then
            SetupInspectHooks()
        end
        
        C_Timer.After(0.2, function()
            GearScoreCalc.OnInspectReady(arg1)
        end)
    end
end)

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    local _, initialUnit = self:GetUnit()
    if initialUnit and UnitIsPlayer(initialUnit) and not InCombatLockdown() then
        local guid = UnitGUID(initialUnit)
        local cachedData = GEAR_SCORE_CACHE[guid]

        lastInspection = initialUnit
        GearScoreCalc.AddGearScoreToTooltip(self, initialUnit)

        if not IS_MANUAL_INSPECT_ACTIVE then
            if not InCombatLockdown() and CheckInteractDistance(initialUnit, "1") and not cachedData then
                C_Timer.After(0.2, function()
                    local _, currentUnit = self:GetUnit()
                    if currentUnit == initialUnit then
                        NotifyInspect(currentUnit)
                    end
                end)
            end
        end
    end
end)

-- Hook into item tooltips
GameTooltip:HookScript("OnTooltipSetItem", GearScoreCalc.AppendItemScoreToTooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", GearScoreCalc.AppendItemScoreToTooltip)