local gm = gmod.GetGamemode()['FolderName']

local seconds = 0
local minutes = 0
local hours = 0

function drawHud()
    draw.DrawText(getHours() .. ":" .. getMinutes() .. ":" .. getSeconds(), "DermaDefault", 10, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT)
end

function getSeconds()
    if (seconds < 10) then
        return "0" .. seconds
    else
        return seconds
    end
end

function getMinutes()
    if (minutes < 10) then
        return "0" .. minutes
    else
        return minutes
    end
end

function getHours()
    if (hours < 10) then
        return "0" .. hours
    else
        return hours
    end
end

function wskyTimer( ply, previousTeam, newTeam)
    local previousTeamName = team.GetName(previousTeam)
    local newTeamName = team.GetName(newTeam)

    print(previousTeamName .. " => " .. newTeamName)

    if (newTeamName == "Staff on Duty") then
        print("Player is staff, starting timer")
        timer.Create("jobTimer", 1, 0, function()
            seconds = seconds + 1
            if (seconds >= 60) then
                minutes = minutes + 1
                seconds = 0
            end
            if (minutes >= 60) then
                hours = hours + 1
                minutes = 0
            end
            print(getHours() .. ":" .. getMinutes() .. ":" .. getSeconds())
        end)
    else
        print("Player is no longer staff, checking if timer exists")
        if (timer.Exists("jobTimer")) then
            print("removed timer.")
            timer.Remove("jobTimer")
        end
    end

    hook.Add("HUDPaint", "TimerHud", drawHud)
end

function addTimeCommand( ply, command, teamChat, isDead)
    commandExplode = string.Explode(" ", command, false)
    if (commandExplode[1] == "!addTime") then
        if (commandExplode[2]) then
            measurement = commandExplode[2]:sub(commandExplode[2]:len())
            timeToAdd = commandExplode[2]:sub(1, commandExplode[2]:len() -1)
            if (measurement == "s") then
                seconds = seconds + timeToAdd
                if (seconds >= 60) then
                    minutes = minutes + 1
                    seconds = 0
                end
                ply:PrintMessage( HUD_PRINTTALK, "[Wsky Rewards] Added " .. timeToAdd .. " seconds.")
                return true    
            elseif (measurement == "m") then
                minutes = minutes + timeToAdd
                if (minutes >= 60) then
                    hours = hours + 1
                    minutes = 0
                end
                ply:PrintMessage( HUD_PRINTTALK, "[Wsky Rewards] Added " .. timeToAdd .. " minutes.")
                return true    
            elseif (measurement == "h") then
                hours = hours + timeToAdd
                ply:PrintMessage( HUD_PRINTTALK, "[Wsky Rewards] Added " .. timeToAdd .. " hours.")
                return true    
            end
                ply:PrintMessage( HUD_PRINTTALK, "[Wsky Rewards] Error occured: unknown time measurement of '" .. measurement .. "', make sure you end your time with s, m or h.")
                return true    
        else
            print("No Time set.")
            ply:PrintMessage( HUD_PRINTTALK, "[Wsky Rewards] Invalid Parameter: No time set.")
            return true
        end
    end
    return false
end

if (gm == 'darkrp') then
    hook.Add("OnPlayerChangedTeam", "wskyTimer", wskyTimer)

    hook.Add("OnPlayerChat", "AddTimeCommand", addTimeCommand)
end