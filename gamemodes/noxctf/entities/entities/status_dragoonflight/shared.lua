ENT.Type = "anim"
ENT.Base = "status__base"

ENT.StartSound = {sound = Sound("ambient/fire/ignite.wav"), vol = 82, pitchLB = 80, pitchRB = 80}
ENT.EndSound = Sound("ambient/fire/gascan_ignite1.wav")
ENT.StatusImage = "spellicons/dragoonflight.png"
ENT.Fatigue = 10
ENT.NextFlap = 0
ENT.NextRecharge = 0
ENT.Glide = 0

function ENT:Move(pl, move)
	if pl ~= self:GetOwner() then return end

	if not pl:OnGround() then
		if pl:KeyPressed(IN_JUMP) and CurTime() > self.NextFlap then
			self.Flap = true
			self.NextFlap = CurTime() + 0.25
			self.Glide = CurTime() + 0.3
			local vel = pl:GetVelocity()
			move:SetVelocity(Vector(vel.x,vel.y,vel.z + 150 * math.max(0.1,self.Fatigue/10)))
			self.Fatigue = self.Fatigue - 1
			if SERVER then
				pl:EmitSound("ambient/fire/mtov_flame2.wav",80, 77)
			end
		end
		if pl:KeyDown(IN_JUMP) or CurTime() <= self.Glide then
			if SERVER then
				pl:SetGravity(0.25)
			end
		else
			if SERVER then
				pl:SetGravity(1)
			end
		end
	else
		if CurTime() > self.NextRecharge and self.Fatigue < 10 then
			self.Fatigue = self.Fatigue + 1
			self.NextRecharge = CurTime() + 0.1
		end
	end

end
