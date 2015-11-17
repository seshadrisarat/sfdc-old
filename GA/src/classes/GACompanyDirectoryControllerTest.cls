/************************************************************************************************************
* Name          : GACompanyDirectoryControllerTest
* Created By    : Appirio Offshore (Hemant)
* Created Date  : 28th May 2013
* Description   : Test class for GACompanyDirectoryController class
************************************************************************************************************/

@isTest
private class GACompanyDirectoryControllerTest{
    
    static testMethod void testGACompanyDirectoryController1() {
        Id RecordTypeId_Standard_Contact;
        for(RecordType rt: [Select Id, Name, SobjectType from RecordType Where SobjectType = 'Contact' And Name = 'Standard Contact' And IsActive = true order By Name limit 1]){
        RecordTypeId_Standard_Contact = rt.Id;  
    }   
    
    //inserting contact records 
    Contact cont1 = new Contact(LastName = 'Test _Last_Name_1', email = 'test_1@email.com', MailingCity = 'Greenwich', Title = 'VP');
    Contact cont2 = new Contact(LastName = 'Test _Last_Name_2', email = 'test_2@email.com', MailingCity = 'Greenwich', Title = 'VP');
    if(RecordTypeId_Standard_Contact != null){  
        cont1.RecordTypeId = RecordTypeId_Standard_Contact;
        cont2.RecordTypeId = RecordTypeId_Standard_Contact;
    }
        List<Contact> contList = new List<Contact>{cont1, cont2};
        insert contList;
        
        //insert data for custom setting GA_Company_Directory_Filters__c 
        GA_Company_Directory_Filters__c gaCompDirFltr = new GA_Company_Directory_Filters__c (Location_Picklist__c = 'New York;Greenwich;Palo Alto;Sao Paulo;São Paulo;Beijing;Duesseldorf;Munich;München;Hong Kong;London;Mumbai;Unknown', Name = 'GA_Company_Directory_Filters__1');
        insert gaCompDirFltr;
        
        //testing methods of the class GACompanyDirectoryController 
        GACompanyDirectoryController GACompController = new GACompanyDirectoryController();
    Test.startTest();
    List<Contact> contLst1 = GACompController.contLst;
    
    GACompController.selectedLocation = 'Greenwich';
    GACompController.selectedTitle = 'VP';
    GACompController.selectedRecordType = RecordTypeId_Standard_Contact;
    GACompController.contName = 'Test _Last_Name';
    GACompController.retriveContactData();
    contLst1 = GACompController.contLst;
    GACompController.exportPDF();
    Boolean hsNxt = GACompController.hasNext;
    hsNxt = GACompController.hasPrevious;
    Integer pgSz = GACompController.pageNumber;
    GACompController.previous();
    GACompController.next();
    GACompController.last();
    GACompController.first();
    
    Test.stopTest();
    }
}