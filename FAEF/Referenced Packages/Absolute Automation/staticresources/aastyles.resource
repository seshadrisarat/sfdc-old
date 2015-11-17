li.aaBullet {
padding: 0 0 0 10px;
background: url(i__aabullet) no-repeat top left; /* relative path to other static resource - nice! */
list-style: none;
margin-bottom: 1em;
}
div.aaTableHdr {
padding:4px;
font-weight:bold;
margin-left:-14px;
margin-top:16px;
}


/*----- subnav bar -----*/
div.subnav {
background:url(i__subnav_bg_left) no-repeat scroll left top transparent;
height:60px;
padding-left:13px;
}
div.subnav div.subnav2 {
background:url(i__subnav_bg_right) no-repeat scroll right top transparent;
height:50px;
padding-right:20px;
overflow: hidden; /* so the "iHance" logo (mostly) disappears when the menu shrinks */
}
div.subnav div.subnav2 a img { /* ihance icon */
float:left;
}
div.subnav div.subnav2 ul {
float:right;
margin:0;
padding:0;
height:38px;
border-left:1px solid #D6D6D6;
}
div.subnav div.subnav2 ul li {
display:block;
list-style:none;
float:left;
margin:0;
}
div.subnav div.subnav2 ul li a {
text-decoration:none;
padding:11px 20px 0;
display:block;
height:28px;
border-right:1px solid #D6D6D6;
font-weight:bold;
}
div.subnav div.subnav2 ul li a img { /* Help tab's open-in-new-window icon, eg */
float: right;
margin-left: 6px;
}
div.subnav div.subnav2 ul li a.current {
background:url(i__subnav_selected) no-repeat scroll center top transparent;
padding-bottom:20px;
border:none;
}

/*----- aaAdmin styles -----*/
.adminTab {
font-size:12px;
font-weight:bold;
background-image:none;
cursor:pointer;
}

.adminTabInactive {
background-color:#FCFCFC;
color:#888;
}

div.uninstallWarning {
border: red 1px solid;
margin: 20px;
margin-top: 0px;
padding: 10px;
background: url(https://www.ihance.com/img/icon/alert_32.gif) no-repeat center left;
}

div.uninstallWarning div {
margin-left: 40px;
line-height: 1.2;
}

div.skip_expressions {
margin-bottom: 35px;
}


/*-----  aaPendingAddrs -----*/
div.matchOneHdr, div.matchManyHdr, div.matchNoneHdr {
padding-left: 100px;
margin: 6px;
}

div.matchOneHdr  { background: url(i__match_one)  no-repeat center left; }
div.matchManyHdr { background: url(i__match_many) no-repeat center left; }
div.matchNoneHdr { background: url(i__match_none) no-repeat center left; }


table.aaPending {
border-collapse: collapse;
}
table.aaPending tr th, table.aaPending tr td {
vertical-align: top;
}
span.lookupInput {
vertical-align: top;
}
table.aaPending tr.if { /*default state of action field rows; cannot set 'display' because, when showing, we must set to '' which will reset it to its stylesheet value (because IE is buggy and doesn't support 'table-row')*/
visibility: hidden; 
}
table.aaPending img.lookupIcon {
margin-bottom: -5px;
}
table.aaPending tr th span {
padding-left:12px;
font-size:8pt;
font-weight:normal;
}
table.aaPending tr td.required {
background: url(i__requiredBlock) no-repeat center left;
}

table.aaPendingFields {
border-width:0 0 0 1px !important;
}

div.saveStatus {
display:none;
font-style: italic;
background: url(i__ajaxloader) no-repeat center left;
padding-left: 20px;
}

div.actionError {
margin:6px;
border-bottom:1px solid red;
font-weight:bold;
color:red;
}

div.aaErrorArea {
margin: 20px;
margin-top: 0px;
padding: 10px;
}

div.aaErrorArea {
border: red 1px solid;
background: url(i__alert_32) no-repeat center left;
}

div.aaErrorArea div {
margin-left: 40px;
line-height: 1.2;
}


/*----- other common elements -----*/
div.pre {
whitespace:pre;
font-family: Monaco,Consolas,monospace;
}
.box {
padding:8px;
border:1px solid #D6D6D6;
}
td.nowrap {
white-space:nowrap;
}
span.comment {
margin-left: 12px;
}
.smalltext {
font-weight:normal;
font-size:91%;
white-space:normal;
}
div.smalltext {
padding-top: 6px;
}
.helptext {
font-weight: normal;
font-size: 91%;
font-style: italic;
}
span.case {
font-size: 75%;
margin-left: 8px;
}
span.case a {
padding-left: 2px;
padding-right: 2px;
}

div.prevNext {
text-align:center;
font-size:91%;
margin-top:-2px;
margin-bottom:2px;
}

div.fewerMore { /* addition to sfdc-provided style */
margin-top:2px;
}

div.snippetFrom, div.snippetTo {
float:left;
}

div.snippetFrom {
width:37px;
}

div.snippetTo { /* inbound mail marker */
padding-left:15px;
width:22px;
background: url(i__aabullet) no-repeat top left;
}
 
td.colTo {  /* inbound mail marker */
background: url(i__aabullet) no-repeat scroll 1px 5px;
}

td.rowTo { /* hilite inbound mail */
background-color: #FCFCFA;
}

td.clipCol { /* paperclip column */
width:8px;
}

td.sentCol { /* "Sent" column */
width:11em;
}


/* 'show/hide quoted text' links */
a.quotedText {
font-size: x-small;
text-decoration: none;
}

/* email lookup field (case/opp) style */
div.emailLookupField {
margin:4px 0 16px 8px;
}


/*
-------------------------------------------------------------------------------
Setup instructions
-------------------------------------------------------------------------------
*/

div.manualsteps ol li {
padding-bottom: 12px;
}

div.manualsteps ol li ol li {
list-style-type: lower-alpha;
padding-top: 6px;
padding-bottom: 0px;
margin-left:0px;
}
div.manualsteps ol li ol li p {
margin-top:0px;
padding-top:4px;
padding-bottom:0px;
margin-bottom:0px;
}

span.vidlink {
margin-left: 12px;
font-size: 90%;
}

span.vidlink a {
padding:2px;
color:blue;
}

/*
-------------------------------------------------------------------------------
yui-based 'loading...' modal popup
-------------------------------------------------------------------------------
*/
div#waitPanelHeader {
background:url("/img/alohaSkin/grid_headerbg.gif") repeat-x scroll 0 bottom #FFFFFF;
padding:8px;
font-size: 110%;
}
.hd span {
background: url(i__ajaxloader) no-repeat center left;
padding-left: 24px;
}
span.container-close {
top:7px;
}
