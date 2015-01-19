AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.On = true
ENT.Team = 0
ENT.Class = 1
ENT.Inverse = false

function ENT:Initialize()
	self:DrawShadow(false)
	self.Think = nil
end

local disclassbin
local function SendDisabledClasses(pl)
	pl:SendLua("DecrDisClasses(\""..disclassbin.."\")")
end

local function UpdateDisabledClasses()
	local str = ""
	for i=1, #CLASSES do
		if GAMEMODE.DisabledClasses[i] then
			str = str.."1"
		else
			str = str.."0"
		end
	end
	disclassbin = str
end

function ENT:AcceptInput(name, activator, caller, arg)
	name = string.lower(name)
	if name == "seton" then
		self.On = arg == "1"
	elseif name == "enable" then
		self.On = true
	elseif name == "disable" then
		self.On = false
	end
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "class" then
		value = string.lower(value)
		for i, classtab in ipairs(CLASSES) do
			if string.lower(classtab.Name) == value then
				self.Class = i
				GAMEMODE.DisabledClasses[ i ] = true
				timer.Create("UPDCL", 0, 1, function() UpdateDisabledClasses() end)
				hook.Add("PlayerReady", "upddisabledclasses", SendDisabledClasses)
				break
			end
		end
	elseif key == "team" then
		if value == "red" then
			self.Team = TEAM_RED
		elseif value == "blue" then
			self.Team = TEAM_BLUE
		elseif value == "yellow" then
			self.Team = TEAM_YELLOW
		elseif value == "green" then
			self.Team = TEAM_GREEN
		else
			self.Team = 0
		end
	elseif key == "startdisabled" then
		self.On = value == "0"
	elseif key == "inversemode" then
		self.Inverse = value == "1"
	end
end
