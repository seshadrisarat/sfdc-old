@isTest
private class SROC_Featured_GroupsControllerTest {

    static testMethod void myUnitTest() 
    {
        CollaborationGroup collGroup = new CollaborationGroup(Name = 'existed-group-name'+DateTime.now(),	
                                                          CollaborationType = 'Public',
                                            			  CanHaveGuests = false,
                                            			  IsArchived = false,
                                            			  IsAutoArchiveDisabled = true);
		insert collGroup;
        CORECONNECT__CC_Custom_Group__c objCoreConnectCustomGroup = new CORECONNECT__CC_Custom_Group__c(Name='Test Group-01', 
                                                                                                        CORECONNECT__Collaboration_GroupId__c = collGroup.Id);
        insert objCoreConnectCustomGroup; 
        
        CORECONNECT__CC_Home_Page_Item__c objCoreConnectHomePageItem = new CORECONNECT__CC_Home_Page_Item__c (CORECONNECT__Featured_Group__c = objCoreConnectCustomGroup.Id,
                                                                                                              CORECONNECT__Order__c = 1);
        insert objCoreConnectHomePageItem;
        
        SROC_Featured_GroupsController objTestClass = new SROC_Featured_GroupsController();
        List<CORECONNECT.CC_CommunityContentWrapper> ListOfGroups = objTestClass.ListOfGroups;
        objTestClass.numOfGroups = 1;
        List<CORECONNECT.CC_CommunityContentWrapper> lstCoreContentWrapper = objTestClass.queryFeaturedGroups(); 
        System.assertEquals(lstCoreContentWrapper.size(), 1);
    }
}