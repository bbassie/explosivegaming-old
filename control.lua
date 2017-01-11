-----------------------------------------------------------------------------------
-----------------------------Varabliles--------------------------------------------
-----------------------------------------------------------------------------------
itemRotated = {}
warningAllowed = 9999
timeForRegular = 120
warnings = {}
entityCache = {}
spectating = {}
playerRanks = nil
ranks = {
  {
    id = 0,
    name = "owner"
  },
  {
    id = 1,
    name = "admin"
  },
  {
    id = 2,
    name = "mod"
  },
  {
    id = 3,
    name = "reg"
  },
  {
    id = 4,
    name = "guest"
  },
  {
    id = 5,
    name = "jail"
  }
}
currentOwner = 1
defaultRank = 'guest'
defaultMinRank = 'jail'
defaultMaxRank = 'owner'
-----------------------------------------------------------------------------------
-----------------------------Basic Functions---------------------------------------
-----------------------------------------------------------------------------------
function ticktohour (tick)
  local hour = math.floor(tick * (1 /(60*game.speed)) / 3600)
  return hour
end
-----------------------------------------------------------------------------------
function ticktominutes (tick)
  local minutes = math.floor((tick * (1 /(60*game.speed))) / 60)
  return minutes
end
-----------------------------------------------------------------------------------
function callRank(msg, minRank, maxRank)
	for _, player in pairs(game.players) do 
		if testRank(player, minRank, maxRank) then
			player.print(msg)
		end
	end
end
-----------------------------------------------------------------------------------
function clearElement(elementToClear)
  if elementToClear ~= nil then
    for i, element in pairs(elementToClear.children_names) do
      elementToClear[element].destroy()
    end
  end
end
-----------------------------------------------------------------------------------
-------------------------------Rank functions--------------------------------------
-----------------------------------------------------------------------------------
function isPlayerAbleTo(player, event)
  if player.tag ~= nil then
    local playerRank = NameToId(player.tag)
		if event == "basic" then
      if playerRank <= 4 then return true else return false end 
		elseif event == "rank" then
      if playerRank <= 1 then return true else return false end 
    elseif event == "jail" then
      if playerRank <= 2 then return true else return false end 
    elseif event == "spectate" then
      if playerRank <= 2 then return true else return false end 
    elseif event == "modifier" then
      if playerRank <= 1 then return true else return false end 
    elseif event == "deconstruct" then
      if playerRank <= 3 then return true else return false end 
    elseif event == "rotate" then
      if playerRank <= 3 then return true else return false end 
    elseif event == "blueprint" then
      if playerRank <= 3 then return true else return false end 
    end
  end
end
function setPlayerRank(player, byPlayer, rank)
  if type(byPlayer) ~= "string" then
    if isPlayerAbleTo(byPlayer, "rank") == true and rank ~= "owner" then
      player.tag = rank
      player.print("Your rank has been updated by " .. byPlayer.name .. " to: " .. rank)
    else
      byPlayer.print("Your rank is to low to set a rank for an other player")
    end
  elseif byPlayer == "system" then
    player.tag = rank
    player.print("Your rank has been updated by the auto ranking system to: " .. rank)
  end
end
function getPlayerRank(player)
  return player.tag
end
function idToName(id)
  return ranks[name].name
end
function NameToId(name)
  for i, rank in pairs(ranks) do
    if rank.name == name then return rank.id else return 0 end
  end
end
function jailController(player, byPlayer, rankToMoveTo)
  if player.tag == "jail" and rank ~= nil then
    player.print("You are now out of jail, thanks to " .. byPlayer)
    setPlayerRank(player, byPlayer, rankToMoveTo)
    player.character.active = true
  else
    player.print('You have been Jailed by ' .. byPlayer.name .. ', please leave or contact a admin at https://discord.gg/XSsBV6b')
    setPlayerRank(player, byPlayer, "jail")
    player.character.active = false
  end
end
function warning(player, byPlayer)

end
-----------------------------------------------------------------------------------
-----------------------------Advanced Functions------------------------------------
-----------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------
<<<<<<< HEAD
=======
function editRank(currentPlayer, player, rank)
	if rank ~= 'owner' then
		local playerRank = ranks[playerRanks[player.index]]-1
		for rank in pairs(ranks) do
			if playerRank == ranks[rank] then playerRank = rank break end end
		if type(playerRank) == 'number' then playerRank = 'owner' end
		if testRank(currentPlayer, playerRank) and testRank(currentPlayer, rank) then
			playerRanks[player.index] = rank
			jailControler(player, currentPlayer)
			clearElement(player.gui.left)
			drawPlayerList()
			drawToolbar(player)
		else
			currentPlayer.print('You can not give this rank to this player')
		end
	else
		if currentPlayer.index == currentOwner then
			currentPlayer.print('Owner can only be transfered. It can not be given')
		else
			currentPlayer.print('You can not give this rank')
		end
	end
