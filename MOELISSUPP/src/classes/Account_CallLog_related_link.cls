public with sharing class Account_CallLog_related_link {
    private final Call_Log_related__c curCallLogRel;
    private Id CallLod_Id;
    private Id Company_Id;

    public Account_CallLog_related_link(ApexPages.StandardController stdController) 
    {
        curCallLogRel = (Call_Log_related__c)stdController.getRecord();
        List<Call_Log_related__c> res = [SELECT Call_Log__r.Id,Account__r.Id 
        								 FROM Call_Log_related__c
        								 WHERE Id = :curCallLogRel.Id];
        if (res.size() > 0) {
        	CallLod_Id = res[0].Call_Log__r.Id;
        	Company_Id = res[0].Account__r.Id;
        }
    }
    
    public PageReference autoReload()
    {
        PageReference pageRef = new PageReference('/'+CallLod_Id+'/e?retURL=/'+Company_Id);
		pageRef.setRedirect(true);
        return pageRef;
     }
    public PageReference autoReloadView()
    {
        PageReference pageRef = new PageReference('/'+CallLod_Id);
		pageRef.setRedirect(true);
        return pageRef;
     }
}