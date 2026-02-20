GearScoreCalc = {}


GEAR_SCORE_CACHE = {}

-- Create frames for character and inspect windows
scoreFrame = nil
inspectScoreFrame = nil
local _, PLAYER_CLASS = UnitClass("player")

IS_MANUAL_INSPECT_ACTIVE = false
local fontPath = "Fonts\\FRIZQT__.TTF"  -- Standard WoW font
local FONT_SIZE = 11
local BRACKET_SIZE = 400  -- TBC bracket size (Classic=200, TBC=400, WotLK=1000)
local MAX_GEAR_SCORE = BRACKET_SIZE * 6 - 1  -- 2399 for TBC
local GS_SCALE = 1.8618  -- GearScoreLite base scale factor
local GS_ENCHANT_MODIFIER = 1.05  -- 5% increase for enchanted items
local GS_GEM_SCORE_PER_GEM = 5    -- Flat score bonus per socketed gem
local MAX_RETRIES = 3
local INSPECT_RETRY_DELAY = 0.2
local INSPECT_RETRIES = {}
local TOTAL_EQUIPPABLE_SLOTS = 17
local ADDON_VERSION = 1.0

print("|cFFFFFF00" .. "GearScoreTBCClassic+ " .. "|r" .. "|cFF00FF00" .. ADDON_VERSION .. "|r" .. "|cFFFFFF00" .. " by " .. "|r" .. "|cFFFFA500" .. "gk646" .. "|r")

local itemTypeInfo = {
    ["INVTYPE_RELIC"] = { 0.3164, false },
    ["INVTYPE_TRINKET"] = { 0.5625, false },
    ["INVTYPE_2HWEAPON"] = { 2.000, true },
    ["INVTYPE_WEAPONMAINHAND"] = { 1.0000, true },
    ["INVTYPE_WEAPONOFFHAND"] = { 1.0000, true },
    ["INVTYPE_RANGED"] = { 0.3164, true },
    ["INVTYPE_THROWN"] = { 0.3164, false },
    ["INVTYPE_RANGEDRIGHT"] = { 0.3164, true },
    ["INVTYPE_SHIELD"] = { 1.0000, true },
    ["INVTYPE_WEAPON"] = { 1.0000, true },
    ["INVTYPE_HOLDABLE"] = { 1.0000, false },
    ["INVTYPE_HEAD"] = { 1.0000, true },
    ["INVTYPE_NECK"] = { 0.5625, false },
    ["INVTYPE_SHOULDER"] = { 0.7500, true },
    ["INVTYPE_CHEST"] = { 1.0000, true },
    ["INVTYPE_ROBE"] = { 1.0000, true },
    ["INVTYPE_WAIST"] = { 0.7500, false },
    ["INVTYPE_LEGS"] = { 1.0000, true },
    ["INVTYPE_FEET"] = { 0.75, true },
    ["INVTYPE_WRIST"] = { 0.5625, true },
    ["INVTYPE_HAND"] = { 0.7500, true },
    ["INVTYPE_FINGER"] = { 0.5625, false },
    ["INVTYPE_CLOAK"] = { 0.5625, true },
    ["INVTYPE_BODY"] = { 0, false },
    ["INVTYPE_TABARD"] = { 0, false },
    ["INVTYPE_AMMO"] = { 0, false },
    ["INVTYPE_BAG"] = { 0, false },
}

-- GearScoreLite formula tables
-- Table A: items with ilvl > 120, Table B: items with ilvl <= 120
local GS_Formula = {
    ["A"] = {
        [4] = { A = 91.4500, B = 0.6500 },
        [3] = { A = 81.3750, B = 0.8125 },
        [2] = { A = 73.0000, B = 1.0000 },
    },
    ["B"] = {
        [4] = { A = 26.0000, B = 1.2000 },
        [3] = { A = 0.7500, B = 1.8000 },
        [2] = { A = 8.0000, B = 2.0000 },
        [1] = { A = 0.0000, B = 2.2500 },
    },
}

