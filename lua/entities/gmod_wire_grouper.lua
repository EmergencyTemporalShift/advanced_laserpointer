-- The premise of this is to act as a passthrough while renaming signals ( The wire tool auto selects signals with the same name)
-- One input might be able to link to multiple outputs

AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName       = "Wire Grouper"
ENT.WireDebugName	= "Grouper"

function ENT:SetupDataTables()
	--self:NetworkVar( "Bool", 0, "On" )
end



if CLIENT then
	local halo_ent, halo_blur

	function ENT:Initialize()
		self.PosePosition = 0.0
	end

	function ENT:Think()
		--
	end

	function ENT:Draw()
		self:DoNormalDraw(true,false)
		Wire_Render(self)
	end
	
	return  -- No more client
end

function ENT:Initialize()
	print("InitCalled")
	print(tostring(self))
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	ets_ins = ets_ins or {}
	ets_outs = ets_outs or {}
	ets_ins[self] = ets_ins[self] or {}
	ets_outs[tostring(self)] = ets_outs[self] or {}
	--ets_ins, ets_outs
	ets_ins[self], ets_outs[self] = interpPuts(GetConVar("wire_grouper_table"):GetString()) -- Pull down wire_grouper_table
	local ets_instype = appendTypes(ets_ins[self], "NORMAL")
	local ets_outs_processed = removeDupes(flattenTable(ets_outs[self]))
	local ets_outstype = appendTypes(ets_outs_processed, "NORMAL")

	
	print()
	print("ins: " .. tableToString(ets_ins[self]))
	print("outs: " .. tableToString(ets_outs[self]))
	print("flat_outs: " .. tableToString(ets_outs_processed,true))
	
	self.Inputs = WireLib.CreateInputs(self, ets_ins[self])
	self.Outputs = WireLib.CreateOutputs(self, ets_outs_processed)
end

function ENT:Setup(io_table)
	print("SetupCalled")
	-- Shamelessly stolen from the wire ranger, It really should be built in, at least a version of it
	-- TODO: Recreate functions to take one input and type and one or more outputs with the same type
	
	ets_ins = ets_ins or {}
	ets_outs = ets_outs or {}
	ets_ins[tostring(self)] = ets_ins[self] or {}
	ets_outs[tostring(self)] = ets_outs[self] or {}
	
	local onames, otypes = {}, {}
	local function add_output(...)
		local args = {...}
		for i=1,#args,2 do
			onames[#onames+1] = args[i]
			otypes[#otypes+1] = args[i+1]
		end
	end
	local inames, itypes = {}, {}
	local function add_input(...)
		local args = {...}
		for i=1,#args,2 do
			inames[#inames+1] = args[i]
			itypes[#itypes+1] = args[i+1]
		end
			
	end
	
	ets_ins[self], ets_outs[self] = interpPuts(GetConVar("wire_grouper_table"):GetString())
	local ets_instype = appendTypes(ets_ins[self], "NORMAL")
	local ets_outs_processed = removeDupes(flattenTable(ets_outs[self]))
	local ets_outstype = appendTypes(ets_outs_processed, "NORMAL")
	print("etsins: " .. tableToString(ets_ins[self],true))
	print("etsouts: " .. tableToString(ets_outs[self],true))
	
	add_input(ets_instype)
	add_output(ets_outstype)
	
	
	--WireLib.AdjustSpecialInputs(self, inames, itypes, {})
	WireLib.AdjustSpecialInputs(self, ets_instype, nil, {})
	--WireLib.AdjustSpecialOutputs(self, onames, otypes, {})
	WireLib.AdjustSpecialOutputs(self, ets_outstype, nil, {})
end

function ENT:TriggerInput(name, value)
	for i = 1, #ets_ins[self] do
		if name == ets_ins[self][i] then
			for j = 1, #ets_outs[self][i] do
				WireLib.TriggerOutput(self, ets_outs[self][i][j], value)
			end
			return -- After the above loop runs we should be done
		end
	end
end

function ENT:ShowOutput()
	self:SetOverlayText("TODO")
end

duplicator.RegisterEntityClass("gmod_wire_grouper", WireLib.MakeWireEnt, "description" )
