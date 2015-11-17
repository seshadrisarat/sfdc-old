/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest (seeAllData=true)
private class OpportunityHandlerTest {

    static testMethod void testOpportunityHandler() {
        //ID oppRecordId = TestDataUtil.getNPDNotReconciledOpportunityRecordTypeId();
        //For now hardcode to troubleshoot, then we can put it in custom setting
        ID oppRecordId = '012K0000000DOFO';
        //in case the custom setting is not created
        try{
            if(sfdc_id__c.getAll().containsKey('Record Type New Opportunity'))
                oppRecordId  = sfdc_id__c.getAll().get('Record Type New Opportunity').id__c;
            }catch(exception e){}
        
        Account acc = new Account(  Type = 'NPD Customer',
      Name='Test',
      netsuite_conn__Celigo_Update__c = true,
      
      Industry = 'Automotive', 
      CurrencyIsoCode = 'USD',
      AccountClass__c = 'Automotive Services',
      AccountBU__c = 'U.S. Automotive',
      Account_Sector__c = 'U.S. Hardlines',
      BillingCountry = 'United States',
      BillingStreet = '25 Main St',
      BillingCity = 'Dallas',
      BillingState = 'Texas',
      BillingPostalCode = '75201',
      Fiscal_Code_Italy__c = null,
      VAT_Number__c  = null );
        insert acc;
        
        Contact contact = 
                new Contact(NPD_Client_Satisfaction_Survey__c = 'Yes', 
                            LastName = 'Test', 
                            JobFunction__c = 'Administration', 
                            Email = 'test@npd.com', 
                            ContactType__c = 'NPD Customer',
                            AccountId = acc.Id);
        contact.MailingStateCode='GA';
        contact.MailingCity = 'Alpharetta';
        contact.MailingPostalCode='30009';
        contact.MailingCountryCode='US';
        
        insert contact;
        
        Opportunity opp = new Opportunity(  LOB_Summary__c='/USA - 2500/USA - 3100', 
                                            TotalOpportunityQuantity=3.00, 
                                            SubscriptionAmount__c=375200, 
                                            CloseDate=Date.today(),
                                            TotalContractAmount__c=490755, 
                                            MasterOpportunityDept__c='USA - 2500 - NET', 
                                            Opportunity_Brief_Description__c='Template', 
                                            Probability=99, 
                                            RecordTypeId=oppRecordId,  
                                            Amount=490755.00, 
                                            CurrencyIsoCode='USD', 
                                            Cash_or_Barter__c='Cash', 
                                            Name='Template Opp-USA - 2500-Cloned-USD', 
                                            StageName='Renew',
                                            MasterOpportunityBU__c='FBS',
                                            Master_Opportunity_Sector__c = 'U.S. Hardlines',
                                            AccountId = acc.Id,
                                            Type = 'Existing Customer');

        insert opp;
        
        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        insert prd1;

        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb.id,UnitPrice=50, isActive=true);
        insert pbe1;
              
        OpportunityLineItem oli = new OpportunityLineItem(opportunityid=opp.id);
        oli.Opportunity_Dept__c='test';
        oli.Opportunity_BU__c='test';
        oli.Quantity=1;
        oli.End_Date__c=System.today().addDays(100);
        oli.Start_Date__c=System.today();
        oli.TotalPrice =10;
        oli.pricebookentryid = pbe1.id;
        insert oli;
        
        Map<ID,Opportunity> oppties = new Map<ID,Opportunity>();
        oppties.put(opp.Id, opp);
        
        List<OpportunityContactRole> lstRoles = new List<OpportunityContactRole>();
                
        OpportunityContactRole ocr = 
            new OpportunityContactRole(OpportunityId = opp.Id, 
                            ContactId = contact.Id, 
                            role = 'Billing Contact');

        lstRoles.add(ocr);
        
        OpportunityContactRole ocr1 = 
            new OpportunityContactRole(OpportunityId = opp.Id, 
                            ContactId = contact.Id, 
                            role = 'Shipping Contact');
        lstRoles.add(ocr1);

        OpportunityContactRole ocr2 = 
            new OpportunityContactRole(OpportunityId = opp.Id, 
                            ContactId = contact.Id, 
                            role = 'cc Billing');
        lstRoles.add(ocr2);             
        
        insert lstRoles;
        
        opportunityHandler.OpptyBillingContactInfoHandler(oppties.values() );        
        opportunityHandler.summarize_AU_PA_Sector(oppties.values());
    }
}