include("shared.lua")

ENT.PickupName = "Crossbow"

function ENT:Draw()
	self:DrawModel()
end

ENT.MaxTraceHUDPaintLength = 512

function ENT:TraceHUDPaint()
	local c = self:GetColor()
	if c.a == 0 then return end
	draw.SimpleText(self.PickupName, "teamplay", w*0.5, h*0.5, Color(0,200,255,255), TEXT_ALIGN_CENTER)
	if self:CanUse(MySelf:GetClassTable().Name) then
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
