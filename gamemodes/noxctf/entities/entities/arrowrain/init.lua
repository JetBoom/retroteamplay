AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
	self.DeathTime = CurTime() + 1
	self:DrawShadow(false)
	self:SetNoDraw(true)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0.05)
		phys:Wake()
	end
	
	self.Arrows = 0
	self.NextArrow = 0
	self.Size = 280
	
	local owner = self:GetOwner()
	local pos = self:GetPos()
	
	for k,v in pairs(ents.FindInBox(pos + Vector(-self.Size*0.5,-self.Size*0.5,-6000),pos + Vector(self.Size*0.5,self.Size*0.5,0))) do
		if v:IsPlayer() then
			if v:Team() ~= owner:Team() and v:Alive() then
				local arrowpos = v:GetPos() + Vector(0,0,self:GetPos().z - v:GetPos().z)
				local arrow = ents.Create("projectile_volleyarrowbolt")
				if arrow:IsValid() then
					arrow:SetPos(arrowpos)
					arrow:SetAngles(Angle(90,0,0))
					arrow:SetOwner(owner)
					arrow.Damage = 20
					local teamid = owner:Team()
					local col = team.GetColor(owner:Team())
					arrow:SetColor(Color(col.r, col.g, col.b, 255))
					arrow:Spawn()
					arrow:SetTeamID(teamid)
					local phys = arrow:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocityInstantaneous(Vector(0,0,-1)*1500)
					end
				end
			end
		end
	end
end

function ENT:Think()
	local owner = self:GetOwner()
	if self.Arrows < 10 then
		if self.NextArrow < CurTime() then
			self.Arrows = self.Arrows + 2
			self.NextArrow = CurTime() + 0.05
			for i=1, 2 do
				local rVec = Vector(math.Rand(-1,1),math.Rand(-1,1),0) * self.Size
				local arrow = ents.Create("projectile_volleyarrowbolt")
				if arrow:IsValid() then
					arrow:SetPos(self:GetPos() + rVec)
					arrow:SetAngles(Angle(90,0,0))
					arrow:SetOwner(owner)
					arrow.Damage = 15
					local teamid = owner:Team()
					local col = team.GetColor(teamid)
					arrow:SetColor(Color(col.r, col.g, col.b, 255))
					arrow:Spawn()
					arrow:SetTeamID(teamid)
					local phys = arrow:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocityInstantaneous(Vector(0,0,-1)*1500)
					end
				end
			end
		end
	else
		self:Remove()
	end
end
