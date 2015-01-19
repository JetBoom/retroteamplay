include("shared.lua")

function ENT:Draw()
	self:SetModelScale(1.1, 0)
	self:DrawModel()
end

ENT.MaxTraceHUDPaintLength = 512

function ENT:TraceHUDPaint()
	local c = self:GetColor()
	if c.a == 0 then return end
	draw.SimpleText("Short Sword", "teamplay", w*0.5, h*0.5, COLOR_CYAN, TEXT_ALIGN_CENTER)
	local classname = MySelf:GetPlayerClassTable().Name
	if classname == "Warrior" or classname == "Dragoon" then
		local _, hhh = surface.GetTextSize("A")
		draw.SimpleText("(Pick up with USE key)", "teamplay", w*0.5, h*0.5 + hhh, color_white, TEXT_ALIGN_CENTER)
	end
end

function ENT:Initialize()
end

function ENT:Think()
end

function ENT:OnRemove()
end
