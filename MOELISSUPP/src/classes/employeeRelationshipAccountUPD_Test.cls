public class employeeRelationshipAccountUPD_Test {

    static testMethod void myUnitTest() {
        Contact testContact = new Contact(FirstName='test', LastName='testL');
        insert testContact;

    	ID UserID = UserInfo.getUserId();
        Employee_Profile__c emplObj = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        emplObj.User_ID__c = UserID;
        insert emplObj;

        Employee_Relationships__c er = new Employee_Relationships__c();
        er.Contact__c = testContact.Id;
        er.Employee__c = emplObj.ID;
        insert er;
    }
    
}