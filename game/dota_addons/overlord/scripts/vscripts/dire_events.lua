if spawners == nil then
  _G.spawners = class({}) -- put spawners in the global scope
end
require('spawner_tables')

spawners.dire_unit_count = -1
--thinker that triggers dire spawns, it's called under function GameMode:OnGameRulesStateChange(keys) under events
function dire_thinker() 
  Timers:CreateTimer(
    function()      
      activate_spawned_unit_orders()
      return 5.0
    end)
  
   Timers:CreateTimer(
    function()     

    for _,overlord in pairs(CustomGameRules.overlord_table) do

      activate_spawners(overlord)
    end  
      return 30.0
    end)
  
end

function spawners:stats_update_thinker(overlord) --called on the spawn event for the overlord in gamemode.lua
  
   Timers:CreateTimer(
    function()     
    
local count = spawners:get_dire_unit_count(overlord)
if count ~= spawners.dire_unit_count then
CustomGameEventManager:Send_ServerToTeam(overlord:GetTeam(),"UpdateUnitCount", {text = count .."/".. SPAWNER_UNIT_CAP} )
end
spawners.dire_unit_count = count

local cost = spawners:get_active_spawner_cost(overlord)

if cost ~= overlord.active_spawner_cost then

CustomGameEventManager:Send_ServerToTeam(overlord:GetTeam(),"UpdateGoldCostPerMinute", {text = "-" .. cost } )
end
overlord.active_spawner_cost = cost

gpm = PlayerResource:GetGoldPerMin(overlord:GetPlayerID())
CustomGameEventManager:Send_ServerToTeam(overlord:GetTeam(),"UpdateGoldPerMinute", {text = math.floor(gpm) .. "Gold/Minute" } )
    return 2
    end)

end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Spawner scripts
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function activate_spawners(overlord)
      overlord.UnitCount = 0     
      overlord.wave_gold_spent = 0     
      for spawner,spawn_unit_string in pairs(spawners.spawner_table) do
            overlord.UnitCount = 0
            for unit, _ in pairs( spawners.dire_spawned_units ) do
              if IsValidEntity(unit) then
                if unit:GetOwner() == overlord then
                 overlord.UnitCount = overlord.UnitCount + 1
                end
              end  
            end
            if overlord.UnitCount < SPAWNER_UNIT_CAP then

                if spawner:IsNull() == false then

                    if spawner:IsChanneling() == false and spawner.deactivated == false and spawner:GetOwner() == overlord then

                        spawn_location = spawner:GetOrigin()            
                        spawn(spawn_unit_string,spawn_location, spawner,spawner:GetOwner())
                    end
                else
                delete_spawner(spawner)
                end
            end           
      end
      GameAlerts:DireSpawnComplete(overlord.wave_gold_spent,overlord.UnitCount + 1,overlord)

end

function clear_unit_ai(unit)
 spawners.dire_spawned_units[unit] = nil
 spawners.neutral_spawned_units[unit] = nil
 unit.ai = nil
end

function delete_spawner(spawner)
spawners.spawner_table[spawner] = nil
end

function spawners:assign_dire_ai(unit,string)
if IsValidEntity(unit) then
  clear_unit_ai(unit)
  unit.starting_team = unit:GetTeam()
  unit.ai = string
  spawners.dire_spawned_units[unit] = string
end
spawners:unit_order(unit, string) 
end

function spawners:assign_neutral_ai(unit,string)
if IsValidEntity(unit) then
  clear_unit_ai(unit)
  unit.ai = string
  spawners.neutral_spawned_units[unit] = string
end
spawners:unit_order(unit, string) 
end

function spawners:new_spawner(spawner,unit_string)
if IsValidEntity(spawner) then
  spawner.deactivated = false
  spawners.spawner_table[spawner] = unit_string
end
end

function spawners:get_dire_unit_count(overlord)
count = 0
      for unit,unit_script_string in pairs(spawners.dire_spawned_units) do
            if unit:IsNull() == false then
              if unit:GetTeam() == unit.starting_team and unit:GetTeam() == overlord:GetTeam() and unit:IsAlive() then
                
                count = count + 1

              end
            else
              clear_unit_ai(unit)
            end                 
      end
return count
end

function spawners:get_active_spawner_cost(overlord)
local total_cost = 0   
for spawner,unit_name_string in pairs(spawners.spawner_table) do      
    if spawner:IsNull() == false then
        if spawner:IsChanneling() == false and spawner.deactivated == false and spawner:GetTeam() == overlord:GetTeam() then                                   
            local cost = gold_cost[unit_name_string]
            total_cost = total_cost + cost
        end
    else
    delete_spawner(spawner)
    end               
