/**
* @ClassName 	: SL_ArticleDetail
* @JIRATicket   : CW -10
* @CreatedOn    : 27/Dec/12
* @ModifiedBy   : SL
* @Description  :
*/

/**
@Shailendra
Percentage of best practices followed	: 100%
No of SOQL queries used					: 2
No of collections used					: 1
Exception Handling implemented			: Yes
Coding standards followed				: Yes
Naming conventions followed				: Yes
Third party integrations				: No
Maximum of No of records tested with	:
Customer Approval						:
Last Modified Date						: 27/Dec/12
Approved by								:

*/


public without sharing class SL_ArticleDetail
{
	/* Start - Variables*/
	public Sobject objArticle					{	get;set;	} //This variable is used to show the detail of the articles.
	public User objUser							{	get;set;	} //This variable is used to show the detail of the user.
	public List<Category> lstCategory			{	get;set;	} //This list store the categories of the articles.
	public String strNumberOfComments			{	get;set;	} // Holds the number of FB comments.
	public Boolean isVideoFieldPresent			{	get;set;	} // Used to check whether selected article's object includes VideoId Field or Not
	public Boolean isArticleBodyPresent			{	get;set;	} // Used to check whether selected article's object includes ArticleBody Field or Not
	public String strSubscriptionOrgId			{	get;set;	}
	public String strSiteDirectory				{	get;set;	} // Used to dynamically get the site directory
	public String strPageTitle					{	get;set;	}
	public String strCustomSettingName		{	get;set;	}

	private String strArticleUrlName;//This string is used to store the article id.
	private String strArticleType;
	private String strUserId;// This string is used to store the user id.
	private List<Sobject> lstSobject;//This list store the articles detail.
	public Map<String, String> mapObjectTypeToCategoryLabel {get;set;}

	/* End - Variables*/


	/* Start - Inner Class for Category */
	public class Category
	{
		/* Inner Class Variables */
		public String strCategoryNameAPI		{	get;set;	}
		public String strCategoryName			{	get;set;	}
		public String strCategoryGroupName		{	get;set;	}
		public String strId						{	get;set;	}
		public String strComma					{	get;set;	}
		/* Inner Class Variables */

		/* Start - Constructor*/
		public Category(String strCategoryName, String strCategoryNameAPI, String strCategoryGroupName, String strId, String strComma)
		{
			this.strCategoryNameAPI = strCategoryNameAPI + '__c';
			this.strCategoryGroupName = strCategoryGroupName + '__c';

			if(strComma != 'Last')
			{
				//this.strCategoryName = strCategoryName + ',';
				this.strCategoryName = strCategoryName ;
			}
			else
				this.strCategoryName = strCategoryName;

			this.strId = strId;
			this.strComma = '';
		}
		/* Start - Constructor*/
	}
	/* End - Inner Class for Category */

	/* Start - Contructor*/
	public SL_ArticleDetail()
	{
		//To intialize all the variables onload of the page.
		initialization();

		if(System.currentPageReference().getParameters().containsKey('subId'))
		{
			strSubscriptionOrgId = System.currentPageReference().getParameters().get('subId');
		}

		/* To create map of labels and API names  */
			Map<String, Schema.Sobjecttype> mapObject = new Map<String, Schema.Sobjecttype>();
			String strDCSobjects = '';

			//To get all the Sobjects
			mapObject = Schema.getGlobalDescribe();

			// store all the KAV objects in a String
			for(String str:  mapObject.keyset())
	        {
	         	if(str.endsWithIgnoreCase('__DataCategorySelection'))
	         	{
					if(strDCSobjects != '')
						strDCSobjects += ',' + str;
					else
						strDCSobjects = str;
	         	}
	        }

 			for(String str : strDCSobjects.split(','))
	        {
	        	// Updating the Language value to Userinfo.getLanguage() from hardcoded 'en_US'
	        	String query = '';
	        	query += 'Select Id, DataCategoryGroupName, toLabel(DataCategoryName) From ';
	        	query += str;

	        	for(sObject objDataCategorySelection : Database.query(query))
	        	{
	        		String strDataCategoryGroup = String.valueOf(objDataCategorySelection.get('DataCategoryGroupName'));
					if(strDataCategoryGroup == 'Support_Category')
					{
	        			mapObjectTypeToCategoryLabel.put(String.valueOf(objDataCategorySelection.get('Id')), String.valueOf(objDataCategorySelection.get('DataCategoryName')));
					}
	        	}
	        }

		/* To create map of labels of DataCAtegorySelection type objects  */
		//getting the articles id form the url.
		strArticleUrlName = apexpages.currentpage().getparameters().get('Name');
		strArticleType = apexpages.currentpage().getparameters().get('obj');
		//getting the article detail from the method getArticleInfo.
		if(strArticleUrlName != null && strArticleUrlName != '' && strArticleType != null && strArticleType != '')
			objArticle = getArticleInfo(strArticleUrlName, strArticleType);

		//getting the Number of comments from getNoOfComment Method.
		strNumberOfComments = getNoOfComments();


	}
	/* End - Constructor*/

	/* Start - Method*/
	private void initialization()
	{
		strPageTitle = '';
		strCustomSettingName = '';

		strCustomSettingName = getCustomSettingName();
		
		system.debug('----strCustomSettingName---' + strCustomSettingName);
		
		strPageTitle = getCustomSettingValue(strCustomSettingName + '_' +'ProductCategory');
		
		system.debug('----strPageTitle---' + strPageTitle);
		
		strPageTitle = strPageTitle.subString(0,strPageTitle.length() - 3 );
		strSiteDirectory = getCustomSettingValue(strCustomSettingName + '_' +'Site Directory');

		lstCategory = new List<Category>();
		lstSobject = new List<Sobject>();
		strArticleUrlName = strNumberOfComments = strArticleType = strSubscriptionOrgId = '';
		strUserId = '';
		isVideoFieldPresent = false;
		isArticleBodyPresent = false;

		mapObjectTypeToCategoryLabel = new Map<String, String>();
	}
	/* End - Method */

	/* Start - Method to query the Article */
	private Sobject getArticleInfo(String articleName, String articleType)
	{
		try
		{
			String strQuery = '';
			String sobjName = articleType;

			//Updated by Hemant as per CW-44
    		//Publish Status made dynamic as we can not publist articles via code in test class
			String strPublishStatus = '\'Online\'';

	    	if(Test.isRunningTest())
	    		strPublishStatus = '\'Draft\'';

			strQuery = 'Select Id, Title, Video_ID__c, Article_Body__c, UrlName, LastModifiedDate, CreatedById,';
			strQuery += '(Select Id, DataCategoryName, DataCategoryGroupName From DataCategorySelections) '+
					   	'FROM '+ sobjName + ' where UrlName = \'' + articleName + '\' AND PublishStatus = '+ strPublishStatus +' AND Language = \'en_US\' limit 1';

			//Getting the article information.
			lstSobject = Database.query(strQuery);
			
			if(lstSobject.size() > 0)
			{
				strUserId = String.valueOf(lstSobject[0].get('CreatedById'));
				getUserInfo();
				getArticleCategories();
		   		return lstSobject[0];
			}
		   	else
		   		return null;
		}
		catch(Exception ex)
		{
			return null;
		}
	}
	/* End - Method to query the Article */

	/* Start - Method to get the user information */
	private void getUserInfo()
	{
		try
		{
			String strProfilePhoto = '';
			objUser = [SELECT Id, Title, Name, PhotoURL__c, Profile_Photo__c FROM User WHERE Id =: strUserId LIMIT 1];
			system.debug('????????????'+objUser);
			//Setting the width and height of the User Photo.
			if(objUser != null)
				strProfilePhoto = String.valueOf(objUser.Profile_Photo__c);

			String strProfileImage = '';
			if(strProfilePhoto != null && strProfilePhoto != '')
			{
				if(strProfilePhoto.contains('width') || strProfilePhoto.contains('height'))
				{
					for(String s : strProfilePhoto.split(' '))
					{
						if(s.contains('width'))
						{
							strProfileImage += ' width="50"';
							continue;
						}
						else if(s.contains('height'))
						{
							strProfileImage += ' height="50"';
							continue;
						}
						strProfileImage += (' ' + s + ' ');
					}
				}
				else
				{
					strProfileImage += '<img ';
					strProfileImage += ' width="50" height="50" ';
					strProfileImage += strProfilePhoto.split('<img')[1];
				}
			}
			else
			{
				strProfileImage = '<img width="50" height="50"></img>';
			}

			objUser.Profile_Photo__c = strProfileImage;
		}
		catch(Exception ex)
		{
		}
	}
	/* End - Method to get the user information */

	/* Start - Method to get the Categories of the article */
	private void getArticleCategories()
	{
		integer intListSize = 0;
		integer intLast = 0;
		if(lstSobject[0].getSObjects('DataCategorySelections') != null)
			intListSize = lstSobject[0].getSObjects('DataCategorySelections').size();

		if(lstSobject.size()>0 && lstSobject[0].getSObjects('DataCategorySelections') != null)
		{
            for(Sobject sObjectDCS: lstSobject[0].getSObjects('DataCategorySelections'))
            {
            	String strDataCategoryGroup = String.valueOf(sObjectDCS.get('DataCategoryGroupName'));
				if(strDataCategoryGroup == 'Support_Category')
				{
	            	intLast++;
	            	Category objCategory;
	            	if(intListSize != intLast)
	            		objCategory = new Category(mapObjectTypeToCategoryLabel.get(String.valueOf(sObjectDCS.get('Id'))), String.valueOf(sObjectDCS.get('DataCategoryName')),String.valueOf(sObjectDCS.get('DataCategoryGroupName')),String.valueOf(sObjectDCS.get('Id')), 'First');
	            	else
	            	{
	            		objCategory = new Category(mapObjectTypeToCategoryLabel.get(String.valueOf(sObjectDCS.get('Id'))), String.valueOf(sObjectDCS.get('DataCategoryName')) ,String.valueOf(sObjectDCS.get('DataCategoryGroupName')),String.valueOf(sObjectDCS.get('Id')), 'Last');
	            	}
	            	lstCategory.add(objCategory);
            	}
            }
		}
	}
	/* End - Method to get the Categories of the article */

	/* Start - Method to get the no of comment on artcle */

	private String getNoOfComments()
	{
		String strNoOfComment = '';
		// Get the number of Comments for the current article in context
		if(objArticle != null)
		{
			//Getting base URL of the site  as per CW-38 (Hemant)
			String baseUrl = '';
			baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();

			baseUrl = baseUrl.substring(baseUrl.lastIndexOf('/') + 1, baseUrl.length());

			//String endPointURL = 'http://graph.facebook.com/fql?q=select+comment_count+from+link_stat+where+url+%3D+%22silverline.dev.cs15.force.com%2Findex%2FArticleDetail%3Fname%3D'+ objArticle.get('UrlName') +'%22';
			String endPointURL = 'http://graph.facebook.com/fql?q=select+comment_count+from+link_stat+where+url+%3D+%22' +
								 baseUrl + '%2F' + strSiteDirectory +'%2FArticleDetail%3Fname%3D'+ objArticle.get('UrlName') +'%22';

			String xmlResponseString;

			// Forming HTTP request
			Http h = new Http();
			HttpRequest req = new HttpRequest();
			req.setEndpoint(endPointURL);
			req.setMethod('GET');
			req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

			if(!Test.isRunningTest())
			{
				HttpResponse res = h.send(req);
				//Getting xml response
				xmlResponseString = res.getBody();
				strNoOfComment = xmlResponseString.contains('comment_count') ? xmlResponseString.substring(26, xmlResponseString.removeEnd('}]}').length()) : '0';
			}
		}
		else
			strNoOfComment = '0';
		return strNoOfComment;
	}
	/* End - Method to get the no of comment on artcle */

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


	@isTest()
	private static void test_SL_ArticleDetail()
	{
		// Insert record and then pass that Id to URL
		Blob objBlob = Blob.valueOf('Body');

		Website_Use_Case__kav objWSUseCase1 = new Website_Use_Case__kav(Video_ID__c = '1234441', UrlName = 'URL11', Title = 'UseCase11', Status__c = 'Featured',
																		Article_Body__c = 'Body11',  Icon__Name__s ='Icon11',Icon__ContentType__s = 'image/png',
																		Icon__Body__s = objBlob ,Language = 'en_US');
																		//Icon__Body__s = objBlob ,Language = 'en_US',PublishStatus = 'Online');
    	insert objWSUseCase1;
    	

    	Website_Use_Case__DataCategorySelection testDS1 = new Website_Use_Case__DataCategorySelection( ParentId=objWSUseCase1.Id,
    																									 DataCategoryName= 'Feature_Setup' , 
    																									 DataCategoryGroupName = 'Support_Category'
        																							 );
        insert testDS1;
	   
	   
	    Test.setFixedSearchResults(new List<String>{objWSUseCase1.Id, testDS1.Id});
	   
	    SL_SiteName__c objNav = new SL_SiteName__c(Name = 'CalendarAnything_Website', SiteIdentifier__c = 'ca');
	    insert objNav;
	   
	    SL_Navigation__c objNavigation = new SL_Navigation__c(Name = 'ca_ProductCategory', URL__c = 'CalendarAnything__c');
	    insert objNavigation;
	   	
		System.currentpagereference().getparameters().put('subId', '12345');
		System.currentpagereference().getparameters().put('Name', 'URL11');
		System.currentpagereference().getparameters().put('obj', 'Website_Use_Case__kav');

		SL_ArticleDetail objAD = new SL_ArticleDetail();
		objAD.getArticleInfo('URL11','Website_Use_Case__kav');
		objAD.getUserInfo();
	}
}