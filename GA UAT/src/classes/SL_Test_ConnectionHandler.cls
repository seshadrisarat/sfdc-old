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
private class SL_Test_ConnectionHandler {
    
    // test method for Connection Handler
    static testMethod void testConnectionHandler() 
    {
        // Preparing test Data
        list<Account> lstAccounts = new list<Account>{new Account(Name = 'TestAccount'),
                                                      new Account(Name = 'TestAccount-01'),
                                                      new Account(Name = 'TestAccount-02')};
        insert lstAccounts;
        
        Connection__c objConnection = new Connection__c(From_Account__c = lstAccounts[0].Id, To_Account__c = lstAccounts[1].Id);
        
        test.startTest();
        // Creating Account connectors
        insert objConnection;
        test.stopTest();
        
        //Querying Created Inverse connection through trigger
        Connection__c objInverseConnection = [Select From_Account__c,To_Account__c,Related_Connector__c from Connection__c where Related_Connector__c =: objConnection.Id ];
        
        // Verifying expected results for creation of Inverse connection record.
        system.assertEquals(objInverseConnection.From_Account__c,objConnection.To_Account__c);
        system.assertEquals(objInverseConnection.To_Account__c,objConnection.From_Account__c);
        
        SL_RecursionHelper.setIsAfterInsert(true);
        
        objConnection.From_Account__c = lstAccounts[2].Id;
        update objConnection;
        
        //Querying Created Inverse connection through trigger
        Connection__c objUpdatedInverseConnection = [Select From_Account__c,To_Account__c,Related_Connector__c from Connection__c where Id =: objInverseConnection.Id ];
        
        // Verifying expected results for creation of Inverse connection record.
        system.assertEquals(objUpdatedInverseConnection.From_Account__c,objConnection.To_Account__c);
        system.assertEquals(objUpdatedInverseConnection.To_Account__c,objConnection.From_Account__c);
        
        SL_RecursionHelper.setisAfterUpdate(true);
        
        delete objConnection;
        
        list<Connection__c> lstConnectionRecs = [Select Name from Connection__c];
        system.assertEquals(lstConnectionRecs.size(),0);
        
        Database.undelete(objConnection);
        
        list<Connection__c> lstConnectionRecs1 = lstConnectionRecs = [Select Name from Connection__c];
        system.assertEquals(lstConnectionRecs1.size(),2);
    }
}