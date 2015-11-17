public class Contact_Relationships_Upd_Test {

    static testMethod void testThis() {
        Account testAccount1 = new Account(Name='testAccount1');
        Account testAccount2 = new Account(Name='testAccount2');
		insert testAccount1;
		insert testAccount2;
        
		Contact testContact = new Contact(AccountId=testAccount1.Id,FirstName='testFirstName', LastName='testLastName');
    	insert testContact;

    	ID UserID = UserInfo.getUserId();
        Employee_Profile__c emplObj = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        emplObj.User_ID__c = UserID;
        insert emplObj;
    	
    	Employee_Relationships__c testER = new Employee_Relationships__c(Contact__c=testContact.Id);
		testER.Employee__c = emplObj.ID;
    	insert testER;
    	
    	testContact.AccountId = testAccount2.Id;
    	update testContact;
    	
    }

}