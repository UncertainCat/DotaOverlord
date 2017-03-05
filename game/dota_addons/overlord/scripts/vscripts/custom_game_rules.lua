require('no_overlord_mode')
require('neutral_spawners')
require('dire_events')

if CustomGameRules == nil then
  CustomGameRules = class({})
end

if CustomGameRules.overlord_table == nil then
  CustomGameRules.overlord_table = {}
end

function CustomGameRules:HeroSelectStart()
  if GAMEMODE == OVERLORD then
  id = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS,1) 
    if id ~= -1 then
        overlord = PlayerResource:GetPlayer(id)
        overlord:MakeRandomHeroSelection()
       -- PrecacheUnitByNameAsync("npc_dota_hero_abaddon",function() CreateHeroForPlayer("npc_dota_hero_abaddon", overlord) end, id)
    end  
 elseif GAMEMODE == OVERLORD_VS then
    for _,team in pairs({DOTA_TEAM_BADGUYS,DOTA_TEAM_GOODGUYS}) do
       local id = PlayerResource:GetNthPlayerIDOnTeam(team,1) 
        if id ~= -1 then
            local overlord = PlayerResource:GetPlayer(id)
            overlord = PlayerResource:GetPlayer(id)
            overlord:MakeRandomHeroSelection()
      --  PrecacheUnitByNameAsync("npc_dota_hero_abaddon",function() CreateHeroForPlayer("npc_dota_hero_abaddon", overlord) end, id)
        end  
    end
 end 
  ---start the selection clock
  hero_select_time_remaining = HERO_SELECTION_TIME
  
  Timers:CreateTimer(0, function()  
    hero_select_time_remaining = hero_select_time_remaining - 1
    local time = hero_select_time_remaining  
      if time < 0 then
        time = "-"               
      end
    CustomGameEventManager:Send_ServerToAllClients("Updatetimer", {text=time} )  
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
    return 1
    else
    return
    end
  end)         

  
  CustomGameRules.RadiantHeroCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) 

  GameMode.deniability_dummy = CreateUnitByName( "npc_dummy_unit", Vector(6000,6000,0), false, nil, nil, DOTA_TEAM_CUSTOM_2)
  GameMode.deniability_dummy:AddAbility("deniable_state_ability")
  
  
end

