/**
  *  Marketo Sales Insight CSS
  *  Copyright (c) 2009 Marketo, Inc. All Rights Reserved
  *
  *  N.B. All styles that include static resources are defined in components/CssAndJavascript
  *
  */
  
/* Two classes for hiding page elements using apex booleans */
.mktDisplay-false,
.mktHide-true,
.mktShow-false {
  display: none;
}
.mktHide-false {
}
.mktDisplay-true {
  display: block !important;
}
a.mktDisplay-true,
span.mktDisplay-true {
  display: inline !important;
}


html {
  padding: 0px;
  margin: 0px;
}
body {
  border: 0px;
  padding: 0px;
  margin: 0px;
}
body.ext-ie6 {
}

body.debug {
  border: 1px dotted purple;
}

.mkto,
.mktMainPage {
  position: relative;
  background-color: white;
}

.mkto * {
  font-family: arial, helvetica, sans-serif;
  font-size: 12px;
}
body.ext-safari.ext-mac .mkto * {
  /*font-size: 9px;*/
}
.mkto input {
  font-family: Verdana, Geneva, sans-serif;
  font-size: 10px;
}


.mktPageHeader .ptBody,
.mktStreamTitle {
  background-color: #6656bc;
  /*background-color: #716fb3;*/
}

/* Main title and logo */
.mkto h2.mainTitle {
  padding: 3px 2px 3px 30px;
  width: 300px;
  white-space: nowrap;
}
.mktPartialPage .mktMain .mktLogoButton {
  position: absolute;
  z-index: 1000;
  top: 3px;
  left: 2px;
}
.mktFullPage .mktMain .mktLogoButton {
  display: none;
}
.mktLogoButton a {
  cursor: default;
  border: none;
  text-decoration: none;
}

body.ext-ie6 .mktMain .help{
  margin-right: 30px;
}

/* Page header */
.mktPageHeader .pageType,
.mktPageHeader .pageType span {
  font-size: 2em !important;
  font-family: verdana, geneva, sans-serif;
  line-height: 1.1em;
}
.mktPageHeader .pageType {
  margin: 8px 0 11px 4px;
}
.mktPageHeader .mktLogoButton {
  float: left;
  margin: 5px 4px 0px 2px;
}
.mktFullPage .mktPageHeader.bPageTitle {
  margin-bottom: 0px;
}
.mkto.mktFullPage.mktFullList .mktPageHeader.bPageTitle {
  margin-bottom: 1px;
}
.mkto.mktDashboard.mktFullPage.mktFullList .mktPageHeader.bPageTitle {
  margin-bottom: 0px;
}
.mktPageHeader .helpLink{
  font-size: 11px;
}
#mktPageHeaderSpacer {
  display: none;
  background-color: white;
}
.mktDashboard #mktPageHeaderSpacer {
  height: 18px;
  display: block;
}
.mktDashboard.mktShowingWelcome #mktPageHeaderSpacer {
  display: none;
}

.mkto.mktDashboard.mktFullList.mktFullPage .mktRenderPageBody-true {
  margin: 0px 7px 0px 10px;
}

/* Marketo outer wrapper div */
.mktPartialPage {
  margin-top: 20px;
}
.mktFullPage {
  margin-top: 0px;
  min-height: 495px;
}

.mkto .mktMain .bPageBlock .pbBody .bPageBlock  {
  padding: 2px;
  margin: 10px 10px 6px 5px;
}
.mkto .mktMain .bPageBlock.secondaryPalette  {
  position: relative;
}
.mkto .mktoTable .bPageBlock.secondaryPalette {
  background: none !important;
}
.mkto .individualPalette .secondaryPalette {
  background: none !important;
}
.mkto .secondaryPalette .secondaryPalette,
.mkto .mktMain .pbBody {
  border: none;
}
.mkto .apexp .bPageBlock .pbBody {
  background: none;
  height: auto;
  margin: 0px;
  padding: 0px;
}
.mktDashboard.mktPartialPage .mktMain .individualPalette .secondaryPalette .pbBody {
  height: auto;
}
.mktPartialPage .mktMain .pbSubsection  {
  height: 270px;
  overflow: auto;
 }
.mktFullPage .mktMain .mktTabPanel,
.mktFullPage .mktMain .bPageBlock,
.mktFullPage .mktMain .pbSubsection {
  /*min-height: 475px;*/ 
}

