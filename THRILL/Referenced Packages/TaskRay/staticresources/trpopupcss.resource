@font-face {
  font-family: "Salesforce Sans";
  src: url("https://www2.sfdcstatic.com/system/shared/common/assets/fonts/SalesforceSans/SalesforceSans-Regular.woff2") format("woff2"),
       url("https://www2.sfdcstatic.com/system/shared/common/assets/fonts/SalesforceSans/SalesforceSans-Regular.woff") format("woff");
  font-style: normal;
  font-weight: 500;
}
@font-face {
  font-family: "Salesforce Sans Bold";
  src: url("https://www2.sfdcstatic.com/system/shared/common/assets/fonts/SalesforceSans/SalesforceSans-Bold.woff2") format("woff2"),
       url("https://www2.sfdcstatic.com/system/shared/common/assets/fonts/SalesforceSans/SalesforceSans-Bold.woff") format("woff");
  font-weight: 600;
}
@font-face {
  font-family: "Salesforce Sans Light";
  src: url("https://www2.sfdcstatic.com/system/shared/common/assets/fonts/SalesforceSans/SalesforceSans-Light.woff2") format("woff2"),
       url("https://www2.sfdcstatic.com/system/shared/common/assets/fonts/SalesforceSans/SalesforceSans-Light.woff") format("woff");
  font-weight: 400;
}

.content{width: 100% !important;}

* {
    font-family: 'Salesforce Sans';
}

.detailList th label {
    font-size: 10.92px;
}

.ui-button-text{
	color: #333;
	padding: 4px 3px;
	font-weight: bold;
	font-size: 11px;
}

.ui-state-default.ui-button{
	margin: 1px;
	border: 1px solid #B5B5B5;
	border-bottom-color: #7F7F7F;
	background: #E8E8E9 url('/img/alohaSkin/btn_sprite.png') repeat-x right top;
	-moz-border-radius: 3px;
	-webkit-border-radius: 3px;
	border-radius: 3px;
}

.bPageBlock{
	background-color: white !important;
	border: none !important;
}

.pbSubsection span, .pbSubsection a, .pbSubsection .labelCol{
    color: #16325C !important;
}

input[type="text"] {
    color: #16325C !important;
}

#delete-confirm div.modal-header, #delete-confirm div.modal-body {
    color: #16325C;
}

#archive-confirm div.modal-header, #archive-confirm div.modal-body {
  color: #16325C;
}

#clone-dialog #clone-title-div, #clone-dialog ul, #clone-dialog span, 
#clone-dialog #clone-modal-child-projects input, #clone-dialog div.clone-modal-child-project-name,
.clone-modal-child-header .clone-modal-child-project-end-date,
.clone-modal-child-header .clone-modal-child-project-start-date {
    color: #16325C;
}

h1.pageType.noSecondHeader {
    height: 17px;
}

.detailList .tr-bootstrap .button--brand {
    color: white !important;
}

.tag-title{
	margin-right: 20px;
	color: black;
	font-size: 14px;
	line-height: 16px;
	margin-left: -10px;
}

#tag-list, .tag-title{
	float: left;
}

#tag-list{
	line-height: 32px;
}

#tag-existing{
	clear: both;
}

#tag-entry{
	margin-left: 78px;
}

input.Name, textarea.Description__c{

	width: 100%;
}

#add-tags-btn{
	color: #333;
	margin: 1px;
	border: 1px solid #B5B5B5;
	border-bottom-color: #7F7F7F;
	background: #E8E8E9 url('/img/alohaSkin/btn_sprite.png') repeat-x right top;
	font-weight: bold;
	font-size: 11px;
	-moz-border-radius: 3px;
	-webkit-border-radius: 3px;
	border-radius: 3px;
	padding: 4px 3px;
}

.pbHeader table{
	border: none !important;
}

.bPageBlock {
	border-top-width: 3px !important;
}

.project-task-tag{
	cursor: pointer;
}

.delete-tag{
	cursor: pointer;
}

#tag-input{
	width: 300px;
	font-size: 11px;
	padding: 4px 3px;
}

