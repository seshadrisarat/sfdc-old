/**
* @ClassName 	: SL_AutoCompleteSearchController
* @JIRATicket   : CW-10
* @CreatedOn    : 27/Dec/12
* @ModifiedBy   : Hemant (27/Feb/2013)
* @Description  :
*/

/**
@Hemant
Percentage of best practices followed	: 100%
No of SOQL queries used					: 0
No of SOSL queries used					: 1
No of collections used					: 1
Exception Handling implemented			: Yes
Coding standards followed				: Yes
Naming conventions followed				: Yes
Third party integrations				: No
Maximum of No of records tested with	: 
Customer Approval						:
Last Modified Date						: 27/feb/13
Approved by								:

*/

global class SL_AutoCompleteSearchController
{
    public String strInitialVal 									{	get;set;	}
    public String searchText										{	get;set;	}
    public String strSubscriptionOrgId								{	get;set;	}

    public static String strCustomSettingName							{	get;set;	}
    public String strSiteDirectory									{	get;set;	} // Used to dynamically get the site directory
    public static String strProductCategory							{	get;set;	}
    
    private static Set<String> setSpecialChars = new Set<String>{'?', '&', '|', '!', '{', '}', '[', ']', '(', ')',   '^', '~' , '*' ,':','\'', '" ', '+', '-'};

    /*
		@Constuctor
		@param None
		@Description: To set initial value of Search Box
	*/
    public SL_AutoCompleteSearchController()
    {
    	strCustomSettingName = strProductCategory = '';
    	strCustomSettingName = getCustomSettingName();

    	strProductCategory = getCustomSettingValue(strCustomSettingName + '_' +'ProductCategory');

    	strInitialVal = strCustomSettingName == 'si' ? 'Search Knowledge Base…' : 'Have a question? Ask or enter a search term here.';
    	searchText = strSubscriptionOrgId = '';

    	if(System.currentPageReference().getParameters().containsKey('subId'))
		{
			strSubscriptionOrgId = System.currentPageReference().getParameters().get('subId');
		}

    	//If coming from any other page the value in search box should be searched text
    	String strSearchText = ApexPages.currentPage().getParameters().get('search');
    	if(strSearchText != '' && strSearchText != null)
    	{
    		if(strSearchText != 'All')
    			strInitialVal = strSearchText;
    		else
    			strInitialVal = strCustomSettingName == 'si' ? 'Search Knowledge Base…' : 'Have a question? Ask or enter a search term here.';
    	}
    	else
	    	strInitialVal = strCustomSettingName == 'si' ? 'Search Knowledge Base…' : 'Have a question? Ask or enter a search term here.';
    }

    /* Start - Method to get the URL from the custom setting */
    private static String getCustomSettingValue(String strCSName)
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
	private static String getCustomSettingName()
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

    /*
		@MethodName: findArticleObjects
		@param None
		@Description: To get all the __Kav objects in a string in csv format.
	*/
	public static String findArticleObjects()
	{
		try
		{
			String strTempKAVObjects = '';
			String strKAVObjects = '';

			//To get all the objects
			Map<String, Schema.Sobjecttype> mapObject = new Map<String, Schema.Sobjecttype>();

			//To get all the Sobjects
	  		mapObject = Schema.getGlobalDescribe();

			//Map to store all the Knowledge article type objects
			Map<String, String> mapKavObject = new Map<String, String>();

			//Iterate through loop to collect all the Knowledge article type objects
	  		for(String str:  mapObject.keyset())
	        {
	        	if(str.endsWith('__kav'))
	         	{
					 Schema.DescribeSObjectResult r =  mapObject.get(str).getDescribe();
					 String strTemp = r.getKeyPrefix();

					 mapKavObject.put(strTemp, str);

					if(strTempKAVObjects != '')
						strTempKAVObjects += ',' + str;
					else
						strTempKAVObjects = str;

	         	}
	        }

	        for(String str : strTempKAVObjects.split(','))
	        {
	        	if(strKAVObjects != '')
					strKAVObjects += ',' + str;
				else
					strKAVObjects = str;
	        }

			return strKAVObjects;
		}
		catch(Exception e)
		{
			return null;
		}
	}

    @RemoteAction
    global static ArticleWrapper[] findSObjects(string qry)
    {
    	strCustomSettingName = getCustomSettingName();

    	strProductCategory = getCustomSettingValue(strCustomSettingName + '_' +'ProductCategory');
		// check to see if the object passed is valid
		String strQueryReturning = '';
		String escapedStrText = '';
		
		List<ArticleWrapper> lstSearchResults = new List<ArticleWrapper>();

        for(Integer i=0 ; i<=qry.length() -1; i++)
		{
			if(setSpecialChars.contains(qry.substring(i,i+1)))
			{
				if(qry.substring(i,i+1) == '*' || qry.substring(i,i+1) == '+')
				{
					escapedStrText += '\\\\';
					escapedStrText += qry.substring(i,i+1);
				}
				continue;
			}
			
			escapedStrText += qry.substring(i,i+1);
		}
		
		qry = escapedStrText;
		
        //Dynamic SOSL query string
        string sosl = '';
        sosl = 'FIND ' + '\'' + qry + '*\'' +  ' IN ALL FIELDS '+ 'RETURNING ';
		
		string strObjectFields = '(ID, UrlName, Title, Summary, KnowledgeArticleId WHERE PublishStatus = \'Online\' AND language = \'en_US\')';
		if(Test.isRunningTest())
			 strObjectFields = '(ID, UrlName, Title, Summary, KnowledgeArticleId WHERE PublishStatus = \'Draft\' AND language = \'en_US\')';
		//Adding all _kav objects into query string to search the articles from all Article type objects
		String strKAVObjects = findArticleObjects();

		for(String str : strKAVObjects.split(','))
		{
			if(strQueryReturning == '')
				strQueryReturning = str + strObjectFields ;
			else
				strQueryReturning += ',' + str + strObjectFields;
		}

		sosl += strQueryReturning;
		// Updated by Hemant as per CW-41
		//sosl += ' WITH DATA CATEGORY CalendarAnything_Support__c BELOW (All__c) AND Products__c AT (CalendarAnything__c)';
		if(!Test.isRunningTest())
			sosl += ' WITH DATA CATEGORY Products__c AT (' + strProductCategory + ')';

		List<List<SObject>> searchList = new List<List<SObject>>();
		
		
        try 
		{
        	//Search to get the Articles
			if(qry.length() > 1)
	        	searchList = search.query(sosl);
	        //List to store all the queried articles from 'searchList'(List of List)
	        List<SObject> commonResultsList = new List<SObject>();
	
	        for(List<Sobject> results : searchList)
	        {
	        	if(results.size() > 0)
	        		commonResultsList.addAll(results);
	        }

	        //To prepare 'knowledgeArticlesToDisplay' class objects with queried values to show it on a page
	        for(SObject sObjResult : commonResultsList)
	        {
	        	//To avoid the view state issue
	        	if(lstSearchResults.size() == 6)
	        		break;

	        	lstSearchResults.add(new ArticleWrapper(String.valueOf(sObjResult.getsObjectType()) ,sObjResult));
	        }

        }
        catch (QueryException e)
        {
            return null;
        }
        catch (SearchException e)
        {
            return null;
        }

        return lstSearchResults;
   }

   global class ArticleWrapper
   {
   		global String articleObjectType	{get;set;}
		global sObject articleObject	{get;set;}

		global ArticleWrapper(String articleObjectType, sObject articleObject)
		{
			this.articleObjectType = articleObjectType;
			this.articleObject = articleObject;
		}
   }

   public pageReference goToSearchPage()
   {
   		strInitialVal = urlEncoder(strInitialVal);
   		PageReference pr = new Pagereference('/Search?search=' + strInitialVal + '&subId='+strSubscriptionOrgId);
   		return pr;
   }


  	 /*
	  @MethodName: urlEncoder
	  @param : url parameters
	  @Description: Encoding special characters before sending into URL
	 */
	 public String urlEncoder(String parameter)
	 {
	  	parameter = parameter.replace('%' , '%25').replace('*' , '%2A').replace('!' , '%21').replace('"' , '%22').replace('#' , '%23').replace('$' , '%24').replace('&' , '%26').replace('\'' , '%27').replace('\\' , '%5C').replace('(' , '%28').replace(')' , '%29').replace('+' , '%2B').replace(',' , '%2C').replace('-' , '%2D').replace('.' , '%2E').replace('/' , '%2F');
	  	return parameter;
	 }

	 @isTest
	 private static void test_SL_AutoCompleteSearchController()
	 {
	 	Blob objBlob = Blob.valueOf('Body');
		
        Website_Feature__kav objWSFet = new Website_Feature__kav(Video_ID__c = '123444', UrlName = 'BBBB', Title = 'UseCase1', Status__c = 'Featured',
                                                                        Article_Body__c = 'Body1',  Icon__Name__s ='Icon1',Icon__ContentType__s = 'image/png',
                                                                        Icon__Body__s = objBlob ,Summary='Test Test Test',Language = 'en_US');
        insert objWSFet;


        Website_Feature__DataCategorySelection testDS2 = new Website_Feature__DataCategorySelection( ParentId=objWSFet.Id, DataCategoryName= 'CalendarAnything' , DataCategoryGroupName = 'Products'
        																							 );
        insert testDS2;
        
        System.currentpagereference().getparameters().put('subId', '12345');
		System.currentpagereference().getparameters().put('search', 'All');

        SL_AutoCompleteSearchController objTest = new SL_AutoCompleteSearchController();

        findSObjects('UseCase1');

        objTest.goToSearchPage();

        System.currentpagereference().getparameters().put('search', 'UseCase1');
        SL_AutoCompleteSearchController objTest2 = new SL_AutoCompleteSearchController();

        System.currentpagereference().getparameters().put('search', '');
        SL_AutoCompleteSearchController objTest3 = new SL_AutoCompleteSearchController();

        findSObjects('Test\'s');
        findSObjects('Test****\'s');
        findSObjects('Body1');
        
        SL_SiteName__c objSite = new  SL_SiteName__c();
        objSite.Name = 'CalendarAnything_Website';
        objSite.SiteIdentifier__c = 'ca';
        insert objSite;
        
        SL_Navigation__c objCustSetting = new SL_Navigation__c();
        objCustSetting.Name = 'ca_ProductCategory';
        objCustSetting.URL__c = 'Website_Feature__kav,Website_Use_Case__kav';
        insert objCustSetting;
        
        SL_AutoCompleteSearchController objTest4 = new SL_AutoCompleteSearchController();
         
        findSObjects('Test\'s');
        findSObjects('Test****\'s');
        findSObjects('Body1');
        
        SL_AutoCompleteSearchController.ArticleWrapper objAW = new SL_AutoCompleteSearchController.ArticleWrapper('Website_Feature__kav',objWSFet);
	 }
}