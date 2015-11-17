function re(s){var q =ge(s);if (q!=null) q.parentNode.removeChild(q);}
function nullf(){}
function ge(s){return document.getElementById(s);}
function sleep(milliseconds){ var now = new Date(); var exitTime = now.getTime() + milliseconds; while (true) { now = new Date(); if (now.getTime() > exitTime) return; } }
function sleeperQuery(sUser,iRecallInt){
say('sleeper called: ' + sUser + ' recallint ' + iRecallInt);
try {
 var result = sforce.connection.query("Select Id from User where Id = '" + sUser + "'");
 var records = result.getArray("records");
 }
catch (err) {}
if (iRecallInt!=null) { setTimeout("sleeperQuery(sUser," + iRecallInt + ")",iRecallInt);}
}

function SetCtAddrToLocAddr(sCtId, sLocaleId){
try {
var resLoc = sforce.connection.query("Select c.Id, c.Country__c, c.Zip__c, c.State__c, c.City__c, c.Street1__c, c.Street2__c, c.Street3__c from OrgLocale__c c where Id = '" + sLocaleId + "'");
var recordsLoc = resLoc.getArray("records");
if (recordsLoc!=null && recordsLoc.length==1) { var qLoc = recordsLoc[0];
 var resCt = sforce.connection.query("Select c.Id, c.PrimaryAddrCountry__c, c.PrimaryAddrZip__c, c.PrimaryAddrState__c, c.PrimaryAddrCity__c, c.PrimaryAddrStreet1__c, c.PrimaryAddrStreet2__c, c.PrimaryAddrStreet3__c from Contact c where Id = '" + sCtId + "'");
 var recordsCt = resCt.getArray("records");
 if (recordsCt!=null && recordsCt.length==1) {
    var qCt=recordsCt[0];
    qCt.PrimaryAddrCountry__c = qLoc.Country__c;
    qCt.PrimaryAddrZip__c = qLoc.Zip__c;
    qCt.PrimaryAddrState__c = qLoc.State__c;
    qCt.PrimaryAddrCity__c = qLoc.City__c;
    qCt.PrimaryAddrStreet1__c = qLoc.Street1__c;
    qCt.PrimaryAddrStreet2__c = qLoc.Street2__c;
    qCt.PrimaryAddrStreet3__c = qLoc.Street3__c;
    var res3 = sforce.connection.update([qCt]);
    if (!res3[0].getBoolean("success")) alert("Error updating current role: " + res3[0]); 
  }
 else alert('Could not find contact record associated with id:' + sCtId);  }
 else alert('Could not find locale record associated with id:' + sLocaleId); }
catch (err) { alert("Error trying to update address for contact to locale:" + err);}
}

function fDelContactShortList(atCfg,fldCfgs,rec) {
	var delResult=sforce.connection.deleteIds([rec.CurrentOrgContactRole__c]);
	return delResult;
}



function showWindowAsDialogue(elAnchor, locAnchOffsetTop, locAnchOffsetLeft, sBGDivID,sIFrameDivID, sIFrameID, sIFrameURL, iWidth, iHeight){
 dimBG(sBGDivID);
 var el = document.createElement("div");
 el.id = sIFrameDivID;
 el.style.display="inline"; 
 el.style.position="absolute";
 el.style.backgroundColor="white";
 el.style.border="3px solid grey";
 el.style.padding="2px";
 el.style.zIndex=2;
 if (elAnchor != null) {
	 var pos = getElementPositionByElem(elAnchor);
	 el.style.left = pos.left+locAnchOffsetLeft;
	 el.style.top = pos.top+locAnchOffsetTop;
 }
 else
 {
	 var qx = autoCenter(iHeight, iWidth);
	 el.style.left = qx.left+locAnchOffsetLeft;
	 el.style.top = qx.top+locAnchOffsetTop;
 }
 
 var elf = document.createElement("IFRAME");
 elf.src = sIFrameURL;
 elf.frameBorder = "0";
 elf.marginHeight="0";
 elf.scrolling="no"
 elf.id= sIFrameID;
 elf.style.height=""+iHeight+"px";
 elf.style.width=""+iWidth+"px"; elf.
 style.border="0px solid black";
 el.appendChild(elf);
 document.body.appendChild(el);
}

function toggleCollapse(sId,sUser, bSerializeState, pToggleFunc){
var SetTo='';
var btn = ge('bt_'+sId);
var dv = ge('content_' + sId);
var s=btn.value;
if (s==" + ") {
 SetTo='EXPANDED';
 btn.value = " -- ";
 dv.style.display="block";
 }
 else
 {
 SetTo='COLLAPSED';
 dv.style.display="none";
 btn.value = " + ";
 }
if (pToggleFunc != null && pToggleFunc!='null') pToggleFunc(SetTo);
if (bSerializeState==true)
 SaveCollapseBarState(SetTo,sUser,sId);
}
function SvSrchSttgs(sSt,sUser,sId)
{
var sTg="";
try {
 var result=sforce.connection.query("Select Id, SearchCheckSettings__c from User where Id = '" + sUser + "'");
 var records= result.getArray("records");
 var rec = records[0];
 if (rec.SearchCheckSettings__c!=null) sTg = rec.SearchCheckSettings__c;
// var sId = sId; 
 var sTgOut="" + sId + ":" + sSt + "#";
 var sX=sTg.split("#");
 for (var s2 in sX) { var sq=sX[s2]; if (sq != "") { var sq2 = sq.split(":");  if (sq2[0]!= sId ) { sTgOut+=sq + "#"; } } }
 rec.SearchCheckSettings__c = sTgOut;
 result = sforce.connection.update([rec]);
 if (!result[0].getBoolean("success")) alert("Error saving search setting " + result[0]);
 }
 catch (err) { alert('Error saving search settings:' + err); } 
 }

function SvSecSttgs(sSt,sUser,sId)
{
var sTg="";
try {
 var result=sforce.connection.query("Select Id, ViewSectionSettings__c from User where Id = '" + sUser + "'");
 var records= result.getArray("records");
 var rec = records[0];
 if (rec.ViewSectionSettings__c!=null) sTg = rec.ViewSectionSettings__c;
 var sId = "cbv" + sId;
 var sTgOut="--" + sId + "--:" + sSt + "#";
 var sX=sTg.split("#");
 for (var s2 in sX) { var sq=sX[s2]; if (sq != "") { var sq2 = sq.split("--");  if (sq2[1]!= sId ) { sTgOut+=sq + "#"; } } }
 rec.ViewSectionSettings__c = sTgOut;
 result = sforce.connection.update([rec]);
 if (!result[0].getBoolean("success")) alert("Error saving section setting " + result[0]);
 }
 catch (err) { alert('Error saving section settings:' + err); } 
 }

function SaveCollapseBarState(sSt,sUser,sId)
{
var sTg = "";
try {
 var result = sforce.connection.query("Select Id, CollapseBarSettings__c from User where Id = '" + sUser + "'");
 var records = result.getArray("records");
 var rec = records[0];
 if (rec.CollapseBarSettings__c!=null)
 sTg = rec.CollapseBarSettings__c;
 
 var sId = "cbr" + sId;
 var sTgOut="--" + sId + "--:" + sSt + "#";

 var sX=sTg.split("#");
 
 for (var s2 in sX) {
 var sq=sX[s2];
 if (sq != "") {
 var sq2 = sq.split("--");
 
 if (sq2[1]!= sId ) {
 sTgOut+=sq + "#";
 }
 }
 }
 
 // now save sTgOut
 rec.CollapseBarSettings__c = sTgOut;
 result = sforce.connection.update([rec]);
 if (!result[0].getBoolean("success")) 
 alert("failed to update collapse bar setting " + result[0]);
 }
 catch (err)
 {
 alert('Error trying to save collapse bar settings:' + err);
 }
}

function dimBG(sNewDivId) {
	var pd = document.createElement("div");
	if (sNewDivId!=null) pd.id=sNewDivId
	pd.className="promptdiv";
	pd.style.top="0";
	pd.style.top="0";
	pd.style.zIndex=1;
	var qCrd = getWindowSize();
	pd.style.height = qCrd.scrollHeight;
	pd.style.width=qCrd.scrollWidth;
	pd.style.display="inline";
	document.body.appendChild(pd);
	return(pd);
}

function autoCenter(h,w)
{
    var q = getWindowSize();
    //var qtx = top.document;
    var st = document.documentElement.scrollTop; var sl = document.documentElement.scrollLeft;
    var t=   (((q.pageHeight/2)+st)-(h/2));
    if (t < st) t = st;
    var l = ((sl+(q.pageWidth/2))-(w/2));
    if (l < sl) l = sl;
    return { top:t, left:l };
}                 

