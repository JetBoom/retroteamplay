AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
ENT.Bounces = 3
ENT.NextBounce = CurTime() + 0.2

function ENT:StatusInitialize()
	self.Shocked = {}
end

function ENT:PlayerSet(pPlayer, bExists)
	self:GetOwner():TakeSpecialDamage(10, DMGTYPE_LIGHTNING, self.Inflictor or self, self)
	self.NextBounce = CurTime() + 0.2
	self.Shocked[self:GetOwner()] = true
	self:SetBeamTarget(self:GetOwner())
	self:EmitSound("nox/lightning0"..math.random(1,2)..".ogg")
end

function ENT:StatusThink(owner)
	local caster = self.Inflictor
	local casterteam = caster:Team()
	local owner = self:GetOwner()
	local pos = owner:EyePos()
	if CurTime() < self.NextBounce and self.Bounces > 0 then
		local Near = {}
		for i, ent in ipairs(ents.FindInSphere(pos, 512)) do
			if not self.Shocked[ent] and ent:IsValid() and ent:IsPlayer() and ent:Alive() and ent ~= owner and ent ~= caster and ent:GetTeamID() ~= casterteam then
				Near[ent] = ent:EyePos():Distance(pos) * -1
			end
		end
		local nearest = table.GetWinningKey( Near )
		if nearest then
			self.NextBounce = CurTime() + 0.2
			self.Bounces = self.Bounces - 1
			self:SetBeamTarget(owner)
			self:SetOwner(nearest)
			self:SetPos(nearest:GetPos())
			nearest:TakeSpecialDamage(10, DMGTYPE_LIGHTNING, caster or self, self)
			self.Shocked[self:GetOwner()] = true
			self:EmitSound("nox/lightning0"..math.random(1,2)..".ogg")
		end
	end
end


function ENT:StatusOnRemove(owner, silent)
end

