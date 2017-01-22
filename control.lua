script.on_load(function(evernt)
globalVars = {}
entityCache = {}
globalVars.itemRotated = {}
globalVars.entityRemoved = {}
globalVars.spectating = {}
globalVars.warnings = {}

globalVars.ranks = {
	owner=	{id=1,name='owner',	tag='[Owner]',	playerListTag='- Owner',	colour={r=170,g=0,b=0},			online=0,count=0,warningAllowed=nil,	rights={'basic toolbar','readme','Player Info','death chest','Spectate','Modifier','editRank','setInfo','Jail','devRanks','giveOwner'}},
	dev=	{id=2,name='dev',	tag='[Dev]',	playerListTag='- Dev',		colour={r=65,g=233,b=233},		online=0,count=0,warningAllowed=nil,	rights={'basic toolbar','readme','Player Info','death chest','Spectate','Modifier','editRank','setInfo','Jail','devRanks'}},
	manager={id=3,name='manager',tag='[Manager]',playerListTag='- Manager',	colour={r=150,g=63,b=67},		online=0,count=0,warningAllowed=nil,	rights={'basic toolbar','readme','Player Info','death chest','Spectate','Modifier','editRank','Jail'}},
	admin=	{id=3,name='admin',	tag='[Admin]',	playerListTag='- Admin',	colour={r=233,g=63,b=233},		online=0,count=0,warningAllowed=nil,	rights={'basic toolbar','readme','Player Info','death chest','Spectate','Modifier','editRank','Jail'}},
	mod=	{id=4,name='mod',	tag='[Mod]',	playerListTag='- Mod',		colour={r=200,g=0,b=200},		online=0,count=0,warningAllowed=10,		rights={'basic toolbar','readme','Player Info','death chest','Spectate','Jail'}},
	reg=	{id=5,name='reg',	tag='[Reg]',	playerListTag='- Reg',		colour={r=24,g=172,b=188},		online=0,count=0,warningAllowed=5,		rights={'basic toolbar','readme','Player Info','death chest'}},
	guest=	{id=6,name='guest',	tag='',			playerListTag='',			colour={r=255,g=159,b=27},		online=0,count=0,warningAllowed=2,		rights={'Anti Grefer','basic toolbar','readme'}},
	jail=	{id=7,name='jail',	tag='[Jailed]',	playerListTag='- Jailed',	colour={r=175,g=175,b=175},		online=0,count=0,warningAllowed=nil,	rights={'Anti Grefer','readme','jailed','death chest'}}
}

lotOfBelt = 5
lotOfRemoving = 5
lotOfRemoving = 5
timeForRegular = 180
timeForMod = 600
defaultRank = globalVars.ranks['guest']
syncVar = nil
end)
--------------------------------------------------------------------------------
function ticktohour (tick)
    local hour = tostring(math.floor(tick * (1 /(60*game.speed)) / 3600))
    return hour
end

function ticktominutes (tick)
  	local minutes = math.floor((tick * (1 /(60*game.speed))) / 60)
    return minutes
end

function clearElement(elementToClear)
  if elementToClear ~= nil then
    for _, element in pairs(elementToClear.children_names) do
      elementToClear[element].destroy()
    end
  end
end

function sync(save)
	if game.surfaces[1].find_entities_filtered{name='radar', area = {{-5, -5}, {5, 5}}}[1] == nil then 
		temp = game.surfaces[1].create_entity({name = "radar", position = {0,3}, force = game.forces.neutral})
		temp.backer_name = table.tostring(globalVars)
		temp.destructible=false
		temp.minable=false
		temp.operable=false
	end
	if save then
		game.surfaces[1].find_entities_filtered{name='radar', area = {{-5, -5}, {5, 5}}}[1].backer_name = table.tostring(globalVars)
	else
		assert(loadstring('globalVars = ' .. game.surfaces[1].find_entities_filtered{name='radar', area = {{-5, -5}, {5, 5}}}[1].backer_name))()
	end
end
--------------------------------------------------------------------------------
---------------------------Rank Functions--------------------------------------
--------------------------------------------------------------------------------
function getRank(player)
	if player then
		for _,rank in pairs(globalVars.ranks) do
			if player.tag == rank.tag then return rank end
		end
	end
end

function setOwner(player)
	if player then
		for _,a in pairs(game.players) do
			if getRank(a).name == 'owner' then 
				a.tag = defaultRank.tag
				drawToolbar(a)
				drawPlayerList()
				break
			end
		end
		player.tag = globalVars.ranks.owner.tag
		drawToolbar(player)
	else
		for i,player in pairs(game.players) do
			if player.connected then 
				player.tag = globalVars.ranks.owner.tag
				drawToolbar(player)
				drawPlayerList()
				drawPlayerList()
				break
			end
		end
	end