function pageWidth() {return window.innerWidth != null? window.innerWidth : document.documentElement && document.documentElement.clientWidth ?       document.documentElement.clientWidth : document.body != null ? document.body.clientWidth : null;}
function pageHeight() {return  window.innerHeight != null? window.innerHeight : document.documentElement && document.documentElement.clientHeight ?  document.documentElement.clientHeight : document.body != null? document.body.clientHeight : null;}

function getWindowSize() {
var theWidth,theHeight, theScrollHeight, theScrollWidth, thePageHeight, thePageWidth;
thePageWidth=pageWidth();thePageHeight=pageHeight();
if (document.body) {
 theScrollWidth = document.body.scrollWidth;
 theWidth=document.body.clientWidth; 
 if (theScrollWidth==null || theScrollWidth < theWidth ) theScrollWidth = theWidth;
 
 
 theScrollHeight = document.body.scrollHeight;
 theHeight=document.body.clientHeight;
 if (theScrollHeight==null || theScrollHeight < theHeight ) theScrollHeight=theHeight;
}

	 return {height:theHeight, width:theWidth, scrollHeight:theScrollHeight, scrollWidth:theScrollWidth, pageHeight:thePageHeight, pageWidth:thePageWidth}; 
}


function getElementPositionByElem(offsetTrail)
{ var offsetLeft = 0; var offsetTop = 0;
 while(offsetTrail) {
 if (offsetTrail.style.position!="absolute") {
 offsetLeft += offsetTrail.offsetLeft;
 offsetTop += offsetTrail.offsetTop;
 } offsetTrail = offsetTrail.offsetParent;
 } if (navigator.userAgent.indexOf("Mac") != -1 && typeof document.body.leftMargin != "undefined") {
 offsetLeft += document.body.leftMargin;
 offsetTop += document.body.topMargin;
 } return {left:offsetLeft, top:offsetTop};
}



function getElementSize(elemID){ 
 var elD = ge(elemID);
 var theWidth,theHeight;
 theHeight=elD.clientHeight;
 if (theHeight==0 && elD.offsetHeight!=0)	theHeight = elD.offsetHeight;
 theWidth=elD.clientWidth;
 if (theWidth==0 && elD.offsetWidth!=0)	theWidth = elD.offsetWidth;
 return { width:theWidth, height: theHeight };
 }

function gep(e){return getElementPosition(e);}
function getElementPosition(elemID){ 
	var offsetTrail= ge(elemID ); 
	return getElementPositionByElem(offsetTrail);
}

function setTextFocus(sid) { var t = ge(sid); t.focus(); try { t.select(); } catch (err) { }} 
function ToggleCLUButton(sAction, sButtonId, sTextId, sStatusId, bIsDate)
{ 
var btn = ge(sButtonId);
var txt = ge(sTextId);
if (sAction=='OFF') {
 var offset=gep(sButtonId);
 btn.style.visibility="hidden";
 var xpb = gep(sButtonId);
 var xpt = gep(sTextId);
 txt.style.visibility="visible";
  txt.style.left = (offset.left-xpt.left)+"px";
setTimeout("setTextFocus('" + sTextId + "')",200);
 if (sStatusId!=null) {
  var eld = ge(sStatusId);
  if (eld!=null) { { eld.innerHTML = "?"; eld.style.color = "orange"; } }
  }
 if (bIsDate!=null && bIsDate == true) showCalendar(btn.id,txt.id);
 } 
else 
 {
 say('toggling button on [' + sButtonId + '] / text off');
 btn.style.visibility="visible";
 txt.style.visibility="hidden";
 if (bIsDate != null && bIsDate) {
 var dtxd = ge(txt.id+"dtcala");
 if (dtxd!=null) 
 document.body.removeChild(dtxd);
 dtxd = ge(txt.id+"dtcaldiv");
 if (dtxd!=null) 
 dtxd.style.visibility="hidden";
 }
 btn.focus();
 if (sStatusId!=null) {
 var eld = ge(sStatusId);
 if (eld!=null) {
 { eld.innerHTML = "*"; eld.style.color = "green"; }
 
 }
 }
 }
return false;
}

// date calendar popup stuff
function calDateChosen(y,m,d){ 
say("caldatechosen called");
 if (window.CP_targetInput!=null) {
 var dt = new Date(y,m-1,d,0,0,0);
 if (window.CP_calendarObject!=null) { window.CP_calendarObject.copyMonthNamesToWindow(); }
 window.CP_targetInput.value = formatDate(dt,window.CP_dateFormat);
 if(window.CP_targetInput.onrowsdelete) 
 window.CP_targetInput.onrowsdelete();
 }
}

function showCalendar(sLocationId,sTextId) {
 var tdx = ge(sTextId);
 var xLoc = gep(sLocationId);
 var dtxd = ge(sTextId+"dtcala");
 if (dtxd!=null) 
 document.body.removeChild(dtxd);
 dtxd = ge(sTextId+"dtcaldiv");
 var ela = document.createElement("a");
 ela.innerHTML=" ";
 ela.style.visibility="hidden";
 ela.id= sTextId+"dtcala";
 ela.name = ela.id;
 ela.style.position="absolute";
 ela.style.top=xLoc.top;
 ela.style.left=xLoc.left+150;
 document.body.appendChild(ela);
 var eld = dtxd;
 if (eld==null)
 {
 eld = document.createElement("div");
 eld.id = sTextId+"dtcaldiv";
 document.body.appendChild(eld);
 }
 eld.style.position="absolute";
 eld.style.backgroundColor="white";
 eld.style.top=xLoc.top;
 eld.style.zIndex=100;
 eld.style.left=xLoc.left;
 var cal = new CalendarPopup(eld.id);
 cal.setReturnFunction('calDateChosen');
 cal.setYearSelectStartOffset(60);
 cal.showNavigationDropdowns();
 cal.select(tdx, ela.id, 'MM/dd/yyyy');
}

// share buttonselect functions
function bselect_postUpdate(sbtID,sVal,sText,sObjectFieldToUpdateUponEnter,sObjectTypeToUpdateUponEnter,sObjectIDToUpdateUponEnter)	{
//create the object
try {
var els = ge(sbtID+'_status');
els.innerHTML="?";
els.style.color="blue";
var obj = new sforce.SObject(sObjectTypeToUpdateUponEnter);
obj[sObjectFieldToUpdateUponEnter]=(sVal == '' ? null : sVal);
obj.id=sObjectIDToUpdateUponEnter;
var state = {ObjectFieldToUpdateUponEnter: sObjectFieldToUpdateUponEnter ,ObjectTypeToUpdateUponEnter:sObjectTypeToUpdateUponEnter, btID: sbtID, Value:sVal,Text:sText};
var result = sforce.connection.update([obj],
{
onSuccess : bselect_update_success,
onFailure : bselect_update_error,
source : state
}
);

} catch (err) {
alert("Exception updating id " + sObjectTypeToUpdateUponEnter + " " + sObjectIDToUpdateUponEnter + ":" + err);
}
}

function bselect_update_success(results,source) { 
 say('bselect update: ' + source.ObjectFieldToUpdateUponEnter + ' received val ' + source.Value);
 var els = ge(source.btID+ '_status');
 els.innerHTML="*";
 els.style.color="green"; 
 var btn = ge(source.btID+'_ToggleButton');
 var sVal = source.Value;//txt.value); 
 btn.value = source.Text;//sVal;
 var txt = ge(source.btID+'_updatedText');
 txt.value=sVal;
 }

function bselect_update_error(error,source) {
 alert("Error attempting to update " + source.ObjectFieldToUpdateUponEnter + ":" + error);
 say('btext ' + source.ObjectFieldToUpdateUponEnter + ' received val ' + source.Value);//result.Name + " -- " + result.Id);
 var els = ge(source.btID+ '_status');
 els.innerHTML="!";
 els.style.color="red"; 

}
// shared buttonselect functions end
// shared clu functions start

function clu_data(cluID) {
	var sid = "";
	var sval = "";
	var ssrch = $('#'+cluID+'_cluSearchText').val();
	var elemCurrRow = ge(cluID+'_selected_row'); 
	if (elemCurrRow!=null && elemCurrRow.value != null && elemCurrRow.value != '') {
		var sID = cluID+'_ID_r'+elemCurrRow.value; 
		var elemID = ge(sID); if (elemID!=null) sid = elemID.value;
		var sValID = cluID+'_VAL_r'+elemCurrRow.value;
		elemID = ge(sValID); if (elemID!=null) sval= elemID.value;

	}
	else
	{
			var el2 = ge(cluID+'_updatedID'); 
			sid = el2.value;
			el2 = ge(cluID+'_updatedText'); 
			sval = el2.value;
	}
/*	var sid = '';
	var sval='';
	if (sid!=null && sid < 0) {*/
//	}

	return { id: sid, val: sval, search:ssrch };
}