.mktMessage,
.mkto .mktGridMessage {
  height: 100px;
  margin-top: 100px;
  text-align: center;
}
.mktMessage,
.mkto .mktGridMessage,
.mkto .mktGridMessage *,
.mktPageBodyLoadMask span,
.mktTabPanelLoadMask span {
  color: #666;
  font-size: 16px;
  font-family: Verdana, Geneva, sans-serif;
}
body.ext-safari.ext-mac .mktMessage,
body.ext-safari.ext-mac .mkto .mktGridMessage,
body.ext-safari.ext-mac .mkto .mktGridMessage * {
  font-size: 13px;
}
.mktPageBodyLoadMask span,
.mktTabPanelLoadMask span {
  font-size: 16px !important;
}
.mkto .mktErrorMsg {
}
.mkto .mktException {
  display: none;
}
.mkto .mktErrorIcon {
  position: absolute;
  top: 0px; 
  right: 150px;
  z-index: 19000;
  height: 256px;
  width: 256px;
  opacity: 0.30;
  -ms-filter:'alpha (opacity=30)';
  filter: alpha(opacity=30);
}


.mktHoverIcon {
  opacity: 0.30;
  -ms-filter:'alpha (opacity=30)';
  filter: alpha(opacity=30);
}
.mktHoverIcon:hover {
  opacity: 1.0;
  -ms-filter:'alpha (opacity=100)';
  filter: alpha(opacity=100);
}


/* mktFullPage is applied to an outer wrapper div when in "full list" or "dashboard" mode */
.mktFullPage .dr-bottom-line {
  background: white;
}
.mktFullPage .mktMain .pbHeader,
.mktFullPage .mktMain .pbFooter {
  display: none;
}
.mktFullPage .individualPalette .pbBody {
  background: none;
 }
.mktFullPage .bPageBlock {
  border-top: 0px;
}

/* Hot Bar */
.mktHotBar {
  position: relative;
  margin: -1px 6px 6px 0px;
  font-weight: bold;
}

.mktHotBarTab,
.mktHotBarTab-right {
  display: block;
  height: 38px;
  background-color: transparent;
  background-repeat: no-repeat;
}
.mktHotBarTab {
  position: relative;
  padding: 8px 0px 0px 10px;
  background-position: 0 0;
}
.mktHotBarTab-right {
  margin-left: 0px;
  z-index: 1;
  width: 10px;
  position: absolute;
  right: 0px;
  top: 0px;
  background-position: right -76px;
}
.mktFullPage .mktHotBarTab-right {
  background-position: right -38px;
}
.mktFullPage .right-col .mktHotBarTab,
.mktFullPage .right-col .mktHotBarTab-right {
  background-image: none;
}

.mktHotBar .left-col {
  width: 220px;
  padding-right: 10px;
}
.mktHotBar .left-col .mktHotBarTab {
  width: 190px;
  margin-left: 30px;
}
.mktHotBar .center-col {
  width: 50%;
}
.mktHotBar .center-col .mktHotBarTab {
  width: 90px;
}
.mktHotBar .left-col .scale img {
  height: 20px;
  width: 57px;
}
.mktHotBar .right-col {
  width: 340px;
  padding-right: 30px;
}
.mktHotBar .right-col .mktHotBarTab {
  width: 280px;
  margin-right: 30px;
}
.mktHotBar .label {
  font-weight:bold;
  float: left;
  padding-top: 4px;
  padding-right: 10px;
}
.mkto .mktHotBar select { 
  position: relative;
  top: 1px;
}
.mktHotBar .mktActionsMenu {
  float: left;
  position: relative;
  top: -2px;
}

/* Watch List */
.mktHotBar .mktWatchList {
   font-weight: normal;
}
.mktHotBar .mktWatchList a {
  float: left;
  text-decoration: none;
}
.mktHotBar .mktWatchList a img {
  float: left;
  margin-right: 6px;
}
.mktHotBar .mktWatchList a span {
  float: left;
  margin-top: 5px;
}
.mktHotBar .mktWatchList a img {
  margin-top: -1px;
}
.mktPartialPage .mktHotBar .mktWatchList a span {
  margin-top: 5px;
}
.mktHotBar .mktWatchList a:hover span {
  text-decoration: underline;
}
.mktHotBar .mktWatchListIcon {
  width: 125px;
}
.mktHotBar .mktWatchListStatus span {
   color: #666;
}

/* Toolbars */
.mktTopToolbar,
.mktBottomToolbar {
  margin: 5px 5px 5px 8px;
  padding: 5px 5px 5px 5px;
}
.mktPartialPage .mktBottomToolbar {
  margin: 0px 5px 5px 8px;
  padding-top: 0px;
}
.mktLinksRight {
  text-align: right;
}
.mktFullListLink {
  float: left;
}
.mktPagination {
  display: none;
}
.mktFullPage.mktFullList .mktPagination,
.mktFullPage.mktDashboard .mktPagination {
  margin: auto;
  text-align: center;
  white-space: nowrap;
  display: block;
}
.mktGridRows0.mktPagination {
  display: none !important;
}
.mktPagination-count {
  padding-right: 10px;
  padding-left: 10px;
}