end

function hasRight(rank, testRight) -- rank can be a player
	if rank and testRight then
		if globalVars.ranks[rank] == nil then rights = getRank(rank).rights else rights = globalVars.ranks[rank].rights end
		for _,right in pairs(rights) do
			if right == testRight then return true end
		end
		return false
	end
end

function effectRank()
	for _,player in pairs(game.players) do
		if player.connected then
			playerRank = getRank(player)
			if hasRight(player, 'jailed') then player.character.active = false else player.character.active = true end
		end
	end
end

function autoRank()
	if globalVars.ranks.owner.count == 0 then setOwner() end
	for _,player in pairs(game.players) do
		rankID = getRank(player).id
		if rankID > 3 and rankID < 7 and player.admin then player.tag = globalVars.ranks.admin.tag
		elseif rankID > 4 and rankID < 7 and ticktominutes(player.online_time) > timeForMod then player.tag = globalVars.ranks.mod.tag drawToolbar(player)
		elseif rankID > 5 and rankID < 7 and ticktominutes(player.online_time) > timeForRegular then player.tag = globalVars.ranks.reg.tag drawToolbar(player)
		elseif globalVars.warnings[player.index] and getRank(player).warningAllowed and globalVars.warnings[player.index] > getRank(player).warningAllowed then jail(player)
		end
	end
	effectRank()
	countRankMembers()
	drawPlayerList()
end

function callRank(msg, rank)
	if rank == nil then rank = 4 else rank = rank.id end -- default mod or higher
	for _, player in pairs(game.players) do 
		rankID = getRank(player).id
		if rankID <= rank then player.print(msg) end
	end
end

function countRankMembers()
	for _,rank in pairs(globalVars.ranks) do
	rank.count = 0
	rank.online = 0
	end
	for _,player in pairs(game.players) do
		rank = getRank(player)
		rank.count = rank.count +1
		if player.connected then rank.online = rank.online +1 end
	end
end

function editWarnings(player, change, byPlayer)
	if player and change then
		if byPlayer then
			byPlayerName = byPlayer.name 
			byPlayerRankId = getRank(byPlayer).id 
			byPlayerRank = getRank(byPlayer) 
		else
			byPlayerName = 'server'
			byPlayerRankId = 0
			byPlayerRank = globalVars.ranks.mod
		end
		if getRank(player).warningAllowed ~= nil then
			if getRank(player).id > byPlayerRankId and getRank(player).warningAllowed then
				globalVars.warnings[player.index] = globalVars.warnings[player.index] or 0
				globalVars.warnings[player.index] = globalVars.warnings[player.index] + change
				if change > 0 then
					callRank(player.name .. ' has been given a warning by ' .. byPlayerName, byPlayerRank)
					left = getRank(player).warningAllowed - globalVars.warnings[player.index]
					player.print('You have been given a warning by ' .. byPlayerName .. ' you have ' .. left .. ' left')
				else
					callRank(player.name .. ' has had a warning removed by ' .. byPlayerName, byPlayerRank)
					left = getRank(player).warningAllowed - globalVars.warnings[player.index]
					player.print('You have had a warning removed by ' .. byPlayerName .. ' you have ' .. left .. ' left')
				end
				autoRank()
			else
				if byPlayerName ~= 'server' then byPlayer.print('Your rank is to low to give this player a warning') end
			end
		else
			if byPlayerName ~= 'server' then byPlayer.print('This player can not be given warnings') end
		end
	else
		if byPLayer then byPlayer.print('') end
	end
end

function jail(player ,byPlayer)
	if player then
		if byPlayer then
			byPlayerName = byPlayer.name 
			byPlayerRankId = getRank(byPlayer).id 
			byPlayerRank = getRank(byPlayer) 
		else
			byPlayerName = 'server'
			byPlayerRankId = 0
			byPlayerRank = globalVars.ranks.mod
		end
		if getRank(player).id > byPlayerRankId then
			player.tag = globalVars.ranks.jail.tag
			player.print('You have been jailed you can not do anything pleace leave or contact an admin you were jailed by - ' .. byPlayerName)
			player.print('Ban appeles avablie at http://explosivegaming.nl/category/6/appeal')
			globalVars.warnings[player.index] = 0
			callRank(player.name .. ' has been jailed by ' .. byPlayerName, byPlayerRank)
			autoRank()
			drawToolbar(player)
		else
			if byPlayerName ~= 'server' then byPlayer.print('Your rank is to low to Jail this player') end
		end
	end
