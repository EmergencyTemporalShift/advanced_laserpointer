-- The premise of this is to act as a passthrough while renaming signals ( The wire tool auto selects signals with the same name)
-- One input might be able to link to multiple outputs

AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName       = "Wire Grouper"
ENT.WireDebugName	= "Grouper"

function ENT:SetupDataTables()
	--self:NetworkVar( "Bool", 0, "On" )
end


function ENT:Setup()
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
	
	
	Wirelib.AdjustInputs(self, inames)
end

function ENT:ShowOutput()
	self:SetOverlayText("TODO")
end

duplicator.RegisterEntityClass("gmod_wire_grouper", WireLib.MakeWireEnt, "description" )