function clear_clu(cluID) {
 var txt=ge(cluID+'_cluSearchText'); txt.value = "";
 var btn=ge(cluID+'_ToggleButton'); btn.value = "";
 var el2 = ge(cluID+'_updatedID'); if (el2!=null) el2.value = "";
 el2 = ge(cluID+'_updatedText'); if (el2!=null) el2.value = "";
 
 var elemCurrRow = ge(cluID+'_selected_row'); 
 var sID = cluID+'_ID_r'+elemCurrRow.value; 
 var elemID = ge(sID); if (elemID!=null) elemID.value = "";
 var sValID = cluID+'_VAL_r'+elemCurrRow.value;
 elemID = ge(sValID); if (elemID!=null) elemID.value = "";
}



function clu_add_success_setup_post_update(results,source){
 if (source.AddNewFields != source.outputfields) {
 try {
 var sQ = "Select Id, " + source.outputfields + " from " + source.sourceobject + " where Id = '" + results[0].id + "'";
 var result = sforce.connection.query(sQ);
 var records = result.getArray("records"); 
 var flds = (source.outputfields+",").split(",");
 var sRc = "";
 var rec= records[0];
 for (var iFx=0;iFx < flds.length; iFx++) {
 if (flds[iFx] != null && flds[iFx] != '') {
 if ( iFx > 0 )
 sRc += " ";
 sRc += rec[flds[iFx]]; 
 }
 }
 source.Value = sRc;
 } catch (err) {
 alert("Error trying to get value for new item: " + source.Value + ' -- ' + err);
 }
 }

 if (
 source.ObjectFieldToUpdateUponEnter!=null && source.ObjectFieldToUpdateUponEnter!=""
 &&
 source.ObjectTypeToUpdateUponEnter != null && source.ObjectTypeToUpdateUponEnter!= ""
 && 
 source.ObjectIDToUpdateUponEnter != null && source.ObjectIDToUpdateUponEnter != ""
 ) {
 cluPostUpdate(source.cluID, results[0].id, source.Value,source.ObjectFieldToUpdateUponEnter,source.ObjectTypeToUpdateUponEnter,source.ObjectIDToUpdateUponEnter
 , source.JavascriptCallbackFunction, source.pasteSelectedIDToHTMLElement, source.highlightValueAfterSelection, source.PostIDUponSelect
 );
 }

 else
	{
			source.Id = results[0].id;
			clu_cleanup_post_update(source);
	}

}



function cluAddNew(sAddNewObjectType,cluID,sValueToAdd,sAddNewFields, sDefaults, sObjectFieldToUpdateUponEnter,sObjectTypeToUpdateUponEnter,sObjectIDToUpdateUponEnter,
 JavascriptCallbackFunction,pasteSelectedIDToHTMLElement,highlightValueAfterSelection ,bPostIDUponSelect, outputfields, sourceobject, bInforceNonNullOnFieldValues, sPrompt) 

{
 try
 {
 var els = ge(cluID+'_status');
 els.innerHTML="?";
 els.style.color="blue";

 // create the object
 var obj = new sforce.SObject(sAddNewObjectType);
 var vFldValues = (trim(sValueToAdd)+'#').split('#');
 var vFldDefaults = (sDefaults+'#').split('#');
 var vFlds = (sAddNewFields+',').split(",");
 for (var iFx=0;iFx < vFlds.length; iFx++)
 {
 if (bInforceNonNullOnFieldValues && vFldValues[iFx]=='' && (iFx != vFlds.length-1))
 	{
 	alert("Values are missing.  The system cannot create the new record.  " + sPrompt);
 	return;
 	}
 if (vFlds[iFx]!=null && vFlds[iFx]!='')  obj[vFlds[iFx]]=vFldValues[iFx];

 }

 for (var iFx=0;iFx < vFldDefaults.length; iFx++)
 {
 var sDef = vFldDefaults[iFx];
 if (sDef!=null && sDef!='') {
 var defaultInfo = (sDef+":").split(":");
 var sFld = defaultInfo[0]; 
 var sVal = defaultInfo[1]; 
 var sType = 'string';
 if (defaultInfo.length > 2)
 sType=defaultInfo[2];


 if (sType.toUpperCase() == 'BOOLEAN')
 {
 sVal = sVal.toUpperCase();
 obj[sFld]= (sVal=='TRUE');
 }
 else if (sType.toUpperCase() == 'NUMBER')
 {
 obj[sFld]= parseFloat(sVal);
 //oNewOrg.put(sFld,Double.valueOf(sVal));
 }
 else
 obj[sFld]=sVal;
 //obj[vFlds[iFx]]=vFldValues[iFx];
 }
 }
 var state = { 
 ObjectIDToUpdateUponEnter : sObjectIDToUpdateUponEnter,ObjectFieldToUpdateUponEnter: sObjectFieldToUpdateUponEnter ,ObjectTypeToUpdateUponEnter:sObjectTypeToUpdateUponEnter, cluID: cluID, Value:sValueToAdd,
 JavascriptCallbackFunction:JavascriptCallbackFunction,
 //JavascriptCallbackFunctionParms:JavascriptCallbackFunctionParms,
 pasteSelectedIDToHTMLElement:pasteSelectedIDToHTMLElement,highlightValueAfterSelection:highlightValueAfterSelection, PostIDUponSelect:bPostIDUponSelect, outputfields:outputfields, 
					AddNewFields:sAddNewFields, sourceobject:sourceobject
 };																																										 
 
 var result = sforce.connection.create([obj],
 {
 onSuccess : clu_add_success_setup_post_update,
 onFailure : clu_insert_error,
 source : state
 }
 ); 
 }
 catch (err) {
 alert("error trying to add new for combo lookup:" + cluID + " " + sValueToAdd + " " + sAddNewFields + " " + sDefaults + " " + sTypeToAdd);
 }
}

function cluPostUpdate(cluid, sChosenId, sChosenVal,sObjectFieldToUpdateUponEnter,sObjectTypeToUpdateUponEnter,sObjectIDToUpdateUponEnter,
 JavascriptCallbackFunction,	sPasteIdToElement, bClearAfterSelect, bPostChosenId)
{
try {
var els = ge(cluid+'_status');
els.innerHTML="?";
els.style.color="blue";

var obj = new sforce.SObject(sObjectTypeToUpdateUponEnter);
obj[sObjectFieldToUpdateUponEnter]=	(bPostChosenId? (sChosenId==""?null:sChosenId) : (sChosenVal==""?null:sChosenVal));

obj.id=sObjectIDToUpdateUponEnter;
var state = {ObjectFieldToUpdateUponEnter: sObjectFieldToUpdateUponEnter ,ObjectTypeToUpdateUponEnter:sObjectTypeToUpdateUponEnter, cluID: cluid, Id:sChosenId , Value:sChosenVal,
 JavascriptCallbackFunction: JavascriptCallbackFunction, PasteIdToElement:sPasteIdToElement, ClearAfterSelect:bClearAfterSelect};
var result = sforce.connection.update([obj],{ onSuccess : clu_update_success, onFailure : clu_update_error,	source : state });
} catch (err) {alert("Exception updating id " + sObjectTypeToUpdateUponEnter + " " + sObjectIDToUpdateUponEnter + ":" + err);}}



function clu_update_error(error,source) {
 alert("Error attempting to update " + source.ObjectFieldToUpdateUponEnter + ":" + error);
 say('clu ' + source.ObjectFieldToUpdateUponEnter + ' received val ' + source.Value);
 var els = ge(source.cluID+ '_status');
 els.innerHTML="!";
 els.style.color="red"; 

}

function clu_cleanup_post_update(source) {
	ge(source.cluID+"_selected_row").value="";
 var sSelectedId = source.Id;
 var els = ge(source.cluID+ '_status');
 els.innerHTML="*";
 els.style.color="green"; 
 var elm = ge(source.cluID+'_updatedText');
 var elmID = ge(source.cluID+'_updatedID');

 var btn = ge(source.cluID+'_ToggleButton');
 var txt = ge(source.cluID+'_cluSearchText');
 var sVal = source.Value;//txt.value); 
 btn.value = (source.ClearAfterSelect?'':sVal);
 txt.value = (source.ClearAfterSelect?'':sVal);
 elm.value=source.Value;
	elmID.value = source.Id;
 ToggleCLUButton('ON',source.cluID+ '_ToggleButton',source.cluID+'_cluSearchText', source.cluID+'_status',false);
 
 if (source.PasteIdToElement!=null && source.PasteIdToElement!='')
 {
 var elT = ge(source.PasteIdToElement);
 if (elT!=null)
 elT.innerHTML=sSelectedId;
 }
 if (source.JavascriptCallbackFunction!=null) 
 source.JavascriptCallbackFunction(sSelectedId );
 


}

function clu_update_success(results,source) {
 say('clu update: ' + source.ObjectFieldToUpdateUponEnter + ' received val ' + source.Value);
 clu_cleanup_post_update(source) ;
 }


