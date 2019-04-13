-- local gm = gmod.GetGamemode()['FolderName']

local jobTimeCounter = {}

local seconds = 0

function getFormatedTime(jobName)
    local jobSeconds = jobTimeCounter[jobName]
    if (jobSeconds) then
        return getHours(jobSeconds) .. ":" .. getMinutes(jobSeconds) .. ":" .. getSeconds(jobSeconds)
    else
        return ''
    end
end

function getSeconds(jobSeconds)
    local clampSeconds = jobSeconds % 60
    if (clampSeconds < 10) then
        return "0" .. clampSeconds
    else
        return clampSeconds
    end
end

function getMinutes(jobSeconds)
    local minutes = math.floor( (jobSeconds / 60) % 60 )
    if (minutes < 10) then
        return "0" .. minutes
    else
        return minutes
    end
end

function getHours(jobSeconds)
    local hours = math.floor( jobSeconds / 60 / 60 )
    if (hours < 10) then
        return "0" .. hours
    else
        return hours
    end
end

function drawHud()
    -- draw.DrawText(getHours() .. ":" .. getMinutes() .. ":" .. getSeconds(), "DermaDefault", 10, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT)
    local count = 0
    for index, value in pairs(jobTimeCounter) do
        draw.DrawText(index .. " => " .. getFormatedTime(index), "DermaDefault", 10, 10 + (count * 20), Color(255,255,255,255), TEXT_ALIGN_LEFT)
        count = count + 1
    end
end

net.Receive("wskyReturnPlayerData", function()
    local loadedData = net.ReadTable()
    if (loadedData) then
        jobTimeCounter = loadedData
    end
end)

function wskyTimer( ply, previousTeam, newTeam)
    if (ply && CLIENT) then
        net.Start("wskyReadPlayerData")
        net.SendToServer()
    end

    local previousTeamName = team.GetName(previousTeam)
    local newTeamName = team.GetName(newTeam)

    print(previousTeamName .. " => " .. newTeamName)

    if (timer.Exists("jobTimer")) then
        print("removed timer.")
        timer.Remove("jobTimer")
        seconds = jobTimeCounter[newTeamName] and jobTimeCounter[newTeamName] or 0
    end

    timer.Create("jobTimer", 1, 0, function()
        seconds = seconds + 1
        jobTimeCounter[newTeamName] = seconds
        if (jobTimeCounter && ply && CLIENT) then
            net.Start("wskySavePlayerData")
            net.WriteTable(jobTimeCounter)
            net.SendToServer()
        end
    end)

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
                ply:PrintMessage( HUD_PRINTTALK, "[Wsky Rewards] Added " .. timeToAdd .. " seconds.")
                return true    
            elseif (measurement == "m") then
                seconds = seconds + (timeToAdd * 60)
                ply:PrintMessage( HUD_PRINTTALK, "[Wsky Rewards] Added " .. timeToAdd .. " minutes.")
                return true    
            elseif (measurement == "h") then
                seconds = seconds + (timeToAdd * 60 * 60)
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

-- if (gm == 'darkrp') then
if (timer.Exists("jobTimer")) then
    timer.Remove("jobTimer")
end
hook.Add("OnPlayerChangedTeam", "wskyTimer", wskyTimer)

hook.Add("OnPlayerChat", "AddTimeCommand", addTimeCommand)
-- end