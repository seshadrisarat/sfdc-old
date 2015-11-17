/**
 * \author Vika Osmak 
 * \date 06/23/11
 * \see http://silverline.jira.com/browse/MC-1
 * \brief Test Class for trigger SL_ProjectClientContact on Project_Client_Contact__c
 */
@isTest
private class SL_Test_ProjectClientContact_Trigger 
{
	static testMethod void SL_Test_ProjectClientContact_Trigger_coverage() 
    {
     	Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        Ibanking_Project__c ip = new Ibanking_Project__c(Client__c = acc.Id);
     	insert ip;
        Contact cntct = new Contact();
		cntct.AccountId = acc.Id;
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		insert cntct;
     	Project_Client_Contact__c pcc = new Project_Client_Contact__c(Client_Contact__c = cntct.Id, Moelis_Project__c = ip.Id);
     	insert pcc;
     	update pcc;
     	delete pcc;
    }
}