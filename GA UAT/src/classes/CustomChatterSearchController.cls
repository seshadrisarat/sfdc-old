// Name         : CustomChatterSearchController
// Author       : Kapil Choudhary (Appirio Offshore)
// Created Date : 5-January-2013
// Description  : Cloud Spoke Result Class Extended for  T-107258.
// Last Modified: 

public without sharing class CustomChatterSearchController {

    public String baseUrl{get;set;}
    public List<NewsFeed> myfeed{get; set;}
    public string feedItemId {get;set;}
    public string feedCommentText{get;set;}
    public User currentUser {get;set;}
    public FeedComment newFeedComment {get;set;}
    public transient List<NewsFeed> newsFeed{get;set;}
    public transient List<NewsFeed> newsFeedFromComments{get;set;}
    public Map<String, String> mapOfPhoto{get;set;}
    public Map<ID, String> mapOfParentName{get;set;}
    public Map<String, String> mapOfNonOwnerObjects{get;set;}
    public Map<ID, String> mapOfOwnerName{get;set;}
    public Map<ID, sObject> mapOfParentList{get; set;}
    public String searchTag {get; set;}
    public String queryString = '';
    public Map<Id, List<FeedComment>> mapOfComment{get; set;}
    public Map<String, set<Id>> typeSobjectMap{get; set;}
    public List<SelectOption> fieldOrderOptions {get;set;}
    public String dateRange{get; set;}
    public DateTime startDate{get; set;}
    public DateTime endDate{get; set;}
    private Set<Id>addedNewFeedsSet;
    private Date weekstart;
    private Date monthstart;
    private Date lastweekstart;
    private Date lastmonthstart;
    private Set<String> checkedObjects = null;
    public  map<string,string> commentHtmlMap{get;set;}
    
    private String convertHtmlBody(string currBody){
    	if(currBody != null && currBody != ''){
	    	if(currBody.indexOf('\r\n') >=0){
	    		currBody =currBody.replaceAll('\r\n','<br>');
	    	} else if(currBody.indexOf('\r') >=0){
	    		currBody =currBody.replaceAll('\r','<br>');
	    	}else if(currBody.indexOf('\n') >=0){
	    		currBody =currBody.replaceAll('\n','<br>');
	    	} 
    	}
    	return currBody;
    }
    public List<NewsFeed> getNewsFeedList() {
        if(newsFeed == null || newsFeed.size() ==0) {
            searchChatterList();
        }
        return newsFeed;
    }
    public CustomChatterSearchController(){
    	commentHtmlMap = new map<string,string>();
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        feedItemId ='';
        feedCommentText ='';
        currentUser = [select id,name,SmallPhotoUrl from user where id= :Userinfo.getUserId()];
        newFeedComment = new FeedComment();
        addedNewFeedsSet = new set<Id>();
        newsFeed = new List<NewsFeed>();
        searchTag = '';
        fieldOrderOptions = new  List<SelectOption>();
        fieldOrderOptions.add(new SelectOption('CreatedDate','CreatedDate'));
        fieldOrderOptions.add(new SelectOption('Id','Id'));
        mapOfPhoto = new Map<String, String>();
        newsFeed = new List<NewsFeed>();
        newsFeedFromComments = new List<NewsFeed>();
        //newsFeed = getChatterList();
       // getComments();
        for(Integer i=0; i<newsFeed.size(); i++){
            String photourl = [select SmallPhotoUrl from User where Id = :newsFeed[i].CreatedById limit 1].SmallPhotoUrl;
            mapOfPhoto.put(newsFeed[i].CreatedById, photourl);
        }
        system.debug('mapOfPhoto1 '+mapOfPhoto);
        weekstart = System.today().toStartOfWeek();
        monthstart = System.today().toStartOfMonth();
        lastweekstart = Date.newInstance(weekstart.year(), weekstart.month(), (weekstart.day() - 7));
        lastmonthstart = Date.newInstance(monthstart.year(), (weekstart.month()-1), weekstart.day());
        
        
    }
    set<Id> newsFeedFromFeedCommentsSet;
    
    public List<NewsFeed> getChatterList(){
        newsFeedFromFeedCommentsSet = new set<Id>();
        checkedObjects = new Set<String>();
        newsFeedFromComments = new List<NewsFeed>();
        mapOfNonOwnerObjects = new Map<String,String>();
        addedNewFeedsSet = new set<Id>();
        newsFeed = new List<NewsFeed>();
        commentHtmlMap = new map<string,string>();
        //Fetch NeesFeeds From Feed Comments in which the search #tag found.
        if(searchTag != ''){
            string queryS = 'Select FeedItemId, Id From FeedComment f where CommentBody like \'%'+searchTag +'%\' and CommentType = \'TextComment\'';
                    system.debug('>>>>queryS>>>>'+queryS);
                    for(FeedComment fc: database.query(queryS)){
                        newsFeedFromFeedCommentsSet.add(fc.FeedItemId);
                    }
        }
        
        if(dateRange != 'all'){
            if(dateRange == 'thisweek'){
                startDate = Datetime.newInstance(weekstart, System.now().time());
                endDate = System.now();
            } else if(dateRange == 'lastweek'){
                startDate = Datetime.newInstance(lastweekstart, System.now().time()); 
                endDate = Datetime.newInstance(weekstart, System.now().time());
            } else if(dateRange == 'thismonth'){
                startDate = Datetime.newInstance(monthstart, System.now().time()); 
                endDate = System.now();
            } else if(dateRange == 'lastmonth'){
                startDate = Datetime.newInstance(lastmonthstart, System.now().time()); 
                endDate = Datetime.newInstance(monthstart, System.now().time());
            }
				//system.debug('QQQQQ  :: '+ [SELECT Id, Type, CreatedById, CreatedBy.FirstName, CreatedBy.Email, CreatedBy.Name, CreatedDate, ParentId, Parent.Name, Body, Title, LinkUrl, ContentData, ContentFileName,  (SELECT CreatedBy.FirstName, CreatedBy.LastName FROM FeedLikes) FROM NewsFeed WHERE CreatedDate < :enddate AND CreatedDate > :startdate and id not in :newsFeedFromFeedCommentsSet ORDER BY CreatedDate DESC, Id DESC LIMIT 20 ]);
                for(NewsFeed  nF: [SELECT Id, Type, CreatedById, CreatedBy.FirstName, CreatedBy.Email, CreatedBy.Name, CreatedDate, ParentId, Parent.Name, Body, Title, LinkUrl, ContentData, ContentFileName,  (SELECT CreatedBy.FirstName, CreatedBy.LastName FROM FeedLikes) FROM NewsFeed WHERE CreatedDate < :enddate AND CreatedDate > :startdate and id not in :newsFeedFromFeedCommentsSet ORDER BY CreatedDate DESC, Id DESC LIMIT 20 ]){
                    addedNewFeedsSet.add(nF.id);
                    commentHtmlMap.put(nF.id,convertHtmlBody(nF.Body));
                    newsFeed.add(nF);
                    system.debug('nFFFFFF Upper >>> '+nF.id);
                }
                //Fetch NeesFeeds From Feed Comments in which the search #tag found.
                   //system.debug('PPPP  :: '+  [SELECT Id, Type, CreatedById, CreatedBy.FirstName, CreatedBy.Email, CreatedBy.Name, CreatedDate, ParentId, Parent.Name, Body, Title, LinkUrl, ContentData, ContentFileName,  (SELECT CreatedBy.FirstName, CreatedBy.LastName FROM FeedLikes) FROM NewsFeed WHERE id in :newsFeedFromFeedCommentsSet AND CreatedDate < :enddate AND CreatedDate > :startdate ORDER BY CreatedDate DESC, Id DESC LIMIT 20 ]);
                    if(!newsFeedFromFeedCommentsSet.isEmpty()){
                        for(NewsFeed  nF: [SELECT Id, Type, CreatedById, CreatedBy.FirstName, CreatedBy.Email, CreatedBy.Name, CreatedDate, ParentId, Parent.Name, Body, Title, LinkUrl, ContentData, ContentFileName,  (SELECT CreatedBy.FirstName, CreatedBy.LastName FROM FeedLikes) FROM NewsFeed WHERE id in :newsFeedFromFeedCommentsSet AND CreatedDate < :enddate AND CreatedDate > :startdate ORDER BY CreatedDate DESC, Id DESC LIMIT 20 ]){
                             if(!addedNewFeedsSet.contains(nF.id)){
                    			commentHtmlMap.put(nF.id,convertHtmlBody(nF.Body));
                                newsFeedFromComments.add(nf);
                             }
                        }
                        if(!newsFeedFromComments.isEmpty()){
                            newsFeed.addall(newsFeedFromComments);
                        }
                    }
        }else{
                  for(NewsFeed  nF: [SELECT Id, Type, CreatedById, CreatedBy.FirstName, CreatedBy.Email, CreatedBy.Name, CreatedDate, ParentId, Parent.Name, Body, Title, LinkUrl, ContentFileName, (SELECT CreatedBy.FirstName, CreatedBy.LastName FROM FeedLikes) FROM NewsFeed where id not in :newsFeedFromFeedCommentsSet ORDER BY CreatedDate DESC, Id DESC LIMIT 100 ]){
                     addedNewFeedsSet.add(nF.id);
                     if(newsFeedFromFeedCommentsSet.contains(nF.id)){
                          system.debug('Shoud Not Include >:: >>> '+nF.id);
                     }
                     commentHtmlMap.put(nF.id,convertHtmlBody(nF.Body));
                     newsFeed.add(nF);
                     system.debug('nFFFFFF Lower >>> '+nF.id);
                  }
                    system.debug('newsFeed>:: >>> '+newsFeed);
                     system.debug('newsFeedFromFeedCommentsSettttt '+newsFeedFromFeedCommentsSet);
                     system.debug('addedNewFeedsSet>:??? >>> '+addedNewFeedsSet);
                   if(!newsFeedFromFeedCommentsSet.isEmpty()){
                        for(NewsFeed  nF: [SELECT Id, Type, CreatedById, CreatedBy.FirstName, CreatedBy.Email, CreatedBy.Name, CreatedDate, ParentId, Parent.Name, Body, Title, LinkUrl,  ContentFileName,  (SELECT CreatedBy.FirstName, CreatedBy.LastName FROM FeedLikes) FROM NewsFeed where id in :newsFeedFromFeedCommentsSet ORDER BY CreatedDate DESC, Id DESC LIMIT 100 ]){
                             system.debug('nFnFnFnF'+nF);
                    		commentHtmlMap.put(nF.id,convertHtmlBody(nF.Body));
                            newsFeedFromComments.add(nf);
                        }
                        if(!newsFeedFromComments.isEmpty()){
                              newsFeed.addall(newsFeedFromComments);
                            }
                    }
                     system.debug('newsFeedFromComments >:: '+newsFeedFromComments);
                      system.debug('newsFeed>:: Add All >>> '+newsFeed);
        }
        
        mapOfParentName = new Map<ID, String>();
        mapOfParentList = new Map<ID, sObject>();
        mapOfOwnerName = new Map<ID, String>();
        typeSobjectMap = new Map<String, set<Id>>();
        for(Integer i=0; i<newsFeed.size(); i++){
            Id parentid = newsFeed[i].ParentId;
            system.debug('parentid>>>> '+parentid);
            system.debug('newsFeed[i]>> '+i+' '+newsFeed[i]);
            Schema.Sobjecttype objectType = parentid.getSObjectType();
            //system.debug(':Get Name ::'+objectType.getDescribe().getName());
            
           
            Schema.DescribeSObjectResult d = objectType.getDescribe();
            if(! checkedObjects.contains(d.getName())) {
	            Map<String, Schema.SObjectField> FsMap = d.fields.getMap();
	            if(FsMap.get('OwnerId') == null)
	            	mapOfNonOwnerObjects.put(d.getName(),d.getName());            
	            
	            if(!typeSobjectMap.containskey(d.getName())){
	                typeSobjectMap.put(d.getName(),new Set<Id>());
	            }
            	checkedObjects.add(d.getName());
            }
            
                typeSobjectMap.get(d.getName()).add(parentid);

            system.debug('mapOfParentName>>> '+mapOfParentName);
            system.debug('mapOfParentList>>> '+mapOfParentList);
             
        }
        system.debug('typeSobjectMap >>> '+typeSobjectMap);
        for(String objName : typeSobjectMap.keyset()){
            String query ='';
            set<id> keyset = typeSobjectMap.get(objName);
            if(objName == 'Case'){
                query = 'Select Status, OwnerId, Id, ContactId,CaseNumber, AccountId from '+ objName +' where Id in : keyset';
            }else{
                 query = 'select Id, Name';
                  
                 if(objName !='User' && mapOfNonOwnerObjects.get(objName)== null){
                    query += ',OwnerId ';
                 }
                
                 if(objName=='Opportunity'){
                    query +=', AccountId, ExpectedRevenue, CreatedDate, StageName, CloseDate, Amount ';
                 }
                 if(objName=='ContentDocument'){
                 	 query = 'select Id, title , OwnerId';
                 }
                 if(objName=='Dashboard'){
                 	 query = 'select Id, title , CreatedById';
                 }
                 if (mapOfNonOwnerObjects.get(objName)!= null) {
                 	query +=',CreatedById';
                 }
                 query +=' from ' + objName +' where Id in :keyset';
            }
            system.debug('queryyyyy>>>>> '+query);
            for(sObject sObj : Database.query(query)){
                      //sob = sObj.getSObjectType();
                    mapOfParentList.put((ID)sObj.get('id'),sObj);
                    mapOfParentName.put((ID)sObj.get('id'),objName);
                    if(objName !='User' && objName !='Dashboard' && mapOfNonOwnerObjects.get(objName) == null){
                       mapOfOwnerName.put((ID)sObj.get('ownerId'), objName);
                    }
                    if(objName =='Dashboard' || mapOfNonOwnerObjects.get(objName)!= null){
                    	mapOfOwnerName.put((ID)sObj.get('CreatedById'), objName);
                    }
                    
                    
                        //system.debug('Nam:--> '+objName +'>>ID '+sObj.get('id') + 'OBJJJJ >>> '+ob);
            }
        }
        system.debug('mapOfParentName>>> '+mapOfParentName);
        system.debug('mapOfParentList>>> '+mapOfParentList);
        return newsFeed;  
    }
    
    private Boolean validateSearchTag(){
    	if(searchTag == null || searchTag == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please insert a search tag.'));
            return false;
          }
          if(searchTag.length() == 1 && searchTag == '#'){
          	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide a search tag and try again.'));
            return false;
          }
          return true;
    }
    public void searchChatterList(){
    	 if(!validateSearchTag()){
    	 	return ;
    	 }
        if(searchTag != ''){
            if(searchTag.contains('#') == false)
            searchTag = '#'+searchTag;
        }
        newsFeed = getChatterList();
        getComments();
         system.debug('>>>> Upper newsFeednewsFeed  >>> '+newsFeed);
        if(searchTag != ''){
           // if(searchTag.contains('#') == false)
           // searchTag = '#'+searchTag;
            List<NewsFeed> searchedFeed = new List<NewsFeed>();
            Integer recordCoount =0;
            for(Integer i=0; i<newsFeed.size(); i++){
                if(newsFeedFromFeedCommentsSet.contains(newsFeed[i].id)){
                    system.debug('>>>NNN>!@#  ' +i+'   '+newsFeed[i].id);
                    system.debug('>>>W?W?W:: ' +i+'   '+newsFeed[i].Body);
                    searchedFeed.add(newsFeed[i]);
                    continue;
                }
                if(newsFeed[i].Body != null){
                	 system.debug('>>>NNN>???????? ' +i+'   '+newsFeed[i].Body);
                    String post = (String)newsFeed[i].Body;
                    post = post.toUpperCase();
                    /*system.debug('>>>post>>> B4'+post);
                    post = post.replaceAll(',',' ');
                    system.debug('>>>post>>> After'+post);
                    List<String> postArray = post.split(' ');
                    for(Integer j=0; j<postArray.size(); j++ ){
                        if(postArray[j].equalsIgnoreCase(searchTag)){
                            searchedFeed.add(newsFeed[i]);
                        }
                    }*/
                    system.debug('>>>post>>> B4'+post);
                    if(post.contains(searchTag.toUpperCase())){
                        searchedFeed.add(newsFeed[i]);
                         system.debug('>>>post>>> '+ i+' '+post);
                         recordCoount++;
                    }
                    if(recordCoount == 20){
                    	break;
                    }
                }
            }
            newsFeed = searchedFeed;
            
            system.debug('>>>> newsFeedFromComments  >>> '+newsFeedFromComments);
            system.debug('>>>> newsFeednewsFeed  >>> '+newsFeed);
            system.debug('>>>> searchedFeed  >>> '+searchedFeed);
            /*if(!newsFeedFromComments.isEmpty()){
                 newsFeed.addall(newsFeedFromComments);
            }*/
            
        }
        
    }
    
    public void commentAdhocFeed(){
      FeedItem fItem = new FeedItem();
      newFeedComment.FeedItemId = feedItemId;
      newFeedComment.CommentBody = feedCommentText;
      newFeedComment.CreatedById = Userinfo.getUserId();
      insert newFeedComment;
      feedItemId ='';
      feedCommentText ='';
      newFeedComment = new FeedComment();
      searchChatterList();
       getComments();
     
    }
    public void getComments(){
        mapOfComment = new Map<Id, List<FeedComment>>();
        mapOfPhoto = new Map<String, String>();
        Set<Id> feedcommentCreatedById = new  Set<Id>();
        system.debug('mapOfPhoto2 '+mapOfPhoto);
        //List<FeedComment> mainFeedComments = [SELECT Id, ParentId, CommentBody, CreatedDate, CreatedBy.FirstName, CreatedBy.LastName FROM FeedComments ORDER BY CreatedDate DESC LIMIT 40];
        
     /*   for(Integer i=0; i < newsFeed.size(); i++){
            Id postId = newsFeed[i].Id;
            list<FeedComment> comment = new list<FeedComment>();
            for(FeedComment fc :[SELECT Id, ParentId, CommentBody, CreatedDate,CreatedBy.id, CreatedBy.Name, CreatedBy.LastName FROM FeedComment WHERE FeedItemId =:postId ORDER BY CreatedDate LIMIT 40]){
            	comment.add(fc);
            	feedcommentCreatedById.add(fc.CreatedBy.id);
            }
            mapOfComment.put(postId,comment);
            if(mapOfPhoto.containsKey(postId) == false){
                String photourl = [select SmallPhotoUrl from User where Id = :newsFeed[i].CreatedById limit 1].SmallPhotoUrl;
                mapOfPhoto.put(newsFeed[i].CreatedById, photourl);
            }
        }
        */
         Set <String> feedCreatedByIds = new Set <String>();
        for (FeedComment fc :[SELECT Id, ParentId,FeedItemId, CommentBody, CreatedDate,CreatedBy.id, CreatedBy.Name, CreatedBy.LastName FROM FeedComment WHERE FeedItemId in :newsFeed ORDER BY CreatedDate]){
        	if (mapOfComment.get(fc.FeedItemId) == null) {
        		mapOfComment.put(fc.FeedItemId,new list<FeedComment>());
        	}
            commentHtmlMap.put(fc.id,convertHtmlBody(fc.CommentBody));
        	mapOfComment.get(fc.FeedItemId).add(fc);
	       feedCreatedByIds.add(fc.CreatedBy.id);
        }
       
        for(Integer i=0; i < newsFeed.size(); i++){
        	if(mapOfComment.get(newsFeed[i].id) == null)
        		mapOfComment.put(newsFeed[i].id,new list<FeedComment>());
        	feedCreatedByIds.add(newsFeed[i].CreatedById);
        }
        system.debug('feedCreatedByIds>>> '+feedCreatedByIds);
        for (User u : [select SmallPhotoUrl from User where Id in :feedCreatedByIds]) {
        	String photourl = u.SmallPhotoUrl;
        	 mapOfPhoto.put(u.id, photourl);
        }
        for(id cId : mapOfPhoto.keyset()){
             if(feedcommentCreatedById.contains(cID)){
             	feedcommentCreatedById.remove(cID);
             }	
        }
        system.debug('feedCreatedByIds>>> After '+feedCreatedByIds);
        for(user usr : [select id,SmallPhotoUrl from User where Id in: feedcommentCreatedById ]){
        	  mapOfPhoto.put(usr.id, usr.SmallPhotoUrl);
        }
        system.debug(' mapOfPhotoUUU >>> '+ mapOfPhoto);
    }
    
    public void changeDateAndSearch(){
    	if(!validateSearchTag()){
    	 	return ;
    	 }
        searchChatterList();
    }
    
}