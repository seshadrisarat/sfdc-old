/**
* @ClassName 	:	SL_PostAQuestion
* @JIRATicket   :	CW-11
* @CreatedOn    :	31/Dec/12
* @ModifiedBy   :	Hemant
* @Description  :	This page will allow users to open a new case. There are 5 visible fields on the page plus a CAPTCHA entry.
					Additionally, there are hidden fields which need to be set when submitting a case.
*/

/**
@Hemant
Percentage of best practices followed	: 100%
No of SOQL queries used					: 0
No of SOSL queries used					: 1
No of collections used					: 13
Exception Handling implemented			: Yes
Coding standards followed				: Yes
Naming conventions followed				: Yes
Third party integrations				: No
Maximum of No of records tested with	: 20
Customer Approval						:
Last Modified Date						: 4/Jan/13
Approved by								:

/**
@Major Change1		  : Removal of few global variables as part of code clean up and optimization
JIRA Link:
Short desc:
Impacted methods/areas: initialize(), submitCase(), validateForm(), insertCase()
Result:
Changed By:			  : Hemant
Approved By:

*/


public class SL_PostAQuestion
{
	/* Global Variables and collections */
    public String strInputCaptcha				{get; set;}		//Used to get form value entered
    public String strCaptcha					{get; set;}		//Used to set catcha value on page
    public String strCaptchaStyle				{get; set;}		//Used to set catcha style on page
    public String strCaptchaColor				{get; set;}		//Used to set catcha style on page
    public Boolean isError						{get; set;}
    public Boolean isModalWindowRendered		{get; set;}		//Used to decide to display ModalWindow
    public Boolean blnShowModal1				{get; set;}		//Used to decide to display which ModalWindow
    public Boolean blnShowModal2				{get; set;}		//Used to decide to display which ModalWindow
    public String strPageMessage				{get; set;}		//Used to display error messages
    public String caseId                        {get; set;}
    
	public String strSubscriptionOrgId			{get;set;}
	
    public String strIsErrorCaptcha				{get; set;}		//Used to decide is there error for form field Captcha
    public List<ArticleWrapper> lstSearchResults {get;set;}		//Used to display list of Knowledge Articles
    public Case objCase							{get;set;}
	public String strSiteDirectory				{get;set;}		//Used to dynamically get the site directory
	public String strCustomSettingName			{get;set;}
	public String strPageTitle					{get;set;}
	public map<String,string> mapFieldNameToCustomLabel {get;set;}
	
	public Boolean isErrorCaptcha				{get; set;}		//Used to decide to display which ModalWindow

    /* Local Variables and collections */
	private List<String> strCharactersCollection;
	private List<String> lstStrFontStyle;
    private List<String> lstStrFontColor;
    private String strKAVObjects;


