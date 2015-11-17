/***
 *
 * SkyEditor2 SearchTemplateJs
 * All CopyRight http://www.terrasky.co.jp
 *
 ***/
 
/* Load時にInputにFocusさせない。 */
beenFocused = true;
var messages = new Object();
messages["DUPLICATE_VALUE"] = "エラー：名称が重複しています。";
messages["REQUIRED_FIELD_MISSING"] = "エラー：名称が未入力です。";
messages["NAMEBLANK"] = "エラー：名称が未入力です。";
messages["UNDOCUMENTED"] = "エラー：検索条件が未登録です。";
messages["DELETEERROR"] = "エラー：削除に失敗しました。";
messages["SAVESUCCESS"] = "保存されました";
messages["CONFIRMMESSAGE"] = "検索条件を削除します。よろしいですか？";
messages["UPDATEMESSAGE"] = "検索条件更新します。よろしいですか？";
messages["CONDITIONSEARCHERROR"] = "検索条件の取得に失敗しました。";
messages["INVALIDSESSION"] = "ページを再読込してください。";
messages["ERRORMESSAG"] = "エラーが発生しました。";

messages["NOTSELECTERROR"] = "編集対象項目が選択されていません。";
messages["VALUEENPTYCONVERTCONFIRM"] = "値が未入力です。値を削除しますか？";


var defaultDateCondition = "";
var defaultsearchItemCondition = "";

