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
	/*
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;
	 */
}

.mktPageHeader .ptBody,
.mktStreamTitle {
  background-color: #6656bc;
  /*background-color: #716fb3;*/
}

/* Main title and logo */
.mkto .pbTitle h2.mainTitle {
	font-size: 1.6em;
  padding: 1px 2px 0 32px;
  white-space: nowrap;
  width: 300px;
}
#detail-tabs-page.mktPartialPage .mktLogoButton {
  position: absolute;
  z-index: 1000;
  top: 5px;
  left: 5px;
}
#detail-tabs-page.mktFullPage .mktLogoButton {
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
  font-size: 1em !important;
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

.mkto.mktDashboard.mktFullList.mktFullPage .mktRenderPageBody-true {
  margin: 0px 7px 0px 10px;
}

/* Marketo outer wrapper div */
.mktPartialPage {
  margin-top: 10px;
  min-width: 600px;  
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
  max-height: 270px;
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
#detail-tabs-page.mktFullPage .pbHeader,
#detail-tabs-page.mktFullPage .pbFooter {
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
  font-weight: bold;
  margin: -1px 6px 10px 0;
	padding: 0 30px;
	position: relative;
	zoom: 1; /* for IE8 compatibility */
}
.mktFullPage .mktHotBar {
	border-top: 1px solid #EAEAEA;
}

.mktHotBarTab,
.mktHotBarTab-right {
  display: block;
  height: 38px;
  background-color: transparent;
  background-repeat: no-repeat;
}
.mktHotBarTab {
	height: 37px;
  position: relative;
  padding: 0 15px 0 15px;
  background-position: 0 0;
	line-height: 34px;
	white-space: nowrap;
}
.mktHotBarTab-right {
	background-position: right -77px;
  margin-left: 0px;
  z-index: 1;
  width: 10px;
  position: absolute;
  right: 0px;
  top: 0px;
}
.mktFullPage .mktHotBarTab-right {
	background-position: right -39px;
}

.mktHotBarTab .scale {
	position: relative;
}
.mktHotBarTab > * {
	vertical-align: middle;
}
.mktHotBarTab > label {
	padding-top: 2px;
}

.mktHotBarPriority {
	float: left;
}
.mktHotBarWatchList {
	float: left;
	margin-left: 20px;
}
.mktHotBarActions {
	float: right;
}

.mktHotBarWatchList a {
  display: block;
	font-weight: normal;
  text-decoration: none;
}
.mktHotBarWatchList a:hover {
  text-decoration: none;
}
.mktHotBarWatchList a:hover > span {
  text-decoration: underline;
}
.mktHotBarWatchList a > img,
.mktHotBarWatchList a > span {
	vertical-align: middle;
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

.mkt-message-block {
	display: block;
	font-size: 16px;
	margin: auto;
	padding: 100px;
	text-align: center;
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
/*
  padding: 4px;
  height: 30px;
*/
}

/**
 * General styles
 */
.mkt-show-true {
	display: block; /* display/hide styles without using of important keyword */
}
a.mkt-show-true,
span.mkt-show-true,
.mkt-show-inline-true {
	display: inline; /* display/hide styles without using of important keyword */
}

.mkt-show-false,
.mkt-show-inline-false {
	display: none;
}

.mkt-template-element {
	display: none !important;
}

/**
 * Tabs (used in dashboard and detail tabs)
 */
.mkt-tabs-body {
	position: relative;
}

.mkt-tabs-body .apexp {
	background-color: #F8F8F8;
	position: relative; /* to allow z-index positioning */
}

.mkt-tabs-body-shadow-l {
	background: transparent url("/img/alohaSkin/bd_sprite.png") left top repeat-y;
	height: 100%;
	left: -10px;
	position: absolute;
	width: 20px;
}

.mkt-tabs-body-shadow-r {
	background: transparent url("/img/alohaSkin/bd_right_shadow.png") right top repeat-y;
	height: 100%;
	left: 10px;
	position: absolute;
	width: 100%;
}

.mkt-tabs-body-shadow-b {
	background: transparent url("/img/alohaSkin/bd_b.png") 0 -9px repeat-x;
	bottom: -10px;
	height: 10px;
	left: 0;
	position: absolute;
	width: 100%;
}

.mkt-tabs-body-shadow-bl, .mkt-tabs-body-shadow-br {
	background: url("/img/alohaSkin/bd_sprite.png") no-repeat;
	height: 10px;
	position: absolute;
	width: 10px;
}

.mkt-tabs-body-shadow-bl {
	background-position: -40px -5px;
	left: -10px;
}

.mkt-tabs-body-shadow-br {
	background-position: -70px -5px;
	right: -10px;
}

.mkt-tabs-message {
  font-size: 16px;
  text-align: center;
}
.mkt-tabs-message * {
  font-size: inherit;
}

.mkt-tabs-row-dim {
	background-color: #fff;
	position: absolute;
}

.mkt-tabs-row-undo {
	background-color: #eee;
	border: 1px solid #ddd;
	border-width: 1px 0 1px 0;
	color: #666;
	font-weight: bold;
	position: absolute;
}
.mkt-tabs-row-undo > * {
	color: inherit;
	font-size: inherit;
	font-weight: inherit;
	vertical-align: middle;
}
.mkt-tabs-row-undo * {
	color: inherit;
}


/**
 * Dashboard
 */
#db-body .pbBody {
	margin: 0;
	min-height: 454px; /* height when the smallest number of elements is shown */
	padding: 5px 8px 6px 0;
	position: relative;
}

