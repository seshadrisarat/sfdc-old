/* General Stuff */
body{
    overflow-y: hidden !important;
	overflow-x: auto !important;
}

.pointer{
	cursor: pointer;
}

/*.right{
	position: absolute;
	right: 0px;
}*/

/* Load Mask */
.wrapper {
    left: 50%;
    position: absolute;
    top: 50%;
}

/* 
 * SFDC Overrides
 */
.noSidebarCell, .sidebarCell .fixed{
	padding: 0px !important;
}

ul li, ol li{
	margin-left: 0 !important;
}

h1, h2, h3, h4, h5, h6{
	display: block !important;
}
.docViewerPanel {
	z-index: 1051;
}

/* 
 * Bootstrap 2.0.2 overrides
 */
.search-hidden{
    display:none;
}

/* fix the styling applied to a sfdc form*/
#sessiontimeout{
	margin-bottom: 0px !important;
}

#task-board{
   /* min-width:1300px !important;     keep content from skrining on smaller browser windows */
}

#inner-container{
	margin-right:300px;
}
#viewport-container{
	/*Kludge for OSX scrollbar bug*/
	/*overflow-x:auto;*/
	overflow-x:hidden;
}

.task-column{
	width: 300px !important;
	float:left;
	margin-left: 20px;
}

.kanban-column{
	/*position:relative;*/
}

#sidebar-chatter-refresh{
	height:8px;
}

#sidebar-chatter-refresh:hover{
	color:#3A87AD;
}

#sidebar-chatter-refresh i:before{
	font-size: 12px;
	margin-left: 4px;
	margin-top: 6px;
}

.sidebar-chatter-header{
	font-size: 11px;
	font-weight: bold;
	line-height: 18px;
	margin:4px;
}

.sidebar-chatter-user-image{
	display:block;
	border-radius: 50%;
	width: 30px;
	height: 30px;	
	margin: 5px;
	margin-top: 0px !important;
}

.sidebar-chatter-user-image-comment{
	display:block;
	border-radius: 50%;
	width: 20px;
	height: 20px;	
	margin: 5px;
	margin-top: 0px !important;
}
.sidebar-chatter-post-content-span{
	margin-left: 0 !important;
	min-height: 0 !important;
}
#sidebar-chatter-activity-container hr{
	margin: 4px 0;
}
.sidebar-chatter-record-name{
	font-family: arial, helvetica, clean, sans-serif;
	font-size:12px;
}

.sidebar-chatter-timeago{
	color: #7d7d84;
	font-size:11px;
}
.sidebar-chatter-hidden-comment{
	display:none;
}
.sidebar-chatter-comment-content{
	margin-top:4px;
	margin-bottom:4px;
}
#sidebar-chatter a{
	color:#015ba7;
}
.sidebar-chatter-show-hidden{
	margin-left:26px;
	margin-top:2px;
	margin-bottom: 2px;
}


/*generic buttons floating on the right */
#sidebar { float: left; width: 268px; margin-left: 0px; margin-right: 22px;}
#projects-sidebar{
	overflow-x: hidden;
}
#sidebar-placeholder{
	position: absolute;
	right: 0px;
	width: 20px;
	/*margin-top: -12px;*/
	height:200px;
	z-index: 1001;
}
#header-sidebar-buttons{
	position: absolute;
	right: 0px;
	width: 20px;
	top: 0px;
	height:40px;
}
.floating-sidebar-container{
	height:18px;
	width:18px;
	padding-left:1px;
	padding-top:4px;

  	border-left: 1px solid #cccccc;
  	border-top: 1px solid #cccccc;
  	border-bottom: 1px solid #cccccc;


	-webkit-border-top-left-radius: 2px;
	-webkit-border-bottom-left-radius: 2px;
	-moz-border-radius-topleft: 2px;
	-moz-border-radius-bottomleft: 2px;
	border-top-left-radius: 2px;
	border-bottom-left-radius: 2px;
}

.floating-sidebar-container-default-color{
	background-color: #f5f5f5;
	*background-color: #e6e6e6;
	background-image: -ms-linear-gradient(top, #ffffff, #e6e6e6);
	background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#ffffff), to(#e6e6e6));
	background-image: -webkit-linear-gradient(top, #ffffff, #e6e6e6);
	background-image: -o-linear-gradient(top, #ffffff, #e6e6e6);
	background-image: linear-gradient(top, #ffffff, #e6e6e6);
	background-image: -moz-linear-gradient(top, #ffffff, #e6e6e6);
	background-repeat: repeat-x;
}
.floating-sidebar-anchor i:before{
	font: 17px/.71em 'Glyphicons' !important;
	text-shadow: 0 -1px 0 rgba(0, 0, 0, 0.25);
}
#sidebar-placeholder a, #header-sidebar-buttons a{
	cursor: pointer;
	padding: 0;
}

/*header toggle stuff*/
#toggle-header i:before{
	font: 12px/.5em 'Glyphicons' !important;
}
#toggle-header-container{
	background-color: none !important;
	border: 0px;
	-webkit-border-top-left-radius: 6px;
	-webkit-border-bottom-left-radius: 6px;
	-moz-border-radius-topleft: 6px;
	-moz-border-radius-bottomleft: 6px;
	border-top-left-radius: 6px;
	border-bottom-left-radius: 6px;
	float:right;
	width: 14px;
	height: 14px;
}



/*Sidebar toggle stuff */
#toggle-sidebar i:before{
	color:white;
}
#toggle-sidebar-container{
	background-color: #3A87AD;
	border: 0px;
	-webkit-border-top-left-radius: 6px;
	-webkit-border-bottom-left-radius: 6px;
	-moz-border-radius-topleft: 6px;
	-moz-border-radius-bottomleft: 6px;
	border-top-left-radius: 6px;
	border-bottom-left-radius: 6px;
	float:right;
}
/*Fix for floating right sidebar*/
#container-fluid > .row-fluid{
	float: left; margin-right: -300px;
}

