/**  
* \arg ClassName        : SL_Test_OpportunityTriggerHandler
* \arg JIRATicket       : NPD-89
* \arg CreatedOn        : 10/Sep/2015
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Sandeep
* \arg ModifiedBy       : 
* \arg Description      : Test class for Opportunity Handler.
*/
@isTest
private class SL_Test_OpportunityTriggerHandler 
{
	private static testMethod void testOpportunityHandler() 
	{
        Practice__c objPractice = new Practice__c(Name = 'Test Practice');
        insert objPractice;
        
        RecordType objRecordType = [SELECT Id FROM RecordType WHERE SObjectType =: 'Account' AND DeveloperName =: 'Practice_Account' LIMIT 1];
	    RecordType objRecordType1 = [SELECT Id FROM RecordType WHERE SObjectType =: 'Account' AND DeveloperName =: 'Parent_Account' LIMIT 1];
	    
	    
	    Account objAccount = new Account(Name = 'Test Account', RecordTypeId = objRecordType.Id, BillingCity = 'London');
        insert objAccount;
        Account objAccount1 = new Account(Name = 'Test Account1', Practice__c = objPractice.Id, ParentId = objAccount.Id, RecordTypeId = objRecordType1.Id, BillingCity = 'London');
        insert objAccount1;
        
        Opportunity objOpportunity = new Opportunity(Name = 'Test Opp1', AccountId = objAccount1.Id, StageName = 'No Contact',
                                                            Amount = 3000, Billing_Details__c = 'London', Billing_Contact_Info_Address__c = 'London',
                                                            CloseDate = System.today());
        insert objOpportunity;
        // system.assertEquals([SELECT Parent_Account__c FROM Opportunity WHERE Id =: objOpportunity.Id].Parent_Account__c, objAccount1.ParentId);
        // system.assertEquals([SELECT Practice__c FROM Opportunity WHERE Id =: objOpportunity.Id].Practice__c, objPractice.Id);
	}
	
	private static testMethod void test() 
	{
        Account a = new Account(Name='testAccount', Industry='Other', Type='Prospect', BillingCity = 'London');
        insert a; 
        
        Product2 prod = new Product2(Name = 'Base Motor Oil Add-on: Census Divisions/Regions', Family = 'Premium Services', Product_Group__c = 'Store Level Enabled',
                                                Product_Identifier__c = 'Test Identifier - 1', isActive = true, Product_Offering__c = 'POS Geographies/Store Groups' );
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        
        
        Opportunity opp = new Opportunity(Name='Test', Account = a,  NextStep='test', PriceBook2Id = pricebookId, CloseDate = System.today(),
                                          AccountId=a.Id, StageName='Decision', Probability = 100, Billing_Details__c = 'Test',
                                          Billing_Contact_Info_Address__c = 'test@test.com', ContractTerm__c = 5, 
                                          Shipping_Contact_Info_Address__c = 'test');
        insert opp; 
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive = true );
        insert customPB;
        
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity = 1, OpportunityId = opp.Id, 
                                                                        UnitPrice = 0.01, PriceBookEntryId = standardPrice.Id,
                                                                        netsuite_conn__Start_Date__c = Date.Today().addDays(-2),netsuite_conn__End_Date__c = Date.Today().addDays(2),
                                                                        netsuite_conn__From_Contract_Item_Id__c = 'Test',
                                                                        netsuite_conn__Item_Category__c = 'Test',
                                                                        netsuite_conn__List_Rate__c = 1,
                                                                        netsuite_conn__NetSuite_Item_Id_Import__c = 'Test',
                                                                        netsuite_conn__NetSuite_Item_Key_Id__c = '1112223Test',
                                                                        netsuite_conn__Pushed_From_NetSuite__c = true,
                                                                        netsuite_conn__Term_Contract_Pricing_Type__c = 'Test',
                                                                        netsuite_conn__Terms__c = 2);
        try{
            insert OPplineitem2;
        }catch(Exception ex)
        {
            //to handle manage package error(Attempt to de-reference a null object) in netsuite_conn.CeligoUpdateOpportunityLineItem: execution of BeforeInsert
            system.debug(ex);
        }
        opp.StageName = 'Cancelled';
        opp.Type = 'Cancellation';
        update opp;
        delete opp;
	}
}