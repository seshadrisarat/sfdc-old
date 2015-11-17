/**
 * @Author      : Edward Rivera
 * @ClassName   : SL_Opportunity_Topic_Updater
 * @CreatedOn   : 16 Oct 2014
 * @Test        : SL_Test_TopicAssignment
 * @Description : This is the functionality for updating the related topics field on Opportunities to reflect their tagged topics
 */

public with sharing class SL_Opportunity_Topic_Updater {
	/*
    @MethodName    : updateTopicsOnOpportunities
    @param      : assignments - all affected TopicAssignment objects; includes Topics attached to non-Opportunities
    @Description  : To build the Related Topics field on all affected Opportunities
    */    
    public static List<Set<String>> masterSet = new List<Set<String>>();
    public static boolean isRecursion= false;
    /*
    @MethodName    : updateTopicsOnOpportunities
    @param      : assignments - all affected TopicAssignment objects; includes Topics attached to non-Opportunities
    @Description  : To build the Related Topics field on all affected Opportunities
    */    
    public static List<SL_Opportunity_Error> updateTopicsOnOpportunities(List<TopicAssignment> assignments){
        Set<Id> opportunityIds = new Set<Id>();
        map<Id,set<String>> relatedTopics = new map<ID,set<String>>();
        for(TopicAssignment t:assignments){

            if (t.EntityId.getSObjectType().getDescribe().getName()=='Opportunity'){
                opportunityIds.add(t.EntityId);
            }
        }
        
        if (opportunityIds.isEmpty()){
            return null; // no SOQL or DML necessary, exit here
        }
        for (Id i: opportunityIds){
            // initialize the relatedTopics map
            relatedTopics.put(i,new set<String>());
        }
        // go through all the TopicAssignments
        for(TopicAssignment t:[select id, EntityId, Topic.Name from TopicAssignment where EntityId in :opportunityIds]) {               
            // Add the Topic's name to the set of strings
            relatedTopics.get(t.EntityID).add(t.Topic.Name);
        }
        
        // create a list of Opportunities that need updating
        list<Opportunity> ToUpdate = new list<Opportunity>();
        // create a list of all the category's related topics
        if (!isRecursion){
        	masterSet = populateCategorySet();
            isRecursion = true;
        }
        // For all of the Opportunities that have been affected
        for(ID oppID : relatedTopics.keyset())
        {    
            // add all topics on the Opportunity to a list
            Set<String> topicSet = new Set<String>();
            topicSet.addall(relatedTopics.get(oppID));
            // add the opportunity to the list of Opportunities needing an update with the fully concatenated list
            SL_Related_Topics fieldset = generateRelatedTopics(topicSet);
            ToUpdate.add( new Opportunity(ID = oppID,related_topics__c = fieldset.getTopics(), related_topics_excel__c= fieldset.getExcelTopics()));
        }
        List<SL_Opportunity_Error> errors = new List<SL_Opportunity_Error>();
        Database.SaveResult[] results = Database.update(ToUpdate, false);
        for (Integer ii = 0; ii < results.size(); ii++){
            if (!results[ii].IsSuccess()){
                errors.add(new SL_Opportunity_Error(ToUpdate[ii].ID, String.valueOf(results[ii].getErrors()[0]), toUpdate[ii].name));
            }
        }
		return errors;        
    }

    /*
    @MethodName    : populateCategorySet
    @param      : 
    @Description  : create a list of sets, each set comprising a category's related topics 
    */
    private static List<Set<String>> populateCategorySet(){
        List<Set<String>> categorySetList = new List<Set<String>>();
            
        // query a list of all Topic Categories that will be used to check the related topics against
        List<Topic_Category__c> topicCategories = [select id, category__c, related_topics__c from Topic_Category__c];
        // create a list of each picklist value and map it to the list of topics
        map<String, String> categoryToList = new map<String, String>();
        for (Topic_Category__c tc: topicCategories){
            categoryToList.put(tc.category__c, tc.related_topics__c); 
        }        
        // perform the operation on Industry category first
        Set<String> IndustrySet = new Set<String>();
        IndustrySet.addAll(categoryToList.get('Industry').split(', '));
        
        // add the result into the masterSet list first
        categorySetList.add(IndustrySet);
        // perform the operation for the remaining categories
        List<String> sortedCategories = new List<String>();
        for (String s: categoryToList.keyset()){
            // omit Industry from this list
            if (s!='Industry'){
                sortedCategories.add(s);
            }
        }
        // sort all categories alphabetical order
        sortedCategories.sort();
        
        // for all remaining categories, add their associated topics as a set to the masterSet list
        for (String s: sortedCategories){
            Set<string> genericSet = new set<string>();
            genericSet.addAll(categoryToList.get(s).split(', '));
            categorySetList.add(genericSet);
        }
    
        return categorySetList;
    }
    /*
    @MethodName    : generateRelatedTopics
    @param      : masterSet - a list of all topics in sets by category, topicSet - all the topics related to an Opportunity
    @Description  : generates the Related_Topics__c field in the form 'Industry # (Topics grouped by category delimited by #) # Uncategorized Topics'
    */
    private static SL_Related_Topics generateRelatedTopics(Set<String> topicSet){
        // map each set of topics to an empty list for storing the tagged topics in that category
        map<set<string>, list<string>> masterMap = new map<set<string>,list<string>>();
        for (set<string> st: masterSet){
            masterMap.put(st, new list<string>());
        }            
        for (Set<String>sett: masterSet){
            Set<String> temp = new Set<String>(sett);
            temp.retainAll(topicSet);
            masterMap.get(sett).addAll(temp);
            topicSet.removeAll(temp);
        }         
        // sort all of the lists
        list<string> unitedStrings = new list<string>(); 
        list<string> unitedStringsExcel = new list<string>(); 
        // add each list to the united list, comma delimited
        for (Set<string>sett: masterSet){
            masterMap.get(sett).sort();
            // add an empty string placeholder if no topics exist in the category
            if (!masterMap.get(sett).isEmpty()){
                unitedStrings.add(String.join(masterMap.get(sett),', '));
                unitedStringsExcel.add(String.join(masterMap.get(sett),', '));
            }
            else {
                unitedStringsExcel.add('');
            }
        }
        // add the uncategorized topics
        if (!topicSet.isEmpty()){
            List<String>uncategorized=new List<String>(topicSet);
            uncategorized.sort();
            unitedStrings.add(String.join(uncategorized, ', '));
            unitedStringsExcel.add(String.join(uncategorized, ', '));
        }
        else {
            unitedStringsExcel.add('');
        }
        // join all topic sets together, delimited by ' # '
        return new SL_Related_Topics (String.join(unitedStrings, ' # '), String.join(unitedStringsExcel, ' # ')); 
    }
}