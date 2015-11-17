(function($){
	
	$.contr_textO = function()
	{
		alert('here1');
	};
	
	$.fn.contr_textO = function()
	{
		return $(this);
	};	
	
	$.contr_textO.drawCell = function(jsonObj, rowIndex, cellIndex)
	{
		return jsonObj.table[rowIndex][cellIndex].value;
	};
	
	$.fn.contr_textOMakeEditable = function(obj){};	
	
})(jQuery);  
(function ($) {
    $.contr_dateO = function () {
        alert("here1")
    };
    $.fn.contr_dateO = function () {
        return $(this)
    };
    $.contr_dateO.drawCell = function (jsonObj, rowIndex, cellIndex) {     
        var txt = '<input type="text" id="date_'+rowIndex+'_'+cellIndex+'" value="' + jsonObj.table[rowIndex][cellIndex].value + '" style="width:70px;color:#111111;border:1px solid #ccc;font-size:12px;padding:0 1px 2px 1px;" ';
		if(jsonObj.fields[cellIndex].validator != null) txt += ' validator="'+jsonObj.fields[cellIndex].validator.type+'" validatorMinChars="'+jsonObj.fields[cellIndex].validator.minChars+'"  validatorMesssage="'+jsonObj.fields[cellIndex].validator.message+'" ';
		txt +=' onfocus="';
		if(jsonObj.fields[cellIndex].onfocusFunction != null) txt += jsonObj.fields[cellIndex].onfocusFunction;
		if(jsonObj.table[rowIndex][cellIndex].onfocusFunction != null) txt += jsonObj.table[rowIndex][cellIndex].onfocusFunction;
		txt +='savedateO('+rowIndex+', '+cellIndex+');"/>';
		txt +='<div id="tr'+rowIndex+'_td'+cellIndex+'errrordiv" style="color:red;"></div><script>savedateO('+rowIndex+', '+cellIndex+')</script>';
		return txt;
    };
    $.fn.contr_dateOMakeEditable = function (obj) {
		/*
        return $(this).each(function () {
            $(this).bind("click", function (e) {
                $this = $(this);
                $tr = $(this).parent();
                var tdIndex = $this.attr("cell_index");
                var trIndex = $tr.attr("row_index");
                savedateO(trIndex, tdIndex);
            })
        })
		*/
    }
})(jQuery);


(function($){
	$.contr_smplselectO = function()
	{
		alert('here1');
	};
	
	$.fn.contr_smplselectO = function()
	{
		return $(this);
	};	
	
	$.getFieldLabel = function (fieldObj, value)
	{
		var label = '';
		
		$.each(fieldObj.values, 
			function ()
			{
				if (this.value == value)
				{
					label = this.label;
					return false;
				}
			}
		);
		
		return label; 
	}
	
	$.contr_smplselectO.drawCell = function(jsonObj, rowIndex, cellIndex)
	{
		var selectHtml = '';
		if(jsonObj.table[rowIndex][cellIndex].values != null)
		{
			$.each(jsonObj.table[rowIndex][cellIndex].values, function(index){
					selectHtml += '<option '+( this.value == jsonObj.table[rowIndex][cellIndex].value ? 'selected="true"': '')+'value="' + this.value + '">' + this.label + '</option>';
			});
		}
		if(jsonObj.fields[cellIndex].values != null)
		{
			$.each(jsonObj.fields[cellIndex].values, function(index){
					selectHtml += '<option '+( this.value == jsonObj.table[rowIndex][cellIndex].value ? 'selected="true"': '')+'value="' + this.value + '">' + this.label + '</option>';
			});
		}
		var txt = '<select class="selectClass" id="select_'+rowIndex+'_'+cellIndex+'" style="color:#111111; ';
		if(jsonObj.fields[cellIndex].style != null) txt += ' '+jsonObj.fields[cellIndex].style+'" ';
		else txt +=' width:150px;_width:150px;/width:150px; " ';
		if(jsonObj.fields[cellIndex].validator != null) txt += ' validator="'+jsonObj.fields[cellIndex].validator.type+'" validatorMinChars="'+jsonObj.fields[cellIndex].validator.minChars+'"  validatorMesssage="'+jsonObj.fields[cellIndex].validator.message+'" ';
		txt +=' onblur="';
		//if(jsonObj.fields[cellIndex].onchangeFunction != null) txt += jsonObj.fields[cellIndex].onchangeFunction;
		//if(jsonObj.table[rowIndex][cellIndex].onchangeFunction != null) txt += jsonObj.table[rowIndex][cellIndex].onchangeFunction;
		txt +='" onfocus="';
		if(jsonObj.fields[cellIndex].onfocusFunction != null) txt += jsonObj.fields[cellIndex].onfocusFunction;
		if(jsonObj.table[rowIndex][cellIndex].onfocusFunction != null) txt += jsonObj.table[rowIndex][cellIndex].onfocusFunction;
		txt +='" >'+selectHtml+'</select><div id="tr'+rowIndex+'_td'+cellIndex+'errrordiv" style="color:red;"></div>';
		return txt;
	};
	
	$.fn.contr_smplselectOMakeEditable = function(obj)
	{
		return $(this).each(
			function ()
			{
				$(this).bind(
					"click change",
					function (e)
					{
						var $td = $(this);
						var $tr = $td.parent();
						var tdIndex = $td.attr('cell_index');
						var trIndex = $tr.attr('row_index');
						$('#tr'+trIndex+'_td'+tdIndex+'errrordiv').html('');
						$td.find('select').bind('change', function()
						{
							var newValue = $(this).val();
							//try	{
							obj.model.table[trIndex][tdIndex].value = newValue; 
							if(jsonTable2.model.fields[tdIndex].validator != null && jsonTable2.model.fields[tdIndex].validator.message3 != null)	
							{
								$.each(jsonTable2.model.table, function (rowIndex, rowValue) 
								{
									if (newValue == jsonTable2.model.table[rowIndex][tdIndex].value && rowIndex != trIndex) $('#tr'+trIndex+'_td'+tdIndex+'errrordiv').html(jsonTable2.model.fields[tdIndex].validator.message3);
								});
							}
							
							$(obj.params.divPath).find('table').trigger('update'); 
							//}catch(Exception){}
						})
					}
				)
				.bind("keypress keydown blur", function (event) {$(this).triggerHandler("change");})
			}		
		);
	};	
	
})(jQuery);  