function CustomGameRules:PreGameStart()
  if GAMEMODE == OVERLORD then

   if PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS) == 0 then
    initiate_no_overlord_mode()
   end   

  GameMode.ancient = Entities:FindByName(nil, "dota_goodguys_fort")
  
  random_drops:roll_starting_drops()
  --neutral_bosses:Spawn() --not implemented yet
  GameAlerts:GameStartOverlord(DOTA_TEAM_BADGUYS)
  GameAlerts:GameStart()
  GameAlerts:GameStartRadiant()  
    for i=1,2 do
      local point = Entities:FindByName(nil,"fow_point_"..i):GetOrigin()
      AddFOWViewer(DOTA_TEAM_GOODGUYS, point, 800, 5, false)
      AddFOWViewer(DOTA_TEAM_BADGUYS, point, 800, 5, false)        
    end 

  local goodguys = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0), nil,1000000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, 0, FIND_UNITS_EVERYWHERE, false)
  CustomGameRules.good_creeps = goodguys

  local creep_intro_flag = true
  Timers:CreateTimer(0,function() 
  for key,creep in pairs(CustomGameRules.good_creeps) do
    if IsValidEntity(creep) then
    local heroes = FindUnitsInRadius(creep:GetTeam(),creep:GetOrigin() , nil, 800, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO , FIND_CLOSEST, false) 
      if #heroes > 0 and creep:IsAlive() and creep:GetTeam() == DOTA_TEAM_GOODGUYS then
      local hero = heroes[1]
      local PID = hero:GetPlayerID() 

       creep:SetOwner(hero)
       creep:SetControllableByPlayer(PID, false)  
       local roll = RandomInt(1,400)
       local bubble_string = nil
       if creep_intro_flag then
       bubble_string = "#first_creep_greeting"
       creep_intro_flag = false
       elseif roll <= 129 then
       bubble_string = "#creep_greeting_"..roll
       end
    --   creep:AddSpeechBubble(1, bubble_string, 4, 0, 0)       
       CustomGameRules.good_creeps[key] = nil
       MoveToPoint(creep,creep:GetOrigin() + (-1 * creep:GetOrigin() + hero:GetOrigin())/2, false)
       EmitSoundOnLocationWithCaster(creep:GetOrigin(),"compendium_levelup",creep)
      end  
   else
   CustomGameRules.good_creeps[key] = nil    
   end
  end
  return 1  
  end)
  
  elseif GAMEMODE == OVERLORD_VS then
  local buildings = Entities:FindAllByClassname('npc_dota_building') 
  
  for _,building in pairs(buildings) do
    AddFOWViewer(DOTA_TEAM_GOODGUYS, building:GetOrigin(), 500, 5, false)
    AddFOWViewer(DOTA_TEAM_BADGUYS, building:GetOrigin(), 500, 5, false)        
  end 
  
  GameMode.ancient = Entities:FindByName(nil, "dota_goodguys_fort")
  if GameMode.ancient == nil then
  GameMode.ancient = CreateUnitByName("npc_particle_dummy_unit", Vector(6000,6000,0), false, nil, nil, DOTA_TEAM_CUSTOM_1 )
  end
  local ability = GameMode.ancient:AddAbility('particle_dummy_unit')
  ability:SetLevel(1)
  GameMode.ancient:AddNoDraw()
  GameMode.ancient:SetTeam(DOTA_TEAM_CUSTOM_1)
  
  Timers:CreateTimer(1, function() 
  CustomGameEventManager:Send_ServerToAllClients("UpdateGameTimer", {text="0:00"} )    
  end)
  GameAlerts:GameStartOverlord(DOTA_TEAM_BADGUYS)
  GameAlerts:GameStartOverlord(DOTA_TEAM_GOODGUYS)    
  end  
end
  
function CustomGameRules:GameStart()
  if GAMEMODE == OVERLORD then  
  NeutralSpawns:Activate_Spawners()
  time_remaining = 24 * 60
  --Start the game clock
  local overlord = spawners.overlord
  
  Timers:CreateTimer(0, function()  
    time_remaining = time_remaining - 1
    local seconds = time_remaining % 60
    local minutes = math.floor(time_remaining/60)
    if seconds < 10 then
    seconds = "0" .. seconds
    end
    time_string = minutes .. ":" .. seconds
    CustomGameEventManager:Send_ServerToAllClients("UpdateGameTimer", {text=time_string} )  
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    return 1
    else
    return
    end
  end)      
  

  Timers:CreateTimer({
  endTime = 14*60, 
  callback = function()
    GameAlerts:EndNear()
  end
  })  


  Timers:CreateTimer(8*60 - 10,function()
    CustomGameRules:Reinforcements(1)
  end) 
   
  Timers:CreateTimer(16*60 - 10,function()
    CustomGameRules:Reinforcements(2)
  end)  

  Timers:CreateTimer(24*60 - 10,function()
    CustomGameRules:Reinforcements(3)
  end)  
    

    
  Timers:CreateTimer({
  endTime = 24*60, 
  callback = function()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
       for i = 0,5 do
        PlayerResource:SetCameraTarget(i, spawners.overlord)
        
        end
      AddFOWViewer(DOTA_TEAM_GOODGUYS, overlord:GetOrigin(), 10000, 10*60, false)
      AddFOWViewer(DOTA_TEAM_BADGUYS, overlord:GetOrigin(), 10000, 10*60, false)  
         
      final_death_animation(overlord)                      
    end
  end})  

  
  
  elseif  GAMEMODE == OVERLORD_VS then
  
   time_passed = 0
  Timers:CreateTimer(0, function()  
    time_passed = time_passed + 1
    local seconds = time_passed % 60
    local minutes = math.floor(time_passed/60)
    if seconds < 10 then
    seconds = "0" .. seconds
    end
    time_string = minutes .. ":" .. seconds
    CustomGameEventManager:Send_ServerToAllClients("UpdateGameTimer", {text=time_string} )  
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    return 1
    else
    return
    end
  end)    
  
  end

    all_buildings = Entities:FindAllByTarget("bad_filler_1")
  for _, building in pairs(all_buildings) do
      print(building:GetName())
      building:RemoveModifierByName("modifier_invulnerable")
      building:RemoveModifierByName("modifier_backdoor_protection_in_base")
      building:RemoveModifierByName("modifier_backdoor_protection")
      building:RemoveModifierByName("modifier_backdoor_protection_active")
  end

