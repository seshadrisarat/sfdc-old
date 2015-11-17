/**
* \arg ClassName  : SL_Lease_Payment_Calculator_Controller     
* \arg JIRATicket : FAEF -28
* \arg CreatedOn  : 25/08/2014
* \arg CreatedBy  : Vivek
* \arg ModifiedBy : Lodhi
* \arg Description: This class is used to calculate payment rate
*/
public without sharing class SL_Lease_Payment_Calculator_Controller    
{
    /* Start - Variables */
    
    /* Variables for Calculation section */  
    public Decimal amount                   {   get;set;    }//Variable to get the Project Amount
    public String strLikelyTerm             {   get{if(strLikelyTerm == null) strLikelyTerm = '36 Months'; return strLikelyTerm;}set;   }
    public String strLikelyStruct           {   get{if(strLikelyStruct == null) strLikelyStruct = 'FMV'; return strLikelyStruct;}set; }
    public String strAlterTerm              {   get{if(strAlterTerm == null) strAlterTerm = '60 Months'; return strAlterTerm;}set;  }
    public String strAlterStruct            {   get{if(strAlterStruct == null) strAlterStruct = '$1 Buyout'; return strAlterStruct;}set;    }
    
    /* Variables for Calculation section */  
    
    /* Variables for Result section */
    public Decimal decLikelyMonthlyRate     {   get;set;    }
    public Decimal decAlterMonthlyRate      {   get;set;    }
    public String strLikelyMonth            {   get;set;    }
    public String strAlterMonth             {   get;set;    }
    public Decimal decLikelyLRFactor        {   get;set;    }
    public Decimal decAlterLRFactor         {   get;set;    }
    public String strCompany                {   get;set;    }//Variable to get Company Name
    public String strCompanyId              {   get;set;    }//to get Company Id
    public String strCustomer               {   get;set;    }//to get Customer Name
    public String strcustomerId             {   get;set;    }//to get Customer id
    public String strProject                {   get;set;    }//to get Project Name 
    public String strDescription            {   get;set;    }//to get Project Description
    public String strAdditionalInfo         {   get;set;    }//
    public String strEmail                  {   get;set;    }//to get Email Id
    public String opportunityId             {   get;set;    }//to get the Opportunity Id
    public String errormsg                  {   get;set;    }//to display errormsg
    public String strPhone                  {   get;set;    }//to get the phone number
    public String siteName                  {   get;set;    }//to get the site name, if any
    public String btnColor                  {   get;set;    }
    public String btnFontColor                  {   get;set;    }
    public String btnHoverColor             {   get;set;    }
    public String btnHoverFontColor             {   get;set;    }
    public List<Vendor_Community_Opportunity_Owner__c> lstVCOO;//to get the owner id from custom setting 
    /* Variables for Result section */
    
    public Map<Decimal, String> mapRangeLimitToPicklistValue;  //map contains Range Limit to the Picklist Value 

    private RecordType VendorDivisionRecordType;
    
    /* End - Variables */
    
    
    
    /*  
        @MethodName   : Constructor
        @param        : None
        @Description  : This method will be called on page load
    */
    public SL_Lease_Payment_Calculator_Controller() 
    {
        intialization();
        mapRangeLimitToPicklistValue = getPaymentRates();
        lstVCOO = Vendor_Community_Opportunity_Owner__c.getAll().values();//getting the user id from custom setting.
        VendorDivisionRecordType = [Select Id From RecordType Where SobjectType='Opportunity' AND Name = 'Vendor Division Opportunity'];  
    }
    
    /* End */
    /*  
        @MethodName   : intialization
        @param        : None
        @Description  : This method to intialize all global variables.
    */
    private void intialization()
    {
        amount = 0.0;
        strCompany = strCustomer = strProject = strDescription = strEmail = '';
        siteName = Site.getPathPrefix();

        SL_util_VendorCommunity.PortalBrandingWrapper branding = SL_util_VendorCommunity.getPortalBranding();
        this.btnColor = branding.activeNavColor;
        this.btnFontColor = branding.activeNavFontColor;
        this.btnHoverColor = branding.hoverNavColor;
        this.btnHoverFontColor = branding.hoverNavFontColor;
    }
    /* End */
    
    /*  
        @MethodName   : getPaymentRates
        @param        : None
        @Description  : get the payment rates.
    */
    private Map<Decimal, String> getPaymentRates()
    {
        Map<Decimal, String> mapRangeLmtToPicklistValue = new Map<Decimal, String>(); //!< Hold decimal value with corresponding picklist value.
        /* Fetch all Range picklist value and creating map of decimal value to actual picklist value */
        for(Schema.PicklistEntry objType: Payment_Rates__c.Range__c.getDescribe().getPicklistValues()) 
        {
            String strPicklistValue = objType.getValue().replaceAll('<','').replaceAll('>','').replaceAll('$', '').replaceAll(',', '').replaceAll(' ', '');
            strPicklistValue        = strPicklistValue.substring(1, strPicklistValue.length());
            Decimal decRange        = Decimal.valueOf(strPicklistValue);
            mapRangeLmtToPicklistValue.put(decRange, objType.getValue()); 
        }
        return mapRangeLmtToPicklistValue;
    }
    /* End */
    
    /*  
        @MethodName   : getTerms
        @param        : None
        @Description  : 
    */
    public List<SelectOption> getTerms()
    {
        List<SelectOption> options = new List<SelectOption>();
        /* Fetching all Term picklist value */
        for(Schema.PicklistEntry objTerms: Payment_Rates__c.Term__c.getDescribe().getPicklistValues()) 
        {
            options.add(new SelectOption(objTerms.getValue(),objTerms.getValue()));
        }
        return options;//list returns the terms of Project
    }
    /* End */
    
    /*  
        @MethodName   : getType
        @param        : None
        @Description  : 
    */
    public List<SelectOption> getType()
    {
        List<SelectOption> options = new List<SelectOption>();
        /* Fetch all Type picklist value */
        for(Schema.PicklistEntry objType: Payment_Rates__c.Type__c.getDescribe().getPicklistValues()) 
        {
            options.add(new SelectOption(objType.getValue(),objType.getValue()));
        }
        return options;
    }
    /* End */
    /*  
        @MethodName   : calculateRate
        @param        : None
        @Description  : This method is used for calculating payment rate.
    */
    public void reset()
    {
        amount =  0.0;
        strLikelyTerm = '36 Months'; 
        strLikelyStruct = 'FMV'; 
        strAlterTerm = '60 Months';
        strAlterStruct = '$1 Buyout';
    }
    /* End */
    
    /*  
        @MethodName   : calculateRate
        @param        : None
        @Description  : This method is used for calculating payment rate.    
    */
    public void calculateRate() 
    {
        if(amount != null && amount != 0.0)
        {
            String strPicklistValue = '';
            List<Decimal> lstRange  = new List<Decimal>();
            
            lstRange.addAll(mapRangeLimitToPicklistValue.keySet());
            lstRange.sort();
            
            /* Iterate over list of range to compare with user input and get actual picklist value */
            for(Decimal decRange : lstRange)
            {
                if(amount < decRange)
                {
                    strPicklistValue = mapRangeLimitToPicklistValue.get(decRange);
                    break;
                }   
            }
            if(strPicklistValue == '')
                strPicklistValue = mapRangeLimitToPicklistValue.get(lstRange[lstRange.size()-1]);
            
            /* Query Payment Rate object for Likely Structure where term, type is same as user input and range falls within range. */
            List<Payment_Rates__c> lstPaymentRate = new List<Payment_Rates__c>([SELECT Range__c, 
                                                                                       Rate__c, 
                                                                                       Term__c, 
                                                                                       Type__c 
                                                                                  FROM Payment_Rates__c 
                                                                                 WHERE Term__c =: strLikelyTerm 
                                                                                   AND Type__c =: strLikelyStruct 
                                                                                   AND Range__c = :strPicklistValue LIMIT 1]);
                                                                                   
            if(!lstPaymentRate.isEmpty())
            {
                decLikelyMonthlyRate = amount * lstPaymentRate[0].Rate__c;
                decLikelyLRFactor = lstPaymentRate[0].Rate__c;
                strLikelyMonth = lstPaymentRate[0].Term__c.replace('Months', '');
            }
            
            /* Query Payment Rate object for Alternative Structure where term, type is same as user input and range falls within range. */
            lstPaymentRate = new List<Payment_Rates__c>([SELECT Range__c, 
                                                                Rate__c, 
                                                                Term__c, 
                                                                Type__c 
                                                           FROM Payment_Rates__c 
                                                          WHERE Term__c =: strAlterTerm 
                                                            AND Type__c =: strAlterStruct 
                                                            AND Range__c = :strPicklistValue LIMIT 1]);
                                                                                   
            if(!lstPaymentRate.isEmpty())
            {
                decAlterMonthlyRate = amount * lstPaymentRate[0].Rate__c; //Calculates the Monthly Payment 
                decAlterLRFactor = lstPaymentRate[0].Rate__c;
                strAlterMonth = lstPaymentRate[0].Term__c.replace('Months', '');
            }
        }
        
    }
    /* End */
    
    /*  
        @MethodName   : redirect
        @param        : None
        @Description  : redirecting to result page
    */
    public Pagereference redirect() 
    {
        Pagereference pageRef = Site.getPathPrefix() == '' ? Page.SL_Lease_Payment_Result : Page.SL_VendorLeasePaymentResult; //Redirects to the Lease Payment Page
        pageRef.setRedirect(false);
        return pageRef;
    }
    /* End */
    
    /*  
        @MethodName   : redirectCalculator
        @param        : None
        @Description  : redirecting to calculator page
    */
    public Pagereference redirectCalculator()
    {
        Pagereference pageRef = Site.getPathPrefix() == '' ? Page.SL_Lease_Payment_Calculator : Page.SL_VendorCalculator; //Redirects to the Lease Payment Calculator Page
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /*  
        @MethodName   : createRecords
        @param        : None
        @Description  : This method will be called on click of "Create Record" button.
    */
    public PageReference createRecords() 
    {
        try
        {
            errormsg = '';
            opportunityId = '';
            
            //checks whether contact of same customer name is present so as to create opportunity
            if(strCompanyId != null && strCompanyId != '')
            {
                if(!String.isEmpty(strcustomerId))  
                    opportunityId = createOpportunity(strcustomerId, strCompanyId); //creates Opportunity when contact with customer same is present
                else
                    opportunityId = createOpportunity(createContact(strCompanyId), strCompanyId);//calls method create contact while creating Opportunity when contact is not present
            }
            else
            {
                List<RecordType> lstRecordType = [SELECT Id  
                                                  FROM RecordType  
                                                  WHERE RecordType.DeveloperName = 'Vendor_Division'];
                                                   
                Account objAccount = new Account(Name = strCompany);
                
                if(!lstRecordType.isEmpty())
                    objAccount.RecordTypeId = lstRecordType[0].Id;                                               
                if(!lstVCOO.isEmpty() && lstVCOO[0].User_ID__c != null)
                    objAccount.OwnerId = lstVCOO[0].User_ID__c;
                insert objAccount;
                
                opportunityId = createOpportunity(createContact(objAccount.Id), objAccount.Id);
            }
            PageReference pr = new PageReference(Site.getPathPrefix()+'/SL_VendorOpportunityDetail?opportunityId='+opportunityId);
            pr.setRedirect(true);
            return pr;
        }
        catch(Exception ex)
        {
            errormsg = ex.getMessage();
            System.debug('=========Exception========='+ex);
            return null;
        }
    }
    /*  
        @MethodName   : createContact
        @param        : String companyId
        @Description  : This method will be called to create Contact
    */
    private String createContact(String accountId) 
    {
        String strFirstName = (strCustomer.split(' ').size() > 1) ? strCustomer.split(' ')[0] : '';
        String strLastName =   (strCustomer.split(' ').size() > 1) ? strCustomer.replaceFirst(strCustomer.split(' ')[0],'') : strCustomer;
        
        Contact objContact = new Contact(LastName = strLastName, FirstName = strFirstName, 
                                         AccountId = accountId, Email = strEmail, Phone = strPhone);
        insert objContact;
        return objContact.Id;
    }
    /* End */
    
    /*         
        @MethodName   : createOpportunity
        @param        : String contactId, String accountId
        @Description  : this method will be called to create Opportunity and OpportunityContactRole.
    */
    private String createOpportunity(String contactId, String accountId) 
    {
        List<OpportunityShare> lstOpportunityShare = new List<OpportunityShare>();//List of OpportunityShare for creating the manual sharing 
        
        //getting the currently login user's contact Id
        List<User> lstUser = [SELECT ContactId,
                                     AccountId
                                FROM User 
                               WHERE Id =: UserInfo.getUserId() LIMIT 1];
        
        //Create a opportunity and changing its owner id
        Opportunity objOpportunity       = new Opportunity(RecordType = VendorDivisionRecordType,
                                                           Name = strProject,
                                                           Equipment_Detail_Purpose__c = strDescription,
                                                           Vendor_Referral1__c = (!lstUser.isEmpty() && lstUser[0].AccountId != null) ? lstUser[0].AccountId : null, 
                                                           //Monthly_Payment__c = decLikelyMonthlyRate,
                                                           //Monthly_Payment_2__c = decAlterMonthlyRate,
                                                           Term__c = Decimal.valueOf(strLikelyMonth.trim()),
                                                           Term_In_Months_2__c = Decimal.valueOf(strAlterMonth.trim()),
                                                           Likely_Structure__c = strLikelyStruct,
                                                           Other_Structure_Offered__c = strAlterStruct,
                                                           Monthly_LRF__c = decLikelyLRFactor,
                                                           Monthly_LRF_2__c = decAlterLRFactor,
                                                           Payment_Frequency__c = 'monthly',
                                                           Payment_Frequency_2__c = 'monthly',
                                                           StageName = 'Information Gathering', 
                                                           CloseDate = Date.today(), 
                                                           Customer_Email__c = strEmail, 
                                                           Amount = amount,
                                                           AccountId = accountId,
                                                           Text_Area_Long__c = strAdditionalInfo, 
                                                           OwnerId = (!lstVCOO.isEmpty() && lstVCOO[0].User_ID__c != null) ? lstVCOO[0].User_ID__c : Userinfo.getUserId());
        
        insert objOpportunity;
        
        //Creating the OpportunityContactRole for existing/created contact
        OpportunityContactRole objOCR = new OpportunityContactRole(OpportunityId = objOpportunity.Id, 
                                                                   ContactId = contactId,
                                                                   IsPrimary = true,
                                                                   Role = 'Decision Maker');
        insert objOCR; 
        
        if(!lstUser.isEmpty() && lstUser[0].ContactId != null)
        {
            //Creating the OpportunityContactRole for external user
            OpportunityContactRole objOCRExternal = new OpportunityContactRole(OpportunityId = objOpportunity.Id, 
                                                                               ContactId = lstUser[0].ContactId, Role='Vendor');
            insert objOCRExternal;
        }
        
        //To create manual share record for the current owner of the opportunity  
        if(!lstVCOO.isEmpty() && lstVCOO[0].User_ID__c != null)
        {
            lstOpportunityShare.add(new OpportunityShare(OpportunityId = objOpportunity.Id, 
                                                         OpportunityAccessLevel = 'Edit',
                                                         UserOrGroupId = UserInfo.getUserId()));
        }
        
        //finding the account where Vendor_Affiliate__c is not null 
        List<Account> lstAccount = [SELECT Id, 
                                           Vendor_Affiliate__c 
                                      FROM Account 
                                     WHERE Id =: accountId 
                                       AND Vendor_Affiliate__c != null];
                                        
        if(!lstAccount.isEmpty())
        {
            //Iterating on user to create manual sharing for opportunity that is related to the account where Vendor_Affiliate__c is not null . 
            for(User objUser : [SELECT Id 
                                  FROM User 
                                 WHERE ContactId IN: [SELECT Id 
                                                        FROM Contact 
                                                       WHERE AccountId =:lstAccount[0].Vendor_Affiliate__c]
                                   AND Id !=: UserInfo.getUserId()])
            {
                lstOpportunityShare.add(new OpportunityShare(OpportunityId = objOpportunity.Id, 
                                                             OpportunityAccessLevel = 'Edit',
                                                             UserOrGroupId = objUser.Id));
            }
        }
        
        if(!lstOpportunityShare.isEmpty())
                insert lstOpportunityShare;
        
        return objOpportunity.Id;
    }
    /* End */
}