
itemRotated = {}
entityCache = {}
spectating = {}

warningAllowed = nil
timeForRegular = 180
timeForMod = nil
warnings = nil
playerRanks = nil
ranks = nil
currentOwner = nil
defaultRank = nil
defaultMinRank = nil
defaultMaxRank = nil

function ticktohour (tick)
    local hour = tostring(math.floor(tick * (1 /(60*game.speed)) / 3600))
    return hour
end

function ticktominutes (tick)
  	local minutes = math.floor((tick * (1 /(60*game.speed))) / 60)
    return minutes
end

script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  player.insert{name="iron-plate", count=8}
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
  player.insert{name="burner-mining-drill", count = 1}
  player.insert{name="stone-furnace", count = 1}
  --developer items
  if player.name == "test" then
    player.insert{name="blueprint", count = 1}
    player.insert{name="deconstruction-planner", count = 1}
  end
  player.force.chart(player.surface, {{player.position.x - 200, player.position.y - 200}, {player.position.x + 200, player.position.y + 200}})
  if (#game.players <= 1) then
    game.show_message_dialog{text = {"msg-intro"}}
  else
    player.print({"msg-intro"})
  end
end)

script.on_event(defines.events.on_player_respawned, function(event)
  local player = game.players[event.player_index]
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
end)

script.on_event(defines.events.on_rocket_launched, function(event)
  local force = event.rocket.force
  if event.rocket.get_item_count("satellite") == 0 then
    if (#game.players <= 1) then
      game.show_message_dialog{text = {"gui-rocket-silo.rocket-launched-without-satellite"}}
    else
      for index, player in pairs(force.players) do
        player.print({"gui-rocket-silo.rocket-launched-without-satellite"})
      end
    end
    return
  end
  if not global.satellite_sent then
    global.satellite_sent = {}
  end
  if global.satellite_sent[force.name] then
    global.satellite_sent[force.name] = global.satellite_sent[force.name] + 1   
  else
    game.set_game_state{game_finished=true, player_won=true, can_continue=true}
    global.satellite_sent[force.name] = 1
  end
  for index, player in pairs(force.players) do
    if player.gui.left.rocket_score then
      player.gui.left.rocket_score.rocket_count.caption = tostring(global.satellite_sent[force.name])
    else
      local frame = player.gui.left.add{name = "rocket_score", type = "frame", direction = "horizontal", caption={"score"}}
      frame.add{name="rocket_count_label", type = "label", caption={"", {"rockets-sent"}, ":"}}
      frame.add{name="rocket_count", type = "label", caption=tostring(global.satellite_sent[force.name])}
    end
  end 
end)

function encode ( table, name, items )
  local encodeString
  local encodeSubString
  local encodeSubSubString
  for i, keyTable in pairs(table) do
    encodeSubSubString = nil
    for i, keyItem in pairs(items) do
      if type(keyTable[keyItem]) == "string" then
        if encodeSubSubString ~= nil then
          encodeSubSubString = encodeSubSubString .. ",\"" .. keyItem .. "\": \"" .. keyTable[keyItem] .. "\""
        else
          encodeSubSubString = "\"" .. keyItem .. "\": \"" .. keyTable[keyItem] .. "\""
        end
      elseif type(keyTable[keyItem]) == "number" then
        if encodeSubSubString ~= nil then
          encodeSubSubString = encodeSubSubString .. ",\"" .. keyItem .. "\": " .. tostring(keyTable[keyItem])
        else
          encodeSubSubString = "\"" .. keyItem .. "\": " .. tostring(keyTable[keyItem])
        end
      elseif type(keyTable[keyItem]) == "boolean" then
        if encodeSubSubString ~= nil then
          encodeSubSubString = encodeSubSubString .. ",\"" .. keyItem .. "\": " .. tostring(keyTable[keyItem])
        else
          encodeSubSubString = "\"" .. keyItem .. "\": " .. tostring(keyTable[keyItem])
        end
      end
    end
    if encodeSubSubString ~= nil and encodeSubString ~= nil then
      encodeSubString = encodeSubString .. ", {" .. encodeSubSubString .. "}"
    else
      encodeSubString = "{" .. encodeSubSubString .. "}"
    end
  end
  encodeString = "{" .. "\"" .. name .. "\": [" .. encodeSubString .. "]}"
  return encodeString
end

function callAdmin(msg)
	for _, player in pairs(game.players) do 
		if player.admin then
			player.print(msg)
		end
	end
end
	
script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	local eplayer = game.players[event.player_index]
  local timeForRegular = 120
	if not eplayer.admin and ticktominutes(eplayer.online_time) < timeForRegular then
    if not event.entity.type == "tree" or not event.entity.type == "simple-entity" then
      event.entity.cancel_deconstruction("player")
      eplayer.print("You are not allowed to do this yet, play for a bit longer. Try again in about: " .. math.floor((timeForRegular - ticktominutes(eplayer.online_time))) .. " minutes")
      callAdmin(eplayer.name .. " tryed to deconstruced something")
    end
	end
end)

