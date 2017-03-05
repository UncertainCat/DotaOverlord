require('abilities/overlord_interface_tables')

if overlord_interface == nil then
  _G.overlord_interface = class({}) -- put spawners in the global scope
end

if current_state ~= nil then

for _,overlord in pairs(CustomGameRules.overlord_table) do
if overlord:GetOwner() ~= nil then
overlord_interface:set_default_state(overlord)
end
end
end

if current_state == nil then
current_state = DEFAULT_STATE
end

function overlord_interface:set_default_state(overlord)
keys = {}
keys.state = DEFAULT_STATE
keys.caster = overlord
set_state(keys)
end

function overlord_interface:set_up(overlord)
create_ability_tables(overlord)
overlord.current_state = DEFAULT_STATE
for _,info in pairs(overlord.default_state_table) do
local name = info[1]
local lvl = info[2]
ability = overlord:FindAbilityByName(name)
if ability ~= nil then
ability:SetLevel(lvl)
end
end
overlord_interface:set_default_state(overlord)
end


function set_state(keys)

local overlord = keys.caster

local new_state_table = overlord.state_metatable[keys.state]
local disabled_bool = false

clear_abilities(overlord) 

for i=1,6 do
  local ability_info = new_state_table[i]
  activate_ability(ability_info,disabled_bool,overlord)
  if keys.state ~= DEFAULT_STATE and ability_info[2] == 0 then
    disabled_bool = true
  end
end
overlord.current_state = keys.state

end
  
function clear_abilities(overlord)
local ability_table = {} --I'll fill this table up with the abilities I'll be clearing

local state_table = overlord.state_metatable[overlord.current_state]    --I'm storing everything so I can recall it at the correct level
  for i=0,15 do  
    local ability = overlord:GetAbilityByIndex(i)
      if ability ~= nil then
        if ability:IsNull() == false then       
        ability_table[i] = ability
          if ability:GetName() ~= "locked_ability" then
            if state_table[i+1] ~= nil then           
              state_table[i+1] = {ability:GetName(), ability:GetLevel()  } 
            end    
          end          
        end
      end
  end
overlord.state_metatable[overlord.current_state] = state_table 

  for _,ability in pairs(ability_table) do 
      if ability:IsNull() == false then  
        overlord:RemoveAbility(ability:GetName())       
      end

  end
end

function activate_ability(ability_info,disabled_bool, overlord)

  local ability_name = ability_info[1]
  local ability_lvl = ability_info[2]
    if ability_name == nil then
    return
    end
  
  if ability_name == "return_ability" or ability_name == "cancel_summon_ability" then
  disabled_bool = false
  end
  
  
  if disabled_bool then
  ability_name = "locked_ability"
  ability_lvl = 0
  end
  newability = overlord:AddAbility(ability_name)
  newability:SetLevel(ability_lvl)    


end

function cancel_summon(keys)
caster = keys.caster
set_state(keys)
ability = caster:FindAbilityByName("summon_monster_ability")
  if ability:IsNull() == false then
          ability:EndCooldown()
  end
end

function overlord_interface:on_level_ability(overlord)
if overlord:IsChanneling() == false then
keys = {}
keys.state = overlord.current_state
keys.caster = overlord
set_state(keys)
else
  Timers:CreateTimer(.1, function() 
    if overlord:IsChanneling() == false then
    overlord_interface:on_level_ability(overlord)
    else
    return .1
    end
  end)
end
end