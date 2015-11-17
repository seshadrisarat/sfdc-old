@isTest
public class SL_Manage_Assumption_Test_Method 
{

    static testMethod void testMethodSL_ManageAssumption()
    {
    	Project__c objProject = new Project__c(Name='PO1',Estimated_Start_Date__c=Date.today());
		insert objProject;
		
		Change_Order__c objCO = new Change_Order__c(Name='CO-1',Stage__c='Needs Analysis',	Project__c=objProject.Id, Close_Date__c = date.today());
		insert objCO;
		
		List<Assumption__c> lstAssumption = new List<Assumption__c>();
		Assumption__c objAssumption = new Assumption__c(Name='Assumption',Task_Type__c = 'All,Configuration',Component__c = 'All,Account',Industries__c = 'All,Investment Banking',Assumption_Detail__c = 'Test Detail');
    	lstAssumption.add(objAssumption);
    	Assumption__c objAssumption1 = new Assumption__c(Name='Assumption1',Task_Type__c = 'All,Configuration',Component__c = 'All,Account',Industries__c = 'All,Investment Banking',Assumption_Detail__c = 'Test Detail');
        lstAssumption.add(objAssumption1);
    	Assumption__c objAssumption2 = new Assumption__c(Name='Assumption2',Task_Type__c = 'Configuration',Component__c = 'Account',Industries__c = 'Investment Banking',Assumption_Detail__c = 'Test Detail');
    	lstAssumption.add(objAssumption2);
    	
    	insert lstAssumption;
    	
    	Project_Assumption__c objPA = new Project_Assumption__c(Assumption__c = objAssumption.Id,Assumption_Detail_One_time_use__c='Test',Change_Order__c=objCO.Id);
    	insert objPA;
    	Project_Assumption__c objPA1= new Project_Assumption__c(Assumption__c = objAssumption1.Id,Assumption_Detail_One_time_use__c='Test1',Change_Order__c=objCO.Id);
    	insert objPA1;
    	
    	ApexPages.currentPage().getParameters().put('coId',objCO.Id);
    	SL_Manage_Assumptions_Controller objMAController = new SL_Manage_Assumptions_Controller();
    	objMAController.getExistingAssumptions();
    	objMAController.getAssumptions();
    	objMAController.addSelected();
    	objMAController.prev();
    	objMAController.next();
    	objMAController.first();
    	objMAController.last();
    	system.assertEquals(objMAController.lstExistingAssumptionWrapper.size(), 2);
        PageReference newPageRef = objMAController.back();
    	objMAController.addSelected();
    	objMAController.strAssumptionId =  objAssumption2.Id;
    	objMAController.addSelected();
    	objMAController.strSearchText = 'assum ';
    	objMAController.refresh();
    	objMAController.filterAssumption = new Assumption__c(Name='Assumption',Task_Type__c = 'Configuration',Component__c = 'Account',Industries__c = 'Investment Banking');
    	objMAController.strFilterText = 'industries';
    	objMAController.removeFiltersAndSearchText();
    	objMAController.strFilterText = 'taskType';
    	objMAController.removeFiltersAndSearchText();
    	objMAController.strFilterText = 'components';
    	objMAController.removeFiltersAndSearchText();
    	objMAController.strFilterText = 'search';
    	objMAController.removeFiltersAndSearchText();
    	objMAController.refresh();
    	objMAController.lstExistingAssumptionWrapper[0].isSelected = true;
    	objMAController.addSelected();
    	objMAController.removeSelected();
    	objMAController.resetFilter();
    	objMAController.strSearchText = '% _ xz';
    	objMAController.refresh();
    	system.assertEquals(objMAController.lstExistingAssumptionWrapper.size(), 3);
    	objMAController.createNewAssumption();
    	objMAController.newAssumption = new Assumption__c(Assumption_Detail__c='test');
    	objMAController.createNewAdHocAssumption();
    	objMAController.newAssumption =  new Assumption__c(Name='Assumption7',Task_Type__c = 'Configuration',Component__c = 'Account',Industries__c = 'Investment Banking',Assumption_Detail__c='test');
    	objMAController.createNewAssumption();
    }
}