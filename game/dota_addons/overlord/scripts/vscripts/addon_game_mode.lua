-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')

function Precache( context )
--[[
  This function is used to precache resources/units/items/abilities that will be needed
  for sure in your game and that will not be precached by hero selection.  When a hero
  is selected from the hero selection screen, the game will precache that hero's assets,
  any equipped cosmetics, and perform the data-driven precaching defined in that hero's
  precache{} block, as well as the precache{} block for any equipped abilities.

  See GameMode:PostLoadPrecache() in gamemode.lua for more information
  ]]

  DebugPrint("[BAREBONES] Performing pre-load precache")

  -- Particles can be precached individually or by folder
  -- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
  PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
  PrecacheResource("particle", "particles/econ/events/league_teleport_2014/teleport_start_e_league.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_alchemist/alchemist_lasthit_coins.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_slark/slark_dark_pact_pulses.vpcf", context)
  PrecacheResource("particle_folder", "particles/test_particle", context)
  PrecacheResource("particle", "particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_flash_c_cowlofice.vpcf", context)
  PrecacheResource("particle", "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_loadout_end_swirl.vpcf", context)
  PrecacheResource("particle", "particles/rain_of_chaos/sf_fire_arcana_wings_grow_rope_no_cull.vpc", context)
  PrecacheResource("particle", "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_requiemofsouls_head_swirl_smoke.vpcf", context)
  PrecacheResource("particle", "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_basher_ambient_lightning_b.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_pugna/pugna_life_drain.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_pugna/pugna_life_drain_beam_2e_give_give_give.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_jakiro/jakiro_ice_path_shards.vpcf", context)
  PrecacheResource("particle", "particles/econ/items/doom/doom_f2p_death_effect/doom_bringer_f2p_death_fire.vpcf", context)
  PrecacheResource("particle", "particles/base_attacks/ranged_tower_good.vpcf", context)
  PrecacheResource("particle", "particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_c_egset.vpcf", context)
  PrecacheResource("particle", "particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_magma_low_egset.vpcf", context)  
  PrecacheResource("particle", "particles/econ/items/templar_assassin/templar_assassin_butterfly/templar_assassin_base_attack_explosion_warp_butterfly.vpcf", context)
  PrecacheResource("particle", "particles/econ/items/lanaya/lanaya_epit_trap/templar_assassin_epit_trap_explode_arcs.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_recall_poof.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_wings.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_tiny/tiny_toss_impact_b.vpcf", context) 
  -- Models can also be precached by folder or individually
  -- PrecacheModel should generally used over PrecacheResource for individual models
  PrecacheResource("model_folder", "particles/heroes/antimage", context)
 -- PrecacheResource("model_folder", "models/items/courier", context)
  PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
  
  PrecacheModel("models/props_items/necronomicon.vmdl", context)

  -- Sounds can precached here like anything else

  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_jakiro.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_tiny.vsndevts", context)  
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_lion.vsndevts", context) 
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context)    
  PrecacheResource("soundfile", "soundevents/game_sounds_custom.vsndevts", context)    
  -- Entire items can be precached by name
  -- Abilities can also be precached in this way despite the name
  PrecacheItemByNameSync("example_ability", context)
  PrecacheItemByNameSync("item_example_item", context)

  -- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
  -- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
  PrecacheUnitByNameSync("npc_dota_hero_invoker", context)  --rain of chaos
  PrecacheUnitByNameSync("npc_dota_hero_warlock", context)  --sounds on demon lord
  PrecacheUnitByNameSync('npc_dota_creature_bruiser', context)
  PrecacheUnitByNameSync('npc_dota_hero_abaddon', context)
  PrecacheUnitByNameSync('npc_dota_hero_night_stalker', context)  
  PrecacheUnitByNameSync('npc_dota_creature_spooky_ghost', context)
  PrecacheUnitByNameSync('npc_dota_creature_nether_lich', context)
  PrecacheUnitByNameSync('npc_overseer', context)
  PrecacheUnitByNameSync('npc_dota_creature_demon_lord', context)  
  PrecacheUnitByNameSync('npc_dota_hero_winter_wyvern', context)
  PrecacheUnitByNameSync("npc_melee_spawner", context)
  PrecacheUnitByNameSync("npc_zombie_spawner", context)
  PrecacheUnitByNameSync("npc_ranged_spawner", context)
  PrecacheUnitByNameSync("npc_dota_creature_basic_zombie", context)
  PrecacheUnitByNameSync("npc_melee_spawner" , context)
  PrecacheUnitByNameSync("npc_ranged_spawner", context)           
  PrecacheUnitByNameSync("npc_zombie_spawner", context)                   
  PrecacheUnitByNameSync("npc_dota_creature_basic_zombie", context)          
  PrecacheUnitByNameSync("npc_dota_creature_greater_zombie", context)      
  PrecacheUnitByNameSync("npc_dota_creature_bruiser", context)            
  PrecacheUnitByNameSync("npc_ghoul_spawner", context)      
  PrecacheUnitByNameSync("npc_dota_creature_lesser_ghoul", context)       
  PrecacheUnitByNameSync("npc_dota_creature_greater_ghoul", context)
  PrecacheUnitByNameSync("npc_dota_creature_lesser_orc", context)       
  PrecacheUnitByNameSync("npc_dota_creature_greater_orc", context)  
  PrecacheUnitByNameSync("npc_orc_spawner", context)      
  PrecacheUnitByNameSync("npc_soul_harvester", context)    
  PrecacheUnitByNameSync("npc_hearstopper_ward", context)
  PrecacheUnitByNameSync("npc_vampiric_tower", context)
  PrecacheUnitByNameSync("npc_flame_turret", context)    
  PrecacheUnitByNameSync("npc_dota_creature_wandering_vhoul", context)  
  PrecacheUnitByNameSync("npc_dota_creature_gargoyle", context)      
  PrecacheUnitByNameSync("npc_dota_creature_restless_spirit", context)    
  PrecacheUnitByNameSync("npc_dota_creature_wandering_kobold", context)
  PrecacheUnitByNameSync("npc_dota_creature_restless_banshee", context)
  PrecacheUnitByNameSync("npc_dota_creature_basic_skeleton", context)    
  PrecacheUnitByNameSync("npc_dota_fire_spirit", context)
  PrecacheUnitByNameSync("npc_dota_jelly_fish", context)
  PrecacheUnitByNameSync("npc_dota_treasure_scarab", context)
  PrecacheUnitByNameSync("npc_dota_sheep", context)
  PrecacheUnitByNameSync("npc_dota_pig", context)
  PrecacheUnitByNameSync("npc_dota_treasure_frog", context)
  PrecacheUnitByNameSync("npc_dota_mimic", context)
              
end

-- Create the game mode when we activate
function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:InitGameMode()
end