@isTest
private class SROC_Content_ViewControllerTest {

    static testMethod void myUnitTest() 
    {
            Id ScheduledContent_RecordType_Id = Schema.SObjectType.CORECONNECT__CC_Community_Content__c.getRecordTypeInfosByName().get('ScheduledContent').getRecordTypeId();
			Id FreeText_RecordType_Id = Schema.SObjectType.CORECONNECT__CC_Community_Content__c.getRecordTypeInfosByName().get('FreeText').getRecordTypeId();
			Id MemberBenefits_RecordType_Id = Schema.SObjectType.CORECONNECT__CC_Community_Content__c.getRecordTypeInfosByName().get('Member Benefits').getRecordTypeId();
        
        
            CORECONNECT__CC_Community_Content__c objcoreConnect = new CORECONNECT__CC_Community_Content__c(recordTypeId = ScheduledContent_RecordType_Id);
            insert objcoreConnect;
            ApexPages.StandardController sc = new ApexPages.StandardController(objcoreConnect); 
            
            SROC_Content_ViewController objSROC_Content_ViewController = new SROC_Content_ViewController(sc);   
            objSROC_Content_ViewController.redirect(); 
            
            CORECONNECT__CC_Community_Content__c objcoreConnect2 = new CORECONNECT__CC_Community_Content__c(recordTypeId = FreeText_RecordType_Id);
            insert objcoreConnect2;
            ApexPages.StandardController sc2 = new ApexPages.StandardController(objcoreConnect2); 
            SROC_Content_ViewController objSROC_Content_ViewController2 = new SROC_Content_ViewController(sc2);   
            objSROC_Content_ViewController2.redirect(); 
            
            CORECONNECT__CC_Community_Content__c objcoreConnect3 =  new CORECONNECT__CC_Community_Content__c(recordTypeId = MemberBenefits_RecordType_Id);
            insert objcoreConnect3;
            ApexPages.StandardController sc3 = new ApexPages.StandardController(objcoreConnect3); 
            SROC_Content_ViewController objSROC_Content_ViewController3 = new SROC_Content_ViewController(sc3);   
            objSROC_Content_ViewController3.redirect();  
    }
}