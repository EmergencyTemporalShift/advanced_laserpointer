WireToolSetup.setCategory( "Input, Output" )
WireToolSetup.open( "grouper", "Grouper", "gmod_wire_grouper", nil, "Groupers" )


if CLIENT then
	language.Add( "tool.wire_grouper.name",					"Wire grouping tool" )
	language.Add( "tool.wire_grouper.desc",					"Spawns a device that can take several inputs and output them in place" )
	TOOL.Information = { { name = "left", text = "Create/Update " .. TOOL.Name } }
end
WireToolSetup.BaseLang()
WireToolSetup.SetupMax( 20 )

if SERVER then
	
	function TOOL:GetConVars() 
		return self:GetClientInfo( "description" )
	end

	-- Uses default WireToolObj:MakeEnt's WireLib.MakeWireEnt function
end

CreateClientConVar( "wire_grouper_description", "", true, false )

TOOL.ClientConVar = {
	model 					= "models/props_c17/clock01.mdl", -- Placeholder
	model_category			= "button", -- Placeholder
	description				= ""
}

function TOOL.BuildCPanel(panel) -- This pops up but doesn't pull the tool out
	WireToolHelpers.MakePresetControl(panel, "wire_grouper")
	
	
end

WireToolSetup.close()