end  
 
 
-----On death event 
function CustomGameRules:OnDeath(killedUnit,killerEntity,killerAbility)
  if GAMEMODE == OVERLORD  then
    if killedUnit:GetClassname() == 'npc_dota_building' then
    GameMode.moonwells_destroyed = GameMode.moonwells_destroyed + 1
    if PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS) ~= 0 then
        local points = spawners.overlord:GetAbilityPoints()
        spawners.overlord:SetAbilityPoints(points+MOONWELL_ABILITYPOINT_BOUNTY)
        EmitSoundOnClient("powerup_06",spawners.overlord:GetOwner())     
    end
    GameAlerts:Moonwell_Destroyed()
    end
  
    if killedUnit:GetClassname() == 'npc_dota_tower' then
    GameMode.moonwells_destroyed = GameMode.moonwells_destroyed + 1
    if PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS) ~= 0 then
        local points = spawners.overlord:GetAbilityPoints()
        spawners.overlord:SetAbilityPoints(points+TOWER_ABILITYPOINT_BOUNTY)  
        if TOWER_ABILITYPOINT_BOUNTY ~= 0 then
        EmitSoundOnClient("powerup_06",spawners.overlord:GetOwner())    
        end 
    end
    end
  elseif GAMEMODE == OVERLORD_VS  then
  
    if killedUnit:GetClassname() == 'npc_dota_building' then
    GameMode.moonwells_destroyed = GameMode.moonwells_destroyed + 1
    for _,overlord in pairs(CustomGameRules.overlord_table) do
        if overlord:GetTeam() ~= killedUnit:GetTeam() then
        local points = overlord:GetAbilityPoints()
        overlord:SetAbilityPoints(points+MOONWELL_ABILITYPOINT_BOUNTY)
        EmitSoundOnClient("powerup_06",overlord:GetOwner())     
        end
    end
   -- GameAlerts:Moonwell_Destroyed()
    end
  
  end
   
  if GAMEMODE == OVERLORD  then
    if killedUnit.IsOverlord and killedUnit:IsReincarnating() == false then
    for i = 0,5 do
    PlayerResource:SetCameraTarget(0, killedUnit)
    end
    AddFOWViewer(DOTA_TEAM_GOODGUYS, killedUnit:GetOrigin(), 30000, 10*60, false)
    AddFOWViewer(DOTA_TEAM_BADGUYS, killedUnit:GetOrigin(), 30000, 10*60, false)  
    GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
    end
  elseif GAMEMODE == OVERLORD_VS then

    if killedUnit.IsOverlord then
      local flag = true
      for _,overlord in pairs(CustomGameRules.overlord_table) do
        if overlord:GetTeam() == killedUnit:GetTeam() and overlord:IsAlive() then
        flag = false
        end
      end
      
      if flag then
        for i = 0,5 do
        PlayerResource:SetCameraTarget(0, killedUnit)
        end
        AddFOWViewer(DOTA_TEAM_GOODGUYS, killedUnit:GetOrigin(), 30000, 10*60, false)
        AddFOWViewer(DOTA_TEAM_BADGUYS, killedUnit:GetOrigin(), 30000, 10*60, false)  
        
        
        if killedUnit:GetTeam() == DOTA_TEAM_BADGUYS then
        GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)   
        elseif killedUnit:GetTeam() == DOTA_TEAM_GOODGUYS then
        GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)       
        end
      end  
    end
  end

  if killedUnit:GetTeam() == DOTA_TEAM_NEUTRALS and GAMEMODE == OVERLORD then
    if killerEntity ~= nil then
      if killerEntity:GetTeam() == DOTA_TEAM_GOODGUYS and killerEntity:GetOwner() ~= nil then
        random_drops:roll_drop(killedUnit)
      end  
    end
  end
  
  if killedUnit.summoner ~= nil then
    if killedUnit:GetTeam() == killedUnit.summoner:GetTeam() then 
      killedUnit.summoner:Stop()    --to force him to end his channel
    end
  end
  

  if killedUnit.deactivated ~= nil then  --This means its a spawner 

    
    ParticleManager:CreateParticle("particles/econ/items/effigies/status_fx_effigies/base_statue_destruction_gold.vpcf",PATTACH_ABSORIGIN,killedUnit)
      Timers:CreateTimer(.5, function()
        killedUnit:AddNoDraw()
      end)
    if killerEntity:GetTeam() ~= DOTA_TEAM_BADGUYS then
    PlayerResource:IncrementKills(killerEntity:GetPlayerOwnerID(), 1)  
    PlayerResource:IncrementDeaths(killedUnit:GetPlayerOwnerID(),-1)
    
    end
    print()
  elseif spawners.overlord ~= nil then
      if killedUnit:GetPlayerOwner() == spawners.overlord:GetPlayerOwner() then
        if killerEntity:GetTeam() == DOTA_TEAM_GOODGUYS then
        PlayerResource:IncrementAssists(killerEntity:GetPlayerOwnerID(), -1)        
        end
      end
  end

