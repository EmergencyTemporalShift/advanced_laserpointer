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
		return self:GetClientInfo( "description" ),
		self:GetClientInfo( "table" )
	end

	-- Uses default WireToolObj:MakeEnt's WireLib.MakeWireEnt function
end

CreateClientConVar( "wire_grouper_description", "", true, false )

TOOL.ClientConVar = {
	model 					= "models/bull/gates/microcontroller1.mdl",
	model_category			= "gate",
	description				= "",
	table					= "in1:out1a,out1b;in2:out2a,out2b"
}

function TOOL.BuildCPanel(panel)
	WireToolHelpers.MakePresetControl(panel, "wire_grouper")
	
	panel:AddControl( "TextBox", { 
		Label = "InputOutputs", 
		Description = "String to interpret inputs and outputs", 
		MaxLength = "64",
		Text = "in1:out1a,out1b;in2:out2a,out2b",
		WaitForEnter = "true",
		Command = "wire_grouper_table", 
	} )
	
end

WireToolSetup.close()