end	
----------------------------------------------------------------------------------------
---------------------------Other Functions----------------------------------------------
----------------------------------------------------------------------------------------
function deathChest(player)
	local pos = game.surfaces[player.surface.name].find_non_colliding_position("steel-chest", player.position, 16, 1)
	if game.surfaces[player.surface.name].can_place_entity({name = "steel-chest", position = pos, force = game.forces.neutral}) then
		local tomb = game.surfaces[player.surface.name].create_entity({name = "steel-chest", position = pos, force = game.forces.neutral})
		local tomb_inventory = tomb.get_inventory(defines.inventory.chest)
		local count = 0
		
		for _, inventory_type in ipairs
		{
			defines.inventory.player_guns,
			defines.inventory.player_tools,
			defines.inventory.player_ammo,
			defines.inventory.player_armor,
			defines.inventory.player_quickbar,
			defines.inventory.player_main,
			defines.inventory.player_trash,
			defines.inventory.player_vehicle
		}
		do 
			local inventory = player.get_inventory(inventory_type)
			if inventory ~= nil then
				for item = 1, #inventory do
					if inventory[item].valid_for_read then
						count = count + 1
						tomb_inventory[count].set_stack(inventory[item])
					end
				end
			end
		end
		tomb.operable = false
	end
end

function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end
----------------------------------------------------------------------------------------
---------------------------Player Events------------------------------------------------
----------------------------------------------------------------------------------------	
script.on_event(defines.events.on_player_created, function(event)
  sync()
  local player = game.players[event.player_index]
  player.insert{name="iron-plate", count=8}
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
  player.insert{name="burner-mining-drill", count = 1}
  player.insert{name="stone-furnace", count = 1}
  player.force.chart(player.surface, {{player.position.x - 200, player.position.y - 200}, {player.position.x + 200, player.position.y + 200}})
  player.tag = defaultRank.tag
end)

script.on_event(defines.events.on_player_died, function(event)
	local player = game.players[event.player_index]
	if hasRight(player, 'death chest') then deathChest(player) end
end)
script.on_event(defines.events.on_player_respawned, function(event)
  local player = game.players[event.player_index]
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  sync()
  local player = game.players[event.player_index]
  player.print({"", "Welcome"})
  player.print({"", "Please join our discond and forum links are in server info under read me"})
  if player.gui.left.PlayerList ~= nil then
    player.gui.left.PlayerList.destroy()
  end
  if player.gui.center.README ~= nil then
    player.gui.center.README.destroy()
  end
  drawToolbar(player)
  drawPlayerList()
  local playerStringTable = encode(game.players, "players", {"name", "admin", "online_time", "connected", "index"})
  game.write_file("players.json", playerStringTable, false)
  if not player.admin and ticktominutes(player.online_time) < 1 then
    ReadmeGui(player, "Rules")
  end
  autoRank()
end)

script.on_event(defines.events.on_player_left_game, function(event)
  local player = game.players[event.player_index]
  drawPlayerList()
  autoRank()
end)
----------------------------------------------------------------------------------------
---------------------------Gui Events---------------------------------------------------
----------------------------------------------------------------------------------------
script.on_event(defines.events.on_gui_click, function(event)
  local player = game.players[event.player_index]
  if event.element.name == "btn_readme" then
    ReadmeGui(player, "Rules", true)
  elseif event.element.name == "btn_readme_rules" then
    player.gui.center.README.destroy()
    ReadmeGui(player, "Rules")
  elseif event.element.name == "btn_readme_server_info" then
    player.gui.center.README.destroy()
    ReadmeGui(player, "Server info")
  elseif event.element.name == "btn_readme_chat" then
    player.gui.center.README.destroy()
    ReadmeGui(player, "Chat")
  elseif event.element.name == "btn_readme_admins" then
    player.gui.center.README.destroy()
    ReadmeGui(player, "Admins")
  elseif event.element.name == "btn_readme_players" then
    player.gui.center.README.destroy()
    ReadmeGui(player, "Players")
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
    modifierGui(player, false)
  elseif event.element.name == "btn_Modifier_apply" then
    modifierGui(player, true)
  elseif event.element.name == "btn_Modifier_close" then
    player.gui.center.modifier.destroy()
  elseif event.element.name == "btn_toolbar_rocket_score" then
    satelliteGuiSwitch(player)
  elseif event.element.name == "getInfoBtn" then
    PlayerInfoGui(player, 1)
  elseif event.element.name == "setInfoBtn" then
    PlayerInfoGui(player, 2)
  elseif event.element.name == "JailBtn" then
    jail(game.players[player.gui.center.PlayerInfo.flowFind.playerNameInput.text] ,player)
  elseif event.element.name == "addWarningsBtn" then
    editWarnings(game.players[player.gui.center.PlayerInfo.flowFind.playerNameInput.text], 1, player)
  elseif event.element.name == "removeWarningsBtn" then
    editWarnings(game.players[player.gui.center.PlayerInfo.flowFind.playerNameInput.text], -1, player)
  elseif event.element.name == "RankBtn" then
    PlayerInfoGui(player, 3)
  elseif event.element.name == "giveOwnerBtn" then
    PlayerInfoGui(player, 4)
  elseif event.element.name == "playerInfoBtn" then
    PlayerInfoGui(player)
  elseif event.element.name == "btn_dev_apply" then
    devRank(player, 1)
  elseif event.element.name == "btn_dev_close" then
    devRank(player)
  elseif event.element.name == "btn_dev_load" then
    devRank(player, 2)
  elseif event.element.name == "devBtn" then
    devRank(player)
  elseif event.element.name == "btn_dev_setRanks" then
    devRank(player, 3)
  end
  sync(true)
end)
----------------------------------------------------------------------------------------
---------------------------Grefer Events------------------------------------------------
----------------------------------------------------------------------------------------
script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	local player = game.players[event.player_index]
	if hasRight(player, 'Anti Grefer') then
    if event.entity.type ~= "tree" and event.entity.type ~= "simple-entity" then
      event.entity.cancel_deconstruction("player")
      player.print("You are not allowed to do this yet, play for a bit longer. Try again in about: " .. math.floor((timeForRegular - ticktominutes(player.online_time))) .. " minutes")
      callRank(player.name .. " tryed to deconstruced something")
	  editWarnings(player, 1)
    end
	end
