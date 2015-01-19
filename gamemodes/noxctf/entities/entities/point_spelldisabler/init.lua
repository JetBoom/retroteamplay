AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self.Think = nil
end

local disspellbin
local function SendDisabledSpells(pl)
	pl:SendLua("DecrDisSpells(\""..disspellbin.."\")")
end

local function UpdateDisabledSpells()
	local str = ""
	for i=1, #Spells do
		if GAMEMODE.DisabledSpells[i] then
			str = str.."1"
		else
			str = str.."0"
		end
	end
	disspellbin = str
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "spell" then
		value = string.lower(value)
		if NameToSpellLower[value] then
			GAMEMODE.DisabledSpells[ NameToSpellLower[value] ] = true
			timer.Create("UPDSP", 0, 1, function() UpdateDisabledSpells() end)
			hook.Add("PlayerReady", "upddisabledspells", SendDisabledSpells)
		end
	end
end
