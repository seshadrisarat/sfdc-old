/*
*  ClassName      : Sl_BillingSummaryController
*  JIRATicket     : PURE-10
*  CreatedOn      : 14/2/2014
*  ModifiedBy     : Hemant
*  Description    :   
*/
public with sharing class SL_BillingSummaryController {
    
    public list<activePolicyWrapper> lstActivePolicyWrapper {get;set;}//To Store all active policies
    public list<accountPaymentCreditsWrapper> lstPaymentCredits     {get;set;}//Payment Credit details
    public list<invoicesWrapper> lstInvoices        {get;set;}//invoices details
    public list<invoicesWrapper> lstInvoicesPrimary {get;set;}
    public list<FuturePaymentDatesWrapper> lstFuturePayments {get;set;}//Future payments details
    public list<FuturePaymentDatesWrapper> lstFuturePaymentsPrimary {get;set;}
    public Account objMemberInformation                     {get;set;}//This is to store logged in member all details.
    public Boolean isOverdue                                {get;set;}//To check whether user account is having past due amount or not.
    public List<activePolicyWrapper> lstBillingPolicyWrapper {get;set;}
    public Decimal totalCharges                 {get;set;}
    public Decimal totalPaymentCredit           {get;set;}
    public Decimal totalBalance                 {get;set;}
    public Decimal totalMinDue                  {get;set;}
    public Decimal lastPaymentReceived 			{get;set;}
   	public DateTime lastPaymentDate 			{get;set;}
    public Boolean isIndividaullyBilled         {get;set;}
    public Boolean isNotIndividaullyBilled      {get;set;}
    public String PrimaryBillingAddrs           {get;set;}
    
    public Map<Id, Integer> mapPolicyIdToFuturePaymentDateCount {get;set;}
    public Map<Id, Integer> mapPolicyIdToRecentInvoicesCount {get;set;}
    
    public Decimal primaryTotalCharges                                      {get;set;}
    public Decimal primaryMinDue                                            {get;set;}
    public Decimal primaryBalance                                           {get;set;}
    public Boolean isError      {get;set;}
    
    public String primaryEmail                  {get;set;}
    
    public String payMyBillLink {get;set;}
    // Constructor
    public SL_BillingSummaryController()
    {
        lstActivePolicyWrapper = new List<activePolicyWrapper>();   //This is a wrapper class list to store all active policies.
        lstPaymentCredits = new list<accountPaymentCreditsWrapper>();   //This is a wrapper class list to store all payment credits.
        lstInvoices = new list<invoicesWrapper>();  
        lstFuturePaymentsPrimary = new list<FuturePaymentDatesWrapper>();   
        lstInvoicesPrimary = new list<invoicesWrapper>();           // Invoices information
        lstFuturePayments = new list<FuturePaymentDatesWrapper>();  
        lstBillingPolicyWrapper = new List<activePolicyWrapper>();// Future payments details
        payMyBillLink = '';
        PortalURLMap__c oPayMyBillLink = new PortalURLMap__c();
        oPayMyBillLink = PortalURLMap__c.getInstance('PayBill');
        payMyBillLink = (oPayMyBillLink != null) ? oPayMyBillLink.URL__c : '#';
        primaryEmail = PrimaryBillingAddrs = '';
        primaryTotalCharges = primaryMinDue = primaryBalance = 0;
        
        mapPolicyIdToFuturePaymentDateCount = new Map<Id, Integer>();
        mapPolicyIdToRecentInvoicesCount = new Map<Id, Integer>();
        pageAction();
    }
    
    /*
        Name: pageAction
        Param: None
        Description: This page action method will ensure that non authenicated user can't see the page content
    */
    public pageReference pageAction()
    {
        //if(Userinfo.getUserType() == 'Guest') return new Pagereference('/');//If logged in user type is 'Guest' then redirect to login page.
        try
        {
                    
            String userAccountId;                                       //This is to store logged in user account id.
            String userRecordTypeId;
            isOverdue = isError = false;
            objMemberInformation = new Account();
            set<String> setPolicyNumbers = new set<String>();
            set<String> setPolicyNumbersPrimary = new set<String>();
            set<String> setALLPolicyNumbers = new set<String>();
            isIndividaullyBilled = false;
            
            totalCharges = 0;
            totalPaymentCredit = 0;
            totalBalance = 0;
            totalMinDue = 0;
            
            List<SL_PolicyStatusValues__c> lstSLPolicyStatusValues = new List<SL_PolicyStatusValues__c>();
            lstSLPolicyStatusValues = SL_PolicyStatusValues__c.getall().values();
            
            Set<String> setSLPolicyStatusValuesName = new Set<String>();
            
            String strBrocker = ''; 
            String strContactId = '';
            Set<Id> setAgencyContactId = new Set<Id>();     
            String strProfileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()].Name;
            
            for(SL_PolicyStatusValues__c obj : lstSLPolicyStatusValues) {
                
                setSLPolicyStatusValuesName.add(obj.Name);
            }
            
            //If it is not accessing from portal
            if(Apexpages.currentPage().getParameters().containsKey('aid'))
            {
                userAccountId = ApexPages.currentPage().getParameters().get('aid');
                List<Account> lstAccount = new List<Account>([Select Id From Account Where Id = :userAccountId]);
                
                if(!lstAccount.isEmpty())
                {
                    
                }
                else
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Parameter');
                    ApexPages.addMessage(msg);
                    isError = true;
                    return null;
                }
            }
            /* If it is accessed from AgentHomepage  // Added regarding PURE-63 */
            else if(Apexpages.currentPage().getParameters().containsKey('mId') && strProfileName != 'Pure Customer Community Login User')
            {
                // Member Id
                userAccountId = Apexpages.currentPage().getParameters().get('mId');
                
                for(User objUser : [SELECT Id, Contact.AccountId, ContactId, Contact.Account.IsOverdue__c FROM User WHERE Id =: Userinfo.getUserId() LIMIT 1]){
                    strContactId = objUser.ContactId;
                    if(objUser.Contact.Account.IsOverdue__c != null && objUser.Contact.Account.IsOverdue__c > 0){
                        isOverdue = true;
                    }
                }
                
                for(Agency_Contact__c obj : [SELECT Agency__c 
                                             FROM Agency_Contact__c 
                                             WHERE Contact__c =: strContactId 
                                               AND User_Status__c = 'Active' 
                                               AND (Agency__r.Broker_Status__c = 'Active' 
                                                OR Agency__r.Broker_Status__c = 'Suspended with Access')])
                    setAgencyContactId.add(obj.Agency__c);
                
                if(!setAgencyContactId.isEmpty() && setAgencyContactId != null)
                    strBrocker =  'Broker__c IN: setAgencyContactId';
                else {
                    PageReference pageRef = new PageReference('/Exception');
                    return pageRef;
                }
            }
            else
            {
                /* This is to query member record type id.*/
                for(RecordType objRecordType : [Select Id, SobjectType, Name from RecordType where Name =:'Member' AND SobjectType =: 'Account' limit 1])
                {
                    userRecordTypeId = objRecordType.Id;
                }
                
                /* This is to query logged in user account id.*/
                for(User objUser : [    Select Id, User_s_Email__c, Contact.AccountId, Contact.Account.RecordTypeId, Contact.Account.IsOverdue__c
                                        from User where Id=: Userinfo.getUserId() AND Contact.Account.RecordTypeId =: userRecordTypeId limit 1
                                        
                                    ])
                {
                    primaryEmail = objUser.User_s_Email__c;
                    
                    /* If isOverdue field on account is not null then check if isOverdue is greater than 0.*/
                    if (objUser.Contact.Account.IsOverdue__c != null)
                    {
                        if(objUser.Contact.Account.IsOverdue__c > 0)
                        {
                            isOverdue = true;
                        }
                    }
                    
                    userAccountId = objUser.Contact.AccountId;
                    
                }
                
            }
            
            for(Contact_Info__c objContInfo : [ SELECT Id,City__c,City_Old__c,Email__c,Email_Old__c,Is_Updated__c,Is_Primary__c,Phone__c,Phone_Old__c,Receive_Annual_Report__c,
                                                    Receive_Company_Updates__c,Receive_Policy_Information__c,Receive_PURE_Events__c,Receive_PURE_Press__c,  Receive_PURE_Prevention__c,
                                                    Receive_PURE_Situation_Room__c,Receive_SSA_Statements__c,State__c,State_Old__c,Street__c,Street_Old__c,Street_2__c,Street_2_Old__c,
                                                    Type__c,Zip__c,Zip_Old__c,Account__c
                                                FROM Contact_Info__c 
                                                WHERE Account__c =: userAccountId ])
            {
                
                if( objContInfo.Type__c == 'Email' )
                {
                    if(objContInfo.Is_Primary__c) {
                        
                        if(objContInfo.Email__c != null && objContInfo.Email__c != '')
                            primaryEmail = objContInfo.Email__c;
                    }
                }
                if( objContInfo.Type__c == 'Billing')
                {
                    if(objContInfo.Is_Primary__c)                            
                        PrimaryBillingAddrs = (objContInfo.Street__c != null ? objContInfo.Street__c+' ' : '') + (objContInfo.Street_2__c != null ? objContInfo.Street_2__c : '') + ' \n '+ (objContInfo.City__c != null ? objContInfo.City__c + ',' : '') + (objContInfo.State__c != null ? objContInfo.State__c : '') + ' ' + (objContInfo.Zip__c != null ? objContInfo.Zip__c : '');
                }   
                
                
                
            }
            
            /* Start - Member information section. */
            
            // Added regarding PURE-63 
            String strQuery = 'SELECT Id, RecordTypeId, Last_Payment_Received__c, Member_Key_EDW__c, Name, Five_Year_Service_Date__c,IsOverdue__c, SSA_Balance__c,'
                              + 'Phone,Primary_Email__c , BillingPostalCode, Billing_Document_Delivery_Method__c, Total_Charges__c, Balance__c, Min_Due__c,'
                              + 'Last_Payment_Date__c, billingAddress__c, shippingAddress__c ';     
            
            List<Account> lstAccount = new List<Account>();
            String strMember = 'Member';
            
            if(!String.isEmpty(strBrocker) && strBrocker != '')
            {
                strQuery += ' FROM Account WHERE Id=' + '\'' + userAccountId +'\' AND ' + strBrocker + ' AND RecordType.Name =: strMember LIMIT 1';
                lstAccount = Database.query(strQuery);
                
                if(!lstAccount.isEmpty() && lstAccount != null){
                    objMemberInformation = lstAccount[0];
                    lastPaymentDate = objMemberInformation.Last_Payment_Date__c;
                    lastPaymentReceived = objMemberInformation.Last_Payment_Received__c;
                    System.debug('~~~~ objMemberInformation.Last_Payment_Received__c: ' + objMemberInformation.Last_Payment_Received__c);
                    System.debug('~~~~ objMemberInformation.Last_Payment_Date__c: ' + objMemberInformation.Last_Payment_Date__c);
                }
                
                if(lstAccount.isEmpty() || lstAccount == null )
                {
                    PageReference pageRef = new PageReference('/Exception');
                    return pageRef;
                }
            }
            else
            {
                strQuery += ' FROM Account WHERE Id=' + '\'' + userAccountId +'\' LIMIT 1';
                lstAccount = Database.query(strQuery);
                if(!lstAccount.isEmpty() && lstAccount != null){
                    objMemberInformation = lstAccount[0];
                    lastPaymentDate = objMemberInformation.Last_Payment_Date__c;
                    lastPaymentReceived = objMemberInformation.Last_Payment_Received__c;
                }
            }
            
            /* End - Member information section. */
            
            /* Start - Your active policy section */
            
            for(Policy__c objPolicy : [SELECT Id, Policy_Number__c, User_Description__c,Integration_Description__c, Policy_Status__c, Policy_Term_Dates__c, Total_Charges__c, Balance__c, Effective_Date__c, Expiration_Date__c,
                                              Description_Display__c, Line_of_Business__c,  IsOverdue__c,Total_Premium_Amount__c,Pending_Renewal_Premium_Amount__c,IsIndividuallyBilled__c,
                                              PaymentsCredits__c, Bill_Payor_Name__c, Min_Due__c 
                                        FROM Policy__c 
                                        WHERE Member__c = :userAccountId AND (Policy_Status__c IN : setSLPolicyStatusValuesName) order by Description_Display__c])
            {
                mapPolicyIdToFuturePaymentDateCount.put(objPolicy.Id, 0); 
                mapPolicyIdToRecentInvoicesCount.put(objPolicy.Id, 0); 
                
                String strDesc = (String.isEmpty(objPolicy.User_Description__c) ? objPolicy.Integration_Description__c : objPolicy.User_Description__c);
                lstActivePolicyWrapper.add(new activePolicyWrapper(objPolicy.Description_Display__c, objPolicy.Policy_Term_Dates__c, objPolicy.Total_Charges__c, objPolicy.Policy_Number__c,
                                                                    objPolicy.IsOverdue__c, objPolicy.Total_Premium_Amount__c, objPolicy.Pending_Renewal_Premium_Amount__c, objPolicy.IsIndividuallyBilled__c, 
                                                                    objPolicy.Balance__c, objPolicy.Expiration_Date__c, objPolicy.Effective_Date__c,objPolicy.PaymentsCredits__c,
                                                                    objPolicy.Id,objPolicy.Bill_Payor_Name__c,objPolicy.Min_Due__c  ));
                if( objPolicy.IsIndividuallyBilled__c)  
                {
                    setPolicyNumbers.add(objPolicy.id);
                    isIndividaullyBilled = true;
                    lstBillingPolicyWrapper.add(new activePolicyWrapper(strDesc, objPolicy.Total_Charges__c, objPolicy.Balance__c, objPolicy.Min_Due__c, objPolicy.Policy_Number__c, objPolicy.IsOverdue__c));
                }   
                else 
                {           
                    isNotIndividaullyBilled  = true;                        
                    totalCharges += (objPolicy.Total_Charges__c == null ? 0 : objPolicy.Total_Charges__c);
                    totalPaymentCredit += (objPolicy.PaymentsCredits__c == null ? 0 : objPolicy.PaymentsCredits__c);
                    totalBalance += (objPolicy.Balance__c == null ? 0 : objPolicy.Balance__c);
                    totalMinDue += (objPolicy.Min_Due__c == null ? 0 : objPolicy.Min_Due__c);
                    setPolicyNumbersPrimary.add(objPolicy.id);
                }
                setALLPolicyNumbers.add(objPolicy.id);
                
            }
            /* End - Your active policy section  */
            Integer i=0;
            
            /* Start - Invoices */
            for(Invoices__c objInvoices : [SELECT name,Bill_Date__c, Display_Text__c, Document_ID__c, Document_URL__c, Is_Consolidated__c,Policy__c from Invoices__c where Member__c =: userAccountId AND Bill_Date__c = LAST_N_DAYS:365 order by Bill_Date__c desc])
            {
                if(objInvoices.Is_Consolidated__c)
                    lstInvoicesPrimary.add(new invoicesWrapper(objInvoices.Name,objInvoices.Bill_Date__c,objInvoices.Display_Text__c,objInvoices.Document_URL__c,objInvoices.Is_Consolidated__c,objInvoices.Policy__c,i++));
                
                if(setPolicyNumbers.contains(objInvoices.Policy__c) && !objInvoices.Is_Consolidated__c )
                {
                    if(objInvoices.Policy__c != null)
                        mapPolicyIdToRecentInvoicesCount.put(objInvoices.Policy__c, 1);
                        
                    lstInvoices.add(new invoicesWrapper(objInvoices.Name,objInvoices.Bill_Date__c,objInvoices.Display_Text__c,objInvoices.Document_URL__c,objInvoices.Is_Consolidated__c,objInvoices.Policy__c,i++));
                }
            }
            /* End - Invoices */
        
            /* Start - Future Payment Details */
            for(Future_Payment__c objFutPayment : [SELECT Estimated_Date__c, Minimum_Due__c, Is_Consolidated__c,Policy__c from Future_Payment__c  where  Member__c =: userAccountId AND Estimated_Date__c >= TODAY order by Estimated_Date__c desc])
            {
                if(objFutPayment.Is_Consolidated__c)
                    lstFuturePaymentsPrimary.add(new FuturePaymentDatesWrapper(objFutPayment.Estimated_Date__c,objFutPayment.Minimum_Due__c,objFutPayment.Is_Consolidated__c,objFutPayment.Policy__c));
                
                if(setPolicyNumbers.contains(objFutPayment.Policy__c) && !objFutPayment.Is_Consolidated__c )
                {
                    if(objFutPayment.Policy__c != null)
                        mapPolicyIdToFuturePaymentDateCount.put(objFutPayment.Policy__c, 1);
                        
                    lstFuturePayments.add(new FuturePaymentDatesWrapper(objFutPayment.Estimated_Date__c,objFutPayment.Minimum_Due__c,objFutPayment.Is_Consolidated__c,objFutPayment.Policy__c));
                }
            } 
            /* End - Future Payment Details */
            
            /* Start - Payment & Credits */
            for(Payment_Credits__c objPaymentCredits : [    SELECT Name, Type__c, Transaction_Date__c, Hide_Payment_Flag__c, Amount__c, Check_Number__c 
                                                            FROM Payment_Credits__c 
                                                            WHERE member__c =: userAccountId  AND Hide_Payment_Flag__c =: false AND Transaction_Date__c = LAST_N_DAYS:365 order by Transaction_Date__c DESC])
            {
                lstPaymentCredits.add(new accountPaymentCreditsWrapper(objPaymentCredits.Name, objPaymentCredits.Type__c, objPaymentCredits.Transaction_Date__c, objPaymentCredits.Amount__c, objPaymentCredits.Check_Number__c));                                                  
            }
        }
        catch(Exception e)
        {
            system.debug('------e-------'+e.getMessage());
        }
        /* End - Payment & Credits */
        return null;
    }
    
    /* Inner class to store active policies related to loggedin member. */
    public class activePolicyWrapper
    {
        public String policyDescription     {get;set;}
        public String policyEffectiveDate       {get;set;}
        public Decimal policyTotalCharges   {get;set;}
        public String policyNumber      {get;set;}
        public Boolean policyIsOverdue  {get;set;}
        public Decimal policyTotalPremium{get;set;}
        public Decimal policyPendingPremiumRenewal{get;set;}
        public Boolean isIndivisualBilled {get;set;}
        public Decimal Balance {get;set;}
        public Date expirationDate {get;set;}
        public Date effectiveDate {get;set;}
        public Decimal paymentsCredits {get; set;}
        public Id   policyId {get; set;}
        public String BillPayorName {get;set;}
        public Decimal policyMinDue {get;set;}
        
        
        public  activePolicyWrapper(String policyDescription, Decimal policyTotalCharges, Decimal Balance, Decimal policyMinDue, String policyNumber, Boolean policyIsOverdue)
        {
            this.policyDescription = policyDescription;
            this.policyTotalCharges = policyTotalCharges;
            this.Balance = Balance;
            this.policyMinDue = policyMinDue;
            this.policyNumber = policyNumber;
            this.policyIsOverdue = policyIsOverdue;
            
        }
        /* Inner class parametric constructor */
        public  activePolicyWrapper(String policyDescription, String policyEffectiveDate, Decimal policyTotalCharges, String policyNumber, 
                                    Boolean policyIsOverdue, Decimal policyTotalPremium,  Decimal policyPendingPremiumRenewal, Boolean isIndivisualBilled, 
                                    Decimal Balance,Date expirationDate, Date effectiveDate, Decimal paymentsCredits,Id policyId,String BillPayorName,Decimal policyMinDue )
        {
            this.policyDescription = policyDescription;
            this.policyEffectiveDate = policyEffectiveDate;
            this.policyTotalCharges = (policyTotalCharges == null ? 0 : policyTotalCharges);
            this.policyNumber = policyNumber;
            this.policyIsOverdue = policyIsOverdue;
            this.policyTotalPremium = (policyTotalPremium == null ? 0 : policyTotalPremium);
            this.policyPendingPremiumRenewal = (policyPendingPremiumRenewal == null ? 0 : policyPendingPremiumRenewal);
            this.isIndivisualBilled  = isIndivisualBilled;
            this.Balance = (Balance == null ? 0 : Balance);
            this.expirationDate = expirationDate;
            this.effectiveDate = effectiveDate;
            this.paymentsCredits = (paymentsCredits == null ? 0 : paymentsCredits);
            this.policyId = policyId;
            this.BillPayorName = BillPayorName;
            this.policyMinDue = policyMinDue;
        }
    }
    /* Start - Invoices */
    public class invoicesWrapper
    {
        public Date BillDate {get;set;}
        public String DisplayText {get;set;}
        public String DocumentId {get;set;}
        public Boolean IsConsolidated {get;set;}
        public Id PolicyId {get;set;}
        public String invName {get;set;}
        public Integer row          {   get;set;    }
        
        public invoicesWrapper(String invName, Date BillDate,String DisplayText,String DocumentId,Boolean IsConsolidated,Id PolicyId,Integer row)
        {
            this.invName = invName;
            this.BillDate = BillDate;
            this.DisplayText = DisplayText;
            this.DocumentId = DocumentId;
            this.IsConsolidated = IsConsolidated;
            this.PolicyId = PolicyId;
            this.row = row;   
        }
    }
    /* Start - Future payment dates */
    public class FuturePaymentDatesWrapper
    {
        public Date EstimatedDate {get;set;}
        public Decimal MinDue {get;set;}
        public Boolean IsConsolidated {get;set;}
        public Id PolicyId {get;set;}
        
        public FuturePaymentDatesWrapper(Date EstimatedDate,Decimal MinDue,Boolean IsConsolidated,Id PolicyId)
        {
            this.EstimatedDate = EstimatedDate;
            this.MinDue = MinDue;
            this.IsConsolidated = IsConsolidated;
            this.PolicyId = PolicyId;  
        }
    }
    public class accountPaymentCreditsWrapper
    {
        public String PayeeName             {get;set;}
        public String TransactionType       {get;set;}
        public Date TransactionDate         {get;set;}
        public Decimal Amount               {get;set;}
        public String CheckNumber           {get;set;}
        /* Inner class parametric constructor */
        public accountPaymentCreditsWrapper(String PayeeName,String TransactionType,Date TransactionDate,Decimal Amount,String CheckNumber )
        {
            this.PayeeName          = PayeeName;
            this.TransactionType    = TransactionType;
            this.TransactionDate    = TransactionDate;
            this.Amount             = Amount;
            this.CheckNumber        = CheckNumber; 
        }
    }   
}