jQuery(function(){
	
	if(jQuery('#saveDialog').length != 0){
	
		defaultDateCondition = getDateFieldsValue().join(',');
		defaultsearchItemCondition = getSearchItemsValue().join(',');
		
		jQuery('#saveDialog').dialog({
			bgiframe: true,
			modal: true,
			width: 320,
			autoOpen: false,
			close: function(){
				jQuery(".mText").text("");
			}
		});
	
		jQuery('#readDialog').dialog({
			bgiframe: true,
			modal: true,
			width: 320,
			autoOpen: false,
			close: function(){
				jQuery(".mText").text("");
			}
		});

		jQuery('#saveBtn').click(function(){
			jQuery('#saveDialog').dialog('open');
		});
		
		jQuery('#closeSaveDialog').click(function(){
			jQuery('#saveDialog').dialog( "close" );
		});
		
		jQuery('#closeReadDialog').click(function(){
			jQuery('#readDialog').dialog( "close" );
		});
		
		/**
		 *  検索条件読込ボタン押下処理 
		 **/
		jQuery('#readBtn').click(function(){
			var records = conditionNameSearchForSFDC();
			if(records != null){
				jQuery('#searchConditionList > option').remove();
				jQuery.each( records, function( i, obj )  {
					jQuery( '<option>', { selected: i == 0, val: records[i].Id, text: records[i].SearchConditionName__c } )
					.appendTo( '#searchConditionList' );
				} );
			}
			jQuery('#readDialog').dialog('open');
		});
		
		/**
		 *  検索条件保存 
		 **/
		jQuery('#conditionSave').click(function(){
			
			var inputName = jQuery('#conditionName').val();
			if(inputName == '') {
				jQuery(".mText").text(messages["REQUIRED_FIELD_MISSING"]);
				return; 
			}
			
			/** 期間指定項目 */
			var dateFieldsArr = getDateFieldsValue();
			
			/** 検索条件項目 */
			var strArray = getSearchItemsValue();
			
			var pageId = "";
			var pages = conditionNameSearchForSFDC();
			
			if(pages != null && pages != ''){
				for(var i = 0; i < pages.length; i++){
					if(pages[i].SearchConditionName__c == inputName){
						pageId = pages[i].Id;
					}
				}
			}
			
			sforce.connection.defaultNamespace = "SkyEditor2";
			sforce.connection.sessionId = SkyEditor.SessionId;
			var searchCondition = new sforce.SObject("SearchCondition__c");
			searchCondition.PageName__c = SkyEditor.CurrentPageName;
			searchCondition.SearchConditionName__c = inputName;
			searchCondition.SearchFieldFromTo__c = dateFieldsArr.join(',');
			searchCondition.Condition__c = strArray.join(',');
			
			var result = '';
			
			try{
				if(pageId != ""){
					var flg = confirm(messages["UPDATEMESSAGE"]);
					if(flg){
						searchCondition.Id = pageId;
						result = sforce.connection.update([searchCondition]);
					}
				}else{
				
					result = sforce.connection.create([searchCondition]);
				}
				if(result != ''){
					if (result[0].getBoolean("success")) {
						jQuery(".mText").text(messages["SAVESUCCESS"]);
					} else {
						jQuery(".mText").text(messages[result[0].errors["statusCode"]]);
					}
				}
			}catch(e){
				if (e.faultcode=='sf:INVALID_SESSION_ID') {
					jQuery(".mText").text(messages["INVALIDSESSION"]);
				}else{
					jQuery(".mText").text(messages["ERRORMESSAG"] + ":[" + e.faultcode + "]");
				}
			}


		});
		
		/*** 検索条件読込処理 ***/
		jQuery('#setCondition').click(function(){
			
			/** フォーム初期化処理 **/
			multiSelectInitializer();
			setForm(defaultDateCondition);
			setForm(defaultsearchItemCondition);
			
			var selectcond = jQuery("#searchConditionList").val();
			sforce.connection.defaultNamespace = "SkyEditor2";
			sforce.connection.sessionId = SkyEditor.SessionId;
			try{
				if(selectcond != null && selectcond != ""){
					var result = sforce.connection.query("SELECT SearchFieldFromTo__c, Condition__c FROM SearchCondition__c WHERE Id='" + selectcond + "'");
					var searchFieldFromTo = result.getArray("records")[0].SearchFieldFromTo__c;
					var condition = result.getArray("records")[0].Condition__c;
					setForm(searchFieldFromTo);
					setForm(condition);
				}else{
					alert(messages["UNDOCUMENTED"]);
				}
				jQuery('#readDialog').dialog('close');
			}catch(e){
				if (e.faultcode=='sf:INVALID_SESSION_ID') {
					jQuery(".mText").text(messages["INVALIDSESSION"]);
				} else {
					jQuery(".mText").text(messages["CONDITIONSEARCHERROR"] + ':[' + e.faultcode + ']');
				}
			}
		});
		
		/*** 検索条件削除処理 ***/
		jQuery('#deleteCondition').click(function(){
			var flg=confirm(messages["CONFIRMMESSAGE"]);
			if(flg){
				var selectcond = jQuery("#searchConditionList").val();
				sforce.connection.sessionId = SkyEditor.SessionId;
				if(selectcond != null && selectcond != ""){
					try{
						sforce.connection.defaultNamespace = "SkyEditor2";
						var delResult = sforce.connection.deleteIds([selectcond]);
						if (delResult[0].getBoolean("success")) {
							jQuery('#searchConditionList > option').each(function(){
								if(jQuery(this).val() == selectcond){
									jQuery(this).remove();
								}
							})
						} else {
							jQuery(".mText").text(messages["DELETEERROR"]);
						}
					}catch(e){
						if (e.faultcode=='sf:INVALID_SESSION_ID') {
							jQuery(".mText").text(messages["INVALIDSESSION"]);
						} else {
							jQuery(".mText").text(messages["CONDITIONSEARCHERROR"] + ':[' + e.faultcode + ']');
						}
					}
				}else{
					alert(messages["UNDOCUMENTED"]);
				}
			}
		});
	}
	
	jQuery('.labelCol').css({'width':'auto'});
	jQuery('.dataCol').css({'width':'auto'});
	jQuery('label').css({'font-weight':'bold'});

});


/**
 *  Salesforceへ検索条件を検索に行く
 **/
function conditionNameSearchForSFDC(){
	sforce.connection.defaultNamespace = "SkyEditor2";
	sforce.connection.sessionId = SkyEditor.SessionId;
	try{
		var result = sforce.connection.query("SELECT Id, SearchConditionName__c FROM SearchCondition__c WHERE PageName__c='" + SkyEditor.CurrentPageName + "' AND OwnerId='" + SkyEditor.UserId + "' ORDER BY LastModifiedDate DESC");
		var records = result.getArray("records");
		
		return records;
	}catch(e){
		if (e.faultcode=='sf:INVALID_SESSION_ID') {
			jQuery(".mText").text(messages["INVALIDSESSION"]);
		}else{
			jQuery(".mText").text(messages["ERRORMESSAG"] + ":[" + e.faultcode + "]");
		}
	}
	return
}

