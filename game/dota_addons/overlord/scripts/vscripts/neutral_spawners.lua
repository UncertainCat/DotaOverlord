if neutral_spawns == nil then
  _G.NeutralSpawns = class({}) -- put spawners in the global scope
end

function NeutralSpawns:Activate_Spawners() -- called under custom_game_rules on game start

mine_spawn_points = Entities:FindAllByName("mine_spawn_point")
neutral_spawn_points = Entities:FindAllByName("neutral_spawn_point")

Timers:CreateTimer(0,function() 
 NeutralSpawns:SpawnMines()
 NeutralSpawns:SpawnNormal()
 return 60
end)



end

function NeutralSpawns:SpawnMines()

  for _,pointEnt in pairs(mine_spawn_points) do
  local point = pointEnt:GetOrigin()
  local name_string = NeutralSpawns:GetRandomMineSpawnString()
  local order_string = nil
  if name_string == "npc_dota_mimic" then
  order_string = "cower"
  else
  order_string = "guard"
  end
  
  NeutralSpawns:Spawn(name_string,point, order_string)
  
  end

end

function NeutralSpawns:SpawnNormal()
  for _,pointEnt in pairs(neutral_spawn_points) do
  local point = pointEnt:GetOrigin()
  local name_string = NeutralSpawns:GetRandomSpawnString()
    if RandomInt(1,10) == 10 then
    local order_string = nil
    if name_string == "npc_dota_treasure_frog" or name_string == "npc_dota_sheep" or name_string == "npc_dota_treasure_scarab" or  name_string == "npc_dota_pig" or name_string == "npc_dota_jelly_fish" then
    order_string = "cower"
    else
    order_string = "guard"
    end
    
    
    NeutralSpawns:Spawn(name_string,point, order_string)   
    end
  end
end


function NeutralSpawns:Spawn(name_string,point,ai_string)

local nearby_enemies = FindUnitsInRadius( DOTA_TEAM_NEUTRALS, point, nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false )
  if #nearby_enemies == 0 then
      local unit = CreateUnitByName(name_string, point, true, nil, nil, DOTA_TEAM_NEUTRALS) -- ( szUnitName, vLocation, bFindClearSpace, hNPCOwner, hUnitOwner, iTeamNumber )
      
      
      spawners:assign_neutral_ai(unit,ai_string)
  end
end

function NeutralSpawns:GetRandomSpawnString()

local roll = RandomInt(1,50)
if roll < 2 then
return "npc_dota_creature_wandering_vhoul"
elseif roll < 4 then
return "npc_dota_creature_gargoyle"
elseif roll < 8 then
return "npc_dota_creature_restless_spirit"
elseif roll < 35 then
return "npc_dota_creature_wandering_kobold"
elseif roll == 36 then
return "npc_dota_treasure_frog"
elseif roll < 40 then
return "npc_dota_sheep"
elseif roll < 44 then
return "npc_dota_treasure_scarab"
elseif roll < 48 then
return "npc_dota_pig"
elseif roll < 51 then
return "npc_dota_jelly_fish"
end

end

function NeutralSpawns:GetRandomMineSpawnString()
local roll = RandomInt (1,40)
  if roll < 2 then
  return "npc_dota_creature_restless_banshee"
  elseif roll < 4 then
  return "npc_dota_mimic"
  elseif roll < 6 then
  return "npc_dota_creature_basic_skeleton"
  else
  return "npc_dota_creature_restless_spirit"
  end
end

