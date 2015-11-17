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
@isTest(seeAllData = true)
private class SL_Test_CreateShipmentsController 
{
    static void createTestData()
    {
        /* Insert Account */        
        Account objAccount = new Account(Name = 'TestAccount');
        insert objAccount;
        
        /* Insert Contact */
        Contact objContact = new Contact(LastName ='TestContact', AccountId = objAccount.Id);
        insert objContact;
        
        /* Getting UPSShipmatePreference record */
        zkups__UPSShipmatePreference__c objShipmentPreference = [SELECT Id, 
                                                                        Name, 
                                                                        zkups__CompanyName__c, 
                                                                        zkups__ShippingStreet__c, 
                                                                        zkups__ShippingCity__c, 
                                                                        zkups__ShippingState__c,
                                                                        zkups__ShippingPostalCode__c 
                                                                   FROM zkups__UPSShipmatePreference__c 
                                                                  WHERE Name = 'ShipmatePreference-0000' LIMIT 1];
        
        /* Insert Literature_Request__c */
        Literature_Requests__c objLiteratureRequest = new Literature_Requests__c(Contact__c = objContact.Id, Contact_Name__c = 'TestContact', Delivery_Method__c = 'TestDelibvery method', Weight__c = 10, UPS_Account__c = objShipmentPreference.Id,
                                                                                 Street__c = '860 Broadway Floor 5', Status__c = 'New', Zip_Postal_Code__c = '10003',
                                                                                 State_Province__c = 'NY', Country__c = 'US', Packaging_Type__c = 'Your Packaging',
                                                                                 Send_By__c = System.today());
        insert objLiteratureRequest;

                
        /* Insert zkups__BulkShipment__c */
        zkups__BulkShipment__c objBulkShipment = new zkups__BulkShipment__c(zkups__ShipmatePreference__c = objShipmentPreference.Id);
        insert objBulkShipment;
        
        /* Insert zkups__CustomAddressSource__c */
        zkups__CustomAddressSource__c objCustomAddress = new zkups__CustomAddressSource__c(Name = 'Literature Request',
                                                                                           zkups__CustomAddressSourceObject__c = 'Literature_Requests__c',
                                                                                           zkups__ShipmentObjectLookupField__c='Literature_Request__c',
                                                                                           zkups__Street1TextLineField__c = 'Street__c',
                                                                                           zkups__CountryField__c = 'Country__c',
                                                                                           zkups__PhoneField__c = 'Recipient_Phone_Number__c',
                                                                                           zkups__CityField__c = 'City__c',
                                                                                           zkups__StateField__c = 'State_Province__c',
                                                                                           zkups__PostalCodeField__c = 'Zip_Postal_Code__c'
                                                                                           );
        insert objCustomAddress;
        
        /* Insert zkups__QueuedShipment__c */
        zkups__QueuedShipment__c objQueuedShipment = new zkups__QueuedShipment__c(zkups__BulkShipment__c = objBulkShipment.Id, zkups__CustomAddressSource__c = 
                                                                                  objCustomAddress.Id, zkups__CustomAddressSourceRecordId__c = objLiteratureRequest.Id,
                                                                                  zkups__LabelImageType__c = 'Thermal 4x6 - EPL2', zkups__ReturnShipment__c = false, 
                                                                                  zkups__PaymentType__c = 'Sender', zkups__ServiceType__c = objLiteratureRequest.Delivery_Method__c,
                                                                                  zkups__WeightDimensionUnits__c = 'LB / IN'    
                                                                                  );
        insert objQueuedShipment;
        
        /* Insert zkups__QueuedPackage__c */
        zkups__QueuedPackage__c objQueuedPackage = new zkups__QueuedPackage__c(zkups__DeclaredValue__c = 0, zkups__Weight__c = objLiteratureRequest.Weight__c, 
                                                           zkups__QueuedShipment__c = objQueuedShipment.Id);
        insert objQueuedPackage;
        
        /* Setting Literatre Request Id */
        ApexPages.currentPage().getParameters().put('Id', objLiteratureRequest.Id); 
    }
    
    static testMethod void myUnitTest() 
    {
        createTestData();
        
        /* Instantiating controller */
        SL_CreateShipmentsController obj = new SL_CreateShipmentsController();
        obj.createShipments();
        obj.processShipment();
        obj.fetchStatusProceed();
    }
}