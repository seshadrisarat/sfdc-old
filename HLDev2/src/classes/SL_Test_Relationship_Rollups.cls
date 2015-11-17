/**  
* \arg ClassName      : SL_Test_Relationship_Rollups
* \arg JIRATicket     : HL-15
* \arg CreatedOn      : 30/MAY/2014
* \arg LastModifiedOn : 6/NOV/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : Edward Rivera
* \arg Description    : Test class for batch and scheduler
*/
@isTest()
public with sharing class SL_Test_Relationship_Rollups 
{
    private static Integer NUM_EXTERNALS = 10;
    @isTest()
    static void test_Batch_Relationship_Rollups()
    {   
        Id HLRecordtypeId = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'Houlihan_Employee'].Id;
        Id ExternalRTId = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'External_Contact'].Id;
        
        // create a test account
        List<Account> lstAccount = SL_TestSetupUtils.CreateAccount('Account' , 1);
        insert lstAccount;
        // insert a HL contact into that account
        List<Contact> lstContactHL = SL_TestSetupUtils.CreateContact('Contact', 1);
        lstContactHL[0].RecordTypeId = HLRecordtypeId;
        lstContactHL[0].User__c = Userinfo.getUserId();
        insert lstContactHL;
        
        // create a set of external contacts
        List<Contact> lstContactEX = new List<Contact>();
        for(Contact objContact : SL_TestSetupUtils.CreateContact('Contact', NUM_EXTERNALS))
        {
            objContact.AccountId = lstAccount[0].Id;
            objContact.RecordTypeId = ExternalRTId;
            lstContactEX.add(objContact);
        }
        insert lstContactEX;
        System.assertEquals(lstContactEX.size(), NUM_EXTERNALS);
        
        // add an event that took place yesterday
        List<Event> lstEvent = new List<Event>();
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 1))
        {
            objEvent.StartDateTime = datetime.now().addDays(-1);
            objEvent.EndDateTime = datetime.now().addDays(-1);
            objEvent.ActivityDate = date.Today().addDays(-1);
            objEvent.OwnerId = Userinfo.getUserId();
            lstEvent.add(objEvent);
        }
        
        // create multiple events taking place now
        Integer i = 0;
        
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', NUM_EXTERNALS))
        {
            objEvent.ActivityDate = date.Today();
            objEvent.IsAllDayEvent = true;
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhoId = lstContactEX[i].Id;
            lstEvent.add(objEvent);
            i++;
        }
        // create multiple events taking place half a year ago
        i=0;
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', NUM_EXTERNALS))
        {
            objEvent.StartDateTime = datetime.now().addDays(-180);
            objEvent.EndDateTime = datetime.now().addDays(-180);
            objEvent.ActivityDate = date.Today().addDays(-180);
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhoId = lstContactEX[i].Id;
            lstEvent.add(objEvent);
            i++;
        }
        System.assertEquals(lstEvent.size(), NUM_EXTERNALS*2+1);
        insert lstEvent;
        // create task relations for all external contacts to attend the yesterday event
        List<EventRelation> evRelation = new List<EventRelation>();
        for( i = 0; i<NUM_EXTERNALS; i++)
        {
            evRelation.add(new EventRelation(EventId = lstEvent[0].Id, RelationId = lstContactEX[i].Id));
        }
        insert evRelation;
        System.assertEquals(evRelation.size(), NUM_EXTERNALS);
        // create multiple tasks taking place now
        List<Task> lstTask = new List<Task>();
        i=0;
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', NUM_EXTERNALS))
        {
            objTask.ActivityDate = date.Today();
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhoId = lstContactEX[i].Id;
            lstTask.add(objTask);
            i++;
        }

        // create multiple tasks taking place three months ago
        i=0;
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', NUM_EXTERNALS))
        {
            objTask.ActivityDate = date.Today().addDays(-90);
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhoId = lstContactEX[i].Id;
            lstTask.add(objTask);
            i++;
        }
        insert lstTask;
        System.assertEquals(lstTask.size(), NUM_EXTERNALS*2);
        
        // create open and closed engagements
        List<Engagement__c> lstEngagement = new List<Engagement__c>();
        i=0;
        for(Engagement__c objEngagement : SL_TestSetupUtils.CreateEngagement('Engagement__c', 2))
        {
            objEngagement.Client__c = lstAccount[0].Id;
            objEngagement.Subject__c = lstAccount[0].Id;
            if (math.mod(i, 2)==0){
                objEngagement.Stage__c = 'Active';
            }
            else{
                objEngagement.Stage__c = 'Closed';
            }
            lstEngagement.add(objEngagement);   
            i++;
        }
        insert lstEngagement;
        System.assertEquals(lstEngagement.size(), 2);
        // assign internal team to engagements
        i=0;
        List<Engagement_Internal_Team__c> lstEIT = new List<Engagement_Internal_Team__c>();
        for(Engagement_Internal_Team__c objEIT : SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c', 2))
        {
            objEIT.Contact__c = lstContactHL[0].Id;
            objEIT.Engagement__c = lstEngagement[i].Id;
            lstEIT.add(objEIT);
            i++;
        }
        insert lstEIT;
        System.assertEquals(lstEIT.size(), 2);
         
        // assign external team to open and closed engagement
        i=0;        
        List<Engagement_External_Team__c> lstEET = new List<Engagement_External_Team__c>();
        for(Engagement_External_Team__c objEET : SL_TestSetupUtils.CreateEET('Engagement_External_Team__c', NUM_EXTERNALS))
        {
            objEET.Contact__c = lstContactEX[i].Id;
            objEET.Engagement__c = lstEngagement[math.mod(i, 2)].Id;
            lstEET.add(objEET);
            i++;
        }
        insert lstEET; 
        System.assertEquals(lstEET.size(), NUM_EXTERNALS);
        // add a counterparty to engagement
        List<Engagement_Counterparty__c> lstEC = new  List<Engagement_Counterparty__c>();
        i=0;
        for(Engagement_Counterparty__c objEC : SL_TestSetupUtils.CreateEC('Engagement_Counterparty__c', 2))
        {
            objEC.Company__c = lstAccount[0].Id;
            objEC.Engagement__c = lstEngagement[math.mod(i, 2)].Id;
            lstEC.add(objEC);
            i++;
        }
        insert lstEC;
        System.assertEquals(lstEC.size(), 2);
        // assign external contact to counterparty
        i = 0;
        List<Engagement_Counterparty_Contact__c> lstECC = new List<Engagement_Counterparty_Contact__c>();
        for(Engagement_Counterparty_Contact__c objECC : SL_TestSetupUtils.CreateECC('Engagement_Counterparty_Contact__c', NUM_EXTERNALS))
        {
            objECC.Counterparty__c = lstEC[math.mod(i,2)].Id;
            objECC.Contact__c = lstContactEX[i].Id;
            lstECC.add(objECC);
            i++;
        }
        insert lstECC;
        System.assertEquals(lstECC.size(), NUM_EXTERNALS);
        // create an open and closed opportunity
        List<Opportunity__c> lstOpportunity = new List<Opportunity__c>();
        i=0;
        for(Opportunity__c objOpportunity : SL_TestSetupUtils.CreateOpp('Opportunity__c', 2))
        {
            if (math.mod(i,2)==0){
                 objOpportunity.Stage__c = 'Evaluating Prospect';
            }
            else{
                objOpportunity.Stage__c = 'Engaged';
            }
                       
            objOpportunity.Client__c = lstAccount[0].Id;
            lstOpportunity.add(objOpportunity);
            i++;
        }
        insert lstOpportunity;
        // add internal teams to those opportunity
        List<Opportunity_Internal_Team__c> lstOIT = new List<Opportunity_Internal_Team__c>();
        i = 0;
        for(Opportunity_Internal_Team__c objOIT : SL_TestSetupUtils.CreateOIT('Opportunity_Internal_Team__c', 2))
        {
            objOIT.Opportunity__c = lstOpportunity[i].Id;
            objOIT.Contact__c = lstContactHL[0].Id;
            lstOIT.add(objOIT);
            i++;
        }
        insert lstOIT;
        // add external teams to those opportunities, half closed, half opened
        i = 0;
        List<Opportunity_External_Team__c> lstOET = new List<Opportunity_External_Team__c>();
        for(Opportunity_External_Team__c objOET : SL_TestSetupUtils.CreateOET('Opportunity_External_Team__c', NUM_EXTERNALS))
        {
            objOET.Opportunity__c = lstOpportunity[math.mod(i,2)].Id;
            objOET.Contact__c = lstContactEX[i].Id;
            lstOET.add(objOET);
            i++;
        }
        insert lstOET;
        System.assertEquals(lstOET.size(), NUM_EXTERNALS);
        // create relationships between each external contact and the internal contact
        i = 0;
        List<Relationship__c> lstRelationship = new List<Relationship__c>();
        for(Relationship__c objRelationship : SL_TestSetupUtils.CreateRelationship('Relationship__c', NUM_EXTERNALS))
        {
            lstRelationship.add(new Relationship__c(External_Contact__c = lstContactEX[i].Id, HL_Contact__c = lstContactHL[0].Id, Strength_Rating__c = String.ValueOf(math.mod(i,2)+1)));
            i++;
        }
        insert lstRelationship;
        System.assertEquals(lstRelationship.size(), NUM_EXTERNALS);
        
        // run the batch
        Test.startTest();
        SL_Batch_Relationship_Rollups batch = new SL_Batch_Relationship_Rollups();
        Database.executeBatch(batch, 200); 
        Test.stopTest();
        
        List<Relationship__c> lstRelationship1 = [SELECT Id, HL_Contact__c, HL_Contact__r.User__c, External_Contact__c, Last_Activity_Date__c,
                                                Next_Activity_Date__c, Number_of_Activities_LTM__c, Number_of_Deals_on_Client_External_Team__c, Number_of_Deals_Shown__c,
                                                Share_Active_Deal__c, Share_Open_Opp__c, Strength_Rating__c FROM Relationship__c];
        //vlah
        for (Relationship__c rel: lstRelationship1){
            if (rel.Strength_Rating__c=='1'){
                System.assertEquals(date.Today().addDays(-1), rel.Last_Activity_Date__c);
                System.assertEquals(date.Today(), rel.Next_Activity_Date__c);
                System.assertEquals(5, rel.Number_of_Activities_LTM__c);
                System.assertEquals(true, rel.Share_Active_Deal__c);
                System.assertEquals(true, rel.Share_Open_Opp__c);
                System.assertEquals(null, rel.Number_of_Deals_Shown__c);
                System.assertEquals(null, rel.Number_of_Deals_on_Client_External_Team__c);
            }
            else {
                System.assertEquals(date.Today().addDays(-1), rel.Last_Activity_Date__c);
                System.assertEquals(date.Today(), rel.Next_Activity_Date__c);
                System.assertEquals(5, rel.Number_of_Activities_LTM__c);
                System.assertEquals(false, rel.Share_Active_Deal__c);
                System.assertEquals(false, rel.Share_Open_Opp__c);
                System.assertEquals(1, rel.Number_of_Deals_Shown__c);
                System.assertEquals(1, rel.Number_of_Deals_on_Client_External_Team__c);
            }   
        }
        //test_Scheduler_Relationship_Rollups();
    }
     /*
    static void test_Scheduler_Relationship_Rollups()
    {
        SL_Scheduler_Relationship_Rollups batchSchedule = new SL_Scheduler_Relationship_Rollups();
        String scheduleBatch = '0 0 * * * ?';
        System.schedule('Relationship Rollups', scheduleBatch, batchSchedule);  
    }
    */
}