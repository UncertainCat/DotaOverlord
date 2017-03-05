if GameAlerts == nil then
  GameAlerts = class({})
end

function GameAlerts:Moonwell_Destroyed()
  Notifications:TopToAll({text="#moonwell_destroyed", duration=5.0}) 
 id = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS, 1)
   if id ~= 1 then
    player = PlayerResource:GetPlayer(1)
    EmitSoundOnClient("General.CoinsBig", player)
    EmitAnnouncerSound("")
   end
end

function GameAlerts:ReinforcementsInbound()

    Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#radiant_reinforcements_coming", duration=7, class="NotificationMessage"})
    Notifications:TopToTeam(DOTA_TEAM_BADGUYS, {text="#dire_reinforcements_coming", duration=7, class="NotificationMessage"})
    
end

function GameAlerts:UnitCap()

end

function GameAlerts:EndNear()

  Notifications:TopToAll({text="#ten_minutes_remaining", duration=5.0}) 

  Timers:CreateTimer({
    endTime = 300, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
    Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#five_minutes_survive", duration=5, class="NotificationMessage"})
    Notifications:TopToTeam(DOTA_TEAM_BADGUYS, {text="Five minutes remaining", duration=10, class="NotificationMessage"})
    end
  })
  Timers:CreateTimer({
    endTime = 480, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
  Notifications:TopToAll({text="#two_minutes_remaining", duration=5.0}) 
    end
  })
  
    Timers:CreateTimer({
    endTime = 540, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
  Notifications:TopToAll({text="#dawn_approaching", duration=3.0}) 
    end
  })
  local i = 5
  Timers:CreateTimer(595, function()
  Notifications:TopToAll({text=i, duration=1.0}) 
  EmitAnnouncerSound("announcer_ann_custom_countdown_0"..i)  
    i = i - 1
    if i > 0 then
    return 1
    end   
  end)

end

function GameAlerts:DireSpawnComplete(gold_spent,count,overlord)
  if overlord:GetOwner() ~= nil then
  OverlordPlayerID = overlord:GetPlayerID()

  if overlord.gold_spent ~= 0 then
  Notifications:BottomToTeam(overlord:GetTeam(), {text="-"..gold_spent.." ", duration=2.5,style={color="#660000", ["font-size"]="50px",["horizontal-align"] = right, ["font-family"] = Verdana}, class="NotificationMessage"})
  Notifications:BottomToTeam(overlord:GetTeam(), {text="#gold_spent_notification_string", duration=2.5,style={color="#660000", ["font-size"]="50px",["horizontal-align"] = right, ["font-family"] = Verdana}, class="NotificationMessage", continue=true})  
  Notifications:BottomToTeam(overlord:GetTeam(), {ability="invoker_forge_spirit", duration=5.0, style={["margin-left"] = "20px"; width = "50px", height = "50px", border= "3px solid black", ["border-radius"] = "10px" }, continue=true})  
    if OverlordPlayerID ~= -1 then
  OverlordPlayer = PlayerResource:GetPlayer(OverlordPlayerID)
  EmitSoundOnClient("General.Buy", OverlordPlayer)
  end
  
  end
  
  if overlord.NotEnoughGold then
    Notifications:TopToTeam(overlord:GetTeam(), {text="#insufficient_funds", duration=5,style={color="red", ["font-size"]="20px"}, class="NotificationMessage"})
    overlord.NotEnoughGold = false
  end
  end
end

function GameAlerts:NotEnoughGoldForSpawner(overlord)
overlord.NotEnoughGold = true
end

function GameAlerts:PlayerSpawned(hero)
  local id = hero:GetPlayerID()
  if GAMEMODE == OVERLORD then 
  if hero:GetTeam() == DOTA_TEAM_GOODGUYS then
   HeroStartMessage(id)
  end   
  if hero:GetTeam() == DOTA_TEAM_BADGUYS then
    OverlordStartMessage(id)
  end 
  elseif GAMEMODE == OVERLORD_VS then
  
      OverlordVSStartMessage(id)
  end
  
end

function HeroStartMessage(id)
              Timers:CreateTimer({
    endTime = 5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
    Notifications:Top(id, {text="#radiant_gamerules_explanation", duration=20,style={color="white", ["font-size"]="60px"}, ["font-size"]="300px", class="NotificationMessage"})
 
    end})
end

function OverlordStartMessage(id)
          Timers:CreateTimer({
    endTime = 5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
    Notifications:Top(id, {text="#overlord_gamerules_explanation", duration=5,style={color="white", ["font-size"]="60px"}, class="NotificationMessage"})  
    end})
    
          Timers:CreateTimer({
    endTime = 10, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
    Notifications:Top(id, {text="#overlord_gold_tip", duration=10,style={color="white", ["font-size"]="60px"}, class="NotificationMessage"})  
    end})
           Timers:CreateTimer({
    endTime = 20, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
    Notifications:Top(id, {text="#overlord_spawner_tip", duration=10,style={color="white", ["font-size"]="60px"}, class="NotificationMessage"})  
    end})
           Timers:CreateTimer({
    endTime = 30, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
    Notifications:Top(id, {text="#good_luck_have_fun", duration=10,style={color="white", ["font-size"]="60px"}, class="NotificationMessage"})  
    end})   
end

function OverlordVSStartMessage(id)
          Timers:CreateTimer({
    endTime = 5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
    Notifications:Top(id, {text="#vs_objective_explanation", duration=5,style={color="white", ["font-size"]="60px"}, class="NotificationMessage"})  
    end})
    
          Timers:CreateTimer({
    endTime = 10, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
    Notifications:Top(id, {text="#overlord_gold_tip", duration=10,style={color="white", ["font-size"]="60px"}, class="NotificationMessage"})  
    end})
           Timers:CreateTimer({
    endTime = 20, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
    Notifications:Top(id, {text="#overlord_spawner_tip", duration=10,style={color="white", ["font-size"]="60px"}, class="NotificationMessage"})  
    end})
           Timers:CreateTimer({
    endTime = 30, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
    Notifications:Top(id, {text="#good_luck_have_fun", duration=10,style={color="white", ["font-size"]="60px"}, class="NotificationMessage"})  
    end})   
end

function GameAlerts:GameStartRadiant() 

           Timers:CreateTimer({
    endTime = PRE_GAME_TIME - 10, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
    Notifications:TopToTeam(DOTA_TEAM_GOODGUYS,{text="#game_start_radiant", duration=5,style={color="white", ["font-size"]="100px"}, class="NotificationMessage"})     
    end})  


end

function GameAlerts:GameStartOverlord(TEAM)

           Timers:CreateTimer({
    endTime = PRE_GAME_TIME - 10, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
    Notifications:TopToTeam(TEAM,{text="#game_start_dire", duration=5,style={color="white", ["font-size"]="100px"}, class="NotificationMessage"})      
    end}) 
    

        
end

function GameAlerts:GameStart()

           Timers:CreateTimer({
    endTime = PRE_GAME_TIME + 8*60, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
    Notifications:TopToAll({text="#second_day_dawn", duration=5,style={color="white", ["font-size"]="100px"}, class="NotificationMessage"})  
    end})  
           Timers:CreateTimer({
    endTime = PRE_GAME_TIME + 16*60, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
    Notifications:TopToAll({text="#final_day_dawn", duration=5,style={color="white", ["font-size"]="100px"}, class="NotificationMessage"})  
    end})  
end