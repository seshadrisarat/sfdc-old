@isTest
private class SROC_CreateContentControllerTest {

    static testMethod void myUnitTest() 
    {
        SROC_CreateContentController objCreateContent = new SROC_CreateContentController(); 
        
        Attachment att = objCreateContent.att ;
        objCreateContent.createFreeText();
        objCreateContent.FreeTextEndDateString = '12/27/2009';
        objCreateContent.validateForFreeText();
        System.assertNotEquals(objCreateContent.CC.CORECONNECT__FreeText_End_Date__c, null);
        objCreateContent.FreeTextEndDateString = '123456';
        objCreateContent.validateForFreeText();
        System.assertEquals(objCreateContent.CC.CORECONNECT__FreeText_End_Date__c, Date.parse('12/27/2009'));
        objCreateContent.createFreeText();
        objCreateContent.FreeTextDesiredPublishDateString = '10/27/2015 10:20 AM';
        objCreateContent.createFreeText();
        objCreateContent.createScheduledContent();
        objCreateContent.EndDateTimeString = '10/27/2015 10:20 AM';
        objCreateContent.createScheduledContent();
        objCreateContent.StartDateTimeString = '10/27/2015 10:20 PM';
        objCreateContent.createScheduledContent();
        objCreateContent.cancelFreeText();
        objCreateContent.cancelScheduledContent();
        objCreateContent.forwardToLogin();
        objCreateContent.CC.CORECONNECT__FreeText_Desired_Publish_Date__c = Date.today();
        objCreateContent.CC.CORECONNECT__FreeText_Desired_Publish_Date__c = Date.today() + 12;
        objCreateContent.validateForFreeText(); 
        
        objCreateContent.CC.CORECONNECT__Start_Date__c = Date.today();
        objCreateContent.CC.CORECONNECT__End_Date__c = Date.today() + 10;
        objCreateContent.validateForScheduledContent();
        objCreateContent.StartDateTimeString = null;
        objCreateContent.CC.CORECONNECT__Start_Date__c = null;
        objCreateContent.CC.CORECONNECT__End_Date__c = null; 
        objCreateContent.validateForScheduledContent(); 
    }
}