function clu_insert_error(error,source) {
 alert("Error attempting to insert " + source.Value + " to " + source.ObjectFieldToUpdateUponEnter + ":" + error);
 say("Error attempting to insert " + source.Value + " to " + source.ObjectFieldToUpdateUponEnter + ":" + error);
 say('clu ' + source.ObjectFieldToUpdateUponEnter + ' received val ' + source.Value);
 var els = ge(source.cluID+ '_status');
 els.innerHTML="!";
 els.style.color="red"; 

}


// shared clu functions end
// some shared button text functions start

function btext_postUpdate(sbtID,sVal,sObjectFieldToUpdateUponEnter,sObjectTypeToUpdateUponEnter,sObjectIDToUpdateUponEnter,bIsCheckbox,bIsDate, sFormatString)
{
//create the object
try {

var els = ge(sbtID+'_status');
els.innerHTML="?";
els.style.color="blue";

var obj = new sforce.SObject(sObjectTypeToUpdateUponEnter);
if (bIsCheckbox)
 obj[sObjectFieldToUpdateUponEnter]=(sVal.toUpperCase()=='TRUE'?true:false);
 else if (bIsDate) {
 var dx = null;
 try {
		 if (sVal=='') {
			 obj[sObjectFieldToUpdateUponEnter]=null;
		 }
		 else {
 dx= parseDate(sVal);
		 if (sVal!=null && sVal != '' && dx == null) {
			 alert("Could not parse date value '" + sVal + "'");
			 return;
		 }
 obj[sObjectFieldToUpdateUponEnter]=dx;
		 }
 }
 catch (err) { alert("error parsing date [" + sVal + "]:" + err); }

 }
 else
 {
 if (sFormatString!=null && sFormatString != '' && sFormatString != 'null' && sFormatString.indexOf('CURRENCY')!=-1)
 sVal = sVal.replace(/,/g,"");
 if (sFormatString!=null && sFormatString != '' && sFormatString != 'null' && sFormatString.indexOf('PERCENT')!=-1)
 {sVal = sVal.replace(/,/g,"");sVal = sVal.replace(/%/g,""); }

 obj[sObjectFieldToUpdateUponEnter]=(sVal == '' ? null : sVal);
 }

obj.id=sObjectIDToUpdateUponEnter;
var state = {ObjectFieldToUpdateUponEnter: sObjectFieldToUpdateUponEnter ,ObjectTypeToUpdateUponEnter:sObjectTypeToUpdateUponEnter, btID: sbtID, Value:sVal, IsCheckbox:bIsCheckbox,FormatString:sFormatString };
 
var result = sforce.connection.update([obj],
{
onSuccess : btext_update_success,
onFailure : btext_update_error,
source : state
}
);

} catch (err) {
alert("Exception updating id " + sObjectTypeToUpdateUponEnter + " " + sObjectIDToUpdateUponEnter + ":" + err);
}
}


function btext_update_success(results,source) { 
 //say('btext update: ' + source.ObjectFieldToUpdateUponEnter + ' received val ' + source.Value);
 if (results!=null && results[0]!=null && results[0].errors != null &&results[0].errors.message!=null)
 	{
 	alert("There was an error attempting to update the value -- " + results[0].errors.message);
 	//return;
 	}  
 var els = ge(source.btID+ '_status');
 els.innerHTML="*";
 els.style.color="green"; 
 var elm = ge(source.btID+'_updatedText');
 var btn = ge(source.btID+'_ToggleButton');
 var txt = ge(source.btID+'_btxtText');
 var sVal = (source.IsCheckbox ? (txt.checked ? 'Yes':'No') : source.Value);//txt.value);
 if (source.FormatString!=null && source.FormatString!='' )
 sVal = autoTableFormatPerConfig(sVal,source.FormatString);

 btn.value = sVal;
 txt.value = sVal;
 txt = ge(source.btID+'_updatedText');
 txt.value=sVal;
 }

function btext_update_error(error,source) {
 alert("Error attempting to update " + source.ObjectFieldToUpdateUponEnter + ":" + error);
 say('btext ' + source.ObjectFieldToUpdateUponEnter + ' received val ' + source.Value);//result.Name + " -- " + result.Id);
 var els = ge(source.btID+ '_status');
 els.innerHTML="!";
 els.style.color="red"; 

}

// some shared button text functions
function addWindowOnLoadEvent(func) { 
 var oldonload = window.onload; 
 if (typeof window.onload != 'function') { 
 window.onload = func; 
 } else { 
 window.onload = function() { 
 if (oldonload) { 
 oldonload(); 
 } 
 func(); 
 } 
 } 
 } 

// promptuser functions
function promptOKCancel(pT,sMsg,sTitle,pOKi,pCani, iTopOffsetIN, iLeftOffsetIN){promptUserFunc(pT,sMsg,'',sTitle,pOKi,pCani, iTopOffsetIN, iLeftOffsetIN, true, false);}
function promptUser(pT,sMsg,sDefault,sTitle,pOKi,pCani, iTopOffsetIN, iLeftOffsetIN){promptUserFunc(pT,sMsg,sDefault,sTitle,pOKi,pCani, iTopOffsetIN, iLeftOffsetIN, true, true);}
function promptUserNoSelect(pT,sMsg,sDefault,sTitle,pOKi,pCani, iTopOffsetIN, iLeftOffsetIN){promptUserFunc(pT,sMsg,sDefault,sTitle,pOKi,pCani, iTopOffsetIN, iLeftOffsetIN, false,true) ;}
function promptUserFunc(pT,sMsg,sDefault,sTitle,pOKi,pCani, iTopOffsetIN, iLeftOffsetIN, bSelectDefault, bIncludeInputTextBox){
  if (sMsg == null) {
  	alert("promptUser(element,message[,default value][,title][,ok function][,cancel function]");
	return;
  }
 var pdT = document.createElement("table");
			pdT.id = "prompttable";
			pdT.style.position = "absolute";
			pdT.className = "prompttable";
			var iTopOffset = 10; if (iTopOffsetIN!=null) iTopOffset=iTopOffsetIN;
			var iLeftOffset = 10; if (iLeftOffsetIN!=null) iLeftOffset=iLeftOffsetIN;
			if (pT!=null) {
				var pos = getElementPositionByElem(pT);
				pdT.style.left = pos.left + iLeftOffset;
				pdT.style.top = pos.top + iTopOffset;
			}

			var tblRow=pdT.insertRow(pdT.rows.length);
			var tblCell = tblRow.insertCell(tblRow.cells.length)
			tblCell.colSpan=2;
			tblCell.innerHTML=sTitle;
			tblCell.id="prompttitle";

			tblRow=pdT.insertRow(pdT.rows.length);
			tblCell = tblRow.insertCell(tblRow.cells.length);
			tblCell.appendChild(document.createElement("br"));
			tblCell.colSpan=2;
			var sP = document.createElement("span");
			sP.id="promptmessage";
			sP.innerHTML=sMsg;//"....";
			tblCell.appendChild(sP);
			tblCell.appendChild(document.createElement("br"));
			tblCell.appendChild(document.createElement("br"));
			tblCell.align="center";

	if (bIncludeInputTextBox) {
	   tblRow=pdT.insertRow(pdT.rows.length);
	   tblCell = tblRow.insertCell(tblRow.cells.length);
	   tblCell.colSpan=2;
	   tblCell.align="center";
	   tblCell.innerHTML="&nbsp;&nbsp;";
	   var pan=document.createElement("input");
	   pan.type="text";
	   pan.id="promptanswer";
	   pan.onkeyup = function(e) { promptKeystroke(this,pOKi, pCani);}
	   tblCell.appendChild(pan);
	   var txt = document.createElement("text");
	   txt.innerHTML="&nbsp;&nbsp;";
	   tblCell.appendChild(txt);
		}

			tblRow=pdT.insertRow(pdT.rows.length);
			tblCell = tblRow.insertCell(tblRow.cells.length);
			tblCell.align="right";
			tblCell.width="50%";
			tblCell.appendChild(document.createElement("br"));
			var iok=document.createElement("input");
			iok.type="button";
			iok.id="promptok";
			iok.value="OK";
			iok.onclick=function(){promptOK(pOKi);}
			tblCell.appendChild(iok);
			txt = document.createElement("text");
			txt.innerHTML="&nbsp;";
			tblCell.appendChild(txt);
			tblCell.appendChild(document.createElement("br"));
			tblCell.appendChild(document.createElement("br"));



			tblCell = tblRow.insertCell(tblRow.cells.length);
			tblCell.align="left";
			tblCell.width="50%";
			tblCell.appendChild(document.createElement("br"));
			txt = document.createElement("text");
			txt.innerHTML="&nbsp;";
			var ican=document.createElement("input");
			ican.type="button";
			ican.id="promptcancel";
			ican.value="Cancel";
			ican.onclick=function(){promptCancel(pCani);}
			tblCell.appendChild(ican);
			tblCell.appendChild(txt);
			tblCell.appendChild(document.createElement("br"));
			tblCell.appendChild(document.createElement("br"));

			var pd = document.createElement("div");
			pd.id="promptdiv";
			pd.className="promptdiv";
			pd.style.top="0";
			pd.style.top="0";
			if (sDefault!="") 
				pan.value = sDefault;

			var qCrd = getWindowSize();
			pd.style.height = qCrd.height;//scrollHeight;// theHeight;
			pd.style.width=qCrd.width;//scrollWidth;// theWidth;
			pdT.style.display = "inline";
			pd.style.display="inline";
			document.body.appendChild(pdT);
			document.body.appendChild(pd);
			if (pT==null) {
				var qx = autoCenter(pdT.clientHeight, pdT.clientWidth);
				pdT.style.top = qx.top + iTopOffset;
				pdT.style.left = qx.left + iLeftOffset;
			}

			
			pan = ge('promptanswer');
			if (pan!=null) {
				pan.focus();
				pan.value = pan.value;
				if (sDefault!="" && bSelectDefault) 
					pan.select();
			}

		}
		function promptKeystroke(evt, pOK, pCan)
		{
			var evt = window.event;
			if (evt.keyCode == 13 || evt.keyCode == 9 ) { promptOK(pOK); return ; }
			if (evt.keyCode == 27 ) { promptCancel(pCan); return ; }
		}

		function promptCancel(pF){

			var d1=ge('prompttable');
			if (d1!=null) d1.parentNode.removeChild(d1);
			d1=ge('promptdiv');
			if (d1!=null) d1.parentNode.removeChild(d1);

			if (pF!=null)	pF();
 }
