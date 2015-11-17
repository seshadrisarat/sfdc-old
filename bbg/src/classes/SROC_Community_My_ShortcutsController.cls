public with sharing class SROC_Community_My_ShortcutsController {
    
    private String redirectUrl;
    private CORECONNECT__CC_System_Settings__c setting;
    
    public List<CORECONNECT__CC_Personal_Item__c> MyLinks{
        get;set;
    }
    public CORECONNECT__CC_Personal_Item__c MyLink {
        get;set;
    }
    

    public SROC_Community_My_ShortcutsController(){
        MyLink = new CORECONNECT__CC_Personal_Item__c();
        MyLink.RecordTypeId = Schema.SObjectType.CORECONNECT__CC_Personal_Item__c.getRecordTypeInfosByName().get('My Shortcuts').getRecordTypeId();
        queryMyLinks();
        setting = CORECONNECT__CC_System_Settings__c.getInstance(Site.GetName());
        redirectUrl = setting.CORECONNECT__Community_Path_Name__c + '/' + setting.CORECONNECT__Community_Home__c;
    }

    public Id TargetId {
        get;set;
    }
    
    /**
        only query RecordType.Name = 'MyLinks'
    */
    
    private void queryMyLinks (){
       if(Schema.sObjectType.CORECONNECT__CC_Personal_Item__c.isAccessible()){
       		Id devRecordTypeId = Schema.SObjectType.CORECONNECT__CC_Personal_Item__c.getRecordTypeInfosByName().get('My Shortcuts').getRecordTypeId();   
            MyLinks = [select Id,CORECONNECT__My_Links_Title__c, CORECONNECT__My_Links_URL__c , CORECONNECT__Order__c, CORECONNECT__Category__c
                   from CORECONNECT__CC_Personal_Item__c 
                   where 
                    OwnerId = :UserInfo.getUserId() AND RecordTypeId = :devRecordTypeId order by CORECONNECT__Order__c];
       }
    }

    public PageReference AddMyLink (){
        MyLink.CORECONNECT__Order__c = CORECONNECT.CC_CommunityUtil.returnMyLinksLastOrderNumber() + 1;
        system.debug('Peronal Item Order: ' + MyLink.CORECONNECT__Order__c);
        if(Schema.sObjectType.CORECONNECT__CC_Personal_Item__c.isCreateable() && Schema.sObjectType.CORECONNECT__CC_Personal_Item__c.isUpdateable()){
            system.debug('Personal Item is creatable.');
            upsert MyLink;
        }
        queryMyLinks();
        return null;
    }
    

    public PageReference Cancel(){
        MyLink = new CORECONNECT__CC_Personal_Item__c();
        return new PageReference(redirectUrl);
    }

    public PageReference Remove(){
        for(CORECONNECT__CC_Personal_Item__c p: MyLinks ){
            if(p.Id == TargetId){
                delete p; 
                queryMyLinks();
                TargetId = null;
                return null;
            }
        } 
        return null;
    }

    
    public PageReference SelectRecord(){
        for(CORECONNECT__CC_Personal_Item__c p: MyLinks ){
            if(p.Id == TargetId){
                MyLink = p;
                return null;
            }
        }
        return null;
    }

}