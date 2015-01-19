include("shared.lua")

function ENT:StatusInitialize()
	self:SetModel("models/morrowind/dwemer/mace/w_dwemer_mace.mdl")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetRenderBounds(Vector(-80, -80, -32), Vector(80, 80, 120))
end

local matGlow = Material("sprites/orangecore1")
local matBeam = Material("trails/electric")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local rag = owner:GetRagdollEntity()
		if rag then
			owner = rag
		elseif not owner:Alive() or owner:IsInvisible() then return end

		local boneindex = owner:LookupBone("valvebiped.bip01_r_hand")
		if boneindex then
			local pos, ang = owner:GetBonePosition(boneindex)
			if pos then
				local c = owner:GetColor()
				self:SetColor(Color(255, 255, 255, math.max(1, c.a)))
				self:SetPos(pos + ang:Forward() * 3 + ang:Right() * 6 + ang:Up() * -6)
				ang:RotateAroundAxis(ang:Up(), 90)
				ang:RotateAroundAxis(ang:Forward(), 180)
				self:SetAngles(ang)
				self:SetModelScale(1.5, 0)
				self:DrawModel()
				
				-- glow at top of scepter
				render.SetMaterial(matGlow)
				
				local delta
				if CurTime() >= self:GetOrbSize() then
					delta = 1
				else
					delta = 1 - (self:GetOrbSize() - CurTime()) / (owner:GetActiveWeapon().Special2Cooldown - .2)
				end
				
				local siz = 19 * delta + math.sin(CurTime() * 2)
				render.DrawSprite(pos + ang:Up() * 32 + ang:Right() * -3.8 + ang:Forward() * -7.5, siz, siz, self.TeamCol)
				
				-- beams at top of scepter
				render.SetMaterial(matBeam)
				local beampos = CurTime()/5
				local siz = 15
				
				local pos1 = pos + ang:Up() * 26 + ang:Forward() * -6 + ang:Right() * 3
				local pos2 = pos + ang:Up() * 26 + ang:Right() * -4 + ang:Forward() * 2
				render.DrawBeam(pos1, pos2, siz, beampos, beampos + .5, self.TeamCol)
				
				local pos1 = pos + ang:Up() * 26 + ang:Right() * -4 + ang:Forward() * 2
				local pos2 = pos + ang:Up() * 26 + ang:Right() * -11 + ang:Forward() * -4
				render.DrawBeam(pos1, pos2, siz, beampos + .5, beampos + 1, self.TeamCol)
				
				local pos1 = pos + ang:Up() * 26 + ang:Right() * -11 + ang:Forward() * -4
				local pos2 = pos + ang:Up() * 26 + ang:Right() * -4 + ang:Forward() * -14
				render.DrawBeam(pos1, pos2, siz, beampos + 1, beampos + 1.5, self.TeamCol)
				
				local pos1 = pos + ang:Up() * 26 + ang:Right() * -4 + ang:Forward() * -14
				local pos2 = pos + ang:Up() * 26 + ang:Forward() * -6 + ang:Right() * 3
				render.DrawBeam(pos1, pos2, siz, beampos + 1.5, beampos + 2, self.TeamCol)

			end
		end
	end
end
