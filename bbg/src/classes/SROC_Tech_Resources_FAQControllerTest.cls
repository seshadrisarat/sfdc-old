@isTest
private class SROC_Tech_Resources_FAQControllerTest {

    static testMethod void myUnitTest() 
    {
        SROC_Tech_Resources_FAQController objFAQController = new SROC_Tech_Resources_FAQController();
        Integer intResults = objFAQController.selectedNumOfResults;
        List<selectOption> chatterCategoryList = objFAQController.chatterCategoryList;
        Boolean selectedShowCategories = objFAQController.selectedShowCategories;
        String selectedFaqCategory = objFAQController.selectedFaqCategory;
        objFAQController.doFaqFilter();
        objFAQController.showCategories = true;
        selectedShowCategories = objFAQController.selectedShowCategories;
        System.assertEquals(selectedShowCategories, true);
        objFAQController.numOfResults = 10;
        intResults = objFAQController.selectedNumOfResults;
        System.assertEquals(intResults, 10);
    }
}