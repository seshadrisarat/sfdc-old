@isTest(seeAllData=true)
private class SROC_Group_ViewControllerTest {

    static testMethod void myUnitTest() 
    {
        CORECONNECT__CC_Custom_Group__c objCustom_Group = new CORECONNECT__CC_Custom_Group__c(Name ='Custom Group-01', CORECONNECT__Collaboration_GroupId__c ='TestGroupId');
        insert objCustom_Group;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objCustom_Group);
        SROC_Group_ViewController objGroupView = new SROC_Group_ViewController(sc);
        objGroupView.redirect();
    }
}