h1.pageType{
	line-height: inherit !important;
	margin-bottom:4px;
}

.nav .nav-header{
	padding: 0 !important;
	font-family: "Helvetica Neue",Helvetica,Arial,sans-serif !important;
	color: #333333 !important;
}

.navbar .btn-bs{
		
}

/*
 * nav-bar active override
 */
 .nav-list > li > a{
 padding: 3px 0 0 37px !important;
 }
.navbar .nav .active > a, .navbar .nav .active > a:hover{
	background-color: #E9E9E9 !important;
	border-left: 0 none !important;
	border-right-color: #DDDDDD !important;
	box-shadow: 0 3px 5px rgba(0, 0, 0, 0.05) inset !important;
	color: #08C !important;
}

/*
 * navbar inactive override
 */
.navbar .nav > li > a{
	color: #777 !important;
	border-left: 1px solid #F5F5F5 !important;
	border-radius: 0 0 0 0 !important;
	border-right: 1px solid #E5E5E5 !important;
	margin: 0 !important;
	padding-bottom: 7px !important;
	padding-top: 9px !important;	
}

.navbar .nav > li > a:hover{
	color: #005580 !important;
}

.nav-list{
	padding: 0 5px !important;
}

/*
 * Modals
 */
.modal-frame{
	border:none; 
	width:100%; 
	height: 100%;
}

.big-modal.modal{
 	width:900px !important;
 	/*This is done via JS when we open a modal now for window size getting*/
    /*margin-left: -420px !important;
    margin-top: -300px !important;*/
    overflow-y: hidden !important;
}
 
.big-modal-body{
    overflow-x: hidden;
    overflow-y: hidden !important;
    padding: 0px !important; 
    width:100% !important;
    height: 600px ;
    max-height: none !important;
}

.small-modal.modal{
	width:300px !important;
    height: 360px !important;
    /*margin-top: -350px !important;*/
    overflow-y: hidden !important;
}

.small-modal.modal-body{
    overflow-x: hidden;
    overflow-y: hidden;
    padding: 10px !important; 
    height: 360px;
    max-height: none !important;
}

.well-no-background{
	background-color: #fff !important;
}  

.nav-bar-input{
    margin-top:5px !important;
}

.label-fix{
    line-height: inherit !important;
}

.change-permissions-warning{
	width: 445px;
	text-align: left;
}

/*Header override*/
.navbar-inner-grey{
  background-color: #eeeeee; /* Old browsers */
  background-repeat: repeat-x; /* Repeat the gradient */
  background-image: -moz-linear-gradient(top, #f5f5f5 0%, #eeeeee 100%); /* FF3.6+ */
  background-image: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#f5f5f5), color-stop(100%,#eeeeee)); /* Chrome,Safari4+ */
  background-image: -webkit-linear-gradient(top, #f5f5f5 0%,#eeeeee 100%); /* Chrome 10+,Safari 5.1+ */
  background-image: -ms-linear-gradient(top, #f5f5f5 0%,#eeeeee 100%); /* IE10+ */
  background-image: -o-linear-gradient(top, #f5f5f5 0%,#eeeeee 100%); /* Opera 11.10+ */
  filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f5f5f5', endColorstr='#eeeeee',GradientType=0 ); /* IE6-9 */
  background-image: linear-gradient(top, #f5f5f5 0%,#eeeeee 100%); /* W3C */
  border: 1px solid #e5e5e5;
  -webkit-border-radius: 4px;
     -moz-border-radius: 4px;
          border-radius: 4px;	
} 

#header{
    background: -moz-linear-gradient(top,  rgba(205,232,240,1) 0%, rgba(229,242,246,0.5) 100%); /* FF3.6+ */
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(205,232,240,1)), color-stop(100%,rgba(229,242,246,0.5))); /* Chrome,Safari4+ */
    background: -webkit-linear-gradient(top,  rgba(205,232,240,1) 0%,rgba(229,242,246,0.5) 100%); /* Chrome10+,Safari5.1+ */
    background: -o-linear-gradient(top,  rgba(205,232,240,1) 0%,rgba(229,242,246,0.5) 100%); /* Opera 11.10+ */
    background: -ms-linear-gradient(top,  rgba(205,232,240,1) 0%,rgba(229,242,246,0.5) 100%); /* IE10+ */
    background: linear-gradient(top,  rgba(205,232,240,1) 0%,rgba(229,242,246,0.5) 100%); /* W3C */
    filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#cde8f0', endColorstr='#80e5f2f6',GradientType=0 ); /* IE6-9 */
}

/*
 * Header stuff
 */
.bPageTitle{
	margin-bottom: 0 !important;
}

.bPageTitle .ptBody .content{
	width: 100% !important; /*css file override*/
}

.pageTitleIcon{
	background: none !important;	/* hide default SFDC styles */
	margin: 0 5px 0 0 !important;
	height: 50px !important;
	width: 50px !important;
}

.pageType, .pageDescription{
	margin-left: 0 !important;
}

.nav-view-element{
	padding: 0 15px !important;
	color:black;
}

.nav-view-element:hover{
	/*background: #EEE !important;*/
	color:#0088CC;
}

.nav-view-element img{
	height: 32px;
	width: 32px;
}

.active-view{
	/*background: #EEE !important;*/
	color:#0088CC;
}

.active-view:hover{
	color:#0088CC;
}

#quick-add-text{
	width:60%;
	max-width: 250px;
}

#search-input{
	width:250px;
}

