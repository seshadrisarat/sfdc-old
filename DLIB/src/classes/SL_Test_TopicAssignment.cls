@isTest
// Todo: Test a scenario that should throw an exception
private class SL_Test_TopicAssignment{
    
    static Datetime currentDate;
    static List<TopicAssignment> topicAssignments ;
    static Topic_Category__c testTC;
    static Topic_Category__c testIndustry;
   	private static User [] user = [SELECT email FROM USER where ID = :UserInfo.getUserId()]; 
  
    
    static testmethod void testBatchMethod(){
        testSetup();
        final Integer NUMTOPIC = 5; // no less than 3, adjust along with number of topics below
        List<Topic> topics = new List<Topic>();
        Opportunity testOp = new Opportunity(Name='Test Topic', StageName='Qualified Suspect',CloseDate=currentDate.date());    
        insert testOp;
        
        // NUMTOPIC = the number of topics here        
        topics.add(new Topic(Name='Qimbo'));
        topics.add(new Topic(Name='Extra Test'));
        topics.add(new Topic(Name='Aphids On Patrol'));
        topics.add(new Topic(Name='Vab'));
        topics.add(new Topic(Name='Bamul'));
        insert topics;
        // the target string should be the industry topic, followed by a #, followed by each category's topics, the categories in alphabetical order
        // all separated by a #, each topic separated by a , resulting in:
        String target='Vab # Aphids On Patrol, Extra Test # Bamul, Qimbo';
        
        for (Topic t: topics){
                topicAssignments.add(new TopicAssignment(EntityId=testOp.Id, TopicId=t.Id));        
        }
        insert topicAssignments;
        
        testOp.related_Topics__c='THIS IS INCORRECT';
        update testOp;
        Test.startTest();
        Database.executeBatch(new SL_OpportunityTopicCleanUpBatch('SELECT EntityId, TopicId, EntityKeyPrefix FROM TopicAssignment where EntityKeyPrefix=\'006\'', new String[]{ User[0].email }));
        test.stopTest();
        // test insert
        for (Opportunity o:[select id, name, Related_Topics__c from Opportunity where id = :testOp.Id]){                        
            //System.assert(commaDelimitedLength(o.Related_Topics__c)==NUMTOPIC,'Wrong number of topics in list after insertion, expected '+NUMTOPIC+' and received '+commaDelimitedLength(o.Related_Topics__c));            
            System.assert(o.Related_Topics__c.equals(target),'Failed insert, expected '+target+', received '+o.related_Topics__c+' instead.');   
        }
		SL_Opportunity_Error error = new SL_Opportunity_Error (testOp.ID, 'error', testOp.Name);
        System.debug(error.getId()+ error.getName()+ error.getError());
        
    }
    /*
    @MethodName    : testInsertionAndDeletion
    @Description  : Tests insertion and deletion
    */
    // this method should be changed to duplicate the logic of the code it's testing so that future revisions of the code are checked for regression
    static testmethod void testInsertionAndDeletion(){
        // set up
        testSetup();
        final Integer NUMTOPIC = 5; // no less than 3, adjust along with number of topics below
        List<Topic> topics = new List<Topic>();
        Opportunity testOp = new Opportunity(Name='Test Topic', StageName='Qualified Suspect',CloseDate=currentDate.date());    
        insert testOp;
        
        // NUMTOPIC = the number of topics here        
        topics.add(new Topic(Name='Qimbo'));
        topics.add(new Topic(Name='Extra Test'));
        topics.add(new Topic(Name='Aphids On Patrol'));
        topics.add(new Topic(Name='Vab'));
        topics.add(new Topic(Name='Bamul'));
        insert topics;
        // the target string should be the industry topic, followed by a #, followed by each category's topics, the categories in alphabetical order
        // all separated by a #, each topic separated by a , resulting in:
        String target='Vab # Aphids On Patrol, Extra Test # Bamul, Qimbo';
        
        for (Topic t: topics){
                topicAssignments.add(new TopicAssignment(EntityId=testOp.Id, TopicId=t.Id));        
        }
        insert topicAssignments;
        
        
        // test insert
        for (Opportunity o:[select id, name, Related_Topics__c from Opportunity where id = :testOp.Id]){                        
            System.assert(commaDelimitedLength(o.Related_Topics__c)==NUMTOPIC,'Wrong number of topics in list after insertion, expected '+NUMTOPIC+' and received '+commaDelimitedLength(o.Related_Topics__c));            
            System.assert(o.Related_Topics__c.equals(target),'Failed insert, expected '+target+', received '+o.related_Topics__c);   
        }
        
        // set up comma delimiter test
        Topic commaTopic = new Topic(Name='ForCommaTrouble, Test');
        Topic otherTopic = new Topic(Name='Harbinger');
        insert commaTopic;
        insert otherTopic;
        target='Vab # Aphids On Patrol, Extra Test # Bamul, ForCommaTrouble, Test, Harbinger, Qimbo';
        TopicAssignment testInsertion = new TopicAssignment(EntityId=testOp.Id, TopicId=commaTopic.Id);
        insert testInsertion;
        topicAssignments.add(testInsertion);
        TopicAssignment testInsertion2 = new TopicAssignment(EntityId=testOp.Id, TopicId=otherTopic.Id);
        insert testInsertion2;
        topicAssignments.add(testInsertion2);
        // test comma delimeter insertion into topic name
        for (Opportunity o:[select id, name, Related_Topics__c from Opportunity where id = :testOp.id]){ 
            //System.assert(commaDelimitedLength(o.Related_Topics__c)==NUMTOPIC+3,'Wrong number of topics in list in comma test, expected '+NUMTOPIC+3+' and received '+commaDelimitedLength(o.Related_Topics__c));            
            System.assert(o.Related_Topics__c.equals(target),o.Related_Topics__c+'Failed coma test, expected '+target+', received '+o.related_Topics__c);   
        }
        // set up single deletion test
        delete topicAssignments.get(NUMTOPIC-3);
        topicAssignments.remove(NUMTOPIC-3);
        
        target='Vab # Extra Test # Bamul, ForCommaTrouble, Test, Harbinger, Qimbo';
        // test single deletion
        for (Opportunity o:[select id, name, Related_Topics__c from Opportunity where id = :testOp.id]){                        
            //System.assert(commaDelimitedLength(o.Related_Topics__c)==NUMTOPIC+2,'Wrong number of topics in list after deletion.');            
            System.assert(o.Related_Topics__c.equals(target),'Failed deletion, expected '+target+', received '+o.related_Topics__c);   
        }
        
        delete topicAssignments;  
        
        // test bulk deletion
        for (Opportunity o:[select id, name, Related_Topics__c from Opportunity where id = :testOp.id]){                        
            //System.assert(commaDelimitedLength(o.Related_Topics__c)==0,'List not empty, received '+o.Related_Topics__c);            
            System.assert(o.Related_Topics__c==null,'Failed deletion, expected nothing, received '+o.related_Topics__c+' instead');  
        }
                
    }
    /*
    @MethodName    : testBulkInsertion
    @Description  : Test Insertion with multiple Opportunities
    */
    