/** 複数選択リストの初期化処理 ***/
function multiSelectInitializer(){
	jQuery(".searchItemBox").each(function(){
		jQuery(this).children(":input[id*='dataField']").each(function(){
			if(jQuery(this).is(":input[type='select-multiple']")){
				var targetId = jQuery(this).attr('id').replace(/:/g, "\\:");
				jQuery("#" + targetId + "_selected option").each(function(){
					jQuery(this).attr("selected",true);
				});
				eval(decodeURIComponent(jQuery("#" + targetId + "_left_arrow").parent().attr('href')).substring(11));
			}
		});
	});
}

/** 検索フォームの期間指定項目の値を取得 ***/
function getDateFieldsValue(){
	var dateFieldsArr = []; 
	jQuery(".searchDateFieldItems").each(function(){
		var dateFieldsStr = '';
		dateFieldsStr += jQuery(this).attr("id") + "|";
		dateFieldsStr += jQuery(this).val();
		dateFieldsArr.push(dateFieldsStr);
	});
	return dateFieldsArr;
}

/** 検索フォームの検索項目の値を取得 ***/   
function getSearchItemsValue(){
	var strArray = [];
	var lookUpArr = [];
	var flg = false;
	jQuery(".searchItemBox").each(function(){
		
		/* 演算子をセット */
		var operatorStr = jQuery(this).children('.operatorSelect').attr("id") + "|" + jQuery(this).children('.operatorSelect').val();
		strArray.push(operatorStr);
		
		jQuery(this).find(":input[id*='dataField']").each(function(){
			var str = "";
			/* 複数選択があった場合の処理 */
			if(jQuery(this).is(":input[type='select-multiple']") && !jQuery(this).is(":input[id*='_selected']") && !jQuery(this).is(":input[id*='_unselected']")){
				str = jQuery(this).attr("id") + "|";
				var multipleValues = jQuery(this).val() || [];
				str += multipleValues.join(";");
			}else if(jQuery(this).is(":input[type='checkbox']")){
				str = jQuery(this).attr("id") + "|";
				str += jQuery(this).attr('checked');
			}else if(jQuery(this).is(":input[type='hidden']")){
				str = jQuery(this).attr("id") + "|";
				str += jQuery(this).val();   
			}else if(jQuery(this).is(":input[type='text']")){
				str = jQuery(this).attr("id") + "|";
				str += jQuery(this).val();
			} else {
				str = jQuery(this).attr("id") + "|";
				str += jQuery(this).val();
			}
			if(str != ""){
				strArray.push(str);
			} 
		});
	
	});
	
	return strArray;
}

/** フォームへのセット処理 ***/
function setForm(arr){

	if(arr == null){
		return;
	}else{
		var ar = arr.split(',');
		for(var i = 0; i < ar.length; i++){
			var targetId = ar[i].split('|')[0].replace(/:/g, "\\:");
			var targetType = jQuery("#" +targetId).attr("type");
			
			if(targetType == 'checkbox'){
				if(ar[i].split('|')[1] == "true"){
					jQuery("#" + targetId).attr('checked', true);
				}else{
					jQuery("#" + targetId).attr('checked', false);
				}
			}else if(targetType == 'select-multiple'){
				var selectValue = ar[i].split('|')[1].split(';');
				
				for(var j = 0; j < selectValue.length; j++){
					jQuery("#" + targetId + "_unselected option").each(function(){
						if(jQuery(this).text() == selectValue[j]){
							jQuery(this).attr("selected",true);
						}
					})
				}
				eval(decodeURIComponent(jQuery("#" + targetId + "_right_arrow").parent().attr('href')).substring(11));
				
			}else if(targetType == 'hidden' && targetId.match("_lkold")){
				jQuery("#" + targetId).val(ar[i].split('|')[1]);
				if(ar[i].split('|')[1] != 'null'){
					jQuery("#" + targetId.split('_')[0]).val(ar[i].split('|')[1]);
				}else{
					jQuery("#" + targetId.split('_')[0]).val();
				}
			}else{
				jQuery("#" + targetId).val(ar[i].split('|')[1]);
			}
		}
		
	}
}