#user-photo{
	float: left;
	padding: .5em;
}

#header-links-wrapper{
	padding: 10px 0;
	padding-right: 8px;
}

.action-bar-button{
	min-width: 70px !important;
	text-align:center;
	margin-bottom: 2px;
}
.action-bar-button.active{
	border-bottom-width:2px !important;
	margin-bottom: 0;
}
/*
 * Columns
 */
.task-column{
	min-width:248px !important;
}

.active-column{
	display:block;
}

.inactive-column{
	display:none !important;
}

.left-most-column{
    margin-left: 20px !important;
}

/* task cards */
.task-list{
	float:left;
	margin:0 10px;
	display:none;
}

/*.task{
	position: relative;
	border: none;
	border-bottom: 1px solid #aaa;
	border-right: 1px solid #aaa; 
	cursor: move;
	min-width: 250px;

	overflow-x: hidden;
}*/

.task-card{
	border-left-width: 15px;
	border-left-style: solid;
	background-color: white;
}

.task-header-dropdown-button-container{
	float: left;
	margin-top: 6px;
	margin-left: 5px;
}

.task-list .sortable-list .task:first-child{
	/* order-top: 1px solid #aaa; */
}

.task.ui-sortable-helper{ /*no space! - this is for floating tasks*/
	border-top: 1px solid #aaa;
}

.task-header{
	position: relative;
	color: #222;
	font-weight: normal;
}

.task-header-content{
	/*position: relative; #Removed this because it went higher in the stacking order than the photo, making the tool tip not show up*/
	padding: 4px 8px;
	border-top: 1px solid #EEE;
	line-height: 20px;
}

.task-footer-content{
	
}

.task-header-content-nophoto{
	
}

.task-photo img{
	float: right;
	width: 30px;
	height: 30px;
	margin: 5px 5px;
}

.task-name{
	font-size: 14px;
	line-height: 14px;
	font-family: 'Helvetica Nueve', Helvetica, sans-serif;
	margin-top: 5px;
}

.task-name-width-photo{
	width:85%;
}

.task-icon{
	width: 17px;
	height: 17px;
	background-repeat: no-repeat;
	background-position: 0px -14px;
	cursor: pointer;
}

.task-icon-selected {
	background-position: 0px 0px;
}

.follow-unfollow{
	margin-left:8px;
	margin-top:6px;
}

.task-follow-toggle-container{
	cursor: pointer;
	float: left;
}

.task-follow-toggle-container a{
}

.task-follow-toggle-container span{
}

.task-follow-toggle-container:hover a{
    text-decoration: underline;
}

.task-action-item{
	background: url("/img/feeds/follow_sprite.png") no-repeat scroll 0 -54px transparent;
    width: 15px;
    height: 15px;
}

.sort-disabled{
	cursor:not-allowed;
}

.unfollow-container{
	cursor: default;
}

.task-follow-toggle{
	cursor: pointer;
}

.unfollow-container:hover .task-follow-toggle{
	background: url("/img/feeds/follow_sprite.png") no-repeat scroll 0 -75px transparent;
}

.task-tag{
	word-wrap: break-word;
	white-space: normal !important;
}

.task-deadline-tags{
width:auto !important;

}

.task-deadline-date{
	float: left !important;
	text-align: right;
	width: 68px;
	margin-top: 9px;
	margin-left: 8px;
}

.task-deadline-name{
	font-size: 12px;
	font-weight:bold;
	font-family: 'Helvetica Nueve', Helvetica, sans-serif;

}

.task-deadline-overdue{
	color: #c00;
}

.task-deadline{
	width:100%;
}

.task-content{
	border: 1px solid #ccc;
	border-top: none;
}

.task-table{
	margin-left: 2px;
}

.task-table td{
	border-bottom: 1px solid #ECECEC;
}

.task-card-photo{
	width: 22px;
	height: 22px;
	border-left: 12px !important;	
}

td.api-name{
	padding-right: 0 !important;
	font-size: 12px !important;	
}

