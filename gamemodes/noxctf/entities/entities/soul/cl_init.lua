include("shared.lua")

function ENT:Initialize()

	self:SetRenderBounds(Vector(-30, -30, -30), Vector(30, 30, 30))
	self:DrawShadow(false)
	
end


//placehodler from flag effect
local matGlow = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()

	if MySelf:GetPlayerClassTable().Name != "Necromancer" then return end

	local ent = self:GetOwner()
	if not IsValid(ent) then return end

	local pos = self:GetPos()
	
	pos = pos + vector_up * (math.sin(CurTime() * 4) * 5 + 10)
	
	local c = ent:GetPlayerColor() * 100
	
	local rsin = math.sin(CurTime() * 4) * 16
	local rcon = math.cos(CurTime() * 4) * 16
	local drawColor = Color(c.r, c.g, c.b, 255)
	local size =  math.cos(RealTime() * 5) * 60 + 140
	local minisize = math.sin(RealTime() * 7) * 40 + 60

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, size, size, drawColor)
	render.DrawSprite(pos, size*.5, size*.5, drawColor)
	render.DrawSprite(pos + Vector(rsin, rcon, 0), minisize, minisize, drawColor)
	render.DrawSprite(pos + Vector(0, rcon, rsin), minisize, minisize, drawColor)
	render.DrawSprite(pos + Vector(rcon, 0, rsin), minisize, minisize, drawColor)
	render.DrawSprite(pos - Vector(rcon, rsin, 0), minisize, minisize, drawColor)
	render.DrawSprite(pos - Vector(0, rsin, rcos), minisize, minisize, drawColor)
	render.DrawSprite(pos - Vector(rsin, 0, rcon), minisize, minisize, drawColor)
	
end