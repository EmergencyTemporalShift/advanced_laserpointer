WireToolSetup.setCategory( "Detection" )
WireToolSetup.open( "adv_las_receiver", "Advanced Laser Pointer Receiver", "gmod_wire_adv_las_receiver", nil, "Advanced Laser Pointer Receivers" )

if CLIENT then
	language.Add( "Tool.wire_adv_las_receiver.name", "Advanced Laser Receiver Tool (Wire)" )
	language.Add( "Tool.wire_adv_las_receiver.desc", "Spawns a better laser receiver prop for use with the wire system." )
	TOOL.Information = { { name = "left", text = "Create/Update " .. TOOL.Name } }
end
WireToolSetup.BaseLang()
WireToolSetup.SetupMax( 20 )

TOOL.ClientConVar = {
	model = "models/jaanus/wiretool/wiretool_range.mdl",
}

function TOOL.BuildCPanel(panel)
	ModelPlug_AddToCPanel(panel, "Misc_Tools", "wire_adv_las_receiver")
end