body{
	margin:0 10px !important;
}

.bPageBlock .detailList tr td, .bPageBlock .detailList tr th,
.hoverDetail .bPageBlock .detailList tr td,
.hoverDetail .bPageBlock .detailList tr th{
	border-bottom: 1px solid #ECECEC !important; /*Can't figure out why this isn't overriding the earlier stylesheets. Ah well. Code Karma-- */
}

#user_prefs .labelCol{ white-space:nowrap; }

#unfollow-archived-tasks-label{float:left; padding-left:10px; padding-top:4px;}
#user_prefs .btn {width:40px;margin-left:400px;}
.notification_itemname{font-style:italic;}
.notification-task-row{cursor: pointer;text-decoration:underline;padding:2px;color:blue;}
.notification-project-row{cursor: pointer;text-decoration:underline;padding:2px;color:blue;}
#task_more{color:blue;display:block;margin-top:20px;text-decoration:underline;cursor:pointer;}
#project_more{color:blue;display:block;margin-top:20px;text-decoration:underline;cursor:pointer;}
#notification_header{color:#1F99BE;font-size:16px;padding-bottom:8px;}
#task_notifications{
	border:1px dotted;
	min-height:40px;
}
#project_notifications{
	border:1px dotted;
	min-height:40px;
}

#datePicker{
  z-index: 1050;
}

.date-select-container input{
  margin-bottom:0px;
}

#modal-backdrop-loadmask{
  z-index: 1051;
}

/*
 * Bootstrap override
 */
