(function($){
	$.contr_lookup = function()
	{
		alert('here1');
	};
	
	$.fn.contr_lookup = function()
	{
		return $(this);
	};

	$.contr_lookup.drawCell = function(jsonObj, rowIndex, cellIndex)
	{
		return jsonObj.table[rowIndex][cellIndex].value.lkold;
	};
	
	$.fn.contr_lookupMakeEditable = function(obj)
	{
		
		return $(this).each(
			function ()
			{
				$(this).bind(
					"click",
					function (e)
					{
						$this =$(this);
						$tr = $(this).parent();
						var tdIndex = $this.attr('cell_index');
						var trIndex = $tr.attr('row_index');
						if (!$('input',this).length)
						{
							
							var htmlText =
'<input type="hidden" name="tr'+trIndex+'_td'+tdIndex+'_lkid" id="tr'+trIndex+'_td'+tdIndex+'_lkid" value="'+ obj.model.table[trIndex][tdIndex].value.lkid +'" />'+
'<input type="hidden" name="tr'+trIndex+'_td'+tdIndex+'_lkold" id="tr'+trIndex+'_td'+tdIndex+'_lkold" value="'+ obj.model.table[trIndex][tdIndex].value.lkold +'" />'+
'<input type="hidden" name="tr'+trIndex+'_td'+tdIndex+'_lktp" id="tr'+trIndex+'_td'+tdIndex+'_lktp" value="'+ obj.model.table[trIndex][tdIndex].value.lktp +'" />'+
'<input type="hidden" name="tr'+trIndex+'_td'+tdIndex+'_lspf" id="tr'+trIndex+'_td'+tdIndex+'_lspf" value="'+ obj.model.table[trIndex][tdIndex].value.lspf +'" />'+
'<input type="hidden" name="tr'+trIndex+'_td'+tdIndex+'_mod" id="tr'+trIndex+'_td'+tdIndex+'_mod" value="'+ obj.model.table[trIndex][tdIndex].value.mod +'" />'+
'<input type="hidden" id="tr'+trIndex+'_td'+tdIndex+'_show" value="0" />'+
'<div class="lookupInput" id="tr'+trIndex+'_td'+tdIndex+'_div">'+
'<input class="inputClass" name="tr'+trIndex+'_td'+tdIndex+'" id="tr'+trIndex+'_td'+tdIndex+'" type="text" value="'+ obj.model.table[trIndex][tdIndex].value.lkold +'"  />'+
'<a '+
'href="javascript: openLookup(\'/_ui/common/data/LookupPage?lkfm='+ obj.model.table[trIndex][tdIndex].value.formid +'&lknm=tr'+trIndex+'_td'+tdIndex+'&lktp=\' + getElementByIdCS(\'tr'+trIndex+'_td'+tdIndex+'_lktp\').value,670,\'1\',\'&lksrch=\' + escapeUTF(getElementByIdCS(\'tr'+trIndex+'_td'+tdIndex+'\').value.substring(0, 80)))" '+
'id="tr'+trIndex+'_td'+tdIndex+'_lkwgt"  title="Carrier Name Lookup (New Window)">'+
'<img src="/s.gif" '+
'onclick=" setLastMousePosition(event);"  document.getElementById(\'tr'+trIndex+'_td'+tdIndex+'_show\').value = 1;'+
'id="tr'+trIndex+'_td'+tdIndex+'_img" alt="Carrier Name Lookup (New Window)" class="lookupIcon" title="Carrier Name Lookup (New Window)"/>'+
'</a>'+
'</div>';		

								$(this).html(htmlText)
								.find('#tr'+trIndex+'_td'+tdIndex)
								.animate({ width:"80%" }, {
									queue: true,
									duration: 100,
									complete: function ()
									{
										$(this).parent().trigger('focus')			
									}
								})
								
								/*
								.parent()
								.bind('blur', function (e){
									
									//$this = $(this);
									//$div = $this.parent();
									$div = $(this);
									$td = $div.parent();
									$tr = $td.parent();
										
									// getting new value
									var newValue = $('#tr'+trIndex+'_td'+tdIndex).val();
									var newValueId = $('#tr'+trIndex+'_td'+tdIndex+'_lkid').val();
																
									//obj.model.table[$tr.attr('row_index')][$td.attr('cell_index')].value = newValueId;
									obj.model.table[$tr.attr('row_index')][$td.attr('cell_index')].value.lkid = newValueId;
									obj.model.table[$tr.attr('row_index')][$td.attr('cell_index')].value.lkold = newValue;
									$(obj.params.divPath).find('table').trigger('update'); 
									if (curPopupWindow == null) 
									{
										$(this).animate(
											{ width:"1px" }, 
	 										{
												queue: true,
												duration: 100,
												complete: function () {
													$td.find('*').remove().end().html( newValue != '' ? newValue : '&nbsp;');
												}
											}
										);	
									}	
								})
								*/
								.bind('keypress', function (event) {
									var keynum;
									if (jQuery.browser.msie) // IE
									{
										keynum = event.keyCode;
									}
									else // Netscape/Firefox/Opera
									{
										keynum = event.which;
									}
	
									if (keynum == 13) {
										$(this).triggerHandler('blur');
										return false;
									};
								})
								
								.parent('#tr'+trIndex+'_td'+tdIndex+'_div')
								//.css("background", "yellow")
								.hover(
									function (){return null;},
									function ()
									{
										$this = $(this);
										$td = $this.parent();
										$tr = $td.parent();
											
										// getting new value
										var newValue = $('#tr'+trIndex+'_td'+tdIndex).val();
										var newValueId = $('#tr'+trIndex+'_td'+tdIndex+'_lkid').val();
																	
										//obj.model.table[$tr.attr('row_index')][$td.attr('cell_index')].value = newValueId;
										obj.model.table[$tr.attr('row_index')][$td.attr('cell_index')].value.lkid = newValueId;
										obj.model.table[$tr.attr('row_index')][$td.attr('cell_index')].value.lkold = newValue;
										$(obj.params.divPath).find('table').trigger('update'); 
										if (curPopupWindow == null) 
										{
											$(this).animate(
												{ width:"1px" }, 
		 										{
													queue: true,
													duration: 100,
													complete: function () {
													
														$td.find('*').remove().end().html( newValue != '' ? newValue : '&nbsp;');
													
													}
												}
											);	
										}	
												
									}
									
								)
								
								
	
						}//if (!$('input',this).length)
					}
				);
			}		
		);
	};	
	
	
/*
	$.contr_lookup = function()
	{
		this.drawCell = function (param)
		{
			alert('here');
//			return param.type;
		};
	};
	
*/
	
})(jQuery);  