function promptOK(pF){
	var pa = ge('promptanswer');
	var s = (pa == null ? 'OK' : pa.value);
	var d1=ge('prompttable');
	if (d1!=null) d1.parentNode.removeChild(d1);
	d1=ge('promptdiv');
	if (d1!=null) d1.parentNode.removeChild(d1);
	if (pF!=null) pF(s);
 } 

// 
// promptuser functions end
// buttontextarea functions start
function ToggleCancelButton( sID,btxtArea,sRchTxt)
{ 
var sButtonId = sID+'_ToggleButton'; var sCancelButtonId = sID+'_CancelButton';
var sTextId='bta_'+sID;
var sROId = 'btaro_'+sID;
var btn = ge(sButtonId);
var btnCancel = ge(sCancelButtonId);
var txt = ge(sTextId);
var txta = ge(sROId);
 
if (btnCancel.style.display=="inline"){ 
 btnCancel.style.display="none";
 btn.value = "Edit";
 txt.style.display="none";
 txta.style.display="inline-block"; 
 // get the innerHTML from the ro div and putdata
 var sT = txta.innerHTML;
  if (sRchTxt=="true") {
 //var oEditor = FCKeditorAPI.GetInstance(btxtArea) ;
 var oEditor = CKEDITOR.instances[btxtArea];
  var sText = oEditor.setData(sT);
 }
 else
 {
 var d = ge(btxtArea); // 'btaro_' + sID);
 if (sT==null || sT == '') sT = '&nbsp;';
 d.innerHTML=sT;
 }
 
 }
}
function ToggleBTAButton( sID,sTABtn,sTypToUpdOnEnt,sIDToUpdOnEnt,sFldToUpdOnEnt,sRchTxt)
{
var sButtonId = sID+'_ToggleButton'; var sCancelButtonId = sID+'_CancelButton';
var sTextId='bta_'+sID;
var sROId = 'btaro_'+sID;
var btn = ge(sButtonId);
var btnCancel = ge(sCancelButtonId);
var txt = ge(sTextId);
var txta = ge(sROId);
var sAction="OFF";
if (btn.value.toUpperCase()=="SAVE")
 sAction="ON";

if (sAction=='OFF')	{
 btnCancel.style.display="inline"; 
 var offset=gep(sButtonId);
 btn.value='Save';
 var xpb = gep(sButtonId);
 var xpt = gep(sTextId);
 txt.style.display="inline-block";
 txta.style.display="none"; 
 } 
else 
 {
 var ta = ge(sTABtn);
 var sText = "";
 if (sRchTxt=="true") { 
 //var oEditor = FCKeditorAPI.GetInstance(sTABtn) ;
  var oEditor = CKEDITOR.instances[sTABtn];// CKeditorAPI.GetInstance(sTABtn) ;
 sText = oEditor.getData();} else { sText = ge(sTABtn).value; }
 try {
 var obj = new sforce.SObject(sTypToUpdOnEnt);
 obj.Id = sIDToUpdOnEnt;
 obj[sFldToUpdOnEnt]= (sText == '' ? null : sText) ;
 var result = sforce.connection.update([obj]);
 if (result[0].getBoolean("success")) {
 say( sFldToUpdOnEnt + " for " + sTypToUpdOnEnt + " id " + result[0].id + " updated");
 
 btnCancel.style.display="none";
 btn.value = "Edit";
 txt.style.display="none";
 txta.style.display="inline-block"; 
 
 if (sText==null || sText == '')
 sText = '&nbsp;';
 
 txta.innerHTML = sText;

 } else { alert("failed to update " + sFldToUpdOnEnt + " for " + sTypToUpdOnEnt + " : " + result[0]);
}

 } catch (err) { alert("Error updating " + sFldToUpdOnEnt + " for " + sTypToUpdOnEnt + " : " + err);
}
}
return false;
}

function fSetBTAreaText(sId, sFldToUpdOnEnt,sTypToUpdOnEnt, sIDToUpdOnEnt ) {
 var sN="error";
 var d = ge('btaro_' + sId);
 {
 try { 
 var result = sforce.connection.query("Select o." + sFldToUpdOnEnt + " from " + sTypToUpdOnEnt + " o where o.Id = '" + sIDToUpdOnEnt + "'");
 records = result.getArray("records"); 
 if (records!=null && records.length==1)
 sN=records[0].get(sFldToUpdOnEnt);// Note__c
 } 
 catch (err) { alert("Error retrieving {!ObjectFieldToUpdateUponEnter} for {!ObjectTypeToUpdateUponEnter} " + err); }
 } 
 
 say("setting ta text to [" + sN + "]"); 
 if (sN==null || sN == '')
 sN = '&nbsp;';
 d.innerHTML = sN;
 }
// END buttontextarea functions 

function aTableRecurseDottedName(rec, sName) { /* used by autotable */ var x = 'recurse error';try {x = rec; var vs = sName.split("."); for (var iC=0;iC < vs.length;iC++) x = x[vs[iC]]; if (x==null) x=''; return x; } catch (err) { x="atable recurse error"; } }

function addCellText(tblCell, s) {var txtq = document.createElement("text"); txtq.innerHTML=s; tblCell.appendChild(txtq);}

function GatherDocUploadContactString(s) {
 var sRc = "";
 var elem= ge(s);
 if (elem!=null && elem.firstChild!=null) {
 elem = elem.firstChild;
 while (elem!=null && elem.tagName!="TBODY")
 elem = elem.nextSibling;
 if (elem!=null) {
 elem=elem.firstChild;
 while (elem!=null ) { 
 if (elem.tagName=="TR"){
 var sRcAdd = "";
 var bFirst = true;
 var elD = elem.firstChild;
 while (elD!=null ) {
 if (elD.tagName=="TD") {
 if (bFirst)
 {
 
 var elA = elD.firstChild;
 while (elA!=null && elA.tagName!="A")
 elA = elA.nextSibling;
 if (elA!=null) {
 var sR = elA.href;
 var sR2 = sR.split("/");
 if (sR2!=null && sR2.length>0)
 sRcAdd+=sR2[sR2.length-1] + ":";
 }
 bFirst = false;
 }
 else { // tracking#
 var elA = elD.firstChild;
 while (elA!=null && elA.tagName!="INPUT")
 elA = elA.nextSibling;
 if (elA!=null) {
 var sR = elA.value;
 if (sR!=null && sR.length>0)
 sRcAdd+=sR;
								else
									sRcAdd+="<blank>";
 } 
 } 
 }
 elD = elD.nextSibling;
 }
 }
 if (sRcAdd!="") sRc+=sRcAdd+"##";
 elem = elem.nextSibling;
 }
 } 
 } 
 return sRc;
}
 

function closeDocAdd(sId)
{
var elb=document.getElementById('docadddivbg');
if (elb != null) elb.parentNode.removeChild(elb);
elb=document.getElementById('docbtadd_'+sId);
elb.style.display="inline";
var eld = document.getElementById('dldiv_'+sId);
eld.style.display="none";
elb = document.getElementById('doclistupl_'+sId);
elb.style.display="none";
var tbl = document.getElementById('taddcttbl_'+sId);
if (tbl.firstChild!=null){
 var tC = tbl.firstChild;
 tC.parentNode.removeChild(tC);
 } 
}

