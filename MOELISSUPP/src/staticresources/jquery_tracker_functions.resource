var sendValues = 0;
var loads = 0;
var isValidatorOnProcess = false;
function saveJson2(isClose)
{ 	
	if( isValidatorOnProcess ) return false;
	var r = $("*[validator]").validator();
    if(r == true)
    {
    	try
		{
			var quantity = 5;
			var obj_rows = jsonTable.model.table.length;
			var strJSON_obj = document.getElementById('thePage:saveJsonForm:theHiddenInput_strJSON');
			var objBtn = document.getElementById('thePage:saveJsonForm:saveJson_save_btn');
			
				if(jsonTable.model.delList != null)
				{
					strJSON_obj.value = "{" + '"delList" : ' + $.toJSON(jsonTable.model.delList) + "}";
					$(objBtn).click();
					sendValues++;
				}
				var itetation = 0;
				while(itetation <= obj_rows) 
				{
					var ret_rows = [];
					var ret = [];
					for (var i = itetation; i < itetation + quantity; i++) 
					{
						var rowid = $.toJSON(jsonTable.model.rows[i]);
						if(rowid != 'undefined')
						{
							ret_rows.push(rowid);
							ret.push($.toJSON(jsonTable.model.table[i]));
						}
					}
					var strJSON = 
					"{" + 
						'"rows" : [' + ret_rows.join(", ") + "], "+
						'"table" : [' + ret.join(", ") + "]"+
					"}";
					//alert(strJSON);
					strJSON_obj.value = strJSON;
					$(objBtn).click();
					
					itetation =  itetation + quantity;
					sendValues++;
					//alert('ending...');
				}
			
			loads = 1;
			if(isClose)loads = 2;
			
			loading();
			
    		
    		//alert('function end');
			return true;
		}catch(Exception){}
	} else return false;
}

function returnValues(url1,url2)
{
	//alert(sendValues);
	if(sendValues > 0 && loads > 0)sendValues--;
	if(sendValues == 0 && loads > 0) 
	{
		if(loads == 1) location.href = url1;
		if(loads == 2) location.href = url2;
	}
}

            
function showJson()
{
	$('#json-textarea').html($.toJSON(jsonTable.model));
}

function saveJson()
{
	var r = $("*[validator]").validator();
	if(r == true)
	{
		try
		{
			var jsonM = $.toJSON(jsonTable.model);
			objContainer.value = jsonM;
			return true;
		}
		catch(Exception){}
	} else return false;
}
function savedateO(trIndex, tdIndex)
{
	try
	{
		$("#date_"+trIndex+"_"+tdIndex)
					.datepicker({
                        debug: false,
                        dayNamesMin: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
                        monthNamesShort: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
                        changeYear: true,
                        changeMonth: true,
                        dateFormat: 'm/d/yy',
                        showOtherMonths: true,
                        selectOtherMonths: true,
                        showButtonPanel: true,
						beforeShow: function (input) {
                        },
                        onClose: function (dateText, inst) {
                            $this = $(this);
                            $td = $this.parent();
                            $tr = $td.parent();
                            if ($tr.attr("row_index") == undefined || $td.attr("cell_index") == undefined) return;
                            var newValue = $this.val();
                            if(newValue.length > 0) 
                            {
                            	var arrayDate = new Array();
                            	arrayDate = newValue.split('/',3); 
                            	//alert(arrayDate[0]+' '+arrayDate[1]+' '+arrayDate[2])
								if( arrayDate.length > 0 &&
									arrayDate[0] != undefined && arrayDate[1] != undefined && arrayDate[2] != undefined &&  
									arrayDate[0] != null && arrayDate[1] != null && arrayDate[2] != null && 
									arrayDate[2].length == 2) newValue = arrayDate[0]+'/'+arrayDate[1]+'/20'+arrayDate[2];
							}
                            jsonTable.model.table[$tr.attr("row_index")][$td.attr("cell_index")].value = newValue;
                            $('#tr'+trIndex+'_td'+tdIndex+'errrordiv').html('');
                        }
                    })
                    .animate({
                    }, {
                        queue: true,
                        duration: 100,
                        complete: function () {
                            $(this).trigger("focus")
                        }
                    })
                    .bind("blur", function (e) {}).bind("keypress", function (event) {
                        var keynum;
                        if (jQuery.browser.msie) keynum = event.keyCode;
                        else keynum = event.which;
                        if (keynum == 13) {
                            $(this).triggerHandler("blur");
                            return false
                        }
                    })
      
      } catch(Exception){}
}
            


var addRowInd2=1;
function addRows()
{
	try	{
			jsonTable.model.rows.push('new_'+addRowInd2);
			jsonTable.model.table.push(clone(jsonTable.params.json.newRow));
			addRowInd2++;
			jsonTable.refreshTable();
			var $controls = $(".inputClass,.selectClass");
			// Edited: Sergey Brull, 08.06.2010, Task #10380
			$controls.focus(function(event) {
  					var r = $("*[validator]").validator(true);
			});
	}catch(Exception){}
	return false;
}
    
function deleteRows(index)
{
	try	{
			list = new Array;
            $("table tbody tr", jsonTable.divPath).each(function (tRix) {
                    if ($("td:eq(" + index + ") input", this).attr("checked") &&  typeof jsonTable.model.rows[$(this).attr("row_index")] != "undefined" ) list.push(jsonTable.model.rows[$(this).attr("row_index")])
             });
             var candel = true;
             if(candelete() == false) 
             {
             	$.each(list, function () { 
                    if(this.substring(0,3) != "new") 
                    {
                    	alert('Insufficient privileges. Please contact the Help Desk'); 
                    	candel = false;
                    	return false;
                    }
              	});
             }
             if(candel == true) 
             {
             	$.each(list, function () { 
                    if ($.inArray(this, jsonTable.model.delList >= 0)) 
					{
						if(this.substring(0,3) != "new") jsonTable.model.delList.push(''+this);
						jsonTable.delRow(this);
					}
              	});
              	jsonTable.refreshTable();
              	return true;
             }
             
	}catch(Exception){}
	return false;
}


function alternativelookupO(trIndex, tdIndex, obj)
{
	var tmp0 = 'tr'+trIndex+'_td'+tdIndex;
	var tmp = $('#'+tmp0+'list_example');

	var qs = $('input#'+tmp0).quicksearch('#'+tmp0+'list_example div',
			{
				'dropdown' : '#'+tmp0+'list_example',
				'currentClass' : 'ui-current',
				'delay': 0,
    			'bind': 'keyup',
    			'onBefore': function (event) {
    				var key_code = qs.getKeyCode(event);
    				if(key_code != 13 && key_code != 27 && key_code != 38 && key_code != 40) {
						loadLookupData(trIndex, tdIndex, obj, $('input#'+tmp0).val());
					}
					return;
					}
			});
	qs.cache();
}

function presavelookupO(trIndex, tdIndex, id, val)
{
	$('#tr'+trIndex+'_td'+tdIndex).val(val);
	$('#tr'+trIndex+'_td'+tdIndex+'_lkold').val(val);
	$('#tr'+trIndex+'_td'+tdIndex+'_lkid').val(id);
	hidelookupO(trIndex, tdIndex);
}

