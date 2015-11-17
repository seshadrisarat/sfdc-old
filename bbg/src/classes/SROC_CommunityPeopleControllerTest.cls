@isTest
private class SROC_CommunityPeopleControllerTest {

    static testMethod void myUnitTest() 
    {
        SROC_CommunityPeopleController objSROC_CommunityPeopleController = new SROC_CommunityPeopleController();  
        String ambassadorIndicatorImage = objSROC_CommunityPeopleController.ambassadorIndicatorImage;
        List<CORECONNECT.CC_CommunityContentWrapper> ListOfUsers = objSROC_CommunityPeopleController.ListOfUsers;
        String FilterOption = objSROC_CommunityPeopleController.FilterOption;
        objSROC_CommunityPeopleController.PeopleIFollow = true; 
        objSROC_CommunityPeopleController.searchString = 'TestSearchString';
        objSROC_CommunityPeopleController.Filter();
        objSROC_CommunityPeopleController.Follow();
        objSROC_CommunityPeopleController.Unfollow();
        List<SelectOption> lstSelectOption =  objSROC_CommunityPeopleController.getUserDepartmentsValues() ;
        Boolean hasNextSet = objSROC_CommunityPeopleController.hasNextSet;
        System.assertEquals(hasNextSet, false);
        Boolean hasPrevSet = objSROC_CommunityPeopleController.hasPrevSet;
        System.assertEquals(hasPrevSet, false);
        Integer PageNumber = objSROC_CommunityPeopleController.PageNumber;
        Integer TotalPages = objSROC_CommunityPeopleController.TotalPages;
        objSROC_CommunityPeopleController.prevSet();
        objSROC_CommunityPeopleController.nextSet();
        objSROC_CommunityPeopleController.GoToPage();
        objSROC_CommunityPeopleController.forwardToLogin(); 
         
    }
}