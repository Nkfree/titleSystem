-- CHANGE THESE COMMANDS TO SUIT YOUR NEEDS (IT'S WHAT YOU TYPE IN CHAT AFTER THE '/')


local cmds = {}

cmds[1] = "setcolor"
cmds[2] = "disable"
cmds[3] = "titlehelp"
cmds[4] = "settitle"
cmds[5] = "title"
cmds[6] = "listcolors"
cmds[7] = "pardon"
cmds[8] = "incognito"

local chatPrefix = "Titles" -- INFORMATIVE TAG DISPLAYED IN CHAT AFTER YOU PERFORM A CHANGE TO COLOR OR TITLE
local chatPrefixColor = color.Green -- IF YOU NEED TO CHANGE THESE, LOOK IN 'server/scripts/color.lua' or USE /listColors IN-GAME FOR POSSIBLE COLORS
local chatInfoNameColor = color.LightBlue
local chatInfoCommandColor = color.Yellow

local maxTitleLength = 12 -- maximum allowed characters per title ('space' counts as character)




-- DO NOT CHANGE UNLESS YOU KNOW WHAT YOU ARE DOING

local titleData = {color = "Grey", enabled = true, incognito = "off", title = "[default title]"}

local menuCmd = {}

menuCmd[1] = chatInfoCommandColor .. "/" .. cmds[1] .. " <color>"
menuCmd[2] = chatInfoCommandColor .. "/" .. cmds[2] .. " <pid>"
menuCmd[3] = chatInfoCommandColor .. "/" .. cmds[3]
menuCmd[4] = chatInfoCommandColor .. "/" .. cmds[4] .. " <title>"
menuCmd[5] = chatInfoCommandColor .. "/" .. cmds[5] .. " <on/off>"
menuCmd[6] = chatInfoCommandColor .. "/" .. cmds[6]
menuCmd[7] = chatInfoCommandColor .. "/" .. cmds[7] .. " <pid/name>"
menuCmd[8] = chatInfoCommandColor .. "/" .. cmds[8] .. " <on/off>"


local guiId = {}

guiId.staffHelp = 3285
guiId.playerHelp = 3284

local lang = {}

lang["Title"] = "title"
lang["Color"] = "color"
lang["changeSuccessSelf"] = "You have successfully changed %s" .. color.Default .. " to %s" .. color.Default .. ".\n"
lang["changeFailureSelf"] = "You failed to change %s" .. color.Default .. ".\n"
lang["disableSuccesful"] = "You have successfully disabled title for %s" .. color.Default .. ".\n"
lang["disabledTitle"] = "Chat title is off.\n"
lang["disabledByStaff"] = "Your title has been disabled by staff for being offensive. Ask them politely to have it enabled again.\n"
lang["enabledTitle"] = "Chat title is on.\n"
lang["maxCharsExceeded"] = "Your title exceeded maximum allowed number of characters of %d" .. color.Default .. ".\n"
lang["gotNewTitleAndColor"] = "You have been asigned a %s and it's %s. Use %s" .. color.Default .. " to change it, %s" .. color.Default .. " to change it's color or %s" .. color.Default .. " to see all available title commands.\n"
lang["unsufficientRank"] = "You need to be at least moderator to use that command.\n"
lang["wrongUseCmd"] = "Invalid command. Use %s" .. color.Default .. "\n"
lang["unableToDisableStaffMemeber"] = "You can't disable title for the staff member.\n"
lang["restrictOffensiveTitle"] = "Such title is considered offensive, don't be shy to use more polite one.\n"
lang["enabledTitleForPlayer"] = "You have enabled title for player %s" .. color.Default .. ".\n"
lang["enabledTitleByStaff"] = "Your title has been enabled again by staff member.\n"
lang["notInDisabled"] = "Can't enable title for %s" .. color.Default .. ". They already have it enabled.\n"
lang["restrictedToStaff"] = "Sorry, this title is restricted to staff members only.\n"
lang["invalidColor"] = "Invalid color. Use %s" .. color.Default .. " to display available colors.\n"
lang["noSuchPlayerOnline"] = "There's no player online matching that pid.\n"
lang["incognitoOff"] = "You have disabled incognito mode.\n"
lang["incognitoOn"] = "You have enabled incognito mode.\n"

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


Methods.StaffHelp = function(pid)

	local list = ""
	local title = color.Orange .. "\nTitle Staff Help"
	local divider = "\n"

	for i = 1, #menuCmd do
		if i == #menuCmd then
			divider = ""
		end
		
		list = list .. menuCmd[i] .. divider
	end
	
	tes3mp.ListBox(pid, guiId.staffHelp, title, list)
end


Methods.PlayerHelp = function(pid)

	local list = ""
	local title = color.Orange .. "\nTitle Player Help"
	local divider = "\n"

	for i = 1, #menuCmd do
		if i == #menuCmd - 1 then
			divider = ""
		end
		
		if i ~= 2 and i ~= 7 then
		
			list = list .. menuCmd[i] .. divider
		end
	end
	
	tes3mp.ListBox(pid, guiId.playerHelp, title, list)
end


Methods.showColorListCmd = function(pid, cmd)

	if Methods.validateNameOrPid(pid) then
		local list = ""
		local title = color.Green .. "\nList of available colors"
		
		local divider = "\n"
		local tempColors = {}
		
		for targetColor, _ in pairs(color) do
			table.insert(tempColors, targetColor)
		end
		
		table.sort(tempColors) 
		
		for i = 1, #tempColors do
			local currentColor = tempColors[i]
			
			if i == #tempColors then
				divider = ""
			end

			list = list .. color[currentColor] .. currentColor .. divider
		end
		
		tes3mp.ListBox(pid, guiId.playerHelp, title, list)
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

	if cmd[2] then
		
		local targetPid
		local targetName
		
		targetPid = Methods.validateNameOrPid(cmd[2])
		
		if Methods.validateNameOrPid(pid) then 
		
			if Players[pid]:IsServerStaff() then
				if targetPid then
					targetName = tes3mp.GetName(targetPid)
					local targetNameMsg = chatInfoNameColor .. targetName
					
					if not Players[targetPid]:IsServerStaff() then
						Methods.DisableTitleForPlayer(targetPid)
						Methods.SaveDisableEntry(targetName)
						doMessage(pid, "disableSuccesful", targetNameMsg)
					else
						doMessage(pid, "unableToDisableStaffMemeber", targetNameMsg)
					end	
				else
					doMessage(pid, "noSuchPlayerOnline")
				end
			else
				doMessage(pid, "unsufficientRank")
			end
		end
	else
		doMessage(pid, "wrongUseCmd", menuCmd[2])
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

	if cmd[2] then
		if Methods.validateNameOrPid(pid) then
	
			if Players[pid]:IsServerStaff() then
			
				local targetPid = Methods.validateNameOrPid(cmd[2])

				if targetPid then
					local targetName = tes3mp.GetName(targetPid)
						if Methods.RemoveDisabledPlayer(targetName) ~= false then
							Methods.ToggleTitle(targetPid)
							doMessage(pid, "enabledTitleForPlayer", targetName)
							doMessage(targetPid, "enabledTitleByStaff")
						else
							doMessage(pid, "notInDisabled", targetName)
						end	
				end
			else
				doMessage(pid, "unsufficientRank")
			end
		end
	else
		doMessage(pid, "wrongUseCmd", menuCmd[7])
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
		Players[pid].data.customVariables.titleData[key] = value
	end
	
	Players[pid]:QuicksaveToDrive()
end


local function OnServerPostInit(eventStatus)

	LoadJson()

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
				Methods.CreateEntry(pid)
			end
		end
	
	end

end


local function OnPlayerSendMessageValidator(eventStatus, pid, message)

	if Methods.validateNameOrPid(pid) and Methods.HasTitle(pid) then
		
			if message:sub(1, 1) ~= '/' then
				local playerColor = Players[pid].data.customVariables.titleData.color
				local playerTitle = Players[pid].data.customVariables.titleData.title .. " "
				local message = color.Default .. logicHandler.GetChatName(pid) .. ": " .. message .. "\n"
				
				if Players[pid].data.customVariables.titleData.incognito == "off" then
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
				
				tes3mp.SendMessage(pid, message, true)
			
				return customEventHooks.makeEventStatus(false,false)
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

				if Players[pid].data.customVariables.titleData.incognito == "off" then
					Players[pid].data.customVariables.titleData.incognito = "on"
					doMessage(pid, "incognitoOn")
				elseif Players[pid].data.customVariables.titleData.incognito == "on" then
					Players[pid].data.customVariables.titleData.incognito = "off"
					doMessage(pid, "incognitoOff")
				end
				
				Players[pid]:QuicksaveToDrive()
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
	
	if #cmd > 1 then
		
		if Methods.validateNameOrPid(pid) then
			
			local playerName = tes3mp.GetName(pid)
			
			if not Methods.IsPlayerDisabled(playerName) then
			
				if Methods.HasTitle(pid) then
	
					local title = ""
					
					for i = 2, #cmd do
						title = title .. " " .. cmd[i]
					end
					
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
		end
	end
end



Methods.SetColor = function(pid, newColor)

	Players[pid].data.customVariables.titleData.color = newColor
	
	Players[pid]:QuicksaveToDrive()

end


Methods.LookupColor = function(colorToFind)
	
	local newColor = ""
	
	for keyColor, valueColor in pairs(color) do
		if string.upper(keyColor) == string.upper(colorToFind) or string.upper(valueColor) == string.upper(colorToFind) then
			newColor = keyColor
			return newColor
		end
	end

	return false

end


Methods.setColorCmd = function(pid, cmd)
	
	if cmd[2] then
		
		if Methods.validateNameOrPid(pid) then
		
			local playerName = tes3mp.GetName(pid)
			
			if not Methods.IsPlayerDisabled(playerName) then
		
				if Methods.HasTitle(pid) then

					local newColor = Methods.LookupColor(cmd[2])
					
					if newColor then
						Methods.SetColor(pid, newColor)
						doMessage(pid, "changeSuccessSelf", lang.Color, color[newColor] .. string.lower(newColor))
					else
						doMessage(pid, "invalidColor", menuCmd[6])
					end
				end
			else
				doMessage(pid, "disabledByStaff")
			end
		end
	else
		doMessage(pid, "wrongUseCmd", menuCmd[1])
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
customCommandHooks.registerCommand(cmds[1], Methods.setColorCmd)
customCommandHooks.registerCommand(cmds[2], Methods.disableTitleForPlayerCmd)
customCommandHooks.registerCommand(cmds[3], Methods.displayHelpCmd)
customCommandHooks.registerCommand(cmds[4], Methods.setTitleCmd)
customCommandHooks.registerCommand(cmds[5], Methods.toggleTitleForSelfCmd)
customCommandHooks.registerCommand(cmds[6], Methods.showColorListCmd)
customCommandHooks.registerCommand(cmds[7], Methods.pardonPlayerCmd)
customCommandHooks.registerCommand(cmds[8], Methods.incognitoCmd)
