include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
end

function ENT:Think()
end

function ENT:OnRemove()
end

function ENT:Draw()
	if self:GetModel() == "models/error.mdl" then return end

	local seat = self:GetOwner()

	if seat:IsValid() then
		local driver = NULL
		for _, pl in pairs(player.GetAll()) do if pl:GetVehicle() == seat then driver = pl end end
		if driver:IsValid() then
			local ang = driver:GetAimVector():Angle()
			ang:RotateAroundAxis(ang:Forward(), -90)
			ang:RotateAroundAxis(ang:Right(), -90)
			self:SetAngles(ang)
		else
			local ang = seat:GetAngles()
			ang:RotateAroundAxis(ang:Forward(), -90)
			self:SetAngles(ang)
		end

		self:DrawModel()
	end
end
