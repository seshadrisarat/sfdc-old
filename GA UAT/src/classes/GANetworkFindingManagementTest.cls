/*Created By - Anuradha Suthar
Created on - May 20, 2013
Story - S-117095*/

@isTest
public class GANetworkFindingManagementTest{

@isTest
public static void checkGAFInsertUpdateDelete(){
    //Create Test data
    Account acc = Test_Utility.createAccount('TestGAAccount', null, 'GA Vendor');
    Insert acc;
    Contact con1 = Test_Utility.createContact('GAContact1',acc.ID);
    con1.FirstName = 'Test';
    Insert con1;
    Contact con2 = Test_Utility.createContact('GAContact2',acc.ID);
    con2.FirstName = 'Test';
    Insert con2;
    GA_Network_Request__c GANR = Test_Utility.createGANetworkRequest('TestGA1','Active',true);
    
    //Start testing triggers
    Test.startTest();
    //Insert trigger
    GA_Network_Finding__c GAF1 = Test_Utility.createGAFinding(con1.ID,GANR.ID,'Hired',true);        
    GANR = [Select id,Hired_Candidate_s__c from GA_Network_Request__c where id= :GANR.ID];
    system.assertEquals(GANR.Hired_Candidate_s__c,'Test GAContact1');
    //Update trigger
    GAF1.status__c = 'Match';
    update GAF1;
    GA_Network_Finding__c GAF2 = Test_Utility.createGAFinding(con2.ID,GANR.ID,'Hired',true);
    GANR = [Select id,Hired_Candidate_s__c from GA_Network_Request__c where id= :GANR.ID];
    system.assertEquals(GANR.Hired_Candidate_s__c,'Test GAContact2');
    //Delete trigger        
    Delete GAF2;
    GANR = [Select id,Hired_Candidate_s__c from GA_Network_Request__c where id= :GANR.ID];
    system.assertEquals(GANR.Hired_Candidate_s__c,null);
    Test.stopTest();
}
}