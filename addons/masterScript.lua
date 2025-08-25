--> @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--> @@@@@@@@@@@@@@@@               @@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@
--> @@@@@@@@@@@@@@@@@@@    @@@@@@     @@@@@@@@@     @@@@@@@@@@@@@@@@@@@@@@@@@@@
--> @@@@@@@@@@@@@@@@@@@    @@@@@@@     @@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@
--> @@@@@@@@@@@@@@@@@@@    @@@@@@@     @@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@
--> @@@@@@@@@@@@@@@@@@@    @@@@@@@    @@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@
--> @@@@@@@@@@@@@@@@@@@    @@@@@@    @@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@
--> @@@@@@@@@@@@@@@@@@@            @@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@
--> @@@@@@@@@@@@@@@@@@@    @@@@@@@     @@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@
--> @@@@@@@@@@@@@@@@@@@    @@@@@@@@@    @@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@
--> @@@@@@@@@@@@@@@@@@@    @@@@@@@@@     @@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@
--> @@@@@@@@@@@@@@@@@@@    @@@@@@@@@     @@@@@@@    @@@@@@@@@@  @@@@@@@@@@@@@@@
--> @@@@@@@@@@@@@@@@@@@    @@@@@@@@@    @@@@@@@@    @@@@@@@@@   @@@@@@@@@@@@@@@
--> @@@@@@@@@@@@@@@@@@@     @@@@@     @@@@@@@@@     @@@@@@@@    @@@@@@@@@@@@@@@
--> @@@@@@@@@@@@@@@@              @@@@@@@@@@                   @@@@@@@@@@@@@@@@
--> @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

--#####################
--##  Configuration  ##
--#####################

--> Set REALIPADDR to the IP address of your server, excluding the port
--> Set REALIP_PORT to the port of your server.
local REALIPADDR = ""
local REALIP_PORT = 0
local ServerName = "New Brickline Server | %CLIENT%"
local LauncherVersion = "Novetus Snapshot v25.9352.2"
local ServerImage = "" -- Optional: URL to a server image for display on Brickline

--> %MAP% and %CLIENT% are variables and will automatically get replaced by the client and map name.

--#####################
--##     Script      ##
--#####################
--> DO NOT MODIFY BELOW <--
local REALIPENABLED = true
local masterServerAddr = "brickline.blackspace.lol"

local function rndID(length)
	local res = ""
	for i = 1, length do
		res = res .. string.char(math.random(97, 122))
	end
	return res
end

local function getPlayerCount(max)
	local count = game.Players:GetChildren()
	for _, v in ipairs(count) do 
		if v.Name == "[SERVER]" and not v.Character then
			return tostring(#count - 1).."/"..tostring(max - 1)
		end
	end
	return tostring(#count).."/"..tostring(max)
end

local function getPlayerNames()
	local names = {}
	for _, v in ipairs(game.Players:GetChildren()) do
		table.insert(names, v.Name)
	end
	return table.concat(names, ",")
end


local function masterServerPinger()
    --> Init
    local ID         = rndID(50)
    local maxPlayers = game.Players.MaxPlayers
    local ClientVer  = game.Lighting.Version.Value
    local LauncherVer = LauncherVersion
    local num        = 0
    local mapName    = tostring(game)
    local port       = game.NetworkServer.Port
    local requestURI = "?id="..tostring(ID).."&client="..ClientVer.."&launcherversion="..LauncherVer.."&map="..mapName.."&name="..ServerName

    local ipAddr     = ""
    if REALIPENABLED and REALIPADDR ~= "" and REALIP_PORT >= 1 and REALIP_PORT <= 65535 then
        port   = REALIP_PORT
        ipAddr = REALIPADDR
    end

    -- Add ServerImage if provided
    if ServerImage ~= "" then
        requestURI = requestURI .. "&image=" .. ServerImage
    end

    print("Creating new server on Brickline: " .. masterServerAddr)

    local callServer = Instance.new("Sound", game.Lighting)
        callServer.Name = "Create server"
        callServer.SoundId = "https://"..masterServerAddr.."/server/create"..requestURI.."&players="..getPlayerCount(maxPlayers).."&playitIP="..ipAddr.."&port="..port

    callServer:remove()
    print("Done creating server on Brickline.")

game:GetService("NetworkServer").IncommingConnection:connect(function(name, repl)
	local timer = 0
	while not repl:GetPlayer() do
		wait(1)
		timer = timer + 1
		
		if timer >= 30 then
			repl:CloseConnection()
		end
	end
	local isValid = pcall(function() return game:HttpGet("https://"..masterServerAddr.."/game/checkKey/"..repl:GetPlayer().Name, true) end)
	if isValid then
		local username = game:HttpGet("https://"..masterServerAddr.."/game/checkKey/"..repl:GetPlayer().Name, true)
		print("looks like we have " .. username .. " joining!")
		repl:GetPlayer().Name = username
	else
		repl:CloseConnection()
	end
end)

    while wait(5) do
        num = num + 1
	local encodedList = getPlayerNames():gsub(" ", "%%20")
        game:HttpGet("https://"..masterServerAddr.."/server/keepAlive"..num..requestURI.."&players="..getPlayerCount(maxPlayers).."&playitIP="..ipAddr.."&port="..port .. "&playernames="..encodedList, true)
    end
end

this = {}

function this:Name()
    return "BRICKLINE CONNECTION SCRIPT"
end

function this:PostInit()
    print("\nHello from Brickline (https://discord.gg/7j8C6TV9gN)\n")
    print("BRICKLINE CONNECTION SCRIPT v4.0")

    --> If studio type isn't a server, then stop don't execute.
    if game.Lighting.ScriptLoaded.Value ~= "Server" then
        print("This isn't a server. Stopping master server connection script.") return
    end

    local MSC = coroutine.create(masterServerPinger)
    coroutine.resume(MSC)
end

function AddModule(t)
    print("AddonLoader: Adding " .. this:Name())
    table.insert(t, this)
end

_G.CSScript_AddModule=AddModule

