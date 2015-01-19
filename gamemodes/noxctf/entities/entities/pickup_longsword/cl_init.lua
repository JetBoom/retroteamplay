include("shared.lua")

function ENT:Draw()
	self:SetModelScale(1.3, 0)
	self:DrawModel()
end

ENT.MaxTraceHUDPaintLength = 512

function ENT:TraceHUDPaint()
	local c = self:GetColor()
	if c.a == 0 then return end
	draw.SimpleText("Long Sword", "teamplay", w*0.5, h*0.5, COLOR_CYAN, TEXT_ALIGN_CENTER)
	if MySelf:GetPlayerClassTable().Name == "Warrior" then
		local _, hhh = surface.GetTextSize("A")
		draw.SimpleText("(Pick up with USE key)", "teamplay", w*0.5, h*0.5 + hhh, color_white, TEXT_ALIGN_CENTER)
	end
end