/**************************************************************
 **
 ** 一括処理用のScript
 **
 *************************************************************/

//** Dialogを開く処理
function openBulkEditDialog(tableId, dialogId){ 
	jQuery(document.getElementById(dialogId)).dialog({
		title:'関連オブジェクト一括編集',
		width:450
	});
}

//** Dialogを閉じる処理
function closeBulkEditDialog(tableId, dialogId){
	jQuery(document.getElementById(dialogId)).dialog({
		close:function(event){
			jQuery('#' + dialogId + ' [id$=' + tableId + '_selecter]').val('').trigger("change");
		}
	});
	jQuery(document.getElementById(dialogId)).dialog('close');
}
	  
//** jQueryで使用できるようにIDをreplace
function changeId(targetID){
	return targetID.replace(/:/g, "\\:");
}

//** Reference判定
function isReference(targetID){
	return !! jQuery(document.getElementById(targetID + '_lkid'))[0];
}

//** MultiSelectPicklistを未選択へ
function picklistUnselect(targetID){
	MultiSelectPicklist.handleMSPUnSelect(targetID);
}

//** MultiSelectPicklistを選択へ
function picklistSelect(targetID){
	MultiSelectPicklist.handleMSPSelect(targetID);
}

//** MultiSelectPicklist初期化
function resetSelectPicklist(targetID){
	jQuery(document.getElementById(targetID + '_selected')).find('option').each(function(){
		jQuery(this).attr('selected',true);
	});
	picklistUnselect(targetID);
}

//** PageBlockTable/DataTableの値セット
function setTableValue(tableId, dialogId){
	try{
	//** ダイアログ内の項目選択がされているか？
		var selectedVal = jQuery('#' + dialogId + ' [id$=' + tableId + '_selecter]').val();
		if (selectedVal === '') {
			jQuery('#dialogErrBox').text(messages["NOTSELECTERROR"]);
			return;
		}else{
			jQuery('#dialogErrBox').empty();
		}
		
		//** 変更対象のIDを取得
		if(!jQuery('#' + dialogId + ' [id*=inputField]').attr('id')){
			return;
		}
		var idArr = jQuery('#' + dialogId + ' [id*=inputField]').attr('id').split(':');
		var targetId = idArr[idArr.length - 1].split('_')[0];

		//** 変更する値を取得
		var modifierValue = getValueItem(jQuery('#' + dialogId + ' [id*=inputField]').attr('id'));
		if(modifierValue  == null || modifierValue  == "" && !jQuery('#' + dialogId + ' [id*=inputField]').is(":input[type='checkbox']")){
			if(confirm(messages["VALUEENPTYCONVERTCONFIRM"])){
				modifierValue = '';
			} else {
				return;
			}
		}
		
		//** テーブルのチェックボックスを判定して、対象となる項目の値を変更する
		jQuery('[id$=' + tableId + '] tbody tr').each(function(){
			if(jQuery(this).find('[id*=BulkSelectCheckbox]').attr('checked')){
				setValueItem(jQuery(this).find('[id$=' + targetId + ']').attr('id'),modifierValue);
			}
		});
		
	} catch(e) {
		alert(messages["ERRORMESSAG"] + ":[" + e.faultcode + "]");
	}
}

