AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')



SWEP.Weight = 8
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Receiver = nil
SWEP.Pointing = false

function SWEP:Initialize()
	self.Pointing = false
end

function SWEP:Equip( newOwner )
	if IsValid(newOwner.AdvLasReceiver) then
		self.Receiver = newOwner.AdvLasReceiver
		newOwner.AdvLasReceiver = nil
		newOwner:PrintMessage( HUD_PRINTTALK, "Relinked Sucessfully" )
	end
end

hook.Add("PlayerBindUp", "FinishedPrimaryAttack", function(player, binding)
    if binding ~= "attack" then return end
    local weapon = player:GetActiveWeapon()
    if not IsValid(weapon) or not weapon:IsWeapon() or not weapon.FinishedPrimaryAttack then return end
    weapon:FinishedPrimaryAttack()
end)

function SWEP:PrimaryAttack()
	if IsValid(self.Receiver) then
		self.Pointing = true
		self.Weapon:SetNWBool("PrimaryActive", true)
		WireLib.TriggerOutput(self.Receiver,"PrimaryActive",1)
	else
		self:GetOwner():PrintMessage( HUD_PRINTTALK, "No linked Receiver" )
	end
end

function SWEP:FinishedPrimaryAttack()
	if IsValid(self.Receiver) then
		self.Pointing = false
		self.Weapon:SetNWBool("PrimaryActive", false)
		WireLib.TriggerOutput(self.Receiver,"PrimaryActive",0)
	end
	-- self:GetOwner():PrintMessage( HUD_PRINTTALK, "FinishedPrimaryAttack" )
end

function SWEP:SecondaryAttack()
	-- Send a secondary signal for a short time on rising edge
	if IsValid(self.Receiver) then
		WireLib.TriggerOutput(self.Receiver,"SecondaryActive", 1)
		
		timer.Create("adv_las_secondary_"..self:GetOwner():EntIndex(), 0.1, 1, function()
			WireLib.TriggerOutput(self.Receiver,"SecondaryActive", 0)
		end)
	end
end


function SWEP:Reload()
	local trace = self:GetOwner():GetEyeTrace()
	local traceEnt = trace.Entity
	local oldReceiver = self.Receiver

	--Am I looking at an advanced laser receiver?
	if IsValid(traceEnt) and traceEnt:GetClass() == "gmod_wire_adv_las_receiver" then
		if(gamemode.Call("CanTool", self:GetOwner(), trace, "wire_adv_las_receiver")) then -- Gamemode allows tool use
			if(oldReceiver ~= traceEnt) then -- You don't need to relink to the same one
				self.Receiver = traceEnt
				if(self.Receiver ~= nil) then -- The pointer is linked to something
					if(oldReceiver == nil) then -- Is this the first link?
						self:GetOwner():PrintMessage( HUD_PRINTTALK, "Successfully linked" )
					else
						self:GetOwner():PrintMessage( HUD_PRINTTALK, "Successfully linked to a new receiver" )
					end
				else
					self:GetOwner():PrintMessage( HUD_PRINTTALK, "Link Failed. Something is wrong" )
				end
			end
		end
	else -- Change pointer settings with menu maybe
		--TODO: Add menu
	end
end


function SWEP:Think()
	if(self.Receiver && self.Receiver:IsValid()) then
		if self.Pointing then
			local owner = self:GetOwner()
			local ownerPos = owner:GetPos()
			local trace = owner:GetEyeTrace()
			local point = trace.HitPos
			if (COLOSSAL_SANDBOX) then point = point * 6.25 end
			WireLib.TriggerOutput(self.Receiver, "X",			point.x)
			WireLib.TriggerOutput(self.Receiver, "Y",			point.y)
			WireLib.TriggerOutput(self.Receiver, "Z",			point.z)
			WireLib.TriggerOutput(self.Receiver, "Pos",		point)
			WireLib.TriggerOutput(self.Receiver, "UserX",		ownerPos.x)
			WireLib.TriggerOutput(self.Receiver, "UserY",		ownerPos.y)
			WireLib.TriggerOutput(self.Receiver, "UserZ",		ownerPos.z)
			WireLib.TriggerOutput(self.Receiver, "UserPos",	ownerPos)
			WireLib.TriggerOutput(self.Receiver, "RangerData", trace)
			self.Receiver.VPos = point
		end
	else
		self.Pointer = false
		self.Weapon:SetNWBool("PrimaryActive", false)
		
	end
end