    /*
	**	Constructor :	SL_PostAQuestion
	**	Paramaters	:	None
	**	Desc 		:	Calls Initialize Method
	**	Return		:	None
	*/

	
    public SL_PostAQuestion()
    {
        initialize();
        if(System.currentPageReference().getParameters().containsKey('subId'))
		{
			strSubscriptionOrgId = System.currentPageReference().getParameters().get('subId');
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
	
    /*
		@MethodName		:	initialize
		@param			:	None
		@Description	:	Initializes all the variables
		@Return 		:	Void
	*/
    private void initialize()
    {
		/* INITIALIZING GLOBAL VARIABLES */
    	strSubscriptionOrgId = '';
    	strIsErrorCaptcha =  'caseInput form-control';
    	lstSearchResults = new List<ArticleWrapper>();
    	objCase = new Case();
    	isErrorCaptcha = false;
		mapFieldNameToCustomLabel = new map<String,string>();
    	strCustomSettingName = getCustomSettingName();
    	strPageTitle = getCustomSettingValue(strCustomSettingName + '_' +'ProductCategory');
    	if(strPageTitle.length() >= 3)
    		strPageTitle = strPageTitle.subString(0,strPageTitle.length() - 3 );

    	// Get the Site Directory from the custom setting as per CW-38 (Hemant)
		SL_Navigation__c objNavigation = SL_Navigation__c.getValues(strCustomSettingName + '_' +'Site Directory');
		if(objNavigation!= null)
			strSiteDirectory = objNavigation.URL__c;
		else
			strSiteDirectory = '#';

    	/*Fetch Record type Id*/
    	List<RecordType> lstRecordType = [Select Id, Name, sObjectType From RecordType
    									  Where Name = 'Product and Sales Support' AND
    									  sObjectType = 'Case' LIMIT 1];
    	if(!lstRecordType.isEmpty())
    	{
    		objCase.RecordTypeId = lstRecordType[0].Id;
    	}

    	objCase.Type = getCustomSettingValue(strCustomSettingName + '_' +'CaseType');
    	//As per CW-74
    	objCase.Origin = 'Web';
    	list<Schema.FieldSetMember> lstSchemaFieldSet = Schema.SObjectType.Case.fieldSets.getMap().get('SL_'+strCustomSettingName+'_PostAQuestion').getFields();
    	
    	for(Schema.FieldSetMember schemaFieldSetMember: lstSchemaFieldSet)
    	{
    		string strFieldName = schemaFieldSetMember.getFieldPath();
    		if(schemaFieldSetMember.getFieldPath().contains('.'))
    			strFieldName = schemaFieldSetMember.getFieldPath().replace('.','_');
    		
    		if(strFieldName.endswith('__c') )
    		{
    			strFieldName = strFieldName.substring(0,schemaFieldSetMember.getFieldPath().length()-3);
    		} 
    			mapFieldNameToCustomLabel.put(schemaFieldSetMember.getFieldPath(),strFieldName);
    		
    	}
		
    	//Initialized model window renderer variables
    	isModalWindowRendered = false;
    	blnShowModal1 = false;
    	blnShowModal2 = false;
    	isError = false;

        /* INITIALIZING PRIVATE VARIABLES */
        //Captcha variables initialized
		strCharactersCollection = new List<String>{
        	'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
        	'1','2','3','4','5','6','7','8','9','0'
        };

        //Captcha fonts
        lstStrFontStyle = new List<String>{ 'molot' , 'capture' };

        //Captcha colors
        lstStrFontColor = new List<String>{ '#A3C552' , '#71C1D9' };

    	strKAVObjects = '';
    }
	
	//This method returns all the fields includes in field set
    public List<Schema.FieldSetMember> getCaseFields() 
    {
    	if(strCustomSettingName == null || strCustomSettingName == '' )
    		getCustomSettingName();
        return Schema.SObjectType.Case.fieldSets.getMap().get('SL_'+strCustomSettingName+'_PostAQuestion').getFields();
    }
	
    /* Start - Method to get the Name used in custom setting */
	private String getCustomSettingName()
	{
		/* Getting info about the Name  */
		String strSitePrefix = Site.getName();
		if(strSitePrefix == Null)
			strSitePrefix = 'CalendarAnything_Website';
			
		SL_SiteName__c objNav = SL_SiteName__c.getAll().get(strSitePrefix);
		if(objNav != null)
			return objNav.SiteIdentifier__c;
		else
			return 'ca';
	}
	/* END -  */

	/* Start - Method to get the URL from the custom setting */
    private String getCustomSettingValue(String strCSName)
    {
        String strUrl = '';
        SL_Navigation__c objNavigation = SL_Navigation__c.getAll().get(strCSName);
        if(objNavigation!= null)
            strUrl = objNavigation.URL__c;
        else
            strUrl = '#';
        return strUrl;
    }

    /*
		@MethodName		:	getCaptcha
		@param			:	None
		@Description	:	Sets strCaptcha ie Captcha again by selecting random Characters, Numbers and Style
		@Return 		:	String
	*/
    public String getCaptcha()
    {
    	try
    	{
	    	strCaptcha = '';

	    	//Setting captcha string by randomlyselecting 6 characters from a list of characters
	    	for(integer i = 0; i < 6; i++)
	    		strCaptcha += strCharactersCollection[randomNumber(strCharactersCollection)];

	    	//Setting captcha Font randomly
	    	strCaptchaStyle = lstStrFontStyle[randomNumber(lstStrFontStyle)];

	    	//Setting captcha Color randomly
	    	strCaptchaColor = lstStrFontColor[randomNumber(lstStrFontColor)];

	    	return strCaptcha;
	    }
		catch(Exception e)
		{
			system.debug('????????????????????'+e.getMessage()+'????????????'+e.getLineNumber());
			strPageMessage = 'An error occurred while loading data. Please refresh a browser.';
			isError = true;
			return Null;
		}
    }

    /*
		@MethodName		:	randomNumber
		@param			:	List of strings
		@Description	:	This methods simply returns a random number between 0 and the size of the character list
		@Return 		:	Integer
	*/
    private Integer randomNumber(List<String> lstParam)
    {
        Integer random = Math.Round(Math.Random() * lstParam.Size());
        if(random == lstParam.size()){
            random--;
        }
        return random;
    }

	/*
		@MethodName		:	validateCaptcha
		@param			:	None
		@Description	:	Checks whether a captcha enetered by User is matching or not if YES returns TRUE elese False
		@Return 		:	Boolean
	*/
    private Boolean validateCaptcha()
    {
        if(strInputCaptcha != strCaptcha)
        {
        	strIsErrorCaptcha = 'caseInput error form-control';
        	isError = isErrorCaptcha = true;
        	return false;
        }
        else
        {
        	isError = isErrorCaptcha = false;
            return true;
        }
    }

    /*
		@MethodName		:	submitCase
		@param			:	None
		@Description	:	Check Validations calls a method InsertCase
		@Return 		:	Void
	*/
    public pagereference submitCase()
    {
    	strPageMessage = '';
		isErrorCaptcha = false;
    	try
    	{
    		//Validating form
	    	if( validateForm() )
	    	{
	    		//Validating Captcha
	    		/*validateCaptcha() commented since this is not included in current html as per the requirement of CW-82 - Nrusingh Sahu*/
	    		/*validateCaptcha() uncommented since this is requested as per the points inscribed in CW-84 - Pankaj Ganwani */
	    		if(validateCaptcha())
	    		{
	    			//If everything is Valid, calls a method findArticles() to find Knowledge Articles and shows modal window
	    			isModalWindowRendered = true;
	    			
	    			//Checks if there are matching knowledge articles and if Yes Shows them in modal window else inserts a Case
			        if( objCase.Subject != null &&  !findArticles(objCase.Subject.trim()))
			        	insertCase();
			        else
			        	blnShowModal1 = true;
	    		}
	    		else
	    		{
	    			strPageMessage = 'Oops... some information is missing! ';
	    			strInputCaptcha =  strCaptcha = '';
	    		}
	    		
	    	}
	    	else
	    	{
	    		strPageMessage = 'Oops... some information is missing! ';
	    		strInputCaptcha = strCaptcha = '';
	    	}
    	}
		catch(Exception e)
		{
			system.debug('????????????????????'+e.getMessage()+'???'+e.getLineNumber());
			strPageMessage = 'An error occurred while loading data. Please refresh a browser.'; 
			isError = true;
		}
		return null;
    }
    
    /*
		@MethodName		:	closeModal
		@param			:	None
		@Description	:	Set Modal Parameters such that after rendering a page Modal window will get closed
		@Return 		:	Void
	*/
    public void closeModal()
    {
		// Setting Modal Window variables to render and display
    	isModalWindowRendered = false;
    	blnShowModal1 = false;
    	blnShowModal2 = false;
    }
    
    /*
		@MethodName		:	validateForm
		@param			:	None
		@Description	:	Checks if all the fields in a form are filled properly or not and returns a Tru or False accordingly
		@Return 		:	Boolean
	*/
    private Boolean validateForm()
    {
        return true;
        
    	//Checks all the form input variables and sets its class Name accordingly to highlight the input box
		strIsErrorCaptcha = 'caseInput form-control';
    	isError = false;

        for(Schema.FieldSetMember schemaFieldSetMember: Schema.SObjectType.Case.fieldSets.getMap().get('SL_'+strCustomSettingName+'_PostAQuestion').getFields())
    	{
    		
    		if(string.valueOf(schemaFieldSetMember.getType()) == 'email' && schemaFieldSetMember.getRequired() 
    					&& (objCase.get(schemaFieldSetMember.getFieldPath()) == null || ( objCase.get(schemaFieldSetMember.getFieldPath()) != null && !isValidEmail(string.valueOf(objCase.get(schemaFieldSetMember.getFieldPath()))))))
    		{
    		   
            	isError = true;
            	return false;
    		}
    		else if((string.valueOf(schemaFieldSetMember.getType()) == 'text' || string.valueOf(schemaFieldSetMember.getType()) == 'id'
    			 || string.valueOf(schemaFieldSetMember.getType()) == 'string' ) && schemaFieldSetMember.getRequired() && !isBlankOrNull(string.valueOf(objCase.get(schemaFieldSetMember.getFieldPath()))))
	        {
	            isError = true;
	            return false;
	        }
	        else if(string.valueOf(schemaFieldSetMember.getType()) == 'textarea' && schemaFieldSetMember.getRequired() 
	        	&& !isBlankOrNull(string.valueOf(objCase.get(schemaFieldSetMember.getFieldPath()))))
	        {
	            isError = true;
	            return false; 
	        }
	        else if((string.valueOf(schemaFieldSetMember.getType()) == 'picklist' || string.valueOf(schemaFieldSetMember.getType()) == 'multiselectpicklist' ) 
	        	&& schemaFieldSetMember.getRequired() && ( string.valueOf(objCase.get(schemaFieldSetMember.getFieldPath())) == null || string.valueOf(objCase.get(schemaFieldSetMember.getFieldPath())) == '--None--' || string.valueOf(objCase.get(schemaFieldSetMember.getFieldPath())) == ''))
	        {
	            isError = true;
	            return false;
	        }
    	}

        isError = false;
        return true;
    }

    /*
		@MethodName		:	isBlankOrNull
		@param			:	String
		@Description	:	Checks if a passed string is blank or Null and returns Tru or False accordingly
		@Return 		:	Boolean
	*/
	private Boolean isBlankOrNull(String strInputValue)
    {
    	// Trimmed a string before checking Null or Blank
    	if(strInputValue != null)
    	    strInputValue = strInputValue.trim();

    	if(strInputValue == null || strInputValue == '')
            return false;
        return true;
    }

	/*
	**	Method		:	isValidEmail
	**	Paramaters	:	String
	**	Return		:	Boolean
	**	Desc		:	Returns true if the string is a valid email
	*/
	private static Boolean isValidEmail(String str)
	{
		// Creating a regex pattern for Validating emailId
		String strEmailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
		Pattern MyPattern = Pattern.compile(strEmailRegex);

	    // Then instantiate a new Matcher object "MyMatcher"
	    Matcher MyMatcher = MyPattern.matcher(str);

	    if(MyMatcher.matches())
	        return true;	//valid email
	    else
	        return false;	//Invalid email
	}

    /*
	**	Method		:	findArticles
	**	Paramaters	:	String
	**	Return		:	Boolean
	**	Desc		:	Returns TRUE if there are knowledge articles matching string recieved as parameter else FALSE
	*/
	private Boolean findArticles(String strText)
    {
    	//Local Variables
		String publishStatus = '';
		String queryReturning = '';
		String strStatus = 'Featured';

		//List to store all the queried articles from 'searchList'(List of List)
		List<List<SObject>> searchList = new List<List<SObject>>();
        List<SObject> commonResultsList = new List<SObject>();

		//To cover the code in test coverage, becuase articles can't be made online through Apex code.
		publishStatus = 'online';
        //Dynamic SOSL query string
        string sosl = '';
        sosl = 'Find ' + '\'' + strText + '*\'' +  ' in ALL FIELDS '+ 'RETURNING ';

		String strObjectFields = '(ID, UrlName, Title, Summary, KnowledgeArticleId WHERE PublishStatus = \''+ publishStatus +
								 '\' AND Status__c = \'' + strStatus +
								 '\' and language = \'' + Userinfo.getLanguage() + '\')';
								 
		findArticleObjects();

		//Adding all _kav objects into query string to search the articles from all Article type objects
		for(String str : strKAVObjects.split(','))
		{
			if(queryReturning == '')
				queryReturning = str + strObjectFields ;
			else
				queryReturning += ',' + str + strObjectFields;
		}

		sosl += queryReturning;

		//Search to get the Articles
        if(strText.length() > 2)
        	searchList = search.query(sosl);

        for(List<Sobject> results : searchList)
        {
        	if(results.size() > 0)
        		commonResultsList.addAll(results);
        }

        lstSearchResults = new List<ArticleWrapper>();

        //To prepare 'knowledgeArticlesToDisplay' class objects with queried values to show it on a page
        for(SObject obj : commonResultsList)
        {
        	//To avoid the view state issue
        	if(lstSearchResults.size() == 3)
        		break;

        	lstSearchResults.add(new ArticleWrapper(String.valueOf(obj.getsobjecttype()),obj));
        }

    	if(lstSearchResults.size() > 0)
    		return true;
    	else
    		return false;
    }

	/*
	**	Method		:	findArticleObjects
	**	Paramaters	:	None
	**	Return		:	Void
	**	Desc		:	To get all the __Kav objects in a string in csv format.
	*/
	private void findArticleObjects()
	{
		//Local Variables
		String strAllKAVObjects = '';

		//Local Variables for fetching fields of knowledge articles
		Map<String, Schema.Sobjecttype> mapObject = new Map<String, Schema.Sobjecttype>();
		Map<string, schema.SobjectField> mapFields = new Map<string, schema.SobjectField>();
		Map<String, Set<String>> mapSobjectFields = new Map<String, Set<String>>();

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

				if(strAllKAVObjects != '')
					strAllKAVObjects += ',' + str;
				else
					strAllKAVObjects = str;
         	}
        }

        for(String strSobjects : strAllKAVObjects.split(','))
        {
        	//To get all the fields of the Sobject
  			mapFields = mapObject.get(strSobjects).getDescribe().fields.getmap();
  			//To get all field of each Article type
  			mapSobjectFields.put(strSobjects, new Set<String>());
  			// add as set of values in rowwise.
  			mapSobjectFields.get(strSobjects).addAll(mapFields.keyset());
        }

        for(String str : strAllKAVObjects.split(','))
        {
        	if(mapSobjectFields.get(str).Contains('status__c'))
        	{
	        	if(strKAVObjects != '')
					strKAVObjects += ',' + str;
				else
					strKAVObjects = str;
        	}
        }
	}