/* Scoring */
.mktNegScoreChange {
  color: darkred;
}
.mktNoScoreChange {
  display: none;
}
.mktPosScoreChange { }

/* Tables */
.mktMain .list tr td.dataCell {
  vertical-align: middle;
}
.mktNumberColumn {
  width: 25%;
  text-align: right;
}
.mktIconColumn {
  margin-top: -1px;
  margin-left: 15px;
  height: 15px;
}

.mktMain table.detailList {
}
.mkto .mktMain td.mktScoreCell,
.mkto .mktMain td.mktActionCell {
  position: relative;
  white-space: nowrap;
}
td.mktScoreCell img {
  vertical-align: middle;
}
td.mktScoreCell span {
  display: none;
  color: #666;
  font-size: 10px;
  position: relative;
  top: -7px;
}

.mktSortableColumn {
}

.mktKnownLead,
.mktKnownAccount {
  font-weight: bold;
}
.mktAnonymousLead {
  font-style: italic;
}

/* Layout table */
table.mktoTable {
  width: 100%;
  background-color: white; 
}
td.mktMain {
  width: 100%;
  vertical-align: top;
}
.mktDashboard td.mktMain {
  width: 75%;
  min-width: 600px;
}

td.mktStream {
  width: 25%;
  min-width: 180px;
  max-width: 250px;
  padding-left: 10px;
  padding-bottom: 20px;
  padding-top: 25px; /* keep in sync with dr-bottom-line rules */
  position: relative;
}

td.mktStream .secondaryPalette{
  min-height: 425px;
}

/* align the top edges of the tabPanel and stream boxes */
.mktTabPanel td.dr-bottom-line {
  height: 26px !important;
  display: table-cell;
  vertical-align: bottom;
}

.mktTabPanel .dr-bottom-line form {
  margin-left: -2px !important;
  float: left;
}

.mktStreamCell {
  position: relative;
  padding-top: 3px;
  padding-bottom: 5px;
}
.mktStream .mktStreamBox {
  width: 100%;
}
.mktStreamIcon {
  position: absolute;
  right: 2px;
  bottom: 2px;
}
body.ext-ie6 .mktStreamIcon {
  position: relative;
  float: right;
  margin-right: 2px;
  margin-top: 8px;
}
.mktStreamLead,
.mktStreamLead a {
  font-size: 13px;
  font-weight: bold;
  font-family: lucida grande,tahoma,verdana,arial,sans-serif;
}
.mktStreamLead,
.mktStreamMoment {
  font-size: 13px;
  font-family: lucida grande,tahoma,verdana,arial,sans-serif;
  display: inline;
}
.mktStreamMoment {
  padding-top: 3px;
  padding-bottom: 6px;
}
.mktStreamAccount *,
.mktStreamTime,
.mktSubscribe {
  font-style: italic;
  color: #555;
  font-size: 11px;
}
.mktStreamAccount {
  padding-top: 6px;
  padding-bottom: 2px;
  width: 80%;
}
.mktStream a,
.mktSubscribe {
  color: #3B5998;
  cursor: pointer;
  text-decoration: underline;
}

.mktStreamBox table.detailList {
  position: relative;
}
.mktStreamBox .data2Col {
  width: 100% !important;
  padding: 0px !important;
  position: relative;
}

.mktStreamBox .headerRow {
  display: none;
}
.mktStreamHeader {
  border: 1px solid #ccc;
  margin-bottom: 10px;
  vertical-align: middle;
}
.mktStreamTitle {
  font-family: arial, helvetica, sans-serif;
  color: white;
  font-size: 13px;
  height: 15px;
  padding: 4px;
}
body.ext-safari.ext-mac .mktStreamTitle {
  font-size: 12px;
}
.mktStreamBox .dataRow.odd {
  background-color: #fff;
}
.mktStreamBox .dataRow.even {
  background-color: #fff;
}
.mktStreamBox .dataRow.highlight td {
  background-color: transparent;
}
.mktStreamBox .dataCell {
  border-bottom: 1px dotted #ccc !important;
}

/* Email threads */
.mktEmailThread-inner {
  /* border-bottom: 0px !important; */
}
.mktEmailThread-start {
}


/*
 * Email Alert subscription modal dialog. 
 */