end
-----------------------------------------------------------------------------------
function setUpRanks()
	for i, player in pairs(game.players) do
		if player.connected == true and player.character ~= nil then
			if i == currentOwner then
				playerRanks[player.index] = 'owner'
			elseif player.admin then
				playerRanks[player.index] = 'admin'
			elseif ticktohour(player.online_time) > 10 then
				playerRanks[player.index] = 'mod'
			elseif ticktohour(player.online_time) > 2 then
				playerRanks[player.index] = 'reg'
			elseif player.character.active == true then
				playerRanks[player.index] = 'guest'
			else
				playerRanks[player.index] = 'jail'
			end
			game.players[1].print(player.name .. ' ' .. playerRanks[player.index])
			drawToolbar(player)
		end
	end
end
-----------------------------------------------------------------------------------
function warning(player, byPlayer)
  local byPlayer = byPlayer
  if byPlayer ~= "system" then
    if type(byPlayer) == "string" then
      byPlayer = game.players[byPlayer]
    end
  else
    byPlayer = game.players[1]
  end
  
  if testRank(player, 'guest', 'reg') then
    if warnings[player.index] == nil then
      warnings[player.index] = 1
    else
      warnings[player.index] = warnings[player.index] +1
    end
    if warnings[player.index] > warningAllowed then
      warnings[player.index]=0
      playerRanks[player.index] = 'jail'
      drawPlayerList()
      drawToolbar(player)
      jailControler(player, byPlayer)
    else
      local warningsLeft = warningAllowed-warnings[player.index]
      player.print('You have been given a warning by ' .. byPlayer.name .. ', you have ' .. warningsLeft .. ' left.')
    end
  else
    byPlayer.print('Their rank is too high to give warnings to.')
  end
end
-----------------------------------------------------------------------------------
>>>>>>> refs/remotes/origin/master
-----------------------------Button Functions--------------------------------------
-----------------------------------------------------------------------------------
function drawToolbar(player)
  game.speed = 0.6
  local frame = player.gui.top
  clearElement(frame)
  if isPlayerAbleTo(player, "basic") == true then
    frame.add{name="btn_toolbar_rocket_score", type = "button", caption="Rocket score", tooltip="Show the satellite launched counter if a satellite has launched."}
    frame.add{name="btn_toolbar_playerList", type = "button", caption="Playerlist", tooltip="Adds a player list to your game."}
    frame.add{name="btn_readme", type = "button", caption="Readme", tooltip="Rules, Server info, How to chat, Playerlist, Adminlist."}
  end
  if isPlayerAbleTo(player, "spectate") == true then
	  frame.add{name="btn_Spectate", type = "button", caption="Spectate", tooltip="Spectate how the game is doing."}
  end
  if isPlayerAbleTo(player, "jail") == true then
	  frame.add{name="btn_jail", type = "button", caption="Jail"}
  end
  if isPlayerAbleTo(player, "rank") then
	  frame.add{name="btn_toolbar_rank", type = "button", caption="Rank"}
  end
  if isPlayerAbleTo(player, "modifier") then
    frame.add{name="btn_Modifier", type = "button", caption="Modifiers", tooltip="Modify game speeds."}
  end
end
-----------------------------------------------------------------------------------
function spectate (player)
  if testRank(player, 'mod') then
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
end
-----------------------------------------------------------------------------------
function satelliteGuiSwitch(play)
  if play.gui.left.rocket_score ~= nil then
    if play.gui.left.rocket_score.style.visible == true then
      play.gui.left.rocket_score.style.visible = false
	elseif play.gui.left.rocket_score.style.visible == nil then
	  play.gui.left.rocket_score.style.visible = false
    else
      play.gui.left.rocket_score.style.visible = true
    end
  end
end
-----------------------------------------------------------------------------------
function playerListGuiSwitch(play)
  if play.gui.left.PlayerList ~= nil then
    if play.gui.left.PlayerList.style.visible == true then
      play.gui.left.PlayerList.style.visible = false
    elseif play.gui.left.PlayerList.style.visible == nil then
	  play.gui.left.PlayerList.style.visible = false
	else
      play.gui.left.PlayerList.style.visible = true
    end
  end
