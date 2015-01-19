function EFFECT:Think()
	return RealTime() < self.DieTime
end

local MDFEnd = 0
local function DrawMDF()
	if MDFEnd < CurTime() or not MySelf:InVehicle() then
		hook.Remove("HUDPaint", "DrawMDF")
	else
		surface.SetFont("teamplay")
		local txtw, txth = surface.GetTextSize("Hit with MDB! Rebooting controls... 10000%")
		surface.SetDrawColor(0,0,0,180)
		surface.DrawRect(w * 0.5 - txtw * 0.5, h * 0.4 - txth * 0.5, txtw, txth)
		surface.SetDrawColor(255,0,0,180)
		surface.DrawOutlinedRect(w * 0.5 - txtw * 0.5, h * 0.4 - txth * 0.5, txtw, txth)
		draw.SimpleText("Hit with MDB! Rebooting weapon systems... ".. math.min(100, math.floor(100 - (MDFEnd - CurTime()) * 50)) .."%", "DefaultBold", w * 0.5, h * 0.4, Color(255, 0, 0, 185 + math.sin(RealTime()*8) * 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local sndMDF = file.Exists("sound/ambient/energy/powerdown2.wav", "MOD") and "ambient/energy/powerdown2.wav" or "vehicles/tank_readyfire1.wav"
function EFFECT:Init(data)
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	local effectdata = EffectData()
		effectdata:SetOrigin(self.EndPos)
	util.Effect("manashardbombexplode", effectdata)
	local ent = data:GetEntity()

	self.Dir = self.EndPos - self.StartPos

	self.HitNormal = util.TraceLine({start=self.EndPos, endpos=self.EndPos + self.Dir}).HitNormal or Vector(0,0,1)

	self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos, Vector(256, 256, 256))

	self.DieTime = RealTime() + 0.6

	sound.Play("nox/lightning_impact.ogg", self.EndPos, 88, math.random(95, 110))
	sound.Play("nox/shocked.ogg", self.StartPos, 88, math.random(75, 90))
	sound.Play("nox/shocked.ogg", self.StartPos, 88, math.random(75, 90))

	self.BeamPos = {}
	local pos = nil
	local dist = self.StartPos:Distance(self.EndPos)
	local segments = math.ceil(dist / 50)
	local realsegments = math.min(segments, math.max(20, 50 * EFFECT_QUALITY))
	local div = 50
	if segments ~= realsegments then
		div = dist / realsegments
	end

	for i=1, math.ceil(dist / div) do
		if pos then
			pos = pos + (self.EndPos - pos):GetNormal() * div
		else
			pos = self.StartPos
		end
		table.insert(self.BeamPos, pos)
	end

	if ent:IsValid() and MySelf:IsValid() then
		ent:EmitSound(sndMDF)

		local veh = MySelf:GetVehicle()
		if veh:IsValid() and veh:GetDTEntity(0) == ent then
			MDFEnd = CurTime() + 5
			surface.PlaySound(sndMDF)
			hook.Add("HUDPaint", "DrawMDF", DrawMDF)
		end
	end

	ExplosiveEffect(self.EndPos, 42, 20, DMGTYPE_LIGHTNING)
end

local matBeam = Material("Effects/laser1")
function EFFECT:Render()
	render.SetMaterial(matBeam)

	local size = (self.DieTime - RealTime()) * 200

	render.DrawBeam(self.StartPos, self.EndPos, size, 1, 0, COLOR_CYAN)

	for i, pos in ipairs(self.BeamPos) do
		for x=1, 3 do
			if self.BeamPos[i+1] then
				render.DrawBeam(pos, self.BeamPos[i+1], size * 0.25, 8, 8, COLOR_CYAN)
			else
				render.DrawBeam(pos, self.EndPos, size * 0.25, 8, 8, COLOR_CYAN)
			end
			self.BeamPos[i] = self.BeamPos[i] + VectorRand() * 5
		end
	end
end