script.on_event(defines.events.on_player_rotated_entity, function(event)
	local eplayer = game.players[event.player_index]
  local lotOfBelt = 5
  local timeForRegular = 120
	if not eplayer.admin and ticktominutes(eplayer.online_time) < timeForRegular then
		if event.entity.name == "express-transport-belt" or event.entity.name == "fast-transport-belt" or event.entity.name == "transport-belt" then
			if itemRotated[event.player_index] == null then
				itemRotated[event.player_index] = 1
			else
				itemRotated[event.player_index] = itemRotated[event.player_index] +1
			end
			if itemRotated[event.player_index] >= lotOfBelt then
				itemRotated[event.player_index]=0
				callAdmin(eplayer.name .. " has rotated a lot of belts")
			end
		end
	end
end)

script.on_event(defines.events.on_built_entity, function(event)
	local eplayer = game.players[event.player_index]
  local timeForRegular = 120
	if not eplayer.admin and ticktominutes(eplayer.online_time) < timeForRegular then
		if event.created_entity.type == "tile-ghost" then
			event.created_entity.destroy()
			eplayer.print("You are not allowed to do this yet, play for a bit longer. Try: " .. math.floor((timeForRegular - ticktominutes(eplayer.online_time))) .. " minutes")
			callAdmin(eplayer.name .. " tryed to place concrete/stone with robots")
		end
	end
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.players[event.player_index]
  player.print({"", "Welcome"})
  if player.gui.left.PlayerList ~= nil then
    player.gui.left.PlayerList.destroy()
  end
  if player.gui.center.README ~= nil then
    player.gui.center.README.destroy()
  end
  if player.gui.top.PlayerList ~= nil then
    player.gui.top.PlayerList.destroy()
  end
  drawToolbar()
  drawPlayerList(player)
  local playerStringTable = encode(game.players, "players", {"name", "admin", "online_time", "connected", "index"})
  game.write_file("players.json", playerStringTable, false)
  if not player.admin and ticktominutes(player.online_time) < 1 then
    drawREADME(player, "Rules", true)
  end
end)

script.on_event(defines.events.on_player_left_game, function(event)
  local player = game.players[event.player_index]
  drawPlayerList(player)
end)

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.players[event.player_index]
  if event.element.name == "btn_readme" then
    README_Controller(player, "Rules", true)
  elseif event.element.name == "btn_readme_rules" then
    player.gui.center.README.destroy()
    README_Controller(player, "Rules")
  elseif event.element.name == "btn_readme_server_info" then
    player.gui.center.README.destroy()
    README_Controller(player, "Server info")
  elseif event.element.name == "btn_readme_chat" then
    player.gui.center.README.destroy()
    README_Controller(player, "Chat")
  elseif event.element.name == "btn_readme_admins" then
    player.gui.center.README.destroy()
    README_Controller(player, "Admins")
  elseif event.element.name == "btn_readme_players" then
    player.gui.center.README.destroy()
    README_Controller(player, "Players")
  elseif event.element.name == "btn_readme_close" then
    player.gui.center.README.destroy()
  elseif event.element.name == "btn_toolbar_playerList" then
    playerListGuiSwitch(player)
  elseif event.element.name == "btn_toolbar_getPlayerInventory" then
    drawGetPlayerInventory(player, nil)
  elseif event.element.name == "btn_getPlayerInventory_close" then
    player.gui.center.getPlayerInventory.destroy()
  elseif event.element.name == "btn_Spectate" then
    spectate(player)
  elseif event.element.name == "btn_Modifier" then
    modifierController(player, false)
  elseif event.element.name == "btn_Modifier_apply" then
    modifierController(player, true)
  elseif event.element.name == "btn_Modifier_close" then
    player.gui.center.modifier.destroy()
  elseif event.element.name == "btn_toolbar_rocket_score" then
    satelliteGuiSwitch(player)
  end
