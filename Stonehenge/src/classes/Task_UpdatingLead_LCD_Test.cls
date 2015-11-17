public class Task_UpdatingLead_LCD_Test {
	public static testMethod void testThis() {
		Lead testLead = new Lead(Status='Open', Phone='123', Lead_Channel__c='Email', LastName='testLastName', Email='qwe@ert.com', Property_Name__c = '10 Downing');
		insert testLead;
		
		Task testTask = new Task(Status='Completed', Type='Call', WhoId=testLead.Id);
		insert testTask;
	}
}