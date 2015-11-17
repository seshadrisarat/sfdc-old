/**
* @ClassName    : SL_HelpHome 
* @JIRATicket   : CW-8
* @CreatedOn    : 
* @ModifiedBy   : SL
* @Description  : This controller for Help section home page. 
*/

/**
@Developer Name							: Sathiyaraja
Percentage of best practices followed	: 
No of SOQL queries used					: 1
No of collections used					: 1
Exception Handling implemented			: yes
Coding standards followed				: yes
Naming conventions followed				: yes
Third party integrations				: No
Maximum of No of records tested with	: 
Customer Approval						: 
Last Modified Date						: 
Approved by								: 
*/

public class SL_HelpHome 
{
	public Map<String, knowledgeArticlesCategoryWrapper> mapArticleDataCategoryToListOfArticles 	 {get;set;}
	public Map<String, Integer> mapCategoryToArticleCount {get;set;}
	public Map<String, String> mapObjectTypeToCategoryLabel {get;set;}
	public String strSiteDirectory		{get;set;}	// Used to dynamically get the site directory
	
	public String strcontactURL			{get;set;}
	public String strSubscriptionOrgId	{get;set;}
	public String strCustomSettingName		{	get;	set;	}
	public String strProductCategory			{	get;	set;	}
	
	/*start - Constructor*/
	public SL_HelpHome()
	{
		initialize();
		
		if(System.currentPageReference().getParameters().containsKey('subId'))
		{
			strSubscriptionOrgId = System.currentPageReference().getParameters().get('subId');
		}
		// fetch all CalendarAnything category related articles
		fetch_CategoryArticle();
		
		// fetch the contatUs Url from custom setting 
		strcontactURL = getCustomSettingValue(strCustomSettingName + '_' +'Contact');
	}
	/*stop - Constructor*/
	
	public class knowledgeArticlesCategoryWrapper
	{
		public String dataCategoryLabel					{get;set;}
		public String dataCategoryApiName				{get;set;}
		public List<ArticleWrapper> lstArticleObjects	{get;set;}
		
		public knowledgeArticlesCategoryWrapper(String dataCategoryLabel, String dataCategoryApiName, List<ArticleWrapper> lstArticleObjects)
		{
			this.dataCategoryLabel = dataCategoryLabel;
			this.dataCategoryApiName = dataCategoryApiName;
			this.lstArticleObjects = lstArticleObjects;
		}
	}
	
	public class ArticleWrapper
	{
		public String articleObjectType	{get;set;}
		public sObject articleObject	{get;set;}
		
		public ArticleWrapper(String articleObjectType, sObject articleObject)
		{
			this.articleObjectType = articleObjectType;
			this.articleObject = articleObject;
		} 
	}
	
	
	/*Start - initialize method*/
	public void initialize()
	{
		strCustomSettingName = getCustomSettingName();
		
		strProductCategory = getCustomSettingValue(strCustomSettingName + '_' +'ProductCategory');
		
		// Get the Site Directory from the custom setting as per CW-38 (Hemant)
		strSiteDirectory = getCustomSettingValue(strCustomSettingName + '_' +'Site Directory');
		
		mapArticleDataCategoryToListOfArticles = new Map<String, knowledgeArticlesCategoryWrapper>();
		mapCategoryToArticleCount = new Map<String, Integer>();
		mapObjectTypeToCategoryLabel = new Map<String, String>();
		strcontactURL = strSubscriptionOrgId = '';
	}
	
