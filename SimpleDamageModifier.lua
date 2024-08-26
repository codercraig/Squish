-- Combined Damage, Healing Display, and Tooltip Stat Squish Addon

-- Define the multipliers for damage and stats
local damageModifier = 0.001  -- This will divide the damage by 1000
local statModifier = 0.01  -- This will divide the stats in tooltips by 100

-- Variables to track position shifts for damage text
local lastHitPosition = 0  -- Start with the middle
local shiftDistance = 100  -- Increase the distance to shift left or right
local verticalShift = 120  -- Increase the distance to move up
local horizontalOffset = 50  -- Move text slightly to the right of center

-- Function to create and display custom combat text (damage or healing)
local function CreateCustomCombatText(amount, r, g, b, fontSize)
    -- Ensure the amount is valid before processing
    if not amount or amount <= 0 then return end

    -- Modify the amount
    local modifiedAmount = math.floor(amount * damageModifier)

    -- Check if the modified amount is greater than 1,000 to set the color to red and increase size
    if modifiedAmount > 1000 then
        r, g, b = 1, 0, 0  -- Red for large numbers
        fontSize = 60  -- Increase font size for large values
    end

    -- Calculate the new position for the text
    local xOffset = lastHitPosition * shiftDistance + horizontalOffset
    lastHitPosition = lastHitPosition + 1
    if lastHitPosition > 1 then lastHitPosition = -1 elseif lastHitPosition == 0 then lastHitPosition = 0 end

    -- Create a new font string for the text
    local combatText = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    combatText:SetPoint("CENTER", UIParent, "CENTER", xOffset, 100)
    
    -- Set the text color
    combatText:SetTextColor(r, g, b)

    -- Set the text font size
    combatText:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")

    -- Set the text to display the modified amount
    combatText:SetText(modifiedAmount)

    -- Create an animation group for moving up, shaking, and fading out
    local animGroup = combatText:CreateAnimationGroup()

    local moveUp = animGroup:CreateAnimation("Translation")
    moveUp:SetOffset(0, verticalShift)
    moveUp:SetDuration(1)

    local fadeOut = animGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetStartDelay(0)
    fadeOut:SetDuration(1)

    -- Add a more intense shaking effect if the amount is large
    if modifiedAmount > 1000 then
        for i = 1, 6 do
            local shake = animGroup:CreateAnimation("Translation")
            shake:SetOffset(i % 2 == 0 and -20 or 20, 0)  -- Alternate shake direction
            shake:SetDuration(0.05)
        end
    end

    -- Hide the text after the animation completes
    animGroup:SetScript("OnFinished", function() combatText:Hide() end)
    animGroup:Play()
end

-- Function to check if the event is done by the player or their pet
local function IsPlayerOrPet(sourceGUID)
    return sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet")
end

-- Event handler function for combat events
local function OnEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subevent, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID, spellName, _, amount, overkill, school, resisted, blocked, absorbed, critical, _ = CombatLogGetCurrentEventInfo()

        -- Check if the event is related to damage or healing done by the player or their pet
        if IsPlayerOrPet(sourceGUID) then
            local r, g, b = 1, 1, 1  -- Default color white for damage
            local fontSize = 32  -- Default font size

            if subevent == "SWING_DAMAGE" or subevent == "SPELL_DAMAGE" or subevent == "RANGE_DAMAGE" then
                if critical then
                    r, g, b = 1, 1, 0  -- Yellow for critical hits
                    fontSize = 55  -- Increase size for critical hits
                end
            elseif subevent == "SPELL_HEAL" or subevent == "SPELL_PERIODIC_HEAL" then
                r, g, b = 0, 1, 0  -- Green for healing
                if critical then
                    fontSize = 55  -- Increase size for critical heals
                end
            else
                return
            end

            -- Display the custom combat text with shifting position
            CreateCustomCombatText(amount, r, g, b, fontSize)
        end
    end
end

-- Create a frame to listen for combat events
local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", OnEvent)

-- Function to scale down stats in tooltip, while ignoring cooldowns, durability, level-related lines, and mythic+/season information
local function ScaleTooltipStats(tooltip)
    -- Iterate over each line in the tooltip
    for i = 1, tooltip:NumLines() do  -- Check all lines
        local line = _G[tooltip:GetName() .. "TextLeft" .. i]
        local text = line:GetText()

        if text then
            -- Skip lines that mention durability, levels, or Mythic+/Season info
            if not text:find("/") and not text:find("Level") 
                and not text:find("Suffused") 
                and not text:find("Mythic") and not text:find("Season") then
                
                -- Scale only numbers that are likely to be stats (e.g., >100)
                local scaledText = text:gsub("(%d+[%d,%.]*)", function(num)
                    local numWithoutCommas = num:gsub(",", "")  -- Remove commas from the number
                    local numValue = tonumber(numWithoutCommas)
                    if numValue and numValue > 100 then  -- Only scale larger numbers
                        local scaledNum = numValue * statModifier
                        return string.format("%.0f", scaledNum)
                    else
                        return num  -- Return the number as-is if it should not be scaled
                    end
                end)

                -- Update the tooltip line with the scaled text
                if scaledText ~= text then  -- Only update if there was a change
                    line:SetText(scaledText)
                end
            end
        end
    end
    tooltip:Show()  -- Ensure the tooltip updates
end

-- Hook to the tooltip processor for items, targets, and other players
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, ScaleTooltipStats)
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, ScaleTooltipStats)

-- Print confirmation when the addon is loaded
print("Combined Damage, Healing Display, and Tooltip Stat Squish Addon loaded!")