(function($){
	$.contr_textareaO = function()
	{
		alert('here1');
	};
	
	$.fn.contr_textareaO = function()
	{
		return $(this);
	};	

	$.contr_textareaO.drawCell = function(jsonObj, rowIndex, cellIndex)
	{
		var txt = '<textarea class="inputClass inputClassT" id="textarea_'+rowIndex+'_'+cellIndex+'"  style="color:#111111; ';
		if(jsonObj.fields[cellIndex].style != null) txt += ' '+jsonObj.fields[cellIndex].style+'" ';
		else txt +=' width:420px;height:33px;" ';
		txt +=' onfocus="';
		if(jsonObj.fields[cellIndex].onfocusFunction != null) txt += jsonObj.fields[cellIndex].onfocusFunction;
		if(jsonObj.table[rowIndex][cellIndex].onfocusFunction != null) txt += jsonObj.table[rowIndex][cellIndex].onfocusFunction;
		txt +='" ';
		if(jsonObj.fields[cellIndex].validator != null) txt += ' validator="'+jsonObj.fields[cellIndex].validator.type+'" validatorMinChars="'+jsonObj.fields[cellIndex].validator.minChars+'"  validatorMesssage="'+jsonObj.fields[cellIndex].validator.message+'" ';
		if(jsonObj.fields[cellIndex].maxLength != null) txt +=' onkeypress="return imposeMaxLength(this, '+jsonObj.fields[cellIndex].maxLength+');" ';
		if(jsonObj.fields[cellIndex].maxLength != null) txt +=' onkeyup = "return imposeMaxLength(this, '+jsonObj.fields[cellIndex].maxLength+');" ';
		txt +=' >'+ jsonObj.table[rowIndex][cellIndex].value +'</textarea><div id="tr'+rowIndex+'_td'+cellIndex+'errrordiv" style="color:red;"></div>';
		return txt;
	};
	

$.fn.contr_textareaOMakeEditable = function(obj)
	{
		return $(this).each(
			function ()
			{
				$(this).find('textarea').blur(
					function (e)
					{
						var $td = $(this).parent();
						var $tr = $td.parent();
						var tdIndex = $td.attr('cell_index');
						var trIndex = $tr.attr('row_index');
					
						$('#tr'+trIndex+'_td'+tdIndex+'errrordiv').html('');
						var newValue = $('#textarea_'+trIndex+'_'+tdIndex).val();
						newValue = newValue.replace(/\"/g,'&quot;')
						if(obj.model.fields[tdIndex].maxLength != null)obj.model.table[trIndex][tdIndex].value = newValue.substr(0,obj.model.fields[tdIndex].maxLength);
						else obj.model.table[trIndex][tdIndex].value = newValue.substr(0,255);
						$(obj.params.divPath).find('table').trigger('update'); 	
					}
				);
			}		
		);
	};		
	
})(jQuery);  

(function($){
	$.contr_rtextO = function()
	{
		alert('here1');
	};
	
	$.fn.contr_rtextO = function()
	{
		return $(this);
	};	

	$.contr_rtextO.drawCell = function(jsonObj, rowIndex, cellIndex)
	{
		var txt = '<input class="inputClass" type="text" value="' + jsonObj.table[rowIndex][cellIndex].value + '" id="rtext_'+rowIndex+'_'+cellIndex+'" style="color:#111111;';
		if(jsonObj.fields[cellIndex].style != null) txt += ' '+jsonObj.fields[cellIndex].style+' ';
		txt +=' " ';
		if(jsonObj.fields[cellIndex].validator != null) txt += ' validator="'+jsonObj.fields[cellIndex].validator.type+'" validatorMinChars="'+jsonObj.fields[cellIndex].validator.minChars+'"  validatorMesssage="'+jsonObj.fields[cellIndex].validator.message+'" ';
		txt +=' onfocus="';
		if(jsonObj.fields[cellIndex].onfocusFunction != null) txt += jsonObj.fields[cellIndex].onfocusFunction;
		if(jsonObj.table[rowIndex][cellIndex].onfocusFunction != null) txt += jsonObj.table[rowIndex][cellIndex].onfocusFunction;
		txt +='" ';
		if(jsonObj.fields[cellIndex].maxLength != null) txt +=' maxlength="'+jsonObj.fields[cellIndex].maxLength+'" ';
		txt +=' ><div id="tr'+rowIndex+'_td'+cellIndex+'errrordiv" style="color:red;"></div>';
		return txt;
	};
	

$.fn.contr_rtextOMakeEditable = function(obj)
	{
		return $(this).each(
			function ()
			{
				$(this).find('input').blur(
					function (e)
					{
						var $td = $(this).parent();
						var $tr = $td.parent();
						var tdIndex = $td.attr('cell_index');
						var trIndex = $tr.attr('row_index');
						$('#tr'+trIndex+'_td'+tdIndex+'errrordiv').html('');
						var newValue = $('#rtext_'+trIndex+'_'+tdIndex).val();
						newValue = newValue.replace(/\"/g,'');
						obj.model.table[trIndex][tdIndex].value = newValue;
						$(obj.params.divPath).find('table').trigger('update'); 	
					}
				);
			}		
		);
	};		
})(jQuery);

(function($){
	$.contr_rtextO2 = function()
	{
		alert('here1');
	};
	
	$.fn.contr_rtextO2 = function()
	{
		return $(this);
	};	

	$.contr_rtextO2.drawCell = function(jsonObj, rowIndex, cellIndex)
	{
		var txt = '<input class="inputClass" type="text" value="' + jsonObj.table[rowIndex][cellIndex].value + '" id="rtext2_'+rowIndex+'_'+cellIndex+'" style="color:#111111;';
		if(jsonObj.fields[cellIndex].style != null) txt += ' '+jsonObj.fields[cellIndex].style+' ';
		txt +=' " ';
		if(jsonObj.fields[cellIndex].validator != null) txt += ' validator="'+jsonObj.fields[cellIndex].validator.type+'" validatorMinChars="'+jsonObj.fields[cellIndex].validator.minChars+'"  validatorMesssage="'+jsonObj.fields[cellIndex].validator.message+'" ';
		txt +=' onfocus="';
		if(jsonObj.fields[cellIndex].onfocusFunction != null) txt += jsonObj.fields[cellIndex].onfocusFunction;
		if(jsonObj.table[rowIndex][cellIndex].onfocusFunction != null) txt += jsonObj.table[rowIndex][cellIndex].onfocusFunction;
		txt +='" ';
		if(jsonObj.fields[cellIndex].maxLength != null) txt +=' maxlength="'+jsonObj.fields[cellIndex].maxLength+'" ';
		txt +=' ><div id="tr'+rowIndex+'_td'+cellIndex+'errrordiv2" style="color:red;"></div>';
		return txt;
	};
	

$.fn.contr_rtextO2MakeEditable = function(obj)
	{
		return $(this).each(
			function ()
			{
				$(this).find('input').blur(
					function (e)
					{
						var $td = $(this).parent();
						var $tr = $td.parent();
						var tdIndex = $td.attr('cell_index');
						var trIndex = $tr.attr('row_index');
						$('#tr'+trIndex+'_td'+tdIndex+'errrordiv2').html('');
						var newValue = $('#rtext2_'+trIndex+'_'+tdIndex).val();
						newValue = newValue.replace(/\"/g,'');
						obj.model.table[trIndex][tdIndex].value = newValue;
						$(obj.params.divPath).find('table').trigger('update'); 	
					}
				);
			}		
		);
	};		
})(jQuery);

(function($){
	$.contr_rtextOMultyTable = function()
	{
		alert('here1');
	};

	$.fn.contr_rtextOMultyTable = function()
	{
		return $(this);
	};

	$.contr_rtextOMultyTable.drawCell = function(jsonObj, rowIndex, cellIndex, tableNumber)
	{
		var txt = '<input class="inputClass" type="text" value="' + jsonObj.table[rowIndex][cellIndex].value + '" id="rtext_'+tableNumber+'_'+rowIndex+'_'+cellIndex+'" style="color:#111111;';
		if(jsonObj.fields[cellIndex].style != null) txt += ' '+jsonObj.fields[cellIndex].style+' ';
		txt +=' " ';
		if(jsonObj.fields[cellIndex].validator != null) txt += ' validator="'+jsonObj.fields[cellIndex].validator.type+'" validatorMinChars="'+jsonObj.fields[cellIndex].validator.minChars+'"  validatorMesssage="'+jsonObj.fields[cellIndex].validator.message+'" ';
		txt +=' onfocus="';
		if(jsonObj.fields[cellIndex].onfocusFunction != null) txt += jsonObj.fields[cellIndex].onfocusFunction;
		if(jsonObj.table[rowIndex][cellIndex].onfocusFunction != null) txt += jsonObj.table[rowIndex][cellIndex].onfocusFunction;
		txt +='" ><div id="t'+tableNumber+'_tr'+rowIndex+'_td'+cellIndex+'errrordiv" style="color:red;"></div>';
		return txt;
	};


$.fn.contr_rtextOMultyTableMakeEditable = function(obj, tableNumber)
	{
		return $(this).each(
			function ()
			{
				$(this).bind(
					"keyup",
					function (e)
					{
						var $td = $(this);
						var $tr = $td.parent();
						var tdIndex = $td.attr('cell_index');
						var trIndex = $tr.attr('row_index');
						$('#t'+tableNumber+'_tr'+trIndex+'_td'+tdIndex+'errrordiv').html('');
						var newValue = $('#rtext_'+tableNumber+'_'+trIndex+'_'+tdIndex).val();
                                                //alert('rtext_'+tableNumber+'_'+trIndex+'_'+tdIndex);
						newValue = newValue.replace(/\"/g,'&quot;');
						obj.model.table[trIndex][tdIndex].value = newValue.substr(0,255);
						$(obj.params.divPath).find('table').trigger('update');
					}
				);
			}
		);
	};
})(jQuery);


(function($){
	$.contr_lookupO2 = function()
	{
		alert('here1');
	};
	
	$.fn.contr_lookupO2 = function()
	{
		return $(this);
	};

	$.contr_lookupO2.drawCell = function(jsonObj, trIndex, tdIndex)
	{
var txt  = '<input class="inputClass inputlookupT" style="color:#111111;"  autocomplete="off" '+
//' onfocus="alternativelookupO('+trIndex+', '+tdIndex+',\''+jsonObj.table[trIndex][tdIndex].value.obj+'\');" '+ 
//' onblur="checklookupO('+trIndex+', '+tdIndex+',\''+jsonObj.table[trIndex][tdIndex].value.obj+'\');"  '+
' onfocus="savelookupO(this, '+trIndex+', '+tdIndex+');"  '+
' onchange="checklookupO('+trIndex+', '+tdIndex+',\''+jsonObj.table[trIndex][tdIndex].value.obj+'\');" '+ 
'name="tr'+trIndex+'_td'+tdIndex+'" id="tr'+trIndex+'_td'+tdIndex+'" type="text" value="'+ jsonObj.table[trIndex][tdIndex].value.lkold +'"  />'+
'<a '+
'href="javascript: openLookup(\'/_ui/common/data/LookupPage?lkfm='+ jsonObj.table[trIndex][tdIndex].value.formid +'&lknm=tr'+trIndex+'_td'+tdIndex+'&lktp=\' + getElementByIdCS(\'tr'+trIndex+'_td'+tdIndex+'_lktp\').value,'+
'670,\'1\',\'&lksrch=\' + escapeUTF(getElementByIdCS(\'tr'+trIndex+'_td'+tdIndex+'\').value.substring(0, 80)));" '+
'id="tr'+trIndex+'_td'+tdIndex+'_lkwgt"  title="Carrier Name Lookup (New Window)">'+
'<img src="/s.gif" '+
'onclick=" $(\'#tr'+trIndex+'_td'+tdIndex+'_show\').val(1);setLastMousePosition(event);" '+
'id="tr'+trIndex+'_td'+tdIndex+'_img" alt="Carrier Name Lookup (New Window)" class="lookupIcon lookupIconT" title="Carrier Name Lookup (New Window)"/>'+
'</a>'+
'</div>'+
'<div  id="tr'+trIndex+'_td'+tdIndex+'list_example" style="position:absolute;display:none;width:170px;background-color: #FFFFFF;border: 1px solid #CCCCCC;padding:0px 0px 3px 3px;" ></div>'+
'<span style="display:none;padding-top:5px;" id="tr'+trIndex+'_td'+tdIndex+'loading"><img src="/img/loading.gif"/></span>'+
'<div id="tr'+trIndex+'_td'+tdIndex+'errrordiv" style="color:red;z-index:100;"></div>'+
'<input type="hidden" name="tr'+trIndex+'_td'+tdIndex+'_lkid" id="tr'+trIndex+'_td'+tdIndex+'_lkid" value="'+ jsonObj.table[trIndex][tdIndex].value.lkid +'" ';
if(jsonObj.fields[tdIndex].validator != null) txt += 'validator="'+jsonObj.fields[tdIndex].validator.type+'" validatorMinChars="'+jsonObj.fields[tdIndex].validator.minChars+'"  validatorMesssage="'+jsonObj.fields[tdIndex].validator.message+'" ';
txt += ' />'+
'<input type="hidden" name="tr'+trIndex+'_td'+tdIndex+'_lkold" id="tr'+trIndex+'_td'+tdIndex+'_lkold" value="'+ jsonObj.table[trIndex][tdIndex].value.lkold +'" />'+
'<input type="hidden" name="tr'+trIndex+'_td'+tdIndex+'_lktp" id="tr'+trIndex+'_td'+tdIndex+'_lktp" value="'+ jsonObj.table[trIndex][tdIndex].value.lktp +'" />'+
'<input type="hidden" name="tr'+trIndex+'_td'+tdIndex+'_lspf" id="tr'+trIndex+'_td'+tdIndex+'_lspf" value="'+ jsonObj.table[trIndex][tdIndex].value.lspf +'" />'+
'<input type="hidden" name="tr'+trIndex+'_td'+tdIndex+'_mod" id="tr'+trIndex+'_td'+tdIndex+'_mod" value="'+ jsonObj.table[trIndex][tdIndex].value.mod +'" />'+
'<input type="hidden" id="tr'+trIndex+'_td'+tdIndex+'_show" value="0" />';
return txt;
};
	
	$.fn.contr_lookupO2MakeEditable = function(obj)	
	{
		return $(this).each(
			function ()
			{
				$(this).bind(
					"click",
					function (e)
					{
						var $td = $(this);
						var $tr = $td.parent();
						var tdIndex = $td.attr('cell_index');
						var trIndex = $tr.attr('row_index');
						$td.hover(
								function (){return null;},
								function ()
								{
										var newValue = $('#tr'+trIndex+'_td'+tdIndex).val();
										var newValueId = $('#tr'+trIndex+'_td'+tdIndex+'_lkid').val();
										obj.model.table[trIndex][tdIndex].value.lkid = newValueId;
										obj.model.table[trIndex][tdIndex].value.lkold = newValue;
										$(obj.params.divPath).find('table').trigger('update'); 
								}
							)
					}
				);
			}		
		);
	};	
	
})(jQuery);  
