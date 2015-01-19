function EFFECT:Init(data)
	self.DieTime = CurTime() + 1
	local pos = data:GetOrigin()
	local normal = data:GetNormal() * -1
	self.Pos = pos + normal * 0.5
	self.Normal = normal

	util.Decal("Impact.Concrete", pos + normal, pos - normal)
	sound.Play("ambient/energy/weld"..math.random(1,2)..".wav", pos, 70, math.Rand(230, 255))
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

local matSprite = Material("noxctf/sprite_nova")
function EFFECT:Render()
	render.SetMaterial(matSprite)
	render.DrawQuadEasy(self.Pos, self.Normal, 32, 32, Color(255, 255, 255, math.max(0, (self.DieTime - CurTime()) * 255)), CurTime() * 90)
end