td.labelCol{
	width:18%;
	font-size: 11px;
	font-weight: 700;
	color: #4A4A56;
	line-height: 13.3px;
	text-alight: right;
	vertical-align: top;
	font-style: normal;
	padding: 3px 0 !important;
}

.topic-box-header{
	border-bottom: 1px solid #D4DADC;
	height: 1.2em;
	padding-bottom: 3px;
	padding-top:10px;
}

h3.topic-widget-header{
	color: #000;
	float: left;
	font-weight: bold;
}

.sortable-list{
	/*Kludge for OSX scrollbar bug*/
    /*overflow-y: auto;*/
    overflow-y: hidden;
    overflow-x: hidden;
	padding: 5px !important;
	min-height: 60px !important;
	/*min-height: 200px !important;
	min-width:260px;*/
}

/* Sidebars */
#sidebar{
    padding: 8px 0 0 2px !important;
    overflow-y: auto;
    overflow-x: hidden;
}

.sidebar-form{
	margin-bottom: 0 !important;
}

#sidebar-list ul li, ol li{
	margin: 5px auto !important;
}

.sidebar-btn{
	/*margin-top: -8px !important;
	margin-right: 8px; 
	float: right;*/
}

.sidebar-files-link{
	margin: 5px;
	border-bottom: 1px solid #E9EAEA;
	padding: 2px;-
}

.files-icon{
	margin: 0 2px -3px 0;
}

a.filelink{
	margin: 0 2px;
	color: #015BA7;
	text-decoration: none;	
}

.project-select{
	cursor: pointer;
}

.project-select a {
	color: #333435 !important;
}

.search-project-select{
	margin: 0 0;
	padding: .6em .1em .6em .25em;
	width: 100%;
	cursor: pointer;
}

.project-select-hover{
	
}

.project-select-hover-over{
	background-color: #F8DA4E;
}

.project-actions{
	float: right;
	margin: 0 .2em;
}

.project-actions{
	text-decoration: none;
	margin: 5px;
} 

.project-action-icon:hover{
	color: #3A87AD;
}

.project-action-icon{
	padding: 0 !important;
	padding-right: 4px !important;
	height:14px;
	width:14px;
}
.project-action-icon i:before{
	font-size:14px !important;
}
.project-list-square{
    background: none repeat scroll 0 0 #FFFFFF;
    border: 1px solid #DCDCDC;
    border-radius: 1px 1px 1px 1px;
    height: 11px;
    margin: 5px;
    margin-bottom:0px;
    top: 2px;
    width: 11px;	
	float:left;
}

.project-name-link{
	text-decoration: none;
	max-width:155px; 
	text-align:left; 
	float:left;
}

.project-name-link:hover{
	text-decoration: none;
	color: black; 
}

.project-action-icon-current{
	padding: 2px .5em;
	-moz-border-radius: 3px;
	-webkit-border-radius: 3px;
	border-radius: 3px;
	font-size: 11px;
	font-weight: bold;
	margin-top: -3px;
	text-decoration: none;
	background-color: #999999;
	display:hidden;
	color: #FFF;	
}

.project-action-icon-noncurrent{
	padding: 2px .5em;
	-moz-border-radius: 3px;
	-webkit-border-radius: 3px;
	border-radius: 3px;
	font-size: 11px;
	font-weight: bold;
	margin-top: -3px;
	text-decoration: none;
	background-color: #999999;
	display:hidden;
	color: #FFF;	
}

/*Project lock icon*/
.project-lock-icon-div{
	margin-top: 7px;
}
.project-lock-icon-div i:before{
	font: 6px/.25em 'Glyphicons' !important;
}

.project-lock-icon-div-white i:before{
	color: white !important;
}

.project-lock-icon-div-black i:before{
	color: black !important;
}

.project-collapse-container{
	float:left;
	width:12px;
	height:12px;
	margin-top:6px;
}
/*sidebar collapse icons*/
#sidebar .halflings.minus i:before, #sidebar .halflings.plus i:before{
	font-size:10px !important;	
}

.display-unassigned-tasks{
	margin-top: 7px;
}

.action-bar-input{
	padding: 3px .5em;
	margin: 0 1em;
	display: inline;
	border-radius: 5px;
	-moz-border-radius: 5px;
	-webkit-border-radius: 5px;
	display: block;
	float: left;
}

#search{
	width:250px;
	float: left;
}


/*Content*/


.clear{
	clear: both;
	height: 0px;
}

/*project-dropdown-button*/
.project-dropdown-button{
	cursor: pointer;
	float: left;
	margin: 2px 5px;
	font-weight: bold;
	color: white;
}
		
.project-dropdown-list{
	background-color: white;
	/* border: 1px solid black;*/
	padding: .5em;
	clear: both;
}
		
.project-dropdown-list ul{
	list-style: none;
	padding: 0px;
}

/*task placeholder*/
.ui-state-highlight {
	width: 100%;
	height: 60px;
	background-color: red !important;
	background: none !important;
	border: 1px dotted #666666 !important;
	
}

.ui-sortable-helpclass{
	height: 50px;
	width: 100%;
}

/*UI Override*/

.ui-dialog-titlebar{
	background: #f5f5f5 none no-repeat !important;
	border: 1px solid #f5f5f5 !important;
}