end 

function CustomGameRules:Reinforcements(count)
  GameAlerts:ReinforcementsInbound()

  Timers:CreateTimer(10, function() 
  local wave_table = {{"npc_dota_creep_goodguys_melee","npc_dota_creep_goodguys_ranged"},{"npc_dota_creep_goodguys_melee_upgraded", "npc_dota_creep_goodguys_ranged_upgraded"},{"npc_dota_creep_goodguys_melee_upgraded_mega","npc_dota_creep_goodguys_ranged_upgraded_mega"}}
        local buildings = Entities:FindAllByClassname('npc_dota_building')
        for _,building in pairs(buildings) do 
         if building:GetTeam() == DOTA_TEAM_GOODGUYS then
            for i=1,count do
              local roll = RandomInt(1,5)
              local unit_string = nil
              if roll > 4 then
              unit_string = wave_table[count][2]
              else
              unit_string = wave_table[count][1]
              end
              CustomGameRules:SpawnReinforcement(unit_string,building:GetOrigin())
            end
         end
        end
  
        for i=1,4 * count do 

          local roll = RandomInt(1,4)
          local unit_string = nil
          if roll > 3 then
          unit_string = wave_table[count][2]
          else
          unit_string = wave_table[count][1]
          end
          CustomGameRules:SpawnReinforcement(unit_string,GameMode.ancient:GetOrigin())
        end 
        
        if count == 3 and #buildings== 7 then
        --Radiant boss spawn
          end
  end)              
end

function CustomGameRules:SpawnReinforcement(unit_string,location)
  Timers:CreateTimer(RandomFloat(0,2), function() 
  local facing = RandomVector(100)
  local backup = CreateUnitByName(unit_string, location + facing, true, nil, nil, DOTA_TEAM_GOODGUYS)
  backup:SetForwardVector(facing)
  EmitSoundOnLocationWithCaster(backup:GetOrigin(),"Portal.Hero_Appear",backup)
  table.insert(CustomGameRules.good_creeps,backup)
  ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_recall_poof.vpcf",PATTACH_ABSORIGIN,backup)
  end)
end
  
function CustomGameRules:InitGameMode()


end