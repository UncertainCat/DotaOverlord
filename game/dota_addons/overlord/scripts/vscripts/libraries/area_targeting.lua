--Example use

--[[
local area = AreaTargeting:MakeRectangle(800,250,caster:GetForwardVector(),caster:GetOrigin()) --(length,width,direction,start)
local args_table = {teamNumber = caster:GetTeam() , cacheUnit = nil, teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY, typeFilter = DOTA_UNIT_TARGET_BASIC, flagFilter = 0, order = FIND_ANY_ORDER, canGrowCache = false}
local target_table = AreaTargeting:FindUnitsInShape(area, args_table)
]]


if AreaTargeting == nil then
  AreaTargeting = class({})
end

function AreaTargeting:FindUnitsInShape(shape, args)
local sum = Vector(0,0,0)
  for i,point in pairs(shape) do
  shape[i] = point
  sum = sum + point
  end
local center = sum/#shape

local max_length = 0
  for _,point in pairs(shape) do
    if (center - point):Length() > max_length then
    max_length = (center - point):Length()
    end
  end

local target_table = {}
local possible_targets = FindUnitsInRadius(args["teamNumber"],center,args["cacheUnit"],max_length,args["teamFilter"],args["typeFilter"],args["flagFilter"],args["order"],args["canGrowCache"])
  
  for _,target in pairs(possible_targets) do
    if 1 == pnpoly( shape, target:GetOrigin()) then
    table.insert(target_table,target)
    end
  end
  return target_table
end

function pnpoly( shape, point ) 
  local vertx = {}
  local verty = {}
  for i=1,#shape do
  table.insert(vertx,shape[i].x)
  table.insert(verty,shape[i].y)
  end 
  local testx = point.x
  local testy = point.y  
  local nvert = #shape
  local c = -1
  local j = nvert
  for i = 1, nvert do
    if ( ((verty[i] > testy) ~= (verty[j] > testy)) and (testx < (vertx[j] - vertx[i]) * (testy - verty[i]) / (verty[j] - verty[i]) + vertx[i] ) ) then 
      c = c * -1
    end
    j = i;
  end
  return c;
end

function AreaTargeting:MakeRectangle(length,width,direction,start)
direction = Vector(direction.x,direction.y,0):Normalized()
local perp = direction:Cross(Vector(0,0,1))
return {start + perp * width / 2, start - perp * width / 2, start - perp * width / 2 + direction * length, start + perp * width / 2  + direction * length}

end