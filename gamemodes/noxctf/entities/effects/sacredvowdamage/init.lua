function EFFECT:Init(data)
	self.StartEnt = Entity(data:GetScale())
	self.EndEnt = data:GetEntity()
	self.Magnitude = data:GetMagnitude()
	self.DeathTime = CurTime() + .2
	self.Entity:SetRenderBounds(Vector(-1200, -1200, -1200), Vector(1200, 1200, 1200))
end

function EFFECT:Think()
	return CurTime() <= self.DeathTime
end

local matGlow = Material("sprites/glow04_noz")
function EFFECT:Render()
	local ent1 = self.StartEnt
	local ent2 = self.EndEnt
	if ent1:IsValid() and ent2:IsValid() then
		render.SetMaterial(matGlow)
		
		local delta = math.Clamp((self.DeathTime - CurTime()) / .2, 0, 1)
		
		local startpos = ent1:GetCenter() + Vector(0, 0, 10)
		local endpos = ent2:GetCenter() + Vector(0, 0, 10)
		
		local dist = startpos:Distance(endpos)
		local norm = (endpos - startpos):GetNormal()
		local mag = self.Magnitude
		
		render.DrawSprite(startpos + norm * dist * (1 - delta), mag * 5, mag * 5, COLOR_RED)
	end
end