	/* start - fetch_CategoryArticle method*/
	public void fetch_CategoryArticle()
	{
		try
		{
			Map<String, Schema.Sobjecttype> mapObject = new Map<String, Schema.Sobjecttype>();
			List<SObject> lstRecords = new List<SObject>();
			List<SObject> lstAllArticles = new List<SObject>();
			String strKAVObjects = '';
			String strDCSobjects = '';
			
			//To get all the Sobjects 
	  		mapObject = Schema.getGlobalDescribe();
	  		
	  		// store all the KAV objects in a String
	  		for(String str:  mapObject.keyset()) 
	        {
	        	if(str.endsWith('__kav')) 
	         	{
					if(strKAVObjects != '')
						strKAVObjects += ',' + str;
					else
						strKAVObjects = str;
	         	}
	         	if(str.endsWithIgnoreCase('__DataCategorySelection')) 
	         	{
					if(strDCSobjects != '')
						strDCSobjects += ',' + str;
					else
						strDCSobjects = str;
	         	}
	        }
	        
	        // query for all the KAV objects and add the results in a list
	        for(String str : strKAVObjects.split(','))
	        {
	        	//Updated by Hemant as per CW-44
		    	//Publish Status made dynamic as we can not publist articles via code in test class    	
		    	String strPublishStatus = '\'Online\'';
		    	
		    	if(Test.isRunningTest())
		    		strPublishStatus = '\'Draft\'';
	        	
	        	lstRecords = new List<SObject>();
	        	
	        	String query = '';
	        	query += 'Select ID, UrlName, Title, Summary, KnowledgeArticleId, LastModifiedDate, (Select Id, DataCategoryName, DataCategoryGroupName From DataCategorySelections) FROM ';
	        	query += str;
	        	query += ' where PublishStatus = '+ strPublishStatus +' and language =\'en_US\' ';
	        	if(!Test.isRunningTest())
        			query += 'WITH DATA CATEGORY  Products__c AT (' + strProductCategory + ') AND Support_Category__c BELOW (All__c) ';
	        	query += 'ORDER BY LastModifiedDate desc';
	        	// query and add into the list.
	        	lstRecords = database.query(query);
	        	lstAllArticles.addAll(lstRecords);
	        }
	        system.debug('-----152-------'+lstAllArticles);
	        
	        for(String str : strDCSobjects.split(','))
	        {
	        	String query = '';
	        	query += 'Select Id, DataCategoryGroupName, toLabel(DataCategoryName) From ';
	        	query += str;
	        	for(sObject objDataCategorySelection : Database.query(query))
	        	{
	        		mapObjectTypeToCategoryLabel.put(String.valueOf(objDataCategorySelection.get('Id')), String.valueOf(objDataCategorySelection.get('DataCategoryName')));
	        	}
	        }
	        Map<Date, List<Sobject>> mapDate_Article = new Map<Date, List<Sobject>>();
	        for(integer i=0; i< lstAllArticles.Size(); i++)
	        {
	        	if(!mapDate_Article.containsKey(date.valueof(lstAllArticles[i].get('LastModifiedDate'))))
    				mapDate_Article.put(date.valueof(lstAllArticles[i].get('LastModifiedDate')), new List<Sobject> {lstAllArticles[i]});
    			else
    				mapDate_Article.get(date.valueof(lstAllArticles[i].get('LastModifiedDate'))).add(lstAllArticles[i]);
	        }
	        
	        List<Date> lstDate = new List<Date>();
	        set<Date> setDate = new set<Date>();
	        
	        if(mapDate_Article != null)
				setDate.addall(mapDate_Article.keySet());
			
			lstDate.addall(setDate);
			lstDate.Sort();
			
			for(Integer i = lstDate.size() - 1; i >= 0; i--)
			{
				if(mapDate_Article.containsKey(lstDate[i]))
				{
					for(Sobject Sobj: mapDate_Article.get(lstDate[i]))
					{
						for(Sobject s : Sobj.getSObjects('DataCategorySelections'))
						{
							String strCategory = String.valueOf(s.get('DataCategoryName'));
							String strDataCategoryGroup = String.valueOf(s.get('DataCategoryGroupName'));
							
							if(strDataCategoryGroup == 'Support_Category')
							{
								if(mapArticleDataCategoryToListOfArticles.keyset().contains(strCategory))
								{
									mapArticleDataCategoryToListOfArticles.get(strCategory).lstArticleObjects.add(new ArticleWrapper(String.valueOf(Sobj.getSobjectType()), Sobj));
								}
								else
								{
									mapArticleDataCategoryToListOfArticles.put(strCategory, new knowledgeArticlesCategoryWrapper(( !mapObjectTypeToCategoryLabel.containsKey(String.valueOf(s.get('Id'))) ? 'All' : mapObjectTypeToCategoryLabel.get(String.valueOf(s.get('Id'))) ) , strCategory + '__c' , new List<ArticleWrapper>{new ArticleWrapper(String.valueOf(Sobj.getSObjectType()), Sobj)}));
								}
							}
						}
					}
				}
			}
			
			for(String strCategory : mapArticleDataCategoryToListOfArticles.keyset())
			{
				if(strCategory == 'All')
				{
					for(String str : mapArticleDataCategoryToListOfArticles.keyset())
					{
						if(str != 'All')
						{
							mapArticleDataCategoryToListOfArticles.get(str).lstArticleObjects.addAll(mapArticleDataCategoryToListOfArticles.get(strCategory).lstArticleObjects);
						}
					}
				}
			}
			
			if(mapArticleDataCategoryToListOfArticles.containsKey('All'))   mapArticleDataCategoryToListOfArticles.remove('All');
			
			for(String strCategory : mapArticleDataCategoryToListOfArticles.keyset())
			{
				mapCategoryToArticleCount.put(strCategory , mapArticleDataCategoryToListOfArticles.get(strCategory).lstArticleObjects.size());
			}

		}
		catch(Exception ex)
		{
			// do nothing.
		}
	}
	
