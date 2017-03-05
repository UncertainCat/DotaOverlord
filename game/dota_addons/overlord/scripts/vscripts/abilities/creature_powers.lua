function ghoul_feeding(keys)
ghoul = keys.caster
target = keys.target
ghoul_heal = keys.creepheal


if target:GetTeam() ~= DOTA_TEAM_NEUTRALS then
    ghoul_heal = keys.heal
end

if target:IsBuilding() or target:IsTower() or target:GetUnitName() == "npc_dota_creature_basic_zombie" or target:GetUnitName() == "npc_dota_creature_greater_zombie" then
    ghoul_heal = 0
end

  ghoul:Heal(ghoul_heal,ghoul)

end

function ghost_void(keys)

local attacker = keys.attacker
local target = keys.target
local ability = keys.ability
local burn = keys.burn

local mana = target:GetMana()
local maxmana = target:GetMaxMana()
local hit =  (maxmana - mana)*burn

local damageTable = {
  victim = target,
  attacker = attacker,
  damage = hit,
  damage_type = DAMAGE_TYPE_PURE,
}
ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_event_glitch.vpcf",PATTACH_ABSORIGIN_FOLLOW,target)
if hit >= 200 then
EmitSoundOnLocationWithCaster(target:GetOrigin(),"DOTA_Item.EtherealBlade.Target",attacker)
elseif RandomInt(1,3) == 3 then
EmitSoundOnLocationWithCaster(target:GetOrigin(),"n_creep_fellbeast.Death",attacker)
end

ApplyDamage(damageTable)

end

function bruiser_lumbering(keys)
local bruiser = keys.caster
local bruiser_loc = bruiser:GetOrigin()
GridNav:DestroyTreesAroundPoint(bruiser_loc, 120, false)
end


function bruiser_leap_slam(keys)
local caster = keys.caster
local near_damage = keys.damage
local far_damage = near_damage/2
local smallradius = 150
local bigradius = 300
keys.ability:ApplyDataDrivenModifier(caster, caster, "leaping_modifier", {})

ParticleManager:CreateParticle("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_c_egset.vpcf",PATTACH_ABSORIGIN,caster)


Physics:start()
 Physics:Unit(caster)
caster:StartPhysicsSimulation()

