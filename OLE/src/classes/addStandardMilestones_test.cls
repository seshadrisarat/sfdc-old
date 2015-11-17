@isTest
private class addStandardMilestones_test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
//Test converage for the myPage visualforce page

PageReference pageRef = Page.milestones;

Test.setCurrentPageReference(pageRef);
        
//create a test project
        projects__c project=new projects__c();
        project.Project_Start_Date__c = Date.today();
        insert project;
        
System.currentPageReference().getParameters().put('id', project.id);

// create an instance of the controller
AddStandardMilestones myPageCon = new AddStandardMilestones ();

//try calling methods/properties of the controller in all possible scenarios

// to get the best coverage.

//first add milestones to the project
string result = myPageCon.AddStandardMilestones();

//try adding milestones again to trigger the else statement
result = myPageCon.AddStandardMilestones(); 
//test all methods in class
result = myPageCon.getResult();

}
}