require('dire_events')
function fountain_scare(event)
local unit = event.activator
local trigger = event.caller
local flag = false

if spawners.dire_spawned_units ~= nil then

  for unitcheck,_ in pairs(spawners.dire_spawned_units)  do

    if unitcheck:IsNull() ~= true then
      if unit == unitcheck then
      flag = true

      end
    end
  end
end

if flag == true then
local point = unit:GetOrigin() + (unit:GetOrigin() - trigger:GetOrigin())/4 --it's a quarter of the distance between them in the opposite direction
unit:Stop()
MoveToPoint(unit,point)
end  
  
end