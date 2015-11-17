@isTest
private class psaSelfAssignmentController_Test
{
	@isTest
	static void test_controller()
	{
		Account a = new Account(Name = 'Text Company');
		insert a;

		Contact c = new Contact(LastName = 'Test Name', pse__Salesforce_User__c = UserInfo.getUserId(), pse__Is_Resource__c = true, pse__Is_Resource_Active__c = true);
		insert c;

		pse__Proj__c p = new pse__Proj__c(Name = 'Test Project', pse__Account__c = a.Id, pse__Is_Active__c = true);
		insert p;

		psaSelfAssignmentController ctrl = new psaSelfAssignmentController();
		ctrl.schedule.pse__Start_Date__c = Date.ValueOf(datetime.now().addDays(-7));
		ctrl.schedule.pse__End_Date__c = Date.ValueOf(datetime.now());
		ctrl.assignment.pse__Project__c = p.Id;

		ctrl.save();

		for (pse__Assignment__c item:[Select Id, Name FROM pse__Assignment__c WHERE id=:ctrl.assignment.Id]) {
			system.assertEquals(item.Name, a.Name + ' - ' + c.LastName);
		}

	}
}