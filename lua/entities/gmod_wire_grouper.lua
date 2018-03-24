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
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	--self:SetUseType( SIMPLE_USE )
	
	local ins, outs
	ins, outs = interpPuts("in1:out1a,out1b;in2:out2a,out2b") -- Pull down wire_grouper_table
	
	print()
	print("ins: " .. tableToString(ins))
	print("outs: " .. tableToString(outs))
	print("flat: " .. tableToString(flattenTable(outs)))
	
	self.Inputs = WireLib.CreateInputs(self, ins)
	self.Outputs = WireLib.CreateOutputs(self, flattenTable(outs))
end

function ENT:Setup(io_table)
	-- Shamelessly stolen from the wire ranger, It really should be built in, at least a version of it
	-- TODO: Recreate functions to take one input and type and one or more outputs with the same type
	
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
	
	ins, outs = interpPuts(GetConVar("wire_grouper_table"):GetString())
	ins = appendTypes(ins, "NORMAL")
	outs = appendTypes(flattenTable(outs), "NORMAL")
	print(tableToString(ins))
	print(tableToString(outs))
	
	add_input(ins)
	add_output(flattenTable(outs))
	add_input("In", "NORMAL")
	add_output("Out", "NORMAL")
	
	
	--WireLib.AdjustSpecialInputs(self, inames, itypes, {})
	WireLib.AdjustSpecialInputs(self, ins, nil, {})
	--WireLib.AdjustSpecialOutputs(self, onames, otypes, {})
	WireLib.AdjustSpecialOutputs(self, outs, nil, {})
end

function ENT:ShowOutput()
	self:SetOverlayText("TODO")
end

duplicator.RegisterEntityClass("gmod_wire_grouper", WireLib.MakeWireEnt, "description" )
