

(function()
{
	var MapName = Game.GetMapInfo().map_name

	if (MapName == "maps/overlord.vpk") {
		
	var Container = $("#MapInfo");
	var newpanel = $.CreatePanel( "Panel", Container, "OverlordPanel" );
	newpanel.BLoadLayout("file://{resources}/layout/custom_game/overlord_game_info.xml", false,false);
	newpanel.AddClass( "OverthrowGameInfo");
	} else {

	var Container = $("#MapInfo");
	var newpanel = $.CreatePanel( "Panel", Container, "VsPanel" );
	newpanel.BLoadLayout("file://{resources}/layout/custom_game/overlord_vs_game_info.xml", false,false) ;
	newpanel.AddClass( "OverthrowGameInfo");


	}
	
	

})();