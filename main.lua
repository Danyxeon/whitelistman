function onInit()
    print("BanMan-Lite (Whitelist) Ready")
    RegisterEvent("onPlayerAuth","onPlayerAuth")
end

function onPlayerAuth(name)

	local f = assert(io.open("./Resources/Server/banman-lite-whitelist/whitelist", "r"))
	local t = f:read ("*all")
	
	print("Checking whitelist for", name)
	
	if not string.match(t, name) then
		return "You have not been whitelisted on this server."
	else
		print("All good, user clear to join.")
	end
	
	f:close()
end