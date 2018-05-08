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
	local Pos = data:GetOrigin() + Vector(0, 0, 1)
	self.EndPos = Pos
	self.DieTime = RealTime() + 2
	self.StartPos = Pos + Vector(0, 0, 22500)
	self.EndPos = util.TraceLine({start=Pos, endpos=Pos + Vector(0, 0, -40000), mask=MASK_SOLID}).HitPos
	local epos = Vector(Pos.x, Pos.y, Pos.z)
	epos.z = epos.z + 5120
	self.Entity:SetRenderBoundsWS(self:GetPos(), epos)

	local teamid = data:GetScale()
	self.Magnitude = data:GetMagnitude()

	if teamid ~= MySelf:Team() and self.Magnitude > 0 then
		local eyepos = MySelf:EyePos()
		local aimvec = MySelf:GetAimVector()

		local dist = Pos:Distance(eyepos)
		if dist < 150 then
			local power = (150 - dist) * 0.01
			power = power * aimvec:Distance((eyepos - Pos):GetNormal())

			EndFlash = CurTime() + power
			MySelf:DI(NameToSpell["Sun Beam"], power)
			MySelf:SetDSP(32)
			hook.Add("RenderScreenspaceEffects", "FlashEffect", FlashColorModify)
		end
	end

	local emitter = ParticleEmitter(Pos)
	emitter:SetNearClip(24, 32)

	--big firecloud
	for i=1, 12 * EFFECT_QUALITY do
		local particle = emitter:Add("particles/flamelet2", Pos + Vector(math.random(-80,80),math.random(-80,80),math.random(0,180)))
		particle:SetVelocity(Vector(math.random(-6,16),math.random(-6,16),math.random(15,40)))
		particle:SetDieTime(math.Rand(2, 3.7))
		particle:SetStartAlpha(math.Rand(220, 240))
		particle:SetStartSize(18)
		particle:SetEndSize(math.Rand(26, 29))
		particle:SetRoll(math.Rand(0, 359))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetAirResistance(20)
	end

	--small firecloud
	for i=1, 13 do
		local particle = emitter:Add("particles/flamelet1", Pos + Vector(math.random(-40,40),math.random(-40,40),math.random(-30,50)))
		particle:SetVelocity(Vector(math.random(-12,15),math.random(-12,15),math.random(17,27)))
		particle:SetDieTime(math.Rand(2, 3.4))
		particle:SetStartAlpha(math.Rand(220, 240))
		particle:SetStartSize(3)
		particle:SetEndSize(math.Rand(22, 26))
		particle:SetRoll(math.Rand(0, 359))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetAirResistance(20)
	end

	for i=1, 5 do
		local particle = emitter:Add("particles/flamelet1", Pos + Vector(math.random(-30,30),math.random(-30,30),math.random(-40,50)))
		particle:SetVelocity(Vector(math.random(-6,6),math.random(-6,6),math.random(3,7)))
		particle:SetDieTime(math.Rand(2, 3.4))
		particle:SetStartAlpha(math.Rand(220, 240))
		particle:SetStartSize(3)
		particle:SetEndSize(math.Rand(23, 26))
		particle:SetRoll(math.Rand(0, 359))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetAirResistance(20)
	end

	--base explosion
	for i=1, math.max(3, 3.5 * EFFECT_QUALITY) do
		local particle = emitter:Add("particles/flamelet3", Pos + Vector(math.random(-40,40),math.random(-40,40),math.random(10,170)))
		particle:SetVelocity(Vector(math.random(-40,40),math.random(-40,40),math.random(-2,18)))
		particle:SetDieTime(math.Rand(2, 2.7))
		particle:SetStartAlpha(math.Rand(220, 240))
		particle:SetStartSize(5)
		particle:SetEndSize(math.Rand(17, 19))
		particle:SetRoll(math.Rand(0,359))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetAirResistance(20)
	end

	--smoke puff
	for i=1, 10 do
		local particle = emitter:Add("noxctf/sprite_smoke", Pos + Vector(math.random(-40,40),math.random(-40,40),math.random(-30,10)))
		particle:SetVelocity(Vector(math.random(-18,18),math.random(-18,18),math.random(0,48)))
		particle:SetDieTime(math.Rand(3.9, 4.3))
		particle:SetStartAlpha(math.Rand(205, 255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(42, 68))
		particle:SetEndSize(math.Rand(192, 256))
		particle:SetRoll(math.Rand(0, 359))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetColor(170, 160, 160)
	end

	--big smoke cloud
	for i=1, 3 do
		local particle = emitter:Add("noxctf/sprite_smoke", Pos + Vector(math.random(-30,30),math.random(-30,30),math.random(10,100)))
		particle:SetVelocity(Vector(math.random(-280,280),math.random(-280,280),math.random(64,320)))
		particle:SetDieTime(math.Rand(3.5, 4.7))
		particle:SetStartAlpha(math.Rand(60, 80))
		particle:SetStartAlpha(math.Rand(60, 80))
		particle:SetStartSize(math.Rand(3, 8))
		particle:SetEndSize(math.Rand(19, 25))
		particle:SetRoll(math.Rand(0,359))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetColor(170, 170, 170)
	end

	for i=1, 6 do
		local particle = emitter:Add("noxctf/sprite_smoke", Pos + Vector(math.random(-40,40),math.random(-40,50),math.random(20,280)))
		particle:SetVelocity(Vector(math.random(-180,180),math.random(-180,180),math.random(60,140)))
		particle:SetDieTime(math.Rand(3.5, 4.7))
		particle:SetStartAlpha(math.Rand(140, 160))
		particle:SetStartSize(math.Rand(3, 4))
		particle:SetEndSize(math.Rand(19, 25))
		particle:SetRoll(math.Rand(0, 359))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetColor(170, 170, 170)
	end

	-- small smoke cloud
	for i=1, 8 do
		local particle = emitter:Add("noxctf/sprite_smoke", Pos + Vector(math.random(-200,200),math.random(-200,200),math.random(5,10)))
		particle:SetVelocity(Vector(math.random(-20,20),math.random(-20,20),math.random(-2,20)))
		particle:SetDieTime(math.Rand(3.1, 4.4))
		particle:SetStartAlpha(math.Rand(200, 255))
		particle:SetStartSize(math.Rand(4, 7))
		particle:SetEndSize(math.Rand(19, 27))
		particle:SetRoll(math.Rand(480, 540))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetColor(170, 170, 170)
	end

	emitter:Finish()

	ExplosiveEffect(Pos, 150, 75, DMGTYPE_FIRE)

	util.Decal("Scorch", Pos, Pos + Vector(0, 0, -1))
end

function EFFECT:Think()
	return RealTime() < self.DieTime
end

local matBeam = Material("effects/laser1")
local matGlow = Material("sprites/light_glow02_add")
local colBeam = Color(255, 255, 127, 255)

// Kind of out did myself on this one.
function EFFECT:Render()
	local delta = self.DieTime - RealTime()
	local size

	if delta > 1 then
		size = (120 + self.Magnitude * 250) + (1 - delta) * 70
	else
		size = delta * (120 + self.Magnitude * 250)
	end

	render.SetMaterial(matBeam)
	render.DrawBeam(self.StartPos, self.EndPos, size, 3, 0, colBeam)
	render.DrawBeam(self.StartPos, self.EndPos, size, 3, 0, colBeam)
	render.DrawBeam(self.StartPos, self.EndPos, size, 3, 0, colBeam)
	local size2 = math.min(size, 32)
	render.DrawBeam(self.StartPos, self.EndPos, size2, 3, 0, color_white)
	render.DrawBeam(self.StartPos, self.EndPos, size2, 3, 0, color_white)
	render.DrawBeam(self.StartPos, self.EndPos, size2, 3, 0, color_white)

	local spritepos = self.EndPos + Vector(0, 0, 64)
	render.SetMaterial(matGlow)
	render.DrawSprite(spritepos, math.max(48, size * 2.5), size, color_white)
	render.DrawSprite(spritepos, math.max(64, size * 3.25), size * 1.25, colBeam)

	local sunsize = size * 32 + 256
	local sunsizewhite = size * 28 + 256
	render.DrawSprite(self.StartPos, sunsizewhite, sunsizewhite, color_white)
	render.DrawSprite(self.StartPos, sunsize, sunsize, colBeam)
	render.DrawSprite(self.StartPos, sunsizewhite, sunsizewhite, color_white)
	render.DrawSprite(self.StartPos, sunsize, sunsize, colBeam)

	local othersize = size * 4
	local meeting = self.StartPos + Vector(0, 0, -4098)
	local ax = self.StartPos + Vector(0, 1024, -4098)
	render.DrawBeam(self.StartPos, ax, othersize, 3, 0, colBeam)
	render.DrawBeam(ax, meeting, othersize, 3, 0, colBeam)
	ax = self.StartPos + Vector(0, -1024, -4098)
	render.DrawBeam(self.StartPos, ax, othersize, 3, 0, colBeam)
	render.DrawBeam(ax, meeting, othersize, 3, 0, colBeam)
	ax = self.StartPos + Vector(-1024, 0, -4098)
	render.DrawBeam(self.StartPos, ax, othersize, 3, 0, colBeam)
	render.DrawBeam(ax, meeting, othersize, 3, 0, colBeam)
	ax = self.StartPos + Vector(1024, 0, -4098)
	render.DrawBeam(self.StartPos, ax, othersize, 3, 0, colBeam)
	render.DrawBeam(ax, meeting, othersize, 3, 0, colBeam)
	ax = self.StartPos + Vector(1024, 1024, -4098)
	render.DrawBeam(self.StartPos, ax, othersize, 3, 0, colBeam)
	render.DrawBeam(ax, meeting, othersize, 3, 0, colBeam)
	ax = self.StartPos + Vector(-1024, -1024, -4098)
	render.DrawBeam(self.StartPos, ax, othersize, 3, 0, colBeam)
	render.DrawBeam(ax, meeting, othersize, 3, 0, colBeam)
	ax = self.StartPos + Vector(1024, -1024, -4098)
	render.DrawBeam(self.StartPos, ax, othersize, 3, 0, colBeam)
	render.DrawBeam(ax, meeting, othersize, 3, 0, colBeam)
	ax = self.StartPos + Vector(-1024, 1024, -4098)
	render.DrawBeam(self.StartPos, ax, othersize, 3, 0, colBeam)
	render.DrawBeam(ax, meeting, othersize, 3, 0, colBeam)

	if delta > 1 then
		local pos = self.EndPos

		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(24, 32)

		for i=1, math.random(4, 16) do
			local particle = emitter:Add("sprites/light_glow02_add", pos)
			local particleVel = Vector(math.random(-80, 80), math.random(-80, 80), 0):GetNormal() * math.Rand(64, 80)
			particle:SetVelocity(particleVel)
			particle:SetDieTime(math.Rand(1.5, 2.5))
			particle:SetStartAlpha(math.Rand(200, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.random(9, 14))
			particle:SetEndSize(0)
			particle:SetRoll(math.random(0, 359))
			particle:SetRollDelta(math.Rand(-3, 3))
			local brightness = math.random(100, 180)
			particle:SetGravity(Vector(0, 0, 250))
			particle:SetCollide(true)
			particle:SetBounce(0.25)
			particle:SetColor(255, brightness * 0.7, brightness * 0.35)
		end

		emitter:Finish()
	end
end
