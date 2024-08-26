-- Simple Damage Display Addon

-- Define the multiplier or divisor you want to apply to damage numbers
local damageModifier = 0.001  -- This will divide the damage by 1000

-- Variables to track position shifts
local lastHitPosition = 0  -- Start with the middle
local shiftDistance = 100  -- Increase the distance to shift left or right
local verticalShift = 120  -- Increase the distance to move up
local horizontalOffset = 50  -- Move text slightly to the right of center

-- Function to create and display custom damage text
local function CreateCustomCombatText(amount, r, g, b, fontSize)
    -- Ensure the damage amount is valid before processing
    if not amount or amount <= 0 then return end

    -- Modify the damage amount
    local modifiedAmount = math.floor(amount * damageModifier)

    -- Check if the modified amount is greater than 1,000 to set the color to red and increase size
    if modifiedAmount > 1000 then
        r, g, b = 1, 0, 0  -- Red for damage above 1,000
        fontSize = 60  -- Increase font size for large damage
    end

    -- Calculate the new position for the damage text
    local xOffset = lastHitPosition * shiftDistance + horizontalOffset
    lastHitPosition = lastHitPosition + 1
    if lastHitPosition > 1 then lastHitPosition = -1 elseif lastHitPosition == 0 then lastHitPosition = 0 end

    -- Create a new font string for the damage text
    local damageText = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    damageText:SetPoint("CENTER", UIParent, "CENTER", xOffset, 100)
    
    -- Set the text color
    damageText:SetTextColor(r, g, b)

    -- Set the text font size
    damageText:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")

    -- Set the text to display the modified damage amount
    damageText:SetText(modifiedAmount)

    -- Create an animation group for moving up, shaking, and fading out
    local animGroup = damageText:CreateAnimationGroup()

    local moveUp = animGroup:CreateAnimation("Translation")
    moveUp:SetOffset(0, verticalShift)
    moveUp:SetDuration(1)

    local fadeOut = animGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetStartDelay(0)
    fadeOut:SetDuration(1)

    -- Add a more intense shaking effect if the damage is above 1,000
    if modifiedAmount > 1000 then
        for i = 1, 6 do
            local shake = animGroup:CreateAnimation("Translation")
            shake:SetOffset(i % 2 == 0 and -20 or 20, 0)  -- Alternate shake direction
            shake:SetDuration(0.05)
        end
    end

    -- Hide the text after the animation completes
    animGroup:SetScript("OnFinished", function() damageText:Hide() end)
    animGroup:Play()
end

-- Function to check if the damage is done by the player or their pet
local function IsPlayerOrPetDamage(sourceGUID)
    return sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet")
end

-- Event handler function
local function OnEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subevent, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID, spellName, _, amount, overkill, school, resisted, blocked, absorbed, critical, _ = CombatLogGetCurrentEventInfo()

        -- Check if the event is related to damage done by the player or their pet and ignore healing
        if IsPlayerOrPetDamage(sourceGUID) and (subevent == "SWING_DAMAGE" or subevent == "SPELL_DAMAGE" or subevent == "RANGE_DAMAGE") then
            -- Determine if it's a white hit or critical hit
            local isWhiteHit = (subevent == "SWING_DAMAGE")
            local r, g, b = 1, 1, 1  -- Default color white for regular hits
            local fontSize = 32  -- Default font size for regular hits

            if critical then
                r, g, b = 1, 1, 0  -- Yellow for critical hits
                fontSize = 55  -- Increase size for critical hits
            elseif isWhiteHit then
                r, g, b = 1, 1, 1  -- White for white hits (auto-attacks)
            end

            -- Display the custom damage text with shifting position
            CreateCustomCombatText(amount, r, g, b, fontSize)
        end
    end
end

-- Create a frame to listen for combat events
local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", OnEvent)

print("SimpleDamageDisplay addon loaded!")
