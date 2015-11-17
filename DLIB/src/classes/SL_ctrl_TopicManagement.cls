public with sharing class SL_ctrl_TopicManagement {
    
    private Map<Id, TopicItem> unapprovedTopics;
    public String unapprovedTopicsJSON {get;set;}
    private Map<Id, TopicItem> approvedTopics;
    public String approvedTopicsJSON {get;set;}
    private Map<String, String> objKeyToObjName;
    private Map<String, String> objNameToObjKey;
    public String categoriesJSON {get;set;}

    public SL_ctrl_TopicManagement() {

    }
    
    @RemoteAction
    public static List<TopicItem> getUnapprovedTopics() {
        Map<String, Approved_Topics__c> ap = Approved_Topics__c.getAll();
        
        //get topic assignments grouped by their assignment to object types
        List<AggregateResult> tAssignments = [Select COUNT(Id) recordCount, Topic.Id topicId, 
                                                     Topic.Name topicName, EntityKeyPrefix objKey 
                                              From TopicAssignment 
                                              Where Topic.Name Not In : ap.keySet()
                                              Group By EntityKeyPrefix, Topic.Name, Topic.Id 
                                              Order By count(Id) Desc];
        //initialize the map
        Map<Id, TopicItem> unapprovedTopics = new Map<Id, TopicItem>(); 
        //for each aggregate result returned, if we don't have a wrapper for that topic create a new one
        //else update the existing object containing that topics information
        for(AggregateResult ar : tAssignments){
            if(unapprovedTopics.get((Id)ar.get('topicId')) == null){
                unapprovedTopics.put((Id)ar.get('topicId'), new TopicItem(ar));
            }
            TopicItem tempTopic = unapprovedTopics.get((Id)ar.get('topicId'));
            tempTopic.totalCount = tempTopic.totalCount + (Integer) ar.get('recordCount'); // add to the total count
            tempTopic.countByObject.put((String) ar.get('objKey'), (Integer) ar.get('recordCount'));// add this object's count to the map
        }

        for(Topic t : [Select Id, Name From Topic Where Id Not In: unapprovedtopics.keySet() And Name Not In: ap.keySet()]){
            TopicItem newTopicItem = new TopicItem();
            newTopicItem.name = t.Name;
            newTopicItem.totalCount = 0;
            newTopicItem.DT_RowId = t.Id;
            newTopicItem.countByObject = new Map<String, Integer>();
            unapprovedTopics.put(t.Id, newTopicItem);
        }
        
        return unapprovedTopics.values();
    }
    
    @RemoteAction
    public static List<TopicItem> getApprovedTopics() {
        Map<String, Approved_Topics__c> ap = Approved_Topics__c.getAll();
        
        // select all topic assignments where their topic id is of a topic from the above list
        List<AggregateResult> tAssignments = [SELECT COUNT(Id) recordCount, Topic.Id topicId, 
                                                     Topic.Name topicName, EntityKeyPrefix objKey 
                                              FROM TopicAssignment 
                                              WHERE Topic.Name IN : ap.keySet()
                                              GROUP BY EntityKeyPrefix, Topic.Name, Topic.Id 
                                              ORDER BY COUNT(Id) DESC];
        //initialize the map
        Map<Id, TopicItem> approvedTopics = new Map<Id, TopicItem>(); 
        //for each aggregate result returned, if we don't have a wrapper for that topic create a new one
        //else update the existing object containing that topics information
        for(AggregateResult ar : tAssignments){
            if(approvedTopics.get((Id)ar.get('topicId')) == null){
                approvedTopics.put((Id)ar.get('topicId'), new TopicItem(ar, ap.get((String)ar.get('topicName')).Category__c));
            }
            TopicItem tempTopic = approvedTopics.get((Id)ar.get('topicId'));
            tempTopic.totalCount = tempTopic.totalCount + (Integer) ar.get('recordCount'); // add to the total count
            tempTopic.countByObject.put((String) ar.get('objKey'), (Integer) ar.get('recordCount')); // add this object's count to the map
        }
        //create topic wrappers for any topics that are approved but not yet used in the system
        //this should really only be the case early on, ideally all approved topics will be topics
        //that are used frequently
        for(Approved_Topics__c t : ap.values()){
            if(approvedTopics.get(t.Id__c) == null){
                approvedTopics.put(t.Id__c, new TopicItem(t, t.Category__c));
            }
        }
        return approvedTopics.values();
    }
    
    @RemoteAction
    public static Set<String> getCategories() {
        Map<String, Topic_Categories__c> categories = Topic_Categories__c.getAll();
        return categories.keySet();
    }
    
    @RemoteAction
    public static Map<String, List<TopicItem>> editTopic(List<Id> topicId, String newTopicName, String newCategory) {
        //determine if new topic exists; if not, create it
        List<Topic> topics = [Select Id, Name From Topic Where Name =: newTopicName];
        Set<Id> passover = new Set<Id>();
        Topic newTopic;
        if(topics.size() == 0){
            newTopic = new Topic(Name = newTopicName);
            insert newTopic;
        }else{
            newTopic = topics.get(0);
            for(TopicAssignment ta : [Select EntityId, Topic.Name From TopicAssignment Where TopicId =: newTopic.Id]){
				passover.add(ta.EntityId);                
            }
        }
        
        Map<Id, Topic> toDelete = new Map<Id, Topic>([Select Id, Name From Topic Where Id In: topicId]);
        for(Id tId : topicId){
            if(newTopicName == toDelete.get(tId).Name){
                toDelete.remove(tId);
                break;
            }
        }
        
        List<TopicAssignment> newAssignments = new List<TopicAssignment>();
        Map<Id, String> chatterToTopic = new Map<Id, String>();
        
        for(TopicAssignment ta : [Select EntityId, Topic.Name From TopicAssignment Where TopicId In: topicId]){
            if(((String)ta.EntityId).substring(0,3) == '0D5' || ((String)ta.EntityId).substring(0,3) == '0D7'){
                chatterToTopic.put(ta.EntityId, ta.Topic.Name);
            }
            if(passover.contains(ta.EntityId)){
                continue;
            }
            passover.add(ta.EntityId);
            TopicAssignment temp = new TopicAssignment();
            temp.TopicId = newTopic.Id;
            temp.EntityId = ta.EntityId;
            newAssignments.add(temp);
        }
        
        if(newCategory != ''){
            updateApprovedTopics(toDelete.values(), newTopic, newCategory);
        }
         	
        delete toDelete.values();
        upsert newAssignments;

        updateChatter(newTopicName, chatterToTopic);
        
        Map<String, List<TopicItem>> response = new Map<String, List<TopicItem>>();
        
        response.put('unapprovedTopics', getUnapprovedTopics());
        response.put('approvedTopics', getApprovedTopics());
        return response;
    }
    
    private static void updateApprovedTopics(List<Topic> toDelete, Topic toInsert, String category){
        Map<String, Approved_Topics__c> ap = Approved_Topics__c.getAll();
        List<Approved_Topics__c> actualToDelete = new List<Approved_Topics__c>();
        for(Topic t : toDelete){
            actualToDelete.add(ap.get(t.Name));
        }
        
        delete actualToDelete;
        
        if(ap.get(toInsert.Name) == null){
            insert new Approved_Topics__c(Name = toInsert.Name, Id__c = toInsert.Id, Category__c = category);
        }
    }
    
    private static void updateChatter(String newTopic, Map<Id, String> chatterToTopic){
        List<FeedItem> feedItems = [Select Id, Body From FeedItem Where Id In: chatterToTopic.keySet()];
        for(FeedItem fi : feedItems){
            if(newTopic.contains(' ')){
                fi.Body = caseInsensitiveReplaceAll(fi.Body, chatterToTopic.get(fi.Id), '['+newTopic+']');
            }else{
                fi.Body = caseInsensitiveReplaceAll(fi.Body, chatterToTopic.get(fi.Id), newTopic);           
            }
        }
        update feeditems;
        
        List<FeedComment> feedComments = [Select Id, CommentBody From FeedComment Where Id In: chatterToTopic.keySet()];
        for(FeedComment fc : feedComments){
            if(newTopic.contains(' ')){
                fc.CommentBody = caseInsensitiveReplaceAll(fc.CommentBody, chatterToTopic.get(fc.Id), '['+newTopic+']');
            }else{
                fc.CommentBody = caseInsensitiveReplaceAll(fc.CommentBody, chatterToTopic.get(fc.Id), newTopic);
            }
        }
        update feedComments;
    }
    
    private static String caseInsensitiveReplaceAll(String corpus, String target, String replacement){
        String lowerTarget = target.toLowerCase();
        String lowerCorpus = corpus.toLowerCase();
        Integer i = lowerCorpus.indexOf(lowerTarget);
        if(i != -1){
	        String toReplace = corpus.substring(i, lowerTarget.length()+i);
    	    return corpus.replaceAll(toReplace, replacement);
        }else{
		    return corpus;    
        }
    }
    
    /*
     * Approve a topic by assigning it a category and appeding it to that topic category's related topics field
     *
     *
     */
    @RemoteAction
    public static Map<String, List<TopicItem>> approveTopic(List<String> topicNames, String category) {
		Map<Id, Topic> newlyApproved = new Map<Id, Topic>([Select Id, Name From Topic Where Name In: topicNames]);
        Map<String, Approved_Topics__c> ap = Approved_Topics__c.getAll();
        List<Approved_Topics__c> addThese = new List<Approved_Topics__c>();
        for(Topic t : newlyApproved.values()){
            Approved_Topics__c at = ap.get(t.Name);
            if(at == null){
                at = new Approved_Topics__c();
                at.Name = t.Name;
                at.Id__c = t.Id;
                at.Category__c = category;
        		addThese.add(at);
            }
        }
        insert addThese;
        
        Map<String, List<TopicItem>> response = new Map<String, List<TopicItem>>();
        response.put('unapprovedTopics', getUnapprovedTopics());
        response.put('approvedTopics', getApprovedTopics());
        return response;
    }

    /*
     * Unapprove a topic by selecting it's topic category and removing the topic name 
     * from the topic category's related topics field
     *
     */
    @RemoteAction
    public static Map<String, List<TopicItem>> unapproveTopic(List<String> topicNames, List<String> categories) {
        Map<String, Approved_Topics__c> ap = Approved_Topics__c.getAll();
        List<Approved_Topics__c> deleteThese = new List<Approved_Topics__c>();
        for(String name : topicNames){
            Approved_Topics__c at = ap.get(name);
            if(at != null){
        		deleteThese.add(at);
            }
        }
        delete deleteThese;
        
        Map<String, List<TopicItem>> response = new Map<String, List<TopicItem>>();
        response.put('unapprovedTopics', getUnapprovedTopics());
        response.put('approvedTopics', getApprovedTopics());
        return response;
    }

    public class TopicItem {
        public String name;
        public Integer totalCount;
        public Map<String, Integer> countByObject;
        public Id DT_RowId;
        public String DT_RowData;
        public String category;

        public TopicItem(){
            
        }
        
        public TopicItem(AggregateResult ar){
            name = (String) ar.get('topicName');
            DT_RowId = (Id) ar.get('topicId');
            countByObject = new Map<String, Integer>();
            totalCount = 0;
        }

        public TopicItem(AggregateResult ar, String c){
            name = (String) ar.get('topicName');
            DT_RowId = (Id) ar.get('topicId');
            countByObject = new Map<String, Integer>();
            totalCount = 0;
            category = c;
        }

        public TopicItem(Approved_Topics__c t, String c){
            name = t.Name;
            DT_RowId = t.Id__c;
            countByObject = new Map<String, Integer>();
            totalCount = 0;
            category = c;
        }
    }
}