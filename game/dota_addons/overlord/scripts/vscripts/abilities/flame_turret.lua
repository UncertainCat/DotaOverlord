require('dire_events')




function launch_fire(keys)
local trigger_radius = 600
local caster = keys.caster
local point = caster:GetOrigin() - caster:GetForwardVector() * 150
local fire = CreateUnitByName( "npc_dota_fire_spirit", point, true, nil, caster, caster:GetTeam())
fire:AddNewModifier(caster, keys.ability, "modifier_kill", {duration = 10})
fire:SetOwner(caster:GetOwner())

Timers:CreateTimer(0, function()
  if fire:IsNull() then
  return
  end
  if fire:IsAlive() == false then
    UTIL_Remove(fire)
    return
  end
  local fireball = ParticleManager:CreateParticle("particles/econ/items/doom/doom_f2p_death_effect/doom_bringer_f2p_death_fire.vpcf",PATTACH_ABSORIGIN_FOLLOW,fire)
  ParticleManager:SetParticleControl(fireball, 3, fire:GetOrigin())
  return .8
end)

local near_units = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, trigger_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false )
if #near_units > 0 then
  Timers:CreateTimer(.1, function() 
  AttackToTarget(fire,near_units[1])
  end)
end

end

function fire_turret_passive(keys)
local caster = keys.caster
local trigger_radius = 600
local ability = caster:FindAbilityByName("flame_turret_fire")
local near_units = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, trigger_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false )
if #near_units > 0 then
CastAbilityNoTarget(caster,ability)
end
end

