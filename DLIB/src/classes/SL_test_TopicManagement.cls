@isTest
public class SL_test_TopicManagement {
	@testSetup 
    static void setup() {
        Library_Topic__c lt = new Library_Topic__c(Name = 'Test DLT');
        insert lt;
        
        List<Topic> topics = new List<Topic>();
        topics.add(new Topic(Name = 'Test Topic 1'));
        topics.add(new Topic(Name = 'Test Topic 2'));
        topics.add(new Topic(Name = 'Test Topic 3'));
        topics.add(new Topic(Name = 'Test Topic 4'));
        topics.add(new Topic(Name = 'Test Topic 5'));
        insert topics;
        
        List<TopicAssignment> tas = new List<TopicAssignment>();
        tas.add(new TopicAssignment(TopicId = topics.get(0).Id, EntityId = lt.Id));
        tas.add(new TopicAssignment(TopicId = topics.get(1).Id, EntityId = lt.Id));
        tas.add(new TopicAssignment(TopicId = topics.get(2).Id, EntityId = lt.Id));
        tas.add(new TopicAssignment(TopicId = topics.get(3).Id, EntityId = lt.Id));
        tas.add(new TopicAssignment(TopicId = topics.get(4).Id, EntityId = lt.Id));
        insert tas;
        
        Topic_Category__c tc = new Topic_Category__c(Name = 'test', Category__c = 'test', Related_Topics__c = 'Test Topic 5, Test Topic 4');
        insert tc;
    }

    static testMethod void testPageLoad(){
        SL_ctrl_TopicManagement page = new SL_ctrl_TopicManagement();
        
        List<Object> unapprovedTopics = (List<Object>)JSON.deserializeUntyped(page.unapprovedTopicsJSON);
        List<Object> approvedTopics = (List<Object>)JSON.deserializeUntyped(page.approvedTopicsJSON);
        List<Object> cats = (List<Object>)JSON.deserializeUntyped(page.categoriesJSON);
        
        System.assertEquals(unapprovedTopics.size(), 3);
        System.assertEquals(approvedTopics.size(), 2);
        System.assertEquals(cats.size(), 1);
    }
    
    static testMethod void testEditTopic(){
        Map<Id, Topic> topics = new Map<Id, Topic>([SELECT Id FROM Topic WHERE Name = 'Test Topic 1' OR Name = 'Test Topic 2']);
        List<Id> topicIds = new List<Id>();
        topicIds.addAll(topics.keySet());
        SL_ctrl_TopicManagement.editTopic(topicIds, 'Test Topic 4', new List<String>(), '');
        
		List<Topic> editedTopics =  [SELECT Id FROM Topic];
		System.assertEquals(3, editedTopics.size());        
    }
    
    static testMethod void testDeleteTopic(){
        
    }
    
    static testMethod void testApproveTopic(){
        
    }
    
    static testMethod void testUnapproveTopic(){
        
    }
}