end)

script.on_event(defines.events.on_player_rotated_entity, function(event)
	local player = game.players[event.player_index]
	if hasRight(player, 'Anti Grefer') then
		if event.entity.name == "express-transport-belt" or event.entity.name == "fast-transport-belt" or event.entity.name == "transport-belt" then
			globalVars.itemRotated[event.player_index] = globalVars.itemRotated[event.player_index] or 0
			globalVars.itemRotated[event.player_index] = globalVars.itemRotated[event.player_index] +1
			if globalVars.itemRotated[event.player_index] >= lotOfBelt then
				globalVars.itemRotated[event.player_index]=0
				callRank(player.name .. " has rotated a lot of belts")
				editWarnings(player, 1)
			end
		end
	end
end)

script.on_event(defines.events.on_built_entity, function(event)
	local player = game.players[event.player_index]
	if hasRight(player, 'Anti Grefer') then
		if event.created_entity.type == "tile-ghost" then
			event.created_entity.destroy()
			player.print("You are not allowed to do this yet, play for a bit longer. Try: " .. math.floor((timeForRegular - ticktominutes(player.online_time))) .. " minutes")
			callRank(player.name .. " tryed to place concrete/stone with robots")
			editWarnings(player, 1)
		end
	end
end)

script.on_event(defines.events.on_player_mined_item, function(event)
	local player = game.players[event.player_index]
	if not player.admin and ticktominutes(player.online_time) < 10 then
		name = event.item_stack.name
		if name ~= 'raw-wood' and name ~= 'coal' and name ~= 'copper-ore' and name ~= 'iron-ore' and name ~= 'stone' then
			globalVars.entityRemoved[event.player_index] = globalVars.entityRemoved[event.player_index] or 0
			globalVars.entityRemoved[event.player_index] = globalVars.entityRemoved[event.player_index] +1
			if globalVars.entityRemoved[event.player_index] >= lotOfRemoving then
				globalVars.entityRemoved[event.player_index]=0
				callRank(player.name .. " has removed alot of stuff and got from it a " .. name)
				editWarnings(player, 1)
			end
		end
	end
end)
----------------------------------------------------------------------------------------
---------------------------Other Events-------------------------------------------------
----------------------------------------------------------------------------------------
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
  if not globalVars.satellite_sent then
    globalVars.satellite_sent = {}
  end
  if globalVars.satellite_sent[force.name] then
    globalVars.satellite_sent[force.name] = globalVars.satellite_sent[force.name] + 1   
  else
    game.set_game_state{game_finished=true, player_won=true, can_continue=true}
    globalVars.satellite_sent[force.name] = 1
  end
  for index, player in pairs(force.players) do
    if player.gui.left.rocket_score then
      player.gui.left.rocket_score.rocket_count.caption = tostring(globalVars.satellite_sent[force.name])
    else
      local frame = player.gui.left.add{name = "rocket_score", type = "frame", direction = "horizontal", caption={"score"}}
      frame.add{name="rocket_count_label", type = "label", caption={"", {"rockets-sent"}, ":"}}
      frame.add{name="rocket_count", type = "label", caption=tostring(globalVars.satellite_sent[force.name])}
    end
  end 
