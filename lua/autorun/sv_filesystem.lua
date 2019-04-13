if SERVER then
    util.AddNetworkString( "wskyReturnPlayerData" )
    util.AddNetworkString( "wskyReadPlayerData" )
    util.AddNetworkString( "wskySavePlayerData" )
    
    local filePath = "wsky-rewards/playerJobTimes/"
    
    net.Receive("wskyReadPlayerData", function (len, ply)
        local steamId = ply:SteamID64()
        local tableString = file.Read( filePath .. steamId .. "-jobTimes.txt", "DATA" )
        if (tableString) then
            local output = util.JSONToTable(tableString)
            net.Start("wskyReturnPlayerData")
            net.WriteTable(output)
            net.Send(ply)
        else
            net.Start("wskyReturnPlayerData")
            net.Send(ply)
        end
    end)
    
    net.Receive("wskySavePlayerData", function (len, ply)
        local steamId = ply:SteamID64()
        local jobsTimerTable = net.ReadTable()
        local fileName = steamId .. "-jobTimes.txt"
        file.Write(filePath .. fileName, util.TableToJSON(jobsTimerTable))
    end)
end