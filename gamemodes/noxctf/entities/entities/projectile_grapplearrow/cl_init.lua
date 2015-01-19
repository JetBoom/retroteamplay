include("shared.lua")

function ENT:Initialize()
	self:SetRenderBounds(Vector(-60, -60, -60), Vector(60, 60, 60))
	self.Col = self:GetColor()

	self:GetOwner().GrappleBeam = self
end

function ENT:Think()
	local owner = self:GetOwner()
	if owner:IsValid() then
		self:SetRenderBoundsWS(self:GetPos(), owner:GetShootPos(), Vector(32, 32, 32))
		if not self.PlayedWhoosh and self:GetSkin() == 1 then
			self.PlayedWhoosh = true
			owner:EmitSound("physics/nearmiss/whoosh_large4.wav", 75, math.Rand(115, 130))
		end
	end
end

function ENT:OnRemove()
	self:GetOwner().GrappleBeam = nil
end

local matBeam = Material("cable/rope")
function ENT:Draw()
	local vel = self:GetVelocity()
	if 10 < vel:Length() then
		self:SetAngles(vel:Angle())
	end
	self:DrawModel()

	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local startpos = owner:EyePos()
	if owner:IsValid() then
		local wep = owner:GetActiveWeapon()
		if owner == MySelf then
			local attach
			if MySelf:ShouldDrawLocalPlayer() and wep:IsValid() then
				attach = wep:GetAttachment(1)
			else
				attach = MySelf:GetViewModel():GetAttachment(1)
			end
			if attach then
				startpos = attach.Pos
			end
		elseif wep:IsValid() then
			local attach = wep:GetAttachment(1)
			if attach then startpos = attach.Pos end
		end
	end

	startpos = startpos or owner:GetShootPos()

	render.SetMaterial(matBeam)
	local pos = self:GetPos()
	render.DrawBeam(pos, startpos, 2, 0, startpos:Distance(pos) / 512, team.GetColor(owner:Team()))
end
