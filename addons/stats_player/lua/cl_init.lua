GLOBAL_PLAYERSTATS = {}

net.Receive("STATS_BroadcastStats", function()
    GLOBAL_PLAYERSTATS = net.ReadTable()
end)
