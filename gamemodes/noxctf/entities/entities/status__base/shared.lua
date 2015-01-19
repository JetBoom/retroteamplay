ENT.Type = "anim"
ENT.m_IsStatus = true

ENT.ShouldDrawShadow = false

function ENT:PlaySound(ent, name)
	name = name.."Sound"
	if self[name] then
		if istable(self[name]) then
			local tab = self[name]
			local sound
			if istable(tab.sound) then
				sound = tab.sound[math.random(1, #tab.sound)]
			else
				sound = tab.sound
			end
			if sound then
				local delay = tab.delay
				if tab.vol and tab.pitchLB and tab.pitchRB then
					local vol = tab.vol
					local pitch = math.Rand(tab.pitchLB, tab.pitchRB)
				
					if delay and delay > 0 then
						timer.Simple(delay, function()
							if ent:IsValid() then ent:EmitSound(sound, vol, pitch) end
						end)
					else
						ent:EmitSound(sound, vol, pitch)
					end
				else
					if delay and delay > 0 then
						timer.Simple(delay, function()
							if ent:IsValid() then ent:EmitSound(sound) end
						end)
					else
						ent:EmitSound(sound)
					end
				end
			end
		else
			ent:EmitSound(self[name])
		end
	end
end

function ENT:StatusThink(owner)
end

function ENT:StatusInitialize()
end

function ENT:StatusOnRemove(owner, silent)
end

function ENT:SetDieTime(time)
	if time == 0 or not time then
		time = 0
	end

	self:SetDTFloat(3, time)
end

function ENT:GetDieTime()
	return self:GetDTFloat(3)
end

