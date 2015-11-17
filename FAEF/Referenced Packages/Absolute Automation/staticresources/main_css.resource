html, body {
	margin:0;
	padding:0;
	font-family: "Lucida Grande", Verdana;
	background-color:#F2F2F2;
	} 

#rootHeader {
	padding:8px 5px 12px;
	background-color: #F8F8F8;
	}

#center-container {
	width:700px;
	background-color:#1a1a1a;
	color:#ccc;
	}

/* extra selectivity to get this applied over SFDC's default styling */
/* cannot just use "id" b/c SFDC prefixes it with some garbage */
body div div div div.bPageBlock.apexDefaultPageBlock  {
	padding-left: 90px;
	}
body div div div div.bPageBlock.apexDefaultPageBlock div.pbBody {
	background-color: #1A1A1A;
/* cannot get this to work; resorting to javascript to set the right margin
margin: 7px 90px 7px 0;
margin-right: 90px;
*/
	}


/* visualization style container */

#infovis {
	position:relative;
	margin:auto;
	/* overflow:hidden; */ /* doesn't work with popup */
	/* over-declare the width & shift left so we draw on the right half of the canvas (moves graph center to left side of visible canvas) */
	width:1100px;
	height:1000px;
	left:-440px;
	*left:-460px; /* ie box model fix */
	}

a, a:link, a:visited {
	color:#343439;
	text-decoration: none;
	}

/*-------------------------------------------------------------------------------
 nodes
-------------------------------------------------------------------------------*/
div.node a, div.node a:link, div.node a:visited {
	color: #fff;
	}

div.node {
	font-weight:bold;
	/* overflow:hidden; */ /* doesn't work with popup */
	position:absolute;
	text-align:center;
	background-color:#1a1a1a;
	border: 1px solid #3a3a3a;
	padding: 2px;
	width: 150px;
	height: 30px;
	}

div.node .subscript, div.node div.popup {
	font-family: "lucida grande",tahoma,verdana,arial,sans-serif;
	font-size: 11px;
	font-weight: normal;
	text-decoration: none;
	}

div.node .subscript {
	color: #aaa;
	padding: 3px;
	}

/* make sure long names don't run multiple lines */
div.node div.name {
height: 1.2em;
overflow: hidden;
}

div.node div.subscript {
height: 1em;
overflow: hidden;
}

/*-------------------------------------------------------------------------------
 popup styles
-------------------------------------------------------------------------------*/
div.node td.viewEditLinks {
	vertical-align:middle;
	width: 7%;
	}

div.popup a, div.popup a:link, div.popup a:visited {
	color: #000;
	}

div.popup {
	display:none;
	position: relative;
	left: 155px;
	top: -30px;
	width: 386px;
	color: black;
	background-color: white;
	z-index: 11; /* above recent items etc. on left */
	background:url("i__hover_sprite_png") no-repeat scroll 15px -29px transparent;
	margin:-12px 0 0 -11px;
	padding:3px 6px 5px;
	}

div.popup div.wrap {
	background:url("i__hover_arrow_png") no-repeat scroll -1px 3px transparent;
	border:0 none;
	margin:0;
	padding-left:15px;
	}

div.popup.left {
	display:none;
	left: -394px;
	}

div.popup.left div.wrap {
	background:url("i__hover_arrow_flip_png") no-repeat scroll 383px 3px transparent;
	width: 370px;
	padding-right: 15px;
	}

div.popup div.wrap div.header {
  border-style: solid;
  border-width: 3px 0 0;
  -moz-border-radius: 4px;

	/* if a single value is supplied, chrome draws it on all 4 corner even if there is no border on those sides */
	/* so we have to specify each corner we want */
  border-top-left-radius: 3px;
  border-top-right-radius: 3px;
  -webkit-border-top-left-radius: 3px;
  -webkit-border-top-right-radius: 3px;

	border-color: #3A6690;
	}


/* gravatar placement */
img.gravatar {
	float:left;
	margin:-1px 0 0 -1px;
	}
div.popup img.gravatar {
	margin:-4px 0 0 -4px;
	}

div.popup td.pbTitle.user {
	width: 90%;
	}

div.popup div.header table {
	width: 100%;
	}

div.popup div.body {
	text-align: left;
	padding: 8px;
	}

table.postTable td {
	padding-top:8px;
	line-height: 1.4em;
	}

/* adapted from chatter.css (.feedcontainer a), which isn't included on our page */
div.popup table.postTable td a {
	font-weight:bold;
	color:#015BA7;
	text-decoration:none;
	}	
	

div.popup div.wrap div.footer {
	background:url("i__hover_sprite_png") no-repeat scroll 0 0 transparent;
	bottom:-14px;
	height:14px;
	left:15px;
	position:absolute;
	width:100%;
	}

/* timespan menu */
span.menu, span.menu select {
	font-size: 110%;
	}


/* sharing link */
span.permalink {
	font-size:90%;
	margin: 8px 12px 0 0;
	float: right;
	}
span.permalink a img {
	margin:0px 3px -5px 0px;
	}


#log {
	padding:8px 0 0 10px;
	font-style: italic;
	color:#fff;
	height: 15px;
	}

img.graphTitle {
	padding:4px 2px 4px 12px;
	}

h1.graphTitle {
	font-family:Arial,Helvetica,sans-serif;
	font-size:1.4em;
	font-weight:bold;
	color:#353535;
	}

span.helpWrap {
float:right;
font-size:91%;
padding:10px 5px 0 0;
text-align:right;
vertical-align:middle;
white-space:nowrap;
}

img.myHelpIcon {
padding-left:4px;
height:16px;
width:16px;
background:url("/img/alohaSkin/help_orange.png") no-repeat scroll 0 0 transparent;
}

/* fix objLookup inputs */
span.lookupInput {
position:relative;
top:-2px;
}
span.lookupInput input {
border: 1px solid #3A3A3A;
padding: 0 2px;
color: #3A3A3A;
background-color: transparent;
}
span.lookupInput a, span.lookupInput a:hover {
text-decoration: none;
}
span.lookupInput a img {
border: 0;
}

select {
border: 1px solid #3A3A3A;
margin: 0px 2px;
}