    static testmethod void testBulkInsertion() {
        // tests insertion of TopicAssignment objects attached to multiple Opportunities simultaneously
        testSetup();
        final Integer NUMTOPIC=20;
        Map<Id,Opportunity> opportunityRecords = new Map<Id,Opportunity>();
        List<Opportunity> bulkOpps = new List<Opportunity>();
        Topic[] topics = new Topic[NUMTOPIC];
        for (Integer ii = 0; ii < NUMTOPIC; ii++){
            Opportunity o = (new Opportunity(Name=''+ii, StageName='Qualified Suspect',CloseDate=currentDate.date()));
            bulkOpps.add(o);
            topics[ii] = new Topic(Name=''+((NUMTOPIC-1)-ii)*10+'a');
        }
        insert bulkOpps;
        for (Opportunity o: bulkOpps){
            opportunityRecords.put(o.Id, o);
        }
        insert topics;
        for (Opportunity o: opportunityRecords.values()){
            for (Integer ii = 0; ii < integer.valueOf(o.Name); ii++){
                topicAssignments.add(new TopicAssignment(EntityId=o.Id, TopicId=topics[ii].Id));        
            }       
        }  
        // test for bulk updates, make sure all of them are lexographically ordered, the right number of entries are there
        Test.startTest();
        Database.SaveResult[] result = Database.insert(topicAssignments);
        Test.stopTest();
        
        for (Database.SaveResult r: result){
            System.assert(r.isSuccess());
        }
        
        for (Opportunity o:[select id, name, Related_Topics__c from Opportunity where id in :opportunityRecords.keySet()]){                     
            //System.assert(commaDelimitedLength(o.Related_Topics__c)==integer.valueOf(o.Name),'Wrong number of topics in list.');            
            System.assert(isLexographic(o.Related_Topics__c),'Not lexographically ordered.');   
        }
        
    }
    
    /*
    @MethodName     : testSetup
    @Param          : null
    @Description    : Sets up the objects for the test
    */
    
    static private void testSetup(){
        currentDate = System.now();
        topicAssignments = new List<TopicAssignment>();
        // insert some Topic Categories, including an Industry
        
        testTC = new Topic_Category__c(Name = 'Test TC', Category__c ='Test', Related_Topics__c = 'Regular, Aphids On Patrol, Extra Test');
        testIndustry = new Topic_Category__c(Name = 'Test Industry', Category__c ='Industry', Related_Topics__c = 'Vegular, Vab, Ra');
        insert testTC;
        insert testIndustry; 
    }
    /*
    @MethodName     : commaDelimitedLength
    @Param          : relatedTopics - the string in the Related Topics field
    @Description    : Checks the number of comma delimited entries in Related Topics
    */
    static integer commaDelimitedLength(String relatedTopics){
    // assumes a comma-space and # delimited string, returns the number of entries
           if (String.isBlank(relatedTopics))
            return 0;
        String [] categories = relatedTopics.split(' # ');
        list <string> allTopics = new list <string>();
        for (String s: categories){
            String [] split = s.split(', ');
            for (String ss: split){
                System.debug(LoggingLevel.Error, '('+ss+')');
                allTopics.add(ss);
            }
        }
        return allTopics.size();
    }
    
    /*
    @MethodName     : isLexographic
    @Param          : relatedTopics - the string in the Related Topics field
    @Description    : Checks that the lexographic ordering is correct for automatically generated tests; can't be used for 
                      any comma-inclusive Topic entry tests
    */
    static boolean isLexographic(String relatedTopics){
    // assumes a comma-space delimited string, checks to make sure it's lexographically ordered
        if (String.isBlank(relatedTopics))
            return true;
        String[] categories=relatedTopics.split(' # ');
        for (String s: categories){
            String[] split = s.split(', ');
            for (Integer ii=0; ii < split.size()-1; ii++){
                if (split[ii].compareTo(split[ii+1])>0){
                    return false;
                }
            }
        }    
        return true;
    }
}