end)

function drawToolbar()
  for i, a in pairs(game.players) do
    game.speed = 0.6
    a.force.manual_mining_speed_modifier = 2
    a.force.manual_crafting_speed_modifier = 1
    a.force.character_running_speed_modifier = 2
    local frame = a.gui.top
    clearElement(frame)
    frame.add{name="btn_toolbar_rocket_score", type = "button", caption="Rocket score", tooltip="Show the satellite launched counter if a satellite has launched."}
    frame.add{name="btn_toolbar_playerList", type = "button", caption="Playerlist", tooltip="Adds a player list to your game."}
    frame.add{name="btn_readme", type = "button", caption="Readme", tooltip="Rules, Server info, How to chat, Playerlist, Adminlist."}
    if a.admin == true then
      frame.add{name="btn_Spectate", type = "button", caption="Spectate", tooltip="Spectate how the game is doing."}
      frame.add{name="btn_Modifier", type = "button", caption="Modifiers", tooltip="Modify game speeds."}
    end
  end
end

function modifierController(play, button)
  local forceModifiers = {
    "manual_mining_speed_modifier",
    "manual_crafting_speed_modifier",
    "character_running_speed_modifier",
    "worker_robots_speed_modifier",
    "worker_robots_storage_bonus",
    "character_build_distance_bonus",
    "character_item_drop_distance_bonus",
    "character_reach_distance_bonus",
    "character_resource_reach_distance_bonus",
    "character_item_pickup_distance_bonus",
    "character_loot_pickup_distance_bonus"
  }
  local function apply ()
    play.print("apply")
    for i, modifier in pairs(forceModifiers) do 
      local number = tonumber(( play.gui.center.modifier.flowContent.modifierTable[modifier .. "_input"].text):match("%d+"))
      if number ~= nil then
        if number > 1 and number < 50 and number ~= play.force[modifier] then
          play.force[modifier] = number
          play.print(modifier .. " changed to number: " .. tostring(number))
        elseif number == play.force[modifier] then
          play.print(modifier .. " Did not change")
        else
          play.print(modifier .. " needs to be a higher number or it contains an letter")
        end
      end
    end
  end
  local function drawFrame ()
    if play.admin == true or play.name == "test" then
      local frame = play.gui.center.add{name= "modifier", type = "frame", caption="Modifiers panel", direction = "vertical"}
            frame.add{type = "scroll-pane", name= "flowContent", direction = "vertical", vertical_scroll_policy="always", horizontal_scroll_policy="never"}
            frame.add{type = "flow", name= "flowNavigation",direction = "horizontal"}
            frame.flowContent.add{name="modifierInfi", type="label", caption="Only use if you know what you are doing"}
            frame.flowContent.add{name="modifierTable", type="table", colspan=3}
            frame.flowContent.modifierTable.add{name="name", type="label", caption="name"}
            frame.flowContent.modifierTable.add{name="input", type="label", caption="input"}
            frame.flowContent.modifierTable.add{name="current", type="label", caption="current"}
      for i, modifier in pairs(forceModifiers) do
            frame.flowContent.modifierTable.add{name=modifier, type="label", caption=modifier}
            frame.flowContent.modifierTable.add{name=modifier .. "_input", type="textfield", caption="inputTextField"}
            frame.flowContent.modifierTable.add{name=modifier .. "_current", type="label", caption=tostring(play.force[modifier])}
      end
            frame.flowNavigation.add{name="btn_Modifier_apply", type = "button", caption="Apply", tooltip="Apply ."}
            frame.flowNavigation.add{name="btn_Modifier_close", type = "button", caption="Close", tooltip="Close the modifier panel."}
    end
  end
  if button == true then
    apply()
  else
    if play.gui.center.modifier ~= nil then
      play.gui.center.modifier.destroy()
    else
      drawFrame()
    end
  end
end

function clearElement (elementToClear)
  if elementToClear ~= nil then
    for i, element in pairs(elementToClear.children_names) do
      elementToClear[element].destroy()
    end
  end
