		/* jQuery bits */
		modalWidth = 700;
		
		$.noConflict();
		
		jQuery(document).ready(function($){
			$('a.users-link').live('click', function(e){
				e.preventDefault();
				
				var id = $(this).attr('id');
				
				if(e.type == 'click'){
					$('#list-'+id).dialog({
						width: modalWidth,
						resizable: false
					});
					if($(this).data('table-loaded')==null){
						$('#list-'+id+' > table').dataTable({"bJQueryUI":true ,
									 "sPaginationType": "full_numbers"});
						$(this).data('table-loaded','1');
					}
				} /*else if(e.type == 'click'){
					multiUserModal();	
					$('#user-group-' + id).show().children().show();
				}else{
					$('#list-'+id).hide();
				} */
			});
			
			/*
			$('a.show-all-users').live('click', function(e){
				e.preventDefault();
				
				multiUserModal();
				var id = $(this).attr('id').replace('show-all-users-','');
				$('#user-group-'+id).show().children().show();
			});*/
			
			/* The handlers for the table that contains all users */
			
			$('#all-users-container > table').dataTable({"bJQueryUI":true ,
		 		"sPaginationType": "full_numbers"});
			 					
			$('a#show-all-link').click(function(e){
				e.preventDefault();			 	
			 	
			 	$('#all-users-container').dialog({
					width: modalWidth,
					resizable: false
				});
			});
			
			/*
			function multiUserModal(){
				$('#modal-window-container').dialog({
					modal: true,
					width: 600,
					resizable: false
				});
				
				$('#modal > div').hide();
								
			} */
			
			/*$('.user-list').live('mouseenter mouseleave', function(e){
				if(e.type == 'mouseenter'){
					$(this).show();
				}else if (e.type == 'mouseleave'){
					$(this).hide();
				}
			});
			
			$('a.user-link').live('click',function(e){
				e.preventDefault();
				
				var id = $(this).attr('id');
				
				$('#modal-window-container').dialog({
					modal: true,
					width: 300,
					resizable: false
				});
				
				$('#modal > div > div').hide();
				$('#user-' + id).show().parent().show();				
			});*/
			
			$('.config-btn').live('mouseenter mouseleave', function(e){
				if(e.type == 'mouseenter'){
					$(this).siblings('ul.role-menu').show();
				}else if (e.type == 'mouseleave'){
					$(this).siblings('ul.role-menu').hide();
				}
			});
			
			$('ul.role-menu').live('mouseenter mouseleave',function(e){
				if(e.type == 'mouseenter'){
					$(this).show();
				}else if (e.type == 'mouseleave'){
					$(this).hide();
				}
			});
			
		});