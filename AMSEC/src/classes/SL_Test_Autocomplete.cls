/**
* \arg ClassName      : SL_Test_Autocomplete
* \arg JIRATicket     : AMSEC-39
* \arg CreatedOn      : 09/APRIL/2015
* \arg LastModifiedOn : 09/APRIL/2015
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : Lodhi
* \arg Description    : test class for SL_Autocomplete class.
*/
@isTest
private class SL_Test_Autocomplete 
{
	static Account objAccount;
    static Contact objContact;
    
    static testMethod void createData() 
    {
        objAccount = new Account(Name = 'Test Account 1', Industry = 'Test', Date_of_Last_Round__c = Date.today(), 
                                 Projected_Revenue__c = 556666.65);
        insert objAccount;
        
        Account objAccount1 = new Account();
        objAccount1.Name = 'Test Account 2';
        insert objAccount1;
        
        Account objAccount2 = new Account();
        objAccount2.Name = 'Test Account 2';
        insert objAccount2;
    }

    private testMethod static void Test_Autocomplete()
    {
        createData();
        SL_Autocomplete objAutocomplete = new SL_Autocomplete();

        SL_Autocomplete.findSObjects('Account','Name', 'Test');
		SL_Autocomplete.findSObjects('Account','Name', 'Test\'s');
		SL_Autocomplete.findSObjects('Account','Name', 'Test?*');
		SL_Autocomplete.findSObjects('Account','Name', 'Test');
		SL_Autocomplete.findSObjects('Account','Name', 'Test//');
		SL_Autocomplete.findSObjects('Account','Date_of_Last_Round__c', '4/9//');
		SL_Autocomplete.findSObjects('Account','Projected_Revenue__c', '55//');
		SL_Autocomplete.findSObjects('Account','Industry', 'Test');
		SL_Autocomplete.findSObjects('Account','Phone', 'Test');
		SL_Autocomplete.findSObjects('Account','NumberOfEmployees', '2');
    }
    private testMethod static void Test_Autocomplete_InValidCondition()
    {
        createData();
        SL_Autocomplete objAutocomplete = new SL_Autocomplete();
        SL_Autocomplete.findSObjects('AccountTest','Name','');
    }
}