.ui-dialog-buttonset{
    text-align: center;
    float: none !important;
}

/*Font fix*/

.font-fix{
	/* font-family: Arial, Helvetica, sans-serif !important; */
}

/* JQuery Overlay */

.ui-dialog{
	border: 1px solid #aaa;
}

/*Group member thumbnail stuff*/
.memthumbnail{
	padding-right:4px;
	padding-top:4px;
}

#group-members-sidebar-header{

}

#group-members-photos{
	width:90.5%;
	padding: 0 8px;
	max-height:118px;
	overflow:hidden;
}

.members-photos{
	padding: 0 8px;
	/*max-height:112px;
	overflow:hidden;*/
}

.members-outline{
	border: 2px solid grey;
	border-radius: 5px;
	padding-bottom: 3px !important;
}

#showallmems
{
	float:left;
	color: #015BA7;
	text-decoration:none;
    font-size: 10px;
    margin-bottom: -4px;
}

/* Group Board CSS */
.group-name{
	float: left;
	width: 160px;
}

#chatter-group-dropdown{
	max-width: 99%; /* account for shrinking sidebar overlap*/
	}

.group-photo-img-sidebar{
	height: 35px;
	width: 35px;
	margin-right:5px;
	float: left;
}

.selected-group{
	color: orange;
	font-weight: bold;	
}

.group-sidebar-element{
	margin-bottom: 1em;
	cursor: pointer;
	display:inline-block;
}

div.group-sidebar-element.selected-group{
	color: #ff6600;
	font-weight: bold;
}

.bracketLabsSupport, .bracketLabsFeedBack, .trPrefs
{
	height:20px !important;
}

.project-follow-toggle{
	float:left;
	padding-left:5px;
	padding-right:5px;
}

.project-unfollow-img{
	background: url("/img/feeds/follow_sprite.png") no-repeat scroll 0 -54px transparent;
	height: 15px;
	margin-left: 2px;
	width: 15px;
}

.project-follow-toggle:hover .project-unfollow-img{
	background: url("/img/feeds/follow_sprite.png") no-repeat scroll 0 -75px transparent;
}

/* 
 * Deadline View
 */
#deadline-view{
	display:none;
}

#accordion2{
	overflow-y: auto;
}

.accordion-heading{
    border-bottom: 1px solid #eee;
    margin-bottom: 5px;
}

.deadline-view-task{
	cursor: pointer;
	padding: 10px !important;
	min-height: 12px !important;
	margin-bottom: 4px !important; 
	padding-bottom: 4px !important;
}

.task-deadline-project{width:16px;height:16px;float:left;margin-top:8px;task}

/*Project Search Stuff*/
.project-actions-search{
	float: right;
	margin: 0 .2em;
}

/*Deadline View Button*/
.deadline-header-count{
	text-decoration: none !important;
	margin: 5px;	
}
#search-projects-modal-body .project-actions{
	width: 90px;
}

.deadline-header-count:hover{
	text-decoration: none;	
}

.deadline-action-bar-button{
	-webkit-user-select: none;
	-moz-user-select: none;
	user-select: none;
	cursor: pointer;
	padding: 4px 6px;
}

.deadline-action-bar-button:hover{
	background-color: #bbe4f1;
}

.deadline-action-bar-button-selected{
	background-color: #39B0D6;
	color: white;
	cursor: pointer;
	border-radius: 4px;
	-webkit-border-radius: 4px;
	-mox-border-radius: 4px;
	border: 1px solid #EFEFEF;
	border-bottom-color: #666666;
	border-right-color: #666666;
}

.deadline-view-task .taskcard-next-icon{
	/*opacity: .7;
	transition: .25s Ease;
	height: 18px;
	margin-left: 6px;
	padding: 0;
	margin-top: 2px;
	width: 14px;*/
	padding-right:8px;
	padding-top: 8px;
	padding-bottom: 8px;
	float:right;
}
.deadline-view-task .taskcard-next-icon i:before{
	font-size: 20px;
	margin-top: -1px;
	margin-left: 0px;
}

.deadline-view-task .taskcard-deadline-icon{
	height: 16px;
    margin-top: -1px;
    padding: 0 4px 0 0;
    width: 16px;
}

.deadline-view-task .taskcard-deadline-icon i:before{
	font-size:16px;
}

.deadline-task-list-container{
	float:right;
	margin-top: 9px;
	width:30%;
}

.deadline-view-task .taskcard-deadline-text{
	font-family: 'Helvetica Nueve', Helvetica, sans-serif;
	color: #333333;
}

.deadline-view-task .taskcard-deadline-text-overdue{
	color: red !important;
}

.deadline-view-task .taskcard-project-name{
	font-family: 'Helvetica Nueve', Helvetica, sans-serif;
	margin-right: 4px;
	color: #3a87ad;
	text-overflow:ellipsis;
}

.disable-action-bar-button{
	background-color: #888888;
	color: white;
	cursor: pointer;
	border-radius: 2px;
	-webkit-border-radius: 2px;
	-mox-border-radius: 2px;
	border: 1px solid #aaaaaa;
	border-bottom-color: #666666;
	border-right-color: #666666;
	cursor: default !important;
	background-color:#EDEDED !important;
	color: black !important;
}

