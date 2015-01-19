include("shared.lua")



function ENT:Initialize()
	self:DrawShadow(false)
	self.Col = team.GetColor(self:GetSkin()) or color_white
	
	self.PlaceTime = CurTime() + self.SetTime -- when it's placed
	self.DeathTime = CurTime() + self.ExplodeTime -- when it blows up
	
	self.Entity:SetRenderBounds(Vector(-200, -200, -200), Vector(200, 200, 200))
	self.AmbientSound = CreateSound(self, "ambient/levels/labs/machine_ring_resonance_loop1.wav")

end

function ENT:Think()
	local delta = math.Clamp((self.DeathTime - CurTime())/self.ExplodeTime, 0, 1)
	self.AmbientSound:PlayEx(1, math.max(40, 100 * (1 - delta)))
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:DrawTranslucent()
	local delta = math.Clamp((self.DeathTime - CurTime())/self.ExplodeTime, 0, 1)
	local col = Color(self.Col.r, self.Col.g, self.Col.b, 255)
	
	local ent = self:GetOwner()
	if CurTime() <= self.PlaceTime then
		if ent:IsValid() and ent:Alive() then
			local boneindex = ent:LookupBone("valvebiped.bip01_l_hand")
			if boneindex then
				render.SetMaterial(matGlow)
				local pos, ang = ent:GetBonePosition(boneindex)
				local size = 600 * (1 - delta)
				local pos = pos + ang:Right() * 10 + ang:Forward() * 3
				self:SetPos(pos)
				render.DrawSprite(pos, size + size/10, size + size/10, col)
				render.DrawSprite(pos, size, size, COLOR_YELLOW)
				render.DrawSprite(pos, size/2, size/2, color_white)		
				self.Pos = pos
			end
		end
	else
		render.SetMaterial(matGlow)
		if self.Pos then
			local pos = self.Pos + Vector(0, 0, 10) * math.sin(CurTime() * 2 * math.pi / (self.ExplodeTime - self.SetTime))
			local size = 600 * (1 - delta)
			render.DrawSprite(pos, size + size/10, size + size/10, col)
			render.DrawSprite(pos, size, size, COLOR_YELLOW)
			render.DrawSprite(pos, size/2, size/2, color_white)
		end
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end
