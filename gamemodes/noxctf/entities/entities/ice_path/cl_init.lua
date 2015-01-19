include("shared.lua")

function ENT:Initialize()
	self.Entity:SetRenderBounds( Vector( -64, -64, -64), Vector( 64, 64, 64))
	self:DrawShadow(false)
	self:SetModel("models/props_debris/concrete_spawnplug001a.mdl")
	self:SetMaterial("models/props/de_inferno/offwndwb_break")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.DeathTime = CurTime() + 5
	self.FadeTime = CurTime() + 4.5
	self.SpawnTime = CurTime() + 0.5
	self:EmitSound("physics/glass/glass_largesheet_break"..math.random(1, 3)..".wav", 80, math.random(160, 180))
end

function ENT:Think()
	ExplosiveEffect(self:GetPos(), 48, 30, DMGTYPE_ICE)
	if self.FadeTime <= CurTime() then	
		self:SetColor(Color(255, 255, 255, 255 * math.Clamp(((self.DeathTime-CurTime())/(self.DeathTime-self.FadeTime)),0,255)))
	end
end

function ENT:Draw()
	if self.FadeTime > CurTime() then	
		if CurTime() < self.SpawnTime then
			self:SetModelScale((1-(self.SpawnTime-CurTime())/0.5) * 1, 0)
			self:DrawModel()
		end
		if CurTime() >= self.SpawnTime then
			self:SetModelScale(1, 0)
			self:DrawModel()
		end
	end
	if self.FadeTime <= CurTime() then	
		self:SetModelScale(((self.DeathTime-CurTime())/(self.DeathTime-self.FadeTime)) * 1, 0)
		self:DrawModel()
	end
end