caster:AddPhysicsVelocity(Vector(0,0,550) + 700* caster:GetForwardVector())
caster:SetPhysicsAcceleration (Vector(0,0,-800))
caster:SetNavCollisionType (PHYSICS_NAV_NOTHING)
local tick = 0
local team = caster:GetTeam()
Timers:CreateTimer(.1, function() 
  if IsValidEntity(caster) == false then return end
  if caster:IsStunned() or caster:IsAlive() == false or caster:GetTeam() ~= team then return 
  elseif tick < 1.5 then tick = tick + .1 return .1 
  elseif tick >= 1.5 then 
    caster:StopPhysicsSimulation()
    local epicenter =  caster:GetAbsOrigin() + caster:GetForwardVector()*150
    EmitSoundOnLocationWithCaster(epicenter, "Hero_ElderTitan.EchoStomp", caster) 
    local cracks = ParticleManager:CreateParticle("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_magma_low_egset.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(cracks, 0, epicenter)
    local targets = FindUnitsInRadius( caster:GetTeam(),epicenter, nil, smallradius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false )
    for _,target in pairs(targets) do
    
      local damageTable = {
      victim = target,
      attacker = caster,
      damage = far_damage,
      damage_type = DAMAGE_TYPE_PHYSICAL,
      }
      ApplyDamage(damageTable) 
      if target:IsMagicImmune() == false then
      fling(caster,target,epicenter,200)  
      end
    end

  local targets = FindUnitsInRadius( caster:GetTeam(),epicenter, nil, bigradius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false )
    for _,target in pairs(targets) do
    keys.ability:ApplyDataDrivenModifier(caster, target, "leap_stun_modifier", {}) 
      local damageTable = {
      victim = target,
      attacker = caster,
      damage = far_damage,
     damage_type = DAMAGE_TYPE_PHYSICAL,
    }
    if target:IsMagicImmune() == false then    
    fling(caster, target,epicenter,50)
    end  
    ApplyDamage(damageTable)  
    end
  GridNav:DestroyTreesAroundPoint(epicenter, bigradius, false)  
  end
end)

end

function bruiser_bash(keys)
local target = keys.target
local caster = keys.caster


local collateral = FindUnitsInRadius( caster:GetTeam(),caster:GetOrigin() + caster:GetForwardVector()*100, nil, 150, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false )
for _,victim in pairs(collateral) do
fling(caster, victim, caster:GetOrigin(),70,PHYSICS_NAV_HALT)
local stuntime
  if victim:IsHero() then
  stuntime = 1.5
  else
  stuntime = 4
  end
keys.ability:ApplyDataDrivenModifier(caster, victim, "modifier_bash_stun_datadriven", {Duration = stuntime})
end
end

function fling(caster,unit,point,strength,NAV)
local fling_damage = .7
if unit:GetClassname() ~= "npc_dota_building" and unit:GetClassname() ~= "npc_dota_tower" and unit:IsMagicImmune() == false and unit:GetClassname() ~= "npc_dota_fort" then
  local direction = unit:GetOrigin() - point 
  local TwoDirection = Vector(direction.x, direction.y, 0)
  local launch_vector = (TwoDirection + Vector(0,0,1)*(TwoDirection:Length())):Normalized()
  if NAV == nil then
  NAV = PHYSICS_NAV_NOTHING
  end
  Physics:start()
   Physics:Unit(unit)
  unit:StartPhysicsSimulation()
  local hit_velocity = launch_vector*strength*10
  unit.fling_velocity = hit_velocity + unit:GetPhysicsVelocity()
  unit:AddPhysicsVelocity(hit_velocity)
  unit:SetNavCollisionType(NAV)
  if unit.fling_velocity:Length() > 1000 then
    if unit:IsHero() then
    EmitSoundOnLocationWithCaster(unit:GetOrigin(), "Hero_Tiny.Toss.Target", unit)
    end
  end
  if unit.IsUnderFling == nil then    
    unit.IsUnderFling = true    
        Timers:CreateTimer(.1, function()
          if IsValidEntity(unit) then        
            local pos = unit:GetAbsOrigin()
            local relative_height = (pos.z - GetGroundHeight(pos,nil))
            if unit:GetPhysicsVelocity().z > 50 or relative_height > 50 then
            unit.fling_velocity = unit:GetPhysicsVelocity()
            unit:AddPhysicsVelocity(Vector(0,0,-1) * 150  )    
            
            return .1
            else 
              unit:SetAbsOrigin(GetGroundPosition(unit:GetAbsOrigin(), nil))
              local landing_damage =  unit.fling_velocity:Length() * fling_damage
              if landing_damage > 300 then           
                local damageTable = {
                  victim = unit,
                  attacker = caster,
                  damage = landing_damage,
                  damage_type = DAMAGE_TYPE_PHYSICAL,
                  }
                ApplyDamage(damageTable)  
                local shockwave = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_toss_impact_b.vpcf", PATTACH_ABSORIGIN, unit)
                ParticleManager:SetParticleControl(shockwave,0,unit:GetOrigin())           
                EmitSoundOnLocationWithCaster(unit:GetOrigin(),"Ability.TossImpact",unit)
                GridNav:DestroyTreesAroundPoint(pos, 250, false)
              end
              unit.IsUnderFling = nil    
              Timers:CreateTimer(1, function() 
              unit:StopPhysicsSimulation()
              unit:AddNewModifier(unit, nil, "modifier_phased", {Duration = .1})
              end)
              return
            end
          end  
        end)
  end
end
end

function demon_lord_aura(keys)
local demon = keys.caster
local burn_damage = keys.burn
local radius = 300

local nearby_units = FindUnitsInRadius( demon:GetTeam(), demon:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false )
  for _,unit in pairs(nearby_units) do
    if unit:GetClassname() == "npc_dota_building" or unit:GetClassname() == "npc_dota_tower" then
    burn_damage = burn_damage/4
    end
    local damageTable = {
    victim = unit,
    attacker = demon,
    damage = burn_damage/2,
   damage_type = DAMAGE_TYPE_MAGICAL,
  }
  ApplyDamage(damageTable)  
  local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_dual_breath_firebreath.vpcf",PATTACH_ABSORIGIN,demon)
          ParticleManager:SetParticleControl(particle, 3,unit:GetOrigin() + Vector(0,0,100) + RandomVector(10))
            Timers:CreateTimer(1, function()
                if IsValidEntity(unit) then
               GridNav:DestroyTreesAroundPoint(unit:GetOrigin(), 250, false)
               end
            end)
  end
  
 trees = GridNav:GetAllTreesAroundPoint(demon:GetOrigin(), radius, true)
 
 for _,tree in pairs(trees) do
 if RandomInt(1,2) == 2 then
   ignite_tree(tree,demon)
 end    
 end 
  
AddFOWViewer(demon:GetTeam(),demon:GetOrigin(), 600, .6, false)  
  
end

function ignite_tree(tree,caster)
tree_origin = tree:GetOrigin()
local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_dual_breath_firebreath.vpcf",PATTACH_ABSORIGIN,caster)
          ParticleManager:SetParticleControl(particle, 3,tree:GetOrigin() + Vector(0,0,RandomInt(80,130)) + RandomVector(10))
            Timers:CreateTimer(1.5, function()
               GridNav:DestroyTreesAroundPoint(tree_origin, 200, false)
            end)   
end

function monster_effects(keys,monster)
  local caster = keys.caster
  local point = keys.target_points[1]

  local particle = ParticleManager:CreateParticle("particles/econ/items/warlock/warlock_staff_glory/warlock_upheaval_hellborn_debuff.vpcf", PATTACH_ABSORIGIN, monster)
  local bparticle = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos.vpcf",PATTACH_ABSORIGIN,monster)
  local cparticle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf", PATTACH_ABSORIGIN_FOLLOW,monster)
  ParticleManager:SetParticleControl(bparticle,1,Vector(1000,100,10))
  ParticleManager:SetParticleControl(particle,0,point)
  if caster ~= nil then
  caster.summon_monster_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf", PATTACH_ABSORIGIN,caster)
  end
  Timers:CreateTimer(4, function()
      ParticleManager:DestroyParticle(particle, false)
      ParticleManager:DestroyParticle(cparticle, false)
  end)


  if monster:GetUnitName() == "npc_dota_creature_demon_lord" then----------demon lord particles ------------
      EmitSoundOn("warlock_golem_wargol_spawn_04a",monster)
    Timers:CreateTimer(1, function()        
       if monster:IsNull() then
       return
       end
       if monster == nil then
       return
       end
       
       local facing = monster:GetForwardVector()
       local left = facing:Cross(Vector(0,0,1))
       local right = facing:Cross(Vector(0,0,-1))
                      
       leftpoint = facing*170 + left*170 + monster:GetOrigin() + Vector(0,0,150 + RandomInt(1,250))
       center = monster:GetOrigin() + Vector(0,0,50 + RandomInt(1,450))
       rightpoint = facing*170 + right*170 + monster:GetOrigin() + Vector(0,0,150 + RandomInt(1,250))
       
       for _,point in pairs({leftpoint,center,rightpoint}) do
       
       if RandomInt(1,10) ~= 1 then
         local flame = ParticleManager:CreateParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_loadout_end_swirl.vpcf",PATTACH_ABSORIGIN,monster)
         ParticleManager:SetParticleControl(flame, 0,point)  
       else
        local flame = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_dual_breath_firebreath.vpcf",PATTACH_ABSORIGIN,monster)
        ParticleManager:SetParticleControl(flame, 3,point)            
       end
       end
  return 0.3 end)
  end


end

function rain_of_chaos(keys)
local caster = keys.caster
local damage = keys.meteor_damage
local meteor_count = 900

EmitSoundOn("warlock_golem_wargol_spawn_18",caster)
  Timers:CreateTimer(3, function()
    for i = 1,meteor_count do
      cast_origin = caster:GetOrigin()
      Timers:CreateTimer(RandomFloat(0,60), function()
        if IsValidEntity(caster) and caster:IsAlive() then
        call_meteor(caster,cast_origin + RandomVector(RandomInt(0,8000)), damage)
        end
      end)   
    end
  end)   
end

function call_meteor(caster,random_target,burn_damage)

local radius = 180
local drop_time = 1.4

ground_height = GetGroundHeight(random_target, {})
random_target = random_target - random_target:Dot(Vector(0,0,1)) + ground_height
EmitSoundOnLocationWithCaster(random_target, "Hero_Invoker.ChaosMeteor.Cast", caster) --
local warn = ParticleManager:CreateParticle("particles/rain_of_chaos/sf_fire_arcana_wings_grow_rope_no_cull.vpcf", PATTACH_ABSORIGIN, GameMode.ancient)
ParticleManager:SetParticleControl(warn,0,random_target)
local smoke = ParticleManager:CreateParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_requiemofsouls_head_swirl_smoke.vpcf", PATTACH_ABSORIGIN, GameMode.ancient )
ParticleManager:SetParticleControl(smoke,3,random_target)
local meteor = ParticleManager:CreateParticle("particles/rain_of_chaos/invoker_chaos_meteor_fly_no_cull.vpcf", PATTACH_ABSORIGIN, GameMode.ancient )
ParticleManager:SetParticleControl(meteor,0,random_target+Vector(0,0,1400) + RandomVector(1000))
ParticleManager:SetParticleControl(meteor,1,random_target)
ParticleManager:SetParticleControl(meteor,2,Vector(2,0,0))
Timers:CreateTimer(drop_time, function()
    GridNav:DestroyTreesAroundPoint(random_target, 300, false)
    EmitSoundOnLocationWithCaster(random_target, "Hero_Invoker.ChaosMeteor.Impact", caster)
    crumble = ParticleManager:CreateParticle("particles/rain_of_chaos/invoker_chaos_meteor_crumble_no_cull.vpcf",PATTACH_ABSORIGIN,GameMode.ancient) 
    ParticleManager:SetParticleControl(crumble,3,random_target+Vector(0,0,50))
  ---actual damage and stats per meteor here
    local caster_team = DOTA_TEAM_CUSTOM_1
    if  caster ~= nil then
      if caster:IsNull() == false then
          if caster:IsAlive() then  
            caster_team = caster:GetTeam()
          end
      end
    end      

  local nearby_units = FindUnitsInRadius(caster_team , random_target, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false ) 
  for _,unit in pairs(nearby_units) do
    
          
    if unit:GetClassname() == "npc_dota_building" or unit:GetClassname() == "npc_dota_tower" then
    burn_damage = burn_damage/4
    end
    local damage_source = nil
    if  caster ~= nil then
      if caster:IsNull() == false then
        damage_source = caster
        end
    end   
    if caster ~= nil then
      if caster:IsNull() then
      caster = nil
      end
    end
    local damageTable = {
    victim = unit,
    attacker = caster,
    damage = burn_damage,
   damage_type = DAMAGE_TYPE_MAGICAL,
  }
  ApplyDamage(damageTable) 
  end
  ----
end)   

end

function soul_harvest(keys)
local harvester = keys.caster
local harvester_radius = keys.radius
local player = harvester:GetOwner()
local playerID = player:GetPlayerID()
local overlord = harvester:GetOwner()
local overlord_pos = overlord:GetOrigin()
local harvester_pos = harvester:GetOrigin()
local heal_amount = 100

if harvester.mana_harvested == nil then
harvester.mana_harvested = 0
harvester:SetMana(0)
end
local newsize = 1.6*math.sqrt(harvester.mana_harvested/1000 ) + .9
nearby_units = FindUnitsInRadius(harvester:GetTeam() , harvester:GetOrigin(), nil, harvester_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false ) 

for _,unit in pairs(nearby_units) do

    local starting_mana = unit:GetMana()
    if starting_mana>1 then
    local yield = 0 
      if unit:IsHero() then
        unit:SetMana(unit:GetMana() - 4)     
      harvester.mana_harvested = harvester.mana_harvested + (starting_mana - unit:GetMana())*4
      
      Timers:CreateTimer(RandomFloat(0,.5), function()
        lightning = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_basher_ambient_lightning_b.vpcf",PATTACH_ABSORIGIN,harvester)
        ParticleManager:SetParticleControl(lightning,3,unit:GetOrigin() )
        ParticleManager:SetParticleControl(lightning,4,harvester_pos + Vector(0,0,110 + 3.5 * newsize ) + ((unit:GetOrigin() - harvester_pos):Normalized()) * 25 )    
        end)
  
      else
      unit:SetMana(unit:GetMana() - 8)
      harvester.mana_harvested = harvester.mana_harvested + (starting_mana - unit:GetMana())
      end


    if RandomInt(1,4) > 0 then
    Timers:CreateTimer(RandomFloat(0,1), function()
      lightning = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_basher_ambient_lightning_b.vpcf",PATTACH_ABSORIGIN,harvester)
      ParticleManager:SetParticleControl(lightning,3,harvester_pos + ((unit:GetOrigin() - harvester_pos):Normalized()) * RandomInt(400,1000) )
      ParticleManager:SetParticleControl(lightning,4,harvester_pos + Vector(0,0,110 + 3.5 * newsize ) + ((unit:GetOrigin() - harvester_pos):Normalized()) * 25 )    
      end)
    end
    end
end

if (harvester_pos - overlord_pos):Length() < 400 then -- and harvester.mana_harvested < heal_amount then
  local current_mana = overlord:GetMana()
  local max_mana = overlord:GetMaxMana()
  local health = overlord:GetHealth()
  local max_health = overlord:GetMaxHealth() 
  if health < max_health and harvester.mana_harvested > heal_amount then
    overlord:Heal(heal_amount, harvester)
    harvester.mana_harvested = harvester.mana_harvested + health - overlord:GetHealth()
    local healeffect = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf", PATTACH_ABSORIGIN_FOLLOW,overlord)
    local healbeam = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_life_drain.vpcf", PATTACH_OVERHEAD_FOLLOW, overlord)
      EmitSoundOnLocationWithCaster(overlord_pos,"Hero_Abaddon.Death" , overlord)    
      if overlord.soundcd == nil then
      overlord.soundcd = 0
      end
    
      if overlord.soundcd == 0 and health < 1000 then
      
      EmitSoundOnLocationWithCaster(overlord_pos,"Hero_Abaddon.BorrowedTime",overlord)
 
      end
    overlord.soundcd = 1 + overlord.soundcd
        Timers:CreateTimer(1, function()
        overlord.soundcd = overlord.soundcd - 1
       end)
  
    ParticleManager:SetParticleControl(healbeam,1,harvester_pos + Vector(0,0,130 + 3.5 * newsize ))
    ParticleManager:SetParticleControl(healbeam,11,Vector(1,0,0))
        Timers:CreateTimer(1, function()
          ParticleManager:DestroyParticle(healbeam,false)
          ParticleManager:DestroyParticle(healeffect,false)        
        end)     

  elseif current_mana  < max_mana and harvester.mana_harvested > heal_amount then
    overlord:GiveMana(heal_amount/5)
    
    harvester.mana_harvested = harvester.mana_harvested + (current_mana - overlord:GetMana())*2
   
    local healeffect = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf", PATTACH_ABSORIGIN_FOLLOW,overlord)
    local healbeam = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_life_drain_beam_2e_give_give_give.vpcf", PATTACH_OVERHEAD_FOLLOW, overlord)
       EmitSoundOnLocationWithCaster(overlord_pos,"Hero_Abaddon.Death" , overlord)  

 
    ParticleManager:SetParticleControl(healbeam,1,harvester_pos + Vector(0,0,130 + 3.5 * newsize ))
    ParticleManager:SetParticleControl(healbeam,11,Vector(1,0,0))
        Timers:CreateTimer(1, function()
          ParticleManager:DestroyParticle(healbeam,false)
          ParticleManager:DestroyParticle(healeffect,false)        
        end)           

  end
end

local mana = harvester:GetMana()
harvester:SetMana(harvester.mana_harvested)
harvester.mana_harvested = harvester:GetMana()
if newsize < 3.5 then
harvester:SetModelScale(newsize)
end
end

function breath_of_winter_start(keys)
caster = keys.caster
EmitSoundOnLocationWithCaster(caster:GetOrigin(), "Hero_Winter_Wyvern.WintersCurse.Target", caster) --
end

function breath_of_winter(keys)
local caster = keys.caster
local shard_damage = 50
local range = 2000
StartAnimation(caster, {duration=2, activity=ACT_DOTA_CAST_ABILITY_2, rate=.8})
EmitSoundOnLocationWithCaster(caster:GetOrigin(), "Hero_Winter_Wyvern.WintersCurse.Cast", caster)

for i=1,10 do

Timers:CreateTimer(i * .2, function()
  local icepath = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_ice_path_shards.vpcf", PATTACH_ABSORIGIN, caster)
  local target = caster:GetOrigin() + caster:GetForwardVector()*2000
  EmitSoundOnLocationWithCaster(caster:GetOrigin(), "Hero_Jakiro.IcePath", caster)
  ParticleManager:SetParticleControl(icepath,0,caster:GetOrigin() + caster:GetForwardVector()*200)
  ParticleManager:SetParticleControl(icepath,1,target + RandomVector(30) - Vector(0,0,300))
  ParticleManager:SetParticleControl(icepath,2,Vector(2,0,0))
  
  
  
  local area = AreaTargeting:MakeRectangle(range,200,caster:GetForwardVector(),caster:GetOrigin()) --(length,width,direction,start)
  local args_table = {teamNumber = caster:GetTeam() , teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY, typeFilter = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, flagFilter = 0, order = FIND_ANY_ORDER, canGrowCache = false}
  local popsicles = AreaTargeting:FindUnitsInShape(area, args_table)
  for _,popsicle in pairs(popsicles) do
  keys.ability:ApplyDataDrivenModifier(caster, popsicle, "breath_freeze", {})  
  end
  local cast_origin = caster:GetOrigin()
  local team = caster:GetTeam()
  Timers:CreateTimer(1.5, function()
  ParticleManager:DestroyParticle(icepath,true)
    for i=1,10 do
    local explosion = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_flash_c_cowlofice.vpcf", PATTACH_ABSORIGIN, caster)
    local explosion_point = target - (target - cast_origin)*RandomFloat(0,1)
    GridNav:DestroyTreesAroundPoint(explosion_point,70, true) 
    if RandomInt(1,5) == 5 then
    EmitSoundOnLocationWithCaster(caster:GetOrigin(), "Hero_Winter_Wyvern.SplinterBlast.Splinter", caster)
    end
    ParticleManager:SetParticleControl(explosion,0, explosion_point )
    local victims = FindUnitsInRadius(team,explosion_point , nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0 , FIND_ANY_ORDER, false)  
      for _,target in pairs(victims) do
        keys.ability:ApplyDataDrivenModifier(caster, popsicle, "breath_freeze", {})        
        local damageTable = {
        victim = target,
        attacker = caster,
        damage = shard_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,}
        ApplyDamage(damageTable)           
      end       
    end
  end)  
end)     
end
end

function ice_dragon_passive(keys)
local caster = keys.caster

if caster:GetHealth() > caster:GetMaxHealth()/4 then
  keys.ability:ApplyDataDrivenModifier(caster, caster, "flight_modifier", {})  


end
end