end)
----------------------------------------------------------------------------------------
---------------------------IDK What There Do Functions----------------------------------
----------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------
---------------------------Tool Bar-----------------------------------------------------
----------------------------------------------------------------------------------------
function drawToolbar(player)
    local frame = player.gui.top
    clearElement(frame)
    if hasRight(player, 'basic toolbar') then frame.add{name="btn_toolbar_rocket_score", type = "button", caption="Rocket score", tooltip="Show the satellite launched counter if a satellite has launched."} end
    if hasRight(player, 'basic toolbar') then frame.add{name="btn_toolbar_playerList", type = "button", caption="Playerlist", tooltip="Adds a player list to your game."} end
    if hasRight(player, 'readme') then frame.add{name="btn_readme", type = "button", caption="Readme", tooltip="Rules, Server info, How to chat, Playerlist, Adminlist."} end
    if hasRight(player, 'Spectate') then frame.add{name="btn_Spectate", type = "button", caption="Spectate", tooltip="Spectate how the game is doing."} end
    if hasRight(player, 'Modifier') then frame.add{name="btn_Modifier", type = "button", caption="Modifiers", tooltip="Modify game speeds."} end
	if hasRight(player, 'Player Info') then frame.add{name="playerInfoBtn", type = "button", caption="Player Info", tooltip="Lookup player info"} end
	if hasRight(player, 'devRanks') then frame.add{name="devBtn", type = "button", caption="Dev", tooltip="Edit basic rank data"} end 
end

function satelliteGuiSwitch(play)
  if play.gui.left.rocket_score then
    if play.gui.left.rocket_score.style.visible == false then
      play.gui.left.rocket_score.style.visible = true
    else
      play.gui.left.rocket_score.style.visible = false
    end
  end
end

function playerListGuiSwitch(play)
  if play.gui.left.PlayerList then
    if play.gui.left.PlayerList.style.visible == false then
      play.gui.left.PlayerList.style.visible = true
    else
      play.gui.left.PlayerList.style.visible = false
    end
  end
end

function spectate(player)
  if player.character then
    globalVars.spectating[player.index] = player.character
    player.character = nil
    player.print("You are spectating")
  else
	if globalVars.spectating[player.index].valid then
		player.character = globalVars.spectating[player.index]
		globalVars.spectating[player.index] = nil
		player.print("You are not spectating")
	else
		player.character = game.surfaces[player.surface.name].create_entity{name = "player", position = {0,0}, force = 'player'}
		globalVars.spectating[player.index] = nil
		player.insert{name="pistol", count=1}
		player.insert{name="firearm-magazine", count=10}
		player.print("You were killed while spectating")
	end
  end
