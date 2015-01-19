AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	if not bExists then
		pPlayer:Freeze(true)

		if pPlayer.m_DrawWorldModel then
			self.ResetWorldModel = true
			pPlayer:DrawWorldModel(false)
		end

		if pPlayer.m_DrawViewModel then
			self.ResetViewModel = true
			pPlayer:DrawViewModel(false)
		end

		pPlayer:CreateRagdoll()
	end
end

function ENT:StatusOnRemove(owner)
	owner:Freeze(false)
	owner.KnockedDown = nil

	if owner:Alive() then
		if self.ResetViewModel then
			owner:DrawViewModel(true)
		end

		if self.ResetWorldModel then
			owner:DrawWorldModel(true)
		end

		local rag = owner:GetRagdollEntity()
		if rag and rag:IsValid() then
			rag:Remove()
		end
	end
end
