AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName       = "Wire Advanced Laser Receiver"
ENT.WireDebugName 	= "Advanced Laser Receiver"

if CLIENT then return end -- Only the server runs the rest of this

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	self.Outputs = WireLib.CreateSpecialOutputs(self, {"PrimaryActive", "SecondaryActive", "X", "Y", "Z", "UserX", "UserY", "UserZ", "Pos", "UserPos", "RangerData"}, {"NORMAL", "NORMAL","NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "VECTOR", "VECTOR", "RANGER"})
	self.VPos = Vector(0,0,0)

	self:SetOverlayText( "Advanced Laser Pointer Receiver" )
end

function ENT:GetBeaconPos(sensor)
	return self.VPos
end
function ENT:GetBeaconVelocity(sensor) return Vector() end

function ENT:Use( User, caller )
	local laserGiven = false -- Was an advanced laserpointer given to the player
	
	if not hook.Run("PlayerGiveSWEP", User, "adv_laserpointer", weapons.Get( "adv_laserpointer" )) then return end -- If the player can't give an adv_laserpointer, just return
	User:PrintMessage(HUD_PRINTTALK, "Hold down your use key for 2 seconds to link or get a linked Laser Pointer.")
	timer.Create("adv_las_receiver_use_"..User:EntIndex(), 2, 1, function()
		if not IsValid(User) or not User:IsPlayer() then return end -- We don't want to give weapons to wired users for instance
		if not User:KeyDown(IN_USE)					then return end -- Make sure the user is still holding down the use key
		if not User:GetEyeTrace().Entity 			then return end -- Make sure the user is still looking at any? entity

		if not IsValid(User:GetWeapon("adv_laserpointer")) then
			if not hook.Run("PlayerGiveSWEP", User, "adv_laserpointer", weapons.Get( "adv_laserpointer" )) then return end
			User:Give("adv_laserpointer")
			laserGiven = true
		end

		User:GetWeapon("adv_laserpointer").Receiver = self -- Set the receiver
		
		if(laserGiven) then
			User:PrintMessage(HUD_PRINTTALK, "adv_laserpointer given and linked")
		else
			User:PrintMessage(HUD_PRINTTALK, "adv_laserpointer linked")
		end
		
		User:SelectWeapon("adv_laserpointer")
	end)
end

local function playerDeath( victim, weapon, killer)
	if(victim:HasWeapon("adv_laserpointer"))then
		local pointer = victim:GetWeapon("adv_laserpointer")
		if(pointer && pointer:IsValid()) then
			victim.AdvLasReceiver = pointer.Receiver
		end
	end
end
hook.Add( "PlayerDeath", "laserMemory", playerDeath)

duplicator.RegisterEntityClass("gmod_wire_adv_las_receiver", WireLib.MakeWireEnt, "Data")
