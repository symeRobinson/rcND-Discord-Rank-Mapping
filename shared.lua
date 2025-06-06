-- modules/job_sync/config.lua

--[[ 
  jobRoleMappings 
    For each NDCore group (job), list a sub‐table whose keys are Discord role IDs
    and whose values are the rank index (1 = first rank, 2 = second rank, etc.)
    (The rank numbers here must match the order in core:groups in your ndcore.cfg.)

  Example: 
    If in your ndcore.cfg you have:
      "lspd": {
        label = "Los Santos Police Department",
        ranks = {"Academy Recruit", "Probationary Officer", "Officer I", ...}
      }
    Then to give someone “Officer I” (which is the 3rd string in that list), set rank = 3.

  NOTE: Replace all of these example role IDs with your own Discord role IDs.
--]]


Config.jobRoleMappings = {

Config.jobRoleMappings = {
  slmpd = {
    -- ["<DISCORD_ROLE_ID>"] = { rank = <NUMBER>, name = "<RANK_NAME>" },
  },

  stlfd = {
    -- ["<DISCORD_ROLE_ID>"] = { rank = <NUMBER>, name = "<RANK_NAME>" },
  },

  stlbems = {
    -- ["<DISCORD_ROLE_ID>"] = { rank = <NUMBER>, name = "<RANK_NAME>" },
  },

  mshp = {
    -- ["<DISCORD_ROLE_ID>"] = { rank = <NUMBER>, name = "<RANK_NAME>" },
  },

  civilian = {
    -- ["<DISCORD_ROLE_ID>"] = { rank = <NUMBER>, name = "<RANK_NAME>" },
  },

  -- Add additional groups here as needed:
  -- dot = { ... },
  -- rangers = { ... },
}

return rankMapConfig