end
----------------------------------------------------------------------------------------
---------------------------Player List--------------------------------------------------
----------------------------------------------------------------------------------------
function drawPlayerList()
  for i, a in pairs(game.players) do
    if a.gui.left.PlayerList == nil then a.gui.left.add{name= "PlayerList", type = "frame", direction = "vertical"} end
	local pList = a.gui.left.PlayerList
    clearElement(pList)
    for i, player in pairs(game.connected_players) do
	  local playerRank = getRank(player)
	  pList.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " ", playerRank.playerListTag}}
	  pList[player.name].style.font_color = playerRank.colour
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
----------------------------------------------------------------------------------------
---------------------------Player Info Gui----------------------------------------------
----------------------------------------------------------------------------------------
function PlayerInfoGui(player, btn)
	local function drawFrame(player)
		local frame = player.gui.center.add{name= "PlayerInfo", type = "frame", direction = "vertical",caption='Player Info'}
		local flowFind = frame.add{name='flowFind', type='flow',direction = "horizontal"}
		flowFind.add{name='playerNameInput',type='textfield',text='Player Name'}
		flowFind.add{name='getInfoBtn',type='button',caption='Select Player'}
		if hasRight(player, 'setInfo') then flowFind.add{name='setInfoBtn',type='button',caption='Set Info'} end
		local infoTable = frame.add{name='infoTable',type='table',colspan=3}
		infoTable.add{name='Rank',type='label',caption='Rank'}
		infoTable.add{name='Warnings',type='label',caption='Warnings Given'}
		infoTable.add{name='Online',type='label',caption='Online Time (Hours)'}
		infoTable.add{name='RankText',type='textfield'}
		infoTable.add{name='WarningsText',type='textfield'}
		infoTable.add{name='OnlineText',type='textfield'}
		infoTable.add{name='Index',type='label',caption='Index'}
		infoTable.add{name='WarningsAllowed',type='label',caption='Warnings Allowed'}
		infoTable.add{name='AFK',type='label',caption='AFK Time (Minutes)'}
		infoTable.add{name='IndexText',type='textfield'}
		infoTable.add{name='WarningsAllowedText',type='textfield'}
		infoTable.add{name='AFKText',type='textfield'}
		if hasRight(player, 'Jail') then
			local flowJail = frame.add{name='flowJail', type='flow',direction = "horizontal"}
			flowJail.add{name='JailBtn',type='button',caption='Jail'}
			flowJail.add{name='addWarningsBtn',type='button',caption='Give Warning'}
			flowJail.add{name='removeWarningsBtn',type='button',caption='Remove Warning'}
			for i, element in pairs(flowJail.children_names) do flowJail[element].style.minimal_width = 150 end
		end
		if hasRight(player, 'editRank') then
			local flowRank = frame.add{name='flowRank', type='flow',direction = "horizontal"}
			flowRank.add{name='NewRank',type='textfield',text='New Rank'}
			flowRank.add{name='RankBtn',type='button',caption='Set New Rank'}
			if hasRight(player, 'giveOwner') then flowRank.add{name='giveOwnerBtn',type='button',caption='Give Owner'} end
			for i, element in pairs(flowRank.children_names) do if element ~= 'NewRank' then flowRank[element].style.minimal_width = 150 end end
		end
		for i, element in pairs(flowFind.children_names) do if element ~= 'playerNameInput' then flowFind[element].style.minimal_width = 150 end end
	end
	local function getInfo(player)
		getPlayer = game.players[player.gui.center.PlayerInfo.flowFind.playerNameInput.text]
		if getPlayer then
			infoTable = player.gui.center.PlayerInfo.infoTable
			infoTable.RankText.text = getRank(getPlayer).name
			infoTable.WarningsText.text = globalVars.warnings[getPlayer.index] or 'N/A'
			infoTable.OnlineText.text = ticktohour(getPlayer.online_time)
			infoTable.IndexText.text = getPlayer.index
			infoTable.WarningsAllowedText.text = getRank(getPlayer).warningAllowed or 'N/A'
			infoTable.AFKText.text = ticktominutes(getPlayer.afk_time)
		else
			player.print('Enter a valid player')
		end
	end
	local function setInfo(player)
		getPlayer = game.players[player.gui.center.PlayerInfo.flowFind.playerNameInput.text]
		if getPlayer then
			infoTable = player.gui.center.PlayerInfo.infoTable
			if globalVars.ranks[infoTable.RankText.text] then getPlayer.tag = globalVars.ranks[infoTable.RankText.text].tag else player.print('Invalid Rank') end
			if type(infoTable.WarningsText.text) == 'number' and tonumber(infoTable.WarningsText.text) < getRank(getPlayer).warningAllowed then 
				globalVars.warnings[getPlayer.index] = tonumber(infoTable.WarningsText.text) 
			elseif infoTable.WarningsText.text ~= globalVars.warnings[getPlayer.index] and infoTable.WarningsText.text ~= 'N/A' then
				player.print('Invalid Number: must be less than Warnings Allowed') 
			end
			if type(infoTable.WarningsAllowedText.text) == 'number' and tonumber(infoTable.WarningsAllowedText.text) > 0 then 
				globalVars.ranks[infoTable.RankText.text].warningAllowed = tonumber(infoTable.WarningsAllowedText.text) 
			elseif infoTable.WarningsAllowedText.text ~= getRank(getPlayer).warningAllowed and infoTable.WarningsAllowedText.text ~= 'N/A' then
				player.print('Invalid Number: must be greater than 0') 
			end
			effectRank()
			drawPlayerList()
			drawToolbar(getPlayer)
			if getPlayer.gui.center.PlayerInfo ~= nil then getPlayer.gui.center.PlayerInfo.destroy() end
		else
			player.print('Enter a valid player')
		end
	end
	local function setRank(player, owner)
		if not owner then
			getPlayer = game.players[player.gui.center.PlayerInfo.flowFind.playerNameInput.text]
			newRank = globalVars.ranks[player.gui.center.PlayerInfo.flowRank.NewRank.text]
			if newRank and getPlayer then
				if newRank.id >= getRank(player).id and getRank(player).id < getRank(getPlayer).id then 
					getPlayer.tag = newRank.tag 
					effectRank()
					drawPlayerList() 
					drawToolbar(getPlayer) 
					if getPlayer.gui.center.PlayerInfo ~= nil then getPlayer.gui.center.PlayerInfo.destroy() end
				else 
					player.print('You are not a high enough rank') 
				end
			else
				player.print('Enter a vaild rank/player')
			end
		else
			getPlayer = game.players[player.gui.center.PlayerInfo.flowFind.playerNameInput.text]
			if getPlayer then
				setOwner(getPlayer)
				if getPlayer.gui.center.PlayerInfo ~= nil then getPlayer.gui.center.PlayerInfo.destroy() end
				drawToolbar(player)
				if player.gui.center.PlayerInfo ~= nil then player.gui.center.PlayerInfo.destroy() end
			else
				player.print('Enter a vaild rank/player')
			end
		end
	end
	if btn == 1 then
		getInfo(player)
	elseif btn == 2 then
		setInfo(player)
	elseif btn == 3 then
		setRank(player)
	elseif btn == 4 then
		setRank(player, true)
    elseif player.gui.center.PlayerInfo ~= nil then
      player.gui.center.PlayerInfo.destroy()
    else
      drawFrame(player)
    end
