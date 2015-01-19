ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.m_IsProjectile = true

function ENT:SetTeam(teamid)
	self:SetColor(team.GetColor(teamid))
end
