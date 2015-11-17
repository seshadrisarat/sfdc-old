/**
*  ClassName      : SL_Test_SL_HomePageOpenActivities 
*  JIRATicket     : HIL-33
*  CreatedOn      : 24/SEP/2015
*  ModifiedBy     : Sanath
*  Description    : This is Test class for SL_HomePageOpenActivitiesController class.
*/

@isTest
private class SL_Test_SL_HomePageOpenActivities
 {
    /*
        * MethodName        : testForOpenTasks
        * param             : -
        * Description       : This function will be testing for Open activities assigned to logged in user.
    */
	private static testMethod void testForOpenTasks() 
	{
	    List<Note__c> lstNotes = new List<Note__c>();
	    Id currentUserId = userinfo.getuserid();  
	    for(Integer i=0; i< 10; i++)
	    {
	       Note__c objNote = new Note__c(Type__c ='Task', Status__c='Open', OwnerId=currentUserId);
	       lstNotes.add(objNote);
	    }
	    insert lstNotes;
	    Test.startTest();
	    PageReference pageRef1 = Page.SL_HomePageOpenActivities;
        SL_HomePageOpenActivitiesController ctrl = new SL_HomePageOpenActivitiesController();
        Test.setCurrentPage(pageRef1);
        
        //Assert to check if the pageBlock is rendered with the list of records or not.
        system.assert(ctrl.renderPageBlock);
        
        Test.stopTest();
	}
    
     /*
        * MethodName        : testForNegation
        * param             : -
        * Description       : This function will be testing negative use cases.
    */
	private static testMethod void testForNegation() 
	{
	    List<Note__c> lstNotes = new List<Note__c>();
	    Id currentUserId = userinfo.getuserid();  
	    for(Integer i=0; i< 10; i++)
	    {
	       Note__c objNote = new Note__c(Type__c ='Task', Status__c='CLosed', OwnerId=currentUserId);
	       lstNotes.add(objNote);
	    }
	    insert lstNotes;
	    Test.startTest();
	    PageReference pageRef1 = Page.SL_HomePageOpenActivities;
        SL_HomePageOpenActivitiesController ctrl = new SL_HomePageOpenActivitiesController();
        Test.setCurrentPage(pageRef1);
        
        //Assertion to check the page block is not rendered when there is no records meeting the criteria.
        system.assert(ctrl.renderPageBlock != true);
        
        Test.stopTest();
	}
}