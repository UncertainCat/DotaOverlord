require('abilities/overlord_interface')
require('abilities/creature_powers')
require('dire_events')

function summon_melee_spawner(keys)
  
return create_spawner(keys,"npc_melee_spawner",spawners.melee_spawn_string)

end

function summon_ranged_spawner(keys)
  
return create_spawner(keys,"npc_ranged_spawner",spawners.ranged_spawn_string)

end

function summon_zombie_spawner(keys)

return create_spawner(keys,"npc_zombie_spawner",spawners.zombie_spawn_string)

end

function summon_ghoul_spawner(keys)

return create_spawner(keys,"npc_ghoul_spawner",spawners.ghoul_spawn_string)

end

function summon_orc_spawner(keys)

return create_spawner(keys,"npc_orc_spawner",spawners.warcamp_spawn_string)

end

function create_spawner_start(keys)
local caster = keys.caster
local point = keys.target_points[1]
local ability = keys.ability



  if vision:fow_check(caster, point) == false then
        EmitSoundOn("General.CastFail_InvalidTarget_Hero", caster)
      caster:Stop()
      return
  end

end

function create_spawner(keys,spawner_name,unit_string)
  local point = keys.target_points[1]
  local caster = keys.caster
  local casterPos = caster:GetAbsOrigin()
  local difference = point - casterPos
  local ability = keys.ability
  --set up a check to make sure there isn't already a building there
  
  if vision:fow_check(caster, point) == false and ability ~= nil then
      caster:ModifyGold(keys.GoldCost, false, 0)
        EmitSoundOn("General.CastFail_InvalidTarget_Hero", caster)
      ability:EndCooldown()
      return
  end
  GridNav:DestroyTreesAroundPoint(point, 200, true)

  spawner = CreateUnitByName(spawner_name, point, true, caster, caster, caster:GetTeam())
  if PlayerResource:GetPlayerCountForTeam(caster:GetTeam()) > 0 then
  spawner:SetControllableByPlayer(caster:GetPlayerID(), false)  
  end
  spawners:new_spawner(spawner,unit_string)


  local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_dark_pact_pulses.vpcf", PATTACH_ABSORIGIN_FOLLOW, spawner)
  ParticleManager:SetParticleControl(particle, 1, spawner:GetAbsOrigin())
  ParticleManager:SetParticleControl(particle, 3, spawner:GetAbsOrigin())  
  ParticleManager:SetParticleControl(particle, 4, spawner:GetAbsOrigin())
  ParticleManager:SetParticleControl(particle, 5, spawner:GetAbsOrigin())  
  EmitSoundOn("Portal.Hero_Appear", spawner)

if caster:GetOwner() ~= nil then
spawner:SetForwardVector(caster:GetForwardVector())
spawner:SetBaseMaxHealth(spawner:GetMaxHealth() * (ability:GetLevel() + 1)/2)
spawner:SetMaxHealth(spawner:GetMaxHealth() * (ability:GetLevel() + 1)/2)  
spawner:SetBaseHealthRegen(spawner:GetBaseHealthRegen() * (ability:GetLevel() + 1)/2)
spawner:SetHealth(spawner:GetMaxHealth())
make_building_dummy(spawner)
overlord_interface:set_default_state(caster)
end
  return spawner
end


function summon_monster_start(keys)
  local caster = keys.caster
  local point = keys.target_points[1]
  
  EmitSoundOn("Hero_Warlock.RainOfChaos",caster)
 

 
             Timers:CreateTimer(0, function()
              if caster:IsChanneling() then
              StartAnimation(caster, {duration=10, activity=ACT_DOTA_CAST_ABILITY_2, rate=.1})
              return 12 
              else
              return
              end
            end)
 
  GridNav:DestroyTreesAroundPoint(point, 200, true)
  
  local targets = FindUnitsInRadius( caster:GetTeam(),point, nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false )
  for _,target in pairs(targets) do
  target:AddNewModifier(caster, keys.ability, "modifier_stunned", {duration = 1})
  end  
  
  keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_disable_actions", {})
  local monster = CreateUnitByName(keys.MonsterString , point, true, caster, caster, caster:GetTeam()) -- ( szUnitName, vLocation, bFindClearSpace, hNPCOwner, hUnitOwner, iTeamNumber )

  monster_effects(keys,monster)
  monster:SetControllableByPlayer(caster:GetPlayerID(), false)
  monster.summoner = caster
  caster.monster = monster

  Timers:CreateTimer(0,function()
  if caster:IsChanneling() == false then
  summon_monster_end(keys)
  return
  end
  return .1
  end)
  
