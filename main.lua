-- Configure your settings here --

local carLimit = 2 -- Server car limit
local playerLimit = 10 -- Server player limit
local staffSlot = false

----------------------------------

function onInit()
    print("WhitelistManager 1.4.3 Loaded")
    MP.RegisterEvent("onPlayerAuth","playerAuthHandler")
	MP.RegisterEvent("onChatMessage", "chatMessageHandler")
end

function playerAuthHandler(name, role, isGuest)

	local pattern = {"%-"}
    local patternout = {"%%-"}

	local file = assert(io.open("../whitelist", "r"))
	local whitelist = file:read ("*all")
	file:close()

	for i = 1, # pattern do
        name = name:gsub(pattern[i], patternout[i])
    end

	if staffSlot == true then
		if playersCurrent == (playerLimit - 1) and not string.match(authlist, name) then
			return "The server is full. Last slot is reserved for staff."
		end
	end
	
	print("WhitelistManager: Checking whitelist for " .. name)
	
	if not string.match(whitelist, name) then
		return "You have not been whitelisted on the server."
	else
		print("WhitelistManager: All good, user clear to join.")
	end
end

function spawnLimitHandler(playerID)

	local playerVehicles = MP.GetPlayerVehicles(playerID)
	local playerCarCount = 0

	-- Check for nil table and loop through player cars
	if playerVehicles ~= nil then
		for _ in pairs(playerVehicles) do playerCarCount = playerCarCount + 1 end
	end

	carLimit = carLimit + 1

	if (playerCarCount + 1) > carLimit then
		MP.DropPlayer(playerID)
		MP.SendChatMessage(-1, "Player " .. MP.GetPlayerName(playerID) .. " was kicked for spawning more than " .. carLimit .. " cars.")
		print("BanManager: Player " .. MP.GetPlayerName(playerID) .. " was kicked for spawning too many cars.")
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