function NotifyOfDocListUpdate(sId,sFileName)
{
//var sq = whoami;
say('parent received update notification of child [' + sId + '] for file [' + sFileName + ']');
if (docListStartupTracker[sId]!=null)
 {
 var xc = docListStartupTracker[sId];
 xc.Status = 'reset';
 xc.FileName = sFileName;
 }
}

function NotifyOfDocListFileUploadWindowStartup(sId,sAssociationId,pSetter,sSecondaryAssociationId)	{
// var sq = whoami;

 if (docListStartupTracker[sId]==null) {
 var acfg = { pFuncSetter : pSetter, DocListId : sId, PrimaryAssocationId:sAssociationId , Status : 'init', FileName: '' };
 docListStartupTracker[sId]= acfg;
 }
 else
 {
 var xc = docListStartupTracker[sId];
 var sC = GatherDocUploadContactString('taddcttbl_'+sId);
 if (docListAddNewFuncTracker!=null && docListAddNewFuncTracker[sId]!=null)
 {
 var sT='?';
 if (docListLinkTypeTracker!=null && docListLinkTypeTracker[sId]!=null)
 sT=docListLinkTypeTracker[sId];
 var pX = docListAddNewFuncTracker[sId];
 pX(xc.FileName,sT, xc.PrimaryAssocationId,sC,sSecondaryAssociationId);
 }
 }
}
function createAutoTableFromSOQLRecords(atCfg,records,sFldConfig, tableCompleteFunc,sDefColHeaderClass,pHeaderFunc,sDefCellClass,pCellFunc,pRowFunc,URLLinkPrefix,pFuncRedraw,pFuncTableStart,pFuncDelete){
 /* used by autotable */
 var fldCfg = new Array(); var sCfg = (sFldConfig+"#").split("#"); var iTF = 0;
 
 var s = JSON.stringify(records);
	say("");say("");say("atable record data (" + atCfg.AutoTableId + "):");say("");say("");say(s);say("");say("");
 
 for (var iFc=0;iFc < sCfg.length;iFc++) {
 var cDetail = (sCfg[iFc]+':::::').split(":");
 var cfg = { ColName : cDetail[0], ColHeaderClass : cDetail[1], ColSource : cDetail[2], CellClass : cDetail[3], URLSource : cDetail[4], CellFormat : cDetail[5] } 
 if (cfg.ColHeaderClass ==null || cfg.ColHeaderClass =='') cfg.ColHeaderClass=sDefColHeaderClass;
 if (cfg.CellClass==null || cfg.CellClass=='') cfg.CellClass=sDefCellClass;
 if (cfg.ColName != '' ||cfg.ColSource != '') fldCfg[iTF++]=cfg;
 }
 var tbl = document.createElement("table"); var tblRow=tbl.insertRow(tbl.rows.length);
 if (pFuncTableStart!=null)	pFuncTableStart(atCfg,tbl,fldCfg,records);
 if (atCfg.ShowColumnHeaders==true) {
 for (var iC=0;iC < fldCfg.length;iC++) {
 var tblCell = tblRow.insertCell(tblRow.cells.length);
		tblCell.vAlign="bottom";
		var fcfgx = fldCfg[iC];
 if ( fcfgx.ColHeaderClass!='') tblCell.className = fcfgx.ColHeaderClass;
 tblCell.innerHTML = fcfgx.ColName;
		if (fcfgx.CellFormat.indexOf("DATE")!=-1) 
			tblCell.align="center";
 if (pHeaderFunc!=null) pHeaderFunc(atCfg,tblCell,fldCfg,iC);
 }
 }
if (atCfg.IncludeDeleteOption==true && atCfg.ShowColumnHeaders==true) { tblCell = tblRow.insertCell(tblRow.cells.length); tblCell.className = sDefColHeaderClass; tblCell.innerHTML = "Del?"; }
if (atCfg.IncludeDeleteOption==true)
 {
 var cfg = { ColName : "Del?", ColHeaderClass : sDefColHeaderClass , ColSource : '', CellClass : sDefCellClass, URLSource : '' } 
 fldCfg[iTF++] = cfg;
 }
 
 for (var iR=0; iR < records.length; iR++) { // populate rows
 var tblRow=tbl.insertRow(tbl.rows.length);
 var rec = records[iR];
 var iC=0;
 for (iC=0;iC < fldCfg.length;iC++) {
 
 if (fldCfg[iC].ColName=='Del?' && atCfg.IncludeDeleteOption)
 continue;
 var tblCell = tblRow.insertCell(tblRow.cells.length);
 if ( fldCfg[iC].CellClass!='') tblCell.className = fldCfg[iC].CellClass;
 if (fldCfg[iC].ColSource!=null && fldCfg[iC].ColSource!='') {
 var sCSrc=fldCfg[iC].ColSource;
 if (fldCfg[iC].URLSource!=null && fldCfg[iC].URLSource!='') {
 var lnk = document.createElement("a");
    lnk.target="_top";
    var sLH = (fldCfg[iC].URLSource.indexOf(".")==-1 ? rec[fldCfg[iC].URLSource] : aTableRecurseDottedName(rec,fldCfg[iC].URLSource));
    if (sLH!=null && sLH!='') 
    	lnk.href = URLLinkPrefix + sLH;
    var sLS= (sCSrc.indexOf(".")==-1 ? 
 autoTableFormatPerConfig(rec[sCSrc],fldCfg[iC].CellFormat)
 : 
 autoTableFormatPerConfig(aTableRecurseDottedName(rec,sCSrc),fldCfg[iC].CellFormat)
 );

 if ((sLS==null || sLS=='') && (sLH!=null && sLH!='')) sLS = "blank";
 lnk.innerHTML = sLS;
 tblCell.appendChild(lnk);
 }
 else
 tblCell.innerHTML = (sCSrc.indexOf(".")==-1 ? 
 autoTableFormatPerConfig(rec[sCSrc] ,fldCfg[iC].CellFormat)
 : 
 autoTableFormatPerConfig(aTableRecurseDottedName(rec,sCSrc),fldCfg[iC].CellFormat));
 }
 
  tblCell.align="left";
if (fldCfg[iC].CellFormat!=null && fldCfg[iC].CellFormat!='') { 
 var sCfg=fldCfg[iC].CellFormat.toUpperCase();
 if (sCfg.indexOf("SHORTDATE")!=-1)
 tblCell.align="center";
			 
 if (sCfg.indexOf("CURRENCY")!=-1 || sCfg.indexOf("PERCENT")!=-1 )
 tblCell.align="right";
 }
 if (pCellFunc!=null) pCellFunc(atCfg,tblCell,fldCfg,iC,rec);
 }
 if (atCfg.IncludeDeleteOption==true) { 
 
 var tblCell2 = tblRow.insertCell(tblRow.cells.length); 
 var icx = iC-1; 
 var btn = document.createElement("input"); btn.type="button"; btn.value="x "; btn.className="flatbutton"; btn.alt=""+iR;
 btn.onclick = function() { funcDeleteAutoTableRow(this,atCfg,fldCfg,records,pFuncRedraw,pFuncDelete);}
 tblCell2.appendChild(btn);
 }
 
 if (pRowFunc!=null) pRowFunc(atCfg,fldCfg,tblRow, rec);
 }
	
 if (tableCompleteFunc!=null) tableCompleteFunc(atCfg,tbl,fldCfg,records);
 return tbl;
} 



function autoTableFormatPerConfig(val, sFormat)
{
//alert("here with " + val);
 var sRc = val;
if (val==null )  return "";

var sF = trim(sFormat);
sF = sF.toUpperCase();


 if (sF.indexOf("SHORTDATE")!=-1) { 
 try {
	
 if (val == "") return "";
 var bIncrMonth=true;
 var d=1;
 if (sF.indexOf("FROMSTRING0")!=-1) // 2010-01-26
 {
// var dP=val.split("-");
// d=new Date(dP[0],dP[1],dP[2]);
 d=parseDate(val);//new Date(dP[0],dP[1],dP[2]);
// bIncrMonth=false;
 bIncrMonth=true;
 }
 else
				if (sF.indexOf("FROMSTRING2")!=-1) // 2010-03-23T16:03:46.000Z 
				{
					//var dP=val.split("-");
					 
					 if (val!=null && val!='')
						{
							var sV = val.substring(0,4) + '-' + val.substring(5,7) + '-' + val.substring(8,10);
							d=parseDate(sV);
							bIncrMonth=true;
					} 
					 
				}
				else
 if (sF.indexOf("FROMSTRING1")!=-1) {
 d=parseDate(val);
 bIncrMonth=true;
 }
 else
 d = new Date(val);
 var curr_date = d.getDate();
 var curr_month = d.getMonth();
 if (bIncrMonth) curr_month++;
 var curr_year = d.getFullYear();
 sRc= (curr_month < 10 ? "0" : "") + curr_month + "/" + (curr_date < 10? "0" :"") + curr_date + "/" + curr_year;
 } catch (err) { sRc="err!"+val+" "+err;
 }
 
 }
 if (sF.indexOf("PERCENT")!=-1) { 
 var nf = new NumberFormat(sRc);
 nf.setSeparators(false);nf.setPlaces(2);
 sRc=nf.toFormatted().replace(".00","")+"%"; 
 }


 if (sF.indexOf("CURRENCY")!=-1) { // using NumberFormat from http://www.mredkj.com/javascript/numberFormatPage2.htmlp
 var nf = new NumberFormat(sRc);

 //nf.setPlaces(sF.indexOf("ONEPOINT")!=-1?1:0); 
 nf.setPlaces(sF.indexOf("CENTS")!=-1?2:
			  (sF.indexOf("ONEPOINT")!=-1?1:0)
			  ); 
 nf.setSeparators(sF.indexOf("NOCOMMAS")!=-1?false:true);
 nf.setCurrency(sF.indexOf("DOLLARSIGN")!=-1?true:false);
 sRc=nf.toFormatted();
 }
 return sRc;
}