end

function summon_monster_end(keys)
  local caster = keys.caster
  local monster = caster.monster
  caster:RemoveModifierByName("modifier_disable_actions")
  ParticleManager:DestroyParticle(caster.summon_monster_particle,false)
  ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_explosion_alliance_wave.vpcf",PATTACH_ABSORIGIN, monster)
  if monster:IsNull() == false then
    if monster:IsAlive() == true then
    monster:SetControllableByPlayer(-1, false)
    monster:SetOwner(nil)
    monster:SetTeam(DOTA_TEAM_CUSTOM_1)
    monster:Stop()    
    local unit_script_string = spawners.ai[monster:GetUnitName()]   
    spawners:assign_neutral_ai(monster,unit_script_string)
    spawners:unit_order(monster, unit_script_string) 
    end
  end
  PlayerResource:IncrementAssists(caster:GetPlayerOwnerID(), -1)      
  overlord_interface:set_default_state(caster) 
  local ability = caster:FindAbilityByName("summon_monster_ability")-- Reset the Overlord's summon monster cooldown
  ability:EndCooldown()
  ability:StartCooldown(ability:GetCooldown(ability:GetLevel() - 1)) --for some reason GetLevel is offset by 1
end


function upgrade_spawner_ability(keys)

local ability = keys.ability
local spawner = keys.caster

ability:SetHidden(true)

spawners:upgrade(spawner)
spawner:SetBaseMaxHealth(spawner:GetMaxHealth() * 1.3)
spawner:SetMaxHealth(spawner:GetMaxHealth() * 1.3)
spawner:SetHealth(spawner:GetMaxHealth())
local x = spawner:GetModelScale()
spawner:SetModelScale(1.3*x)
end


function attack_command(keys)
local  caster = keys.caster
local target = keys.target
local point = keys.target_points[1]
local range = keys.Range

EmitSoundOn("abaddon_abad_attack_02",caster)

spawners:command_in_radius("attack_move", point, caster:GetTeam(), point, range)

overlord_interface:set_default_state(caster)
end

function global_attack_command(keys)
local  caster = keys.caster
local target = keys.target
local point = caster:GetOrigin()
EmitSoundOn("abaddon_abad_lasthit_10",caster)
  spawners:command_in_radius("global_attack", caster:GetOrigin(),caster:GetTeam(), point)

overlord_interface:set_default_state(caster)
end

function defend_command(keys)
local  caster = keys.caster
local target = keys.target
local point = caster:GetOrigin()
local range = keys.Range


if RandomInt(1,10) > 8 then
EmitSoundOn("abaddon_abad_laugh_0".. RandomInt(1,4),caster)
end
  spawners:command_in_radius("defend", caster:GetOrigin(),caster:GetTeam(), point, range)

overlord_interface:set_default_state(caster)
end

function move_command(keys)
local caster = keys.caster
local point = keys.target_points[1]
local range = keys.Range

EmitSoundOn("abaddon_abad_attack_06",caster)
spawners:command_in_radius("move", caster:GetOrigin(),caster:GetTeam(), point, range)
overlord_interface:set_default_state(caster)  

end


function kill_command(keys)
local caster = keys.caster
local range = keys.Range
local target = keys.target

EmitSoundOn("abaddon_abad_kill_08",caster)
spawners:command_in_radius("attack_target", caster:GetOrigin(),caster:GetTeam(), target, range)
overlord_interface:set_default_state(caster)

end

function deactivate_toggle_off(keys)

spawner = keys.caster

spawner.deactivated = false

end

function deactivate_toggle_on(keys)
local spawner = keys.caster
spawner.deactivated = true
end

function blinding_mist_start(keys)


local caster = keys.caster
local point = keys.target_points[1]
local radius = keys.radius
local targets = keys.target_entities
local duration = keys.duration
local mesh = 50


