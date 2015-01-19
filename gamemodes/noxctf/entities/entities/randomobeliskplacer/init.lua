ENT.Type = "point"

function ENT:Initialize()
	self:Fire("place", "", 2)

	self.KeyValues = self.KeyValues or {}
	self.KeyValues.NumObeliskMin = self.KeyValues.NumObeliskMin or 2
	self.KeyValues.NumObeliskMax = self.KeyValues.NumObeliskMax or 3
	self.KeyValues.Radius = self.KeyValues.Radius or 1024
	self.KeyValues.MinRange = self.KeyValues.MinRange or 128
end

function ENT:KeyValue(key, value)
	if key == "numobeliskmin" then
		self.KeyValues.NumObeliskMin = tonumber(value) or self.KeyValues.NumObeliskMin or 2
	elseif key == "numobeliskmax" then
		self.KeyValues.NumObeliskMax = tonumber(value) or self.KeyValues.NumObeliskMax or 3
	elseif key == "radius" then
		self.KeyValues.Radius = tonumber(value) or self.KeyValues.Radius or 1024
	elseif key == "minrange" then
		self.KeyValues.MinRange = tonumber(value) or self.KeyValues.MinRange or 128
	end
end

function ENT:AcceptInput(name, activator, caller, args)
	if name == "place" then
		--self:Fire("kill", "", 1)

		local mypos = self:GetPos()

		for i=1, math.random(self.KeyValues.NumObeliskMin, self.KeyValues.NumObeliskMax) do
			for try=1, 64 do
				local vecsphere = Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0):GetNormal() * math.Rand(-self.KeyValues.Radius, self.KeyValues.Radius)

				local tr = util.TraceLine({start = mypos + vecsphere, endpos = mypos + vecsphere + self:GetUp() * -64000, mask = MASK_SOLID, filter = self})
				if tr.Hit then
					local foundobelisk = false
					for _, ent in pairs(ents.FindInSphere(tr.HitPos, self.KeyValues.MinRange)) do
						if ent:GetClass():lower() == "obelisk" then
							foundobelisk = true
							break
						end
					end

					if not foundobelisk then
						local ob = ents.Create("obelisk")
						if ob:IsValid() then
							ob:SetPos(tr.HitPos)
							local ang = tr.HitNormal:Angle()
							ang:RotateAroundAxis(ang:Right(), -90)
							ob:SetAngles(ang)
							ob:Spawn()
						end

						break
					end
				end
			end
		end

		return true
	end
end
