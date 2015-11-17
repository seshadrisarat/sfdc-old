 th.header { 
            text-align:left;
            background-image: url({!URLFOR($Resource.dirs_img_css, '/img/bg.gif')});
            cursor: pointer; 
            font-weight: bold; 
            background-repeat: no-repeat; 
            background-position:right center ; 
            padding-left: 7px;
            margin-left: -1px;
            margin-right:20px;
        }       

        th.headerSortUp {
            background-image: url({!URLFOR($Resource.dirs_img_css, '/img/asc.gif')});
            background-color: #e5e6e8;
        }
        
        th.headerSortDown {
            background-image: url({!URLFOR($Resource.dirs_img_css, '/img/desc.gif')});
            background-color: #e5e6e8;
        }

        td.no_bor_l_r { border-left-color:#FCFCFC  !important; border-right-color:#FCFCFC  !important; }
        td.no_bor_l{border-left-color:#FCFCFC  !important;}
        td.no_bor_r{border-right-color:#FCFCFC  !important;}
        
        .leftTd {
            text-align : right ! important;
        }
		.rightTd {
            text-align : right ! important;
        }
        .centerTd {
            text-align : center ! important;
        }
        

        .blackF{ color: red;}
        .inputClassT{width:420px;height:33px;_width:420px;_height:33px;/width:420px;/height:33px;}
        .lookupIconT{margin-bottom:-5px;}
        .inputlookupT{width:170px;_width:170px;/width:170px;font-color: #111111;}
        .ui-mystyle { widht: 20px; }
    
	.inputlookupTdiv
	{
		position:absolute;
		visibility:hidden;
		display:none;
		width:170px;
		background-color: #FFFFFF;
		border: 1px solid #CCCCCC;
		padding:0px 0px 3px 3px;
	}
	.ui-qs-list 
	{
		display:none;
		outline-style:solid;
		outline-color:#000;
		outline-width: 1px;
		width:140px;
	}
	.ui-qs-list div {
		height: 20px;
		vertical-align:super;
	}
	.ui-show 
	{
		display:block;
		visibility:visible;
	}
	.ui-hide 
	{
		display:none;
		visibility:hidden;
	}
	.ui-current 
	{
		background-color:#CCC;
	}
	.validatorMesssage 
	{
		color:#F00;_color:#F00;/color:#F00;
	}
 
        
.ui-datepicker  .ui-datepicker-close{ display:none;}

div.ui-datepicker{font-size:12px;}
.ui-datepicker table {margin:0!important;}

/* Component containers
----------------------------------*/
.ui-datepicker .ui-widget { font-family: Verdana,Arial,sans-serif; font-size: 1.1em; }
.ui-datepicker .ui-widget .ui-widget { font-size: 1em; }
.ui-datepicker .ui-widget input,  .ui-widget select, .ui-widget textarea, .ui-widget button { font-family: Verdana,Arial,sans-serif; font-size: 0.8em;  }
.ui-datepicker .ui-widget button { color:#015ba7 !important; }
.ui-datepicker .ui-widget-content { border: 1px solid #aaaaaa; background:none;  color: #222222; }
.ui-datepicker .ui-datepicker .ui-datepicker .ui-widget-content a { color: #222222; }
.ui-datepicker .ui-widget-header { border:none; background:none;  color: #222222; font-weight:normal; font-size:0.9em; }
.ui-datepicker .ui-widget-header select{ border: 1px solid #aaaaaa; margin: 2px;}
.ui-datepicker .ui-widget-header a { color: #222222; }

/* Interaction states
----------------------------------*/
.ui-datepicker .ui-state-default, .ui-datepicker .ui-widget-content .ui-state-default, .ui-datepicker .ui-widget-header .ui-state-default { border: 1px solid #fff;  background:none; font-weight: normal; color:#666; }
.ui-datepicker .ui-state-default a, .ui-datepicker .ui-state-default a:link, .ui-datepicker  .ui-state-default a:visited { color: #555555; text-decoration: none; }
.ui-datepicker .ui-state-hover, .ui-datepicker .ui-widget-content .ui-state-hover, .ui-datepicker .ui-widget-header .ui-state-hover, .ui-datepicker .ui-state-focus, .ui-widget-content .ui-state-focus, .ui-datepicker .ui-datepicker .ui-widget-header .ui-state-focus {border: 1px solid #fff;  font-weight: normal; color: #000; background:#e3f3ff; }
.ui-datepicker .ui-state-hover a, .ui-datepicker .ui-state-hover a:hover { color: #212121; text-decoration: none; }
.ui-datepicker .ui-state-active, .ui-datepicker .ui-widget-content .ui-state-active, .ui-datepicker .ui-widget-header .ui-state-active { border: 1px solid #f3f3f3; background: #c6e1ff ; font-weight: normal; color: #212121; font-weight:bold; }
.ui-datepicker .ui-state-active a, .ui-datepicker .ui-state-active a:link, .ui-datepicker .ui-state-active a:visited { color: #212121; text-decoration: none; }
.ui-datepicker .ui-widget :active { outline: none; }

/* Interaction Cues
----------------------------------*/
.ui-datepicker .ui-state-highlight, .ui-widget-content .ui-state-highlight, .ui-widget-header .ui-state-highlight  {border: 1px solid #99ccff; background: #c6e1ff; color: #363636; }
.ui-datepicker .ui-state-highlight a, .ui-widget-content .ui-state-highlight a,.ui-widget-header .ui-state-highlight a { color: #363636; }
.ui-datepicker .ui-state-error, .ui-widget-content .ui-state-error, .ui-widget-header .ui-state-error {border: 1px solid #cd0a0a;  color: #cd0a0a; }
.ui-datepicker .ui-state-error a, .ui-widget-content .ui-state-error a, .ui-widget-header .ui-state-error a { color: #cd0a0a; }
.ui-datepicker .ui-state-error-text, .ui-widget-content .ui-state-error-text, .ui-widget-header .ui-state-error-text { color: #cd0a0a; }
.ui-datepicker .ui-priority-primary, .ui-widget-content .ui-priority-primary, .ui-widget-header .ui-priority-primary { font-weight: bold; }
.ui-datepicker .ui-priority-secondary, .ui-widget-content .ui-priority-secondary,  .ui-widget-header .ui-priority-secondary { opacity: .7; filter:Alpha(Opacity=70); font-weight: normal; }
.ui-datepicker .ui-state-disabled, .ui-widget-content .ui-state-disabled, .ui-widget-header .ui-state-disabled { opacity: .35; filter:Alpha(Opacity=35); background-image: none; }

/* Icons
----------------------------------*/

/* states and images */

    .ui-datepicker .ui-widget-header .ui-icon {background-image: url( {!URLFOR($Resource.datepicker, '/datepicker/ui-icons_222222_256x240.png')}); }

    .ui-datepicker .ui-state-hover .ui-icon, .ui-datepicker .ui-state-focus .ui-icon {background-image: url( {!URLFOR($Resource.datepicker, '/datepicker/ui-icons_454545_256x240.png')}); }



/* Overlays */
.ui-datepicker .ui-widget-overlay { opacity: .30;filter:Alpha(Opacity=30); }
.ui-datepicker .ui-widget-shadow { margin: -8px 0 0 -8px; padding: 8px;  opacity: .30;filter:Alpha(Opacity=30); -moz-border-radius: 8px; -webkit-border-radius: 8px; border-radius: 8px; }/* Datepicker
----------------------------------*/
.ui-datepicker td {text-align:right; }
.ui-datepicker .ui-state-disabled{padding-right:.4em;}  
.ui-datepicker { width: 17em; padding: .2em .2em 0; background:#fbfbfb; }
.ui-datepicker .ui-datepicker-header { position:relative; padding:.2em 0; }
.ui-datepicker .ui-datepicker-prev, .ui-datepicker .ui-datepicker-next { position:absolute; top: 2px; width: 1.8em; height: 1.8em; }
.ui-datepicker .ui-datepicker-prev-hover, .ui-datepicker .ui-datepicker-next-hover { top: 1px;}
.ui-datepicker .ui-datepicker-prev { left:2px; }
.ui-datepicker .ui-datepicker-next { left:10.5em; }
.ui-datepicker .ui-datepicker-prev-hover { left:1px; }
.ui-datepicker .ui-datepicker-next-hover { left:10.45em;}
.ui-datepicker .ui-datepicker-prev span, .ui-datepicker .ui-datepicker-next span { display: block; position: absolute; left: 50%; margin-left: -8px; top: 50%; margin-top: -8px;  }
.ui-datepicker .ui-datepicker-title { margin: 0 2.3em; line-height: 1.8em; text-align:left;}
.ui-datepicker .ui-datepicker-title select { font-size:1em; margin:1px 1px; }
.ui-datepicker select.ui-datepicker-month-year {width: 100%;}
.ui-datepicker select.ui-datepicker-month { width: 8em;}
.ui-datepicker select.ui-datepicker-year { width: 6em;}

.ui-datepicker select.ui-datepicker-year{ position:absolute; float:none !important; right:2px;  }
.ui-datepicker select.ui-datepicker-month{ margin-left:0;  float:none!important; left:12px;}


.ui-datepicker table {width: 100%; font-size: .9em; border-collapse: collapse; margin:0 0 .4em; }
.ui-datepicker th { padding: .7em .3em; text-align: center; font-weight:normal; border: 0; color:#333;  }
.ui-datepicker td { border: 0; padding: 1px; }
.ui-datepicker td span, .ui-datepicker td a { display: block; padding: .2em; text-align: right; text-decoration: none; }
.ui-datepicker .ui-datepicker-buttonpane { background-image: none; margin: 0 0 0 0; padding:0 .2em; border: 0; text-align:center; height:2em; }
.ui-datepicker .ui-datepicker-buttonpane button { float:none; margin: .1em .2em .1em; cursor: pointer; padding: .2em .6em .3em .6em; width:auto; overflow:visible; }
.ui-datepicker .ui-datepicker-buttonpane button.ui-datepicker-current {  float:none; }


             