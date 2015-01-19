AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusShouldRemove(owner)
	return owner:GetPlayerClassTable().PoisonImmune
end

ENT.Jumped = true -- used to keep track of whether or not the owner has jumped
ENT.Landed = true -- used to keep track of whether or not the owner has left the ground at all

ENT.Threshold = 50 -- if the odometer has passed this number then update the threshold
ENT.Odometer = 0 -- how far the owner has travelled on the ground
function ENT:Move(pl, move)
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	if pl ~= owner then return end

	if not self.LastPos or self.LastPos:Distance(owner:GetPos()) > 200 then
		self.LastPos = owner:GetPos()
	end

	-- we don't want gaps in the odometer when the owner leaves the ground so update their last position before calculating anything else when they land
	if pl:OnGround() and not self.Landed then
		self.Landed = true
		self.LastPos = owner:GetPos()
	elseif not pl:OnGround() then
		self.Landed = false
	end

	if not pl:OnGround() then return end

	if move:KeyDown(IN_JUMP) and not self.Jumped then
		self.Jumped = true
		pl:TakeSpecialDamage(self.JumpDamage, DMGTYPE_POISON, self.Attacker, self)
	elseif not move:KeyDown(IN_JUMP) then
		self.Jumped = false
	end
	
	self.Odometer = self.Odometer + self.LastPos:Distance(owner:GetPos())

	if self.Odometer >= self.Threshold then
		self.Threshold = self.Threshold + self.DistanceThreshold
		pl:TakeSpecialDamage(self.WalkDamage, DMGTYPE_POISON, self.Attacker, self)
	end

	self.LastPos = owner:GetPos()
end