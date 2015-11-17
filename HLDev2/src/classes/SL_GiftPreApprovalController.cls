/**  
* \arg ClassName        : SL_GiftPreApprovalController
* \arg JIRATicket       : HL-37
* \arg CreatedOn        : 01/NOV/2014
* \arg LastModifiedOn   : 19/NOV/2014
* \arg CreatededBy      : Edward Rivera
* \arg ModifiedBy       : -
* \arg Description      : Controller class for SL_GiftPreApproval, SL_GiftCongrats, SL_GiftDecision
*/
public with sharing class SL_GiftPreApprovalController {
	/* Start - Variables */
	public String whichController {get; set;}
    public String profileid {get; set;}
    public String roleid {get; set;}
    public String usertype {get; set;}
    public String justAdded {get; set;}

    public String searchTextContact {get; set;}
    public String searchOptionContact {get; set;}
    public String searchTextAccount {get; set;}
    public String searchOptionAccount {get; set;}
    public String searchMessage{get; set;}
    // the master gift being created and driving the input fields
    public Gift__c gift {get; set;}

    // page parameters
    public ID cloneId { get; set; }
    public String isClone { get; set; }
    public String result { get; set; }
    
    // all recipients that are returned when search is performed
    public List<SL_GiftRecipient> allRecipientsList {get; set;}
    // all recipients that have been added to the selRecipients List
    public List<SL_GiftRecipient> selRecipientsList {get; set;}
    // all recipients that, if the gift is approved will exceed their YTD limit, used for determining which page is redirected to
    public List<SL_GiftRecipient> clientsExceedingYTD {get; set;}
    // list of all the gifts that are cloned from the master gift
    public List<Gift__c> newGifts {get; set;}
    // inserted gift's iDs
    public Set <Id> giftIds { get; set; }
    /* End - Variables */
    /* Start - Constructor */
    public SL_GiftPreApprovalController() {
		gift = new Gift__c();
        selRecipientsList = new List<SL_GiftRecipient>();

        profileid = UserInfo.getProfileId();
        roleid = UserInfo.getUserRoleId();
        usertype = UserInfo.getUserType();
        
        cloneId = ApexPages.currentPage().getParameters().get('id');
        isClone = ApexPages.currentPage().getParameters().get('clone');

        justAdded = ApexPages.currentPage().getParameters().get('gifts');
        
        result = isClone;
        if (isClone == '1') {
            this.gift = [SELECT Name,Gift_Value__c,HL_Relationship__c,CurrencyIsoCode,Desired_Date__c,fApproval_Number__c,Gift_Type__c,Id,Product__c,Reason_For_Gift__c,Recipient__c,Submitted_For__c,Vendor__c FROM Gift__c WHERE id = :cloneId]; 
            result = gift.Name;
        }
        giftIds=new Set<Id>();
        allRecipientsList = new List<SL_GiftRecipient>();
	}
    /* End - Constructor */

    /*
        @MethodName : getSearchOptions 
        @param      : 
        @Description: This method is called upon page load to fill in picklist values
    */
    public List<SelectOption> getSearchOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('contains','Contains')); 
        options.add(new SelectOption('exact','Exact Match')); 
        options.add(new SelectOption('startswith','Starts With')); 
        options.add(new SelectOption('endswith','Ends With'));
        
        return options; 
    }
    /*
        @MethodName : searchRecipients
        @param      : 
        @Description: This method is invoked when a user clicks 'search' and generates the list of potential gift recipients
    */
    public PageReference searchRecipients() {
        if (searchTextContact.trim() != '' | searchTextAccount.trim() != '') {
            String whereConditionContact = '%';
            String whereConditionAccount = '%';
            if (searchOptionContact == 'contains') {
                whereConditionContact = '%' + searchTextContact + '%';
            }
            else if (searchOptionContact == 'startswith') {
                whereConditionContact = searchTextContact + '%';
            }
            else if (searchOptionContact == 'endswith') {
                whereConditionContact = '%' + searchTextContact;
            }
            else if (searchOptionContact == 'exact') {
                whereConditionContact = searchTextContact;
            }
            if (searchOptionAccount == 'contains') {
                whereConditionAccount = '%' + searchTextAccount + '%';
            }
            else if (searchOptionAccount == 'startswith') {
                whereConditionAccount = searchTextAccount + '%';
            }
            else if (searchOptionAccount == 'endswith') {
                whereConditionAccount = '%' + searchTextAccount;
            }
            else if (searchOptionAccount == 'exact') {
                whereConditionAccount = searchTextAccount;
            }
    
            List<Contact> contacts;
            if (searchTextAccount <> '') {
                //GREG - hard-coded recordtype IDs
                contacts = [Select Id, Name, Account.Name, (select id, name, createddate, Gift_Value__c, Approved__c, Desired_Date__c from Gifts__r) from Contact WHERE (Name LIKE :whereConditionContact) and (Account.Name LIKE :whereConditionAccount) AND RecordType.developerName <> 'Houlihan_Employee' order by Account.Name, Name LIMIT 1000];
            }
            else {
                //GREG - hard-coded recordtype IDs
                contacts = [Select Id, Name, Account.Name, (select id, name, createddate, Gift_Value__c, Approved__c, Desired_Date__c from Gifts__r) from Contact WHERE (Name LIKE :whereConditionContact) and (Account.Name LIKE :whereConditionAccount OR Account.Name = null) AND RecordType.developerName <> 'Houlihan_Employee' order by Account.Name, Name LIMIT 1000]; 
            }
            allRecipientsList = new List<SL_GiftRecipient>();
            for(Contact contact: contacts) {
                allRecipientsList.add(new SL_GiftRecipient(contact));
            }
    
            searchMessage = 'Records returned: ' + contacts.size() + ' (max 1000).';
        }
        else {
            searchMessage = 'You must enter at least one search term.';
        }

        return null;
    }

    /*
        @MethodName : saveGifts
        @param      : 
        @Description: This method is invoked when a user attempts to submit the page, and if successful, rerouts them to
                      the appropriate page
    */
    public PageReference saveGifts() {
        try {
            if (selRecipientsList.isEmpty()) {
                throw new SL_GiftLogException('You must select at least one recipient.');
            }
            for(SL_GiftRecipient recipient: selRecipientsList) {
                recipient.giftValue = gift.Gift_Value__c;
            }
            // populates the currencyIsoCode field based on the value in the Currency__c field
            convertCurrencyToIso();
            clientsExceedingYTD = new List<SL_GiftRecipient>();
            newGifts = new List<Gift__c>();

            for ( SL_GiftRecipient contact : selRecipientsList ) {
                Gift__c newGift = new Gift__c();
                newGift = gift.clone();
                newGift.Recipient__c = contact.recipient.id;
                newGifts.Add(newGift);
                if (contact.GiftPrevYTD+gift.Gift_Value__c>100||(contact.GiftPrevYTD+gift.Gift_Value__c>35&&gift.Currency__c=='Euro (in France)')){
                    clientsExceedingYTD.add(contact);
                }
            }
            if (!clientsExceedingYTD.isEmpty()){
                PageReference decisionPage = new PageReference('/apex/SL_GiftDecision');
                decisionPage.setRedirect(false);
                return decisionPage;
            }

            return proceedToCongratulations();
        }           
        catch (SL_GiftLogException e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage());
            ApexPages.addMessage(msg);
        }
        return null;    
    }
    /*
        @MethodName : addSelectedRecipients
        @param      : 
        @Description: Adds the recipients who have been checked off to the selected recipients list
    */
    public PageReference addSelectedRecipients() {
        try {
            if (allRecipientsList.isEmpty()){
                throw new SL_GiftLogException('You must select at least one recipient to add!');
            }
            for(SL_GiftRecipient recipient: allRecipientsList) {
                recipient.giftValue = gift.Gift_Value__c;
                if(recipient.selected == true) {
                    selRecipientsList.add(recipient);
                    recipient.selected = false;
                }
            }
        }
        catch (SL_GiftLogException e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage());
            ApexPages.addMessage(msg);
            System.debug(LoggingLevel.error,'We caught this problem: ' + msg);
        }

        return null;
    }

    /*
        @MethodName : removeSelectedRecipients
        @param      : 
        @Description: Removes the recipients who have been checked off from the selected recipients list
    */
    public PageReference removeSelectedRecipients() {
        try {
            Integer i = 0;
            if (selRecipientsList == null)
                selRecipientsList = new List<SL_GiftRecipient>();
                
            while (i < selRecipientsList.size()) {
                SL_GiftRecipient cur = selRecipientsList.get(i);
                if (cur.selected == true) {
                    selRecipientsList.remove(i);
                }
                else {
                    i++;
                }
            }
            if (allRecipientsList.isEmpty()){
                throw new SL_GiftLogException('You must select at least one recipient to add!');
            }
            for(SL_GiftRecipient recipient: allRecipientsList) {
                recipient.selected = false;
            }
        }
        catch (SL_GiftLogException e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage());
            ApexPages.addMessage(msg);
            System.debug(LoggingLevel.error,'We caught this problem: ' + msg);
        }
        return null;
    }

    /*
        @MethodName : convertCurrencyToIso
        @param      : 
        @Description: Maps the users currency picklist selection to the proper IsoCode for use in conversion rates
    */
    private void convertCurrencyToIso(){
        if (gift.Currency__c=='U.S. Dollar'){
            gift.CurrencyIsoCode='USD';
        }
        else if (gift.Currency__c=='Euro (in France)'||gift.Currency__c=='Euro (not in France)' ){
            gift.CurrencyIsoCode='EUR';
        }
        else if (gift.Currency__c=='British Pound' ){
            gift.CurrencyIsoCode='GBP';
        }
        else if (gift.Currency__c=='British Pound' ){
            gift.CurrencyIsoCode='GBP';
        }
        else if (gift.Currency__c=='Hong Kong Dollar'){
            gift.CurrencyIsoCode='HKD';
        }
    }
    /************************************************************
    Gift Decision Page
    ************************************************************/
    /*
        @MethodName : proceedToCongratulations
        @param      : 
        @Description: Ignores yearly limits on selected recipients and saves the gifts, redirecting the user to the congrats page
    */
    public PageReference proceedToCongratulations(){
        try {
            Database.SaveResult[] MySaveResult = Database.Insert(newGifts);    
            giftIDs.clear();
            for (Gift__c newGift :newGifts) {
                giftIDs.add(newGift.Id);
            }
            PageReference congratsPage = new PageReference('/apex/SL_GiftCongrats');
            congratsPage.setRedirect(false);
                
            return congratsPage;
        }
        catch( DmlException ex )
        {
            Set<String> messageSet = new Set<String>();
            String message = '';
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                messageSet.add(ex.getDmlMessage(i));
                
            }
            for (String s: messageSet){
                message += s + '\r\n'; 
            }    
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,message);
            ApexPages.addMessage(msg);
        } 
        return null;
    }
    /*
        @MethodName : returnToPreApproval
        @param      : 
        @Description: Returns the user to the preapproval page to revise their request
    */
    public PageReference returnToPreApproval(){
        PageReference preApprovalPage = new PageReference('/apex/SL_GiftPreApproval');
        preApprovalPage.setRedirect(false);
        return preApprovalPage;
    }
    /************************************************************
    Gift Congrats Page
    ************************************************************/
    /*
        @MethodName : getGiftsJustAdded
        @param      : 
        @Description: Generates the lists of gifts that have been created upon saving
    */
    public List<SL_Gift> getGiftsJustAdded() {
        List<SL_Gift> justAddedGifts = new List<SL_Gift>();

        if (giftIDs.isEmpty()){
            return justAddedGifts;
        }
        else {            
            List<SL_GiftRecipient> withGifts = new List<SL_GiftRecipient>();
            for(Contact contact: [SELECT Id,
                                         Name,
                                         Account.Name,
                                         (SELECT Id,
                                                 Name,
                                                 CreatedDate,
                                                 Approved__c,
                                                 Gift_Value__c,
                                                 Desired_Date__c,
                                                 Recipient__r.Name,
                                                 Submitted_For__r.Name,
                                                 CurrencyIsoCode 
                                         FROM Gifts__r 
                                         WHERE Id IN :giftIDs)
                                 FROM Contact 
                                 WHERE Id IN (SELECT Recipient__c 
                                              FROM Gift__c 
                                              WHERE Id IN :giftIDs)]) { 
                withGifts.add(new SL_GiftRecipient(contact));
            }
            
            for(SL_GiftRecipient recipient: withGifts) {
                if (!recipient.recipient.Gifts__r.isEmpty()) {
                    for(Gift__c eachGift: recipient.recipient.Gifts__r) {
                        justAddedGifts.add(new SL_Gift(eachGift, recipient.getGiftYTD(), recipient.GiftPrevYTD, recipient));
                    }
                }
            
            }
        }
        return justAddedGifts;
    }


    
    
}