#db-body .mkt-tabs-message {
  padding-top: 185px;
}

#db-feed {
	padding-left: 18px;
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
	-webkit-border-radius: 4px;
	border-radius: 4px;
}

#db-feed .list .headerRow th {
	-moz-border-radius: 4px 4px 0 0;
	-webkit-border-radius: 4px 4px 0 0;
	border-radius: 4px 4px 0 0;
	font-size: 1.1em;
}
#db-feed .list .headerRow th * {
	font-size: inherit;
}

#db-feed .mkt-tabs-message {
  padding-top: 15px;
}

#db-what-is-new {
	color: #fff;
	display: none;
	font-size: 12px;
	height: 215px;
	padding: 35px 32px;
	position: relative;
	width:	306px;
	z-index: 999999;
}

#db-what-is-new > h2 {
	color: inherit;
	display: block;
	font-size: 1.5em;
	font-weight: bold;
}

#db-what-is-new > ul {
	margin: 0;
	padding: 0 0 0 16px;
}

#db-what-is-new li {
	margin: 0;
	padding: 14px 0 0 0;
}

#db-what-is-new li > a {
	color: #C0BBFA;
	font-weight: bold;
	text-decoration: underline;
}
#db-what-is-new a:hover {
	text-decoration: none;
}

#db-what-is-new #db-what-is-new-disable {
	bottom: 35px;
	color: inherit;
	position: absolute;
	right: 30px;
	text-decoration: underline;
}
#db-what-is-new #db-what-is-new-disable:hover {
	text-decoration: none;
}

#db-what-is-new #db-what-is-new-close {
	border: 0 none;
	height: 33px;
	outline: 0;
	position: absolute;
	right: 0px;
	top: 0px;
	width: 33px;
}
#db-what-is-new #db-what-is-new-close:hover {
	text-decoration: none;
}

.stream-rss {
	float: right;
	margin-right: 3px;
}


/**
 * Detail Tabs 2
 */
#detail-tabs-page.mktFullPage .bPageBlock {
	border: 0;
}

/* move padding from table to title cell (IE8 compatibility has styling bug) */
#detail-tabs-page .bPageBlock .pbHeader > table {
	padding: 0;
}
#detail-tabs-page .bPageBlock .pbTitle {
	padding-bottom: 8px;
	padding-top: 8px;
}

#detail-tabs .tabNavigation {
	position: relative;
}

.mktPartialPage #detail-tabs .tabNavigation {
	margin: 0;
	overflow: hidden;
}

#detail-tabs-body {
	padding: 0;
	position: relative;
}

.mktPartialPage #detail-tabs-body {
	overflow: hidden;
}

#detail-tabs-body .pbBody {
	margin: 0;
	min-height: 286px;
	padding: 10px 10px 5px 10px;
}

#detail-tabs-body.mkt-tabs-body .bPageBlock {
	-moz-border-radius: 0;
	-webkit-border-radius: 0;
	border: 0;
	border-radius: 0;
	border-top: 3px solid #6656BC;
	margin: 0;
	padding: 0;
}