end
-----------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------
function drawServerInfo(play, frame)
  local serverInfo = {
    "Discord voice and chat server:",
    "https://discord.gg/RPCxzgt",
    "Game speed:",
    "0.6 = 36 UPS / FPS",
    "Because of the lower UPS other things like walking and crafting are at a higher speed"
  }
  frame.caption = "Server info"
  for i, line in pairs(serverInfo) do
    frame.flowContent.add{name=i, type="label", caption={"", line}}
  end
end
-----------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------
-----------------------------GUI Functions-----------------------------------------
-----------------------------------------------------------------------------------
function RankGui(player, event)
	local function drawFrame()
		if testRank(player, 'admin') then
			frame = player.gui.left.add{name='RankGUI', type = 'frame', caption='Rank Editer', direction = "vertical"}
      frame.add{name='flowPlayerName', type='flow', direction = "horizontal"}
      frame.add{name='rank', type='label', caption='Rank to select from'}
      frame.add{name='flowRanks', type='flow', direction = "horizontal"}
      frame.add{name='flowActions', type='flow', direction = "horizontal"}
			frame.flowPlayerName.add{name='player', type='label', caption='Player'}
			frame.flowPlayerName.add{name='playerT', type='textfield', caption='Player text field', text='Enter Player Name'}
			frame.flowActions.add{name='rankApply', type='button', caption='Apply'}
			frame.flowActions.add{name='rankClose', type='button', caption='Close'}
      for i, rank in pairs(ranks) do
        frame.flowRanks.add{name=rank.name, type="radiobutton", state=false, caption=rank.name}
      end
		end
	end
	local function isValdToMove(rank, player)
		if ranks[rank] ~= nil and game.players[player] ~= nil then
			return true
		else
			return false
		end
	end
  local function checkBox(element)
    for i, checkElement in pairs(element.children_names) do
      if element[checkElement].state == true then
        if element[checkElement].name == "0" then
          return "owner"
        elseif element[checkElement].name == "1" then
          return "admin"
        elseif element[checkElement].name == "2" then
          return "mod"
        elseif element[checkElement].name == "3" then
          return "reg"
        elseif element[checkElement].name == "4" then
          return "guest"
        elseif element[checkElement].name == "5" then
          return "jail"
        end
      end
    end
  end
	local function apply()
		local rank = checkBox(player.gui.left.RankGUI.flowRanks)
		local Rplayer = player.gui.left.RankGUI.flowPlayerName.playerT.text
		if isValdToMove(rank, Rplayer) then
			local Rplayer = game.players[Rplayer]
      editRank(player, Rplayer, rank)
		else
			player.print('Entry was invalid')
		end
	end	
	if event == 1 then
		newOwner = game.players[player.gui.left.RankGUI.flowPlayerName.playerT.text]
		if newOwner ~= nil then
			makeOwner(newOwner)
		else
			player.print('Not a vaild player')
		end
	elseif event == 2 then
		apply()
	elseif event == 3 then
		if player.gui.left.RankGUI ~= nil then
			player.gui.left.RankGUI.destroy()
		elseif player.gui.left.RankGUI == nil then
			drawFrame()
		end
  end
end
-----------------------------------------------------------------------------------
function jailGui(player, event)
	local function drawFrame()
		if testRank(player, 'mod') then
			frame = player.gui.left.add{name='jailGui', type = 'frame', caption='Jail Controler', direction = "vertical"}
			Table = frame.add{name='Table', type='table', colspan=2}
			Table.add{name='player', type='label', caption='Player'}
			Table.add{name='playerT', type='textfield', caption='Player text field', text='Enter Player Name'}
			Table.add{name='jailApply', type='button', caption='Jail'}
			Table.add{name='jailWarning', type='button', caption='Give Warning'}
			Table.add{name='jailClose', type='button', caption='Close'}
		end
	end
	local function apply(jail)
		local Rplayer = player.gui.left.jailGui.Table.playerT.text
		if jail then
			if game.players[Rplayer] ~= nil then
				local Rplayer = game.players[Rplayer]
				if testRank(Rplayer, 'guest', 'reg') then
					editRank(player, Rplayer, 'jail')
				else
					editRank(player, Rplayer, defaultRank)
				end
			else
				player.print('Entry was invalid')
			end
		else
			if game.players[Rplayer] ~= nil then
				Rplayer = game.players[Rplayer]
				warning(Rplayer, player)
			else
				player.print('Entry was invalid')
			end
		end
	end
	if event == 1 then
		apply(true)
	elseif event == 2 then
		apply()
	elseif event == 3 then
		if player.gui.left.jailGui ~= nil then
			player.gui.left.jailGui.destroy()
		elseif player.gui.left.jailGui == nil then
			drawFrame()
		end
    end
