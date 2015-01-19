ENT.Type = "point"

function ENT:Initialize()
	self:Fire("kill", "", 1.7)
	self.Teleported = {}
end

function ENT:Think()
	local pos = self:GetPos()
	for _, ent in pairs(ents.FindInBox(pos + Vector(-20, -20, 0), pos + Vector(20, 20, 48))) do
		if ent:IsPlayer() and ent:Alive() and not ent:InVehicle() and not ent:IsCarrying() and not ent:IsAnchored() and not self.Teleported[ent] then
			if ent:Team() == self:GetTeamID() then
				if ent ~= self.Owner and ent:GetInfoNum("nox_declinefriendlyteleports", 1) == 1 then return end
			else
				ent.LastAttacked = CurTime()
				ent.LastAttacker = self.Owner
			end

			ent:TemporaryNoCollide()

			local vCur = ent:GetVelocity()
			ent:SetLocalVelocity(Vector(vCur.x, vCur.y, 0))
			ent:SetPos(self.TargetPos)
			self.Teleported[ent] = true
		end
	end	
end