.mktFullPage #detail-tabs-body.mkt-tabs-body .bPageBlock {
	-moz-border-radius: 4px;
	-webkit-border-radius: 4px;
	border-bottom: 1px solid #EAEAEA;
	border-left: 1px solid #EAEAEA;
	border-right: 1px solid #EAEAEA;
	border-radius: 4px;
}

#detail-tabs-body .mktBottomToolbar {
	display: block;
	margin: 0;
	padding: 5px 2px 0 2px;
}

#detail-tabs-body .data2Col {
	padding: 0;
}

#detail-tabs-body .mkt-tabs-message {
  padding-top: 130px;
}

/* Full Page Header */
.mkto .bPageTitle .ptBody h1.noSecondHeader {
	font-size: 1.5em;
	font-weight: bold;
	padding-top: 2px;
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


/**
 * Table columns
 */
.mkt-column-priority {
	text-align: center;
	width: 140px;
}

.mkt-column-hide {
	text-align: center;
	width: 55px;
}

.mkt-column-remove {
	text-align: center;
	width: 55px;
}

.mkt-column-subscribe {
  text-align: center;
  width: 55px;
}

.mkt-column-page-views {
	width: 80px;
}

.mkt-column-date {
	width: 120px;
}

.mkt-column-web-research {
	text-align: center;
	width: 80px;
}

.mkt-column-email-opened {
	text-align: center;
	width: 60px;
}

.mkt-column-email-clicked {
	text-align: center;
	width: 60px;
}

/**
 * Stream Component
 */
#stream-content-loading {
	min-height: 464px;
	position: relative;
}

#stream-empty-message {
	display: none;
}


.mkt-auto-suggest-list {
	background: #fff;
	border: 1px solid #eaeaea;
	border-top-width: 0;
	position: absolute;
}

.mkt-auto-suggest-list > a {
	display: block;
	outline: 0;
	padding: 2px 5px;
	text-decoration: none;
}

.mkt-auto-suggest-list > a:hover {
	background: #f6f6f6;
	text-decoration: none;
}


#filter-list table td,
#filter-list table td > * {
	text-align: left;
}

/* Marketo logo on email tab table */
.mktSentByMarketo-true {
	height: 16px; 
	padding: 0 2px;
	position: absolute;
	width: 20px;
}

#mktEmailComboPanel {
  height: 250px;
  overflow: auto;
}

.mktEmailTreePanel ul,
.mktEmailTreePanel li {
  margin: 0;
  padding: 0;
}

.mkto .tabsNewBar {
  position: relative;
}

.mktPartialPage .mktIMContainer{
  display: block;
  overflow: auto;
  max-height: 275px;
}

.mktFullPage .mktIMContainer{
  display: block;
  overflow: auto;
  max-height: 100%;
}


.mktSendMarketoEmail .detailList tr{
  padding-top: 5px;
  padding-bottom: 5px;
  border: 1px solid black !important;
}

/*
Adding these css classes for the summer 12 release
*/
.mkto .tabNavigation .tab .currentTab {
  background-image: url('/img/alohaSkin/tabs_sprite.png');
  background-position: left 0;
}

.mkto .tabNavigation .tab .currentTab div {
	background-image: url('/img/alohaSkin/tabs_sprite.png');
	background-repeat: no-repeat;
	background-position: right -150px;
}

.mkto .tabNavigation .tab td div {
	padding: 7px 10px;
	font-family: Arial, Helvetica, sans-serif;
	font-size: 1.18em;
	font-weight: bold;
	color: #4B4B57;
	max-height: 15px;
	background-image: none;
	background-repeat: no-repeat;
}

.mkto .tabNavigation .tab td {
  background-image: none;
  background-repeat: no-repeat;
}

.mkto .tabNavigation {
	position: relative;
	background: transparent url('/img/alohaSkin/tabbar_sprite.png') left -73px repeat-x;
	margin: 0 5px;
	padding: 3px 0 0;
}

.mkto .tabNavigation .tabBarLeft {
	background: transparent url('/img/alohaSkin/tabbar_sprite.png') no-repeat;
	width: 15px;
	height: 100%;
	position: absolute;
	left: -15px;
	top: 0;
}

.mkto .tabNavigation .tabBarRight {
	background: transparent url('/img/alohaSkin/tabbar_sprite.png') -15px 0 no-repeat;
	width: 15px;
	height: 100%;
	position: absolute;
	right: -15px;
	top: 0;
}
/* End of summer 12 css classes
*/