end
-----------------------------------------------------------------------------------
function drawPlayerList()
  for i, a in pairs(game.players) do
    if a.gui.left.PlayerList ~= nil then
      a.gui.left.PlayerList.destroy()
	  a.gui.left.add{name= "PlayerList", type = "frame", direction = "vertical"}
    else
      a.gui.left.add{name= "PlayerList", type = "frame", direction = "vertical"}
    end
    for i, player in pairs(game.players) do
      if a.gui.left.PlayerList[player.name] == nil and player.connected == true then
        if player.tag == "owner" then
          a.gui.left.PlayerList.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - OWNER"}}
          a.gui.left.PlayerList[player.name].style.font_color = {r=170,g=0,b=0}
        elseif player.tag == "admin" then
          a.gui.left.PlayerList.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - ADMIN"}}
          a.gui.left.PlayerList[player.name].style.font_color = {r=233,g=63,b=233}
        elseif player.tag == "mod" then
          a.gui.left.PlayerList.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - MOD"}}
          a.gui.left.PlayerList[player.name].style.font_color = {r=0,g=170,b=0}
        elseif player.tag == "reg" then
              a.gui.left.PlayerList.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - REG"}}
              a.gui.left.PlayerList[player.name].style.font_color = {r=40,g=160,b=170}
        elseif player.tag == "guest" then
              a.gui.left.PlayerList.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name}}
              a.gui.left.PlayerList[player.name].style.font_color = {r=255,g=153,b=51}
        elseif player.tag == "jail" then
              a.gui.left.PlayerList.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - JAIL"}}
              a.gui.left.PlayerList[player.name].style.font_color = {r=175,g=175,b=175}
        end
      elseif a.gui.left.PlayerList[player.name] ~= nil and player.connected ~= true then
        a.gui.left.PlayerList[player.name].destroy()
      end
    end
  end
end
-----------------------------------------------------------------------------------
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
        if player.connected == true then
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
-----------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------
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
        if number > (-1) and number < 50 and number ~= play.force[modifier] then
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
  if button == true then
    apply()
  else
    if play.gui.center.modifier ~= nil then
      play.gui.center.modifier.destroy()
    else
      if isPlayerAbleTo(play, "modifier") == true then
        drawFrame()
      end
    end
  end
end
-----------------------------------------------------------------------------------
----------------------------GUI Event----------------------------------------------
-----------------------------------------------------------------------------------
script.on_event(defines.events.on_gui_click, function(event)
  local player = game.players[event.player_index]
  local button = event.element.name
  if button == "btn_readme" then
    README_Controller(player, "Rules", true)
  elseif button == "btn_readme_rules" then
    player.gui.center.README.destroy()
    README_Controller(player, "Rules")
  elseif button == "btn_readme_server_info" then
    player.gui.center.README.destroy()
    README_Controller(player, "Server info")
  elseif button == "btn_readme_chat" then
    player.gui.center.README.destroy()
    README_Controller(player, "Chat")
  elseif button == "btn_readme_admins" then
    player.gui.center.README.destroy()
    README_Controller(player, "Admins")
  elseif button == "btn_readme_players" then
    player.gui.center.README.destroy()
    README_Controller(player, "Players")
  elseif button == "btn_readme_close" then
    player.gui.center.README.destroy()
  elseif button == "btn_toolbar_playerList" then
    playerListGuiSwitch(player)
  elseif button == "btn_toolbar_getPlayerInventory" then
    drawGetPlayerInventory(player, nil)
  elseif button == "btn_getPlayerInventory_close" then
    player.gui.center.getPlayerInventory.destroy()
  elseif button == "btn_Spectate" then
    spectate(player)
  elseif button == "btn_Modifier" then
    modifierController(player, false)
  elseif button == "btn_Modifier_apply" then
    modifierController(player, true)
  elseif button == "btn_Modifier_close" then
    player.gui.center.modifier.destroy()
  elseif button == "btn_toolbar_rocket_score" then
    satelliteGuiSwitch(player)
  elseif button == 'rankNewOwner' then
	  RankGui(player, 1)
  elseif button == 'rankApply' then
	  RankGui(player, 2)
  elseif button == 'rankClose' then
	  RankGui(player, 3)
  elseif button == 'btn_toolbar_rank' then
	  RankGui(player, 3)
  elseif button == 'jailApply' then
	  jailGui(player, 1)
  elseif button == 'jailWarning' then
	  jailGui(player, 2)
  elseif button == 'jailClose' then
	  jailGui(player, 3)
  elseif button == 'btn_jail' then
	  jailGui(player, 3)
  end
end)
script.on_event(defines.events.on_gui_checked_state_changed, function(event)
  local player = game.players[event.player_index]
  local Rplayer = player.gui.left.RankGUI.flowPlayerName.playerT.text
  local check = event.element.name
  if check == "owner" then
    clearCheck(player.gui.left.RankGUI.flowRanks, "owner")
  elseif check == "admin" then
    clearCheck(player.gui.left.RankGUI.flowRanks, "admin")
  elseif check == "mod" then
    clearCheck(player.gui.left.RankGUI.flowRanks, "mod")
  elseif check == "reg" then
    clearCheck(player.gui.left.RankGUI.flowRanks, "reg")
  elseif check == "guest" then
    clearCheck(player.gui.left.RankGUI.flowRanks, "guest")
  elseif check == "jail" then
    clearCheck(player.gui.left.RankGUI.flowRanks, "jail")
  end
end)

