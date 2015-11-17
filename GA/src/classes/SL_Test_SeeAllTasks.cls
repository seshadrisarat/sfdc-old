/**
* @ClassName          : SL_Test_SeeAllTasks
* @JIRATicket         : GA-17
* @CreatedOn          : 10/APR/2015
* @LastModifiedOn     : -
* @CreatedBy          : Pankaj Ganwani
* @ModifiedBy         : -
* @Description        : This class is used to check the functionality of SL_SeeAllTasksController.
*/
@isTest
private class SL_Test_SeeAllTasks 
{
	static List<Task> lstTask;
	static ts2__Job__c objJobOrder;
	
	static void createData()
	{
		objJobOrder = new ts2__Job__c(Name = 'Test Job Order');
		insert objJobOrder;
		
		lstTask = new List<Task>{
									new Task(Subject = 'Test1', Status = 'Open', WhatId = objJobOrder.Id),
									new Task(Subject = 'Test2', Status = 'Open', WhatId = objJobOrder.Id),
									new Task(Subject = 'Test3', Status = 'Open', WhatId = objJobOrder.Id)
								};
		insert lstTask;
	}
	
    static testMethod void checkForRecordDisplay() 
    {
    	createData();
        Apexpages.currentPage().getParameters().put('jobOrderid',objJobOrder.Id);
        
        Test.startTest();
        SL_SeeAllTasksController objController = new SL_SeeAllTasksController();
        Test.stopTest();
        
        System.assertEquals(objController.lstTask.size(),3);
    }
    
    static testMethod void checkForNoRecords() 
    {
    	createData();
        Apexpages.currentPage().getParameters().put('jobOrderid',null);
        
        Test.startTest();
        SL_SeeAllTasksController objController = new SL_SeeAllTasksController();
        Test.stopTest();
        
        System.assertEquals(objController.lstTask.size(),0);
    }
    
    static testMethod void checkForCancel() 
    {
    	createData();
        Apexpages.currentPage().getParameters().put('jobOrderid',objJobOrder.Id);
        
        Test.startTest();
        SL_SeeAllTasksController objController = new SL_SeeAllTasksController();
        objController.cancel();
        Test.stopTest();        
    }
}