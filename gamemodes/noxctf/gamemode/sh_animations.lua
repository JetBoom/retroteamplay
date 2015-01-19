local ActTranslations = {}
ActTranslations[ACT_MP_STAND_IDLE]					= 0
ActTranslations[ACT_MP_WALK] 						= 1
ActTranslations[ACT_MP_RUN] 						= 2
ActTranslations[ACT_MP_CROUCH_IDLE] 				= 3
ActTranslations[ACT_MP_CROUCHWALK] 					= 4
ActTranslations[ACT_MP_ATTACK_STAND_PRIMARYFIRE] 	= 5
ActTranslations[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE]	= 5
ActTranslations[ACT_MP_RELOAD_STAND]		 		= 6
ActTranslations[ACT_MP_RELOAD_CROUCH]		 		= 6
function GM:BaseActivityTranslate(act, base)
	if ActTranslations[act] then
		return base + ActTranslations[act]
	end

	return act
end

function GM:CalcMainActivity(ply, velocity)
	ply.CalcIdeal = ACT_MP_STAND_IDLE
	ply.CalcSeqOverride = -1

	if not (ply:CallClassFunction("CalcMainActivity", velocity) or self:HandlePlayerDriving(ply) or self:HandlePlayerJumping(ply, velocity) or self:HandlePlayerDucking(ply, velocity) or self:HandlePlayerSwimming(ply, velocity)) then
		local len2d = velocity:Length2D()

		if len2d > 165 then
			ply.CalcIdeal = ACT_MP_RUN
		elseif len2d > 0.5 then
			ply.CalcIdeal = ACT_MP_WALK
		end
	end
	
	return ply.CalcIdeal, ply.CalcSeqOverride
end

function GM:UpdateAnimation(pl, ...)
	--pl:SetPoseParameter("breathing", 2 - pl:Health() / pl:GetMaxHealth())

	local ret = pl:CallClassFunction("UpdateAnimation", ...)
	if ret ~= nil then return ret end

	return self.BaseClass.UpdateAnimation(self, pl, ...)
end

function GM:DoAnimationEvent(pl, ...)
	local ret = pl:CallClassFunction("DoAnimationEvent", ...)
	if ret ~= nil then return ret end

	return self.BaseClass.DoAnimationEvent(self, pl, ...)
end

--[[function GM:CalcMainActivity(pl, ...)
	local ideal, override = pl:CallClassFunction("CalcMainActivity", ...)
	if ideal ~= nil or override ~= nil then return ideal, override end

	return self.BaseClass.CalcMainActivity(self, pl, ...)
end]]

--[[function GM:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:SetPoseParameter("breathing", 2 - pl:Health() / pl:GetMaxHealth())

	pl:CallClassFunction("UpdateAnimation", velocity, maxseqgroundspeed)

	self.BaseClass:UpdateAnimation(pl, velocity, maxseqgroundspeed)
end

function GM:DoAnimationEvent(pl, event, data)
	return pl:CallClassFunction("DoAnimationEvent", event, data) or self.BaseClass:DoAnimationEvent(pl, event, data)
end
]]
