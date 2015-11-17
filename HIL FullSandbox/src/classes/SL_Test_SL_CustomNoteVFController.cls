/**
*  ClassName      : SL_Test_SL_CustomNoteVFController 
*  JIRATicket     : HIL-33
*  CreatedOn      : 24/SEP/2015
*  ModifiedBy     : Sanath
*  Description    : This is Test class for SL_CustomNoteVFController class.
*/

@isTest
private class SL_Test_SL_CustomNoteVFController 
{  
    /*
        * MethodName        : testForHousehold
        * param             : -
        * Description       : This function will be testing different use cases for Household object.
    */
	private static testMethod  void testForHousehold () 
	{
        List<Relationship_Group__c> lstRelationshipGroups = new List<Relationship_Group__c>();
        List<Account> lstAccount = new List<Account>();
        List<Note__c> lstNotes = new List<Note__c>();
        List<Note__c> lstOpenNotes = new List<Note__c>();
        List<Note__c> lstNotesForAcc = new List<Note__c>();
        List<Note__c> lstOpenNotesForAcc = new List<Note__c>();
        List<Note__c> lstNotesToDelete = new  List<Note__c>();
    
        SL_CustomNoteVFBlockSize__c objCustSettings = new SL_CustomNoteVFBlockSize__c(Name = 'BlockSize', BlockSize__c =5);
        insert objCustSettings;
  
        List<RecordType> rtypes = [Select Name, 
                                          Id, 
                                          DeveloperName 
                                   From RecordType 
                                   where sObjectType='Relationship_Group__c' 
                                   and isActive=true 
                                   and DeveloperName = 'HL_Household'];  

        for(Integer i=0; i<= 5; i++)
        {
            Relationship_Group__c objRelationshipGroup = new Relationship_Group__c(Name = 'Test'+i,RecordTypeId =rtypes[0].Id );
            lstRelationshipGroups.add(objRelationshipGroup);
        }
        insert lstRelationshipGroups;
    
        for(Integer i=0; i<= 5; i++)
        {
            Note__c objNotes = new Note__c( Relationship_Group__c = lstRelationshipGroups[0].Id);
            lstNotes.add(objNotes);
        }   
        insert lstNotes;  

        for(Integer i=0; i<= 20; i++)
        {
            Note__c objNotes = new Note__c( Relationship_Group__c = lstRelationshipGroups[0].Id, Status__c='Open', Type__c ='Task');
            lstOpenNotes.add(objNotes);
        }
        insert lstOpenNotes;

        lstOpenNotes[0].Status__c='Closed';
        update lstOpenNotes;

        for(Integer i=0; i<= 20; i++)
        {
            Account objAcc = new Account(Name = 'Test');
            lstAccount.add(objAcc);
        }
        insert lstAccount;

        ApexPages.StandardController stdController = new ApexPages.StandardController(lstRelationshipGroups[0]);
        Test.startTest();
            PageReference pageRef1 = Page.SL_CustomNoteVFHousehold;
            PageReference pageRef2 = Page.SL_CustomNoteVFforOpenTasks_Household;
            PageReference pageRef3 = Page.SL_CustomNoteVFforClosedTasks_Household;
            pageRef1.getParameters().put('id', String.valueOf(lstRelationshipGroups[0].Id));
            pageRef2.getParameters().put('id', String.valueOf(lstRelationshipGroups[0].Id));
            pageRef3.getParameters().put('id', String.valueOf(lstRelationshipGroups[0].Id));
            SL_CustomNoteVFController ctrl = new SL_CustomNoteVFController(stdController);
            Test.setCurrentPage(pageRef1);
            ctrl.getprev();  
            ctrl.getnxt();
            ctrl.fetchAllOpenTasksForHousehold();
            ctrl.beginning();
            ctrl.next();
            ctrl.previous();
            ctrl.end();   
            ctrl.fetchAllNonTaskTypeNotes();
            ctrl.beginning();
            ctrl.next();
            ctrl.previous();
            ctrl.end();   
            ctrl.fetchAllClosedTasksForHousehold();
            ctrl.beginning();
            ctrl.getprev();
            ctrl.next();
            ctrl.previous();
            ctrl.end();

    
            for(Note__c objTask : [Select Id from Note__c where Type__c != 'Task' and Relationship_Group__c =:lstRelationshipGroups[0].Id])
            {
              lstNotesToDelete.add(objTask);
            }
            if(lstNotesToDelete != null)
              delete lstNotesToDelete;
            ctrl.fetchAllNonTaskTypeNotes();
            
            //Asserts to check if any record which doesn't meet the criteria enters the list of records to display.
            system.assert(ctrl.size == 0); 
            
            lstNotesToDelete.clear();

            for(Note__c objTask : [Select Id from Note__c where Type__c = 'Task' and Relationship_Group__c =:lstRelationshipGroups[0].Id and Status__c='Open'])
            {
              lstNotesToDelete.add(objTask);
            }
            if(lstNotesToDelete != null)
              delete lstNotesToDelete;
            ctrl.fetchAllOpenTasksForHousehold();

            //Asserts to check if any record which doesn't meet the criteria enters the list of records to display.
            system.assert(ctrl.size == 0);
            
            ctrl.fetchAllClosedTasksForHousehold();

            //Negative asserts check to check whether the size of list is updated or not. This shouldn't be zero! 
            system.assertNotEquals(ctrl.size , 0);

            lstNotesToDelete.clear();

            for(Note__c objTask : [Select Id from Note__c where Type__c = 'Task' and Relationship_Group__c =:lstRelationshipGroups[0].Id and Status__c='Closed'])
            {
              lstNotesToDelete.add(objTask);
            }
            if(lstNotesToDelete != null)
              delete lstNotesToDelete;

            ctrl.fetchAllClosedTasksForHousehold();

            //Now that we deleted the records meeting the criteria, the size should be zero
            system.assert(ctrl.size == 0);


        Test.stopTest();     

	}

