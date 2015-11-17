/*
Copyright (c) 2009, Etherios LLC All rights reserved.

This source code cannot be copied, modified, or reproduced without the direct written consent of Etherios LLC.
version: 1.0
*/		

// Create a namespace for our custom functions
	    YAHOO.namespace("etherios");
	
		var posX;
		var posY;
		
		
		function handleClick(oEvent) {
			var scrOfX = 0, scrOfY = 0;
			  if( typeof( window.pageYOffset ) == 'number' ) {
			    //Netscape compliant
			    scrOfY = window.pageYOffset;
			    scrOfX = window.pageXOffset;
			  } else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) {
			    //DOM compliant
			    scrOfY = document.body.scrollTop;
			    scrOfX = document.body.scrollLeft;
			  } else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) {
			    //IE6 standards compliant mode
			    scrOfY = document.documentElement.scrollTop;
			    scrOfX = document.documentElement.scrollLeft;
			  }
	        posX = oEvent.clientX + scrOfX;
	        posY = oEvent.clientY + scrOfY;
	    }	    
	    
	    YAHOO.etherios.showPicks = function(eId){
	    	var e = document.getElementById(eId);
	    	document.body.className = document.body.className + " yui-skin-sam";
	    	YAHOO.etherios.panel_picks = new YAHOO.widget.Panel("panel_picks", 
				{ 
	                    width           :   600,    // You can play with this until it's right
	                    visible         :   true,  // Should be visible when rendered
	                    draggable       :   true,   // Make the dialog draggable
	                    close           :   false,  // Don't include a close title button
	                    modal           :   false,   // Don't ake it modal
	                    fixedCenter     :   false,   // can't do this because of long picklists
	                    zindex          :   40,     // Make sure it's on top of everything
						x				:	posX,
						y				:	posY,
						underlay		:	"shadow",
						constraintoviewport	: true,
	                    
	                    // This line adds the appear/vanish fade effect
	                    effect          :   {
	                                          effect:YAHOO.widget.ContainerEffect.FADE,
	                                          duration:0.25
	                                        } 
	            }
			); 
			YAHOO.etherios.panel_picks.setHeader('<br/>');
			YAHOO.etherios.panel_picks.setBody(e.innerHTML);
			YAHOO.etherios.panel_picks.render(document.body);
	    }
	    
	    YAHOO.etherios.hidePicks = function() {
	    	YAHOO.etherios.panel_picks.hide();
	    }


		YAHOO.etherios.showLoader = function(eId){
	    	var e = document.getElementById(eId);
	    	document.body.className = document.body.className + " yui-skin-sam";
	    	YAHOO.etherios.loader = new YAHOO.widget.Panel("loader", 
				{ 

	                    visible         :   true,  // Should be visible when rendered
	                    draggable       :   false,   // Make the dialog draggable
	                    close           :   true,  // Don't include a close title button
	                    modal           :   true,   // Don't ake it modal
	                    fixedCenter     :   true,   // can't do this because of long picklists
	                    zindex          :   40,     // Make sure it's on top of everything
	                    
	                    // This line adds the appear/vanish fade effect
	                    effect          :   {
	                                          effect:YAHOO.widget.ContainerEffect.FADE,
	                                          duration:0.35
	                                        } 
	            }
			); 
			YAHOO.etherios.loader.setHeader('Retrieving Details');
			YAHOO.etherios.loader.setBody(e.innerHTML);
			YAHOO.etherios.loader.render(document.body);
	    }
	    

	    YAHOO.etherios.hideLoader = function() {
	    	YAHOO.etherios.loader.hide();
	    }
		YAHOO.etherios.screenSize = 0;
		YAHOO.etherios.init = function() {		
			if (YAHOO.etherios.screenSize == 0){
	 			YAHOO.etherios.screenSize = screen.availWidth - 40;
			}
		 	document.getElementById('etheriosHeaderTable').width = YAHOO.etherios.screenSize;
		 	document.getElementById('etheriosTopBlockTable').width = YAHOO.etherios.screenSize;
		 	document.getElementById('etheriosSObjectDetailsTable').width = YAHOO.etherios.screenSize;			
	 	}

	 	YAHOO.util.Event.addListener(window, "load", YAHOO.etherios.init);	