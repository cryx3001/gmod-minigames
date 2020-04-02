ENT.Type = "point"
function ENT:AcceptInput( name, activator, caller, data )
    print("   CONSOLE RUNNING "..(data or "nil"))
    local fullData = string.Explode(" ", data)

    if fullData[1] == "sm_say" then
        fullData[1] = "say"
    end

    if fullData[1] == "say" then
        data = string.Explode( "say ", data )

        for k, v in pairs(player.GetAll()) do
            if data[2] then v:ChatPrint(data[2]) end
        end
    else
        if (fullData[1] == "sv_gravity" and fullData[2] == "800" ) then
            RunConsoleCommand("sv_gravity","600")
        else
            RunConsoleCommand(fullData[1], fullData[2])
        end
    end

    -- MAP SPECIFICS

    if game.GetMap() == "mg_yolo_multigames_v1" and fullData[1] == "phys_pushscale" and fullData[2] == "-2000" then
        RunConsoleCommand("phys_pushscale", "2000")
    end

    if game.GetMap() == "mg_horror_experiments_fix_v2" and data[2] == "<Zombies Vs. Humans>" then
        MG_CANDROPWEAPON = false
        for k, v in pairs(player.GetAll()) do
            if v:Team() == TEAM_RED then
                print(v:Name())
                v:SetMaxHealth(200)
                v:SetHealth(200)
            end
        end
    end
end
