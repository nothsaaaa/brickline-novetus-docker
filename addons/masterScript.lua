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
local ServerName = "New Brickline Server | %MAP% | %CLIENT%"
local LauncherVersion = "Novetus 1.3 v3.2024.2"
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

    while wait(5) do
        num = num + 1

        local keepAlive = Instance.new("Sound", game.Lighting)
            keepAlive.Name = "Pinging Brickline"
            keepAlive.SoundId = "https://"..masterServerAddr.."/server/keepAlive"..num..requestURI.."&players="..getPlayerCount(maxPlayers).."&playitIP="..ipAddr.."&port="..port

        keepAlive:remove()
    end
end

this = {}

function this:Name()
    return "BRICKLINE CONNECTION SCRIPT"
end

function this:PostInit()
    print("\nHello from Brickline (https://discord.gg/7j8C6TV9gN)\n")
    print("BRICKLINE CONNECTION SCRIPT v3.0")

    --> If studio type isn't a server, then stop don't execute.
    if game.Lighting.ScriptLoaded.Value ~= "Server" then
        print("This isn't a server. Stopping master server connection script.") return end

    local MSC = coroutine.create(masterServerPinger)
    coroutine.resume(MSC)
end

function AddModule(t)
    print("AddonLoader: Adding " .. this:Name())
    table.insert(t, this)
end

_G.CSScript_AddModule=AddModule