/* 
 *  ToolTips
 */
.project-members-tooltip{
	min-width:200px;
}

.projects-tooltip{
	min-width:200px;
}

.group-sidebar{
	min-width:200px;
}

#groupmem-header{
	
}

.projmem-drag{
	cursor: move;	
}

.feedback-tooltip{
	min-width:200px;
}

.group-sidebar{
	min-width:200px;
}

.notification_itemname{font-weight: bold;}
.notification_username{font-weight: bold;}
.notification_newchange{font-weight: bold;}

#new-project-btn{text-transform:capitalize;}
#search-projects{text-transform:capitalize;}
#search-projects-header{padding:4px;}

#projectSearchResults{padding:0px;}

button.close{
	background: none repeat scroll 0 0 transparent;
    border: 0 none;
    cursor: pointer;
    padding: 4px;
}

.action-bar-button-disabled a{
	cursor: default !important;
}

.project-file-filelink, .project-file-link{
	cursor: pointer;
}

.project-files-icon{
	width:12px;
	height:12px;
	padding: 0 !important;
}

.project-files-icon i:before{
	color: #333333;
}
/*
 *	Make these look like Twitter bootstrap links
 */
.project-file-name{
	padding-left: 4px;
	color: #08C;
}

.project-file-name:hover{
	color: #005580;
	text-decoration:underline;	
}

#view-select-container{
	margin-top:16px;
}

#view-select-container li{
	text-align:center;
}

#header-links-wrapper .pointer{
	padding: 1px;
}

.taskboard-column-header h4{
	float: left;
	color: #333333;
}

.taskboard-column-header-count{
	float:left;
	display: none;
	margin-left:4px;
}

.task-card-files-attached{
	float:right;
	margin-left:-10px;
	margin-right:0px;
	margin-top:6px;
}

/* 
 *	This selector has a background image pulled from 
 *	static resources on the page
 */
.task-card-feed{
	width:22px;
	height:16px;
	margin:7px 4px;
}

.new-feed-notifcations{
	background-color: rgba(87,176,32,255) !important;
	margin: 4px !important;
    padding: 0px 2px !important;
    position: relative;
    right: -6px;
    top: -18px;
}

.task-deadline-photo{
	width: 30px;
	height: 30px;	
	margin: 5px;
	margin-top: 0px !important;
}

.task-deadline-text{
	margin-top:10px;
	min-height: 0 !important;
}

.deadline-view-task .start-button{
	margin-right:12px;
}

.addProjectToChatterGroup{
	width: 16px;
}

.infoButton{
	padding-left: 2px;
	float:left;
}

#search-projects-header{
	float:left;
}

#groups-sidebar-header{
	margin:0px;
	float:left;
}

#search-projects-modal .infoButton{
	padding-top:6px;
}

#sidebar .infoButton{
	padding-top:2px;
}

#label-searchArchivedInput{
	float:left;
	font-size: 11px;
    font-weight: bold;
    padding-left: 6px;
}

#searchArchivedInput{
	float:left;
}
.task-deadline-text {
    max-width: 395px !important;
}
#projectSearchTermInput{
	width: 200px !important;
	float: left;
}
#searchProjectsBtn{
	float:right;
}
#projectSearchResults{
	height:240px;
	overflow-x: hidden;
    overflow-y: auto;
}

.project-select a span{
	font-size:11px;
}
#group-members-photos-label{
	float:right;
	color: gray;
	font-size:10px;
	margin-bottom: -4px;
}
#view-as-reset{
	border-radius: 0 3px 3px 0;
}
.expand-project{
	cursor:pointer;
}
.collapse-project{
	cursor:pointer;
}
.rightPanel .planning-view-unassigned-project, .rightPanel .planning-view-unassigned-task, .planning-view-task, .rightPanel .quick-add-placeholder{
	box-shadow: none !important;
	background-color: transparent !important;
}
/*if there is a progress div below an unassigned project, don't show it*/
.rightPanel .planning-view-unassigned-project .progress-div{
	display:none;
}
.planning-view-unassigned-project-drag, .planning-view-unassigned-task-drag{
	margin-top: 4px;
	position: absolute !important;
	right: 2px;
	cursor: ew-resize;
}

.planning-view-goto-item{
	margin-top: 4px;
	position: absolute !important;
	right: 2px;
	cursor: pointer;
	height: 14px;
	width: 14px;
	padding: 0 !important;
}
.planning-view-goto-item i:before{
	color: #484A4D !important;
	font-size: 11px !important;
	padding-left: 4px;
	padding-top: 2px;
}

.planning-view-task-drag{
	margin-top: 2px;
	position: absolute !important;
	left: 4px;
	cursor: ew-resize;
}

#planning-view{
	overflow-y:auto;
	overflow-x:auto;
	padding: 0px !important;
}

#planning-view .ui-widget-shadow{
	background: transparent !important;
}

