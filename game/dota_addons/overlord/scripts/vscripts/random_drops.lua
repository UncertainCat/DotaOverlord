require('random_drops_tables')

if random_drops == nil then
  _G.random_drops = class({}) -- put spawners in the global scope
end

function random_drops:roll_starting_drops() -- Called on the pregame game state event

for n = 1, 5 do
if RandomInt(1,10) > 7 then
ent = Entities:FindByName(nil, "item_spawn"..n)
random_drops:roll(ent:GetOrigin(),RandomInt(1, 6),false)
end
end

end

function random_drops:roll_drop(monster)
drop_position = monster:GetOrigin()
mlvl = monster:GetLevel()
bool = monster:IsAncient()
random_drops:roll(drop_position,mlvl,bool)
end

function random_drops:roll(drop_position,mlvl,ancient_bool)
drop_table = lvl1_table

if drop_meta_lvltable[mlvl] ~= nil  then
drop_table =  drop_meta_lvltable[mlvl]
end

if ancient_bool then
    if mlvl == 6 then
    drop_table = strongancient_table
    else
    drop_table = weakancient_table
    end

end

weight_t = 0
for _,weight in pairs(drop_table) do
  weight_t = weight_t + weight 
end

roll = RandomInt(1,weight_t)

for item_string, weight in pairs(drop_table) do
  roll = roll - weight
    if roll <= 0 then
        if item_string ~= "nothing" then
        item = CreateItem(item_string, nil, nil)
        CreateItemOnPositionForLaunch(drop_position, item)
        end
    return
    end
end
end