-- GearScoreLite bracket-based color quality table
local GS_Quality = {
    [BRACKET_SIZE * 6] = {
        Red = { A = 0.94, B = BRACKET_SIZE * 5, C = 0.00006, D = 1 },
        Green = { A = 0, B = 0, C = 0, D = 0 },
        Blue = { A = 0.47, B = BRACKET_SIZE * 5, C = 0.00047, D = -1 },
        Description = "Legendary"
    },
    [BRACKET_SIZE * 5] = {
        Red = { A = 0.69, B = BRACKET_SIZE * 4, C = 0.00025, D = 1 },
        Green = { A = 0.97, B = BRACKET_SIZE * 4, C = 0.00096, D = -1 },
        Blue = { A = 0.28, B = BRACKET_SIZE * 4, C = 0.00019, D = 1 },
        Description = "Epic"
    },
    [BRACKET_SIZE * 4] = {
        Red = { A = 0.0, B = BRACKET_SIZE * 3, C = 0.00069, D = 1 },
        Green = { A = 1, B = BRACKET_SIZE * 3, C = 0.00003, D = -1 },
        Blue = { A = 0.5, B = BRACKET_SIZE * 3, C = 0.00022, D = -1 },
        Description = "Superior"
    },
    [BRACKET_SIZE * 3] = {
        Red = { A = 0.12, B = BRACKET_SIZE * 2, C = 0.00012, D = -1 },
        Green = { A = 0, B = BRACKET_SIZE * 2, C = 0.001, D = 1 },
        Blue = { A = 1, B = BRACKET_SIZE * 2, C = 0.00050, D = -1 },
        Description = "Uncommon"
    },
    [BRACKET_SIZE * 2] = {
        Red = { A = 1, B = BRACKET_SIZE, C = 0.00088, D = -1 },
        Green = { A = 1, B = BRACKET_SIZE, C = 0.001, D = -1 },
        Blue = { A = 1, B = 0, C = 0.00000, D = 0 },
        Description = "Common"
    },
    [BRACKET_SIZE] = {
        Red = { A = 0.55, B = 0, C = 0.00045, D = 1 },
        Green = { A = 0.55, B = 0, C = 0.00045, D = 1 },
        Blue = { A = 0.55, B = 0, C = 0.00045, D = 1 },
        Description = "Trash"
    },
}

local function CreateGearScoreFrame(name, parentFrame, point, relativePoint, xOffset, yOffset, textXOffset, textYOffset)
    local frame = CreateFrame("Frame", name, parentFrame)
    frame:SetSize(100, 30)
    frame:SetPoint(point, parentFrame, relativePoint, xOffset, yOffset)

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.text:SetFont(fontPath, FONT_SIZE)
    frame.text:SetTextColor(1, 1, 1)
    frame.text:SetPoint("BOTTOMLEFT", frame, "LEFT", textXOffset, textYOffset)
    frame.text:SetText("GearScore")

    frame.avgItemLevelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.avgItemLevelText:SetFont(fontPath, FONT_SIZE)
    frame.avgItemLevelText:SetTextColor(1, 1, 1)
    frame.avgItemLevelText:SetPoint("BOTTOMLEFT", frame.text, "LEFT", 185, -5)

    frame.scoreValueText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.scoreValueText:SetFont(fontPath, FONT_SIZE)
    frame.scoreValueText:SetTextColor(1, 1, 1)
    frame.scoreValueText:SetPoint("BOTTOMLEFT", frame.text, "BOTTOMLEFT", 0, 10)

    return frame
end

scoreFrame = CreateGearScoreFrame("GearScoreDisplay", PaperDollFrame, "BOTTOMLEFT", "BOTTOMLEFT", 0, 0, 73, 235)
inspectScoreFrame = CreateGearScoreFrame("InspectGearScoreDisplay", InspectFrame, "BOTTOMLEFT", "BOTTOMLEFT", 0, 0, 73, 140)


-- GearScoreLite bracket-based color interpolation
local function GetGearScoreColor(gearScore)
    if not gearScore or gearScore <= 0 then
        return 0.55, 0.55, 0.55, "Trash"
    end
    if gearScore > MAX_GEAR_SCORE then
        gearScore = MAX_GEAR_SCORE
    end
    for i = 0, 5 do
        if gearScore > i * BRACKET_SIZE and gearScore <= (i + 1) * BRACKET_SIZE then
            local bracket = GS_Quality[(i + 1) * BRACKET_SIZE]
            local r = bracket.Red.A + ((gearScore - bracket.Red.B) * bracket.Red.C) * bracket.Red.D
            -- Note: Green/Blue swap preserved from original GearScoreLite
            local g = bracket.Blue.A + ((gearScore - bracket.Blue.B) * bracket.Blue.C) * bracket.Blue.D
            local b = bracket.Green.A + ((gearScore - bracket.Green.B) * bracket.Green.C) * bracket.Green.D
            return r, g, b, bracket.Description
        end
    end
    return 0.55, 0.55, 0.55, "Trash"
end

-- Returns in r g b values from 0.0 - 1.0
local function GetColorForGearScore(gearScore)
    local r, g, b = GetGearScoreColor(gearScore)
    return r, g, b
end

