include("shared.lua")

local texGradientU = surface.GetTextureID('vgui/gradient-u')
local texGradientD = surface.GetTextureID('vgui/gradient-d')
local texGradientR = surface.GetTextureID('vgui/gradient-r')
function ENT:HUDPaint()
	if self:GetOwner() ~= LocalPlayer() then return end

	local sizeW = ScrW() * 1.3
	local sizeH = ScrH() * 1
	local col = Color(15,0,15,255)
	surface.SetTexture(texGradientU)
	surface.SetDrawColor(col)
	surface.DrawTexturedRect(0, 0, ScrW(), sizeH)
	surface.SetTexture(texGradientR)
	surface.SetDrawColor(col)
	surface.DrawTexturedRect(ScrW()-sizeW, 0, sizeW, ScrH())
	surface.SetTexture(texGradientD)
	surface.SetDrawColor(col)
	surface.DrawTexturedRect(0, ScrH()-sizeH, ScrW(), sizeH)
	surface.SetTexture(texGradientU)
	surface.SetDrawColor(col)
	surface.DrawTexturedRectRotated(sizeW/2, ScrH()/2, ScrH(), sizeW, 90)
end

function ENT:StatusInitialize()
	local owner = self:GetOwner()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 128))
	self:SetModelScale( 1.5, 0 )
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(34, 42)

	if owner == LocalPlayer() then
		owner:SetDSP(31, false)
		self.AmbientSound = CreateSound(self, "player/breathe1.wav")
		self.AmbientSound:PlayEx(1, 100)
		self.AmbientSound2 = CreateSound(self, "player/heartbeat1.wav")
		self.AmbientSound2:PlayEx(1, 100)
	end

	hook.Add("HUDPaint", self, self.HUDPaint)
end

function ENT:StatusOnRemove(owner)
	--self.Emitter:Finish()
	
	if self:GetOwner() == LocalPlayer() then
		self:GetOwner():SetDSP(0, false )
	end
	
	if self.AmbientSound then
		self.AmbientSound:Stop()
		self.AmbientSound = nil
	end
	
	if self.AmbientSound2 then
		self.AmbientSound2:Stop()
		self.AmbientSound2 = nil
	end
	
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() or owner:IsInvisible() then return end

	local pos = owner:EyePos() + Vector(0,0,32 + 5 * math.sin(CurTime() * 10))
	self:SetPos(pos)
	self:SetAngles(Angle(0,owner:GetAngles().yaw,12 * math.sin(CurTime() * 25)))
	self:DrawModel()
	local emitter = self.Emitter
	for i=1, 6 do
		local particle = emitter:Add("particle/particle_smokegrenade", pos + VectorRand():GetNormal() * 15)
		particle:SetDieTime(0.4)
		particle:SetColor(math.random(125,255),0,255)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(10)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-20, 20))
	end
end
