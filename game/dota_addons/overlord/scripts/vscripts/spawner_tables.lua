
if spawners.spawner_table == nil then
spawners.spawner_table = {}
end

if spawners.dire_spawned_units == nil then
spawners.dire_spawned_units = {}
end

if spawners.neutral_spawned_units == nil then
spawners.neutral_spawned_units = {}
end

spawners.melee_spawn_string = "npc_dota_creep_badguys_melee" 
spawners.ranged_spawn_string = "npc_dota_creep_badguys_ranged"
spawners.warcamp_spawn_string = "npc_dota_creature_lesser_orc"
spawners.zombie_spawn_string = "npc_dota_creature_basic_zombie"
spawners.ghoul_spawn_string = "npc_dota_creature_lesser_ghoul"

upgrade_table = {}
upgrade_table["npc_dota_creep_badguys_melee" ] = "npc_dota_creep_badguys_melee_upgraded"
upgrade_table["npc_dota_creep_badguys_ranged"] = "npc_dota_creep_badguys_ranged"
upgrade_table["npc_dota_creature_basic_zombie"] = "npc_dota_creature_greater_zombie"
upgrade_table["npc_dota_creature_lesser_ghoul"] = "npc_dota_creature_greater_ghoul"
upgrade_table["npc_dota_creature_lesser_orc"] = "npc_dota_creature_greater_orc"

spawners.ai = {}
spawners.ai[spawners.melee_spawn_string] = "attack_base"
spawners.ai[spawners.ranged_spawn_string] = "attack_base"
spawners.ai[spawners.warcamp_spawn_string] = "hunt"
spawners.ai[spawners.zombie_spawn_string] = "wander"
spawners.ai[spawners.ghoul_spawn_string] = "farm"

spawners.ai["npc_dota_creep_badguys_melee_upgraded"] = "attack_base"
spawners.ai["npc_dota_creep_badguys_ranged"] = "attack_base"
spawners.ai["npc_dota_creature_greater_zombie"] = "wander"
spawners.ai["npc_dota_creature_greater_ghoul"] = "farm"
spawners.ai["npc_dota_creature_greater_orc"] = "hunt"
spawners.ai["npc_dota_creature_bruiser"] = "ogre"
spawners.ai["npc_dota_creature_spooky_ghost"] = "wander"
spawners.ai["npc_dota_creature_nether_lich"] = "nether_lich"
spawners.ai["npc_dota_creature_demon_lord"] = "demon_lord"
spawners.ai["npc_dota_creature_ice_dragon"] = "wander"

gold_cost = {}
gold_cost["npc_dota_creep_badguys_melee" ] = 10
gold_cost["npc_dota_creep_badguys_ranged"] = 10
gold_cost["npc_dota_creature_basic_zombie"] = 10
gold_cost["npc_dota_creature_lesser_ghoul"] = 35
gold_cost["npc_dota_creep_badguys_melee_upgraded"] = 15
gold_cost["npc_dota_creep_badguys_ranged_upraded"] = 15
gold_cost["npc_dota_creature_greater_zombie"] = 250
gold_cost["npc_dota_creature_greater_ghoul"] = 120
gold_cost["npc_dota_creature_lesser_orc"] = 60
gold_cost["npc_dota_creature_greater_orc"] = 400