end
----------------------------------------------------------------------------------------
---------------------------Dev Consol---------------------------------------------------
----------------------------------------------------------------------------------------
function devRank(play, button)
	local inRanks = {
		"id",
		'name',
		'tag',
		'playerListTag',
		'online',
		'count',
		'warningAllowed',
		'colour',
		'rights'
	}
	local allRights = {
		'basic toolbar',
		'readme',
		'Player Info',
		'Spectate',
		'Modifier',
		'editRank',
		'setInfo',
		'Jail',
		'devRanks',
		'giveOwner',
		'death chest',
		'Anti Grefer',
		'jailed'
	}
	local function loadTable()
		countRankMembers()
		rank = globalVars.ranks[play.gui.center.dev.flowContent.rankInput.text]
		if rank then
			frame = play.gui.center.dev
			clearElement(play.gui.center.dev.flowContent.devTable)
			frame.flowContent.devTable.add{name="Tname", type="label", caption="name"}
			frame.flowContent.devTable.add{name="Tinput", type="label", caption="input"}
			for i, item in pairs(inRanks) do
				if item ~= 'colour' and item ~= 'rights' then
					frame.flowContent.devTable.add{name=item .. '_name', type="label", caption=item}
					frame.flowContent.devTable.add{name=item .. "_input", type="textfield", caption="inputTextField", text=rank[item]}
				elseif item == 'colour' then
					frame.flowContent.devTable.add{name=item .. '_name', type="label", caption=item}
					frame.flowContent.devTable.add{name=item .. "_input", type="flow", direction = "horizontal"}
					for colour,value in pairs(rank[item]) do
						frame.flowContent.devTable.colour_input.add{name=colour, type="textfield", caption="inputTextField", text=value}
						frame.flowContent.devTable.colour_input[colour].style.maximal_width = 40
					end
				else
					frame.flowContent.devTable.add{name=item .. '_name', type="label", caption=item}
					frame.flowContent.devTable.add{name=item .. "_input", type="table", colspan=2}
					for _,item in pairs(allRights) do
						frame.flowContent.devTable.rights_input.add{name=item .. '_input', type="checkbox", caption=item, state = hasRight(rank, item)}
					end
				end
			end
		else
			play.print('Enter a valid rank')
		end
	end
	local function apply(newRights)
		if play.gui.center.dev.flowContent.devTable.Tname then
			rank = globalVars.ranks[play.gui.center.dev.flowContent.rankInput.text]
			if rank then
			if newRights == false then
				local playerRanks = {}
				for i,player in pairs(game.players) do
					playerRanks[i] = getRank(player).name
				end
				for _,item in pairs(inRanks) do
					if item ~= 'colour' and item ~= 'rights' then
						local change = play.gui.center.dev.flowContent.devTable[item .. "_input"].text
						if change ~= nil then
							if tonumber(string.match(change, '%d+')) == rank[item] or change == rank[item] then else
								if item == 'id' or item == 'online' or item == 'count' or item == 'name' then play.print(item .. ' is readonly and did not change') else
									rank[item] = tonumber(string.match(change, '%d+')) or change
										play.print(item .. " changed to : " .. change)
								end	
							end
						end	
					elseif item == 'colour' then
						local vaidColour = true
						colour_input = play.gui.center.dev.flowContent.devTable.colour_input
						change = {r=0,g=0,b=0}
						for _,colour in pairs(colour_input.children_names) do
							if type(tonumber(colour_input[colour].text)) == 'number' and tonumber(colour_input[colour].text) < 256 and tonumber(colour_input[colour].text) >= 0 then  
								change[colour] = tonumber(colour_input[colour].text)
							else 
								play.print(colour .. ' is too big/small, range is 0-256')
								play.print('Colour was invaild so did not change')
								vaidColour = false
								break
							end
						end
						if change.r == rank[item].r and change.g == rank[item].g and change.b == rank[item].b then else
							if vaidColour then
								rank[item] = change
								play.print('Colour has been changed')
							else 
								play.print('Colour was invaild so did not change')
							end
						end
					end
				end
				for i,player in pairs(game.players) do player.tag = globalVars.ranks[playerRanks[i]].tag end
				drawPlayerList()
			else
				rank.rights = {}
				for index,item in pairs(allRights) do
					right = frame.flowContent.devTable.rights_input[item .. '_input'].state
					if right then rank.rights[index] = item end		
				end
				for _,player in pairs(game.players) do
					if getRank(player).name == rank.name then drawToolbar(player) end
				end
				play.print('Rights updated')
			end
			end
		end
		loadTable()
	end
	local function drawFrame ()
		local frame = play.gui.center.add{name= "dev", type = "frame", caption="Dev Rank panel", direction = "vertical"}
        frame.add{type = "flow", name= "flowContent", direction = "vertical"}
        frame.add{type = "flow", name= "flowNavigation",direction = "horizontal"}
        frame.flowContent.add{name="devInfi", type="label", caption="Only use if you know what you are doing"}
		frame.flowContent.add{name='rankInput',type='textfield', text='Rank'}
        frame.flowContent.add{name="devTable", type="table", colspan=2}
        frame.flowNavigation.add{name="btn_dev_apply", type = "button", caption="Apply", tooltip="Apply ."}
		frame.flowNavigation.add{name="btn_dev_setRanks", type = "button", caption="Set Rights", tooltip="set the new rights"}
		frame.flowNavigation.add{name="btn_dev_load", type = "button", caption="Load", tooltip="Load data"}
        frame.flowNavigation.add{name="btn_dev_close", type = "button", caption="Close", tooltip="Close the dev panel."}
	end
	if button == 1 then
		apply(false)
	elseif button == 2 then
		loadTable()
	elseif button == 3 then
		apply(true)
	elseif play.gui.center.dev ~= nil then
		play.gui.center.dev.destroy()
    else
      drawFrame()
    end