function hidelookupO(trIndex, tdIndex)
{
	var tmp = $('#tr'+trIndex+'_td'+tdIndex+'list_example');
	tmp.html('');
	savelookupO('', trIndex, tdIndex);
	tmp.css("visibility", "hidden");
	tmp.css("display", "none");
}

var isAjaxStart = false;
function loadLookupData(trIndex, tdIndex, obj, inp_val)
{
	var tmp = $('#tr'+trIndex+'_td'+tdIndex+'list_example');
	tmp.html('');
	tmp.css("display", "none");
		// obj use in JSON get string
		//alert('/apex/ObjectListJSON?ob='+obj+'&val='+inp_val);
	if(!isAjaxStart)
	{
		isAjaxStart = true;
		$('#tr'+trIndex+'_td'+tdIndex+'loading').css('display','');
		$.ajax({'url': '/apex/ObjectListJSON?ob='+obj+'&val='+inp_val,
				'type': 'GET',
				'dataType': 'json',
				'success': function (data) {
					$.each(data['list_items'], function (e) {
						tmp.append('<div><a onclick="presavelookupO('+trIndex+', '+tdIndex+', \'' + this.key + '\', \'' + this.val + '\');">' + this.val + '</a></div>');
					});
					isAjaxStart = false;
					$('#tr'+trIndex+'_td'+tdIndex+'loading').css('display','none');	
					if(tmp.html()!='') tmp.css("display", "");				
			}
		});
	}
}

function savelookupO(obj, trIndex, tdIndex)
{		
		isValidatorOnProcess = true;
		try
		{
			var newValue = $('#tr'+trIndex+'_td'+tdIndex).val();
			var newValueId = $('#tr'+trIndex+'_td'+tdIndex+'_lkid').val();
			var err = 0;
			if (jsonTable.model.fields[tdIndex].validator != null && jsonTable.model.fields[tdIndex].validator.message3 != null)
			{
				$.each(jsonTable.model.table, function (rowIndex, rowValue) 
				{
				var tmp = jsonTable.model.table[rowIndex][tdIndex].value.lkid;
				if(tmp.length > 15) tmp = tmp.substring(0,15);
				if (newValueId.length > 15) newValueId = newValueId.substring(0,15);
				     if (newValueId == tmp && rowIndex != trIndex && newValue.length != 0 && newValueId.length) 
				     {
				     err = 3;
				     }
				});
			}

			if (err == 0)
			{
				jsonTable.model.table[trIndex][tdIndex].value.lkid = newValueId;
				jsonTable.model.table[trIndex][tdIndex].value.lkold = newValue;
				$('#tr'+trIndex+'_td'+tdIndex+'errrordiv').html('');
				if(jsonTable.model.table[trIndex][tdIndex].value.showaddtext != null && jsonTable.model.table[trIndex][tdIndex].value.obj != null)
				{
					$.ajax({'url': '/apex/ObjectListJSON?ob='+jsonTable.model.table[trIndex][tdIndex].value.obj+'&id='+newValueId+'&ch=1',
					'type': 'GET',
					'dataType': 'json',
					'success': function (data) 
						{
							if(data['data'] != null && data['data'][0] != null && data['data'][0].additional != null) 
							{
								showAdditionalText(trIndex,data['data'][0].additional);
							}
						}
					});
				}
			}
			else 
			{
				jsonTable.model.table[trIndex][tdIndex].value.lkid = '';
				$('#tr'+trIndex+'_td'+tdIndex+'_lkid').val('');
				jsonTable.model.table[trIndex][tdIndex].value.lkold = '';
				//if(jsonTable.model.fields[tdIndex].validator.message3 != null) $('#tr'+trIndex+'_td'+tdIndex+'errrordiv').html(jsonTable.model.fields[tdIndex].validator.message3);
				if(jsonTable.model.fields[tdIndex].validator.message2 != null) $('#tr'+trIndex+'_td'+tdIndex+'errrordiv').html(jsonTable.model.fields[tdIndex].validator.message2);
			}
		}catch(Exception){}
		isValidatorOnProcess = false;
}

function showAdditionalText(trIndex,additional)
{
	try{
	$.each(jsonTable.model.table[trIndex], function (cellInd, cellVall) {
	if (jsonTable.model.fields[cellInd].canaddtext != null && jsonTable.model.newRow[cellInd].type == "textO")
		{
			//$("#div-space table tbody tr:eq("+trIndex+") td:eq("+cellInd+")", jsonTable.divPath).html(additional);
			jsonTable.model.table[trIndex][cellInd].value = additional;
			jsonTable.refreshTable();
		}
	});
	}catch(Exception){}
}

function checklookupO(trIndex, tdIndex, obj)
{	
	isValidatorOnProcess = true;
	try	{						 
	var inp_id = $('input#tr'+trIndex+'_td'+tdIndex+'_lkid');
	var inp = $('input#tr'+trIndex+'_td'+tdIndex);
	var inp_val = inp.val();
	var tmp = $('#tr'+trIndex+'_td'+tdIndex+'errrordiv');
	if(inp_val.length > 0) 
	{
		tmp.html('');
		//document.getElementById('save').disabled = true;
		$.ajax({'url': '/apex/ObjectListJSON?ob='+obj+'&val='+inp_val+'&ch=1',
				'type': 'GET',
				'dataType': 'json',
				'success': function (data) {
					var err = 0;
					var dlength = data['data'].length;
					if (dlength > 1) 
					{	
						if (data['data'][0].value == inp.val()) err = 4;
						else err = 2;
					}
					if (dlength == 0) err = 1;
					
					if (jsonTable.model.fields[tdIndex].validator != null && jsonTable.model.fields[tdIndex].validator.message3 != null && data['data'][0] != null && data['data'][0].id != null && data['data'][0].value != null && data['data'][0].id != '')
					{
						$.each(jsonTable.model.table, function (rowIndex, rowValue) {
			                if (data['data'][0].id == jsonTable.model.table[rowIndex][tdIndex].value.lkid &&
			                	rowIndex != trIndex) err = 3;
			            });
			        }
			        
			       //document.getElementById('save').disabled = false;
			      // alert(dlength);alert(err);
					if ((err == 0 || err == 4) && data['data'][0] != null && data['data'][0].id != null && data['data'][0].value != null && data['data'][0].id != '')
					///if (err == 0 && data['data'][0] != null && data['data'][0].id != null && data['data'][0].value != null && data['data'][0].id != '')
					{
						
						if($('#tr'+trIndex+'_td'+tdIndex+'_show').val()==0)
						{
							jsonTable.model.table[trIndex][tdIndex].value.lkid = data['data'][0].id;
							inp_id.val(data['data'][0].id);
							jsonTable.model.table[trIndex][tdIndex].value.lkold = data['data'][0].value;
							inp.val(data['data'][0].value);
							if(jsonTable.model.table[trIndex][tdIndex].value.showaddtext != null && data['data'][0].additional != null) showAdditionalText(trIndex,data['data'][0].additional);
							//if(err==4)tmp.html('<div style="color:blue;">You can use lookup to select another record with the same Name</div>');
							//if(err==4 && jsonTable.model.fields[tdIndex].validator.message4 != null)tmp.html('<div style="color:blue;">'+jsonTable.model.fields[tdIndex].validator.message4+'</div>');
							if(err==4 && jsonTable.model.fields[tdIndex].validator.message4 != null)tmp.html(jsonTable.model.fields[tdIndex].validator.message4);
						}
						
						isValidatorOnProcess = false;
						return true;
					} else {
						
						jsonTable.model.table[trIndex][tdIndex].value.lkid = '';
						inp_id.val('');
						jsonTable.model.table[trIndex][tdIndex].value.lkold = '';
						
						if(err > 0 && jsonTable.model.fields[tdIndex].validator.message2 != null)	tmp.html(jsonTable.model.fields[tdIndex].validator.message2);
						//if(err == 1 && jsonTable.model.fields[tdIndex].validator.message2 != null) tmp.html(jsonTable.model.fields[tdIndex].validator.message2);
						if((err == 2 || err == 4) && jsonTable.model.fields[tdIndex].validator.message4 != null) tmp.html(jsonTable.model.fields[tdIndex].validator.message4);//tmp.html('<nobr>Please use lookup to select a contact.</nobr>');
						//if(err == 3 && jsonTable.model.fields[tdIndex].validator.message3 != null) tmp.html(jsonTable.model.fields[tdIndex].validator.message3);
					}
					$('#tr'+trIndex+'_td'+tdIndex+'_show').val(0);
				
			}
		});
		
	} 
	else
	{
		//tmp.html(jsonTable.model.fields[tdIndex].validator.message);
		inp_id.val('');
	}
	}catch(Exception){}
	//$('#tr'+trIndex+'_td'+tdIndex+'_show').val(0);
	isValidatorOnProcess = false;
	return false;
}