end

function spectate (player)
  if player.character ~= nil then
    spectating[player.index] = player.character
    player.character = nil
    player.print("You are spectating")
  else
    player.character = spectating[player.index]
    spectating[player.index] = nil
    player.print("You are not spectating")
  end
end

function satelliteGuiSwitch(play)
  if play.gui.left.rocket_score ~= nil then
    if play.gui.left.rocket_score.style.visible == true then
      play.gui.left.rocket_score.style.visible = false
    else
      play.gui.left.rocket_score.style.visible = true
    end
  end
end

function playerListGuiSwitch(play)
  if play.gui.left.PlayerList ~= nil then
    if play.gui.left.PlayerList.style.visible == true then
      play.gui.left.PlayerList.style.visible = false
    else
      play.gui.left.PlayerList.style.visible = true
    end
  end
end

function drawPlayerList (play)
  for i, a in pairs(game.players) do
    if a.gui.left.PlayerList == nil then
      a.gui.left.add{name= "PlayerList", type = "frame", direction = "vertical"}
    end
    for i, player in pairs(game.players) do
      if a.gui.left.PlayerList[player.name] == nil and player.connected == true then
        if player.admin == true then
          if player.name == "badgamernl" or player.name == "BADgamerNL" then
            a.gui.left.PlayerList.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - OWNER"}}
            a.gui.left.PlayerList[player.name].style.font_color = {r=170,g=0,b=0}
          else
            a.gui.left.PlayerList.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - ADMIN"}}
            a.gui.left.PlayerList[player.name].style.font_color = {r=233,g=63,b=233}
          end
        else
          a.gui.left.PlayerList.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name}}
          a.gui.left.PlayerList[player.name].style.font_color = {r=255,g=159,b=27}
        end
      elseif a.gui.left.PlayerList[player.name] ~= nil and player.connected ~= true then
        a.gui.left.PlayerList[player.name].destroy()
      end
    end
  end
end

function drawPlayerTable(play, guiroot, tablename, isAdminonly)
  guiroot.add{name=tablename, type="table", colspan=5}
  guiroot[tablename].style.minimal_width = 500
  guiroot[tablename].style.maximal_width = 500
  guiroot[tablename].add{name="id", type="label", caption="id"}
  guiroot[tablename].add{name="name", type="label", caption="name"}
  guiroot[tablename].add{name="status", type="label", caption="status"}
  guiroot[tablename].add{name="hours", type="label", caption="Hours"}
  guiroot[tablename].add{name="admin", type="label", caption="Admin"}
  for i, player in pairs(game.players) do
    if isAdminonly == true and player.admin == false then
      
    else
      if guiroot[tablename][player.name] == nil then
        guiroot[tablename].add{name=i .. "id", type="label", caption=i}
        guiroot[tablename].add{name=player.name, type="label", caption=player.name}
        if playerconnected == true then
          guiroot[tablename].add{name=player.name .. "Status", type="label", caption="ONLINE"}
        else
          guiroot[tablename].add{name=player.name .. "Status", type="label", caption="OFFLINE"}
        end
        guiroot[tablename].add{name=player.name .. "Hours", type="label", caption=ticktohour(player.online_time)}
        guiroot[tablename].add{name=player.name .. "Admin", type="label", caption=tostring(player.admin)}
      end
    end
  end
end

function README_Controller(play, page, btn)
  if play.gui.center.README ~= nil then
    if page == "Rules" then
      if btn == true then
        play.gui.center.README.destroy()
        return
      end
      clearElement(play.gui.center.flowcontent)
      drawRules(play, play.gui.center.README)
      return
    elseif page == "Server info" then
      clearElement(play.gui.center.flowcontent)
      drawServerInfo(play, play.gui.center.README)
      return
    elseif page == "Chat" then
      clearElement(play.gui.center.flowcontent)
      drawChat(play, play.gui.center.README)
      return                  
    elseif page == "Admins" then
      clearElement(play.gui.center.flowcontent)
      drawAdmins(play, play.gui.center.README)
      return  
    elseif page == "Players" then
      clearElement(play.gui.center.flowcontent)
      drawPlayers(play, play.gui.center.README)
      return
    else
      play.gui.center.README.destroy()
      return
    end
  else
    drawREADME(play, page)
    return
  end
