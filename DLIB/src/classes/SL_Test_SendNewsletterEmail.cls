/**
* \arg ClassName  : SL_Test_SendNewsletterEmail
* \arg JIRATicket : SILVERLINE-273
* \arg CreatedOn  : 1-7-2014
* \arg ModifiedBy : Pankaj Ganwani
* \arg Description: This class is works as test class for SL_SendNewsletterEmail controller
*/
@isTest(SeeAllData = true)
private class SL_Test_SendNewsletterEmail 
{
    static testMethod void myUnitTest() 
    {
        String strEmployeeRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =:'Employee'].Id;
        
        Newsletter__c objNewsLetter = new Newsletter__c(Approved_to_Send__c = true, Delivery_Updates__c = 'Test DOCUMENT_IMAGE_ID=abcdefghijklmnopq');
        insert objNewsLetter;
        
        SL_DefaultSenderEmail__c objSenderEmail = new SL_DefaultSenderEmail__c(Sender_Email_Address__c = 'test@salesforce.com', Name = 'Default1 Sender');
        insert objSenderEmail;
        
        List<Contact> lstContact = new List<Contact>{
        												new Contact(LastName = 'Test Contact 1', Email = 'test@salesforce.com', pse__Is_Resource_Active__c = true, RecordTypeId = strEmployeeRecordTypeId),
        												new Contact(LastName = 'Test Contact 2', Email = 'test@salesforce.com', pse__Is_Resource_Active__c = true, RecordTypeId = strEmployeeRecordTypeId),
        												new Contact(LastName = 'Test Contact 3', Email = 'test@salesforce.com', pse__Is_Resource_Active__c = true, RecordTypeId = strEmployeeRecordTypeId),
        												new Contact(LastName = 'Test Contact 4', Email = 'ts@this.com', pse__Is_Resource_Active__c = true, RecordTypeId = strEmployeeRecordTypeId)
        											};
        insert lstContact;
        
        Apexpages.currentPage().getParameters().put('Id',objNewsLetter.Id);
        Apexpages.currentPage().getParameters().put('type','Send');
        SL_SendNewsletterEmail objSendEmail = new SL_SendNewsletterEmail();
        objSendEmail.sendNewsletterEmail();
        
        Apexpages.currentPage().getParameters().put('type','Test');
        SL_SendNewsletterEmail objSendEmailTest = new SL_SendNewsletterEmail();
        objSendEmailTest.sendNewsletterEmail();
    }
}