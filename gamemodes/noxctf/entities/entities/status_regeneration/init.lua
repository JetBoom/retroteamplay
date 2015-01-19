AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusThink(owner)
	local ct = CurTime()
	if not self.NextHeal or self.NextHeal <= ct then
		self.NextHeal = ct + 0.5
		GAMEMODE:PlayerHeal(owner, self.Healer, 1)
	end
end
