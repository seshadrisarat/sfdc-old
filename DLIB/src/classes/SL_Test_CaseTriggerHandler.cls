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
private class SL_Test_CaseTriggerHandler 
{

    static testMethod void myUnitTest() 
    {
        Contact objContact=new Contact(LastName='Test');
        insert objContact;
        
        sfLma__License__c objLicense = new sfLma__License__c(sfLma__Subscriber_Org_ID__c = '00De0000005Orpq');
        insert objLicense;
        
        sfLma__License__c objLicense1 = new sfLma__License__c(sfLma__Subscriber_Org_ID__c = '00D300000006fTZ');
        insert objLicense1;
        
        Case objCase=new Case(ContactId = objContact.Id,
        					  Origin='Web',
        					  Status='New',
        					  Reason='Administration Request',
        					  Request_Type__c='Training',
        					  Subscriber_Organization_ID__c=objLicense.sfLma__Subscriber_Org_ID__c,
        					  Subject='Test Subject');
        insert objCase;
        
        
        System.assertEquals([select Id, License__c from Case where id = :objCase.Id ].License__c, objLicense.Id);
        
        Case objCase1=new Case(ContactId = objContact.Id,
         					   Id=objCase.Id,
        					   Origin='Web',
        					   Status='New',
        					   Reason='Administration Request',
        					   Request_Type__c='Training',
        					   Subscriber_Organization_ID__c=objLicense1.sfLma__Subscriber_Org_ID__c,
        					   Subject='Test Subject');
        update objCase1;
        System.assertEquals([select Id, License__c from Case where id = :objCase.Id ].License__c, objLicense1.Id);
    }
}