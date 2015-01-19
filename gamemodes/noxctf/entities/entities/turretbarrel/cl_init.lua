include("shared.lua")

function ENT:AlignTo(turret, attach)
	local skin = self:GetSkin()
	if skin == 0 then
		self:SetPos(attach.Pos)
		self:SetAngles(attach.Ang)
		self:SetModelScale(0.5, 0)
	elseif skin == 1 then
		self:SetPos(attach.Pos + attach.Ang:Forward() * -6)
		local ang = attach.Ang
		ang:RotateAroundAxis(ang:Right(), -90)
		--ang.pitch = math.NormalizeAngle(ang.pitch + 90)
		self:SetAngles(ang)
		self:SetModelScale(0.5, 0)
	elseif skin == 2 then
		self:SetPos(attach.Pos + attach.Ang:Forward() * -3)
		self:SetAngles(attach.Ang)
		self:SetModelScale(0.2, 0)
	elseif skin == 3 then
		self:SetPos(attach.Pos)
		self:SetAngles(attach.Ang)
		self:SetModelScale(0.5, 0)
	end
end

function ENT:Draw()
	local turret = self:GetOwner()
	if turret:IsValid() then
		local attach = turret:GetAttachment(2)
		if attach then
			self:AlignTo(turret, attach)
		end
		self:DrawModel()
	end
end
