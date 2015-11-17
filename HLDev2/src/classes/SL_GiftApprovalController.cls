/**  
* \arg ClassName        : SL_GiftApprovalController
* \arg JIRATicket       : HL-37
* \arg CreatedOn        : 01/NOV/2014
* \arg LastModifiedOn   : 19/NOV/2014
* \arg CreatededBy      : Edward Rivera
* \arg ModifiedBy       : -
* \arg Description      : Controller class for SL_GiftApproval
*/
public with sharing class SL_GiftApprovalController {
    /* Start - Variables */
	// list of gifts used to control the displayed list, based on query
	public List<SL_Gift> giftList {get; set;}
    // determines whether pending, approved, or denied gifts are displayed
    public String viewType {get; set;}
    // determines what year gifts are displayed, by year
    public Integer yearFilter {get; set;}
    // last name filter for gifts displayed
    public String nameFilter {get; set;}
    public String approvalComment {get; set;}
    /* End - Variables */
    /* Start - Constructor */
	public SL_GiftApprovalController() {     
		viewType = 'Pending';
		yearFilter = Date.Today().Year();
		nameFilter = '';
		searchGifts();
	}
    /* End - Constructor */
    /*
        @MethodName : getApprovalOptions 
        @param      : 
        @Description: This method is called upon page load to fill in picklist values
    */
	public List<SelectOption> getApprovalOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Pending','Pending')); 
        options.add(new SelectOption('Approved','Approved')); 
        options.add(new SelectOption('Denied','Denied'));      
        return options; 
    }
    /*
        @MethodName : getYearFilterOptions
        @param      : 
        @Description: This method is called upon page load to fill in picklist values for year filter; last 5 years are added
    */
    public List<SelectOption> getYearFilterOptions() {
        List<SelectOption> years = new List<SelectOption>();
        Integer curYear = Date.Today().Year();
        for (Integer ii = 0; ii < 5; ii++){
            years.add(new SelectOption(String.valueOf(curYear-ii),String.valueOf(curYear-ii)));
        }

        return years;
    }
    /*
        @MethodName : searchGifts
        @param      : 
        @Description: Returns a list of gifts that match the filter critera
    */
    public PageReference searchGifts() {
        giftList = new List<SL_Gift>();
        String filter = nameFilter+'%';
        List<SL_GiftRecipient> withGifts = new List<SL_GiftRecipient>();
        for(Contact contact: [SELECT Id,
        							 Name, 
        							 Account.Name, 
        							 (SELECT Id,
        							 		 Name,
        							 		 CreatedDate,
        							 		 Gift_Value__c,
        							 		 Approved__c,
        							 		 Desired_Date__c,
        							 		 Recipient__r.Name,
        							 		 Submitted_For__r.Name,
                                             Currency__c
        							 FROM Gifts__r 
        							 WHERE CALENDAR_YEAR(Desired_Date__c)=:yearFilter 
        							  ) 
        					 FROM Contact 
        					 WHERE Id IN (SELECT Recipient__c 
        					 			 FROM Gift__c 
        					 			 WHERE Gift_Value__c > 0) 
        					 AND Lastname 
        					 LIKE :filter]) { 
            withGifts.add(new SL_GiftRecipient(contact));
        }
        
        for(SL_GiftRecipient recipient: withGifts) {
            if (!recipient.recipient.Gifts__r.isEmpty()) {
                for(Gift__c eachGift: recipient.recipient.Gifts__r) {
                	// need to query all gifts for the recipient to get YTD total, so don't add this to the query above
        			//AND Approved__c=:viewType
                	if (eachGift.Approved__c==viewType){
                		giftList.add(new SL_Gift(eachGift, recipient.GiftPrevYTD+eachGift.Gift_Value__c, recipient.GiftPrevYTD, recipient)); 
                	} 
                }
            }
        
        }
        return null;
    }
    /*
        @MethodName : approveSelectedGifts
        @param      : 
        @Description: Approves the selected gifts
    */
    public PageReference approveSelectedGifts() {
        processSelectedGifts('Approve');
        return null;
    }
    /*
        @MethodName : denySelectedGifts
        @param      : 
        @Description: Denies the selected gifts
    */
    public PageReference denySelectedGifts() {
        processSelectedGifts('Deny');
        return null;
    }
    /*
        @MethodName : processSelectedGifts
        @param      : 
        @Description: Helper method for approve/denySelectedGifts which performs the logic to update the gifts and perform validation
    */
    public void processSelectedGifts(string action) {
        try { 
            List<Gift__c> selectedGifts = new List<Gift__c>();
            Map<SL_GiftRecipient, Decimal> recipientToYTD = new Map<SL_GiftRecipient, Decimal>();
            // needs to be true if a given recipient has gone over the yearly limit, currently only catches single gifts
            Set <SL_GiftRecipient> recipientsOver = new Set<SL_GiftRecipient>();
            for(SL_Gift Gift: giftList) {
                if(Gift.selected == true) {
                    selectedGifts.add(Gift.gift);
                    if (!recipientToYTD.keyset().contains(Gift.recipient)){
                        recipientToYTD.put(Gift.recipient, Gift.GiftYTD);
                    }
                    else{
                        recipientToYTD.put(Gift.recipient, recipientToYTD.get(Gift.recipient)+Gift.Gift.Gift_Value__c);
                    }
                    if(recipientToYTD.get(Gift.recipient)>100||(recipientToYTD.get(Gift.recipient)>35&&Gift.gift.Currency__c=='Euro (in France)' )){
                        recipientsOver.add(Gift.recipient);
                    }
                }
            }

            if (selectedGifts.isEmpty()) {
                System.debug(LoggingLevel.ERROR,'No gifts selected.');
                throw new SL_GiftLogException('You must select at least one gift to '+action.toLowercase()+'.');
            }
            else if (!recipientsOver.isEmpty()&&action=='Approve'&&approvalComment==''){
                String validationError = 'You MUST enter an Approval Comment to exceed the yearly limit.  Recipients exceeding yearly limit: ';
                List <String> errorMessages = new List<String>();
                for (SL_GiftRecipient exceeder: recipientsOver){
                    errorMessages.add(exceeder.recipient.Name + ' - ' + recipientToYTD.get(exceeder));
                }
                validationError += String.join(errorMessages, ', ');
                throw new SL_GiftLogException(validationError);
            }

            for(Gift__c gift: selectedGifts) {
                gift.Approved__c = action == 'Approve' ? 'Approved' : 'Denied';
                gift.Approved_By__c = UserInfo.getUserId();
                gift.Approve_Date__c = datetime.now();
                gift.Approval_Comment__c = approvalComment;
            }


            Database.SaveResult[] MySaveResult = Database.Update(selectedGifts, false);
            Integer giftNumber=0;
            for (Database.SaveResult sr : MySaveResult) {
                if (sr.isSuccess()) {
                    System.debug('Successfully inserted Gift. ID: ' + sr.getId());
                }
                else {

                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Gift fields that affected this error: ' + err.getFields());
                  		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,
                  			'Cannot '+ action.toLowercase() + ' ' + selectedGifts[giftNumber].Name + ' for ' 
                  			+ selectedGifts[giftNumber].Recipient__r.Name + ': ' + err.getMessage());
            			ApexPages.addMessage(msg);  
                    }
                }
            giftNumber++;
            }    
        }    
        catch (SL_GiftLogException e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage());
            ApexPages.addMessage(msg);
            System.debug(LoggingLevel.error,'We caught this problem: ' + msg);
        }
        searchGifts();
    }
    
    

}