end
return total_cost
end

------spawn function ----------------------------------------------------------------------------------------------------------------------------------
function spawn(unit_name_string,spawn_location,spawner,overlord)
if spawner:IsAlive() == false then
return
end
local current_gold
local id
if PlayerResource:GetPlayerCountForTeam(overlord:GetTeam()) ~= 0 then
id = overlord:GetPlayerID()
current_gold = PlayerResource:GetGold(id)
else
current_gold = 10000
id = -1
end

if overlord.wave_gold_spent == nil then
overlord.wave_gold_spent = 0
end

local cost = gold_cost[unit_name_string]

if current_gold > cost then

    PlayerResource:SpendGold(id, cost, 0)
    local unit = CreateUnitByName(unit_name_string, spawn_location + 140*spawner:GetForwardVector(), true, spawner:GetOwner(), spawner:GetOwner(), overlord:GetTeam()) -- ( szUnitName, vLocation, bFindClearSpace, hNPCOwner, hUnitOwner, iTeamNumber )
    local unit_script_string = spawners.ai[unit:GetUnitName()]
    spawners:assign_dire_ai(unit,unit_script_string)

      if GAMEMODE == OVERLORD_VS then
      unit:SetMaximumGoldBounty(0)
      unit:SetMinimumGoldBounty(0)
      end
    
    overlord.wave_gold_spent = overlord.wave_gold_spent + cost
    return unit
    else
    GameAlerts:NotEnoughGoldForSpawner(overlord)
    end
end
--------- function that triggers each ai order
function activate_spawned_unit_orders()
      for unit,unit_script_string in pairs(spawners.dire_spawned_units) do
            if unit:IsNull() == false then
              if unit:GetTeam() == unit.starting_team  then
                if unit:IsAttacking() then
                Timers:CreateTimer(GetAttackTimeRemaining(unit), function()
                spawners:unit_order(unit, unit_script_string)   
                end)         
                else
                spawners:unit_order(unit, unit_script_string) 
                end
              else
              clear_unit_ai(unit)
              end
            else
              clear_unit_ai(unit)
            end                 
      end

      for unit,unit_script_string in pairs(spawners.neutral_spawned_units) do
            if unit:IsNull() == false then
              if unit:GetTeam() ~= DOTA_TEAM_BADGUYS and unit:GetTeam() ~= DOTA_TEAM_GOODGUYS then
                spawners:unit_order(unit, unit_script_string)
              end
            end                 
      end

end

function spawners:upgrade(spawner)
current_spawn = spawners.spawner_table[spawner]
if upgrade_table[current_spawn] == nil then
return false
end

