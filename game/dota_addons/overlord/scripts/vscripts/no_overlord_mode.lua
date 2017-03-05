require('abilities/evilpowers')
function initiate_no_overlord_mode()

  if spawners.overlord == nil then
  spawners.overlord = CreateUnitByName( "npc_dummy_unit", Vector(6000,6000,0), false, nil, nil, DOTA_TEAM_BADGUYS )
  spawners.overlord:AddNoDraw()
  end

wavecount = 0
print("Initiating no Overlord Mode")
  table.insert(CustomGameRules.overlord_table,spawners.overlord)
  Timers:CreateTimer(PRE_GAME_TIME, function()
  wavecount = wavecount + 1 
    if wavecount == 5 then
    no_overlord_finale()
    end
    GameMode.RadiantHeroCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
    if wavecount > 1 then
    for i = 1,GameMode.RadiantHeroCount * 5 + wavecount * 2 do
    create_random_spawner()
    end 
    end
  spawn_bosses()
  return 4*60
  end)
  
  Timers:CreateTimer(PRE_GAME_TIME + 2*60, function() --this is the push timer, it will randomly assign units to the push ai
  
  for unit,_ in pairs(spawners.dire_spawned_units) do
    if RandomInt(0,10) < wavecount  then 
      if IsValidEntity(unit) then
        if unit:GetUnitName() ~= "npc_dota_creature_bruiser" then
        spawners:assign_dire_ai(unit,"attack_base")
        end
      end
    end
  end
  
  return 2*60
  end)

  Timers:CreateTimer(PRE_GAME_TIME + 8*60,function()
    CustomGameRules:Reinforcements(1)
  end) 

  Timers:CreateTimer(PRE_GAME_TIME + 12*60,function()
    CustomGameRules:Reinforcements(2)
  end) 
  
   Timers:CreateTimer(PRE_GAME_TIME + 20*60,function()
    CustomGameRules:Reinforcements(3)
  end)  
  
end

function create_random_spawner()

local info_table = {}
info_table.target_points = {}
info_table.caster = spawners.overlord

  for i=1,100 do
  local possible_spawner_point = RandomVector(RandomInt(4000,15000)) + GameMode.ancient:GetOrigin()
    if GridNav:CanFindPath(GameMode.ancient:GetOrigin()+Vector(500,0,0), possible_spawner_point)  then
    local spawner = nil
    info_table.target_points[1] = possible_spawner_point
    local random_int = RandomInt(1,6)
    if random_int == 1 then
    spawner = summon_melee_spawner(info_table)
    elseif random_int == 2 then
    spawner = summon_ranged_spawner(info_table)
    elseif random_int == 3 then
    spawner = summon_ghoul_spawner(info_table)
    elseif random_int == 4  and wavecount > 4 then
    spawner = summon_orc_spawner(info_table)
    else
    spawner = summon_zombie_spawner(info_table)
    end 
    AddFOWViewer(DOTA_TEAM_GOODGUYS, spawner:GetOrigin(), 300, 1, true)
    MinimapEvent(DOTA_TEAM_GOODGUYS, spawner, spawner:GetOrigin().x, spawner:GetOrigin().y,DOTA_MINIMAP_EVENT_ENEMY_TELEPORTING, 1)
    Timers:CreateTimer(0,function() 
      if spawner:IsAlive() and IsValidEntity(spawner) then
        AddFOWViewer(DOTA_TEAM_GOODGUYS, spawner:GetOrigin(), 10, 1, true)
        return 1
      end
    end)
       
    return
    end
  end
end

function upgrade_spawners()
for spawner,spawn_unit_string in pairs(spawners.spawner_table) do
  if spawner~= nil then
    if spawner:IsNull() == false then
      if RandomInt(1,4) == 1 then
      spawners:upgrade(spawner)
      local x = spawner:GetModelScale()
      spawner:SetModelScale(1.3*x)     
      end
    end
  end   
end

end

function no_overlord_finale()
upgrade_spawners() 
Timers:CreateTimer(4*60 + 1, function()
spawners:command_in_radius("global_attack",Vector(0,0,0),DOTA_TEAM_BADGUYS)
return 30
end)

Timers:CreateTimer(7*60 + 30, function()
    spawn_boss("npc_dota_creature_demon_lord", "demon_lord")
return 30
end)

end

function spawn_bosses()
  for i = 1, GameMode.RadiantHeroCount do -- so many ogres!
    spawn_boss("npc_dota_creature_bruiser","ogre")
  end
  
  if wavecount == 4 then
    spawn_boss("npc_dota_creature_ice_dragon", "attack_base")
 end
  
  if wavecount == 6 then
    for i=1,2 do
    spawn_boss("npc_dota_creature_ice_dragon", "attack_base")
    end
 end  
  
  if wavecount == 6 then
    spawn_boss("npc_dota_creature_nether_lich", "nether_lich")
  end
end

function spawn_boss(boss_string,boss_ai)
  Timers:CreateTimer(RandomFloat(0,5), function()
  local keys = {}
  local spawn_point_ent = Entities:FindByName(nil, "miniboss_spawn_point")
  local spawn_point = spawn_point_ent:GetOrigin() + RandomVector(500)
  keys.target_points = {}
  keys.target_points[1] = spawn_point
  GridNav:DestroyTreesAroundPoint(spawn_point, 200, true)
  local monster = CreateUnitByName(boss_string , spawn_point, true, nil, spawners.overlord, DOTA_TEAM_BADGUYS) -- ( szUnitName, vLocation, bFindClearSpace, hNPCOwner, hUnitOwner, iTeamNumber )
  MinimapEvent(DOTA_TEAM_GOODGUYS, monster, monster:GetOrigin().x, monster:GetOrigin().y,DOTA_MINIMAP_EVENT_ENEMY_TELEPORTING, 1)
  AddFOWViewer(DOTA_TEAM_GOODGUYS, monster:GetOrigin(), 100, 5, true)
  monster_effects(keys,monster)
  spawners:assign_dire_ai(monster,boss_ai)
  end)  
end