#mktAlertModal div.bd input {
  float:left;
}
#mktAlertModal div.bd label {
  float:left;
  cursor: pointer;
  padding-top: 5px;
  padding-bottom: 5px;
  padding-left: 5px;
}
#mktAlertModal div.bd div.mktRadioLabel {
  float:left;
  width: 250px; 
}
#mktAlertModal div.bd input.mktText {
  margin-top: 6px;
}
#mktAlertModal div.bd input.mktRadio {
  margin-top: 6px;
}
body.ext-ie #mktAlertModal div.bd input.mktRadio {
  margin-top: 2px;
}
#mktAlertModal div.bd b {
  float:left;
  width: 80px; 
}
#mktAlertModalEmail {
  margin-top: 0px;
  width: 230px;
}

/*
 *  Add to Marketo Campaign page. 
 */
#mktAddToMarketoCampaign .mktPageBlockSection {
  border-bottom: 0px;
  padding-bottom: 8px;
}

/**
 *  Send Marketo Email
 */
#mktSendMarketoEmail .mktPageBlockSection {
  vertical-align: middle;
}

/* Welcome splash */
.mktWelcome {
  position: relative;
  margin-bottom: 15px;
}
.mktWelcome,
.mktWelcome iframe {
  width: 100%;
  height: 180px;
}
.mktWelcome iframe {
  border: none;
  overflow: hidden;
  border: none;
}
.mktClearWelcomeButton {
  text-align: center;
  vertical-align: top;
  padding: 4px;
  height: 30px;
}



/**
 * Dashboard
 */
#db-body {
	position: relative;
}

#db-body-shadow-l {
	background: transparent url("/img/alohaSkin/bd_sprite.png") left top repeat-y;
	height: 100%;
	left: -10px;
	position: absolute;
	width: 20px;
}

#db-body-shadow-r {
	background: transparent url("/img/alohaSkin/bd_right_shadow.png") right top repeat-y;
	height: 100%;
	left: 10px;
	position: absolute;
	width: 100%;
}

#db-body-shadow-b {
	background: transparent url("/img/alohaSkin/bd_b.png") 0 -10px repeat-x;
	bottom: -10px;
	height: 10px;
	left: 0;
	position: absolute;
	width: 100%;
}

#db-body-shadow-bl, #db-body-shadow-br {
	background: url("/img/alohaSkin/bd_sprite.png") no-repeat;
	height: 10px;
	position: absolute;
	width: 10px;
}

#db-body-shadow-bl {
	background-position: -40px -5px;
	left: -10px;
}

#db-body-shadow-br {
	background-position: -70px -5px;
	right: -10px;
}

#db-body .apexp {
	background-color: #EAEAEA;
	position: relative; /* to allow z-index positioning */
}

#db-body .pbBody {
	margin: 0;
	min-height: 454px; /* height when the smallest number of elements is shown */
	padding: 5px 8px 5px 0;
	position: relative;
}

#db-body .mkt-tab-message {
  margin-top: 180px;
}

#db-feed {
	padding-top: 3px; /* making top border on the same level with dashboard body top */
}

#db-feed .bPageBlock {
	border-top: 1px solid #EAEAEA;
}

#db-feed .pbBody {
	margin: 0;
	min-height: 498px; /* keeping the same height as dashboard body when the smallest number of elements is shown */
}

#db-feed .data2Col {
	padding: 0;
}

#db-feed .list,
#db-feed .list .headerRow th {
	border-left-width: 0;
	border-right-width: 0;
	border-top-width: 0;
}

#db-feed .list {
	-moz-border-radius: 4px;
}

#db-feed .list .headerRow th {
	-moz-border-radius: 4px 4px 0 0;
	font-size: 1.1em;
}

.mkt-tab-message {
  font-size: 16px;
  text-align: center;
}

.stream-rss {
	float: right;
	margin-right: 3px;
}


/**
 * Detail Tabs 2
 */
#detail-tabs .tabNavigation {
	margin: 0;
}

#detail-tabs-body {
	min-height: 300px; /* TODO adjust after hotbar is visible */
	padding: 7px;
	position: relative;
}

#detail-tabs-body .mktBottomToolbar {
	display: block;
	margin: 5px 0;
	padding: 0;
}

#detail-tabs-body .data2Col {
	padding: 0;
}

#detail-tabs-body .mkt-tab-message {
  margin-top: 130px;
}

/**
 * Settings edit page
 */
.bEditBlock .detailList .labelCol,
.bEditBlock .detailList .data2Col {
	vertical-align: middle;
}

.bEditBlock .data2Col .mkt-checkbox {
	margin: 1px 0;
}

/* mimic label column text styling */
.bEditBlock .data2Col label {
	color: #4A4A56;
	font-size: 91%;
	font-weight: bold;
}