end

function drawREADME(play, page)
  local frame = play.gui.center.add{name= "README", type = "frame", direction = "vertical"}
        frame.add{type = "scroll-pane", name= "flowContent", direction = "vertical", vertical_scroll_policy="always", horizontal_scroll_policy="never"}
        frame.add{type = "flow", name= "flowNavigation",direction = "horizontal"}
        frame.flowNavigation.add{name="btn_readme_rules", type = "button", caption="Rules", tooltip= "Rules."}
        frame.flowNavigation.add{name="btn_readme_server_info", type = "button", caption="Server info", tooltip= "Server information page."}
        frame.flowNavigation.add{name="btn_readme_chat", type = "button", caption="Chat", tooltip= "How to chat."}
        frame.flowNavigation.add{name="btn_readme_admins", type = "button", caption="Admins", tooltip= "All the admins and info."}
        frame.flowNavigation.add{name="btn_readme_players", type = "button", caption="Players", tooltip= "All the players that have joined this map."}
        frame.flowNavigation.add{name="btn_readme_close", type = "button", caption="Close", tooltip= "Close the readme."}
        frame.flowContent.style.maximal_height = 400
        frame.flowContent.style.minimal_height = 400
        frame.flowContent.style.maximal_width = 500
        frame.flowContent.style.minimal_width = 500
        frame.flowNavigation.style.maximal_width = 500
        frame.flowNavigation.style.minimal_width = 500
  README_Controller(play, page)
end

function drawRules(play, frame)
  local rules = {
    "Hacking/cheating, exploiting and abusing bugs is not allowed.",
    "Do not disrespect any player in the server (This includes staff).",
    "Do not spam, this includes stuff such as chat spam, item spam, chest spam etc.",
    "Do not laydown concrete with bots when you dont have permission to.",
    "Do not walk in a random direction for no reason(to save map size).",
    "Do not make train roundabouts.",
    "Do not complain about lag, low fps and low ups or other things like that.",
    "Do not ask for rank.",
    "Left Hand Drive (LHD) only.",
    "Use common sense."
  }
  frame.caption = "Rules"
  for i, rule in pairs(rules) do
    frame.flowContent.add{name=i, type="label", caption={"", i ,". ", rule}}
  end
end
function drawServerInfo(play, frame)
  local serverInfo = {
    "Discord voice and chat server:",
    "https://discord.gg/RPCxzgt",
    "Our forum:",
    "explosivegaming.nl",
    "Donate to keep our servers running!(Button is on forum)",
    "Game speed:",
    "0.6 = 36 UPS / FPS",
    "Because of the lower UPS other things like walking and crafting are at a higher speed"
  }
  frame.caption = "Server info"
  for i, line in pairs(serverInfo) do
    frame.flowContent.add{name=i, type="label", caption={"", line}}
  end
end
function drawChat(play, frame)
  local chat = {
    "Chatting for new players can be difficult because it’s different than other games!",
    "It’s very simple, the button you need to press is the “GRAVE/TILDE key”",
    "it’s located under the “ESC key”. If you would like to change the key go to your",
    "controls tab in options. The key you need to change is “Toggle Lua console”",
    "it’s located in the second column 2nd from bottom."
  }
  frame.caption = "Chat"
  for i, line in pairs(chat) do
    frame.flowContent.add{name=i, type="label", caption={"", line}}
  end
end
function drawAdmins(play, frame)
  local admins = {
    "This list contains all the people that are admin in this world. Do you want to become",
    "an admin dont ask for it! an admin will see what you've made and the time you put",
    "in the server."
  }
  frame.caption = "Admins"
  for i, line in pairs(admins) do
    frame.flowContent.add{name=i, type="label", caption={"", line}}
  end
  drawPlayerTable(play, frame.flowContent, "AdminTable", true, nil, nil)
end
function drawPlayers(play, frame, players)
  local players = {
    "These are the players who have supported us in the making of this factory. Without",
    "you the player we wouldn't have been as far as we are now."
  }
  frame.caption = "Players"
  for i, line in pairs(players) do
    frame.flowContent.add{name=i, type="label", caption={"", line}}
  end
  drawPlayerTable(play, frame.flowContent, "PlayerTable", false, nil, nil)
end