.modal-open .dropdown-menu {
  z-index: 2050;
}
.modal-open .dropdown.open {
  *z-index: 2050;
}
.modal-open .popover {
  z-index: 2060;
}
.modal-open .tooltip {
  z-index: 2070;
}
.modal-backdrop {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  z-index: 1040;
  background-color: #000000;
}
.modal-backdrop.fade {
  opacity: 0;
}
.modal-backdrop,
.modal-backdrop.fade.in {
  opacity: 0.8;
  filter: alpha(opacity=80);
}
.modal {
  position: fixed;
  top: 50%;
  left: 50%;
  z-index: 1050;
  overflow: auto;
  width: 560px;
  margin: -250px 0 0 -280px;
  background-color: #ffffff;
  border: 1px solid #999;
  border: 1px solid rgba(0, 0, 0, 0.3);
  *border: 1px solid #999;
  /* IE6-7 */

  -webkit-border-radius: 6px;
  -moz-border-radius: 6px;
  border-radius: 6px;
  -webkit-box-shadow: 0 3px 7px rgba(0, 0, 0, 0.3);
  -moz-box-shadow: 0 3px 7px rgba(0, 0, 0, 0.3);
  box-shadow: 0 3px 7px rgba(0, 0, 0, 0.3);
  -webkit-background-clip: padding-box;
  -moz-background-clip: padding-box;
  background-clip: padding-box;
}
.modal.fade {
  -webkit-transition: opacity .3s linear, top .3s ease-out;
  -moz-transition: opacity .3s linear, top .3s ease-out;
  -ms-transition: opacity .3s linear, top .3s ease-out;
  -o-transition: opacity .3s linear, top .3s ease-out;
  transition: opacity .3s linear, top .3s ease-out;
  top: -25%;
}
.modal.fade.in {
  top: 50%;
}
.modal-header {
  padding: 9px 15px;
  border-bottom: 1px solid #eee;
}
.modal-header .close {
  margin-top: 2px;
}
.modal-body {
  overflow-y: auto;
  max-height: 400px;
  padding: 15px;
}
.modal-form {
  margin-bottom: 0;
}
.modal-footer {
  padding: 14px 15px 15px;
  margin-bottom: 0;
  text-align: right;
  background-color: #f5f5f5;
  border-top: 1px solid #ddd;
  -webkit-border-radius: 0 0 6px 6px;
  -moz-border-radius: 0 0 6px 6px;
  border-radius: 0 0 6px 6px;
  -webkit-box-shadow: inset 0 1px 0 #ffffff;
  -moz-box-shadow: inset 0 1px 0 #ffffff;
  box-shadow: inset 0 1px 0 #ffffff;
  *zoom: 1;
}
.modal-footer:before,
.modal-footer:after {
  display: table;
  content: "";
}
.modal-footer:after {
  clear: both;
}
.modal-footer .btn-bs + .btn-bs {
  margin-left: 5px;
  margin-bottom: 0;
}
.modal-footer .btn-bs-group .btn-bs + .btn-bs {
  margin-left: -1px;
}
/*
.btn-bs {
  display: inline-block;
  *display: inline;

  *zoom: 1;
  padding: 4px 10px 4px;
  margin-bottom: 0;
  font-size: 13px;
  line-height: 18px;
  color: #333333;
  text-align: center;
  text-shadow: 0 1px 1px rgba(255, 255, 255, 0.75);
  vertical-align: middle;
  background-color: #f5f5f5;
  background-image: -moz-linear-gradient(top, #ffffff, #e6e6e6);
  background-image: -ms-linear-gradient(top, #ffffff, #e6e6e6);
  background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#ffffff), to(#e6e6e6));
  background-image: -webkit-linear-gradient(top, #ffffff, #e6e6e6);
  background-image: -o-linear-gradient(top, #ffffff, #e6e6e6);
  background-image: linear-gradient(top, #ffffff, #e6e6e6);
  background-repeat: repeat-x;
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff', endColorstr='#e6e6e6', GradientType=0);
  border-color: #e6e6e6 #e6e6e6 #bfbfbf;
  border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);
  filter: progid:dximagetransform.microsoft.gradient(enabled=false);
  border: 1px solid #cccccc;
  border-bottom-color: #b3b3b3;
  -webkit-border-radius: 4px;
  -moz-border-radius: 4px;
  border-radius: 4px;
  -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);
  -moz-box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);
  cursor: pointer;
  *margin-left: .3em;
}
.btn-bs:hover,
.btn-bs:active,
.btn-bs.active,
.btn-bs.disabled,
.btn-bs[disabled] {
  background-color: #e6e6e6;
}
.btn-bs:active,
.btn-bs.active {
  background-color: #cccccc \9;
}
.btn-bs:first-child {
  *margin-left: 0;
}
.btn-bs:hover {
  color: #333333;
  text-decoration: none;
  background-color: #e6e6e6;
  background-position: 0 -15px;
  -webkit-transition: background-position 0.1s linear;
  -moz-transition: background-position 0.1s linear;
  -ms-transition: background-position 0.1s linear;
  -o-transition: background-position 0.1s linear;
  transition: background-position 0.1s linear;
}
.btn-bs:focus {
  outline: thin dotted #333;
  outline: 5px auto -webkit-focus-ring-color;
  outline-offset: -2px;
}
.btn-bs.active,
.btn-bs:active {
  background-image: none;
  -webkit-box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.15), 0 1px 2px rgba(0, 0, 0, 0.05);
  -moz-box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.15), 0 1px 2px rgba(0, 0, 0, 0.05);
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.15), 0 1px 2px rgba(0, 0, 0, 0.05);
  background-color: #e6e6e6;
  background-color: #d9d9d9 \9;
  outline: 0;
}
.btn-bs.disabled,
.btn-bs[disabled] {
  cursor: default;
  background-image: none;
  background-color: #e6e6e6;
  opacity: 0.65;
  filter: alpha(opacity=65);
  -webkit-box-shadow: none;
  -moz-box-shadow: none;
  box-shadow: none;
}
.btn-bs-large {
  padding: 9px 14px;
  font-size: 15px;
  line-height: normal;
  -webkit-border-radius: 5px;
  -moz-border-radius: 5px;
  border-radius: 5px;
}
.btn-bs-large [class^="icon-"] {
  margin-top: 1px;
}
.btn-bs-small {
  padding: 5px 9px;
  font-size: 11px;
  line-height: 16px;
}
.btn-bs-small [class^="icon-"] {
  margin-top: -1px;
}
.btn-bs-mini {
  padding: 2px 6px;
  font-size: 11px;
  line-height: 14px;
}
.btn-bs-primary,
.btn-bs-primary:hover,
.btn-bs-warning,
.btn-bs-warning:hover,
.btn-bs-danger,
.btn-bs-danger:hover,
.btn-bs-success,
.btn-bs-success:hover,
.btn-bs-info,
.btn-bs-info:hover,
.btn-bs-inverse,
.btn-bs-inverse:hover {
  text-shadow: 0 -1px 0 rgba(0, 0, 0, 0.25);
  color: #ffffff !important;
}
.btn-bs-primary.active,
.btn-bs-warning.active,
.btn-bs-danger.active,
.btn-bs-success.active,
.btn-bs-info.active,
.btn-bs-inverse.active {
  color: rgba(255, 255, 255, 0.75);
}
.btn-bs-primary {
  background-color: #0074cc;
  background-image: -moz-linear-gradient(top, #0088cc, #0055cc);
  background-image: -ms-linear-gradient(top, #0088cc, #0055cc);
  background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#0088cc), to(#0055cc));
  background-image: -webkit-linear-gradient(top, #0088cc, #0055cc);
  background-image: -o-linear-gradient(top, #0088cc, #0055cc);
  background-image: linear-gradient(top, #0088cc, #0055cc);
  background-repeat: repeat-x;
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#0088cc', endColorstr='#0055cc', GradientType=0);
  border-color: #0055cc #0055cc #003580;
  border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);
  filter: progid:dximagetransform.microsoft.gradient(enabled=false);
}
.btn-bs-primary:hover,
.btn-bs-primary:active,
.btn-bs-primary.active,
.btn-bs-primary.disabled,
.btn-bs-primary[disabled] {
  background-color: #0055cc;
}
.btn-bs-primary:active,
.btn-bs-primary.active {
  background-color: #004099 \9;
}
.btn-bs-warning {
  background-color: #faa732;
  background-image: -moz-linear-gradient(top, #fbb450, #f89406);
  background-image: -ms-linear-gradient(top, #fbb450, #f89406);
  background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#fbb450), to(#f89406));
  background-image: -webkit-linear-gradient(top, #fbb450, #f89406);
  background-image: -o-linear-gradient(top, #fbb450, #f89406);
  background-image: linear-gradient(top, #fbb450, #f89406);
  background-repeat: repeat-x;
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#fbb450', endColorstr='#f89406', GradientType=0);
  border-color: #f89406 #f89406 #ad6704;
  border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);
  filter: progid:dximagetransform.microsoft.gradient(enabled=false);
}
.btn-bs-warning:hover,
.btn-bs-warning:active,
.btn-bs-warning.active,
.btn-bs-warning.disabled,
.btn-bs-warning[disabled] {
  background-color: #f89406;
}
.btn-bs-warning:active,
.btn-bs-warning.active {
  background-color: #c67605 \9;
}
.btn-bs-danger {
  background-color: #da4f49;
  background-image: -moz-linear-gradient(top, #ee5f5b, #bd362f);
  background-image: -ms-linear-gradient(top, #ee5f5b, #bd362f);
  background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#ee5f5b), to(#bd362f));
  background-image: -webkit-linear-gradient(top, #ee5f5b, #bd362f);
  background-image: -o-linear-gradient(top, #ee5f5b, #bd362f);
  background-image: linear-gradient(top, #ee5f5b, #bd362f);
  background-repeat: repeat-x;
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ee5f5b', endColorstr='#bd362f', GradientType=0);
  border-color: #bd362f #bd362f #802420;
  border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);
  filter: progid:dximagetransform.microsoft.gradient(enabled=false);
}
.btn-bs-danger:hover,
.btn-bs-danger:active,
.btn-bs-danger.active,
.btn-bs-danger.disabled,
.btn-bs-danger[disabled] {
  background-color: #bd362f;
}
.btn-bs-danger:active,
.btn-bs-danger.active {
  background-color: #942a25 \9;
}
.btn-bs-success {
  background-color: #5bb75b;
  background-image: -moz-linear-gradient(top, #62c462, #51a351);
  background-image: -ms-linear-gradient(top, #62c462, #51a351);
  background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#62c462), to(#51a351));
  background-image: -webkit-linear-gradient(top, #62c462, #51a351);
  background-image: -o-linear-gradient(top, #62c462, #51a351);
  background-image: linear-gradient(top, #62c462, #51a351);
  background-repeat: repeat-x;
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#62c462', endColorstr='#51a351', GradientType=0);
  border-color: #51a351 #51a351 #387038;
  border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);
  filter: progid:dximagetransform.microsoft.gradient(enabled=false);
}
.btn-bs-success:hover,
.btn-bs-success:active,
.btn-bs-success.active,
.btn-bs-success.disabled,
.btn-bs-success[disabled] {
  background-color: #51a351;
}
.btn-bs-success:active,
.btn-bs-success.active {
  background-color: #408140 \9;
}
.btn-bs-info {
  background-color: #49afcd;
  background-image: -moz-linear-gradient(top, #5bc0de, #2f96b4);
  background-image: -ms-linear-gradient(top, #5bc0de, #2f96b4);
  background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#5bc0de), to(#2f96b4));
  background-image: -webkit-linear-gradient(top, #5bc0de, #2f96b4);
  background-image: -o-linear-gradient(top, #5bc0de, #2f96b4);
  background-image: linear-gradient(top, #5bc0de, #2f96b4);
  background-repeat: repeat-x;
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#5bc0de', endColorstr='#2f96b4', GradientType=0);
  border-color: #2f96b4 #2f96b4 #1f6377;
  border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);
  filter: progid:dximagetransform.microsoft.gradient(enabled=false);
}
.btn-bs-info:hover,
.btn-bs-info:active,
.btn-bs-info.active,
.btn-bs-info.disabled,
.btn-bs-info[disabled] {
  background-color: #2f96b4;
}
.btn-bs-info:active,
.btn-bs-info.active {
  background-color: #24748c \9;
}
.btn-bs-inverse {
  background-color: #414141;
  background-image: -moz-linear-gradient(top, #555555, #222222);
  background-image: -ms-linear-gradient(top, #555555, #222222);
  background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#555555), to(#222222));
  background-image: -webkit-linear-gradient(top, #555555, #222222);
  background-image: -o-linear-gradient(top, #555555, #222222);
  background-image: linear-gradient(top, #555555, #222222);
  background-repeat: repeat-x;
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#555555', endColorstr='#222222', GradientType=0);
  border-color: #222222 #222222 #000000;
  border-color: rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);
  filter: progid:dximagetransform.microsoft.gradient(enabled=false);
}
.btn-bs-inverse:hover,
.btn-bs-inverse:active,
.btn-bs-inverse.active,
.btn-bs-inverse.disabled,
.btn-bs-inverse[disabled] {
  background-color: #222222;
}
.btn-bs-inverse:active,
.btn-bs-inverse.active {
  background-color: #080808 \9;
}
button.btn-bs,
input[type="submit"].btn-bs {
  *padding-top: 2px;
  *padding-bottom: 2px;
}
button.btn-bs::-moz-focus-inner,
input[type="submit"].btn-bs::-moz-focus-inner {
  padding: 0;
  border: 0;
}
button.btn-bs.btn-bs-large,
input[type="submit"].btn-bs.btn-bs-large {
  *padding-top: 7px;
  *padding-bottom: 7px;
}
button.btn-bs.btn-bs-small,
input[type="submit"].btn-bs.btn-bs-small {
  *padding-top: 3px;
  *padding-bottom: 3px;
}
button.btn-bs.btn-bs-mini,
input[type="submit"].btn-bs.btn-bs-mini {
  *padding-top: 1px;
  *padding-bottom: 1px;
}
.btn-bs-group {
  position: relative;
  *zoom: 1;
  *margin-left: .3em;
}
.btn-bs-group:before,
.btn-bs-group:after {
  display: table;
  content: "";
}
.btn-bs-group:after {
  clear: both;
}
.btn-bs-group:first-child {
  *margin-left: 0;
}
.btn-bs-group + .btn-bs-group {
  margin-left: 5px;
}
.btn-bs-toolbar {
  margin-top: 9px;
  margin-bottom: 9px;
}
.btn-bs-toolbar .btn-bs-group {
  display: inline-block;
  *display: inline;

  *zoom: 1;
}
.btn-bs-group .btn-bs {
  position: relative;
  float: left;
  margin-left: -1px;
  -webkit-border-radius: 0;
  -moz-border-radius: 0;
  border-radius: 0;
}
.btn-bs-group .btn-bs:first-child {
  margin-left: 0;
  -webkit-border-top-left-radius: 4px;
  -moz-border-radius-topleft: 4px;
  border-top-left-radius: 4px;
  -webkit-border-bottom-left-radius: 4px;
  -moz-border-radius-bottomleft: 4px;
  border-bottom-left-radius: 4px;
}
.btn-bs-group .btn-bs:last-child,
.btn-bs-group .dropdown-toggle {
  -webkit-border-top-right-radius: 4px;
  -moz-border-radius-topright: 4px;
  border-top-right-radius: 4px;
  -webkit-border-bottom-right-radius: 4px;
  -moz-border-radius-bottomright: 4px;
  border-bottom-right-radius: 4px;
}
.btn-bs-group .btn-bs.large:first-child {
  margin-left: 0;
  -webkit-border-top-left-radius: 6px;
  -moz-border-radius-topleft: 6px;
  border-top-left-radius: 6px;
  -webkit-border-bottom-left-radius: 6px;
  -moz-border-radius-bottomleft: 6px;
  border-bottom-left-radius: 6px;
}
.btn-bs-group .btn-bs.large:last-child,
.btn-bs-group .large.dropdown-toggle {
  -webkit-border-top-right-radius: 6px;
  -moz-border-radius-topright: 6px;
  border-top-right-radius: 6px;
  -webkit-border-bottom-right-radius: 6px;
  -moz-border-radius-bottomright: 6px;
  border-bottom-right-radius: 6px;
}
.btn-bs-group .btn-bs:hover,
.btn-bs-group .btn-bs:focus,
.btn-bs-group .btn-bs:active,
.btn-bs-group .btn-bs.active {
  z-index: 2;
}
.btn-bs-group .dropdown-toggle:active,
.btn-bs-group.open .dropdown-toggle {
  outline: 0;
}
.btn-bs-group .dropdown-toggle {
  padding-left: 8px;
  padding-right: 8px;
  -webkit-box-shadow: inset 1px 0 0 rgba(255, 255, 255, 0.125), inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);
  -moz-box-shadow: inset 1px 0 0 rgba(255, 255, 255, 0.125), inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);
  box-shadow: inset 1px 0 0 rgba(255, 255, 255, 0.125), inset 0 1px 0 rgba(255, 255, 255, 0.2), 0 1px 2px rgba(0, 0, 0, 0.05);
  *padding-top: 3px;
  *padding-bottom: 3px;
}
.btn-bs-group .btn-bs-mini.dropdown-toggle {
  padding-left: 5px;
  padding-right: 5px;
  *padding-top: 1px;
  *padding-bottom: 1px;
}
.btn-bs-group .btn-bs-small.dropdown-toggle {
  *padding-top: 4px;
  *padding-bottom: 4px;
}
.btn-bs-group .btn-bs-large.dropdown-toggle {
  padding-left: 12px;
  padding-right: 12px;
}
.btn-bs-group.open {
  *z-index: 1000;
}
.btn-bs-group.open .dropdown-menu {
  display: block;
  margin-top: 1px;
  -webkit-border-radius: 5px;
  -moz-border-radius: 5px;
  border-radius: 5px;
}
.btn-bs-group.open .dropdown-toggle {
  background-image: none;
  -webkit-box-shadow: inset 0 1px 6px rgba(0, 0, 0, 0.15), 0 1px 2px rgba(0, 0, 0, 0.05);
  -moz-box-shadow: inset 0 1px 6px rgba(0, 0, 0, 0.15), 0 1px 2px rgba(0, 0, 0, 0.05);
  box-shadow: inset 0 1px 6px rgba(0, 0, 0, 0.15), 0 1px 2px rgba(0, 0, 0, 0.05);
}
.btn-bs .caret {
  margin-top: 7px;
  margin-left: 0;
}
.btn-bs:hover .caret,
.open.btn-bs-group .caret {
  opacity: 1;
  filter: alpha(opacity=100);
}
.btn-bs-mini .caret {
  margin-top: 5px;
}
.btn-bs-small .caret {
  margin-top: 6px;
}
.btn-bs-large .caret {
  margin-top: 6px;
  border-left: 5px solid transparent;
  border-right: 5px solid transparent;
  border-top: 5px solid #000000;
}
.btn-bs-primary .caret,
.btn-bs-warning .caret,
.btn-bs-danger .caret,
.btn-bs-info .caret,
.btn-bs-success .caret,
.btn-bs-inverse .caret {
  border-top-color: #ffffff;
  border-bottom-color: #ffffff;
  opacity: 0.75;
  filter: alpha(opacity=75);
}
*/
.modal-footer a{
	text-decoration:none !important;
}