spawners.spawner_table[spawner] = upgrade_table[current_spawn]
return true
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--AI scripts
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function spawners:unit_order(unit, unit_script_string) 

   if unit ~= nil then
      if unit:IsNull() then
      return
      end
   else
   return
   end   
    
    if unit:IsAlive() == false then
    return
    end
    
    if unit_script_string == "attack_base" then

        --find the nearest moon well
        unit:Stop()
        
        local buildings = Entities:FindAllByClassname('npc_dota_building')
        local attack_target = nil
        for _,building in pairs(buildings) do
          if building:GetTeam() ~= unit:GetTeam() and building:GetTeam() ~= DOTA_TEAM_CUSTOM_1 and building:IsAlive() then
            if attack_target == nil then
            attack_target = building
            elseif (building:GetOrigin() - unit:GetOrigin()):Length() < (attack_target:GetOrigin() - unit:GetOrigin()):Length() then
            attack_target = building            
            end
          end       
        end
        local towers = Entities:FindAllByClassname('npc_dota_tower')       
        for _,tower in pairs(towers) do
          if tower:GetTeam() ~= unit:GetTeam() and tower:IsAlive() then
            if attack_target == nil then
            attack_target = tower
            elseif (tower:GetOrigin() - unit:GetOrigin()):Length() < (attack_target:GetOrigin() - unit:GetOrigin()):Length() then
            attack_target = tower            
            end
          end       
        end                 
        if attack_target == nil and GameMode.ancient:GetTeam() ~= DOTA_TEAM_CUSTOM_1 then        
          if unit:GetTeam() == DOTA_TEAM_BADGUYS then   
          attack_target = Entities:FindByName(nil, "dota_goodguys_fort")
          elseif unit:GetTeam() == DOTA_TEAM_GOODGUYS then
          attack_target = Entities:FindByName(nil, "dota_badguys_fort")
          end
        end
      
        for spawner,_ in pairs(spawners.spawner_table) do
          if unit:CanEntityBeSeenByMyTeam(spawner) and spawner:GetTeam() ~= unit:GetTeam() then
          attack_target = spawner
          end
        end
      
        if attack_target == nil then
          local enemy_units = FindUnitsInRadius( unit:GetTeam(), unit:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false ) 
          local flag = true
            for i = 0,#enemy_units do            
                if i > 0 and enemy_units[i]:GetTeam() ~= DOTA_TEAM_NEUTRALS and flag then
                attack_target = enemy_units[i]  
                flag = false            
                end

           end   
        end   
        if attack_target == nil then
        MillAbout(unit)
        return 
        end 
          
      AggressiveMoveToPoint(unit,attack_target:GetOrigin())
    return 
                                       
    end
    
    if unit_script_string == "wander" then
        if unit:IsAttacking() == false then
        unit:Stop()
        end
        target_vector = unit:GetOrigin()
        for i=1,7 do

        target_vector = target_vector + RandomVector(RandomInt(0,1200))
          if GridNav:IsTraversable(target_vector) == false then
              target_vector = -target_vector 
          end        
        AggressiveMoveToPoint(unit,target_vector)
        end    
        return  
    end
    
    if unit_script_string == "neutral_wander" then
        
        if unit:IsAttacking() then
            local target = unit:GetAttackTarget()
            if target:GetClassname() == "npc_dota_building" or target:GetClassname() == "npc_dota_tower" then
            unit:Stop()
            MoveToPoint(unit,unit:GetOrigin() + (-1 * target:GetOrigin() + unit:GetOrigin()):Normalized() * 1000)
            return
            end 
        else
        unit:Stop()           
        end
        target_vector = unit:GetOrigin()
        for i=1,7 do

        target_vector = target_vector + RandomVector(RandomInt(0,1200))
          if GridNav:IsTraversable(target_vector) == false then
              target_vector = -target_vector 
          end        
        AggressiveMoveToPoint(unit,target_vector)
        end    
        return  
    end
    
    if unit_script_string == "guard" then
        if unit.guard_point == nil then
        unit.guard_point = unit:GetOrigin()
        end
        for i=1,7 do
        target_vector = RandomVector(RandomInt(0,3000)) + unit.guard_point
          if GridNav:CanFindPath(unit:GetOrigin(),target_vector) then
            AggressiveMoveToPoint(unit,target_vector)
          end        
        end    
        return  
    end  
      
    if unit_script_string == "farm" then
        if unit:IsAttacking() then
            unit:Stop()
            local target = unit:GetAttackTarget()
            if target:GetClassname() == "npc_dota_tower" then
            MoveToPoint(unit,unit:GetOrigin() + (-1 * target:GetOrigin() + unit:GetOrigin()):Normalized() * 3600)
            return
            end             
            if target:GetTeam() ~= DOTA_TEAM_NEUTRALS then
            MoveToPoint(unit,unit:GetOrigin() + (-1 * target:GetOrigin() + unit:GetOrigin()):Normalized() * 1600)
            return
            end 
        end
        local enemy_neutrals = FindUnitsInRadius( DOTA_TEAM_NEUTRALS, unit:GetAbsOrigin(), nil, 1500, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false )
        local target_point
          if #enemy_neutrals > 0 then
          local aggro_target = enemy_neutrals[1]
            if aggro_target:GetTeam() ~= DOTA_TEAM_NEUTRALS then
            MoveToPoint(unit,unit:GetOrigin() + (-1 * target:GetOrigin() + unit:GetOrigin()):Normalized() * 3600)
            return
            end
          target_point = aggro_target:GetOrigin()
            if GridNav:CanFindPath(unit:GetOrigin(),target_point) == false then
            target_point = RandomVector(400)
            end

          AggressiveMoveToPoint( unit, target_point, unit:IsAttacking() ) --Start attacking
                    
          else
          target_point = RandomVector(2000) + unit:GetOrigin()             
        end
                  
        for i=1,3 do  --this is here so they scatter after killing their target
        target_point = RandomVector(RandomInt(0,1200)) + target_point       
          if GridNav:IsTraversable(target_point) == false then
          target_point = -target_point 
          end                 
        AggressiveMoveToPoint( unit, target_point)
        end          

        return
    end
    
    if unit_script_string == "order" then
        if unit:IsIdle() then
        spawners.dire_spawned_units[unit] = spawners.ai[unit:GetUnitName()]
        end
        return
    end
        
    if unit_script_string == "hunt" then
    if unit:IsAttacking() == false then
    unit:Stop()
    end
    unit.IsBored = false
    enemy_heroes = FindUnitsInRadius( unit:GetTeam(), unit:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, FIND_CLOSEST, false )
    unitpos = unit:GetOrigin()   
      if #enemy_heroes > 0 then
          local prey = enemy_heroes[1]

          Timers:CreateTimer(0,function()
            if unit ~= nil then
              if unit:IsNull() == false then 
                if unit:CanEntityBeSeenByMyTeam(prey) then
                unit.preypos = prey:GetOrigin() + 500*prey:GetForwardVector()
                return .1
                end
              end
            end
            return          
          end)
          
          AttackToTarget(unit,prey)
        else
          if unit.preypos ~= nil then
              if (unit.preypos - unitpos):Length() > 50 then
              AggressiveMoveToPoint(unit,unit.preypos)
              else
              AggressiveMoveToPoint(unit,unitpos + RandomVector(RandomInt(1,400)))
              MillAbout(unit)
              unit.preypos = nil
              end
          
          else
          MillAbout(unit)
          end
        end
      return
    end
    
    if unit_script_string == "cower" then
          local enemies = FindUnitsInRadius( unit:GetTeam(), unit:GetAbsOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
          if #enemies > 0 then
            local average_pos = Vector(0,0,0)
            for _,enemy in pairs(enemies) do
            average_pos = average_pos + enemy:GetOrigin()
            end
            average_pos = average_pos/#enemies
            local direction = (unit:GetOrigin() - average_pos):Normalized()
            local backup_loc = unit:GetOrigin() + direction * 2000   
      
            if unit:GetUnitName() == "npc_dota_treasure_frog" then
            EmitSoundOnLocationWithCaster(unit:GetOrigin(), "Hero_Lion.Hex.Target", unit)
            end
            MoveToPoint(unit,backup_loc)       
            return
          
          else
          spawners:unit_order(unit, "wander")
          return 
          end
    end
    
    if unit_script_string == "nether_lich" then
      local enemies = FindUnitsInRadius( unit:GetTeam(), unit:GetAbsOrigin(), nil, 2000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
      local decrepify = unit:FindAbilityByName("pugna_decrepify")
      local nether_blast = unit:FindAbilityByName("pugna_nether_blast")
      local lich_pos = unit:GetOrigin()
      if #enemies > 0 then

        unit.IsBored = false
        nearest = enemies[1]
          if (nearest:GetOrigin() - lich_pos):Length() < 300 then
            unit:Stop()
            
            CastAbilityTargetUnit(unit,decrepify,nearest)
            CastAbilityPoint(unit, nether_blast, nearest:GetOrigin())   
            local direction = (lich_pos - nearest:GetOrigin()):Normalized()
            local backup_loc = unit:GetOrigin() + direction * 2000          
            MoveToPoint(unit,backup_loc)
            return
          end
          if #enemies > 10 then
            CastAbilityPoint(unit, nether_blast, nearest:GetOrigin())   
            local direction = (nearest:GetOrigin() - lich_pos):Normalized()
            MoveToPoint(unit,direction * 1000)
            return        
            else
            AttackToTarget(unit,nearest)
            return
          end              
      else
      MillAbout(unit)  
      return
      end   
    end
    

    if unit_script_string == "demon_lord" then
    local rain = unit:FindAbilityByName("rain_of_chaos")
     if rain:GetCooldownTimeRemaining() == 0 then
     unit:Stop()
     CastAbilityNoTarget(unit,rain)
     MoveToPoint(unit,unit:GetOrigin())
     return
     end
      if unit:CanEntityBeSeenByMyTeam(unit.summoner) then
      unit.IsBored = false   
      AttackToTarget(unit,unit.summoner)
       
      return
      else
      MillAbout(unit)
      
      return
      end
    
    end
    
    if unit_script_string == "ogre" then 
      local leap_slam = unit:FindAbilityByName("bruiser_leap_slam")
      
      local pancakes = FindUnitsInRadius( unit:GetTeam(), unit:GetAbsOrigin() + unit:GetForwardVector() * 600, nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
      local heroes = FindUnitsInRadius( unit:GetTeam(), unit:GetAbsOrigin(), nil, 2000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )      
      if #pancakes > 0 and leap_slam:IsFullyCastable() then
      unit:Stop()
      CastAbilityNoTarget(unit,leap_slam)
      AttackToTarget(unit,pancakes[1])
      elseif #heroes > 1 then
      AttackToTarget(unit,heroes[1],false)
      else
      spawners:unit_order(unit, "wander")
      end
    end
end


function spawners:command_in_radius(command_string,center,TEAM,target,range) --this function looks for badguys on the bad minion list then passes a new order to them and sets their ai to "order"

if range == nil then
range = 1400
end

  if command_string == "global_attack" then
    for unit,_ in pairs(spawners.dire_spawned_units) do
      if IsValidEntity(unit) then
        if unit:GetTeam() == TEAM then
        spawners.dire_spawned_units[unit] = "attack_base"
        end
      end
    end
  activate_spawned_unit_orders()
  return
  end

local unit_table = FindUnitsInRadius( TEAM, center, nil, range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false )
local unitcount = #unit_table
for _,unit in pairs(unit_table) do



  if spawners.dire_spawned_units[unit] ~= nil and unit:GetTeam() == TEAM then 
  spawners.dire_spawned_units[unit] = "order"
  unit:Stop()
  unit.IsBored = false
    if command_string == "attack_move" then

    AggressiveMoveToPoint(unit,target + RandomVector(RandomFloat(1,40*math.sqrt(unitcount))))
    end
  
    if command_string == "attack_target" then
    AttackToTarget(unit,target)
    end
  
    if command_string == "move" then
    MoveToPoint(unit,target + RandomVector(RandomFloat(1,60*math.sqrt(unitcount))))
    end
    
    if command_string == "work" then
    spawners.dire_spawned_units[unit] = spawners.ai[unit:GetUnitName()]
    spawners:unit_order(unit, spawners.dire_spawned_units[unit])
    end
    
    if command_string == "defend" then
    target_table = FindUnitsInRadius( unit:GetTeam(), center, nil, 1400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false )
      if #target_table > 0 then
      AttackToTarget(unit,target_table[1])
      else
      AggressiveMoveToPoint(unit,target + RandomVector(350))
      end
    end
    
  end
end

end


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Commands
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function AggressiveMoveToPoint(unit,point,bool)
if bool == nil then
bool = true
end

    local position = point + RandomVector(RandomInt(1,40))

    ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), 
                            OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                            Position = point, Queue = bool })
