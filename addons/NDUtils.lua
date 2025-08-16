--[[

NovetusDocker Utils

]]--

local Players = game:GetService("Players")

local this = {}

function SerializeToJSON(value)
    local valueType = type(value)

    if valueType == "string" then
        return '"' .. value:gsub('"', '\\"') .. '"'
    elseif valueType == "number" or valueType == "boolean" then
        return tostring(value)
    elseif valueType == "table" then
        -- Check if it's a list (all keys are numeric and consecutive)
        local isArray = true
        local count = 0
        for k, v in pairs(value) do
            count = count + 1
            if type(k) ~= "number" then
                isArray = false
                break
            end
        end

        local result = {}
        if isArray then
            for i = 1, #value do
                table.insert(result, SerializeToJSON(value[i]))
            end
            return "[" .. table.concat(result, ",") .. "]"
        else
            for k, v in pairs(value) do
                table.insert(result, '"' .. tostring(k) .. '":' .. SerializeToJSON(v))
            end
            return "{" .. table.concat(result, ",") .. "}"
        end
    else
        return 'null'
    end
end

local function base64Encode(input)
	local base64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local function toBinaryString(byte)
		local bin = ""
		for i = 7, 0, -1 do
			local bit = math.floor(byte / (2 ^ i)) % 2
			bin = bin .. bit
		end
		return bin
	end

	local binary = ""

	-- Convert each byte to 8-bit binary
	for i = 1, #input do
		local byte = string.byte(input, i)
		binary = binary .. toBinaryString(byte)
	end

	-- Pad to a multiple of 6 bits
	while #binary % 6 ~= 0 do
		binary = binary .. "0"
	end

	local encoded = ""

	for i = 1, #binary, 6 do
		local chunk = string.sub(binary, i, i + 5)
		local index = tonumber(chunk, 2)
		if index then
			encoded = encoded .. string.sub(base64Chars, index + 1, index + 1)
		else
			error("Failed to parse binary chunk: " .. tostring(chunk))
		end
	end

	-- Add '=' padding
	while #encoded % 4 ~= 0 do
		encoded = encoded .. "="
	end

	return encoded
end

function this:Name()
	return "NDUtils"
end

function this:IsEnabled(Script, Client)
	if (Script == "Server") then
		return true
	else
		return false
	end
end

this._lastUpdateTick = 0
this._updateInterval = 5

function this:Update()
	local now = tick()  -- Roblox's UNIX timestamp (float)

	if now - self._lastUpdateTick < self._updateInterval then
		return  -- Too soon, skip this update
	end

	self._lastUpdateTick = now  -- Update timestamp
	
	local playerList = {}

	for _, player in ipairs(Players:GetPlayers()) do
    		table.insert(playerList, {
        		PlayerName = player.Name,
        		PlayerId = tostring(player.userId),
    		})
	end

	jsonList = SerializeToJSON(playerList)
	game:HttpGet("http://127.0.0.1:3000/server/info/" .. base64Encode(jsonList))
end

function AddModule(t)
	print("AddonLoader: Adding " .. this:Name())
	table.insert(t, this)
end

_G.CSScript_AddModule=AddModule
