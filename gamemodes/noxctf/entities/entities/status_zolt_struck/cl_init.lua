include("shared.lua")

-- TODO: This doesn't need an entire entity dedicated to this.

function ENT:StatusInitialize()
	self.DieTime = CurTime() + 2
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 128))
	local dtime = self.DieTime
	if MySelf == self:GetOwner() then
		MySelf:SetDSP(35)
		hook.Add("HUDPaint","ZoltBlind", function()
			local alpha = math.max(0,(CurTime() > dtime-1) and ( dtime - CurTime() )*255 or 255)
			surface.SetDrawColor( 255, 255, 255, alpha)
			surface.DrawRect(0, 0,ScrW() , ScrH() )
		end)
	end
end

function ENT:StatusOnRemove(owner)
	if MySelf == owner then
		self:GetOwner():SetDSP(1)
		hook.Remove("HUDPaint", "ZoltBlind")
	end
end