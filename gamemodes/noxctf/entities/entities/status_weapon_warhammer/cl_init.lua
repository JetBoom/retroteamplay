include("shared.lua")

function ENT:StatusInitialize()
	self:SetModel("models/morrowind/orcish/hammer/w_orcish_hammer.mdl")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetRenderBounds(Vector(-80, -80, -32), Vector(80, 80, 120))
end

function ENT:Draw()
	local owner = self:GetOwner()
	if owner:IsValid() then
		if owner:IsInvisible() then return end

		local rag = owner:GetRagdollEntity()
		if rag then
			owner = rag
		elseif not owner:Alive() then return end

		local boneindex = owner:LookupBone("valvebiped.bip01_r_hand")
		if boneindex then
			local pos, ang = owner:GetBonePosition(boneindex)
			if pos then
				local c = owner:GetColor()
				self:SetColor(Color(255, 255, 255, math.max(1, c.a)))
				self:SetPos(pos + ang:Forward() * 5 + ang:Right() * 6 + ang:Up() * -10)
				ang:RotateAroundAxis(ang:Up(), 90)
				ang:RotateAroundAxis(ang:Forward(), 165)
				self:SetAngles(ang)
				self:SetModelScale(1.5, 0)
				self:DrawModel()
			end
		end
	end
end