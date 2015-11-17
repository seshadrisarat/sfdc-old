@isTest
public with sharing class SL_Test_TopicDescriptionWidget 
{

	static testMethod void test_SL_TopicDescriptionWidget()
	{
		String widgetType = 'SL_IntranetTopicDescription';
		Region__c objRegion = new Region__c(Name = 'testRegion'+widgetType);
        insert objRegion;
        
        Page__c objPage = new Page__c(Name = 'testPage'+widgetType);
        insert objPage;
        
        PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
        insert objPageRegion;
        
        Widget__c objWidget = new Widget__c(Name = 'testWidget'+widgetType ,Type__c = widgetType);
        insert objWidget;
        
        PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c( Page_Region__c = objPageRegion.id, Widget__c = objWidget.id,
																	        Page_Region__r = objPageRegion, Widget__r = objWidget,
																	        Configuration__c = '');
        insert objPageRegionWidget;


        Topic objTopic01 = new Topic(Name='TestTopic01',Description='Testing Description for TestTopic01');
		insert objTopic01;

		PageRegionWidget__c objPRWidget = [Select Name From PageRegionWidget__c Where Id =: objPageRegionWidget.Id];

		new SL_IntranetTopicDescriptionController().getMyImpl();

		SL_IntranetTopicDescriptionController.getData(objPRWidget.Name,String.valueof(objTopic01.Id));

		SL_IntranetTopicDescription objTopicDescription = new SL_IntranetTopicDescription();
		objTopicDescription.newComponent();	
	} 
}