
local f = CreateFrame("frame", nil, UIParent)
f:RegisterEvent("CHAT_MSG_WHISPER")
-- mainly for dev by whispering myself
f:RegisterEvent("CHAT_MSG_WHISPER_INFORM")

f:SetScript("OnEvent", function(self, event, ...)
    if event == "CHAT_MSG_WHISPER_INFORM" or
        event == "CHAT_MSG_WHISPER" then
        -- arg1 = message text, arg2 = author
        local arg1, arg2 = ...
        if arg1 == "PI" then
            -- check range - first need to get player name,
            -- by stripping out the server from arg2
            local player_name = arg2:gsub("%-Yojamba", "")
            
            local inRange = IsSpellInRange("Power Infusion", player_name)
            function getRangeText(inRange)
                if inRange == 0 then
                    return (" but you are OUT OF RANGE.")
                elseif inRange == 1 then
                    return(" and you are in range.")
                else 
                    return(" but you might not be in my raid.")
                end
            end
            range_text = getRangeText(inRange)

            -- get cooldown info for PI and construct message
            function constructMessage(range_text)
                local start, duration = GetSpellCooldown("Power Infusion");
                if duration == 0 then
                    return("PI is available," .. range_text)
                else
                    local avail = math.ceil(180 + start - GetTime())
                    return("PI comes off cooldown in " ..avail.. " seconds," .. range_text)
                end
            end
            msg = constructMessage(range_text)

            -- finally, send message!
            SendChatMessage(msg, "WHISPER", "Common", arg2)
        end
    end
end)

-- note: open key bindings, go to 'other' category, and bind
-- power infusion to a key.

-- create (invisible) frame for PI. this is bound in bindings.xml
local pi = CreateFrame("Button", "PowerInfusion", UIParent,
    "SecureActionButtonTemplate");
-- cast power infusion on the mouseover'd target
pi:SetAttribute("type", "spell");
pi:SetAttribute("spell", "Power Infusion", "mouseover");

-- check whether cast was successful, and if so, notify target
pi:RegisterEvent("UNIT_SPELLCAST_SENT");
pi:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
pi:SetScript("OnEvent", function(self, event, ...)
    -- we have to use this event to get targeted player,
    -- because that's not provided in UNIT_SPELLCAST_SUCCEEDED.
    if event == "UNIT_SPELLCAST_SENT" then
        -- for some reason we have to make this global, scoping is weird
        local unit, target = ...
        pi_target = target
    end
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, castGUID, spellID = ...
        local name = UnitName("player")
        -- check for PI spell ID, and don't send msg to yourself
        if (spellID == 10060 and pi_target ~= name) then
            SendChatMessage("Power Infusion cast on you.",
                "WHISPER", "Common", pi_target) 
        end
       
    end
end)


-- do the same for FW :)
local fw = CreateFrame("Button", "FearWard", UIParent,
    "SecureActionButtonTemplate");
fw:SetAttribute("type", "spell");
fw:SetAttribute("spell", "Fear Ward", "mouseover");
fw:RegisterEvent("UNIT_SPELLCAST_SENT");
fw:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");

local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo("Fear Ward")
print(spellId)
fw:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_SPELLCAST_SENT" then
        local unit, target = ...
        fw_target = target        
    end
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, castGUID, spellID = ...
        local name = UnitName("player")
        if (spellID == 6346 and fw_target ~= name) then
            SendChatMessage("Fear Ward cast on you.",
                "WHISPER", "Common", fw_target) 
        end
       
    end
end)