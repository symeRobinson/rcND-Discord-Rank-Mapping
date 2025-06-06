--[[-------------------------------------------------------------------------
  Discord Rank Mapping -> NDCore | ServerSide

  RPC EVENTS (client -> server)
  ----------------------------
    drms:req:discordRoles              -> returns list of role IDs
    drms:req:groups                    -> returns current NDCore groups
    drms:req:job                       -> returns current job & info
    drms:req:setJob  {group,rank}      -> server validates & sets if allowed

  SERVER internally:
    • Auto-syncs the active character + every stored character on spawn
    • `/syncgroups` – manual resync
    • `/viewgroups` – display active char’s groups in chat
---------------------------------------------------------------------------]]

print('DiscordRankMappingServer Loaded')

--------------------------------------------------------------------- little pieces of shit
local getPlayer = NDCore.getPlayer
local getConfig = NDCore.getConfig

local function fetchDiscordRoles(src)
    local info = NDCore.getPlayerServerInfo(src)
    return (info and info.discord and info.discord.roles) or {}
end

local function hasRole(list, roleId)
    roleId = tostring(roleId)
    for _, id in pairs(list) do if tostring(id) == roleId then return true end end
end

local function entryRank(e) return type(e) == "table" and e.rank or tonumber(e) end
local function prettyRank(group, r)
    local g = (getConfig().groups or {})[group]
    return (g and g.ranks and g.ranks[r]) or ("Rank "..r)
end

---------------------------------------------------------------- big strong buildable
local function buildDesiredGroups(roles)
    local desired = {}
    for gName, map in pairs(Config.jobRoleMappings) do
        local hi
        for roleId, entry in pairs(map) do
            if hasRole(roles, roleId) then
                local r = entryRank(entry)
                if r and (not hi or r > hi) then hi = r end
            end
        end
        if hi then desired[gName] = hi end
    end
    return desired
end

-------------------------------------------------------------- synchronization efforts futile
local function syncCharacter(charObj, roles)
    local want = buildDesiredGroups(roles)

    for gName, _ in pairs(Config.jobRoleMappings) do
        local need  = want[gName]                               -- nil ⇒ shouldn’t
        local curr  = charObj.getGroup and charObj.getGroup(gName) or nil
        local currR = curr and curr.rank or nil

        if need and currR ~= need then
            charObj.addGroup(gName, need)                       -- add / promote
        elseif not need and currR then
            charObj.removeGroup(gName)                          -- remove
        end
    end
end

--------------------------------------------------------- sync helpers
local function syncActive(src)
    local p = getPlayer(src); if p then syncCharacter(p, fetchDiscordRoles(src)) end
end

local function syncAllChars(src)
    local roles = fetchDiscordRoles(src)
    for id in pairs(NDCore.fetchAllCharacters(src) or {}) do
        local c = NDCore.fetchCharacter(id, src)
        if c then syncCharacter(c, roles) end
    end
end

---------------------------------------------------------------- hooks/cmds
AddEventHandler("ND:characterLoaded", function(ch)
    local s = ch.source
    syncActive(s)
    syncAllChars(s)
end)
--============================================================
--Tell this piece of shit to work when player joins
--============================================================
AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local src = source

    -- Defer the sync until NDCore has had a moment to register the player internally.
    CreateThread(function()
        Wait(2000)

        -- If NDCore.getPlayer(src) is available, run the sync:
        local p = NDCore.getPlayer(src)
        if p then
            syncActive(src)
            syncAllChars(src)
            print(("[DiscordSync] Synced player %d on initial connection"):format(src))
        end
    end)
end)

RegisterCommand("syncgroups", function(src)
    syncActive(src); syncAllChars(src)
    TriggerClientEvent("chat:addMessage", src,
        {args={"[NDCore]","All characters resynchronised from Discord roles."}})
end, false)

RegisterCommand("viewgroups", function(src)
    local p = getPlayer(src); if not p then return end
    TriggerClientEvent("chat:addMessage", src, {args={"[NDCore]","Group Memberships:"}})
    local g = p.groups or {}
    if next(g)==nil then TriggerClientEvent("chat:addMessage",src,{args={"- none -"}}) return end
    for name,info in pairs(g) do
        TriggerClientEvent("chat:addMessage", src,
            {args={"- "..name, prettyRank(name, info.rank or 0)}})
    end
end, false)

----------------------------------------------------------- RPC handlers
RegisterNetEvent("drms:req:discordRoles", function()
    TriggerClientEvent("drms:resp:discordRoles", source, {roles = fetchDiscordRoles(source)})
end)

RegisterNetEvent("drms:req:groups", function()
    local p = getPlayer(source)
    TriggerClientEvent("drms:resp:groups", source, {groups = p and p.groups or {}})
end)

RegisterNetEvent("drms:req:job", function()
    local p = getPlayer(source)
    local n,i = p and p.getJob and p.getJob()
    TriggerClientEvent("drms:resp:job", source, {job = n, info = i})
end)

RegisterNetEvent("drms:req:setJob", function(data)
    local g,r = data.group, tonumber(data.rank)
    local allow = buildDesiredGroups(fetchDiscordRoles(source))[g]
    if g and r and allow == r then
        local p = getPlayer(source); if p then p.setJob(g,r) end
        TriggerClientEvent("chat:addMessage", source,
            {args = {"[NDCore]", ("Job set to %s rank %d"):format(g,r)}})
    else
        TriggerClientEvent("chat:addMessage", source,
            {args = {"[NDCore]", "^1Permission denied."}})
    end
end)
CreateThread(function()
    -- Wait because it's a cunt
    Wait(1000)

    for _, id in ipairs(GetPlayers()) do
        local src = tonumber(id)
        -- Do a “live” sync for the currently loaded character and shit on their mom
        syncActive(src)
        -- Also sync all stored characters for that player because NDCore is a piece of burning trash I love.
        syncAllChars(src)
        print(("[DiscordSync] Auto‐synced player %d on resource start"):format(src))
    end
end)
