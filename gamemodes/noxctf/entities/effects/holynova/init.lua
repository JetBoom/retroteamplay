function EFFECT:Think()
	return CurTime() < self.DieTime
end

local EndFlash = 0
local cmtab = {["$pp_colour_brightness"] = 1, ["$pp_colour_contrast"] = 1, ["$pp_colour_colour"] = 1}
local function FlashColorModify()
	cmtab["$pp_colour_brightness"] = math.max(0, math.min(5, EndFlash - CurTime()))
	DrawColorModify(cmtab)

	if cmtab["$pp_colour_brightness"] <= 0 then
		MySelf:SetDSP(0)
		hook.Remove("RenderScreenspaceEffects", "FlashEffect")
	end
end

function EFFECT:Init(data)
	local normal = data:GetNormal() * -1
	local pos = data:GetOrigin()
	local teamid = data:GetScale()
	local owner = data:GetEntity()

	if teamid ~= MySelf:Team() then
		local eyepos = MySelf:EyePos()
		local aimvec = MySelf:GetAimVector()

		local dist = pos:Distance(eyepos)
		if dist < 250 then
			local power = (250 - dist) * 0.01
			power = power * aimvec:Distance((eyepos - pos):GetNormal())

			EndFlash = CurTime() + power
			MySelf:DI(NameToSpell["Holy Nova"], power)
			MySelf:SetDSP(32)
			hook.Add("RenderScreenspaceEffects", "FlashEffect", FlashColorModify)
		end
	end

	self.DieTime = CurTime() + 0.5

	util.Decal("FadingScorch", pos - normal, pos + normal)

	sound.Play("ambient/machines/thumper_hit.wav", pos, 77, 255, 1)

	self.Pos = pos
	self.Normal = normal
	self.Col = Color(255, 255, 0, 255)

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(28, 36)
	self.Emitter = emitter
	
	local particles = {}
	for i=0, math.Rand(200, 250) do
		local heading = VectorRand()

		local particle = emitter:Add("effects/yellowflare", pos)
		particle:SetVelocity(heading * 2200)
		particle:SetDieTime(.5)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(200)
		particle:SetStartSize(math.Rand(48, 64))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-75, 75))
		particle:SetAirResistance(400)
		particle:SetColor(255, 255, 0)
		particle:SetCollide(true)

		particles[#particles + 1] = particle
	end
	emitter:Finish()

	self.Particles = particles
end

local matGlow = Material("sprites/glow04_noz")
local matBeam = Material("Effects/laser1")
function EFFECT:Render()
	local pos = self.Pos
	local normal = self.Normal

	local delta = self.DieTime - CurTime()

	local size
	if 0.25 < delta then
		size = delta * 1024
	else
		size = 1024 - delta * 1024
	end

	local col = self.Col
	col.a = delta * 510

	render.SetMaterial(matGlow)
	render.DrawQuadEasy(pos, normal, size, size, col)
	render.DrawQuadEasy(pos, normal, size, size, col)
	render.DrawQuadEasy(pos, normal * -1, size, size, col)
	render.DrawQuadEasy(pos, normal * -1, size, size, col)
	render.DrawSprite(pos, size, size, col)
	render.DrawSprite(pos, size, size, col)
	
	render.SetMaterial(matBeam)

	local siz = (self.DieTime - CurTime()) * 64

	for i, particle in pairs(self.Particles) do
		if particle and math.random(1, 3) == 1 then
			render.DrawBeam(particle:GetPos(), pos, siz, 1, 0, COLOR_YELLOW)
		end
	end
end