function clearCheck(element, notToClear)
  for i, checkElement in pairs(element.children_names) do
    if element[checkElement].name ~= notToClear then
      element[checkElement].state = false
    end
  end
end
-----------------------------------------------------------------------------------
-----------------------------On Player Events--------------------------------------
-----------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------
script.on_event(defines.events.on_player_respawned, function(event)
  local player = game.players[event.player_index]
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
  setUpRanks()
end)
-----------------------------------------------------------------------------------
script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.players[event.player_index]
  player.print("Welcome to TNT - Explosive gaming")
  local playerStringTable = encode(game.players, "players", {"name", "admin", "online_time", "connected", "index"})
  game.write_file("players.json", playerStringTable, false)
  if player.tag == nil and player.index ~= 1 then
    setPlayerRank(player, "system", "guest")
  elseif player.index == 1 then
    setPlayerRank(player, "system", "owner")
  elseif player.admin == true then
    setPlayerRank(player, "system", "admin")
  end
  if player.tag == "guest" then
    drawREADME(player, "Rules", true)
  end
  drawPlayerList()
  drawToolbar()
end)
-----------------------------------------------------------------------------------
script.on_event(defines.events.on_player_left_game, function(event)
  local player = game.players[event.player_index]
  drawPlayerList(player)
  drawToolbar()
end)
-----------------------------------------------------------------------------------
-----------------------------Other Events------------------------------------------
-----------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------
script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	local player = game.players[event.player_index]
	if isPlayerAbleTo(player, "deconstruct") then
		if event.entity.type ~= "tree" and event.entity.type ~= "simple-entity" then
			event.entity.cancel_deconstruction("player")
			player.print("You are not allowed to do this yet, play for a bit longer. Try again in about: " .. math.floor((timeForRegular - ticktominutes(player.online_time))) .. " minutes")
			callRank(player.name .. " tryed to deconstruced something", 2)
			warning(player, 'system')
		end
	end
end)
-----------------------------------------------------------------------------------
script.on_event(defines.events.on_player_rotated_entity, function(event)
  local player = game.players[event.player_index]
  local lotOfBelt = 5
  local entity = event.entity.name
	if isPlayerAbleTo(player, "rotate") == false then
		if entity == "express-transport-belt" or entity == "fast-transport-belt" or entity == "transport-belt" then
			if itemRotated[event.player_index] == nil then
				itemRotated[event.player_index] = 1
			else
				itemRotated[event.player_index] = itemRotated[event.player_index] +1
			end
			if itemRotated[event.player_index] >= lotOfBelt then
				itemRotated[event.player_index]=0
				callRank(player.name .. " has rotated a lot of belts", 2)
				warning(player, 'system')
			end
		end
	end
end)
-----------------------------------------------------------------------------------
script.on_event(defines.events.on_built_entity, function(event)
	local player = game.players[event.player_index]
	if isPlayerAbleTo(player, "blueprint") == false then
		if event.created_entity.type == "tile-ghost" then
			event.created_entity.destroy()
			player.print("You are not allowed to do this yet, play for a bit longer. Try: " .. math.floor((timeForRegular - ticktominutes(player.online_time))) .. " minutes")
			callRank(player.name .. " tryed to place concrete/stone with robots", 2)
			warning(player, 'system')
		end
	end
end)
-----------------------------------------------------------------------------------