//** inputFieldへの値セット
function setValueItem(itemId,itemValue){
	/**** セット対象の型判定 ****/
	//** multiPickList
	if(jQuery(document.getElementById(itemId)).is(":input[type='select-multiple']")){
		//** 選択リストの初期化処理
		resetSelectPicklist(itemId);
		jQuery(document.getElementById(itemId + '_unselected')).find('option').each(function(){
			for(var i = 0; i < itemValue.length; i++){
				if(jQuery(this).text() == itemValue[i]){
					jQuery(this).attr('selected',true);
				}
			}
		});
		//** SFDCのMultiPickListの選択済み関数の呼び出し
		MultiSelectPicklist.handleMSPSelect(itemId);
		
	//** checkBox
	}else if(jQuery(document.getElementById(itemId)).is(":input[type='checkbox']")){
		if(itemValue){
			jQuery(document.getElementById(itemId)).attr('checked',true);
		}else{
			jQuery(document.getElementById(itemId)).attr('checked',false);
		}
	//**
	}else{
		//** reference
		if(isReference(itemId)){
			if(itemValue == ''){
				jQuery(document.getElementById(itemId + '_lkid')).val('000000000000000');
				jQuery(document.getElementById(itemId)).val('');
			}else{
				jQuery(document.getElementById(itemId + '_lkid')).val(itemValue[1]);
				jQuery(document.getElementById(itemId)).val(itemValue[0]);
			}
		}else{
			jQuery(document.getElementById(itemId)).val(itemValue);
		}
	}
}

//*** 	inputFieldの値を取得する
function getValueItem(itemId){
	var itemValue;
	//** typeがcheckboxだったら
	if(jQuery(document.getElementById(itemId)).is(":input[type='checkbox']")){
		itemValue = jQuery(document.getElementById(itemId)).attr('checked');
		//** typeがhiddenだったら
	} else if(jQuery(document.getElementById(itemId)).is(":input[type='hidden']")){
		var multipickVal = jQuery(document.getElementById(itemId)).val();
		if(multipickVal != '000000000000000' && multipickVal != ''){
			itemValue = [jQuery(document.getElementById(itemId.replace('_lkid','_lkold'))).val(),jQuery(document.getElementById(itemId)).val()];
		}
	} else {
		itemValue = jQuery(document.getElementById(itemId)).val();
	}
	return itemValue;
}

/**
 * DataTableの行のフォーカスオン時の処理
 */
function skyeditorRowOver(elm){
	var styleName = jQuery(elm).parent().parent().attr("class");
	if(styleName == 'greyTableStyle'){
		jQuery(elm).addClass("grayOver");
	}else if(styleName == 'pageblockTableStyle'){
		jQuery(elm).addClass("pageBlockTableOver");
	}else if(styleName == 'greenTableStyle'){
		jQuery(elm).addClass("greenOver");
	}
}

/**
 * DataTableの行のフォーカスアウト時の処理
 */
function skyeditorRowOut(elm){
	var styleName = jQuery(elm).parent().parent().attr("class");
	if(styleName == 'greyTableStyle'){
		jQuery(elm).removeClass("grayOver");
	}else if(styleName == 'pageblockTableStyle'){
		jQuery(elm).removeClass("pageBlockTableOver");
	}else if(styleName == 'greenTableStyle'){
		jQuery(elm).removeClass("greenOver");
	}
}

/**
 * inputFieldにフォーカス時に色がつく処理
 */
function skyeditor_onFocus(elm,color){
	if(color =='pink'){
		jQuery(elm).addClass("skyeditor_focusStyle_pink");
	} else {
		jQuery(elm).addClass("skyeditor_focusStyle_blue");
	}
}

/**
 * inputFieldにフォーカスOUT時に色をなくす
 */
function skyeditor_onBlur(elm,color){
	if(color =='pink'){
		jQuery(elm).removeClass("skyeditor_focusStyle_pink");
	} else {
		jQuery(elm).removeClass("skyeditor_focusStyle_blue");
	}
}

/**
 * jQueryの要素リストから指定した要素の同じリスト要素内のみにフィルタリングする。
 * name属性のコロン区切りで最後の数値までをname属性の先頭に持つノードを取得します。
 * 
 * Visualforceでは、リストの最初に要素を追加したとき、
 * 1行目と2行目のid属性が同じになるため、name属性を使用しています。
 */
function filterListSibling(destObjects, srcObject) {
	var name = srcObject.attr("name"),
		nameSplited = name.split(":"),
		lastIndexValue;
	for (var i = nameSplited.length - 1; i >= 0; i--) {
		var fragment = nameSplited[i];
		if (! isNaN(fragment)) {
			lastIndexValue = fragment;
			break;
		}
	}
	if (lastIndexValue != null) {
		var head = name.substring(0, name.lastIndexOf(":" + lastIndexValue + ":") + (2 + lastIndexValue.length));
		return destObjects.filter("*[name^='" + head + "']");
	} else {
		return destObjects;
	}
}


