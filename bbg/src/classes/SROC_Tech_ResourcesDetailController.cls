public with sharing class SROC_Tech_ResourcesDetailController {
	
	public SObject article {get;set;}
	
	private String articleId;
	
	public String articleType {get; private set;}
	
	public String articleTypeLabel {get;private set;}
	
	public Boolean isError {get;set;}
	
	public Boolean isOwner {get;private set;}
	
	public CORECONNECT__CC_Personal_Item__c bookmarkItem {get;set;}
	
	private Map<String,String> describeMap;
	private Map<String,String> describeMapLabel;
	
	public SROC_Tech_ResourcesDetailController()
	{
		try {
			
		this.isError = false;
		this.isOwner = SROCUtilities.isOwner();
		this.articleId = ApexPages.currentPage().getParameters().get('Id');
		
		createDescribeMap();
		
		this.articleType = retrieveArticleType(this.articleId);
		
		this.articleTypeLabel = retrieveArticleTypeLabel(this.articleId);
		
		String QUERY = 'SELECT '; 
						QUERY += 'ArchivedById,';
						QUERY += 'ArchivedDate,';
						QUERY += 'ArticleNumber,';
						QUERY += 'ArticleType,';
						QUERY += 'Boat_Category__c,';
						QUERY += 'Body__c,';
						QUERY += 'Brand__c,';
						QUERY += 'CreatedById,';
						QUERY += 'CreatedDate,';
						QUERY += 'Filename__c,';
						QUERY += 'File_Url__c,';
						QUERY += 'FirstPublishedDate,';
						QUERY += 'Id,';
						QUERY += 'IsDeleted,';
						QUERY += 'IsLatestVersion,';
						QUERY += 'IsVisibleInApp,';
						QUERY += 'IsVisibleInCsp,';
						QUERY += 'IsVisibleInPkb,';
						QUERY += 'IsVisibleInPrm,';
						QUERY += 'KnowledgeArticleId,';
						QUERY += 'Language,';
						QUERY += 'LastModifiedDate,';
						QUERY += 'LastModifiedById,';
						QUERY += 'LastPublishedDate,';
						QUERY += 'Manual_Type__c,';
						QUERY += 'Model_Description__c,';
						QUERY += 'Model__c,';
						QUERY += 'Other_Data__c,';
						QUERY += 'OwnerId,';
						QUERY += 'PublishStatus,';
						QUERY += 'SourceId,';
						QUERY += 'Summary,';
						QUERY += 'SystemModstamp,';
						QUERY += 'Title,';
						QUERY += 'UrlName,';
						QUERY += 'VersionNumber,';
						QUERY += 'Year__c';
		QUERY += ' FROM ' + this.articleType; 
		QUERY += ' WHERE knowledgeArticleId = \'' + this.articleId + '\' AND PublishStatus = \'online\' LIMIT 1';
		
		System.debug('KAV QUERY: ' + QUERY);
		
		
			try {
				this.article = Database.query(QUERY)[0];
			} catch(QueryException qe) {
				this.isError = true;
			}
			
			queryBookmarkItem();
			
		} catch (Exception e) {
			this.isError = true;
		}
		//this.article = [SELECT ArchivedById,ArchivedDate,ArticleNumber,ArticleType,Boat_Category__c,Brand__c,CreatedById,CreatedDate,Filename__c,File_Url__c,FirstPublishedDate,Id,IsDeleted,IsLatestVersion,IsVisibleInApp,IsVisibleInCsp,IsVisibleInPkb,IsVisibleInPrm,KnowledgeArticleId,Language,LastModifiedById,LastModifiedDate,LastPublishedDate,Manual_Type__c,Model_Description__c,Model__c,Other_Data__c,OwnerId,PublishStatus,SourceId,Summary,SystemModstamp,Title,UrlName,VersionNumber,Year__c FROM Component_Manual__kav WHERE knowledgeArticleId = :this.articleId AND PublishStatus = 'online'];
		
	}
	
	public PageReference addBookmark() {
		
		PageReference pr =  new PageReference(ApexPages.currentPage().getUrl() + '?id=' + this.articleId);
		
		try {
			insertBookmarkItem();
			pr.setRedirect(true);
		}catch(Exception e) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: ' + e));
		}
		
		return pr;
	}
	
	private void insertBookmarkItem() {
		
		if(this.articleTypeLabel != null && this.articleId != null && this.articleId != '' && this.article != null && this.bookmarkItem == null)
		{
			Id devRecordTypeId = Schema.SObjectType.CORECONNECT__CC_Personal_Item__c.getRecordTypeInfosByName().get('Support Documentation').getRecordTypeId();
			
			this.bookmarkItem = new CORECONNECT__CC_Personal_Item__c();
			this.bookmarkItem.CORECONNECT__My_Links_Title__c = (String)this.article.get('Title');
			this.bookmarkItem.CORECONNECT__My_Links_URL__c = Site.getBaseUrl() + '/SROC_Tech_ResourcesDetail?id=' + this.articleId;
			System.debug('bookmarkItem Link: '+this.bookmarkItem.CORECONNECT__My_Links_URL__c);
			this.bookmarkItem.Knowledge_Article_Id__c = this.articleId;
			this.bookmarkItem.CORECONNECT__Category__c = this.articleTypeLabel;
			this.bookmarkItem.RecordTypeId = devRecordTypeId;
			
			insert this.bookmarkItem;
		}
		
	}
	
	private void queryBookmarkItem() {
		if(this.articleId != null)
		{
			Id devRecordTypeId = Schema.SObjectType.CORECONNECT__CC_Personal_Item__c.getRecordTypeInfosByName().get('Support Documentation').getRecordTypeId();
			
			String articleTitle = (String)this.article.get('Title');
			
			List<CORECONNECT__CC_Personal_Item__c> piList = [SELECT Id, Name, CORECONNECT__Category__c, CORECONNECT__My_Links_Title__c, CORECONNECT__My_Links_URL__c, Knowledge_Article_Id__c
															FROM CORECONNECT__CC_Personal_Item__c WHERE RecordTypeId = :devRecordTypeId
															AND (Knowledge_Article_Id__c = :this.articleId OR CORECONNECT__My_Links_Title__c = :articleTitle)];
			
			System.debug('piList: '+piList);
			
			if(piList != null && piList.size() > 0)
			{
				this.bookmarkItem = piList[0];
			}
			
		}
	}
	
	private void createDescribeMap() {
		this.describeMap = new Map<String,String>();
		this.describeMapLabel = new Map<String,String>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Set<String> keySet = gd.keySet();
        for (String key : keySet) {
            Schema.SObjectType objectType = gd.get(key);
            if (key.endsWith('kav')) {
                this.describeMap.put(objectType.getDescribe().getKeyPrefix(), objectType.getDescribe().getName());
                this.describeMapLabel.put(objectType.getDescribe().getKeyPrefix(), objectType.getDescribe().getLabel());
            }
        }
    }
	
	//Util method to get Article Type from article Id.
    private String retrieveArticleType(String articleId) {
        String articlePrefix = articleId.substring(0,3);
        Set<String> keySet = this.describeMap.keySet();
        String articleType = null;
        for(String key: keySet) {
            if(articlePrefix.equalsIgnoreCase(key)) {
                articleType = this.describeMap.get(key);
                return articleType;
            }
        }
        return articleType;
    }
    
    private String retrieveArticleTypeLabel(String articleId) {
        String articlePrefix = articleId.substring(0,3);
        Set<String> keySet = this.describeMap.keySet();
        String articleType = null;
        for(String key: keySet) {
            if(articlePrefix.equalsIgnoreCase(key)) {
                articleType = this.describeMapLabel.get(key);
                return articleType;
            }
        }
        return articleType;
    }
	
}