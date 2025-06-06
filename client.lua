local function dump(tbl, title)
    title = title or "Dump"
    print(("--- %s ---"):format(title))
    if type(tbl) ~= "table" then print(tbl) return end
    for k,v in pairs(tbl) do print(" "..k.." = "..json.encode(v)) end
end

-- simple chat helpers
local function register(cmd, ev, lab)
    RegisterCommand(cmd, function() TriggerServerEvent(ev) end, false)
    RegisterNetEvent("drms:resp:"..lab, function(d) dump(d[lab], "Your "..lab) end)
end

register("myroles",  "drms:req:discordRoles", "roles")
register("mygroups", "drms:req:groups",       "groups")

RegisterCommand("myjob", function() TriggerServerEvent("drms:req:job") end, false)
RegisterNetEvent("drms:resp:job", function(d) dump(d, "Your job") end)

-- demo command: attempt to become Fire Private (rank 3)
RegisterCommand("setfire3", function()
    TriggerServerEvent("drms:req:setJob", {group = "stlfd", rank = 3})
end, false)

--[[-------------------------------------------------------------------------
  Discord-Rank Sync  |  CLIENT utilities

  Commands
  --------
    /myroles       – prints your Discord role IDs
    /mygroups      – prints your current NDCore groups
    /myjob         – prints your current job
    /setfire3      – demo: ask server for stlfd rank 3 (Fire Private)

  To call from other client scripts:
    TriggerServerEvent("drms:req:discordRoles")
    TriggerServerEvent("drms:req:groups")
    TriggerServerEvent("drms:req:job")
    TriggerServerEvent("drms:req:setJob", {group="stlfd", rank=3})
---------------------------------------------------------------------------]]