   /*
        * MethodName        : testForClient
        * param             : -
        * Description       : This function will be testing different use cases for Clients object.
    */
  private static testMethod void testForClient() 
  {
        List<Account> lstAccount = new List<Account>();
        List<Note__c> lstNotes = new List<Note__c>();
        List<Note__c> lstOpenNotes = new List<Note__c>();
        List<Note__c> lstNotesToDelete = new  List<Note__c>();

        SL_CustomNoteVFBlockSize__c objCustSettings = new SL_CustomNoteVFBlockSize__c(Name = 'BlockSize', BlockSize__c =5);
        insert objCustSettings;

        for(Integer i=0; i<= 5; i++)
        {
            Account objAcc = new Account(Name = 'Test'+i);
            lstAccount.add(objAcc);
        }
        insert lstAccount;

        for(Integer i=0; i<= 20; i++)
        {
            Note__c objNotes = new Note__c( Account_del__c = lstAccount[0].Id);
            lstNotes.add(objNotes);
        }
        insert lstNotes;  

        for(Integer i=0; i<= 20; i++)  
        {
            Note__c objNotes = new Note__c( Account_del__c = lstAccount[0].Id, Status__c='Open', Type__c ='Task');
            lstOpenNotes.add(objNotes);
        }
        insert lstOpenNotes;

        lstOpenNotes[0].Status__c='Closed';
        update lstOpenNotes;   

        ApexPages.StandardController stdController = new ApexPages.StandardController(lstAccount[0]);
        Test.startTest();
            PageReference pageRef1 = Page.SL_CustomNoteVFforClient;
            pageRef1.getParameters().put('id', String.valueOf(lstAccount[0].Id));
            SL_CustomNoteVFController ctrl = new SL_CustomNoteVFController(stdController);
            Test.setCurrentPage(pageRef1);  
            ctrl.fetchAllNonTaskTypeNotesForClient();
            ctrl.beginning();
            ctrl.next();
            ctrl.previous();
            ctrl.end();   
            ctrl.fetchAllOpenTasksForClient();
            ctrl.beginning();
            ctrl.next();
            ctrl.previous();
            ctrl.end();   
            ctrl.fetchAllClosedTasksForClient();

            ctrl.beginning();
            ctrl.getprev();
            ctrl.next();
            ctrl.previous();
            ctrl.end();
            ctrl.getprev();

            system.assertEquals(ctrl.getprev() , true);
            system.assertEquals(ctrl.getnxt() , true);

            for(Note__c objTask : [Select Id from Note__c where Type__c != 'Task' and Account_del__c =:lstAccount[0].Id])
            {
              lstNotesToDelete.add(objTask);
            }
            if(lstNotesToDelete != null)
              delete lstNotesToDelete;
            ctrl.fetchAllNonTaskTypeNotesForClient();
            
            //Asserts to check if any record which doesn't meet the criteria enters the list of records to display.
            system.assert(ctrl.size == 0); 
            
            lstNotesToDelete.clear();

            for(Note__c objTask : [Select Id from Note__c where Type__c = 'Task' and Account_del__c =:lstAccount[0].Id and Status__c='Open'])
            {
              lstNotesToDelete.add(objTask);
            }
            if(lstNotesToDelete != null)
              delete lstNotesToDelete;
            ctrl.fetchAllOpenTasksForClient();

            //Asserts to check if any record which doesn't meet the criteria enters the list of records to display.
            system.assert(ctrl.size == 0);
            
            ctrl.fetchAllClosedTasksForClient();

            //Negative asserts check to check whether the size of list is updated or not. This shouldn't be zero! 
            system.assertNotEquals(ctrl.size , 0);

            lstNotesToDelete.clear();

            for(Note__c objTask : [Select Id from Note__c where Type__c = 'Task' and Account_del__c =:lstAccount[0].Id and Status__c='Closed'])
            {
              lstNotesToDelete.add(objTask);
            }
            if(lstNotesToDelete != null)
              delete lstNotesToDelete;

            ctrl.fetchAllClosedTasksForClient();

            //Now that we deleted the records meeting the criteria, the size should be zero. 
            system.assert(ctrl.size == 0);
         Test.stopTest(); 
  }   

    /*
        * MethodName        : testForWrongSobjectId
        * param             : -
        * Description       : This function will be testing for negative use case i.e. when the inline VF page runs for 
                              an object other than Household and Clients.
    */
  private static testMethod void testForWrongSobjectId() 
  {
    Contact objCon = new Contact(LastName='Test');
    insert objCon;

    SL_CustomNoteVFBlockSize__c objCustSettings = new SL_CustomNoteVFBlockSize__c(Name = 'BlockSize', BlockSize__c =5);
    insert objCustSettings;
    ApexPages.StandardController stdController = new ApexPages.StandardController(objCon);
    Test.startTest();
      PageReference pageRef1 = Page.SL_CustomNoteVFforClient;
      pageRef1.getParameters().put('id', String.valueOf(objCon.Id));
      SL_CustomNoteVFController ctrl = new SL_CustomNoteVFController(stdController);
      Test.setCurrentPage(pageRef1);  

      ctrl.getprev();
      ctrl.beginning();
      ctrl.getprev();
      ctrl.next();
      ctrl.previous();  
      ctrl.end();
      ctrl.getprev();

      //Asserts to check the code doesn't execute for objects other than Household and Clients and Prospects
      system.assert(ctrl.size == 0);
    Test.stopTest(); 
   
  }
}