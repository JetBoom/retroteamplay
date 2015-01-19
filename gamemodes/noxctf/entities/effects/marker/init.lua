MARKEFFECT = nil

function EFFECT:Init(data)
	local ent = data:GetEntity()
	if ent ~= MySelf then return end
	if data:GetMagnitude() == 1 then
		self.Entity.Live = false
		if MARKEFFECT then
			MARKEFFECT.Live = false
			MARKEFFECT = nil
		end
		return
	end
	self.DrawPos = data:GetOrigin()
	self.Pos = self.DrawPos + Vector(0,0,12)
	LM(32)
	if MARKEFFECT then
		MARKEFFECT.Live = false
	end
	MARKEFFECT = self.Entity
	self.Entity.Live = true
	self.Rotation = 0
end

function EFFECT:Think()
	return self.Entity.Live and MySelf:Alive()
end

local matGlow = Material("sprites/light_glow02_add")
local matMark = Material("spellicons/marklocation1.png")

function EFFECT:Render()
	if not self.Entity.Live then return end
	local pos = self.Pos

	local qsize = 32 + math.sin(RealTime()*5) * 8
	render.SetMaterial(matMark)
	render.DrawQuadEasy(self.DrawPos, Vector(0,0,1), qsize, qsize, color_white)
	render.DrawQuadEasy(self.DrawPos, Vector(0,0,-1), qsize, qsize, color_white)

	self.Rotation = self.Rotation + FrameTime() * 5
	if self.Rotation > 360 then self.Rotation = 0 end
	render.SetMaterial(matGlow)
	for i=0, 20 do
		local space = 24 + math.sin(RealTime()*2) * (8 + i)
		local rot = self.Rotation + i * 18
		local vOffset = Vector(space * math.sin(rot), space * math.cos(rot), i * 3.6)
		local size = 10 + i * math.sin(RealTime()) * 3
		render.DrawSprite(pos + vOffset, size, size, COLOR_CYAN)
	end
end
