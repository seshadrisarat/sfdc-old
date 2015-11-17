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
@isTest
private class SL_Test_RenewalOpportunityBatch {

    static testMethod void testRenewalOppBatch() 
    {
        String strNewLeaseOppRecordType = [select Name,sobjectType,DeveloperName 
                                          from RecordType where sobjectType = 'Opportunity' and Name = 'New Lease Opportunity' ].Id;
        
        ///Start of Creating test data
        Account objAccount = new Account(Name = 'Test Account');
        insert objAccount;
        
        Building__c objBuilding = new Building__c(Name = 'Test Building', Street_Address__c = 'Test Address',Zip_Code__c = '97654' );
        insert objBuilding;
        
        Apartment__c objApartment = new Apartment__c(Name = 'Test Apartment-01',Apartment_Status__c = 'Leased - Not Available',Building__c = objBuilding.Id);
        insert objApartment;
        
        Lease__c objLease = new Lease__c(Name = 'Test Lease',End_Date__c = Date.today(),Type__c = 'FAIR_MARKET',Apartment__c = objApartment.Id ); 
        insert objLease;
        
        Opportunity objOpportunity = new Opportunity(Name = 'Test Opportunity-01',Lease__c = objLease.Id,StageName = 'Closed-Won',CloseDate = Date.today(),RecordTypeId = strNewLeaseOppRecordType );
        insert objOpportunity;
        
        SL_RenewalBatchTimeSpan__c objRenewalBatchTimeSpan = new SL_RenewalBatchTimeSpan__c(Name = 'NumberOfDays',Fair_Market_Days__c = 1,Fair_Market_Renewal_Days__c=1,
                                                                                            Rent_Stabilized_Days__c =3,Rent_Stabilized_Renewal_Days__c=2);
        insert objRenewalBatchTimeSpan;
        
        list<SL_RenewalBatchMapping__c> lstRenewalBatchMapping = new list<SL_RenewalBatchMapping__c>{ new SL_RenewalBatchMapping__c(Name='StageName',Lease_Opportunity_Field_Api_Name__c = 'StageName'),
                                                                                                      new SL_RenewalBatchMapping__c(Name='CloseDate',Lease_Opportunity_Field_Api_Name__c = 'CloseDate')};
        ///End of Creating test data
        
        insert lstRenewalBatchMapping;
        
        string strQuery = 'SELECT Id,Name, StageName, CloseDate,Asking_Rent__c ,OwnerId, Lease_End_Date__c, Bed_Bug_Rider__c, Apartment__c, Lease__c,'
                  + 'AccountId, Preferred_Apartment_Type__c, Best_Contact__c, Budget_Max__c, Budget__c, Comments_from_Website__c, Existing_Security_Deposit__c, First_Appointment_Date__c,' 
                  + 'First_Call_Date__c, First_Email_Date__c, Last_Appointment_Date__c, LeadSource, Payment_Method__c, Previous_Lease_Rent__c, Previous_Opportunity__c,'
                  + 'Tenant_Referral__c, Type_of_Credit_Card__c, Amount, Lease_Type__c'
                  +' FROM Opportunity'
                  +' WHERE RecordTypeId =: NEW_LEASE_RECORDTYPE_ID'; 
                  
        Id NEW_LEASE_RECORDTYPE_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND  Name = 'New Lease Opportunity'].Id;          
        
        system.assert([select Name from Opportunity].size() == 1);
        Test.StartTest();
            SL_RenewalOpportunitySchedulerCaller objRenOppSched = new SL_RenewalOpportunitySchedulerCaller();
            
            SL_RenewalOpportunityBatch objRenewalOpportunityBatch = new SL_RenewalOpportunityBatch(strQuery,NEW_LEASE_RECORDTYPE_ID,Date.Today(),
                                                                                               Date.Today(),Date.Today(),
                                                                                               Date.Today(), 'Fair Market',
                                                                                               'Fair Market Renewal','Rent Stabilized',
                                                                                               'Rent Stabilized Renewal');
            database.executebatch(objRenewalOpportunityBatch, 200); 
        Test.StopTest();
        
        ///Check if a renewal Opportunity is inserted
        system.assert([select Name from Opportunity].size() == 2);
        
    }
}