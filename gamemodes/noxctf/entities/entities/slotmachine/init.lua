AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("pslot.lua")
AddCSLuaFile("sh_meta.lua")

include("shared.lua")

--[[
	Reason why I am using umsg is to send the client the entity's info 
	in order for the VGUI to send the command back to the server via concommands. 

	Pretty hacky or stupid? Yes.
	Is it exploitable unlike the previous version? Not for now.
]]--

function ENT:Initialize()
	self:SetModel("models/slot_machine.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetUseType(SIMPLE_USE)

	local phy = self:GetPhysicsObject()
	if phy:IsValid() then phy:EnableMotion(false) end

	self:SetDTInt(1, #self.SlotEntries)
	self:SetDTInt(2, #self.SlotEntries)
	self:SetDTInt(3, #self.SlotEntries)
	self:SetDTFloat(1, self.MinPot)
end

--This is to make sure that the player isn't fucking up the slot machine.
function ENT:Think()
	local player = self:GetSlotPlayer()

	if player == NULL then return end
	if not IsValid(player) then
		self:ResetSlotMachine()
	end
	if not player:Alive() or not self:IsCloseDistance(player) then
		self:ResetSlotMachine()
	end
end

function ENT:Use(pl)
	if not self:IsCloseDistance(pl) then return end --Yeah, you can actually get this to open double the distance than metioned there.
	if IsValid(self:GetSlotPlayer()) then return end --Prevent more people taking over the slot.
	
	if self:GetYawSum(pl) >= 150 and self:GetYawSum(pl) <= 215 then --Make sure they are facing INFRONT of the machine.
		self:SetSlotPlayer(pl)

		umsg.Start("openslotwindow", pl)
			umsg.Entity(self)
		umsg.End()
	end
end