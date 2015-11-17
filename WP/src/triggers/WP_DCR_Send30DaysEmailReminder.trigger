trigger WP_DCR_Send30DaysEmailReminder on DCR_Process_Log__c (before update, after update) {
 System.debug('DEBUG:WP_DCR_Send30DaysEmailReminder'); 
 if(trigger.isUpdate){
 	DCR_Process_Log__c[] recs = Trigger.new;
 	List<DCR_Process_Log__c> thisrecs = new List<DCR_Process_Log__c>();
 	//recs = trigger.new;
 	String dealName='';
 	String dealClosedDate='';
  	String[] whoClosedUserId;
  		
 	String[] empId;
 	String[] uName;
 	String[] uEmail;
 	
 	String[] userId;
 	String[] userEmail;
 	String[] userName;
 	String[] alternateEmail;
 	String[] alternateName;

 	Boolean IsValidUser =false;
 	//Now get all the values..and check if field --> Time_Expired__c = True
 	thisrecs = recs;
 	String deal_id = thisrecs[0].Deal__c;	
 	//closeEmail =  new String[] {thisrecs[0].Deal_Closed_Email__c} ;
 	
 	system.debug('DEBUG:AR1:WP_DCR_Send30DaysEmailReminder-->started' );
 	if (trigger.isAfter){
 		if (thisrecs[0].Time_Expired__c && !thisrecs[0].Reminder_Sent__c && thisrecs[0].DCR_Sent_On__c == null) {
 			whoClosedUserId = new String[] {thisrecs[0].CreatedById};
 			
 			List<Deal__c> deal = [SELECT Id, Deal__c.Stage__c,Name,Deal_Closed_Date__c
            FROM Deal__c 
            WHERE Id = :deal_id 
            limit 1
            ];		
			//Check if the status is still closed -otherwise don't sent email 
			if (deal[0].Stage__c=='Committed-Deal Closed'){            
		 		dealName =deal[0].Name;
		 		dealClosedDate = String.valueOf(deal[0].Deal_Closed_Date__c);
		 		
		 		List<Deal_Team__c> deal_team_list = [SELECT Id, Deal__c, Employee__c, Role__c, Employee__r.Id, Employee__r.Email, Employee__r.Full_Name__c
            	FROM Deal_Team__c
            	WHERE Deal__c =: deal_id
            	ORDER BY Role__c ASC
            	];
	       		Integer list_count=0;
	       		Integer found=0;
	       		//Check if the person who closed the deal is still a member of the deal team?
	       		//Need to alter the logic to get the person by Employee.Id from Contact and User_ID__c from Deal Team NOT by email
	       		System.debug('deal_team_list.size()-->' + deal_team_list.size());
	       		//STOP THIS LOGIC FOR NOW, DONT CHECK FOR USER NOT BEING LISTED iN THE DEAL TEAM 
	       		for(Deal_Team__c team_item:deal_team_list) {
	         		IsValidUser = false;
	         		empId = new String[] {team_item.Employee__r.Id};    
	         		System.debug('empID=' + empId);
	         		//Also Check if this Person exists as IsActive User or NOT?
	       			List<User> accId = [SELECT Id, Name, Email, IsActive, Related_Contact_Id__c
	       			FROM User 
	       			WHERE (Related_Contact_Id__c=:empId) AND (IsActive=true) limit 1 ];       
	       			   			
	       			if (accId.size()>0){
	       				IsValidUser = true;
	       				userId =    new String[] {accId[0].Id};
	       				userEmail = new String[] {accId[0].Email};
	       				userName =  new String[] {accId[0].Name};	  
	       				System.debug(list_count + ') TEAM MEMBERS AVAIL IN THE DEAL-->' + userId +' email-->' + userEmail + ' name->' + userName);
	       				if (userEmail!=null){
	       					if (whoClosedUserId==userId){
	         					found = 1;  	
	         					System.debug('FOUND TEAM MEMBER ID WHO CLOSED THE DEAL-->' + empId +' email-->' + userEmail + ' name->' + userName );
	         					break;		       						     						
	       					}else{
	       						alternateEmail= userEmail;
	       						alternateName = userName;
	       						System.debug('ALTERNATE TEAM MEMBER ID -->' + empId +' email-->' + alternateEmail + ' alternateName->' + alternateName);
	       					}	       			
	       				}     	
	         			list_count++;
	       			}
	       		}//end for loop Deal Team Members    		
	       		
	         	if (found==1 & IsValidUser){
	         		uEmail = userEmail;
	         		uName = userName;
	         	}//if found 		
	         	else {
	         		uEmail = alternateEmail;
	         		uName = alternateName;
	         	}
				if ( uEmail!=null & uName!=null ){
					System.debug('WP_DCR_Send30DaysEmailReminder.trigger-EmailSentTo->' + uEmail + ' name ' + uName);
					
				 	String fullDealURL = 'https://na9.salesforce.com/' + deal_id;
					String template = '<br><p><font face="verdana">On ' + dealClosedDate + ', the stage of <b>' + dealName +'</b> was changed to <b>Committed-Deal Closed.</b></face></p>';
					template+='<p><font face="verdana"><br>Please be reminded that at the closing of a new investment, a one page Deal Closing Report is to be submitted.</face></p>';
					template+='<p><font face="verdana"><br>Please make sure that all relevant deal team members are aware of this requirement.</face></p>';
					template+='<p><font face="verdana"><br>The Deal Closing Report and other investment tracking reports can be accessed by selecting <strong>Edit</strong> from the <strong>My Deals</strong> page in Salesforce.</face></p>';
					template+= '<p><font face="verdana"><br>For more details, click on the following DCR link to the deal page - '+ fullDealURL +'<br><br></face></p>';
					
					String subject ='30 days - Reminder to submit a Deal Closing Report';
					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
					mail.setToAddresses(uEmail);   
					mail.setSenderDisplayName('System Administrator<noreply@warburgpincus.com>');
					mail.setSubject(subject);
					String[] bccEmail = new String[]{'ananta.risal@gmail.com'};
	     			mail.setBccAddresses(bccEmail);
					mail.setUseSignature(false);	  
					List<String> args = new List<String>();
					args.add(dealName); 
					String formattedHtml = String.format(template, args);
					mail.setHtmlBody(formattedHtml);
					Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	 
				}//end not null
			}//end Stage__c
 		}//Time_Expired__c=True
 	}//trigger.isAfter  		
  } //trigger.IsUpdate
}//trigger