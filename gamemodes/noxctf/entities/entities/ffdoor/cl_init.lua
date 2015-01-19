include("shared.lua")

function ENT:Initialize()
	--self:SetMaterial("models/props_combine/stasisshield_sheet")
	self:SetMaterial("models/debug/debugwhite")
end

function ENT:Draw()
	--[[if 2 < EFFECT_QUALITY then
		self:SetMaterial("models/props_combine/stasisshield_sheet")
	else
		self:SetMaterial("models/debug/debugwhite")
	end]]
	self:DrawModel()
end
