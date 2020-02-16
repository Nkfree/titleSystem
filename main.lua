-- CHANGE THESE COMMANDS TO SUIT YOUR NEEDS (IT'S WHAT YOU TYPE IN CHAT AFTER THE '/')
local cmds = {}

cmds[1] = "colortitle"
cmds[2] = "disable"
cmds[3] = "titlehelp"
cmds[4] = "settitle"
cmds[5] = "title"
cmds[6] = "colorlist"
cmds[7] = "pardon"
cmds[8] = "incognito"
cmds[9] = "colornick"

local chatPrefix = "Titles" -- INFORMATIVE TAG DISPLAYED IN CHAT AFTER YOU PERFORM A CHANGE TO COLOR OR TITLE
local chatPrefixColor = color.DodgerBlue -- IF YOU NEED TO CHANGE THESE, LOOK IN 'server/scripts/color.lua' or USE /listColors IN-GAME FOR POSSIBLE COLORS
local chatInfoNameColor = color.SkyBlue
local chatInfoCommandColor = color.Yellow
local chatWarningColor = color.Orange

local maxTitleLength = 12 -- maximum allowed characters per title ('space' counts as character)
local incognitoEnabled = true -- change this to false if you don't wish staff members to use this cmd
local nickColorEnabled = true -- change this to false if you don't wish players to use this cmd
local barelyVisibleColors = {"black", "navy", "midnightblue", "darkblue"}




-- DO NOT CHANGE UNLESS YOU KNOW WHAT YOU ARE DOING

local titleData = {color = "GoldenRod", enabled = true, incognito = "off", nickColor = "White", title = "[default title]"}

local cmdDesc = {}

cmdDesc[1] = "\n - sets color of title to color of choice" ..
"\n - displays a list of colors to choose from"
cmdDesc[2] = "\n - disables title for certain player"
cmdDesc[3] = "\n - displays available title system commands"
cmdDesc[4] = "\n - sets new title if it meets requirements"
cmdDesc[5] = "\n - toggles title visibility in chat"
cmdDesc[6] = "\n - displays list of all available colors"
cmdDesc[7] = "\n - pardons a player whose title was disabled"
cmdDesc[8] = "\n - hides staff title in chat from regular players"
cmdDesc[9] = "\n - sets color of chat nick to color of choice" ..
"\n - displays a list of colors to choose from"

local menuCmd = {}

menuCmd[1] = chatInfoCommandColor .. "/" .. cmds[1] .. " <color> or /" .. cmds[1]
menuCmd[2] = chatInfoCommandColor .. "/" .. cmds[2] .. " <pid/name>"
menuCmd[3] = chatInfoCommandColor .. "/" .. cmds[3]
menuCmd[4] = chatInfoCommandColor .. "/" .. cmds[4] .. " <title>"
menuCmd[5] = chatInfoCommandColor .. "/" .. cmds[5]
menuCmd[6] = chatInfoCommandColor .. "/" .. cmds[6]
menuCmd[7] = chatInfoCommandColor .. "/" .. cmds[7] .. " <pid/name>"
menuCmd[8] = chatInfoCommandColor .. "/" .. cmds[8]
menuCmd[9] = chatInfoCommandColor .. "/" .. cmds[9] .. " <color> or /" .. cmds[9]


local guiId = {}

guiId.pickColorNick = 32965
guiId.pickColorTitle = 32966

local lang = {}

lang["Title"] = "title"
lang["Color"] = "color"
lang["NickColor"] = "nick color"
lang["changeSuccessSelf"] = "You have changed %s" .. color.Default .. " to %s" .. color.Default .. ".\n"
lang["disableSuccesful"] = "You have disabled title for " .. chatInfoNameColor .. "%s" .. color.Default .. ".\n"
lang["disabledTitle"] = "Chat title is off.\n"
lang["disabledByStaff"] = chatWarningColor .. "Your title has been disabled by staff for being offensive. Ask them politely to have it enabled again.\n" .. color.Default
lang["disabledByStaffCmd"] = chatWarningColor .. "This command was disabled by staff.\n" .. color.Default
lang["enabledTitle"] = "Chat title is on.\n"
lang["maxCharsExceeded"] = chatWarningColor .. "Your title exceeded maximum allowed number of characters of %d" .. color.Default .. ".\n"
lang["gotNewTitleAndColor"] = "You have been asigned a %s and it's %s. Use %s" .. color.Default .. " to change it, %s" .. color.Default .. " to change it's color or %s" .. color.Default .. " to see all related commands.\n"
lang["unsufficientRank"] = chatWarningColor .. "You need to be at least moderator to use that command.\n" .. color.Default
lang["wrongUseCmd"] = "Invalid command. Use %s" .. color.Default .. "\n"
lang["unableToDisableStaffMemeber"] = chatWarningColor .. "You can't disable title for the staff member.\n" .. color.Default
lang["restrictOffensiveTitle"] = chatWarningColor .. "Such title is considered offensive, don't be shy to use more polite one.\n" .. color.Default
lang["enabledTitleForPlayer"] = "You have enabled title for " .. chatInfoNameColor .. "%s" .. color.Default .. ".\n"
lang["enabledTitleByStaff"] = "Your title has been enabled again by a staff member.\n"
lang["notInDisabled"] = chatWarningColor .. "Can't enable title for %s" .. color.Default .. ". They already have it enabled.\n"
lang["restrictedToStaff"] = chatWarningColor .. "Sorry, this title is restricted to staff members only.\n" .. color.Default
lang["invalidColor"] = "Invalid color. Use %s" .. color.Default .. " to display available colors.\n"
lang["noSuchPlayerOnline"] = chatWarningColor .. "There's no player online matching that pid.\n" .. color.Default
lang["incognitoOff"] = "You have disabled incognito mode.\n"
lang["incognitoOn"] = "You have enabled incognito mode.\n"
lang["invalidColor"] = chatWarningColor .. "Not a valid color! " .. color.Default .. "Check %s " .. color.Default .. "for all available colors.\n"

local function doMessage(pid, message, ...)

	local args = {...}
	local prefix = chatPrefixColor .. "[" .. chatPrefix .. "] " .. color.Default
	local newMessage = prefix .. lang[message]
	
	if #args > 0 then
		newMessage = string.format(newMessage, unpack(args))
	end

	tes3mp.SendMessage(pid, newMessage, false)

end

local disabledPlayers = {}


local function LoadJson()
	jsonInterface.load("titles_disabledPlayers.json")
end


local function SaveJson()
	jsonInterface.save("titles_disabledPlayers.json", disabledPlayers)
end


local Methods = {}

Methods.availableColorsList = {}

Methods.displayHelpCmd = function(pid, cmd)

	if Methods.validateNameOrPid(pid) then
		if Players[pid]:IsServerStaff() then
			Methods.StaffHelp(pid)
		else
			Methods.PlayerHelp(pid)
		end
	end
end


Methods.IsTitleOffensive = function(newTitle) -- at least simple function to protect offensive language in title

	for _, offensiveWord in pairs(config.disallowedNameStrings) do
		if newTitle:match(offensiveWord) then
			return true
		end
	end
	
	return false
end


Methods.IsColorBarelyVisible = function(colorToCheck)
	
	for _, col in pairs(barelyVisibleColors) do
		if string.lower(colorToCheck) == string.lower(col) then
			return true
		end
	end
	
	return false
end


Methods.gatherColors = function()

	for thisColor, _ in pairs(color) do
		if Methods.IsColorBarelyVisible(thisColor) == false then
			table.insert(Methods.availableColorsList, thisColor)
		end
	end
	
	table.sort(Methods.availableColorsList)
end


Methods.SortHelp = function(forStaff)

	local newTable = {}
	
	if forStaff == false then
	
		for i = 1, #menuCmd do
			if i ~= 2 and i ~= 7 and i ~= 8 then
				table.insert(newTable, menuCmd[i] .. cmdDesc[i])
			end
		end
	else
		for i = 1, #menuCmd do
			table.insert(newTable, menuCmd[i] .. cmdDesc[i])
		end
	end
	
	table.sort(newTable)
	
	return newTable
end
		


Methods.StaffHelp = function(pid)

	local list = ""
	local title = color.Orange .. "\nTitle Staff Help"
	local divider = "\n"
	local helpTable = Methods.SortHelp(true)

	for i = 1, #helpTable do
		if i == #helpTable then
			divider = ""
		end
		
		list = list .. helpTable[i] .. divider
	end
	
	tes3mp.ListBox(pid, -1, title, list)
end


Methods.PlayerHelp = function(pid)

	local list = ""
	local title = color.Orange .. "\nTitle Player Help"
	local divider = "\n"
	local helpTable = Methods.SortHelp(false)

	for i = 1, #helpTable do
		if i == #helpTable then
			divider = ""
		end
		
		list = list .. helpTable[i] .. divider
	end
	
	tes3mp.ListBox(pid, -1, title, list)
end


Methods.showColorListCmd = function(pid, cmd)

	if Methods.validateNameOrPid(pid) then
		local list = ""
		local title = color.DodgerBlue .. "\nList of available colors"
		
		local divider = "\n"
		
		for i = 1, #Methods.availableColorsList do
			local currentColor = Methods.availableColorsList[i]
			
			if i == #Methods.availableColorsList then
				divider = ""
			end

			list = list .. color[currentColor] .. currentColor .. divider
		end
		
		tes3mp.ListBox(pid, -1, title, list)
	end
end
			
		


Methods.validateNameOrPid = function(NoP)-- checks whether pid used is logged in / converts player name to pid if that is logged in
	local targetPid = tonumber(NoP)
	if targetPid == nil then
		for id, _ in pairs(Players) do
			if NoP == tes3mp.GetName(id) then
				targetPid = id
				return targetPid
			end
		end
	end
	if targetPid ~= nil and Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then
		return targetPid
	end
	return false
end


Methods.ToggleTitle = function(pid)

	if Players[pid].data.customVariables.titleData.enabled == true then
		Players[pid].data.customVariables.titleData.enabled = false
		doMessage(pid, "disabledTitle")
	elseif Players[pid].data.customVariables.titleData.enabled == false then
		Players[pid].data.customVariables.titleData.enabled = true
		doMessage(pid, "enabledTitle")
	end
	
	Players[pid]:QuicksaveToDrive()
end


Methods.toggleTitleForSelfCmd = function(pid, cmd)
		
	if Methods.validateNameOrPid(pid) then
		local playerName = tes3mp.GetName(pid)
		
		if not Methods.IsPlayerDisabled(playerName) then
			Methods.ToggleTitle(pid)
		else
			doMessage(pid, "disabledByStaff")
		end
	end
end


Methods.IsTitleEnabled = function(pid)

	if Players[pid].data.customVariables.titleData.enabled == false then
		return false
	end
	
	return true
end
	


Methods.disableTitleForPlayerCmd = function(pid, cmd)

	if Methods.validateNameOrPid(pid) then
		if #cmd > 1 then
		
		local target = tableHelper.concatenateFromIndex(cmd, 2, " ")
		
		local targetPid
		local targetName
		
		targetPid = Methods.validateNameOrPid(target) 
		
			if Players[pid]:IsServerStaff() then
				if targetPid then
					targetName = tes3mp.GetName(targetPid)
					
					if not Players[targetPid]:IsServerStaff() then
						Methods.DisableTitleForPlayer(targetPid)
						Methods.SaveDisableEntry(targetName)
						doMessage(pid, "disableSuccesful", targetName)
					else
						doMessage(pid, "unableToDisableStaffMemeber", targetName)
					end	
				else
					doMessage(pid, "noSuchPlayerOnline")
				end
			else
				doMessage(pid, "unsufficientRank")
			end
		else
			doMessage(pid, "wrongUseCmd", menuCmd[2])
		end
	end
end


Methods.IsTitleStaffTag = function(newTitle)

	local staffTitles = {"Owner", "Admin", "Mod", "Moderator", "GM", "GameMaster"}
	
	for _, title in pairs(staffTitles) do
		if string.upper(title) == string.upper(newTitle) then
			return true
		end
	end
	
	return false
end
	
	


Methods.IsPlayerDisabled = function(playerName)
	
	if tableHelper.containsValue(disabledPlayers, playerName) then
		return true
	end
	
	return false
end


Methods.GetDisabledPlayerIndex = function(playerName)

	for index, name in pairs(disabledPlayers) do
		if string.lower(name) == string.lower(playerName) then
			return index
		end
	end
	
	return false

end


Methods.DisableTitleForPlayer = function(targetPid)
	Players[targetPid].data.customVariables.titleData.enabled = false
	Players[targetPid]:QuicksaveToDrive()
end


Methods.SaveDisableEntry = function(targetName)
	table.insert(disabledPlayers, targetName)
	SaveJson()
end


Methods.pardonPlayerCmd = function(pid, cmd)

	if Methods.validateNameOrPid(pid) then
		if #cmd > 1 then
			
			local target = tableHelper.concatenateFromIndex(cmd, 2, " ")
		
				if Players[pid]:IsServerStaff() then
				
					local targetPid = Methods.validateNameOrPid(target)

					if targetPid then
						local targetName = tes3mp.GetName(targetPid)
						if Methods.RemoveDisabledPlayer(targetName) ~= false then
							Methods.ToggleTitle(targetPid)
							doMessage(pid, "enabledTitleForPlayer", targetName)
							doMessage(targetPid, "enabledTitleByStaff")
						else
							doMessage(pid, "notInDisabled", targetName)
						end
					else
						doMessage(pid, "noSuchPlayerOnline")
					end
				else
					doMessage(pid, "unsufficientRank")
				end
		else
			doMessage(pid, "wrongUseCmd", menuCmd[7])
		end
	end
end
			


Methods.RemoveDisabledPlayer = function(targetName)
	
	local pIndex = Methods.GetDisabledPlayerIndex(targetName)
	
	if pIndex == false then
		return false
	end
	
	table.remove(disabledPlayers, pIndex)
	SaveJson()
end


Methods.CreateEntry = function(pid)
	
	if not Players[pid].data.customVariables.titleData then
		Players[pid].data.customVariables.titleData = {}
	end
	
	for key, value in pairs(titleData) do
		if Players[pid].data.customVariables.titleData[key] == nil then
			Players[pid].data.customVariables.titleData[key] = value
		end
	end
	
	Players[pid]:QuicksaveToDrive()
end


local function OnServerPostInit(eventStatus)

	LoadJson()
	Methods.gatherColors()

end


local function OnPlayerAuthentifiedHandler(eventStatus, pid)
	
	if Methods.validateNameOrPid(pid) then
		
		local playerName = tes3mp.GetName(pid)
		
		if not Players[pid].data.customVariables then
			Players[pid].data.customVariables = {}
		end
		
		if Methods.IsPlayerDisabled(playerName) then
			if Players[pid].data.customVariables.titleData.enabled then
				Methods.DisableTitleForPlayer(pid)
			end
			doMessage(pid, "disabledByStaff")
		else
			if not Methods.HasTitle(pid) then
				tes3mp.StartTimer(tes3mp.CreateTimerEx("timer_newTitle", 1000, "i", pid))
			end
			
			Methods.CreateEntry(pid)
			
		end
	
	end

end


local function OnPlayerSendMessageValidator(eventStatus, pid, message)

	if Methods.validateNameOrPid(pid) and Methods.HasTitle(pid) then
		
			if message:sub(1, 1) ~= '/' then
				local playerNickColor = Players[pid].data.customVariables.titleData.nickColor
				local playerColor = Players[pid].data.customVariables.titleData.color
				local playerTitle = Players[pid].data.customVariables.titleData.title .. " "
				
				for id, _ in pairs(Players) do
					local message = message
					if playerNickColor then
						message = color[playerNickColor] .. logicHandler.GetChatName(pid) .. ": " .. color.Default .. message .. "\n"
					else
						message = color.Default .. logicHandler.GetChatName(pid) .. ": " .. message .. "\n"
					end
					
					if Methods.validateNameOrPid(id) then
						
				
						if Players[id]:IsServerStaff() or Players[pid].data.customVariables.titleData.incognito == "off" then
							if Players[pid]:IsServerOwner() then
								message = config.rankColors.serverOwner .. "[Owner] " .. message
							elseif Players[pid]:IsAdmin() then
								message = config.rankColors.admin .. "[Admin] " .. message
							elseif Players[pid]:IsModerator() then
								message = config.rankColors.moderator .. "[Mod] " .. message
							end
						end
					
						if Methods.IsTitleEnabled(pid) then
						
							message = color[playerColor] .. playerTitle .. message
							
						end
						
						tes3mp.SendMessage(id, message, false)
					end
				end
			
				return customEventHooks.makeEventStatus(false,false)
			end
	end
end


local function OnGUIAction(EventStatus, pid, idGui, data)
	
	if idGui == guiId.pickColorNick then
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then
			return
		else
			local newColor = Methods.availableColorsList[tonumber(data)]
			Methods.SetNickColor(pid, newColor)
			doMessage(pid, "changeSuccessSelf", lang.NickColor, color[newColor] .. string.lower(newColor))
		end
	elseif idGui == guiId.pickColorTitle then
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then
			return
		else
			local newColor = Methods.availableColorsList[tonumber(data)]
			Methods.SetTitleColor(pid, newColor)
			doMessage(pid, "changeSuccessSelf", lang.Color, color[newColor] .. string.lower(newColor))
		end
	end
end
		


Methods.HasTitle = function(pid)
	
	local customVar = Players[pid].data.customVariables
	
	if customVar and customVar.titleData and customVar.titleData.title and customVar.titleData.color then
		return true
	end

	return false

end


Methods.incognitoCmd = function(pid, cmd)

	if Methods.validateNameOrPid(pid) then
	
		if Players[pid]:IsServerStaff() then
		
			if incognitoEnabled then

				if Players[pid].data.customVariables.titleData.incognito == "off" then
					Players[pid].data.customVariables.titleData.incognito = "on"
					doMessage(pid, "incognitoOn")
				elseif Players[pid].data.customVariables.titleData.incognito == "on" then
					Players[pid].data.customVariables.titleData.incognito = "off"
					doMessage(pid, "incognitoOff")
				end
				
				Players[pid]:QuicksaveToDrive()
			else
				doMessage(pid, "disabledByStaffCmd")
			end
		else
			doMessage(pid, "unsufficientRank")
		end
	end
end




Methods.SetTitle = function(pid, title)

	Players[pid].data.customVariables.titleData.title = title
	
	Players[pid]:QuicksaveToDrive()

end


Methods.setTitleCmd = function(pid, cmd)
	
	if Methods.validateNameOrPid(pid) then
		if #cmd > 1 then
			
			local playerName = tes3mp.GetName(pid)
			
			if not Methods.IsPlayerDisabled(playerName) then
			
				if Methods.HasTitle(pid) then
	
					local title = tableHelper.concatenateFromIndex(cmd, 2, " ")
					
					if title:sub(1,1) == ' ' then
						title = title:gsub("%s", "", 1)
					end
						
					if string.len(title) <= maxTitleLength then
						
						if Methods.IsTitleOffensive(title) == false then
							
							if Methods.IsTitleStaffTag(title) == false then
					
								local titleColor = Players[pid].data.customVariables.titleData.color
								titleColor = color[titleColor]
								local msgTitle = titleColor .. title
								
								title = "[" .. title .. "]"
								Methods.SetTitle(pid, title)
								doMessage(pid, "changeSuccessSelf", "title", msgTitle)
							else
								doMessage(pid, "restrictedToStaff")
							end
						else
							doMessage(pid, "restrictOffensiveTitle")
						end
					else
						doMessage(pid, "maxCharsExceeded", maxTitleLength)
					end
				end
			else
				doMessage(pid, "disabledByStaff")
			end
		else
			doMessage(pid, "wrongUseCmd", menuCmd[4])
		end
	end
end



Methods.SetTitleColor = function(pid, newColor)

	Players[pid].data.customVariables.titleData.color = newColor
	
	Players[pid]:QuicksaveToDrive()

end


Methods.SetNickColor = function(pid, newColor)

	Players[pid].data.customVariables.titleData.nickColor = newColor
	
	Players[pid]:QuicksaveToDrive()
end


Methods.guiShowAvailableColorsList = function(pid, guiNum)

	local list = " - CANCEL -\n"
	local title = color.DodgerBlue .. "\nPick one of the colors and press 'OK'"
	local guiNumber = guiNum
	
	local divider = "\n"
	
	for i = 1, #Methods.availableColorsList do
		local currentColor = Methods.availableColorsList[i]
		
		if i == #Methods.availableColorsList then
			divider = ""
		end

		list = list .. color[currentColor] .. currentColor .. divider
	end
	
	tes3mp.ListBox(pid, guiNumber, title, list)
end

	


Methods.LookupColor = function(colorToFind)
	
	local newColor = ""
	
	for _, valueColor in pairs(Methods.availableColorsList) do
		if string.upper(valueColor) == string.upper(colorToFind) then
			newColor = valueColor
			return newColor
		end
	end

	return false

end


Methods.setTitleColorCmd = function(pid, cmd)
	
	if Methods.validateNameOrPid(pid) then	
		if #cmd > 1 then
			
				local playerName = tes3mp.GetName(pid)
				
				if not Methods.IsPlayerDisabled(playerName) then
			
					if Methods.HasTitle(pid) then

						local newColor = tableHelper.concatenateFromIndex(cmd, 2, "")
						
						if newColor:sub(1,1) == ' ' then
							newColor = newColor:gsub("%s", "", 1)
						end
							
						newColor = Methods.LookupColor(newColor)
						
						if newColor then
							Methods.SetTitleColor(pid, newColor)
							doMessage(pid, "changeSuccessSelf", lang.Color, color[newColor] .. string.lower(newColor))
						else
							doMessage(pid, "invalidColor", menuCmd[6])
						end
					end
				else
					doMessage(pid, "disabledByStaff")
				end
		else
			Methods.guiShowAvailableColorsList(pid, guiId.pickColorTitle)
		end
	end
end


Methods.setNickColorCmd = function(pid, cmd)
	
	if Methods.validateNameOrPid(pid) then
		
		if nickColorEnabled then
			if #cmd > 1 then
			
				local playerName = tes3mp.GetName(pid)
				
				if not Methods.IsPlayerDisabled(playerName) then
			
					if Methods.HasTitle(pid) then

						local newColor = tableHelper.concatenateFromIndex(cmd, 2, "")
						
						if newColor:sub(1,1) == ' ' then
							newColor = newColor:gsub("%s", "", 1)
						end
							
						newColor = Methods.LookupColor(newColor)
						
						if newColor then
							Methods.SetNickColor(pid, newColor)
							doMessage(pid, "changeSuccessSelf", lang.NickColor, color[newColor] .. string.lower(newColor))
						else
							doMessage(pid, "invalidColor", menuCmd[6])
						end
					end
				else
					doMessage(pid, "disabledByStaff")
				end
			else
				Methods.guiShowAvailableColorsList(pid, guiId.pickColorNick)
			end
		else
			doMessage(pid, "disabledByStaffCmd")
		end
	end
end



function timer_newTitle(pid)
	
	local playerTitle = Players[pid].data.customVariables.titleData.title
	local playerTitleColor = Players[pid].data.customVariables.titleData.color
	playerTitleColor = color[playerTitleColor] .. "color" .. color.Default
	local title = menuCmd[4]
	local color = menuCmd[1]
	local help = menuCmd[3]
	doMessage(pid, "gotNewTitleAndColor", playerTitle, playerTitleColor, title, color, help)
end


customEventHooks.registerHandler("OnServerPostInit", OnServerPostInit)
customEventHooks.registerHandler("OnPlayerAuthentified", OnPlayerAuthentifiedHandler)
customEventHooks.registerValidator("OnPlayerSendMessage", OnPlayerSendMessageValidator)
customEventHooks.registerHandler("OnGUIAction", OnGUIAction)
customCommandHooks.registerCommand(cmds[1], Methods.setTitleColorCmd)
customCommandHooks.registerCommand(cmds[2], Methods.disableTitleForPlayerCmd)
customCommandHooks.registerCommand(cmds[3], Methods.displayHelpCmd)
customCommandHooks.registerCommand(cmds[4], Methods.setTitleCmd)
customCommandHooks.registerCommand(cmds[5], Methods.toggleTitleForSelfCmd)
customCommandHooks.registerCommand(cmds[6], Methods.showColorListCmd)
customCommandHooks.registerCommand(cmds[7], Methods.pardonPlayerCmd)
customCommandHooks.registerCommand(cmds[8], Methods.incognitoCmd)
customCommandHooks.registerCommand(cmds[9], Methods.setNickColorCmd)
