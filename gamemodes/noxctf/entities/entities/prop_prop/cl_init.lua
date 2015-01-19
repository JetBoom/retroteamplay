include("shared.lua")

ENT.NextRequest = 0
ENT.MaxTraceHUDPaintLength = 256

function ENT:Initialize()
	if not self.Name then
		local mdl = string.lower(self:GetModel())
		for _, typ in pairs(PROPTYPES) do
			if string.lower(typ.Model) == mdl then
				self.Name = typ.Name
			end
		end
	end
end

function ENT:Info(um)
	local str = um:ReadString()
	if str == "deny" then
		self.DeniedAccess = true
		return
	end

	local stuff = string.Explode(",", str)
	self.PHealth = tonumber(stuff[1]) or 0
	self.MaxPHealth = tonumber(stuff[2]) or 1
end

function ENT:TraceHUDPaint()
	GAMEMODE:GenericPropHealthBar(self)

	if not self.DeniedAccess and CurTime() >= self.NextRequest then
		MySelf:ConCommand("ReqInfo "..self:EntIndex())
		self.NextRequest = CurTime() + 0.75
	end
end
