

DEFAULT_STATE = 1
COMMAND_STATE = 2
HERO_STATE = 3
SPAWNER_STATE = 4
BUILDING_STATE = 5
SUMMON_STATE = 6

function create_ability_tables(overlord)

overlord.default_state_table = {
{"create_spawner_ability",1},
{"hero_abilities",1},
{"create_building_ability",1} ,
{"summon_monster_ability",0},
{"unit_orders_ability",1},
{"frostmourne_datadriven",1}--
}

overlord.command_state_table = {
{"attack_command",1},
{"move_command",1},
{"defend_command",1},
{"kill_command",1},
{"global_attack_command",0},
{"return_ability",1}
}

overlord.hero_state_table = {
{"abaddon_death_coil",1},
{"night_stalker_crippling_fear",1},
{"blinding_mists",1},
{"betrayal",0},
{"abaddon_aphotic_shield",0},
{"return_ability",1}
}

overlord.spawner_state_table = {
{"summon_ghoul_spawner",1},
{"summon_melee_spawner",1},
{"summon_ranged_spawner", 1},
{"summon_zombie_spawner",0},
{"summon_orc_spawner",0},
{"return_ability",1}
}

overlord.building_state_table = {
{"build_overseer",1},
{"build_flame_turret",1},
{"build_heartstopper_ward",0,},
{"build_soul_harvester",0},
{"build_vampiric_shrine",0},
{"return_ability",1}
}

overlord.summon_state_table = {
{"summon_monster_bruiser",1},
{"summon_monster_ghost",0},
{"summon_monster_nether_lich",0},
{"summon_monster_dragon",0},
{"summon_monster_demon_lord",0},
{"cancel_summon_ability",1}
}

overlord.state_metatable = {
overlord.default_state_table,
overlord.command_state_table,
overlord.hero_state_table,
overlord.spawner_state_table,
overlord.building_state_table,
overlord.summon_state_table,
}
end