-- Returns the color string which can be used in text formatting
local function GetColorForGearScoreText(gearScore)
    local r, g, b = GetGearScoreColor(gearScore)
    return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

-- Tries to find the enchant id from an itemLink
local function GetEnchantIDFromItemLink(itemLink)
    local enchantID = itemLink:match("item:%d+:(%d+)")
    return tonumber(enchantID)  -- Convert to number, will be nil if no enchantment
end

-- Counts the number of gems socketed in an item from its itemLink
-- Item link format: item:itemID:enchantID:gemID1:gemID2:gemID3:gemID4:...
local function GetGemCountFromItemLink(itemLink)
    local gemCount = 0
    local _, _, gem1, gem2, gem3 = itemLink:match("item:%d+:%d*:(%d*):(%d*):(%d*)")
    if gem1 and gem1 ~= "" and tonumber(gem1) > 0 then gemCount = gemCount + 1 end
    if gem2 and gem2 ~= "" and tonumber(gem2) > 0 then gemCount = gemCount + 1 end
    if gem3 and gem3 ~= "" and tonumber(gem3) > 0 then gemCount = gemCount + 1 end
    return gemCount
end

-- Calculates the score of a single individual item (based on GearScoreLite formula)
local function CalculateItemScore(itemLink, classToken)
    if not itemLink then
        return 0, 0
    end

    local itemName, _, itemRarity, itemLevel, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)

    -- If data is not ready, retry later
    if not itemName or not itemRarity or not itemLevel or not itemEquipLoc then
        C_Timer.After(0.2, function()
            CalculateItemScore(itemLink, classToken)
        end)
        return 0, 0
    end

    local slotData = itemTypeInfo[itemEquipLoc]
    if not slotData then
        return 0, 0
    end

    local slotModifier = slotData[1]
    local isEnchantable = slotData[2]

    -- Rarity adjustments (from GearScoreLite)
    local qualityScale = 1
    local isHeirloom = false
    if itemRarity == 5 then        -- Legendary
        qualityScale = 1.3
        itemRarity = 4
    elseif itemRarity == 1 then    -- Common
        qualityScale = 0.005
        itemRarity = 2
    elseif itemRarity == 0 then    -- Poor
        qualityScale = 0.005
        itemRarity = 2
    elseif itemRarity == 7 then    -- Heirloom
        itemRarity = 3
        itemLevel = 187.05
        isHeirloom = true
    end

    -- Pick formula table based on item level threshold
    local formulaTable
    if itemLevel > 120 then
        formulaTable = GS_Formula["A"]
    else
        formulaTable = GS_Formula["B"]
    end

    if itemRarity < 2 or itemRarity > 4 or not formulaTable[itemRarity] then
        return 0, itemLevel
    end

    local gearScore = math.floor(
        ((itemLevel - formulaTable[itemRarity].A) / formulaTable[itemRarity].B)
        * slotModifier * GS_SCALE * qualityScale
    )

    -- Reset heirloom item level for avg calculation
    if isHeirloom then
        itemLevel = 0
    end

    if gearScore < 0 then
        gearScore = 0
    end

    -- Hunter class adjustments (from GearScoreLite)
    if classToken == "HUNTER" then
        if itemEquipLoc == "INVTYPE_2HWEAPON" or itemEquipLoc == "INVTYPE_WEAPONMAINHAND"
            or itemEquipLoc == "INVTYPE_WEAPONOFFHAND" or itemEquipLoc == "INVTYPE_WEAPON"
            or itemEquipLoc == "INVTYPE_HOLDABLE" then
            gearScore = math.floor(gearScore * 0.3164)
        elseif itemEquipLoc == "INVTYPE_RANGED" or itemEquipLoc == "INVTYPE_RANGEDRIGHT" then
            gearScore = math.floor(gearScore * 5.3224)
        end
    end

    -- Enchant bonus (addon enhancement)
    local enchantID
    if isEnchantable then
        enchantID = GetEnchantIDFromItemLink(itemLink)
    end
    if enchantID and enchantID > 0 then
        gearScore = math.floor(gearScore * GS_ENCHANT_MODIFIER)
    end

    -- Gem bonus (addon enhancement)
    local gemCount = GetGemCountFromItemLink(itemLink)
    gearScore = gearScore + (gemCount * GS_GEM_SCORE_PER_GEM)

    return gearScore, itemLevel
end

