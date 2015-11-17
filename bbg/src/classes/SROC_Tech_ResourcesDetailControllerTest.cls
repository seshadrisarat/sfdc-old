@isTest
private class SROC_Tech_ResourcesDetailControllerTest {

    static testMethod void myUnitTest() 
    {
        FAQ__kav objFAQ = new FAQ__kav(Title = 'faqtitle', Summary = 'Test Summary-01', URLName = 'faqtitle');
        insert objFAQ;
        objFAQ  = [Select Id, Title, Summary, URLName, KnowledgeArticleId from FAQ__kav where Id = :objFAQ.Id LIMIT 1];
        
        KbManagement.PublishingService.publishArticle(objFAQ.KnowledgeArticleId, true);
        ApexPages.currentPage().getParameters().put('Id', objFAQ.KnowledgeArticleId);
        SROC_Tech_ResourcesDetailController objRDetail = new SROC_Tech_ResourcesDetailController();
        System.assertEquals(objRDetail.article.Id, objFAQ.Id);
        objRDetail.addBookmark();
    }
}