// Edited:  Sergey Brull, 08.06.2010, Task# 10380
jQuery(function ($) {
		$.fn.validator = function (p_behaviour) {
			var behaviour = (p_behaviour == 'undefined') ? false : p_behaviour;
			var result = true;
			var options = {
					noempty  : {
						Messsage : "field not be empty",
						MinChars : 2
					},
					checkNumber  : {
						Messsage : "Invalid Number"
					},
					checkUSDate  : {
						Messsage : "Invalid Date"
					},
					checkCurrency  : {
						Messsage : "Invalid Number"
					}
			}
			$target = $(this);
			$(".validatorMesssage").remove();
			
			$target.each( function(idx) {
				var validator = $(this).attr("validator");
				if(validator.length != 0) {
					_log(validator);
					switch(validator) {
						case 'noempty':
							var r = noempty(this);
							_log("noempty::r = " + r);
							if(r == false) {
								_log("noempty::false");
								result = false;
							}
						break;
						case 'noemptyCheckHours':
							var r = noemptyCheckHours(this,'rtext_');
							_log("noemptyCheckHours::r = " + r);
							if(r == false) {
								_log("noemptyCheckHours::false");
								result = false;
							}
						break;
						case 'noemptyCheckHours2':
							var r = noemptyCheckHours(this,'rtext2_');
							_log("noemptyCheckHours::r = " + r);
							if(r == false) {
								_log("noemptyCheckHours::false");
								result = false;
							}
						break;
						case 'noemptyCheckNumber':
							var r = noemptyCheckNumber(this,'errrordiv');
							_log("noemptyCheckNumber::r = " + r);
							if(r == false) {
								_log("noemptyCheckNumber::false");
								result = false;
							}
						break;
						case 'noemptyCheckNumber2':
							var r = noemptyCheckNumber(this,'errrordiv2');
							_log("noemptyCheckNumber2::r = " + r);
							if(r == false) {
								_log("noemptyCheckNumber2::false");
								result = false;
							}
						break;
						case 'checkDuplicates':
							var r = checkDuplicates(this);
							_log("checkDuplicates::r = " + r);
							if(r == false) {
								_log("checkDuplicates(::false");
								result = false;
							}
						case 'checkNumber':
							var r = checkNumber(this);
							_log("checkNumber::r = " + r);
							if(r == false) {
								_log("checkNumber(::false");
								result = false;
							}
						break;
						case 'checkUSDate':
							var r = checkUSDate(this);
							_log("checkUSDate::r = " + r);
							if(r == false) {
								_log("checkUSDate(::false");
								result = false;
							}
						break;
						case 'checkCurrency':
							var r = checkCurrency(this);
							_log("checkCurrency::r = " + r);
							if(r == false) {
								_log("checkCurrency(::false");
								result = false;
							}
						break;
						case 'checkEmail':
							var r = checkEmail(this);
							_log("checkEmail::r = " + r);
							if(r == false) {
								_log("checkEmail(::false");
								result = false;
							}
						break;
					}
				} 
			});
			
			function noempty(p_this) {
				var $this = $(p_this);
				var value = $this.attr("value");
								
				if(behaviour) {
					if($this.val() == "") {
						return false;
					}
				}
								
				var value = $this.attr("value");
				_log("noempty:value = " + value);
				var min_chars = $this.attr("validatorMinChars");
				if(min_chars.length == 0) {
					min_chars = options.noempty.MinChars;
				}
				
				var $td = $this.parent();
				var $tr = $td.parent();
				var tdIndex = $td.attr('cell_index');
				var trIndex = $tr.attr('row_index');
				var tmp = $('#tr'+trIndex+'_td'+tdIndex+'errrordiv');
				
				if(value.length < min_chars) {
					var message = $this.attr("validatorMesssage");
					if(message.length == 0) {
						message = options.noempty.Messsage;
					}
					_log("noempty:message = " + message);
					if ($this.attr('id') == 'tr'+trIndex+'_td'+tdIndex+'_lkid' &&  $('#tr'+trIndex+'_td'+tdIndex).val() != '')
					{
						try	{
						tmp.html(jsonTable.model.fields[tdIndex].validator.message2);
						$.ajax({'url': '/apex/ObjectListJSON?ob='+jsonTable.model.table[trIndex][tdIndex].value.obj+'&val='+$('#tr'+trIndex+'_td'+tdIndex).val()+'&ch=1',
								'type': 'GET',
								'dataType': 'json',
								'success': function (data) {
									var err = 0;
									var dlength = data['data'].length;
									if (dlength > 1) err = 2;
									if (dlength == 0) err = 1;
									if(err == 2)	tmp.html(jsonTable.model.fields[tdIndex].validator.message4);
							}
						});
						}catch(Exception){}
					}
					else tmp.html(message);
					_log($this);
					return false;		
				} else {
					tmp.html('');
					
					try	{
						if($this.attr('class') == 'selectClass' && jsonTable2.model.fields[tdIndex].validator != null && jsonTable2.model.fields[tdIndex].validator.message3 != null)
						{
							var err = 0;
							$.each(jsonTable2.model.table, function (rowIndex, rowValue) 
							{
								if (value == jsonTable2.model.table[rowIndex][tdIndex].value && rowIndex != trIndex) 
								{
									err = 3;
								}
							});
							if(err > 0)	
							{
								tmp.html(jsonTable2.model.fields[tdIndex].validator.message3);
								return false;
							}
						}
					}catch(Exception){}
					
					return true;
				}
			}
			function noemptyCheckHours(p_this,rtext) {
				var $this = $(p_this);
				var strValue = $this.attr("value");
								
				if(behaviour) {
					if($this.val() == "") {
						return false;
					}
				}
				var $td = $this.parent();
				var $tr = $td.parent();
				var tdIndex = $td.attr('cell_index');
				var trIndex = $tr.attr('row_index');
				var tmp = $('#tr'+trIndex+'_td'+tdIndex+'errrordiv');
				var message = $this.attr("validatorMesssage");
				if(message.length == 0) {
						message = options.noempty.Messsage;
				}
				if(strValue.length == 0)
				{
					var tdHourIndex = parseInt(tdIndex)+ 1 ;
					var trHourIndex = trIndex;
					var inputHourValue = $('#'+rtext+trHourIndex+'_'+tdHourIndex).val();
					if(parseInt(inputHourValue) > 0)
					{
						var is_error = false;
						if(rtext == 'rtext2_')
						{
							var tdNonDealProjectIndex = parseInt(tdIndex)- 1 ;
							if(jsonTable2.model.fields[tdIndex].validator != null && jsonTable2.model.fields[tdIndex].validator.checkError != null)	
							{
								$.each(jsonTable2.model.fields[tdIndex].validator.checkError, function () 
								{
									if (this.value == jsonTable2.model.table[trIndex][tdNonDealProjectIndex].value)
									{
										is_error = true;
									}
								});
							}
						}
						else if(rtext == 'rtext_') is_error = true;
					
						if(is_error)
						{
							tmp.html(message);
							return false;
						}
						else tmp.html('');
					}
					else tmp.html('');
				}
				return true;
			}
			
			function noemptyCheckNumber(p_this, errrordiv) {
				var $this = $(p_this);
				var strValue = $this.attr("value");
								
				if(behaviour) {
					if($this.val() == "") {
						return false;
					}
				}
				var $td = $this.parent();
				var $tr = $td.parent();
				var tdIndex = $td.attr('cell_index');
				var trIndex = $tr.attr('row_index');
				var tmp = $('#tr'+trIndex+'_td'+tdIndex+errrordiv);
				var message = $this.attr("validatorMesssage");
				if(message.length == 0) {
						message = options.noempty.Messsage;
				}
				var objRegExp  =  /(^\d\d*\.\d*$)|(^\d\d*$)|(^\.\d\d*$)/;
				var returnvalue = objRegExp.test(strValue);
				if(!returnvalue || strValue.length == 0)
				{
					tmp.html(message);
					return false;
				}
				/*
				if(parseInt(strValue) > 0)
				{
					var tdSBankerIndex = parseInt(tdIndex) - 1 ;
					var trSBankerIndex = trIndex;
					var inputSBankerValue = $('#'+rtext+trHourIndex+'_'+tdHourIndex).val();
					//alert(inputSBankerValue);
					if(parseInt(inputSBankerValue) > 0)
					{
						tmp.html(message);
						return false;
					}
				}
				*/
				return true;
			}
			
function trim(s)
{
  return s.replace(/^\s+|\s+$/, '');
}
			function checkDuplicates(p_this) {
			/*
				var $this = $(p_this);
				var value = $this.attr("value");				
				if(behaviour) {
					if($this.val() == "") {
						return false;
					}
				}
				
				var $td = $this.parent();
				var $tr = $td.parent();
				var tdIndex = $td.attr('cell_index');
				var trIndex = $tr.attr('row_index');
				var tmp = $('#tr'+trIndex+'_td'+tdIndex+'errrordiv');
				alert();
				try	{
					//if(checkselectJson2O(p_this))	return true;
					
					if (jsonTable2.model.fields[tdIndex].validator != null && jsonTable2.model.fields[tdIndex].validator.message3 != null)
					{
						
						$.each(jsonTable2.model.table[tdIndex], function (rowIndex, rowValue) 
						{
							
							if (value == jsonTable2.model.table[rowIndex][tdIndex].value && rowIndex != trIndex) 
							{
								
								err = 3;
								alert('tut');
							}
						});
						
						if(err > 0)	tmp.html(jsonTable2.model.fields[tdIndex].validator.message3);
						return true;
					}
				}catch(Exception){}
				return false;	
				*/
			}
			
			function checkEmail(p_this) 
			{
				var $this = $(p_this);
				var $td = $this.parent();
				var $tr = $td.parent();
				var tdIndex = $td.attr('cell_index');
				var trIndex = $tr.attr('row_index');
				var tmp = $('#tr'+trIndex+'_td'+tdIndex+'errrordiv');
				
				var strValue = $this.attr("value");
			    var tfld = trim(strValue);                        // value of field with whitespace trimmed off
			    var emailFilter = /^[^@]+@[^@.]+\.[^@]*\w\w$/ ;
			    var illegalChars= /[\(\)\<\>\,\;\:\\\"\[\]]/ ;
			    if (strValue == "") 
			    {
			       //tmp.html("You didn't enter an email address.\n");
			      // return false;
			    } else if (!emailFilter.test(tfld)) 
			    {              //test email for illegal characters
			        tmp.html("Please enter a valid email address.\n");
			        return false;
			    } else if (strValue.match(illegalChars)) 
			    {
			        tmp.html("The email address contains illegal characters.\n");
			        return false;
			    }
			    return true;
			}
						
			function checkNumber(p_this) 
			{
				/*****************************************************************
				DESCRIPTION: Validates that a string contains only valid numbers.
				PARAMETERS: strValue - String to be tested for validity
				RETURNS: True if valid, otherwise false.
				******************************************************************/
				var objRegExp  =  /(^\d\d*\.\d*$)|(^\d\d*$)|(^\.\d\d*$)/;
				var $this = $(p_this);
				var strValue = $this.attr("value");
				var returnvalue = objRegExp.test(strValue);
				if(!returnvalue && strValue.length > 0)
				{
					var $td = $this.parent();
					var $tr = $td.parent();
					var tdIndex = $td.attr('cell_index');
					var trIndex = $tr.attr('row_index');
					var tmp = $('#tr'+trIndex+'_td'+tdIndex+'errrordiv');
					var message = $this.attr("validatorMesssage");
					if(message.length == 0) {
						message = options.checkNumber.Messsage;
					}
					tmp.html(message);
					return false;
				}
				return true;
			}
			
			function checkCurrency(p_this) 
			{
				//var objRegExp  =	/^([1-9]{1}[0-9]{0,2}(\,\d{3})*(\.\d*)?|[1-9]{1}\d*(\.\d*)?|0(\.\d*)?|(\.\d*))$|^([1-9]{1}\d{0,2}(\,\d{3})*(\.\d*)?|[1-9]{1}\d{0,}(\.\d*)?|0(\.\d*)?|(\.\d*))$|^\(([1-9]{1}\d{0,2}(\,\d{3})*(\.\d*)?|[1-9]{1}\d{0,}(\.\d*)?|0(\.\d*)?|(\.\d*))\)$/;
				var objRegExp  =	/^([0-9][0-9]{0,2}([,][0-9]{3}){0,4}([.][0-9]{0,8})?)$|^([0-9]{1,14})?([.][0-9]{1,8})$|^[0-9]{1,14}$/;
				var $this = $(p_this);
				var $td = $this.parent();
				var $tr = $td.parent();
				var tdIndex = $td.attr('cell_index');
				var trIndex = $tr.attr('row_index');
				var strValue = $this.attr("value");
				
				var returnvalue = objRegExp.test(strValue);
				var err = false;
				if( strValue.indexOf(".")== -1 && jsonTable.model.fields[tdIndex].validator.digitsLength != null) 
				{
				  	var strValue2 = strValue;
				  	if(strValue.indexOf(",")!= -1) strValue2 = strValue.replace(/,/g,'');
				  	if (strValue2.length > jsonTable.model.fields[tdIndex].validator.digitsLength) err = true;
				}
				if(strValue.indexOf(".")!= -1)
				{
					try	{
						var dataArray = strValue.split(".", 2);
						if(dataArray[0] != undefined && dataArray[0].indexOf(",")!= -1) dataArray[0] = dataArray[0].replace(/,/g,'');
						if( jsonTable.model.fields[tdIndex].validator.digitsLength != null && jsonTable.model.fields[tdIndex].validator.digitsScale != null && 
							dataArray[0] != undefined && dataArray[1] != undefined &&
							(dataArray[0].length > jsonTable.model.fields[tdIndex].validator.digitsLength || dataArray[1].length > jsonTable.model.fields[tdIndex].validator.digitsScale)
						   ) err = true;
						//alert(dataArray[0].length +' - '+jsonTable.model.fields[tdIndex].validator.digitsLength +' - '+dataArray[1].length+' - '+jsonTable.model.fields[tdIndex].validator.digitsScale);
					}catch(Exception){}
				}
				if(!returnvalue && strValue.length > 0 || err)
				{
					var tmp = $('#tr'+trIndex+'_td'+tdIndex+'errrordiv');
					var message = $this.attr("validatorMesssage");
					if(message.length == 0) {
						message = options.checkCurrency.Messsage;
					}
					tmp.html(message);
					return false;
				}
				return true;
			}

			function checkUSDate(p_this) 
			{
				var objRegExp = /^\d{1,2}(\/)\d{1,2}\1\d{2,4}$/
				var $this = $(p_this);
				var strValue = $this.attr("value");
				var returnvalue = objRegExp.test(strValue);
				
				var ret = false;
				if(!returnvalue)
				{
				    if (strValue.length == 0)	ret = true;
				    else  ret = false;
				}
				else{
				    var arrayDate = strValue.split('/'); 
				    var arrayLookup = { '1' : 31,'3' : 31, 
				                        '4' : 30,'5' : 31,
				                        '6' : 30,'7' : 31,
				                        '8' : 31,'9' : 30,
				                        '10' : 31,'11' : 30,'12' : 31}
				    var intDay = parseInt(arrayDate[1],10); 
					var intMonth = parseInt(arrayDate[0],10); 
					//console.log('intMonth='+intMonth+' arrayLookup[arrayDate[0]]='+arrayLookup[arrayDate[0]]+' arrayLookup[intMonth]='+arrayLookup[intMonth]);
					
					/*
				    //check if month value and day value agree
				    if(arrayLookup[arrayDate[0]] != null) {
				      if(intDay <= arrayLookup[arrayDate[0]] && intDay != 0)
				        ret = true; 
				    }
				    */
				    if(arrayLookup[intMonth] != null) {
				      if(intDay <= arrayLookup[intMonth] && intDay != 0)
				        ret = true; 
				    }
				    
				    //check for February (bugfix 20050322)
				    //bugfix  for parseInt kevin
				    //bugfix  biss year  O.Jp Voutat
				   
				    if (intMonth == 2) { 
				       var intYear = parseInt(arrayDate[2]);
				       if (intDay > 0 && intDay < 29) {
				           ret = true; 
				       }
				       else if (intDay == 29) {
				         if ((intYear % 4 == 0) && (intYear % 100 != 0) || 
				             (intYear % 400 == 0)) {
				              // year div by 4 and ((not div by 100) or div by 400) ->ok
				             ret = true; 
				         }   
				       }
				    }
				}
				
				//console.log(strValue+' '+ret);
				var $td = $this.parent();
				var $tr = $td.parent();
				var tdIndex = $td.attr('cell_index');
				var trIndex = $tr.attr('row_index');
				var tmp = $('#tr'+trIndex+'_td'+tdIndex+'errrordiv');
				tmp.html('');				
				if (ret == false)
				{
					var message = $this.attr("validatorMesssage");
					if(message.length == 0) {
							message = options.checkNumber.Messsage;
					}
					tmp.html(message);
					
				}
				return ret; 
			}
			
			function _log(obj) {
				//if(console != "undefined") { console.log(obj); } 
			}
			
			return result;
		};
	});

function drowPaging()
{

	var str = '';
	try
	{
        if(jsonTable.model.paging != null)
        {
	        var pagesFromTo = parseInt(jsonTable.model.paging.ObjPageSize*parseInt(jsonTable.model.paging.ObjPageNumber - 1) + 1 )+'-';
	        if(parseInt(jsonTable.model.paging.ObjPageSize * jsonTable.model.paging.ObjPageNumber) < parseInt(jsonTable.model.paging.ObjResultSize))pagesFromTo += parseInt(jsonTable.model.paging.ObjPageSize * jsonTable.model.paging.ObjPageNumber);
	        else pagesFromTo += jsonTable.model.paging.ObjResultSize;
    str += '<div id="navigation" class="bottomNav" style="padding-top:10px;">';
 	 str += '<div class="paginator">';
 		str += '<span class="left">'; 
 			str += '<span onmouseout="this.className = \'selectorTarget\';" onmouseover="this.className = \'selectorTarget selectorOpen\';"  onmousedown="this.className = \'selectorTarget selectorOpen\';" id="pages_div" class="selectorTarget">';
 			str += pagesFromTo+' of '+jsonTable.model.paging.ObjResultSize+''; 
 			str += '<table cellspacing="0" cellpadding="0" id="pages_table" class="selector rpp" style="margin-bottom:-4px;">'; 
 					str += '<tr onmousedown="downRow(this,5,'+jsonTable.model.paging.ObjPageNumber+');" onmouseout="this.className = this.className.replace(\'optHover\', \'\')" onmouseover="if (this.className.indexOf(\'optHover\') &lt; 0) { this.className += \' optHover\' }"  ';
 					if(jsonTable.model.paging.ObjPageSize == '5')str += 'class="opt optSelected">';
 					else str += 'class="opt optUnselected">'; 
 						str += '<td class="optUnselected">Display</td>'; 
 						str += '<td class="rppOpt">5</td>'; 
 						str += '<td class="optUnselected">records per page</td>'; 
 					str += '</tr>';
 					str += '<tr onmousedown="downRow(this,10,'+jsonTable.model.paging.ObjPageNumber+');" onmouseout="this.className = this.className.replace(\'optHover\', \'\')" onmouseover="if (this.className.indexOf(\'optHover\') &lt; 0) { this.className += \' optHover\' }"  ';
 					if(jsonTable.model.paging.ObjPageSize == '10')str += 'class="opt optSelected">';
 					else str += 'class="opt optUnselected">'; 
 						str += '<td class="optUnselected">Display</td>'; 
 						str += '<td class="rppOpt">10</td>'; 
 						str += '<td class="optUnselected">records per page</td>'; 
 					str += '</tr>'; 
 					str += '<tr onmousedown="downRow(this,25,'+jsonTable.model.paging.ObjPageNumber+');" onmouseout="this.className = this.className.replace(\'optHover\', \'\')" onmouseover="if (this.className.indexOf(\'optHover\') &lt; 0) { this.className += \' optHover\' }"  ';
 					if(jsonTable.model.paging.ObjPageSize == '25')str += 'class="opt optSelected">';
 					else str += 'class="opt optUnselected">'; 
 						str += '<td class="optUnselected">Display</td>'; 
 						str += '<td class="rppOpt">25</td>'; 
 						str += '<td class="optUnselected">records per page</td>'; 
 					str += '</tr>'; 
 					str += '<tr onmousedown="downRow(this,50,'+jsonTable.model.paging.ObjPageNumber+');" onmouseout="this.className = this.className.replace(\'optHover\', \'\')" onmouseover="if (this.className.indexOf(\'optHover\') &lt; 0) { this.className += \' optHover\' }"  ';
 					if(jsonTable.model.paging.ObjPageSize == '50')str += 'class="opt optSelected">';
 					else str += 'class="opt optUnselected">';  
 						str += '<td class="optUnselected">Display</td>'; 
 						str += '<td class="rppOpt">50</td>'; 
 						str += '<td class="optUnselected">records per page</td>'; 
 					str += '</tr>'; 
 					str += '<tr onmousedown="downRow(this,100,'+jsonTable.model.paging.ObjPageNumber+');" onmouseout="this.className = this.className.replace(\'optHover\', \'\')" onmouseover="if (this.className.indexOf(\'optHover\') &lt; 0) { this.className += \' optHover\' }"  ';
 					if(jsonTable.model.paging.ObjPageSize == '100')str += 'class="opt optSelected">';
 					else str += 'class="opt optUnselected">'; 
 						str += '<td class="optUnselected">Display</td>'; 
 						str += '<td class="rppOpt">100</td>'; 
 						str += '<td class="optUnselected">records per page</td>'; 
 					str += '</tr>'; 
 					str += '<tr onmousedown="downRow(this,200,'+jsonTable.model.paging.ObjPageNumber+');" onmouseout="this.className = this.className.replace(\'optHover\', \'\')" onmouseover="if (this.className.indexOf(\'optHover\') &lt; 0) { this.className += \' optHover\' }"  ';
 					if(jsonTable.model.paging.ObjPageSize == '200')str += 'class="opt optSelected">';
 					else str += 'class="opt optUnselected">';  
 						str += '<td class="optUnselected">Display</td>'; 
 						str += '<td class="rppOpt">200</td>'; 
 						str += '<td class="optUnselected">records per page</td>'; 
 					str += '</tr>'; 
 			str += '</table>'; 
 			str += '<img src="/s.gif" class="selectArrow"/>'; 
 			str += '</span>'; 
	 	str += '</span>'; 
	 	str += '<span class="prevNextLinks">'; 
	 	str += '<span class="prevNext">';
	 		if(jsonTable.model.paging.hasObjPrevious == 'true') 	str += '<a href="javascript:goFirst(1,'+jsonTable.model.paging.ObjPageSize+');"><img class="first" src="/s.gif"/></a>';
	 		else  	str += '<img class="firstoff" src="/s.gif"/>';
	 	str += '</span>'; 
	 	str += '<span class="prevNext">';
	 		if(jsonTable.model.paging.hasObjPrevious == 'true') 	str += '<a href="javascript:goPrev('+jsonTable.model.paging.ObjPageNumber+','+jsonTable.model.paging.ObjPageSize+');"><img class="prev" src="/s.gif"/>Previous</a>';
	 		else  	str += '<img class="prevoff" src="/s.gif"/>Previous';
	 	str += '</span>';
	 	str += '<span class="prevNext">';
	 		if(jsonTable.model.paging.hasObjNext == 'true') 	str += '<a href="javascript:goNext('+jsonTable.model.paging.ObjPageNumber+','+jsonTable.model.paging.ObjPageSize+');">Next<img class="next" src="/s.gif"/></a>';
	 		else  	str += 'Next<img class="nextoff" src="/s.gif"/>';
	 	str += '</span>';
	 	str += '<span class="prevNext">';
	 		if(jsonTable.model.paging.hasObjNext == 'true') 	str += '<a href="javascript:goLast('+jsonTable.model.paging.LastPage+','+jsonTable.model.paging.ObjPageSize+');"><img class="last" src="/s.gif"/></a>';
	 		else  	str += '<img class="lastoff" src="/s.gif"/>';
	 	str += '</span>';
	 	str += '</span>'; 
	 	str += '<span class="right">Page<input value="'+jsonTable.model.paging.ObjPageNumber+'" onchange="goToPage(this.value,'+jsonTable.model.paging.ObjPageSize+')" maxlength="4" class="pageInput"/>of '+jsonTable.model.paging.LastPage+'</span>'; 
	 str += '</div>'; 
 	str += '<div class="clearingBox"></div>'; 
 str += '</div>';               
  		}
  	}catch(Exception){}
  	return str;
}


function loading()
{
	$.openDOMWindow({ 
        		loader:1, 
				height:50,
				loaderImagePath:'/img/loading.gif',
				loaderWidth:50,
				overlayOpacity:'25',
				width:50, 
        		windowSource:'#example8Content' 
    }); 
}
(function($){

	//openDOMWindow
	$.fn.openDOMWindow = function(instanceSettings){	
		
		var shortcut =  $.fn.openDOMWindow;
	
		//default settings combined with callerSettings////////////////////////////////////////////////////////////////////////
		
		shortcut.defaultsSettings = {
			anchoredClassName:'',
			anchoredSelector:'',
			borderColor:'#ccc',
			borderSize:'4',
			draggable:0,
			eventType:null, //click, blur, change, dblclick, error, focus, load, mousedown, mouseout, mouseup etc...
			fixedWindowY:100,
			functionCallOnOpen:null,
			functionCallOnClose:null,
			height:500,
			loader:0,
			loaderHeight:0,
			loaderImagePath:'',
			loaderWidth:0,
			modal:0,
			overlay:1,
			overlayColor:'#000',
			overlayOpacity:'85',
			positionLeft:0,
			positionTop:0,
			positionType:'centered', // centered, anchored, absolute, fixed
			width:500, 
			windowBGColor:'#fff',
			windowBGImage:null, // http path
			windowHTTPType:'get',
			windowPadding:10,
			windowSource:'inline', //inline, ajax, iframe
			windowSourceID:'',
			windowSourceURL:'',
			windowSourceAttrURL:'href'
		};
		
		var settings = $.extend({}, $.fn.openDOMWindow.defaultsSettings , instanceSettings || {});
		
		//Public functions
		
		shortcut.viewPortHeight = function(){ return self.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;};
		shortcut.viewPortWidth = function(){ return self.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;};
		shortcut.scrollOffsetHeight = function(){ return self.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop;};
		shortcut.scrollOffsetWidth = function(){ return self.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft;};
		shortcut.isIE6 = typeof document.body.style.maxHeight === "undefined";
		
		//Private Functions/////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		var sizeOverlay = function(){
			var $DOMWindowOverlay = $('#DOMWindowOverlay');
			if(shortcut.isIE6){//if IE 6
				var overlayViewportHeight = document.documentElement.offsetHeight + document.documentElement.scrollTop - 4;
				var overlayViewportWidth = document.documentElement.offsetWidth - 21;
				$DOMWindowOverlay.css({'height':overlayViewportHeight +'px','width':overlayViewportWidth+'px'});
			}else{//else Firefox, safari, opera, IE 7+
				$DOMWindowOverlay.css({'height':'100%','width':'100%','position':'fixed'});
			}	
		};
		
		var sizeIE6Iframe = function(){
			var overlayViewportHeight = document.documentElement.offsetHeight + document.documentElement.scrollTop - 4;
			var overlayViewportWidth = document.documentElement.offsetWidth - 21;
			$('#DOMWindowIE6FixIframe').css({'height':overlayViewportHeight +'px','width':overlayViewportWidth+'px'});
		};
		
		var centerDOMWindow = function() {
			var $DOMWindow = $('#DOMWindow');
			if(settings.height + 50 > shortcut.viewPortHeight()){//added 50 to be safe
				$DOMWindow.css('left',Math.round(shortcut.viewPortWidth()/2) + shortcut.scrollOffsetWidth() - Math.round(($DOMWindow.outerWidth())/2));
			}else{
				$DOMWindow.css('left',Math.round(shortcut.viewPortWidth()/2) + shortcut.scrollOffsetWidth() - Math.round(($DOMWindow.outerWidth())/2));
				$DOMWindow.css('top',Math.round(shortcut.viewPortHeight()/2) + shortcut.scrollOffsetHeight() - Math.round(($DOMWindow.outerHeight())/2));
			}
		};
		
		var centerLoader = function() {
			var $DOMWindowLoader = $('#DOMWindowLoader');
			if(shortcut.isIE6){//if IE 6
				$DOMWindowLoader.css({'left':Math.round(shortcut.viewPortWidth()/2) + shortcut.scrollOffsetWidth() - Math.round(($DOMWindowLoader.innerWidth())/2),'position':'absolute'});
				$DOMWindowLoader.css({'top':Math.round(shortcut.viewPortHeight()/2) + shortcut.scrollOffsetHeight() - Math.round(($DOMWindowLoader.innerHeight())/2),'position':'absolute'});
			}else{
				$DOMWindowLoader.css({'left':'50%','top':'50%','position':'fixed'});
			}
			
		};
		
		var fixedDOMWindow = function(){
			var $DOMWindow = $('#DOMWindow');
			$DOMWindow.css('left', settings.positionLeft + shortcut.scrollOffsetWidth());
			$DOMWindow.css('top', + settings.positionTop + shortcut.scrollOffsetHeight());
		};
		
		var showDOMWindow = function(instance){
			if(arguments[0]){
				$('.'+instance+' #DOMWindowLoader').remove();
				$('.'+instance+' #DOMWindowContent').fadeIn('fast',function(){if(settings.functionCallOnOpen){settings.functionCallOnOpen();}});
				$('.'+instance+ '.closeDOMWindow').click(function(){
					$.closeDOMWindow();	
					return false;
				});
			}else{
				$('#DOMWindowLoader').remove();
				$('#DOMWindow').fadeIn('fast',function(){if(settings.functionCallOnOpen){settings.functionCallOnOpen();}});
				$('#DOMWindow .closeDOMWindow').click(function(){						
					$.closeDOMWindow();
					return false;
				});
			}
			
		};
		
		var urlQueryToObject = function(s){
			  var query = {};
			  s.replace(/b([^&=]*)=([^&=]*)b/g, function (m, a, d) {
				if (typeof query[a] != 'undefined') {
				  query[a] += ',' + d;
				} else {
				  query[a] = d;
				}
			  });
			  return query;
		};
			
		//Run Routine ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
		var run = function(passingThis){
			
			//get values from element clicked, or assume its passed as an option
			settings.windowSourceID = $(passingThis).attr('href') || settings.windowSourceID;
			settings.windowSourceURL = $(passingThis).attr(settings.windowSourceAttrURL) || settings.windowSourceURL;
			settings.windowBGImage = settings.windowBGImage ? 'background-image:url('+settings.windowBGImage+')' : '';
			var urlOnly, urlQueryObject;
			
			if(settings.positionType == 'anchored'){//anchored DOM window
				
				var anchoredPositions = $(settings.anchoredSelector).position();
				var anchoredPositionX = anchoredPositions.left + settings.positionLeft;
				var anchoredPositionY = anchoredPositions.top + settings.positionTop;
				
				$('body').append('<div class="'+settings.anchoredClassName+'" style="'+settings.windowBGImage+';background-repeat:no-repeat;padding:'+settings.windowPadding+'px;overflow:auto;position:absolute;top:'+anchoredPositionY+'px;left:'+anchoredPositionX+'px;height:'+settings.height+'px;width:'+settings.width+'px;background-color:'+settings.windowBGColor+';border:'+settings.borderSize+'px solid '+settings.borderColor+';z-index:10001"><div id="DOMWindowContent" style="display:none"></div></div>');		
				//loader
				if(settings.loader && settings.loaderImagePath !== ''){
					$('.'+settings.anchoredClassName).append('<div id="DOMWindowLoader" style="width:'+settings.loaderWidth+'px;height:'+settings.loaderHeight+'px;"><img src="'+settings.loaderImagePath+'" /></div>');
					
				}

				if($.fn.draggable){
					if(settings.draggable){$('.' + settings.anchoredClassName).draggable({cursor:'move'});}
				}
				
				switch(settings.windowSource){
					case 'inline'://////////////////////////////// inline //////////////////////////////////////////
						$('.' + settings.anchoredClassName+" #DOMWindowContent").append($(settings.windowSourceID).children());
						$('.' + settings.anchoredClassName).unload(function(){// move elements back when you're finished
							$('.' + settings.windowSourceID).append( $('.' + settings.anchoredClassName+" #DOMWindowContent").children());				
						});
						showDOMWindow(settings.anchoredClassName);
					break;
					case 'iframe'://////////////////////////////// iframe //////////////////////////////////////////
						$('.' + settings.anchoredClassName+" #DOMWindowContent").append('<iframe frameborder="0" hspace="0" wspace="0" src="'+settings.windowSourceURL+'" name="DOMWindowIframe'+Math.round(Math.random()*1000)+'" style="width:100%;height:100%;border:none;background-color:#fff;" class="'+settings.anchoredClassName+'Iframe" ></iframe>');
						$('.'+settings.anchoredClassName+'Iframe').load(showDOMWindow(settings.anchoredClassName));
					break;
					case 'ajax'://////////////////////////////// ajax //////////////////////////////////////////	
						if(settings.windowHTTPType == 'post'){
							
							if(settings.windowSourceURL.indexOf("?") !== -1){//has a query string
								urlOnly = settings.windowSourceURL.substr(0, settings.windowSourceURL.indexOf("?"));
								urlQueryObject = urlQueryToObject(settings.windowSourceURL);
							}else{
								urlOnly = settings.windowSourceURL;
								urlQueryObject = {};
							}
							$('.' + settings.anchoredClassName+" #DOMWindowContent").load(urlOnly,urlQueryObject,function(){
								showDOMWindow(settings.anchoredClassName);
							});
						}else{
							if(settings.windowSourceURL.indexOf("?") == -1){ //no query string, so add one
								settings.windowSourceURL += '?';
							}
							$('.' + settings.anchoredClassName+" #DOMWindowContent").load(
								settings.windowSourceURL + '&random=' + (new Date().getTime()),function(){
								showDOMWindow(settings.anchoredClassName);
							});
						}
					break;
				}
				
			}else{//centered, fixed, absolute DOM window
				
				//overlay & modal
				if(settings.overlay){
					$('body').append('<div id="DOMWindowOverlay" style="z-index:10000;display:none;position:absolute;top:0;left:0;background-color:'+settings.overlayColor+';filter:alpha(opacity='+settings.overlayOpacity+');-moz-opacity: 0.'+settings.overlayOpacity+';opacity: 0.'+settings.overlayOpacity+';"></div>');
					if(shortcut.isIE6){//if IE 6
						$('body').append('<iframe id="DOMWindowIE6FixIframe"  src="blank.html"  style="width:100%;height:100%;z-index:9999;position:absolute;top:0;left:0;filter:alpha(opacity=0);"></iframe>');
						sizeIE6Iframe();
					}
					sizeOverlay();
					var $DOMWindowOverlay = $('#DOMWindowOverlay');
					$DOMWindowOverlay.fadeIn('fast');
					//if(!settings.modal){$DOMWindowOverlay.click(function(){$.closeDOMWindow();});}
				}
				
				//loader
				if(settings.loader && settings.loaderImagePath !== ''){
					$('body').append('<div id="DOMWindowLoader" style="z-index:10002;width:'+settings.loaderWidth+'px;height:'+settings.loaderHeight+'px;"><img src="'+settings.loaderImagePath+'" /></div>');
					centerLoader();
				}

				//add DOMwindow
				$('body').append('<div id="DOMWindow" style="background-repeat:no-repeat;'+settings.windowBGImage+';overflow:auto;padding:'+settings.windowPadding+'px;display:none;height:'+settings.height+'px;width:'+settings.width+'px;background-color:'+settings.windowBGColor+';border:'+settings.borderSize+'px solid '+settings.borderColor+'; position:absolute;z-index:10001"></div>');
				
				var $DOMWindow = $('#DOMWindow');
				//centered, absolute, or fixed
				switch(settings.positionType){
					case 'centered':
						centerDOMWindow();
						if(settings.height + 50 > shortcut.viewPortHeight()){//added 50 to be safe
							$DOMWindow.css('top', (settings.fixedWindowY + shortcut.scrollOffsetHeight()) + 'px');
						}
					break;
					case 'absolute':
						$DOMWindow.css({'top':(settings.positionTop+shortcut.scrollOffsetHeight())+'px','left':(settings.positionLeft+shortcut.scrollOffsetWidth())+'px'});
						if($.fn.draggable){
							if(settings.draggable){$DOMWindow.draggable({cursor:'move'});}
						}
					break;
					case 'fixed':
						fixedDOMWindow();
					break;
					case 'anchoredSingleWindow':
						var anchoredPositions = $(settings.anchoredSelector).position();
						var anchoredPositionX = anchoredPositions.left + settings.positionLeft;
						var anchoredPositionY = anchoredPositions.top + settings.positionTop;
						$DOMWindow.css({'top':anchoredPositionY + 'px','left':anchoredPositionX+'px'});
								
					break;
				}
				
				$(window).bind('scroll.DOMWindow',function(){
					if(settings.overlay){sizeOverlay();}
					if(shortcut.isIE6){sizeIE6Iframe();}
					if(settings.positionType == 'centered'){centerDOMWindow();}
					if(settings.positionType == 'fixed'){fixedDOMWindow();}
				});

				$(window).bind('resize.DOMWindow',function(){
					if(shortcut.isIE6){sizeIE6Iframe();}
					if(settings.overlay){sizeOverlay();}
					if(settings.positionType == 'centered'){centerDOMWindow();}
				});
				
				switch(settings.windowSource){
					case 'inline'://////////////////////////////// inline //////////////////////////////////////////
						$DOMWindow.append($(settings.windowSourceID).children());
						$DOMWindow.unload(function(){// move elements back when you're finished
							$(settings.windowSourceID).append($DOMWindow.children());				
						});
						showDOMWindow();
					break;
					case 'iframe'://////////////////////////////// iframe //////////////////////////////////////////
						$DOMWindow.append('<iframe frameborder="0" hspace="0" wspace="0" src="'+settings.windowSourceURL+'" name="DOMWindowIframe'+Math.round(Math.random()*1000)+'" style="width:100%;height:100%;border:none;background-color:#fff;" id="DOMWindowIframe" ></iframe>');
						$('#DOMWindowIframe').load(showDOMWindow());
					break;
					case 'ajax'://////////////////////////////// ajax //////////////////////////////////////////
						if(settings.windowHTTPType == 'post'){
							
							if(settings.windowSourceURL.indexOf("?") !== -1){//has a query string
								urlOnly = settings.windowSourceURL.substr(0, settings.windowSourceURL.indexOf("?"));
								urlQueryObject = urlQueryToObject(settings.windowSourceURL);
							}else{
								urlOnly = settings.windowSourceURL;
								urlQueryObject = {};
							}
							$DOMWindow.load(urlOnly,urlQueryObject,function(){
								showDOMWindow();
							});
						}else{
							if(settings.windowSourceURL.indexOf("?") == -1){ //no query string, so add one
								settings.windowSourceURL += '?';
							}
							$DOMWindow.load(
								settings.windowSourceURL + '&random=' + (new Date().getTime()),function(){
								showDOMWindow();
							});
						}
					break;
				}
				
			}//end if anchored, or absolute, fixed, centered
			
		};//end run()
		
		if(settings.eventType){//if used with $().
			return this.each(function(index){				  
				$(this).bind(settings.eventType,function(){
					run(this);
					return false;
				});
			});	
		}else{//else called as $.function
			run();
		}
		
	};//end function openDOMWindow
	
	//allow for public call, pass settings
	$.openDOMWindow = function(s){$.fn.openDOMWindow(s);};
	
})(jQuery);

function imposeMaxLength(Object, MaxLen)
{
	if(Object.value.length >= MaxLen) 
	{	
		Object.value = Object.value.substr(0,MaxLen);
		alert('Text input is limited by '+MaxLen+' symbols');
	}
	return (Object.value.length <= MaxLen);
}