//
// 数値取得処理を変更。
// ・カンマを除いて処理するように。
// ・全角数値を半角に
//
if (typeof _jquery_math__getNumber__ === "undefined") {
	var _jquery_math__getNumber__ = jQuery.getNumber;
	jQuery.getNumber = jQuery.fn.getNumber = function(value) {
		if (value == null) {
			value = jQuery(this).getValue();
		}
		value = value || 0;
		if (isNaN(value) && typeof value.replace === "function") {
			value = value.replace(/,/g, "")
						.replace(/０/g, "0")
						.replace(/１/g, "1")
						.replace(/２/g, "2")
						.replace(/３/g, "3")
						.replace(/４/g, "4")
						.replace(/５/g, "5")
						.replace(/６/g, "6")
						.replace(/７/g, "7")
						.replace(/８/g, "8")
						.replace(/９/g, "9");
		}
		return _jquery_math__getNumber__.call(this, value);
	};
}


/** 型毎に計算に使用する数値を取得 */
function getCalcValue(arg) {
	var value = typeof arg[0] === "number" || arg[0] instanceof Number ?
		arg[0] :
		arg.getNumber();
	
	if (arg.length === 0) { //jQuery(0)は空配列になる
		value = 0;
	}
	if (value == Number.POSITIVE_INFINITY || value == Number.NEGATIVE_INFINITY) {
		return 0;
	} else {
		return value;
	}
}

/** 計算結果のセット */
function setNumber(target, value) {
	if (isNaN(value) || value == Number.POSITIVE_INFINITY || value == Number.NEGATIVE_INFINITY) {
	} else {
		target.val(value);
	}
}


/** baseNodeObjectの兄弟、且つtargetIdで終わるnameの項目を取得する。 */
function getListSibling(targetId, baseNodeObject) {
	var targetList = jQuery("*[name$='" + targetId + "']");
	return (
		baseNodeObject == null ? 
		targetList :
		filterListSibling(targetList, baseNodeObject)
	);
}

/** 値を入力 */
function setValue(targetObj, value, roundType, roundLength) {
	targetObj.val(roundCalcValue(getCalcValue(value), roundType, roundLength - 1));
}
/** 丸め処理 */
function roundCalcValue(value, roundType, roundLength) {
	var fn = {
		"round" : calcRound,
		"floor" : calcFloor,
		"ceil" : calcCeil
	}[roundType];
	return fn(value, roundLength);
}
/** 四捨五入 */
function calcRound(value, length) {
	return jQuery.round(value, length);
}
/** 切捨て */
function calcFloor(value, length) {
	var scale = Math.pow(10, length);
	return Math.floor(value * scale) / scale;
}
/** 切上げ */
function calcCeil(value, length) {
	var scale = Math.pow(10, length);
	return Math.ceil(value * scale) / scale;
}
/** 加算 */
function addCalc() {
	var result = getCalcValue(arguments[0]);
	for (var i = 1; i < arguments.length; i++) {
		result += getCalcValue(arguments[i]);
	}
	return jQuery(result);
}
/** 減算 */
function subtractCalc() {
	var result = getCalcValue(arguments[0]);
	for (var i = 1; i < arguments.length; i++) {
		result -= getCalcValue(arguments[i]);
	}
	return jQuery(result);
}
/** 乗算 */
function multiplyCalc() {
	var result = getCalcValue(arguments[0]);
	for (var i = 1; i < arguments.length; i++) {
		result *= getCalcValue(arguments[i]);
	}
	return jQuery(result);
}
/** 除算 */
function divideCalc() {
	var result = getCalcValue(arguments[0]);
	for (var i = 1; i < arguments.length; i++) {
		result /= getCalcValue(arguments[i]);
	}
	return jQuery(result);
}
/** 合計 */
function sumCalc(arg) {
	return jQuery(arg.sum());
}


