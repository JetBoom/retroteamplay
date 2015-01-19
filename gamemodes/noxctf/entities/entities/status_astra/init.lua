AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	self:SetModel("models/PHXtended/trieq1x1x1solid.mdl")
end

function ENT:StatusThink(owner)
	local toRemove = owner:GetAllStatuses(true) -- true means only hostile
	
	if #toRemove > 0 then
		table.Random(toRemove):Remove()
		self:Remove()
	elseif owner:IsPoisoned() then
		owner:CurePoison()
		self:Remove()
	end
	
	self:NextThink(CurTime())
	return true
end