end


----------------------------------------------------------------------------------------
---------------------------Read Me Gui--------------------------------------------------
----------------------------------------------------------------------------------------
function ReadmeGui(play, page, btn)
	local function drawREADME(play, page)
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
		ReadmeGui(play, page)
	end
	local function drawRules(play, frame)
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
			"Use common sense."}
		frame.caption = "Rules"
		for i, rule in pairs(rules) do
			frame.flowContent.add{name=i, type="label", caption={"", i ,". ", rule}}
		end
	end
	local function drawServerInfo(play, frame)
		local serverInfo = {
			"Discord voice and chat server:",
			"https://discord.gg/RPCxzgt",
			"Our forum:",
			"explosivegaming.nl"
    }
		frame.caption = "Server info"
		for i, line in pairs(serverInfo) do
			frame.flowContent.add{name=i, type="label", caption={"", line}}
		end
	end
	local function drawChat(play, frame)
		local chat = {
				"Chatting for new players can be difficult because it’s different than other games!",
				"It’s very simple, the button you need to press is the “GRAVE/TILDE key”",
				"it’s located under the “ESC key”. If you would like to change the key go to your",
				"controls tab in options. The key you need to change is “Toggle Lua console”",
				"it’s located in the second column 2nd from bottom."}
		frame.caption = "Chat"
		for i, line in pairs(chat) do
			frame.flowContent.add{name=i, type="label", caption={"", line}}
		end
	end
	local function drawAdmins(play, frame)
		local admins = {
			"This list contains all the people that are admin in this world. Do you want to become",
			"an admin dont ask for it! an admin will see what you've made and the time you put",
			"in the server."}
		frame.caption = "Admins"
		for i, line in pairs(admins) do
			frame.flowContent.add{name=i, type="label", caption={"", line}}
		end
		drawPlayerTable(play, frame.flowContent, "AdminTable", true, nil, nil)
	end
	local function drawPlayers(play, frame, players)
		local players = {
			"These are the players who have supported us in the making of this factory. Without",
			"you the player we wouldn't have been as far as we are now."}
		frame.caption = "Players"
		for i, line in pairs(players) do
			frame.flowContent.add{name=i, type="label", caption={"", line}}
		end
		drawPlayerTable(play, frame.flowContent, "PlayerTable", false, nil, nil)
	end
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
----------------------------------------------------------------------------------------
---------------------------Modifier Gui-------------------------------------------------
----------------------------------------------------------------------------------------
function modifierGui(play, button)
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
  local function apply()
    for i, modifier in pairs(forceModifiers) do 
      local number = tonumber(( play.gui.center.modifier.flowContent.modifierTable[modifier .. "_input"].text))
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
  elseif play.gui.center.modifier ~= nil then
    play.gui.center.modifier.destroy()
  else
    drawFrame()
  end
end