EmitSoundOnLocationWithCaster(caster:GetOrigin(),"Hero_Warlock.Upheaval", caster)
EmitSoundOn("abaddon_abad_rival_15",caster)
for i=0,duration do
  Timers:CreateTimer(i, function()
        for i = 1, mesh do 
        
          local smoke = ParticleManager:CreateParticle("particles/rain_of_chaos/riki_smokebomb_b_no_cull.vpcf", PATTACH_ABSORIGIN, GameMode.ancient)
          smoke_point = point + RandomVector(i*radius/mesh)
          ParticleManager:SetParticleControl(smoke, 0,smoke_point + Vector(0,0,400))
          ParticleManager:SetParticleControl(smoke, 1,Vector(100000,1000,1))

          --ParticleManager:SetParticleControl(smoke, 2,point)
            Timers:CreateTimer(6, function()
                ParticleManager:DestroyParticle(smoke, false)
            end)
            
 
            
        end
  end)
end
overlord_interface:set_default_state(caster)
end

function blinding_mists(keys)
local target = keys.target

if target:GetClassname() == "npc_dota_building" or target:GetClassname() == "npc_dota_tower"  then
AddFOWViewer(target:GetTeam(),target:GetOrigin(),400,1,true)
elseif target.FogFlag == nil then

AddFOWViewer(target:GetTeam(),target:GetOrigin(),400,1,true)
target.FogFlag = true

  Timers:CreateTimer(50, function()
  target.FogFlag = nil
  end)
  
end

end

function create_building_start(keys)
  local caster = keys.caster
  local point = keys.target_points[1]
  local ability = keys.ability
    StartSoundEvent("Portal.Loop_Appear",caster)
              Timers:CreateTimer(0, function()
              if caster:IsChanneling() then
                StartAnimation(caster, {duration=2, activity=ACT_DOTA_CAST_ABILITY_1, rate=.5}) 
                local portal_particles = ParticleManager:CreateParticle("particles/econ/events/fall_major_2015/teleport_end_fallmjr_2015_lvl2_black_b.vpcf", PATTACH_ABSORIGIN, caster)            
                ParticleManager:SetParticleControl(portal_particles,0,point + Vector(0,0,100))
                 Timers:CreateTimer(4, function()
                  ParticleManager:DestroyParticle(portal_particles,false)
                 end)    
                return 2
              else
                StopSoundEvent("Portal.Loop_Appear",caster)    
                return
              end
            end) 
  


end

function create_building(keys)
  local building_name = keys.building
  local point = keys.target_points[1]
  local caster = keys.caster
  local casterPos = caster:GetAbsOrigin()
  local difference = point - casterPos
  local ability = keys.ability
  StopSoundEvent("Portal.Loop_Appear",caster)     
  EmitSoundOn("Portal.Hero_Appear", caster)
  
  GridNav:DestroyTreesAroundPoint(point, 150, true)
  building = CreateUnitByName(building_name, point, true, caster, caster, caster:GetTeam())
  if building_name == "npc_flame_turret" then
  building:SetForwardVector(-1 * caster:GetForwardVector())  --wtf it faces backwards
  else
  building:SetForwardVector(caster:GetForwardVector())
  end
  building:SetControllableByPlayer(caster:GetPlayerID(), false)
  make_building_dummy(building)
  caster:Stop()
  StartAnimation(caster,{duration=.1, activity=ACT_DOTA_IDLE, rate=1})
  StartAnimation(building, {duration=24*60, activity=ACT_DOTA_IDLE, rate=.3})
  local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_dark_pact_pulses.vpcf", PATTACH_ABSORIGIN, building)
--ParticleManager:SetParticleControl(particle, 0, spawner:GetAbsOrigin())

  EmitSoundOn("Portal.Hero_Appear", spawner)
overlord_interface:set_default_state(caster)
end

function betray(keys)
local caster = keys.caster
local target = keys.target
local duration = keys.duration

  EmitSoundOnLocationWithCaster(target:GetOrigin(),"Hero_Abaddon.BorrowedTime",target)

if target:IsIllusion() then
target:ForceKill(false)
end
 
