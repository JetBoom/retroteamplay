include("shared.lua")

function ENT:Initialize()
	self:SetRenderBounds(Vector(-300, -300, -300), Vector(300, 300, 300))
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
	self.NextEmit = 0

	self.AmbientSound = CreateSound(self, "npc/scanner/combat_scan_loop4.wav")
	self:EmitSound("npc/roller/mine/rmine_shockvehicle"..math.random(1,2)..".wav", 76, 80)

	self.FullChargeTime = CurTime() + self.ChargeTime
	self.Delta = 0
	self.Col = team.GetColor(self:GetTeamID())

	if MySelf == self:GetOwner() then
		MySelf:DI(NameToSpell["Nether Bomb"], self.ChargeTime)
	end
end

function ENT:OnRemove()
	if MySelf == self:GetOwner() and not self:GetSkin() == 1 then
		MySelf:DI(NameToSpell["Nether Bomb"], 5)
	end
	self.AmbientSound:Stop()
end

function ENT:Think()
	if not self.Delta or self.Delta <= 1 then
		self.Delta = 1 - (self.FullChargeTime - CurTime())/self.ChargeTime
	end

	self.AmbientSound:PlayEx(0.4 * self.Delta, 50 + 80 * self.Delta * 1.3)
	self:NextThink(CurTime())
	return true
end

local matLight = Material("models/props_combine/tpballglow")
local matWhite = Material("models/debug/debugwhite")
local matGlow = Material("sprites/orangecore2")
function ENT:DrawTranslucent()
	local pos = self:GetPos()
	local owner = self:GetOwner()
	local spritecol = 1.5
	if not MySelf:IsValid() then return end
	local distdelt = 1 - MySelf:GetCenter():Distance(pos)/self.VisibilityRadius
	if MySelf:GetTeamID() ~= owner:GetTeamID() then
		if distdelt <= 0 then
			return
		else
			render.SetBlend(distdelt)
			spritecol = 1.5 * distdelt
		end
	end
	local delta = self.Delta
	local sindistort = math.sin(CurTime()*2)
	self:SetModelScale(math.max(0, .5 * delta + .05 * sindistort), 0)

	render.SetColorModulation(51/255, 0, 99/255)
		render.MaterialOverride(matWhite)
			self:DrawModel()
		render.MaterialOverride(matLight)
			self:DrawModel()
		render.MaterialOverride()
	render.SetColorModulation(1, 1, 1)
	render.SetBlend(1)

	local siz = self.MaxRadius * self.Delta
	local distort = self.MaxRadius / 5
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, math.max(0, siz + math.Rand(-distort, distort) + self.MaxRadius/10 * sindistort), math.max(0, siz + math.Rand(-distort, distort) + self.MaxRadius/10 * sindistort), Color(51 * spritecol, 0, 99 * spritecol))
end

