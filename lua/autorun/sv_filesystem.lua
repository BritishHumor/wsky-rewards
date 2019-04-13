if SERVER then
    util.AddNetworkString( "wskyReturnPlayerData" )
    util.AddNetworkString( "wskyReadPlayerData" )
    util.AddNetworkString( "wskySavePlayerData" )
    
    local filePath = "wsky-rewards/playerJobTimes/"
    
    net.Receive("wskyReadPlayerData", function (len, ply)
        local steamId = ply:SteamID64()
        print("filepath is")
        print(filePath .. steamId .. "-jobTimes.txt")
        local tableString = file.Read( filePath .. steamId .. "-jobTimes.txt", "DATA" )
        print("tableis " .. tableString)
        if (tableString) then
            local output = util.JSONToTable(tableString)
            print(table.ToString(output, "output", true))
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
        print("writing file: " .. fileName)
        file.Write(filePath .. fileName, util.TableToJSON(jobsTimerTable))
    end)
end