if target:IsHero() then
  keys.ability:ApplyDataDrivenModifier(caster, target, "betrayal_hero_modifier", {})
  target:AddNoDraw()
    local outgoingDamage = 200
    local incomingDamage = 100
    local origin = target:GetOrigin()
    local unit_name = target:GetUnitName()
    local targetAngles = target:GetAngles()
    -- handle_UnitOwner needs to be nil, else it will crash the game.
    local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
    illusion:SetModelScale(target:GetModelScale() * 1.2)
    illusion:SetOwner(caster)
    illusion:SetAngles( targetAngles.x, targetAngles.y, targetAngles.z )
    illusion:SetControllableByPlayer(caster:GetPlayerID(), false)
    -- Level Up the unit to the casters level
    local targetLevel = target:GetLevel()
    for i=1,targetLevel-1 do
      illusion:HeroLevelUp(false)
    end

    -- Set the skill points to 0 and learn the skills of the caster
    illusion:SetAbilityPoints(0)
    for abilitySlot=0,15 do
      local ability = target:GetAbilityByIndex(abilitySlot)
      if ability ~= nil then 
        local abilityLevel = ability:GetLevel()
        local abilityName = ability:GetAbilityName()
        local illusionAbility = illusion:FindAbilityByName(abilityName)
        illusionAbility:SetLevel(abilityLevel)

      end
    end

    -- Recreate the items of the caster
    for itemSlot=0,5 do
      local item = target:GetItemInSlot(itemSlot)
      if item ~= nil then
        local itemName = item:GetName()
        local newItem = CreateItem(itemName, illusion, illusion)
        illusion:AddItem(newItem)
      end
    end

    -- Set the unit as an illusion
    -- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
    illusion:AddNewModifier(target, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage})
    --  illusion:AddNewModifier(target, ability, "modifier_kill", { duration = duration})
    -- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
    illusion:MakeIllusion()
    -- Set the illusion hp to be the same as the caster
    illusion:SetHealth(target:GetHealth())

    local particles = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf", PATTACH_ABSORIGIN_FOLLOW,illusion)
    keys.ability:ApplyDataDrivenModifier(caster, illusion, "betrayal_modifier", {})
    
    Timers:CreateTimer(0, function() 

    if IsValidEntity(illusion) then
      if illusion:IsAlive() then
      angles = illusion:GetAngles()
      target:SetAngles(angles.x, angles.y, angles.z)
      target:SetOrigin(illusion:GetOrigin())
      return .1  
      else
      target:RemoveNoDraw()
      end 
    end
  
  end)
  
  
  Timers:CreateTimer(duration, function() 
  ParticleManager:DestroyParticle(particles,false)
  end)
elseif target:GetUnitName() == "npc_dota_roshan" then

  target:SetOwner(caster)
  target:SetControllableByPlayer(caster:GetPlayerID(), false)
  target:SetTeam(caster:GetTeam())
  local start_scale = target:GetModelScale()
  target:SetModelScale(start_scale * 1.3)
  keys.ability:ApplyDataDrivenModifier(caster, target, "betrayal_modifier", {})
  local particles = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf", PATTACH_ABSORIGIN_FOLLOW,target)
  Timers:CreateTimer(duration, function() 
  ParticleManager:DestroyParticle(particles,false)
  target:SetOwner(nil)  
  target:SetControllableByPlayer(-1, false)  
  target:SetModelScale(start_scale)
  target:SetTeam(DOTA_TEAM_NEUTRALS)
  end)

else

  keys.ability:ApplyDataDrivenModifier(caster, target, "betrayal_hero_modifier", {})
  local unit_name = target:GetUnitName()
  local origin = target:GetOrigin()
  local angles = target:GetAngles()
  target:ForceKill(false)
  UTIL_Remove(target)
  local traitor = CreateUnitByName(unit_name, origin, false, caster, nil, caster:GetTeamNumber())
  traitor:SetOwner(caster)
  traitor:SetControllableByPlayer(caster:GetPlayerID(), false)
  traitor:SetAngles(angles.x, angles.y, angles.z)
  traitor:SetModelScale(traitor:GetModelScale() * 1.2)
  traitor:SetBaseMaxHealth(traitor:GetBaseMaxHealth()*2)
  traitor:SetHealth(traitor:GetMaxHealth())
  traitor:SetBaseDamageMax(traitor:GetBaseDamageMax()*2)
  traitor:SetBaseDamageMin(traitor:GetBaseDamageMin()*2)
  keys.ability:ApplyDataDrivenModifier(caster, traitor, "betrayal_modifier", {})
  local particles = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf", PATTACH_ABSORIGIN_FOLLOW,traitor)
  Timers:CreateTimer(duration, function() 
  keys.ability:ApplyDataDrivenModifier(caster, traitor, "traitor_modifier", {})  
  ParticleManager:DestroyParticle(particles,false)
  end)
