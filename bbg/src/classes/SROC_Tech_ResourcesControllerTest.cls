@isTest
private class SROC_Tech_ResourcesControllerTest {

    static testMethod void myUnitTest() {
        
        SROC_Tech_ResourcesController objTechResource = new SROC_Tech_ResourcesController();
        objTechResource.forwardToLogin();
        objTechResource.doFaqFilter();
        objTechResource.doFilter();
        objTechResource.getCategoryList();
        objTechResource.getChatterCategoryList();
        objTechResource.getZoneId();
        objTechResource.GoToPage();
        objTechResource.nextSet();
        objTechResource.noResults();
        objTechResource.prevSet();
        objTechResource.resetFilter();
        objTechResource.selectCategory();
        objTechResource.selectFilterBy();
        objTechResource.yesResults();
        objTechResource.filterBy = 'Boat_Category';
        objTechResource.getCategoryList();
        Boolean next = objTechResource.hasNextSet;
        Boolean prev = objTechResource.hasPrevSet;
        Boolean result = objTechResource.hasResults;
        objTechResource.PageNumber = 10;
        prev = objTechResource.hasPrevSet;
        System.assertEquals(prev, true);
        objTechResource.currArticleId = 'test';
    }
}