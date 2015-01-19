include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())

	if MySelf == self:GetOwner() and not MySelf:GetPlayerClassTable().PoisonImmune then
		hook.Add("HUDPaintBackground", self, self.HUDPaintBackground)
		hook.Add("RenderScreenspaceEffects", self, self.RenderScreenspaceEffects)
	end
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	if owner:IsInvisible() then return end

	local pos
	if owner ~= MySelf or (owner == MySelf and owner:ShouldDrawLocalPlayer()) then
		local attach = owner:GetAttachment(owner:LookupAttachment("mouth"))
		if attach then
			pos = attach.Pos
		end
	end

	if pos then
		local a = owner:GetVisibility()

		local emitter = self.Emitter
		for i=1, 2 do
			particle = emitter:Add("sprites/light_glow02_add", pos + VectorRand())
			particle:SetDieTime(0.6)
			particle:SetStartAlpha(a)
			particle:SetEndAlpha(a * 0.25)
			particle:SetStartSize(3)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-0.8, 0.8))
			particle:SetColor(30, 255, 30)
			particle:SetAirResistance(75)
			particle:SetGravity(Vector(0, 0, -200))
			particle:SetCollide(true)
		end
	end
end

local cmtab = {["$pp_colour_brightness"] = -.1, ["$pp_colour_contrast"] = .8, ["$pp_colour_colour"] = 1, ["$pp_colour_addr"] = 44/255, ["$pp_colour_addg"] = 125/255, ["$pp_colour_addb"] = 31/255}
function ENT:RenderScreenspaceEffects()
	DrawColorModify(cmtab)
end

function ENT:HUDPaintBackground()
	local ang = EyeAngles()
	ang.r = ang.r + 3*math.sin((CurTime()) * 3.15)*2
	local camdata = {angles = ang}
	render.RenderView(camdata)
end