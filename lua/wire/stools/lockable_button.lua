WireToolSetup.setCategory( "Input, Output" )
WireToolSetup.open( "lockable button", "Lockable Button", "gmod_wire_lockable_button", nil, "Lockable Buttons" )


if CLIENT then
	language.Add( "tool.wire_lockable_button.name",					"Lockable Button Tool (Wire)" )
	language.Add( "tool.wire_lockable_button.desc",					"Spawns a lockable button for use with the wire system and DarkRP." )
	language.Add( "WireLockableButtonTool_toggle", 					"Toggle" )
	language.Add( "WireLockableButtonTool_allow_set_lock",			"Allow setting the lock state via wire, \nmight be a bad idea" )
	language.Add( "WireLockableButtonTool_lock_controlled_toggle",	"Lock State Determines Output,\notherwise button can be activated or toggled while unlocked" )
	language.Add( "WireLockableButtonTool_output_lock_state", 		"Should the entity output whether it's locked" )
	language.Add( "WireLockableButtonTool_entityout", 				"Output Entity" )
	language.Add( "WireLockableButtonTool_value_on", 				"Value On:" )
	language.Add( "WireLockableButtonTool_value_off", 				"Value Off:" )
	TOOL.Information = { { name = "left", text = "Create/Update " .. TOOL.Name } }
end
WireToolSetup.BaseLang()
WireToolSetup.SetupMax( 20 )

if SERVER then
	ModelPlug_Register("button")
	
	function TOOL:GetConVars() 
		return self:GetClientNumber( "toggle" ) ~= 0,
		self:GetClientNumber( "allow_set_lock" ),
		self:GetClientNumber( "lock_controlled_toggle" ),
		self:GetClientNumber( "output_lock_state" ),
		self:GetClientNumber( "value_off" ),
		self:GetClientNumber( "value_on" ), 
		self:GetClientInfo( "description" ), 
		self:GetClientNumber( "entityout" ) ~= 0
	end

	-- Uses default WireToolObj:MakeEnt's WireLib.MakeWireEnt function
end

CreateClientConVar( "wire_lockable_button_toggle", "0", true, false )
CreateClientConVar( "wire_lockable_button_allow_set_lock", "0", true, false )
CreateClientConVar( "wire_lockable_button_lock_controlled_toggle", "1", true, false )
CreateClientConVar( "wire_lockable_button_output_lock_state", "0", true, false )
CreateClientConVar( "wire_lockable_button_value_off", "0", true, false )
CreateClientConVar( "wire_lockable_button_value_on", "1", true, false )
CreateClientConVar( "wire_lockable_button_description", "", true, false )
CreateClientConVar( "wire_lockable_button_entityout", "0", true, false )

TOOL.ClientConVar = {
	model 					= "models/props_c17/clock01.mdl",
	model_category			= "button",
	toggle					= "0",
	allow_set_lock			= "0", -- Allow an input to set whether it's locked or not, I have no idea how secure that is
	lock_controlled_toggle	= "1", -- Basicly if this is on, being unlocked outputs value_on and being locked outputs value_off
	output_lock_state		= "0", -- Output the lock state seperatly from the output
	value_off				= "0",
	value_on				= "1",
	description				= "",
	entityout				= "0"
}

function TOOL.BuildCPanel(panel) -- This pops up but doesn't pull the tool out
	WireToolHelpers.MakePresetControl(panel, "wire_lockable_button")

	ModelPlug_AddToCPanel_Multi(
		panel,
		{	lockable_button		 = "Normal",
			lockable_button_small = "Small"
		},
		"wire_lockable_button", "#Button_Model", 6
	)
	panel:CheckBox("#WireLockableButtonTool_toggle",					"wire_lockable_button_toggle")
	panel:CheckBox("#WireLockableButtonTool_allow_set_lock",			"wire_lockable_button_allow_set_lock")
	panel:CheckBox("#WireLockableButtonTool_lock_controlled_toggle", "wire_lockable_button_lock_controlled_toggle")
	panel:CheckBox("#WireLockableButtonTool_output_lock_state",		"wire_lockable_button_output_lock_state")
	panel:CheckBox("#WireLockableButtonTool_entityout",				"wire_lockable_button_entityout")
	panel:NumSlider("#WireLockableButtonTool_value_on",				"wire_lockable_button_value_on", -10, 10, 1)
	panel:NumSlider("#WireLockableButtonTool_value_off",				"wire_lockable_button_value_off", -10, 10, 1)
end

WireToolSetup.close()
