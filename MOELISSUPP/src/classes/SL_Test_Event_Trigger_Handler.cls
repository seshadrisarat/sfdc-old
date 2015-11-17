/**
 * \author Vika Osmak 
 * \date 06/23/11
 * \see http://silverline.jira.com/browse/MC-1
 * \brief Test Class for trigger SL_Event on Event
 */
@isTest
private class SL_Test_Event_Trigger_Handler 
{
	static testMethod void SL_Test_Event_Trigger_Handler_coverage() 
    {
     	Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
     	Event ip = new Event(WhoId = cntct.id, DurationInMinutes = 120, ActivityDateTime = datetime.now()); 
     	insert ip;
     	update ip;
     	delete ip;
    } 
}