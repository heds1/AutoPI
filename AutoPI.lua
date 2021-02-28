
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
