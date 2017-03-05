function UpdateUnitCount( msg ) {
	var count = msg.text;
$( "#OverlordUnitCountText" ).text = count;
}

function UpdateGoldPerMinute(msg) {
	var gpm = msg.text;
//$( "#OverlordIncomeText" ).text = gpm;
}

function UpdateGoldCostPerMinute(msg){
	var cost = msg.text;
$( "#OverlordExpenseText" ).text = cost;
}


(function () {
  GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false );      //Glyph.
  GameEvents.Subscribe( "UpdateUnitCount", UpdateUnitCount );
  GameEvents.Subscribe( "UpdateGoldCostPerMinute", UpdateGoldCostPerMinute );
  //GameEvents.Subscribe( "UpdateGoldPerMinute", UpdateGoldPerMinute );


})();


