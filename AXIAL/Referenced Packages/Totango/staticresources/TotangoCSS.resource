
/* Totango Demo CSS */
.t-hidden{display:none !important;}
.t-assistive-text{position:absolute;top:0;left:0;clip:rect(1px, 1px, 1px, 1px);*clip:rect(1px 1px 1px 1px)}
.t-detail-body,.t-button{font-family:"Avenir Next",Avenir,Helvetica,Arial,sans-serif;font-weight:100;}
.t-detail-body{padding:0;}
.t-outer{padding:30px 0;height:210px;}
.t-outer:before,.t-outer:after{content: " ";display: table;}
.t-outer:after{clear:both;}
.t-row{zoom:1;}
.t-col{min-height:1px;float:left;zoom:1;position:relative;box-sizing:border-box;}
.t-col:last-child{float:none;display:table-cell;vertical-align:top;width:10000px !important;}
.t-size1of3{width:33.333333% !important;}
.t-size2of3{width:66.666667% !important;}
.t-size1of2{width:50% !important;}
.t-size1of4{width:25% !important;}
.t-size1of5{width:20% !important;}
.t-health-primary{position:relative;}
.t-health-gauge{display:block;margin:0 auto;}
.t-health-score{margin:0;text-align:center;height:50px;line-height:48px;font-size:1.75em;font-weight:100;}
.t-health-score-primary{font-weight:400;}
.t-insight-row-top{}
.t-insight-row-bottom{}
.t-insight-heading,.t-insight-content{text-align:center;margin:0;height:50px;line-height:50px;}
.t-insight-content{line-height:20px;}
.t-insight-heading{position:relative;font-size:1.25em;font-weight:500;}
.t-insight-primary{font-size:1.75em;font-weight:500;}
.t-insight-secondary{margin-left:.35em;color:rgba(0,0,0,.5);font-weight:normal;}
.t-insight-secondary-small{position:absolute;bottom:10px;text-align:center;width:100%;font-size:.75em;}
.t-insight-poor{color:rgb(221,0,45);}
.t-insight-average{color:rgb(239,185,0);}
.t-insight-good{color:rgb(117,210,124);}
.t-insight-unknown{color:#000000;}
.t-insight-row-top .t-col1,.t-insight-row-top .t-col3{border-radius:10px 10px 0 0;}
.t-insight-row-bottom .t-col1,.t-insight-row-bottom .t-col3{border-radius:0 0 10px 10px;}
.t-insight-row-bottom .t-insight-heading-only{padding-bottom:5px;}
.t-insight-variable-increase:before,.t-insight-variable-decrease:before,.t-insight-variable-no-change:before{display:inline-block;position:relative;top:-5px;font-weight:bold;margin-right:5px;font-size:.85em;}
.t-insight-variable-increase:before{content:"\2191";}
.t-insight-variable-decrease:before{content:"\2193";}
.t-insight-variable-no-change:before{content:"\2194";}
.t-logo{position:absolute;width:75px;height:13px;top:10px;left:50%;margin-left:-37px;}
.t-last-updated{font-size:.75em;white-space:nowrap;margin-top:-10px;text-align:center;}
.t-insight-reason{position:absolute;display:block;color:rgb(255,255,255);text-decoration:none;top:0;right:0;bottom:0;left:0;}
.t-insight-reason:hover{text-decoration:none;}
.t-insight-handle{font-weight:500;display:block;font-size:.85em;opacity:.4;position:absolute;top:11px;left:10px;height:24px;line-height:26px;width:24px;border-radius:12px;background-color:rgb(186,186,186);text-align:center;}
.t-insight-reason:hover .t-insight-handle,.t-insight-reason:focus .t-insight-handle{z-index:2;opacity:1;}
.t-insight-detail{background-color:rgba(0,0,0,.85);display:none;position:absolute;top:0;right:0;bottom:0;left:0;line-height:normal;text-align:left;border-radius:10px;z-index:1;}
.t-insight-reason:hover .t-insight-detail,.t-insight-reason:focus .t-insight-detail{display:block;}
.t-insight-reason-header,.t-insight-reason-description{margin:10px;font-weight:100;}
.t-insight-reason-header{white-space:nowrap;font-size:1.2em;font-weight:500;margin-left:43px;}
.t-insight-reason-description{font-size:.85em;}
.t-insight-reason:hover .t-insight-handle-Green,.t-insight-reason:focus .t-insight-handle-Green{background-color:rgb(117,210,124);}
.t-insight-reason:hover .t-insight-handle-Yellow,.t-insight-reason:focus .t-insight-handle-Yellow{background-color:rgb(239,185,0);}
.t-insight-reason:hover .t-insight-handle-Red,.t-insight-reason:focus .t-insight-handle-Red{background-color:rgb(221,0,45);}
.t-insight-reason:hover .t-insight-handle-Gray,.t-insight-reason:focus .t-insight-handle-Gray{background-color:#999999;}
.t-online-status{display:block;width:24px;height:24px;margin:0 auto;}
.t-offline{background-color:rgb(186,186,186);opacity:.4;}
.t-online{background-color:green;opacity:.4;}
.t-lifecycle-stage{position:relative;top:-10px;width:48px;height:48px;display:inline-block;background-size:48px 192px;background-position:left -144px;}
.t-Onboarding{background-position:left top;}
.t-Established{background-position:left -48px;}
.t-Renewal{background-position:left -96px;}
.t-lifecycle-stage-text{display:inline-block;padding-left:10px;position:relative;top:-31px;font-size:1.5em;}
.t-button{display:inline-block;margin-bottom:5px;position:relative;height:32px;line-height:32px;text-decoration:none;background-color:rgb(32,32,32);background-image:-webkit-linear-gradient(rgba(255,255,255,0.1),rgba(255,255,255,0));color:rgb(255,255,255);padding:0 10px;font-size:1em;border:0 none;border-radius:2px;border:1px solid rgba(255,255,255,0.1);}
.t-button:hover,.t-button:focus{text-decoration:none;background-image:-webkit-linear-gradient(rgba(255,255,255,0.2),rgba(255,255,255,0.1));}
.t-button:active{bottom:-1px;}
.t-action-links{padding-top:30px;text-align:center;}
.t-action-panel{display:none;position:absolute;top:0;right:0;bottom:0;left:0;border-radius:5px;background-color:rgba(0,0,0,.9);padding:20px 10px;}
.t-action-panel-content{width:100%;text-align:center;height:50px;line-height:50px;position:absolute;top:50%;margin-top:-25px;font-weight:normal;}
.t-action-panel-dismiss{display:block;height:32px;width:32px;line-height:32px;text-align:center;position:absolute;top:10px;right:10px;text-decoration:none;color:rgb(255,255,255);font-size:2em;font-weight:bold;opacity:.75;}
.t-action-panel-dismiss:hover,.t-action-panel-dismiss:focus{text-decoration:none;opacity:1;}
.t-action-panel-insight{position:relative;border-radius:5px;height:230px;margin:0 10px;background-color:rgb(255,255,255);}
.t-action-panel-insight-links{box-shadow:none;background-color:transparent;}
.t-action-panel-insight-links .t-action-panel-content{height:111px;margin-top:-56px;}
.t-health-face{width:130px;height:130px;display:block;margin:0 auto;background-position:left 25px;}
.t-health-happy-face{background-image:url("https://app.totango.com/revisioned_files/css/img/icon-health-good.png");}
.t-health-sad-face{background-image:url("https://app.totango.com/revisioned_files/css/img/icon-health-poor.png");}
.t-health-meh-face{background-image:url("https://app.totango.com/revisioned_files/css/img/icon-health-average.png");}
.t-health-unknown-face{background-image:url("https://app.totango.com/revisioned_files/css/img/icon-status-free.png");}
.t-csm-thumbnail{display:block;margin:0 auto 20px;}