#planning-view .leftPanel{
	overflow: visible;
	z-index:1000;
	position: absolute;
}
#planning-view .rightPanel{
	/*overflow: hidden;
	z-index:20;*/
	margin-left: 225px;
}
#column-view{
	margin-top: 10px;
}
#gantt-chart{
	padding-bottom:20px;
	position:relative;
	z-index:1000;
	width:10000px;

}
#gantt-chart .fn-gantt .bar, #gantt-chart .fn-gantt .leftPanel .name{
	cursor: pointer;
}
#gantt-chart .fn-gantt .fn-label img{
	margin-top: -4px;
}

.progress-div-left{
	-webkit-border-top-left-radius: 3px;
	-webkit-border-bottom-left-radius: 3px;
	-moz-border-radius-topleft: 3px;
	-moz-border-radius-bottomleft: 3px;
	border-top-left-radius: 3px;
	border-bottom-left-radius: 3px;
}

.progress-div-right{
	-webkit-border-top-right-radius: 3px;
	-webkit-border-bottom-right-radius: 3px;
	-moz-border-radius-topright: 3px;
	-moz-border-radius-bottomright: 3px;
	border-top-right-radius: 3px;
	border-bottom-right-radius: 3px;	
}

.progress-div{
	position:absolute;
	height:100%;
}

.progress-div-text{
	width:100%;
	text-align:center;
	margin-top:2px;
	position:absolute;
	left: 0;
	font-family: Arial,Helvetica,sans-serif;	
}

.planning-quick-add{
	height: 13px !important;
	width: 140px !important;
	font-weight:normal !important;
	font-size: 11px !important;
	color: #333435 !important;
}

.planning-view-task-label{
	font-weight:normal !important;
	font-size: 11px !important;
	color: #333435 !important;
	/*text-shadow: 0 1px 0 rgba(255, 255, 255, 0.5);	*/
}

#planning-view-wrapped-header{
	float: left;
	position: absolute;
	z-index:11;
}
#planning-view .row.spacer.spacer-absolute{
	position: absolute;
	z-index:11;
	margin-bottom: 0px;
	margin-top: 0px;
	padding-bottom:1px;
	border-bottom: 1px solid #DDDDDD;
}

.planning-view-overdue-task-bg{
	-webkit-border-radius: 2px;
	-moz-border-radius: 2px;
	border-radius: 2px;
}

.bar {
	z-index:10;
}
#planning-view .dataPanel{
	position: relative;
	margin-left: 0 !important;
}
.leftPanel .halflings.map-marker{
	padding: 0 !important;
	height: 14px;
	width: 14px;
}
.leftPanel .halflings.map-marker i:before{
	right: 0 !important;
	left: auto !important;
}
.leftPanel .halflings.minus, .leftPanel .halflings.plus{
	/*padding: 0 0 0 4px !important;*/
	width: 12px;
	height: 12px;
	
}
.leftPanel .halflings.minus i:before, .leftPanel .halflings.plus i:before{
	font-size:10px !important;	
	color: #484A4D !important;
	left: auto;
	top: 2px;
}
.fn-gantt .navigate .nav-zoomOut, .fn-gantt .navigate .nav-zoomIn, .fn-gantt .navigate .nav-now{
	float:left;
	margin-top: 0px !important;
}
.fn-gantt .navigate .btn-bs-group{
	float:left;
	padding-top: 0px;
}
.fn-gantt .navigate .btn-bs-group .btn-bs{
	margin-left: -1px;
}
.fn-gantt .navigate .nav-slider-content{
	float:left;
}
#quick-add-text-wrapper{
	margin-bottom: 0;
}
#quick-add-text-wrapper .input-append{
	width: 100%;
}
#quick-add-text-wrapper .navigate{
	border-top: 0 !important;
}

/*kludge to put overlay on top of planning view*/
.ui-widget-overlay, #canvasloader-container{
	z-index: 1001;	
}

/* way the hell off screen */
.scrollbar-measure {
	width: 100px;
	height: 100px;
	overflow: scroll;
	position: absolute;
	top: -9999px;
}

/*new taskcard styles*/
.task{
	max-width:288px;
	/*width:288px;
	min-height:48px;*/
	
	border-color: #aaa;
	border-width: 1px;
	border-top-width: 0px;
	border-left-width: 0px;
	border-style: solid;
	position: relative;
	overflow-x: none;
	cursor: move;
}
.sortable-list div:first-child{
	border-top-width:1px;
}
.taskcard-full-width{
	width: 100%;
}

.taskcard-top-container{
	padding-top:2px;
}

.taskcard-padding-between-name-and-tags{
	padding-top: 2px;
}

.task .taskcard-tag{
	float:left;
	/*line-height: inherit !important;*/
	margin: 1px;
}

.task .taskcard-bottom-toolbar-container{
	margin-left:4px;
	height:18px;
}

.task .taskcard-task-name{
	font-size: 12px;
	font-weight:bold;
	font-family: 'Helvetica Nueve', Helvetica, sans-serif;
	margin-left: 4px;
	padding-top: 2px;
	padding-bottom: 0;
}

.task .taskcard-project-color{
	width:14px;
	height:14px;
	margin:2px;
}

.task .taskcard-wrapper{
	background-color: white;
}

.task.selected-task .taskcard-wrapper{
	background-color: #FEFE9A;
}

