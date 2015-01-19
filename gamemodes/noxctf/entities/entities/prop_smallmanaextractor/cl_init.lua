include("shared.lua")

function ENT:Initialize()
	self.NextRequest = 0
	self.NextEmit = 0
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(35, 40)
	self.AmbientSound = CreateSound(self, "ambient/machines/machine6.wav")
end

function ENT:OnRemove()
	--self.Emitter:Finish()
	self.AmbientSound:Stop()
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())

	if self:GetSkin() == 1 then
		self.AmbientSound:PlayEx(0.67, 190 + math.sin(CurTime()))
	else
		self.AmbientSound:Stop()
	end
end

function ENT:Info(um)
	local str = um:ReadString()
	if str == "deny" then
		self.DeniedAccess = true
		return
	end

	local stuff = string.Explode(",", str)
	self.PHealth = tonumber(stuff[1])
	self.MaxPHealth = tonumber(stuff[2])
	self.Powering = stuff[3] == "true"
end

ENT.MaxTraceHUDPaintLength = 256

function ENT:TraceHUDPaint()
	if self.PHealth then
		local toscreen = self:GetPos():ToScreen()
		local x, y = toscreen.x, toscreen.y
		draw.SimpleText("Small Mana Extractor", "teamplay", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
		local _, hhh = surface.GetTextSize("A")
		y = y + hhh * 1.2
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(x - 100, y, 200, hhh)
		surface.SetDrawColor(255, 0, 0, 255)
		local health = self.PHealth
		local maxhealth = self.MaxPHealth
		surface.DrawRect(x - 100, y, (health / maxhealth) * 200, hhh)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect(x - 100, y, 200, hhh)
		draw.SimpleText(health.." / "..maxhealth, "teamplaytargetidsmall", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
		local start = self:GetPos() + self:GetUp() * 16
		local trent = util.TraceLine({start = start, endpos = start + self:GetForward() * -48, filter=self}).Entity
		if not (IsValid(trent) and trent:GetClass():lower() == "obelisk") then
			y = y + hhh
			draw.SimpleText("(NOT FACING AN OBELISK)", "teamplaytargetidsmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		else
			local c = self:GetColor()
			if c.a == 255 and self:GetSkin() == 0 then
				y = y + hhh
				draw.SimpleText("(OBELISK IS ALREADY BEING HARVESTED)", "teamplaytargetidsmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
			end
		end

		if not util.TraceLine({start = start + self:GetUp() * 18, endpos = start + self:GetForward() * 32000, filter=self}).Entity.CanTakeMana then
			y = y + hhh
			draw.SimpleText("(NO CAPACITOR IN BACK)", "teamplaytargetidsmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		end
	end

	if not self.DeniedAccess and self.NextRequest < CurTime() then
		MySelf:ConCommand("reqinfo "..self:EntIndex())
		self.NextRequest = CurTime() + 0.75
	end
end

local matBeam = Material("effects/laser1")
local matGlow = Material("sprites/light_glow02_add")
function ENT:Draw()
	self:DrawModel()

	if self:GetSkin() == 1 then
		if self.NextEmit <= CurTime() then
			self.NextEmit = CurTime() + 0.02 + EFFECT_IQUALITY * 0.015

			local startpos = self:GetPos() + self:GetUp() * 34
			local partpos = startpos + self:GetForward() * -30 + VectorRand():GetNormal() * math.Rand(4, 24)
			local particle = self.Emitter:Add("sprites/glow04_noz", partpos)
			particle:SetVelocity((startpos - partpos):GetNormal() * math.Rand(44, 54))
			particle:SetDieTime(math.Rand(0.9, 1.1))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(200)
			particle:SetStartSize(math.Rand(13, 17))
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-4, 4))
			particle:SetColor(100, 100, 255)
			particle:SetCollide(true)
			particle:SetBounce(0.75)
		end
	else
		local start = self:GetPos() + self:GetUp() * 34
		render.SetMaterial(matBeam)
		local endpos = start + self:GetForward() * -48
		local tr = util.TraceLine({start=start, endpos=endpos, filter=self})
		local trent = tr.Entity
		if 0 < tr.Fraction and trent:IsValid() and trent:GetClass():lower() == "obelisk" then
			render.DrawBeam(start, tr.HitPos, 4, 1, 0, COLOR_LIMEGREEN)
			render.SetMaterial(matGlow)
			render.DrawSprite(tr.HitPos, 16, 16, COLOR_LIMEGREEN)
		else
			render.DrawBeam(start, tr.HitPos, 4, 1, 0, COLOR_RED)
			render.SetMaterial(matGlow)
			render.DrawSprite(tr.HitPos, 16, 16, COLOR_RED)
		end
	end

	if GAMEMODE.EyeTraceEntity == self then
		local start = self:GetPos() + self:GetUp() * 34
		local endpos = start + self:GetForward() * 32000
		local tr = util.TraceLine({start=start, endpos=endpos, filter=self})
		local trent = tr.Entity
		local TargetCapacitor = trent:IsValid() and trent.CanTakeMana
		render.SetMaterial(matBeam)
		if TargetCapacitor then
			render.DrawBeam(start, tr.HitPos, 4, 1, 0, COLOR_LIMEGREEN)
			render.SetMaterial(matGlow)
			render.DrawSprite(tr.HitPos, 16, 16, COLOR_LIMEGREEN)
		else
			render.DrawBeam(start, tr.HitPos, 4, 1, 0, COLOR_RED)
			render.SetMaterial(matGlow)
			render.DrawSprite(tr.HitPos, 16, 16, COLOR_RED)
		end
	end
end
