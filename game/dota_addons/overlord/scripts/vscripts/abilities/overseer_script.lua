

watcher_speed = 40
SIGHT_RADIUS = 200
MAX_RANGE = 2000
MIN_RANGE = 400

function overseer_passive(keys)
local watcher = keys.caster

watcher.ability = keys.ability
if watcher.state == nil then
watcher.cooldown = 0
watcher.state = "new_scan"
watcher.focus = watcher:GetAbsOrigin()
end
AddFOWViewer(watcher:GetTeam(), watcher.focus, SIGHT_RADIUS,.75, false)

if watcher.state == "new_scan" then
new_scan(watcher)
end

if watcher.state == "sweep" then
sweep(watcher)
end
local length = (watcher.target - watcher:GetAbsOrigin()):Length()

if length > MAX_RANGE then
watcher.target = watcher:GetAbsOrigin() + (watcher.target - watcher:GetAbsOrigin()) * MAX_RANGE/length
end


watcher:SetForwardVector(watcher.focus - watcher:GetAbsOrigin()) 

  local distort = ParticleManager:CreateParticle("particles/econ/items/templar_assassin/templar_assassin_butterfly/templar_assassin_base_attack_explosion_warp_butterfly.vpcf",PATTACH_ABSORIGIN, GameMode.ancient)
  local origin = watcher.focus - watcher.focus:Dot(Vector(0,0,1)) + GetGroundHeight(watcher.focus, nil) + RandomVector(RandomInt(1,10))
  ParticleManager:SetParticleControl(distort, 1,origin + Vector(0,0,00))
  Timers:CreateTimer(.2,function() ParticleManager:DestroyParticle(distort,false) end)
  if RandomInt(1,20) > 19 then 
  local beam = ParticleManager:CreateParticle("particles/econ/items/lanaya/lanaya_epit_trap/templar_assassin_epit_trap_explode_arcs.vpcf",PATTACH_ABSORIGIN, GameMode.ancient)
  local origin = watcher.focus - watcher.focus:Dot(Vector(0,0,1)) + GetGroundHeight(watcher.focus, nil) + RandomVector(RandomInt(1,10))
  ParticleManager:SetParticleControl(beam, 0,origin + Vector(0,0,00))
  Timers:CreateTimer(2,function() ParticleManager:DestroyParticle(beam,false) end)
  end
  
end

function new_scan(watcher)

for i=1,10 do
local new_target = watcher:GetAbsOrigin() + RandomVector(RandomInt(1500,MAX_RANGE))
  if GridNav:CanFindPath(watcher.focus,new_target) then
    watcher.target = new_target
    watcher.state = "sweep"
    return
  end

end

watcher.target = watcher.focus + RandomVector(1000)
watcher.state = "sweep"
end

function sweep(watcher)

watcher.focus = watcher.focus + (watcher.target - watcher.focus):Normalized() * watcher_speed

visible_units = FindUnitsInRadius( watcher:GetTeam(), watcher:GetAbsOrigin(), nil, MAX_RANGE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )

if #visible_units>0 then
watcher.target = visible_units[1]:GetAbsOrigin()
MinimapEvent(watcher:GetTeam(), watcher, watcher.target:Dot(Vector(1,0,0)), watcher.target:Dot(Vector(0,1,0)),DOTA_MINIMAP_EVENT_ENEMY_TELEPORTING, 1) -- (nTeamID, hEntity, nXCoord, nYCoord, nEventType, nEventDuration).
end

watched_units = FindUnitsInRadius( watcher:GetTeam(), watcher.focus, nil, SIGHT_RADIUS, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false )
if watcher.cooldown < 1  and #watched_units > 0 then
  spawners:command_in_radius("attack_move", watcher:GetAbsOrigin(),watcher:GetTeam(), watched_units[1]:GetOrigin(), MAX_RANGE)
  ParticleManager:CreateParticle("particles/items_fx/dust_of_appearance_true_sight.vpcf",PATTACH_ABSORIGIN_FOLLOW, watched_units[1])
  watcher.cooldown = 50 --5 seconds
elseif watcher.cooldown > 0 then
  watcher.cooldown = watcher.cooldown - 1
end
  
  for _,unit in pairs(watched_units) do
    watcher.ability:ApplyDataDrivenModifier(watcher, unit, "watched_modifier", {})
   -- ParticleManager:CreateParticle("particles/items_fx/dust_of_appearance_true_sight.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
  end

if (watcher.target - watcher.focus):Length()< watcher_speed then
watcher.state = "new_scan"
end

end