.task.blocked-task .taskcard-wrapper{
	background-color: #EEB3B2;
}

.task.blocked-task.selected-task .taskcard-wrapper{
	background-color: #F6D8A6;
}

.task .taskcard-project-name-container{
	margin-bottom:2px;
}

.task .taskcard-project-name{
	font-size: 11px;
	font-family: 'Helvetica Nueve', Helvetica, sans-serif;
	margin-left: 4px;
	color: #3a87ad;
	white-space: nowrap;
	overflow: hidden;
	text-overflow:ellipsis;
	width:225px;
}

.task .taskcard-deadline-container{
	height:100%;
	width:70px;
	overflow: hidden;
}
.task .taskcard-link-container, .task  .taskcard-chatter-container, .task  .taskcard-cog-container, .task  .taskcard-next-container{
	height:100%;
	width: 28px;
}
.task .taskcard-bottom-toolbar-icon{
	height: 14px;
	margin-left: 6px;
	padding: 0;
	margin-top: 2px;
	width: 14px;	
	padding-right: 4px;
}
.task .taskcard-bottom-toolbar-icon i:before{
	font-size: 14px;
	color: #333333;
}

.task .taskcard-bottom-toolbar-icon-small{
	height: 13px;
	margin-left: 3px;
	padding: 0;
	margin-top: 2px;
	width: 13px;	
}
.task .taskcard-bottom-toolbar-icon-small i:before{
	font-size: 13px;
	color: #333333;
}

.task .taskcard-deadline-icon{
	margin-left: 0px !important;
}

.task .taskcard-next-icon{
	height: 14px;
	margin-left: 6px;
	padding: 0;
	margin-top: -2px;
	width: 14px;	
	padding-right: 4px;

}
.task .taskcard-next-icon i:before{
	font-size: 20px;
	color: #333333;
}
.task .taskcard-next-icon:hover{
	opacity:1;
}
.task .taskcard-chatter-icon{
	height: 18px;
	margin-left: 6px;
	padding: 0;
	margin-top: 0px;
	width: 18px;	
}
.task .taskcard-chatter-icon i:before{
	color: #333333;
	font-size: 18px;
}

.task .taskcard-deadline-text{
	margin-left:0px;
	margin-top: 3px;
	font-size:11px;
	font-family: 'Helvetica Nueve', Helvetica, sans-serif;
	width:40px;
	white-space: nowrap;
	text-overflow: ellipsis;
	color: #333333;
}

.task .taskcard-deadline-text-overdue{
	color: red !important;
}

.task .taskcard-chatter-follow-toggle{
	width:45px;
}
.task .taskcard-unfollow-task{
	padding-right:5px;
}
.task .taskcard-next-container{
	margin-right:6px;
}
.taskcard-photo-container{
	margin-left: 2px;
	padding-right: 2px;
}

.task .taskcard-blocked-toggle-icon{
	height: 12px;
	margin-left: 0px;
	margin-right: 4px;
	padding: 0;
	margin-top: 3px;
	width: 12px;
}
.task .taskcard-blocked-toggle-icon i:before{
	font-size: 12px;
	color: #333333;
}

.taskcard-cog-icon, .taskcard-next-icon{
	cursor: pointer;
}

.taskcard-top-left-container{
    margin-right: 26px;
    position: relative;
}

.taskcard-top-left-item{
	position:relative;
	min-width:225px;
}

.taskcard-follow-toggle{
	cursor: pointer;
}
.task .taskcard-follow-task i:before{
	color:#64B300;
}

.task .taskcard-unfollow-x i:before{
	color: #AAAEB3;
}

.task .taskcard-unfollow-check i:before{
	color: #16ABDD;
}

.task .taskcard-unfollow-x:hover i:before, .task .taskcard-cog-icon:hover i:before, .deadline-view-task .taskcard-next-icon:hover i:before, .task .taskcard-next-icon:hover i:before, .task .taskcard-follow-task:hover i:before{
	color: #3A87AD;
}

.task .label,.badge, .deadline-view-task .label{
	font-size: 10px;
	font-weight: bold;
}

.taskcard-action-icon{
	height:40px;
	width:40px;
	position:absolute;
	left:50%;
	margin-left: -20px;
	top:50%;
	margin-top:-20px;
}

.taskcard-action-icon .glyphicons i:before{
	font: 40px/1em 'Glyphicons';
	color: pink;
}
/* end new taskcard styles*/




.task-column .last-column-archive{
	width: 14px;
	height: 14px;
	padding: 0;
	margin-top: 2px;
	margin-right: 4px;
	cursor: pointer;
}

.task-column .last-column-archive i:before{
	color: #333333;
	font-size: 14px;
	
}

.button-disabled{
	cursor:not-allowed;
}

.bulk-project-select-container a{
	font-size: 11px;
	cursor: pointer;
}

.sidebar-bin-icon{
	padding: 0 !important;
	cursor: move;
	height:20px;
	width:20px;
	margin-top: 20px;
	color: #333333;
	margin-right: 4px;


}
.sidebar-bin-icon i:before{
	font-size:15px !important;
}

.delete-hover-styling{
	border-style: outset !important;
}