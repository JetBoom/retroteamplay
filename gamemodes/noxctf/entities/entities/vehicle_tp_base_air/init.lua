AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.Acceleration = 0

function ENT:PhysicsSimulate(phys, frametime)
	phys:Wake()

	local driver = self:GetDriver()
	local driverisvalid = driver:IsValid()
	local vel = phys:GetVelocity()
	local newangles = phys:GetAngles()
	local forward = newangles:Forward()
	local dotheading = math.max(vel:GetNormalized():Dot(forward), 0)
	local maxspeed = driverisvalid and math.Clamp(dotheading, 0.25, 1) * self.MaxSpeed or self.MaxSpeed
	local hovering = false

	if driverisvalid and driver:KeyDown(IN_FORWARD) then
		self.Acceleration = math.Approach(self.Acceleration, self.MaxAcceleration, self.AccelerationRate * frametime)
	else
		self.Acceleration = math.Approach(self.Acceleration, 0, self.DeaccelerationRate * frametime)
	end

	if driverisvalid and driver:KeyDown(IN_FORWARD) then
		vel = vel * math.max(1 - frametime * self.DampingFactor * (1 - dotheading), 0)
	else
		vel = vel * math.max(1 - frametime * self.InactiveDampingFactor * (1 - dotheading), 0)
	end

	vel = vel + frametime * self.Acceleration * (3 - dotheading * 2) * forward

	if vel:Length() > maxspeed then
		vel = vel:GetNormalized() * maxspeed
	end

	if self.HoverSpeed > 0 and vel:Length() <= self.HoverSpeed then
		local trace = {mask = MASK_HOVER, filter = self}
		trace.start = self:GetPos()
		trace.endpos = trace.start + Vector(0, 0, -self.HoverHeight)
		local tr = util.TraceLine(trace)

		if tr.Hit then
			hovering = true

			vel = vel + frametime * (1 - tr.Fraction) * self.HoverForce * (trace.start - tr.HitPos):GetNormalized()

			local diffangles2 = self:WorldToLocalAngles(Angle(0, newangles.yaw, 0))
			newangles:RotateAroundAxis(newangles:Forward(), math.Clamp(diffangles2.roll, -90, 90) * frametime * 2)
			newangles:RotateAroundAxis(newangles:Right(), math.Clamp(diffangles2.pitch, -90, 90) * frametime * -1)

			if driverisvalid then
				local diffangles = self:WorldToLocalAngles(driver:EyeAngles())
				newangles:RotateAroundAxis(newangles:Up(), math.Clamp(diffangles.yaw, -90, 90) * frametime)
			end
		end
	end

	if not hovering and driverisvalid then
		local speed = self:GetRotationSpeedMultiplier() * frametime

		if driver:KeyDown(IN_MOVELEFT) then
			newangles:RotateAroundAxis(newangles:Forward(), -self.RollSpeed * speed)
		end

		if driver:KeyDown(IN_MOVERIGHT) then
			newangles:RotateAroundAxis(newangles:Forward(), self.RollSpeed * speed)
		end

		local diffangles = self:WorldToLocalAngles(driver:EyeAngles())
		newangles:RotateAroundAxis(newangles:Right(), math.Clamp(diffangles.pitch, -90, 90) * speed * -self.TurnSpeed)
		newangles:RotateAroundAxis(newangles:Up(), math.Clamp(diffangles.yaw, -90, 90) * speed * self.TurnSpeed)
	end

	phys:SetAngleDragCoefficient((driverisvalid or hovering) and 2000000 or 1)
	phys:EnableGravity(self.Acceleration == 0 and not hovering)
	self:SetAngles(newangles)
	phys:SetVelocityInstantaneous(vel)

	return SIM_NOTHING
end

function ENT:GetRotationSpeedMultiplier()
	return math.Clamp(self.Acceleration / self.MaxAcceleration, 0.5, 1)
end
