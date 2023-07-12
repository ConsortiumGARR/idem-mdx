// JavaScript Document

$(window).load(function() {
	"use strict";
	loadVideoTube();
	FermaVideo();
});

$(window).resize(function() {
	"use strict";
	loadVideoTube();
	FermaVideo();
});


/* funzioni */




function loadVideoTube() {
	"use strict";
	var width  = $('div.videosizer').width();
		$('div.videosizer iframe').css('height', width / 16 * 9);
		//console.log ("height: " + (width / 16 * 9));
}




function FermaVideo(){
	"use strict";
	if ($('video').is(':visible')){
		function isInView(el) {
		  var rect = el.getBoundingClientRect();
		  return !(rect.top > $(window).height() || rect.bottom < 0);
		}
		
		$(document).on("scroll", function() {
		  $( "video" ).each(function() {
			if (isInView($(this)[0])) {
			  if ($(this)[0].paused) { $(this)[0].pause(); }
			}
			else {
			  if ($(this)[0].played) { $(this)[0].pause(); }
			}
		  });  
		});
	} else {  }
}