function funcDeleteAutoTableRow(th,atCfg,fldCfgs,records,pFuncRedraw,pFuncExternalDelete)
 {
//alert(atCfg.DeleteQuestion);
 var iRec = parseInt(th.alt);
 var rec = records[iRec];
	var sName = "";
	 if (atCfg.NameField!=null && atCfg.NameField!='') {
		 var iFn = 0; 
		 try { iFn = parseInt(atCfg.NameField); 
		 var fNameCfg = fldCfgs[iFn]; 
		 sName = "'" + aTableRecurseDottedName(rec,fNameCfg.ColSource) + "'";

		 } 
		 catch (err) { alert("error determining name to delete row:" + err); iFn=0; sName = "";};
	 }
 var sM = (atCfg.DeleteQuestion != null &&  atCfg.DeleteQuestion != ''  ? atCfg.DeleteQuestion : "Delete " + sName + "?");
 if (confirm(sM)) {
			var delResult = null;
			try {
				
			
			if (pFuncExternalDelete!=null) 
				delResult=pFuncExternalDelete(atCfg,fldCfgs,rec); 
			else 
				delResult=sforce.connection.deleteIds([rec.Id]);
 if (delResult[0].getBoolean("success")) {
 say("id " + delResult[0].id + " deleted");
 if (pFuncRedraw!=null) pFuncRedraw();
 } else {
 alert("failed to delete " + delResult[0]);
 }
			}
			catch (err) {
				alert("Error trying to delete table record: " + err);

			}
			
 }
 }
 
function cluSearchFunc(cluID,sFilterText,iRowLimit,bAddNewOption/*,bIncludeClearOption*/,sSrcObj,sOutputFields,sFilterField,sOrderByField,sAdditionalWhereClause,
 sRequiredItems,bFilterRequiredItems,cluClickCB, funcQuery, defItem
) { 
	if (sFilterText.indexOf("\\")!=-1) {alert("Search expression cannot contain a backslash.");return;}
	if (sFilterText.indexOf("'")!=-1) {alert("Search expression cannot contain single quote mark.");return;}
	var iDefItem = 0;
	if (defItem!=null) {
		iDefItem=defItem;
	}
	/* used by combolookup */
 var state = { //state that you need when the callback is called 
 sourceObject : sSrcObj,
 cluID : cluID,
 qryText : sFilterText,
 defaultTagItem: iDefItem,
 columns : 1,
 id_field_index : 0,
 showIDFieldYN : 'NO',
 rowCount : 0,
 named_field_index : 1,
 rowLimit : iRowLimit,
 // includeClearOption : bIncludeClearOption,
 includeAddNewOption : bAddNewOption,
 outputFields : sOutputFields,
 startTime : new Date().getTime(),
 requiredItems : sRequiredItems,
 filterRequiredItems : bFilterRequiredItems, cluMenuClickCB : cluClickCB
 };
 var callback = { onSuccess: cluResultsCallback, onFailure: cluQueryFailed, source: state};
 var arFlds = (sOutputFields+',').split(","); var sFlds = "";
 for (var i=0;i < arFlds.length;i++) { if (sFlds!="" && arFlds[i]!="") sFlds+=", "; if (arFlds[i]!="") sFlds += arFlds[i]; }
 var sW=''; var sO=sFilterField; if(sOrderByField!='') sO=sOrderByField;
 if (sAdditionalWhereClause!='') 
 sW=sAdditionalWhereClause + ' and ' ;
 var soqlq = "Select o.Id, " + sFlds + " from " + sSrcObj + " o where " + sW + sFilterField + " like '%" + sFilterText + "%' order by " + sO;
 say("query:" + soqlq);
 if (funcQuery==null) 
	 sforce.connection.query(soqlq, callback);
	 else
		 cluResultsCallback(funcQuery(sFilterText),state);
 }

function cluQueryFailed(error, source) { alert('Error retrieving data for clu id(' + source.cluID + '):' + error); }
function cluResultsCallback(queryResult, source) {
 var iRout = 0;
 var arRows = new Array();
 if (source.includeAddNewOption == true) {
 var row = { "Id" : "-1000","RowNumber" : iRout,"DisplayText" : "Add new ..." }; 
 arRows[iRout++]=row;
 }
 if (source.requiredItems!=null && source.requiredItems!=''){
 var s = source.requiredItems+ "#";
 var s2 = s.split("#");
 var bPlacedDefaultTagItem=false;
 for (var ireq=0;ireq < s2.length; ireq++){
 if (s2[ireq]!= '') {
 var sKV = s2[ireq].split(":");
 var row = { "Id" : sKV[0],"RowNumber" : iRout,"DisplayText" : sKV[1]};
 if (!source.filterRequiredItems || sKV[1].toUpperCase().indexOf(source.qryText.toUpperCase() )!=-1
 || sKV[1].toUpperCase().indexOf("ADD NEW")!=-1
 )
 { if (!bPlacedDefaultTagItem)
					{
						if (source.defaultTagItem== -1) {
							source.defaultTagItem=iRout; 
						}
					}
					bPlacedDefaultTagItem=true; 
 arRows[iRout++]=row; 
 }
 }
 }
 }
 
 if ((queryResult.length!=null && queryResult.length!=0) || queryResult.size > 0 ) {
		 
 var output = ""; bPlacedDefaultTagItem=false;

	 var records = null;
	 if (queryResult.length != null) 
		 records = queryResult;
	 else
		 records =	queryResult.getArray('records'); 


 var arFldNames = (source.outputFields+",").split(","); 
 
 var iRin = 0;
 for ( ;iRin < records.length; iRin++) {
 var rec = records[iRin]; var sData="";
 for (var iCa=0;iCa < arFldNames.length;iCa++) {
 if (arFldNames[iCa]!='') {
		var s1 = aTableRecurseDottedName(rec, arFldNames[iCa]);
 if (sData!='') sData += " "; sData += s1;
 }}
 var row = {"Id" : rec.Id, "RowNumber" : iRout, "DisplayText" : sData}; 
 if (!bPlacedDefaultTagItem) {
		 if (source.defaultTagItem== -1) 
			 source.defaultTagItem=iRout;
	 }
 bPlacedDefaultTagItem=true;
 arRows[iRout++]=row;
 }
 }

	if (
		((source.defaultTagItem+1) > iRout)
		||
		(source.defaultTagItem==-1 && iRout > 0)
		) 
		source.defaultTagItem=0;

 var ld = {config : source,rows: arRows };
 ld.config.rowCount=iRout; 
 receiveCLUObjectData (ld);
	ge(source.cluID+'_cluSearchText').focus();
											
}
 