end

function MoveToPoint(unit,point, bool)
if bool == nil then
bool = true
end

    local position = point + RandomVector(RandomInt(1,300))

    ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), 
                            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                            Position = point, Queue = bool })
    AggressiveMoveToPoint(unit,point)            
end

function AttackToTarget(unit,target,bool)
if bool == nil then
bool = true
end
    ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), 
                            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                            TargetIndex = target:entindex(), Queue = bool })
    AggressiveMoveToPoint(unit,target:GetOrigin())
end


function MoveToTarget(unit,target,bool)
if bool == nil then
bool = true
end
    ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), 
                            OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
                            TargetIndex = target:entindex(), Queue = bool })
    AggressiveMoveToPoint(unit,target:GetOrigin())
end

function CastAbilityTargetUnit(unit,ability,target,bool)

if bool == nil then
bool = true
end

    ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), 
                            OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                            AbilityIndex = ability:GetEntityIndex(),
                            TargetIndex = target:entindex(), Queue = bool })
end

function CastAbilityPoint(unit,ability,point,bool)

if bool == nil then
bool = true
end

    ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), 
                            OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                            AbilityIndex = ability:GetEntityIndex(),
                            Position = point, Queue = bool })
end

function CastAbilityNoTarget(unit,ability,bool)

if bool == nil then
bool = true
end
    ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), 
                            OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                            AbilityIndex = ability:GetEntityIndex(),
                             Queue = bool })                             
end




function MillAbout(unit)
if unit.IsBored ~= true then
unit.millpos = unit:GetOrigin()
end
unit.IsBored = true
  Timers:CreateTimer(
    function()   
      if unit:IsNull() == false then   
          if unit:IsAlive() then
              if unit.IsBored == true then
              AggressiveMoveToPoint(unit,unit.millpos + RandomVector(RandomInt(1,800)))
              return RandomInt(1,10)
              else 
              return nil
              end
          end
      end
    end
  )
end

function GetAttackTimeRemaining(unit)
local animation_point = unit:GetAttackAnimationPoint()
local attack_time = 1/(unit:GetAttackSpeed())
local time_until_next_attack = unit:TimeUntilNextAttack()
local time_until_attack_lands = attack_time * animation_point - (attack_time - time_until_next_attack)
  if time_until_attack_lands < 0 then
  time_until_attack_lands = time_until_attack_lands + attack_time
  end
return time_until_attack_lands + .02 --slight offset in case of float rounding errors from division
end