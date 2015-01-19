include("shared.lua")

util.PrecacheSound("ambient/energy/force_field_loop1.wav")
for i=1,6 do
	util.PrecacheSound("sound/ambient/weather/thunder"..i..".wav")
end

function ENT:Initialize()
	self:DrawShadow(false)

	self.AmbientSound = CreateSound(self, "ambient/atmosphere/trainstation_ambient_loop1.wav")
	self.AmbientSound:PlayEx(0.8, 1)

	self.NextEmit = 0

	ParticleEffectAttach("zolt", PATTACH_ABSORIGIN_FOLLOW, self, 0)
end

function ENT:Think()
	self.AmbientSound:PlayEx(0.8, 100 + math.sin(RealTime()))

	if CurTime() >= self.NextEmit then
		self.NextEmit = CurTime() + 5
		self:EmitSound(")ambient/weather/thunder"..math.random(1, 6)..".wav", 80, 100)
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
	self:StopParticles()

	self:EmitSound("ambient/levels/labs/electric_explosion5.wav", 85, 90 + math.Rand(-10, 5))

	ParticleEffect("zolt_core_explode", self:GetPos(), angle_zero, nil)
end

function ENT:Draw()
end

local ScreenDieTime
local function ScreenEffect()
	surface.SetDrawColor(255, 255, 255, math.max(0, ScreenDieTime - CurTime()) * 180)
	surface.DrawRect(0, 0, ScrW(), ScrH())
end

local function ScreenEffectRemove()
	ScreenDieTime = nil
	hook.Remove("HUDPaint", "ZoltBlind")
end

function ZoltStruckMe()
	MySelf:SetDSP(35) -- This DSP automatically removes itself.
	ScreenDieTime = CurTime() + 1
	hook.Add("HUDPaint", "ZoltBlind", ScreenEffect)
	timer.Create("ZoltEffectRemove", 2, 1, function() ScreenEffectRemove() end)
end
