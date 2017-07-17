 
AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName       = "Wire Key Button"
ENT.WireDebugName	= "Key Button"

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "On" )
end

if CLIENT then 
	local halo_ent, halo_blur

	function ENT:Initialize()
		self.PosePosition = 0.0
	end

	function ENT:Think()
		baseclass.Get("gmod_button").UpdateLever(self)
	end

	function ENT:Draw()
		self:DoNormalDraw(true,false)
		if LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance( self:GetPos() ) < 512 then
			if self:GetOn() then
				halo_ent = self
				halo_blur = 4 + math.sin(CurTime()*20)*2
			else
				self:DrawEntityOutline()
			end
		end
		Wire_Render(self)
	end

	hook.Add("PreDrawHalos", "Wiremod_button_overlay_halos", function()
		if halo_ent then
			halo.Add({halo_ent}, Color(255,100,100), halo_blur, halo_blur, 1, true, true)
			halo_ent = nil
		end
	end)
	
	return  -- No more client
end

ENT.OutputEntID = false
ENT.EntToOutput = NULL

local anims = {
	-- ["model"] = { on_anim, off_anim }
	["models/props/switch001.mdl"] = { 2, 1 },
	["models/props_combine/combinebutton.mdl"] = { 3, 2 },
	["models/props_mining/control_lever01.mdl"] = { 1, 4 },
	["models/props_mining/freightelevatorbutton01.mdl"] = { 1, 2 },
	["models/props_mining/freightelevatorbutton02.mdl"] = { 1, 2 },
	["models/props_mining/switch01.mdl"] = { 1, 2 },
	["models/bull/buttons/rocker_switch.mdl"] = { 1, 2 },
	["models/bull/buttons/toggle_switch.mdl"] = { 1, 2 },
	["models/bull/buttons/key_switch.mdl"] = { 1, 2 },
	["models/props_mining/switch_updown01.mdl"] = { 2, 3 },
}

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )

	self.Outputs = Wire_CreateOutputs(self, { "Out" })
	self.Inputs = Wire_CreateInputs(self, { "Set" })
	local anim = anims[self:GetModel()]
	if anim then self:SetSequence(anim[2]) end
end

function ENT:TriggerInput(iname, value)
	if iname == "Set" then
		if (self.toggle) then
			self:Switch(value ~= 0)
			self.PrevUser = nil
			self.podpress = nil
		end
	end
end

function ENT:Use(ply)
	if (not ply:IsPlayer()) then return end
	if (self.PrevUser) and (self.PrevUser:IsValid()) then return end
	if self.OutputEntID then
		self.EntToOutput = ply
	end
	if (self:GetOn()) then
		if (self.toggle) then self:Switch(false) end

		return
	end

	self:Switch(true)
	self.PrevUser = ply
end

function ENT:Think()
	self.BaseClass.Think(self)

	if ( self:GetOn() ) then
		if (not self.PrevUser)
		or (not self.PrevUser:IsValid())
		or (not self.podpress and not self.PrevUser:KeyDown(IN_USE))
		or (self.podpress and not self.PrevUser:KeyDown( IN_ATTACK )) then
		    if (not self.toggle) then
				self:Switch(false)
			end

			self.PrevUser = nil
			self.podpress = nil
		end

		self:NextThink(CurTime()+0.05)
		return true
	end
end

function ENT:Setup(toggle, allow_set_lock, lock_controlled_toggle, output_lock_state, value_off, value_on, description, entityout)
	self.toggle 				= toggle
	self.allow_set_lock			= allow_set_lock
	self.lock_controlled_toggle = lock_controlled_toggle
	self.output_lock_state      = output_lock_state
	self.value_off				= value_off
	self.value_on				= value_on
	self.entityout				= entityout
	
	-- Shamelessly stolen from the wire ranger, It really should be built in, at least a version of it
	local onames, otypes = {}, {}
	local function add_output(...)
		local args = {...}
		for i=1,#args,2 do
			onames[#onames+1] = args[i]
			otypes[#otypes+1] = args[i+1]
		end
	end
	local inames = {}
	local function add_input(...)
		local args = {...}
		for i=1,#args,1 do
			inames[#inames+1] = args[i]
		end
			
	end
	
	add_output("Out", "NORMAL")
	
	-- Should I output locked state seperate?
	if output_lock_state then
		add_output("LockState", "NORMAL")
		self.OutputLockState=true
	else
		self.OutputLockState=false
	end
	
	if entityout then
		add_output("EntID" , "NORMAL",
				   "Entity", "ENTITY")
		Wire_TriggerOutput(self, "EntID", 0)
		Wire_TriggerOutput(self, "Entity", nil)
		self.OutputEntID=true
	else
		self.OutputEntID=false
	end
	
	WireLib.AdjustSpecialOutputs(self, onames, otypes)
		
	-- I don't know if I should allow setting the lock state --
	if allow_set_lock then
		add_input("SetLock")
	else
		-- add nothing
	end
	

	
	if toggle then
		add_input("Set")
	else
		-- add nothing
	end
	
	Wirelib.AdjustInputs(self, inames)
	self:Switch(self:GetOn())
end

function ENT:Switch(on)
	if (not self:IsValid()) then return end

	self:SetOn( on )

	if (on) then
		self:ShowOutput(self.value_on)
		self.Value = self.value_on

		local anim = anims[self:GetModel()]
		if anim then self:SetSequence(anim[1]) end
	else
		self:ShowOutput(self.value_off)
		self.Value = self.value_off

		local anim = anims[self:GetModel()]
		if anim then self:SetSequence(anim[2]) end

		if self.OutputEntID then self.EntToOutput = NULL end
	end

	Wire_TriggerOutput(self, "Out", self.Value)
	if self.OutputEntID then
		Wire_TriggerOutput(self, "EntID", self.EntToOutput:EntIndex())
		Wire_TriggerOutput(self, "Entity", self.EntToOutput)
	end
	if self.OutputLockState then
		Wire_TriggerOutput(self, "LockState", self.LockState)
	return true
	end
end

function ENT:ShowOutput(value) -- TODO: Add lock state
	self:SetOverlayText( "(" .. self.value_off .. " - " .. self.value_on .. ") = " .. value )
end

duplicator.RegisterEntityClass("gmod_wire_key_button", WireLib.MakeWireEnt, "Data", "toggle", "allow_set_lock", "lock_controlled_toggle", "output_lock_state", "value_off", "value_on", "description", "entityout" )