end



end

function final_death_animation(caster)

  for i=1,6 do
  item = caster:GetItemInSlot(i)
    if item~=nil then
      if item:GetName() == "item_aegis" then
      caster:RemoveItem(item)
      end
    end
  end

caster:RemoveNoDraw()
caster:AddNewModifier(caster, nil, "modifier_invulnerable", {})
caster:Stop()
caster:SetControllableByPlayer(-1, false)  
GameMode.ancient:AddNewModifier(caster, nil, "modifier_invulnerable", {})

 facing = caster:GetForwardVector()
 left = facing:Cross(Vector(0,0,1))
local location = caster:GetOrigin()
local sky = location + Vector(0,0,1000)

StartAnimation(caster, {duration=6, activity=ACT_DOTA_DISABLED, rate=1})
local roll = RandomInt(1,15)
if roll < 10 then
death_cry_roll = "0"..roll
else
death_cry_roll = roll
end
EmitSoundOn("abaddon_abad_death_"..death_cry_roll, caster)


for i=1,100 do
      Timers:CreateTimer(RandomFloat(0,5), function()
          local shockparticle = ParticleManager:CreateParticle("particles/econ/items/zeus/lightning_weapon_fx/zuus_base_attack_explosion_core_b_immortal_lightning_immortal_lightning.vpcf",PATTACH_ABSORIGIN,caster)
          if RandomInt(1,5) > 4 then
          EmitSoundOnLocationWithCaster(caster:GetOrigin(), "Hero_Zuus.ArcLightning.Target", caster)
          end
          ParticleManager:SetParticleControl(shockparticle,3,location + RandomVector(50) + Vector(0,0,RandomInt(0,300)))
      end)   
end

beams = {}
for i=1,5 do
    Timers:CreateTimer(RandomFloat(2,4), function()    
    EmitSoundOnLocationWithCaster(caster:GetOrigin(), "Hero_Pugna.LifeDrain.Cast", caster)
    local beamparticle = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_life_drain_beam_2b_disabled.vpcf",PATTACH_ABSORIGIN,caster)
    ParticleManager:SetParticleControl(beamparticle,1,location+Vector(0,0,RandomInt(100,250)))
    ParticleManager:SetParticleControl(beamparticle,0,sky + RandomVector(300))
    ParticleManager:SetParticleControl(beamparticle,11,Vector(.1,0,0)) 
    table.insert(beams,beamparticle)
  end)   
end
Timers:CreateTimer(6, function()
  EmitSoundOnLocationWithCaster(caster:GetOrigin(), "Hero_Abaddon.AphoticShield.Destroy", caster)
  for _,beamparticle in pairs(beams) do
  ParticleManager:DestroyParticle(beamparticle,false)
  local explosion = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf",PATTACH_ABSORIGIN,caster)
  ParticleManager:SetParticleControl(explosion,0,location + Vector(0,0,300))
  StartAnimation(caster, {duration=60, activity=ACT_DOTA_DIE, rate=.4})        
  end
end)   
Timers:CreateTimer(8, function()
  EmitSoundOnLocationWithCaster(caster:GetOrigin(),"Hero_Warlock.Upheaval", caster)
  for i=1,15 do
  local grasp = ParticleManager:CreateParticle("particles/econ/items/warlock/warlock_staff_glory/warlock_upheaval_hellborn_debuff.vpcf", PATTACH_ABSORIGIN, caster)       
  ParticleManager:SetParticleControl(grasp,0,location + RandomVector(RandomInt(1,150)) - 100 * facing + 100 * left)
  
    Timers:CreateTimer(5, function() 
      ParticleManager:DestroyParticle(grasp,false)
    end)
  end
end)

Timers:CreateTimer(12, function()
  caster:AddNoDraw()
  caster:ForceKill(true)
end)
end      

function make_building_dummy(unit)
  local dummy = CreateUnitByName("npc_particle_dummy_unit", unit:GetOrigin(), false, unit:GetOwner(), unit:GetOwner(), unit:GetTeam())
  Timers:CreateTimer(0,function()
  
  if unit:IsAlive() == false then
  UTIL_Remove(dummy)
  return
  else
  return .1
  end
  
  end)
end