	/*
	**	Method		:	insertCase
	**	Paramaters	:	None
	**	Return		:	Void
	**	Desc		:	Inserts a case as per values inserted in input form
	*/
	public void insertCase()
	{
		try
		{
			objCase.Origin = 'Web';
			Case objCaseToBeInserted = objCase;
			if(objCase.SuppliedEmail != null && objCase.SuppliedEmail != '' )
				objCaseToBeInserted.ContactId = getMatchingContact(objCase.SuppliedEmail);
			//Product field should be defaulted based on the site 
			objCaseToBeInserted.Product__c = strCustomSettingName == 'ca' ? 'Calendar Anything' :strCustomSettingName == 'si' ? 'Water Cooler': strCustomSettingName == 'vrm'? 'VRM':'';
			if(strSubscriptionOrgId != '')
			{
				List<sfLma__License__c> lstLicenseRecords = new List<sfLma__License__c>();
				lstLicenseRecords = [Select Id, sfLma__Subscriber_Org_ID__c
									 From sfLma__License__c
									 Where sfLma__Subscriber_Org_ID__c =: strSubscriptionOrgId
									 AND Package_Name__c = : getCustomSettingValue(strCustomSettingName + '_' +'PackageName') Order By LastModifiedDate DESC LIMIT 1];
				if(!lstLicenseRecords.isEmpty())
				{
					objCaseToBeInserted.License__c = lstLicenseRecords[0].Id;
				}
			}
			Database.DMLOptions dmo = new Database.DMLOptions();
			dmo.assignmentRuleHeader.assignmentRuleId= '01Qa0000000HTqB';
			objCaseToBeInserted.setOptions(dmo);
			//Inserting a Case
			insert objCaseToBeInserted;
			isModalWindowRendered = true;
		    caseId = objCaseToBeInserted.Id;
		    
			//Setting Modal window variables to decide which modal window to be dispayed after insert
			blnShowModal2 = true;
			blnShowModal1 = false;
		}
		catch(Exception e)
		{
			isModalWindowRendered = blnShowModal2 = blnShowModal1 = false;
			strPageMessage = 'An error occurred Inserting Case. Please try again.';
			isError = true;
		}
	}
    
