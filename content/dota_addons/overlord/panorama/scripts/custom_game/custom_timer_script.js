function UpdateTimer( msg ) {
	var time = msg.text;
$( "#Timer" ).text = time;
}

function UpdateGameTimer( msg ) {
	var time = msg.text;
$( "#GameTimer" ).text = time;
}

(function () {
  GameEvents.Subscribe( "UpdateTimer", UpdateTimer );
  GameEvents.Subscribe( "UpdateGameTimer", UpdateGameTimer );
})();


