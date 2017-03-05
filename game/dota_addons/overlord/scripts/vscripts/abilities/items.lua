function skill_book(keys)
local target = keys.target
target:SetAbilityPoints(target:GetAbilityPoints()+1)
EmitSoundOnClient("powerup_02",target:GetOwner())
end

function whistle(keys)
local caster = keys.caster
EmitSoundOnLocationWithCaster(caster:GetOrigin(),"Item.GreevilWhistle",caster)
Timers:CreateTimer(2, function()
  local spawn_table = {"npc_dota_creep_goodguys_melee", "npc_dota_creep_goodguys_ranged", "npc_dota_creature_wandering_vhoul", "npc_dota_creature_gargoyle", "npc_dota_neutral_black_dragon", "npc_dota_neutral_black_drake", "npc_dota_neutral_harpy_storm", "npc_dota_neutral_harpy_scout", "npc_dota_neutral_forest_troll_high_priest", "npc_dota_neutral_forest_troll_berserker",   "npc_dota_neutral_dark_troll", "npc_dota_neutral_dark_troll_warlord", "npc_dota_neutral_small_thunder_lizard","npc_dota_neutral_satyr_soulstealer","npc_dota_neutral_giant_wolf","npc_dota_neutral_polar_furbolg_champion","npc_dota_neutral_kobold_tunneler","npc_dota_creep_goodguys_ranged_upgraded_mega","npc_dota_creep_goodguys_ranged_upgraded","npc_dota_creep_goodguys_melee_upgraded","npc_dota_creep_goodguys_melee_upgraded_mega","npc_dota_neutral_kobold","npc_dota_neutral_centaur_outrunner","npc_dota_neutral_centaur_khan","npc_dota_neutral_polar_furbolg_ursa_warrior","npc_dota_neutral_mud_golem","npc_dota_neutral_ogre_mauler","npc_dota_neutral_ogre_magi","npc_dota_neutral_alpha_wolf","npc_dota_neutral_enraged_wildkin","npc_dota_neutral_granite_golem","npc_dota_neutral_big_thunder_lizard","npc_dota_neutral_gnoll_assassin","npc_dota_neutral_satyr_trickster","npc_dota_neutral_harpy_storm"  }
  local name_string = spawn_table[RandomInt(1,#spawn_table)]
  summon_minion(keys,name_string)
end)
end

function mushroom(keys)
local caster = keys.caster
EmitSoundOnLocationWithCaster(caster:GetOrigin(),"DOTA_Item.Cheese.Activate",caster)
local effect_duration = keys.duration
local bubbles = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_drunken_haze_bubbles.vpcf", PATTACH_ABSORIGIN, caster)
ParticleManager:SetParticleControl(bubbles,1,caster:GetOrigin())
local poof = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_dark_pact_pulses_edge_sml.vpcf", PATTACH_ABSORIGIN, caster)
ParticleManager:SetParticleControl(poof,1,caster:GetOrigin() + Vector(0,0,100))
ParticleManager:SetParticleControl(poof,3,caster:GetOrigin() + Vector(0,0,100))
local shroom_table = {"heal", "mana", "blind",  "magic_immune", "silenced", "invisible", "haste", "min_health", "poison", "speed"}
local modifiers_string = "modifier_item_strange_mushroom_"..shroom_table[RandomInt(1,#shroom_table)]
keys.ability:ApplyDataDrivenModifier(caster, caster, modifiers_string, {strength = 10, duration = effect_duration})
EmitSoundOnLocationWithCaster(caster:GetOrigin(),"powerup_05",caster)
end

function summon_minion(keys,name_string)
  local caster = keys.caster
  local minion = CreateUnitByName(name_string, caster:GetOrigin() + 140*caster:GetForwardVector(), true, caster:GetOwner(), caster:GetOwner(), caster:GetTeam())
  minion:SetForwardVector(caster:GetForwardVector())
  EmitSoundOnLocationWithCaster(minion:GetOrigin(),"compendium_levelup",minion)
  minion:SetTeam(DOTA_TEAM_GOODGUYS)
  minion:SetOwner(caster)
  minion:AddNewModifier(caster, keys.ability, "modifier_kill", {duration = 180})
  ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_recall_poof.vpcf",PATTACH_ABSORIGIN,minion)
  local PID = caster:GetPlayerID()
  minion:SetControllableByPlayer(PID, false)  
end

function pocket_tower(keys)
local caster = keys.caster
local duration = keys.duration
local point = keys.target_points[1]
local tower = CreateUnitByName("npc_dota_pocket_tower", point, true, caster:GetOwner(), caster:GetOwner(), caster:GetTeam())
tower:SetOrigin(point)
tower:RemoveModifierByName("modifier_invulnerable")
tower:SetForwardVector(Vector((point - caster:GetOrigin()).x, (point - caster:GetOrigin()).y,0))


tower:SetOwner(caster:GetOwner())


end