function receiveCLUObjectData(lData) {
 var sR = 'rows:' + lData.rows.length ; 
 
 var sComboName = lData.config.cluID+"_cluSearchText";
 var txtBox= ge(sComboName );
 var offsetLeft=txtBox.offsetLeft;
 var offsetTop = txtBox.offsetTop+ txtBox.offsetHeight;
 var menu= ge(lData.config.cluID + "_list_div");
 
 menu.style.left= "" + offsetLeft +"px";
 menu.style.top= "" + offsetTop +"px";
 
 var tbl = ge(lData.config.cluID+"_list_table");
 var tblRow, tblCell, cellText;
 
 var lVisibleRows=lData.config.rowCount;

 var sShowConfig = lData.config.showIDFieldYN;
 sShowConfig=sShowConfig.toUpperCase();

 var lVisibleColumns=lData.config.columns;
 var iRows = tbl.rows.length;
 var iIDFieldIndex = lData.config.id_field_index;
 var iNamedFieldIndex = lData.config.named_field_index;


 var elemSelectedRow=ge(lData.config.cluID+"_selected_row");
 var defaultTagItem=""+lData.config.defaultTagItem; say('setting default item to ' + defaultTagItem);

 elemSelectedRow.value=defaultTagItem;
 for (i=0;i < iRows;i++)
 tbl.deleteRow(0);

 var iFirstVisibleCol=-1;
 
 for (i=0;i < lVisibleRows;i++)
 {
 tblRow=tbl.insertRow(tbl.rows.length);
 var q = 0;
 {
 {

 tblCell = tblRow.insertCell(tblRow.cells.length);
 tblCell.onclick = function() {processLookupComboMouseClick(this,lData.config.cluID,lData.config.cluMenuClickCB)} ;
 tblCell.onmouseover = function() {processLookupComboMouseOver(this,lData.config.cluID)} ;
 tblCell.onkeypress = function() {processLookupComboMenuKeyPress(this,lData.config.cluID)} ;
 tblCell.className = "comboLookupItemNormal";

 if (defaultTagItem!="" && ((""+i)==defaultTagItem)) 
 {
 elemSelectedRow.value=(""+i);
 tblCell.className= "comboLookupItemHighlighted";
 }

 {

 var elemID=document.createElement("input");
 elemID.setAttribute("type","hidden");
 var sID=lData.config.cluID + "_ID_r" + i;
 elemID.setAttribute("id",sID);
 var sID_val = "" + lData.rows[i].Id;
 elemID.setAttribute("value",sID_val);
 tblCell.appendChild(elemID);


 var elemVal=document.createElement("input");
 elemVal.setAttribute("type","hidden");
 sID=lData.config.cluID + "_VAL_r" + i;
 elemVal.setAttribute("id",sID);
 sID_val = "" + lData.rows[i].DisplayText;
 elemVal.setAttribute("value",sID_val);
 tblCell.appendChild(elemVal);
 var elemcheck = ge(sID);
 }
 q=1;
 var sHighlightColorFG="#2F4F4F";
 var sHighlightColorBG = "#D3D3D3";
 var sT = lData.rows[i].DisplayText;
 var sVal = lData.config.qryText;
 if (sT==null) 
 sT=""
 
 tblCell.appendChild(setupHighlightedText (sT,sVal, sHighlightColorFG, sHighlightColorBG ));
 }
 }
 }
 menu.style.visibility='visible';
 } 
function processLookupComboMouseClick(td,sCombo,pCallbackFunc){ pCallbackFunc(); }

function processLookupComboMouseOver(td,sCombo)
{
var elem = td;
var iRow = -1;
// walk to first <td> in the row
while (elem.previousSibling!=null)
 { 
 elem=elem.previousSibling; 
 }
if (elem!=null) { // found the first col in the row, now take it is first child that is hidden
 if (elem.firstChild!=null) 
 {
 elem = elem.firstChild;
 while (elem!=null && elem.type!="hidden" && elem.tagName!="INPUT") {
 elem = elem.nextSibling;
 }
 if (elem!=null) {
 var s = elem.id;
 var iLoc = s.indexOf("_ID_r");
 if (iLoc!=-1) 
 {
 //var lCurr = 0 + eval(s.indexOf("_ID_r")+5);
 var lCurr = eval(s.substring(iLoc+5)); 
 var tbl = ge(sCombo + "_list_table");
 var elemCurrRow = ge(sCombo + "_selected_row");
 var lRows = 0;
 lRows = 0+tbl.rows.length;
 elemCurrRow.value = "" + lCurr;
 {
 {
 for (var iR=0;iR < lRows;iR++) {
 for (var iC=0;iC < tbl.rows[0].cells.length;iC++) 
 {
 if (iR==lCurr )//&& (lCurr < lRows-1)) 
 tbl.rows[iR].cells[iC].className = "comboLookupItemHighlighted";
 else
 tbl.rows[iR].cells[iC].className = "comboLookupItemNormal";
 }
 }
 }
 }
 }
 }
 }
}
}
 
function processLookupComboMenuKeyPress(td,sCombo)
{
 var evt = window.event;
 if (evt.keyCode == 27) // escape - hide menu
 {
 var elem = ge(sCombo+"_list_div");
 if (elem!=null) 
 elem.style.visibility="hidden";
 }

}

function setupHighlightedText(sText, sHighlight, sColorFG, sColorBG)
{
 var s, sH;
 var txtNode;
 var txt;
 var iChecks
 iChecks=20;

 var iIdx=0;
 s =sText;//.toUpperCase();
 sH = sHighlight;//.toUpperCase();
 txtNode = document.createTextNode("");
 var frag = document.createDocumentFragment();
 frag.appendChild(txtNode);
 while ( iChecks > 0 && ( s.toUpperCase().indexOf(sH.toUpperCase(), iIdx) != -1)) 
 {
 // search thru sText, adding text node and highlighted span
 var iIdx2=s.toUpperCase().indexOf(sH.toUpperCase(), iIdx);
 txt = s.substring(iIdx,iIdx2);
 var sMatch = s.substring(iIdx2,iIdx2+sH.length);
 iIdx=iIdx2;
 s = s.substring(iIdx + sH.length);
 txtNode = document.createTextNode(txt);
 var myem = document.createElement("SPAN");
 myem.style.color=sColorFG;//"#D3D3D3";//="cellInverted";//fontWeight="bold";
 myem.style.backgroundColor=sColorBG;//"#2F4F4F";//="cellInverted";//fontWeight="bold";
 var txtMatch = document.createTextNode(sMatch);
 myem.appendChild(txtMatch);
 frag.appendChild(txtNode);
 frag.appendChild(myem);
 iChecks=iChecks-1;
 iIdx=0;
 }

 if (iIdx < s.length)
 {
 txt=s.substring(iIdx,s.length);
 txtNode = document.createTextNode(txt);
 frag.appendChild(txtNode);
 }
 return frag;
}

function checkIfCLUKeyShouldBeProcessed(keyCode,sComboName,sVal, lMinKeystrokes, list_div_id, search_text_id,status_id, bIsDate) {
 say('check->val[' + sVal + '] combo[' + sComboName + '] minkeystrokes' + lMinKeystrokes);
 if ( keyCode == 27 ) { 
 var menu = ge(list_div_id);
 menu.style.visibility="hidden"; 
 var btn = ge(sComboName+'_ToggleButton');
 var txt = ge(search_text_id);
 txt.value = btn.value;
 ToggleCLUButton('ON',sComboName+'_ToggleButton',search_text_id,status_id, bIsDate);
 return false; 
 } 
 if (keyCode == 16 || keyCode == 9 ) return false;
 if (keyCode == 35 || keyCode == 36 || keyCode == 37 || keyCode == 39 ) return false; // home & end, right and left arrows 
 return true; 
}
 
function processNavigation(keyCode, sComboName)
{
 var txtBox = ge(sComboName );
 var tbl = ge(sComboName + '_list_table');
 var elemCurrRow = ge(sComboName + '_selected_row');
 var lRows = 0;
 lRows = 0+tbl.rows.length;
 var lCurr = -1;
 if (elemCurrRow.value!="") {
 lCurr = eval(elemCurrRow.value);
 }
 if (keyCode == 40 ) {
 if (lCurr < (lRows-1)) {
 elemCurrRow.value = "" + (lCurr+1);
 for (var iR=0;iR < lRows;iR++) {
 for (var iC=0;iC < tbl.rows[0].cells.length;iC++) {
 var qx = 0;
 if (iR==lCurr && (lCurr < lRows-1)) 
 tbl.rows[iR].cells[iC].className = "comboLookupItemNormal"; 
 if (iR==lCurr+1) 
 tbl.rows[iR].cells[iC].className = "comboLookupItemHighlighted";
 }
 }
 }
 }
 
 if (keyCode == 38 && elemCurrRow.value!=""/* up */) {
 if (lCurr > 0) {
 if (lCurr > 0) 
 elemCurrRow.value = "" + (lCurr-1);
 for (var iR=0;iR < lRows;iR++) {
 for (var iC=0;iC < tbl.rows[0].cells.length;iC++) {
 if (iR==lCurr && (lCurr > 0)) tbl.rows[iR].cells[iC].className = "comboLookupItemNormal";
 if (iR==lCurr-1) tbl.rows[iR].cells[iC].className = "comboLookupItemHighlighted";
 }
 }
 }
 }
} 
 
function noPageRefreshOnEnterKey(evt) { evt = (evt) ? evt : ((window.event) ? event : null); return !(evt.keyCode==13); }
function getValueFromEvent(evt) { evt = (evt) ? evt : ((window.event) ? event : null); if (evt) var elem = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null); return elem.value; }
function trim(s)
{
	var l=0; var r=s.length -1;
	while(l < s.length && s[l] == ' ')
	{	l++; }
	while(r > l && s[r] == ' ')
	{	r-=1;	}
	return s.substring(l, r+1);
}


