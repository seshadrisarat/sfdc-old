/* Author : Bryan Anderson*/
@isTest
private class SL_Test_SharingController
{
    static testmethod void testSharingController()
    {
        Account a = new Account(Name = 'Test');
        insert a;
        Schema.SObjectType s = SL_SharingController.identifySObject(a.Id);
		
		String sObjName = s.getDescribe().getName();
        
        String shareName = SL_SharingController.getShareObjName(s.getDescribe().getName());
        
        SL_SharingController.sharingParams[] spList = new SL_SharingController.sharingParams[]{};
            
        Group g = [Select Id From Group WHERE DeveloperName = 'AllInternalUsers'];
            
        SL_SharingController.sharingParams sp = new SL_SharingController.sharingParams(a.Id,g.Id,'Edit');
        
        spList.add(sp);
        
        a = a.clone();
        
        sObject[] sObjList = SL_SharingController.createSObjectList(spList, shareName,sObjName,false);
        
        SL_SharingController.modifySharing(spList);
        
    }
}