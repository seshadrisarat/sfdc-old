/*
*Class: SL_Test_Organization_Address_Handler
*Description: This test class is used to test Organization Address trigger functionality and its code coverage
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@IsTest
public class SL_Test_Organization_Address_Handler
{
    
      @IsTest
        private static void TestOA()
        {
            Account a = New Account(Name = 'Silverline Test New');
            INSERT a;
            Organization_Address__c oa = new Organization_Address__c(Organization__c = a.id, Primary__c = true, Type__c = 'Practice', 
                                     								  Street_Address_1__c = 'test', Street_Address_2__c = 'test',Street_Address_3__c = 'test', City__c = 'test city',
                                     								 State__c = 'NY', Postal_Code__c = '10001');
            INSERT oa;
            
            Organization_Address__c oa1 = new Organization_Address__c(Organization__c = a.id, Primary__c = true, Type__c = 'Practice', 
                                     								  Street_Address_1__c = 'test1', Street_Address_2__c = 'test1',Street_Address_3__c = 'test1', City__c = 'test city1',
                                     								  State__c = 'NY', Postal_Code__c = '10002');
            insert oa1;
            
             Organization_Address__c oa2 = new Organization_Address__c(Organization__c = a.id, Primary__c = true, Type__c = 'Billing', 
                                     								   Street_Address_1__c = 'test2', Street_Address_2__c = 'test2',Street_Address_3__c = 'test2', City__c = 'test city2',
                                                                       State__c = 'NY', Postal_Code__c = '10003');
            insert oa2;
             oa.Type__c = 'Billing';
           UPDATE oa;
           oa1.City__c='New City';
           oa1.street_address_1__c='576 North State RD';
           oa1.State__c='CT';
           oa1.postal_Code__c='12345';
           oa1.Primary__c= false;
           update oa1;
           oa2.Type__c = 'Practice';
           update oa2;
         
            DELETE oa;
           UNDELETE oa;
            DELETE oa2;
           UNDELETE oa2;
        }

}