	/* Start - Method to get the URL from the custom setting */
    private String getCustomSettingValue(String strCSName)
    {
        String strUrl = '';
        SL_Navigation__c objNavigation = SL_Navigation__c.getValues(strCSName);
        if(objNavigation!= null)
            strUrl = objNavigation.URL__c;
        else
            strUrl = '#';
        return strUrl;
    }
    /* Start - Method to get the URL from the custom setting */
    
	
	/* Start - Method to get the Name used in custom setting */
	private String getCustomSettingName()
	{
		/* Getting info about the Name  */
		String strSiteName = Site.getName();
		
		if(strSiteName == Null)
			strSiteName = 'CalendarAnything_Website';
			
		SL_SiteName__c objNav = SL_SiteName__c.getValues(strSiteName);
		
		if(objNav != null)
			return objNav.SiteIdentifier__c;
		else
			return '#';
	}
	/* END -  */
	
	/* Start - Method for test coverage */
    @isTest
    static void SL_HelpHome_Test()
    {
    	Blob objBlob = Blob.valueOf('Body');
    	 
    	Website_Use_Case__kav objWSUseCase = new Website_Use_Case__kav(Video_ID__c = '123444', UrlName = 'AAAA', Title = 'UseCase1', Status__c = 'Draft', 
                                                                        Article_Body__c = 'Body1',  Icon__Name__s ='Icon1',Icon__ContentType__s = 'image/png', 
                                                                        Icon__Body__s = objBlob ,Language = 'en_US');
                                                                        //Icon__Body__s = objBlob ,Language = 'en_US',PublishStatus = 'Online');
        insert objWSUseCase;
        
        Website_Feature__kav objWSFet = new Website_Feature__kav(Video_ID__c = '123444', UrlName = 'BBBB', Title = 'UseCase1', Status__c = 'Draft', 
                                                                        Article_Body__c = 'Body1',  Icon__Name__s ='Icon1',Icon__ContentType__s = 'image/png', 
                                                                        Icon__Body__s = objBlob ,Language = 'en_US');
                                                                        //Icon__Body__s = objBlob ,Language = 'en_US',PublishStatus = 'Online');
        insert objWSFet;
        
        Website_Feature__DataCategorySelection testDS1 = new Website_Feature__DataCategorySelection( ParentId=objWSFet.Id, DataCategoryName= 'Feature_Setup' , DataCategoryGroupName = 'Support_Category'
        																							 );
        insert testDS1;
        
        Website_Use_Case__DataCategorySelection testDS2 = new Website_Use_Case__DataCategorySelection( ParentId=objWSUseCase.Id, DataCategoryName= 'Feature_Setup' , DataCategoryGroupName = 'Support_Category' 
        																							 );
        insert testDS2;
        
  
        SL_SiteName__c objNav = new SL_SiteName__c(Name = 'CalendarAnything_Website', SiteIdentifier__c = 'ca');
    	insert objNav;
    
	    SL_Navigation__c testNav = new SL_Navigation__c(Name = 'ca_ProductCategory', URL__c = 'CalendarAnything__c');
	    insert testNav;
        
        
     	System.currentpagereference().getparameters().put('subId', '12345');
      
        SL_HelpHome clsHelpHome = new SL_HelpHome();
        clsHelpHome.strProductCategory = 'CalendarAnything';
        
		
		SL_HelpHome.ArticleWrapper objAW = new SL_HelpHome.ArticleWrapper('Website_Feature__kav', objWSUseCase);
		SL_HelpHome.knowledgeArticlesCategoryWrapper objKACW = new SL_HelpHome.knowledgeArticlesCategoryWrapper('Test Categ1', 'CalendarAnything', new List<ArticleWrapper>{objAW});
        
    }
}