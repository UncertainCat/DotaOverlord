
function CreateOverlordHeroSelect(msg) 
{

	var Container = $("#TeamSpecificUI");
	var newpanel = $.CreatePanel( "Panel", Container, "DirePanel" );
	newpanel.BLoadLayout("file://{resources}/layout/custom_game/custom_cards.xml", false,false);
	newpanel.AddClass( "OverlordSelectionHud");
	
}

function 	CreateMultiTeamHeroSelect()
{
	
	var Container = $("#TeamSpecificUI");
	var newpanel = $.CreatePanel( "Panel", Container, "RadiantPanel" );
	newpanel.BLoadLayout("file://{resources}/layout/custom_game/multiteam_hero_select_overlay.xml", false,false) ;
	newpanel.AddClass( "HeroSelectOverlayRoot");	
	
}

(function()
{
	GameEvents.Subscribe( "create_overlord_hero_select", CreateOverlordHeroSelect);
	GameEvents.Subscribe( "create_radiant_hero_select", CreateMultiTeamHeroSelect);
	GameEvents.SendCustomGameEventToServer( "client_loaded_hero_select", { "player" :  Game.GetLocalPlayerInfo() } );
})();