local function CalculateGearScoreAndAverageItemLevel(unit)
    local totalScore = 0
    local totalItemLevel = 0
    local itemMissing = false
    local _, classToken = UnitClass(unit)

    -- Loop through all the equipment slots
    for i = 1, 19 do
        -- Skip the body (shirt, slot 4) and tabard (slot 19)
        if i ~= 4 and i ~= 19 then
            local itemLink = GetInventoryItemLink(unit, i)
            if itemLink then
                local itemScore, iLevel = CalculateItemScore(itemLink, classToken)
                totalScore = totalScore + itemScore
                if iLevel and iLevel > 0 then
                    totalItemLevel = totalItemLevel + iLevel
                end
            else
                -- Check if the slot is not legitimately empty
                local itemID = GetInventoryItemID(unit, i)
                if itemID then
                    itemMissing = true
                end
            end
        end
    end
    local avgItemLevel = (totalItemLevel / TOTAL_EQUIPPABLE_SLOTS) or 0
    return totalScore, avgItemLevel, itemMissing
end

local function CalculateAndCacheGearScore(unit)
    local gearScore, avgItemLevel, itemMissing = CalculateGearScoreAndAverageItemLevel(unit)
    local guid = UnitGUID(unit)
    if guid and gearScore and avgItemLevel then
        local cachedData = GEAR_SCORE_CACHE[guid]
        if not cachedData or cachedData[1] ~= gearScore or cachedData[2] ~= avgItemLevel then
            -- Update cache if it's a new entry or if the gear score or avg item level has changed
            GEAR_SCORE_CACHE[guid] = { gearScore, avgItemLevel }
        end
    end
    return gearScore, avgItemLevel, itemMissing
end

function GearScoreCalc.OnInspectFrameShow()
    IS_MANUAL_INSPECT_ACTIVE = true
end

function GearScoreCalc.OnInspectFrameHide()
    IS_MANUAL_INSPECT_ACTIVE = false
end

function GearScoreCalc.UpdateFrame(frame, unit)
    local score, avgItemLevel, _ = CalculateAndCacheGearScore(unit)
    local r, g, b = GetColorForGearScore(score)

    -- Set the numerical gear score with color
    frame.scoreValueText:SetTextColor(r, g, b)
    frame.scoreValueText:SetText(math.floor(score + 0.5))

    -- Set the average item level text
    frame.avgItemLevelText:SetText(math.floor(avgItemLevel + 0.5) .. "\niLvl")
end

function GearScoreCalc.OnPlayerEquipmentChanged()
    GearScoreCalc.UpdateFrame(scoreFrame, "player")
end

function GearScoreCalc.AddGearScoreToTooltip(tooltip, unit)
    if unit then
        local guid = UnitGUID(unit)
        local gearScore, avgItemLevel

        -- Get cached data
        local cachedData = GEAR_SCORE_CACHE[guid]
        if cachedData then
            gearScore, avgItemLevel = unpack(cachedData)
        end

        -- Display the gearscore
        if gearScore and gearScore > 0 then
            local color = GetColorForGearScoreText(gearScore)
            tooltip:AddLine("Gear Score: " .. color .. math.floor(gearScore + 0.5))
            tooltip:Show()  -- Force tooltip to refresh
        end
    end
end

function GearScoreCalc.OnInspectReady(inspectGUID)
    if lastInspection and UnitGUID(lastInspection) == inspectGUID then
        local gs, avg, itemMissing = CalculateGearScoreAndAverageItemLevel(lastInspection)

        if itemMissing then
            INSPECT_RETRIES[inspectGUID] = (INSPECT_RETRIES[inspectGUID] or 0) + 1

            if INSPECT_RETRIES[inspectGUID] <= MAX_RETRIES then
                C_Timer.After(INSPECT_RETRY_DELAY, function()
                    if lastInspection then
                        NotifyInspect(lastInspection)
                    end
                end)
            else
                GEAR_SCORE_CACHE[inspectGUID] = { gs, avg }
                GearScoreCalc.AddGearScoreToTooltip(GameTooltip, lastInspection)
                lastInspection = nil
                INSPECT_RETRIES[inspectGUID] = nil
            end
        else
            GEAR_SCORE_CACHE[inspectGUID] = { gs, avg }
            GearScoreCalc.AddGearScoreToTooltip(GameTooltip, lastInspection)
            INSPECT_RETRIES[inspectGUID] = nil
        end
    end
end

function GearScoreCalc.AppendItemScoreToTooltip(tooltip)
    local _, itemLink = tooltip:GetItem()
    if itemLink and IsEquippableItem(itemLink) then
        local score = CalculateItemScore(itemLink,PLAYER_CLASS)
        local itemName, _, _, itemLevel = GetItemInfo(itemLink)
        if score then
            tooltip:AddLine("GearScore: " .. math.floor(score))
            tooltip:AddLine("iLvl: " .. itemLevel)
            tooltip:Show()
        end
    end
end
