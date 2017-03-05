-- In this file you can set up all the properties and settings for your game mode.
OVERLORD = 0
OVERLORD_VS = 1

if GetMapName() == "overlord" then
ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
GAMEMODE = OVERLORD
elseif GetMapName() == "overlord_vs" or GetMapName() == "overlord_vs_2v2" then
ENABLE_HERO_RESPAWN = false              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
GAMEMODE = OVERLORD_VS
end


UNIVERSAL_SHOP_MODE = false             -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = true        -- Should we let people select the same hero as each other
MOONWELL_BOUNTY = 000
SPAWNER_UNIT_CAP = 120
TOWER_ABILITYPOINT_BOUNTY = 0           --How many ability points the Overlord gets for destroying a tower
if GAMEMODE == OVERLORD then
MOONWELL_ABILITYPOINT_BOUNTY = 1        --How many ability points the Overlord gets for destroying a moonwell
else
MOONWELL_ABILITYPOINT_BOUNTY = 2  
end

GRAVITY = 8

HERO_SELECTION_TIME = 1.0              -- How long should we let people select their hero?
STRATEGY_TIME = 1
PRE_GAME_TIME = 1.0                    -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 3600.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 1                     -- How much gold should players get per tick?
GOLD_TICK_TIME = 1                      -- How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = true     -- Should we disable the recommened builds for heroes
CAMERA_DISTANCE_OVERRIDE = 1134.0       -- How far out should we allow the camera to go?  1134 is the default in Dota

MINIMAP_ICON_SIZE = 1                   -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- What icon size should we use for runes?

RUNE_SPAWN_TIME = 120                   -- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = true      -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = true  -- Should we use a custom buyback time?
BUYBACK_ENABLED = false                 -- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = false     -- Should we disable fog of war entirely for both teams?
USE_UNSEEN_FOG_OF_WAR = false           -- Should we make unseen and fogged areas of the map completely black until uncovered by each team? 
                                            -- Note: DISABLE_FOG_OF_WAR_ENTIRELY must be false for USE_UNSEEN_FOG_OF_WAR to work
USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = true    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

USE_CUSTOM_TOP_BAR_VALUES = true        -- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = false                  -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = true             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION = false-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false       -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false             -- Should we disable the gold sound when players get gold?

END_GAME_ON_KILLS = false                -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 50         -- How many kills for a team should signify an end of game?

USE_CUSTOM_HERO_LEVELS = false           -- Should we allow heroes to have custom levels?
MAX_LEVEL = 25                          -- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = false            -- Should we use custom XP values to level up heroes, or the default Dota numbers?

-- Fill this table up with the required XP per level if you want to change it
--XP_PER_LEVEL_TABLE = {}
--for i=1,MAX_LEVEL do
--  XP_PER_LEVEL_TABLE[i] = (i-1) * 100
--
XP_PER_LEVEL_TABLE = {  
0,     --1
100,   --2
250,   --3
450,   --4
700,   --5
1000,  --6
2000,  --7
3000,  --8
4000,  --9
6000,  --10
7000,  --11
8000,  --12
9000,  --13
10500, --14
12000, --15
13500, --16
15200, --17
17000, --18
19000, --19
21000, --20
23000, --21
25000, --22
27500, --23
30000, --24
33000 --25
}


ENABLE_FIRST_BLOOD = false               -- Should we enable first blood for the first kill in this game?
HIDE_KILL_BANNERS = false               -- Should we hide the kill banners that show when a player is killed?
LOSE_GOLD_ON_DEATH = true               -- Should we have players lose the normal amount of dota gold on death?
SHOW_ONLY_PLAYER_INVENTORY = false      -- Should we only allow players to see their own inventory even when selecting other units?
DISABLE_STASH_PURCHASING = false        -- Should we prevent players from being able to buy items into their stash when not at a shop?
DISABLE_ANNOUNCER = false               -- Should we disable the announcer from working in the game?
FORCE_PICKED_HERO = "npc_dota_hero_abaddon"                 -- What hero should we force all players to spawn as? (e.g. "npc_dota_hero_axe").  Use nil to allow players to pick their own hero.

FIXED_RESPAWN_TIME = -1                 -- What time should we use for a fixed respawn timer?  Use -1 to keep the default dota behavior.
FOUNTAIN_CONSTANT_MANA_REGEN = -1       -- What should we use for the constant fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_MANA_REGEN = -1     -- What should we use for the percentage fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_HEALTH_REGEN = -1   -- What should we use for the percentage fountain health regen?  Use -1 to keep the default dota behavior.
MAXIMUM_ATTACK_SPEED = 600              -- What should we use for the maximum attack speed?
MINIMUM_ATTACK_SPEED = 20               -- What should we use for the minimum attack speed?


-- NOTE: You always need at least 2 non-bounty (non-regen while broken) type runes to be able to spawn or your game will crash!
ENABLED_RUNES = {}                      -- Which runes should be enabled to spawn in our game mode?
ENABLED_RUNES[DOTA_RUNE_DOUBLEDAMAGE] = true
ENABLED_RUNES[DOTA_RUNE_HASTE] = true
ENABLED_RUNES[DOTA_RUNE_ILLUSION] = true
ENABLED_RUNES[DOTA_RUNE_INVISIBILITY] = true
ENABLED_RUNES[DOTA_RUNE_REGENERATION] = false -- Regen runes are currently not spawning as of the writing of this comment
ENABLED_RUNES[DOTA_RUNE_BOUNTY] = true


MAX_NUMBER_OF_TEAMS = 4                -- How many potential teams can be in this game mode?
USE_CUSTOM_TEAM_COLORS = true          -- Should we use custom team colors?
USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS = true          -- Should we use custom team colors to color the players/minimap?

TEAM_COLORS = {}                        -- If USE_CUSTOM_TEAM_COLORS is set, use these colors.
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = { 61, 210, 150 }  --    Teal
TEAM_COLORS[DOTA_TEAM_BADGUYS]  = { 140, 42, 244 }  --    Purple
TEAM_COLORS[DOTA_TEAM_CUSTOM_8] = { 197, 77, 168 }  --    Pink
TEAM_COLORS[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }   --    Orange
TEAM_COLORS[DOTA_TEAM_CUSTOM_3] = { 52, 85, 255 }   --    Blue
TEAM_COLORS[DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }  --    Green
TEAM_COLORS[DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }   --    Brown
TEAM_COLORS[DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }  --    Cyan
TEAM_COLORS[DOTA_TEAM_CUSTOM_7] = { 199, 228, 13 }  --    Olive
TEAM_COLORS[DOTA_TEAM_CUSTOM_1] = { 243, 201, 9 }   --    Yellow


USE_AUTOMATIC_PLAYERS_PER_TEAM = false   -- Should we set the number of players to 10 / MAX_NUMBER_OF_TEAMS?
  CUSTOM_TEAM_PLAYER_COUNT = {}           -- If we're not automatically setting the number of players per team, use this table
if GAMEMODE == OVERLORD then
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 5
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 1
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_1] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_2] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_3] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_4] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_5] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_6] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_7] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_8] = 0
elseif GetMapName() == "overlord_vs" then
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 1
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 1
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_1] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_2] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_3] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_4] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_5] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_6] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_7] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_8] = 0
elseif GetMapName() == "overlord_vs_2v2" then
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 2
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 2
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_1] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_2] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_3] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_4] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_5] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_6] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_7] = 0
  CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_8] = 0
end