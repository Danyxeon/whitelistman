-- Change this to 'true' to allow guests
local allowGuests = false

function onInit()
    print("WhitelistManager 1.3.3 Loaded")
    MP.RegisterEvent("onPlayerAuth","playerAuthHandler")
	MP.RegisterEvent("onChatMessage", "chatMessageHandler")
end

function playerAuthHandler(name, role, isGuest)

	if isGuest and not allowGuests then
		return "You must be signed in to join this server!"
	end

	local file = assert(io.open("../banlist", "r"))
	local banlist = file:read ("*all")

	file:close()
	
	print("WhitelistManager: Checking whitelist for " .. name)
	
	if string.match(banlist, name) then
		return "You have not been whitelisted on the server."
	else
		print("WhitelistManager: All good, user clear to join.")
	end
end

function chatMessageHandler(playerID, senderName, message)

	-- Initialize files
	local file = assert(io.open("../perms", "r"))
	local perms = file:read ("*all")
	local whitelist = assert(io.open("../whitelist", "a+"))

	local permsMatch = string.match(perms, senderName)
	local msgTxt = string.match(message, "%s(.*)")
	local msgNum = tonumber(string.match(message, "%d+"))

	file:close()

	-- Intialize commands
	local getPlayerList = string.match(message, "/idmatch")
	local msgKick = string.match(message, "/kick")
	local msgWhitelist = string.match(message, "/whitelist")
	local msgCountdown = string.match(message, "/countdown")

	if msgCountdown then
		local i = 3
		while i > 0 do
			MP.SendChatMessage(-1, "Countdown: " .. i)
			i = i - 1
			MP.Sleep(1000)
		end
		MP.SendChatMessage(-1, "Go!")
		return -1
	end

	if senderName == permsMatch then
		
		if getPlayerList then
			local i = 9
			while i >= 0 do
				local playerName = MP.GetPlayerName(i)
				if playerName == nil then
					MP.SendChatMessage(playerID, "Did not find player with ID" .. i)
				else
					playerName = i .. " - " .. MP.GetPlayerName(i)
					MP.SendChatMessage(playerID, playerName)
				end
				i = i - 1
			end
			return -1
		end

		if msgKick then
			if msgNum == nil then
				MP.SendChatMessage(playerID, "No ID given")
			else
				MP.DropPlayer(msgNum)
				MP.SendChatMessage(playerID, "Kicked player " .. MP.GetPlayerName(msgNum))
			end
			return -1
		end

		if msgWhitelist then
			if msgTxt == nil then
				MP.SendChatMessage(playerID, "Missing username")
			else
				whitelist:write("\n" .. msgTxt)
				whitelist:flush()
				whitelist:close()
				MP.SendChatMessage(playerID, "Whitelisted user " .. msgTxt)
			end
			return -1
		end
	end
end