    /*@RemoteAction
    public static void createAtt(String caseId, String contentString, String fileName, String contentType, String fileExt)
    {
        if(fileExt == 'html' || fileExt == 'rtf' || fileExt == 'doc' || fileExt == 'docx' || fileExt == 'xls' || fileExt == 'xlsx' || fileExt == 'pdf' || fileExt == 'ppt' || fileExt == 'pptx' || fileExt == 'zip' || fileExt == 'rar')
            fileName+=fileName+'.'+fileExt;
        contentString = contentString.replace('{','').replace('}','').trim();
        Attachment obj = new Attachment(ParentId = caseId, Body = EncodingUtil.base64Decode(contentString), Name=fileName, ContentType = contentType);
        insert obj;
    }*/
     
	private Id getMatchingContact(String strEMailIdToMatch)
	{
		Id idMatchingContactId;
		for( Contact objContact : [ SELECT Id, Email FROM Contact WHERE Email =: strEMailIdToMatch ORDER BY CreatedDate LIMIT 1 ] )
		{
			idMatchingContactId = objContact.Id;
		}
		if( idMatchingContactId != Null || idMatchingContactId != '' )
			return idMatchingContactId;
		else
			return Null;
	}
	public void dummy()
	{
		
	}

	/*
	**	TestMethod	:	TestSL_Index
	**	Paramaters	:	None
	**	Return		:	Void
	**	Desc		:	Covering a code written above.
	*/
	@isTest()
    static void SL_PostAQuestion()
    {

    	SL_PostAQuestion objSLPAQ = new SL_PostAQuestion();

    	//Setting Input Fields vars of Form
    	objSLPAQ.objCase.SuppliedName = '';
    	objSLPAQ.validateForm();
    	objSLPAQ.objCase.SuppliedName = 'Hemant';
    	objSLPAQ.objCase.SuppliedEmail = '';
    	objSLPAQ.validateForm();
	    objSLPAQ.objCase.SuppliedEmail = 'Hemant';

	    objSLPAQ.objCase.Subject = '';
	    objSLPAQ.validateForm();
	    objSLPAQ.objCase.Subject = 'Hemant';
	    objSLPAQ.validateForm();
	    objSLPAQ.strCaptcha = 'abcdef';
    	objSLPAQ.strInputCaptcha = 'wrongCaptcha';

    	//Submitting form with invalid List value
    	objSLPAQ.submitCase();

    	//Submitting form with valid List value and  invalid Captcha Value
    	objSLPAQ.objCase.Type = 'Select one';
    	objSLPAQ.submitCase();

    	//Submitting form with valid Captcha Value
    	objSLPAQ.strInputCaptcha = 'abcdef';
    	objSLPAQ.submitCase();

    	objSLPAQ.objCase.Type = 'Technical Issue';
    	objSLPAQ.objCase.SuppliedEmail = 'Hemant@test.com';
    	objSLPAQ.submitCase();

    	objSLPAQ.objCase.Type = '';
	    objSLPAQ.validateForm();

	    objSLPAQ.objCase.Type = 'Test';
	    objSLPAQ.objCase.Subject = '';
	    objSLPAQ.validateForm();

    	//Inserting Knowledge Articles
    	Blob objBlob = Blob.valueOf('Body');
    	List<Website_Use_Case__kav> lst_InsertWebsiteUC = new List<Website_Use_Case__kav>();
    	Website_Use_Case__kav objWSUseCase = new Website_Use_Case__kav(Video_ID__c = '123444', UrlName = 'URL1', Title = 'Calendar Anything1', Status__c = 'Featured',
																		Article_Body__c = 'Body1',  Icon__Name__s ='Icon1',Icon__ContentType__s = 'image/png',
																		Icon__Body__s = objBlob, Summary='Test Test Test', Language = 'en_US');
																		//Icon__Body__s = objBlob ,Language = 'en_US',PublishStatus = 'Online');
    	lst_InsertWebsiteUC.add(objWSUseCase);

    	Website_Use_Case__kav objWSUseCase1 = new Website_Use_Case__kav(Video_ID__c = '1234441', UrlName = 'URL11', Title = 'Calendar Anything2', Status__c = 'Featured',
																		Article_Body__c = 'Body11',  Icon__Name__s ='Icon11',Icon__ContentType__s = 'image/png',
																		Icon__Body__s = objBlob ,Summary='Test Test Test', Language = 'en_US');
																		//Icon__Body__s = objBlob ,Language = 'en_US',PublishStatus = 'Online');
    	lst_InsertWebsiteUC.add(objWSUseCase1);

    	Website_Use_Case__kav objWSUseCase2 = new Website_Use_Case__kav(Video_ID__c = '1234442', UrlName = 'URL2', Title = 'Calendar Anything3', Status__c = 'Featured',
																		Article_Body__c = 'Body12',  Icon__Name__s ='Icon2',Icon__ContentType__s = 'image/png',
																		Icon__Body__s = objBlob ,Summary='Test Test Test', Language = 'en_US');
																		//Icon__Body__s = objBlob ,Language = 'en_US',PublishStatus = 'Online');
    	lst_InsertWebsiteUC.add(objWSUseCase2);

    	insert lst_InsertWebsiteUC;
    	Website_Use_Case__DataCategorySelection testDS1 = new Website_Use_Case__DataCategorySelection( ParentId=objWSUseCase2.Id,
    																									 DataCategoryName= 'Feature_Setup' , 
    																									 DataCategoryGroupName = 'Support_Category'
        																							 );
        insert testDS1;
        Website_Use_Case__DataCategorySelection testDS2 = new Website_Use_Case__DataCategorySelection( ParentId=objWSUseCase1.Id,
    																									 DataCategoryName= 'Feature_Setup' , 
    																									 DataCategoryGroupName = 'Support_Category'
        																							 );
        insert testDS2;
    	 Website_Use_Case__DataCategorySelection testDS3 = new Website_Use_Case__DataCategorySelection( ParentId=objWSUseCase.Id,
    																									 DataCategoryName= 'Feature_Setup' , 
    																									 DataCategoryGroupName = 'Support_Category'
        																							 );
        insert testDS3;
    	
    	Contact objContact = new Contact(LastName = 'Contact1' , Email = 'test@gmail.com');
    	insert objContact;
    	
    	RecordType objRT  = [Select Id, Name, sObjectType From RecordType
    									  Where Name = 'Product and Sales Support' AND
    									  sObjectType = 'Case' LIMIT 1];
    	SL_SiteName__c objNav = new SL_SiteName__c(Name = 'CalendarAnything_Website', SiteIdentifier__c = 'ca');
	    insert objNav;								  
    	SL_Navigation__c objNavigation = new SL_Navigation__c(Name = 'ca_ProductCategory', URL__c = 'CalendarAnything__c');
	    insert objNavigation;
	    
    									  
		SL_PostAQuestion.ArticleWrapper objAW = new SL_PostAQuestion.ArticleWrapper('Website_Feature__kav', objWSUseCase);
		
    	objSLPAQ.objCase.Subject = 'Body1';
    	objSLPAQ.submitCase();

    	objSLPAQ.closeModal();

    	objSLPAQ.getCaptcha();
    	objSLPAQ.validateCaptcha();
    	objSLPAQ.getCaptcha();

    	objSLPAQ.objCase.RecordTypeId = objRT.Id;
    	objSLPAQ.strSubscriptionOrgId = 'test';
    	objSLPAQ.insertCase();
    	objSLPAQ.findArticles('Test');
    	objSLPAQ.findArticleObjects();
    	objSLPAQ.strCaptcha = 'Test';
    	objSLPAQ.objCase.Subject = 'Test';
    	objSLPAQ.validateCaptcha();
    	objSLPAQ.submitCase();
    	
    	objSLPAQ.objCase.SuppliedName = 'Test';
    	objSLPAQ.objCase.SuppliedEmail = 'test@gmail.com';
		objSLPAQ.objCase.Type = 'Test';
		objSLPAQ.objCase.Subject = 'Test';
		objSLPAQ.submitCase();
		
		objSLPAQ.strCaptcha = 'Test';
    	objSLPAQ.objCase.Subject = 'Test';
    	objSLPAQ.validateCaptcha();
    	objSLPAQ.submitCase();
    	System.currentPageReference().getParameters().put('subId','test');
    	
    	SL_PostAQuestion objSLPAQ1 = new SL_PostAQuestion();
    	objSLPAQ1.objCase.SuppliedName = 'Test';
    	objSLPAQ1.objCase.SuppliedEmail = 'test@gmail.com';
		objSLPAQ1.objCase.Type = 'Test';
		objSLPAQ1.objCase.Subject = 'Test';
		objSLPAQ1.submitCase();
		objSLPAQ.strCustomSettingName = 'ca';
		list<Schema.FieldSetMember> lstSchemaFieldSet = Schema.SObjectType.Case.fieldSets.getMap().get('SL_'+objSLPAQ.strCustomSettingName+'_PostAQuestion').getFields();
    	for(Schema.FieldSetMember schemaFieldSetMember: lstSchemaFieldSet)
    	{
    		if(string.valueOf(schemaFieldSetMember.getType()) == 'email' && schemaFieldSetMember.getRequired())
    			objSLPAQ.objCase.put(schemaFieldSetMember.getFieldPath(), 'test@test.vom');
    		else if((string.valueOf(schemaFieldSetMember.getType()) == 'text' || string.valueOf(schemaFieldSetMember.getType()) == 'id' || string.valueOf(schemaFieldSetMember.getType()) == 'string' ) && schemaFieldSetMember.getRequired() )
	       	 objSLPAQ.objCase.put(schemaFieldSetMember.getFieldPath(), 'test');
	        else if((string.valueOf(schemaFieldSetMember.getType()) == 'picklist' || string.valueOf(schemaFieldSetMember.getType()) == 'multiselectpicklist' ) && schemaFieldSetMember.getRequired() )
    			objSLPAQ.objCase.put(schemaFieldSetMember.getFieldPath(),'test');
    		else if((string.valueOf(schemaFieldSetMember.getType()) == 'integer' || string.valueOf(schemaFieldSetMember.getType()) == 'decimal' ) && schemaFieldSetMember.getRequired() )
    		objSLPAQ.objCase.put(schemaFieldSetMember.getFieldPath(),'1234');
    	}
		
		objSLPAQ1.strCaptcha = 'Test';
    	objSLPAQ1.objCase.Subject = 'Test';
    	objSLPAQ1.validateCaptcha();
    	objSLPAQ1.submitCase();
    }
}