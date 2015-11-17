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
private class SL_SendApplication_Test
{   
    
    private static final Id CUSTOMER_ID = [SELECT Id FROM RecordType WHERE DeveloperName =: 'PersonAccount' LIMIT 1].Id;
    
    static testMethod void test_SendApplication() 
    {
        //Creating test records
        Account objAccount = new Account(LastName = 'Test Account - sndApp',RecordTypeId=CUSTOMER_ID,PersonEmail = 'test@test1.com');
        insert objAccount;
        
        Opportunity objOpportunity = new Opportunity(Name='Test Opportunity',AccountId = objAccount.Id,
                                                     CloseDate = Date.today(),StageName='Prospecting');
        insert objOpportunity;
        
        Building__c objBuilding = new Building__c(Name = 'Test Building', Street_Address__c = '123', Zip_Code__c = '560');
        insert objBuilding;
        
        Apartment__c objApartment = new Apartment__c(Name = 'Test Apartment', Building__c = objBuilding.Id);
        insert objApartment;
        
        Unit_to_Opportunity_Connector__c objUnitConnector = new Unit_to_Opportunity_Connector__c(Unit__c = objApartment.Id, Opportunity__c = objOpportunity.Id);
        insert objUnitConnector;
        
        SL_ContactRoleAddedForRecipient__c objCustomSetting = new SL_ContactRoleAddedForRecipient__c();
        objCustomSetting.Name = 'Tenant';
        insert objCustomSetting;    
        
        list<Contact_Role__c> lstContactRoles = new list<Contact_Role__c>{ new Contact_Role__c(Person_Account__c = objAccount.Id,
                                                            								   Opportunity__c = objOpportunity.Id,Role__c = 'Tenant',Email__c = 'test@test1.com'),
                                                             
        																   new Contact_Role__c(Person_Account__c = objAccount.Id,
                                                            									Opportunity__c = objOpportunity.Id,Role__c = 'Tenant',Email__c = 'test@test1.com'),
        
																	       new Contact_Role__c(Person_Account__c = objAccount.Id,
																	                           Opportunity__c = objOpportunity.Id,Role__c = 'Tenant',Email__c = 'test@test1.com'),
																	        
																	       new Contact_Role__c(Person_Account__c = objAccount.Id,
																	                           Opportunity__c = objOpportunity.Id,Role__c = 'Tenant',Email__c = 'test@test1.com'),
																	                                                             
																	       new Contact_Role__c(Person_Account__c = objAccount.Id,
																	                           Opportunity__c = objOpportunity.Id,Role__c = 'Tenant',Email__c = 'test@test1.com'),
																	        
																	       new Contact_Role__c(Person_Account__c = objAccount.Id,
                                                                                               Opportunity__c = objOpportunity.Id,Role__c = 'Tenant',Email__c = 'test@test1.com')};
                                                                                               
         insert lstContactRoles;                                                                                     
                                                             
        
        ApexPages.CurrentPage().getparameters().put('id',objOpportunity.Id);
        
        ApexPages.StandardController  controller = new ApexPages.StandardController(objOpportunity);
        SL_SendApplication bsExt = new SL_SendApplication(controller);
        bsExt.lstWrapperClass[0].isChecked = true;
        bsExt.lstApartmentWrapperClass[0].isChecked = true;
        bsExt.sendApplication();
        bsExt.cancel();
        bsExt.nextPageForRecipient();
        bsExt.previousPageForApartment();
        bsExt.nextPageForApartment();   
        bsExt.previousPageForRecipient();
    }
}