.project_task_message{
	color: red;
}

.group-sharing-explanation{
	/*background-color: #FCDE87;*/
	margin-bottom: 12px;
	padding: 6px;
	max-width: 700px;
}

.all-internal-user-sharing-container input{
	float:left;
}
.all-internal-user-sharing-container label{
	float:left;
	margin-left: 6px;
	margin-bottom: 0px;
	margin-top: 1px;
}

.feedcontainer .feeditemcommentplaceholder input[readonly]{
  cursor: text !important;
}

.controls select{
  height: 30px;
  line-heihgt:30px;
}
.form-horizontal .control-label{
  padding-top: 0px !important;
}


.button {
  position: relative;
  display: inline-block;
  padding: 0;
  background: transparent;
    background-clip: padding-box;
  border: none;
    border-radius: 0.25rem;
  color: #0070d2;
  font-size: inherit;
  line-height: 2.125rem;
  text-decoration: none;
  -webkit-appearance: none;
  white-space: normal;
  user-select: none;
  transition: color 0.05s linear, background-color 0.05s linear; }
  .button:hover,
  .button:focus,
  .button:active,
  .button:visited {
    text-decoration: none; }
  .button:link,
  .button:visited {
    color: #0070d2; }
  .button:hover,
  .button:focus {
    color: #005fb2; }
  .button:focus {
    outline: 0;
    box-shadow: 0 0 3px #0070D2; }
  .button:active {
    color: #00396b; }
  .button[disabled] {
    color: #e0e5ee; }
  .button + .button,
  .button + .button-group,
  .button-group + .button {
    margin-left: 0.25rem; }


.button--brand {
  padding-left: 1rem;
  padding-right: 1rem;
  text-align: center;
  vertical-align: middle;
  background-color: #0070d2;
  border-color: #0070d2;
  color: white; }
  .button--brand:link,
  .button--brand:visited,
  .button--brand:active {
    color: white; }
  .button--brand:hover,
  .button--brand:focus {
    background-color: #005fb2;
    color: white; }
  .button--brand:active {
    background-color: #00396b; }
  .button--brand[disabled] {
    background: #e0e5ee;
    border-color: transparent;
    color: white; }

.button--neutral {
  padding-left: 1rem;
  padding-right: 1rem;
  text-align: center;
  vertical-align: middle;
  border: 1px solid #d8dde6;
  background-color: white; }
  .button--neutral:hover,
  .button--neutral:focus {
    background-color: #f4f6f9; }
  .button--neutral:active {
    background-color: #eef1f6; }
  .button--neutral[disabled] {
    background-color: white;
    cursor: default; }

.button {
  font-weight: initial !important;
}