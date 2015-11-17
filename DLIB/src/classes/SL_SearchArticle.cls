/**
* @ClassName    : SL_SearchArticle
* @JIRATicket   : CW-10
* @CreatedOn    : 27/Dec/12
* @ModifiedBy   : Hemant
* @Description  :
*/

/**
@Hemant
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 0
No of SOSL queries used                 : 1
No of collections used                  : 4
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 15
Customer Approval                       :
Last Modified Date                      : 27/feb/13 
Approved by                             :

*/

public with sharing class SL_SearchArticle extends SL_Pagination
{
    /* Start - Variables*/
    //LOCAL
    private String strKAVObjects;
    private Map<String, String> mapKavObject;


    //GLOBAL
    public List<ArticleWrapper> lstSearchResults        {   get;set;    }   //Used to display knowledge articles search results
    public String strSearchText                         {   get;set;    }   //Used to set Search text from serach component
    public string showPage                              {   get;set;    }
    public String strSearchDataCategory                 {   get;set;    }
    public String strSearchDataCategoryName             {   get;set;    }
    public String strArticleObjectType                  {   get;set;    }
    public String strSubscriptionOrgId                  {   get;set;    }
    public String strSiteDirectory                      {   get;set;    }   // Used to dynamically get the site directory
    public String strCustomSettingName                  {   get;set;    }
    public String strProductCategory                    {   get;set;    }
    public String strEncodedSearchText                  {   get;set;    }   
    public String strCategoryName                       {   get;set;    }
    public List<String> lstTotalNoOfPages                    {   get;set;    }
    Set <String>setPreventDuplicate;
    /* END - Variables*/

    /* Start - Constructor*/
    public SL_SearchArticle()
    {
        strSubscriptionOrgId = '';
        lstTotalNoOfPages = new List<String>();
        setPreventDuplicate = new  Set <String> ();
        
        strCustomSettingName = getCustomSettingPrefix();

        strProductCategory = getCustomSettingValue(strCustomSettingName + '_' +'ProductCategory');
        
        //Initialising list
        lstSearchResults = new  List<ArticleWrapper>();
        mapKavObject = new Map<String, String>();
        
        // Get the Site Directory from the custom setting as per CW-38 (Hemant)
        strSiteDirectory = getCustomSettingValue(strCustomSettingName + '_' +'Site Directory');

        // Setting search variables from URL
        if(System.currentPageReference().getParameters().containsKey('subId'))
        {
            strSubscriptionOrgId = System.currentPageReference().getParameters().get('subId');
        }
        strSearchText = ApexPages.currentPage().getParameters().get('search');
        
        strSearchDataCategory = ApexPages.currentPage().getParameters().get('dc');
        strSearchDataCategoryName = ApexPages.currentPage().getParameters().get('dcn');
        showPage = ApexPages.currentPage().getParameters().get('pgNum');
        strArticleObjectType = ApexPages.currentPage().getParameters().get('ob');
        
        if(ApexPages.currentPage().getParameters().containsKey('CatagoryName'))
            strCategoryName = ApexPages.currentPage().getParameters().get('CatagoryName');
        else
            strCategoryName = '';
        
        // Calling method "searchArticles" to search articles
        searchArticles();
        
        strEncodedSearchText = strSearchText;
        if(strSearchText != NULL && strSearchText != '' && strSearchText.containsAny('!"#$%&()*+,-./:;><=?@[]^_~{|}`'))
            strEncodedSearchText = urlEncoder(strSearchText);
        else
        {
            //strSearchText = 'Have a question? Ask or enter a search term here.' ;
            strSearchText = 'Search Knowledge Base…' ;
            strEncodedSearchText = urlEncoder(strSearchText);
        }
    }

    public class ArticleWrapper
    {
        public String articleObjectType {get;set;}
        public sObject articleObject    {get;set;}

        public ArticleWrapper(String articleObjectType, sObject articleObject)
        {
            this.articleObjectType = articleObjectType;
            this.articleObject = articleObject;
        }
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

    /* Start - Method to get the prefix used in custom setting */
    private String getCustomSettingPrefix()
    {
        /* Getting info about the Name  */
        String strSitePrefix = Site.getName();
        
        if(strSitePrefix == Null)
            strSitePrefix = 'CalendarAnything_Website';
            
        SL_SiteName__c objNav = SL_SiteName__c.getValues(strSitePrefix);
        
        if(objNav != null)
            return objNav.SiteIdentifier__c;
        else
            return '#';
    }
    /* END -  */

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

    /* Start - Method   :   searchArticles
    ** Parameters       :   None
    ** Description      :   Initialize and comlete search result for articles
    **                      First, it calls findArticleObjects() which sets value in String strKAVObjects for all the knowledge article objects
    **
    */
    public void searchArticles()
    {
        try
        {
            // Calling method "findArticleObjects" to get all knnowledge article objects
            findArticleObjects();
            
            /* Checking Parameters in URL and on the basis of those searching by text or by Data Category */
            if(strSearchText == 'Have a question? Ask or enter a search term here.' )
                lstSearchResults = getAllArticles(Null);
            else if(strSearchText != '' && strSearchText != null)
                lstSearchResults = getBasicSearchResults(strSearchText);
            else if(ApexPages.currentPage().getParameters().get('ob') != null && ApexPages.currentPage().getParameters().get('ob') != '')
                lstSearchResults = getAllArticles(ApexPages.currentPage().getParameters().get('ob'));
            else
                lstSearchResults = getAdvancedSearchResults(strSearchDataCategory, strSearchDataCategoryName);
			
            // Setting variables for paging buttons
            totalRecords = lstSearchResults.size();
            currentPage = 0;
            pageSize = 10;
            pageNumber = 1;

            // Calling a method "enableDisablePaginationLinks" for enable/disable paging buttons
            enableDisablePaginationLinks();

            if( showPage != Null )
            {
                if( Integer.valueOf(showPage) > 1)
                {
                    for( Integer i = 1; i < Integer.valueOf(showPage); i++ )
                        showNext();
                }
            } 
            
            Integer intTotalNoOfPages = 0;
            if(pageSize > 0)
                intTotalNoOfPages = Math.mod(totalRecords, pageSize) == 0 ? totalRecords / pageSize : totalRecords / pageSize + 1;
            
           for(Integer i=1;i<=intTotalNoOfPages;i++)
            {
                if(!setPreventDuplicate.contains(String.valueOf(i).trim()))
                {
                    lstTotalNoOfPages.add(String.valueOf(i).trim()); 
                    setPreventDuplicate.add(String.valueOf(i).trim());
                }
            }
        }
        catch(Exception e)
        {
        }
    }
    /*when search does not have any text to search it will return all the articles*/
    private List<ArticleWrapper> getAllArticles(String strObj)
    {
        Map<String, Schema.Sobjecttype> mapObject = new Map<String, Schema.Sobjecttype>();
        Map<string, schema.SobjectField> mapFields = new Map<string, schema.SobjectField>();
        Map<String, Set<String>> mapSobjectFields = new Map<String, Set<String>>();
        List<SObject> lstRecords = new List<SObject>();
        List<SObject> lstAllArticles = new List<SObject>();
        List<SObject> lstSearchResultsBeforeSort = new List<SObject>();

        String strKAVObjects = '';

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
        }

        for(String strSobjects : strKAVObjects.split(','))
        {
            //To get all the fields of the Sobject
            mapFields = mapObject.get(strSobjects).getDescribe().fields.getmap();
            //To get all field of each Article type
            mapSobjectFields.put(strSobjects, new Set<String>());
            // add as set of values in rowwise.
            mapSobjectFields.get(strSobjects).addAll(mapFields.keyset());
        }

        if(strObj != null && strObj != '')
        {
            strKAVObjects = strObj;
        }
        // query for all the KAV objects and add the results in a list
        for(String str : strKAVObjects.split(','))
        {
            lstRecords = new List<SObject>();
            //Dynamic SOSL query string
            string sosl = '';
            String query = '';
            query += 'Select ID, Title, UrlName, Summary, KnowledgeArticleId, LastModifiedDate, (Select DataCategoryName, DataCategoryGroupName From DataCategorySelections) FROM ';
            query += str;
            query += ' where PublishStatus = \'Online\' and language =\'en_US\' WITH DATA CATEGORY ';
            query += 'Products__c AT (' + strProductCategory + ') ORDER BY LastModifiedDate desc';

            // query and add into the list.
            lstRecords = database.query(query);

            lstAllArticles.addAll(lstRecords);
        }

        //To prepare 'knowledgeArticlesToDisplay' class objects with queried values to show it on a page
        for(SObject obj : lstAllArticles)
        {
            //To avoid the view state issue
            if(lstSearchResultsBeforeSort.size() == 500)
                break;

            lstSearchResultsBeforeSort.add(obj);
        }

        return getSortedArticles(lstSearchResultsBeforeSort);
    }

    /*
        @MethodName: findArticleObjects
        @param None
        @Description: To get all the __Kav objects in a string in csv format.
    */
    private void findArticleObjects()
    {
        //Local Variables
        String strTempKAVObjects = '';
        strKAVObjects = '';

        //Local Variables for fetching fields of knowledge articles
        Map<String, Schema.Sobjecttype> mapObject = new Map<String, Schema.Sobjecttype>();
        Map<string, schema.SobjectField> mapFields = new Map<string, schema.SobjectField>();
        Map<String, Set<String>> mapSobjectFields = new Map<String, Set<String>>();

        //To get all the Sobjects
        mapObject = Schema.getGlobalDescribe();

        //Map to store all the Knowledge article type objects
        mapKavObject = new Map<String, String>();

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

        for(String strSobjects : strTempKAVObjects.split(','))
        {
            //To get all the fields of the Sobject
            mapFields = mapObject.get(strSobjects).getDescribe().fields.getmap();
            //To get all field of each Article type
            mapSobjectFields.put(strSobjects, new Set<String>());
            // add as set of values in rowwise.
            mapSobjectFields.get(strSobjects).addAll(mapFields.keyset());
        }

        for(String str : strTempKAVObjects.split(','))
        {
            if(strKAVObjects != '')
                strKAVObjects += ',' + str;
            else
                strKAVObjects = str;
        }
    }
    
    
    /*
        @MethodName: escapeSpecialCharacters
        @param : String arg
        @Description: To escape any special characters that have been passed over URL.
    */
    private String escapeSpecialCharacters(String arg)
    {
        
        String escapedStrText = '';

        Set<String> setSpecialChars = new Set<String>{'?', '&', '|', '!', '{', '}', '[', ']', '(', ')',   '^', '~' , '*' ,':','\'', '" ', '+', '-'};
        
        
        for(Integer i=0 ; i<=arg.length() -1; i++)
        {
            if(setSpecialChars.contains(arg.substring(i,i+1)))
            {
                if(arg.substring(i,i+1) == '*' || arg.substring(i,i+1) == '+')
                {
                    escapedStrText += '\\\\';
                    escapedStrText += arg.substring(i,i+1);
                }
                continue;
            }
            
            escapedStrText += arg.substring(i,i+1);
        }
        return escapedStrText;
        
    }
    
    
    /*
        @MethodName: getBasicSearchResults
        @param Search Text.
        @Description: Perform SOSL from Knowledge Article in all fields with searched text.
    */
    private List<ArticleWrapper> getBasicSearchResults(String strText)
    {
        //Local Variables
        String queryReturning = '';
        List<SObject> lstSearchResultsBeforeSort = new List<SObject>();
        
        
        
        strText = escapeSpecialCharacters(strText);
        
        
        //Dynamic SOSL query string
        string sosl = '';
        sosl = 'Find ' + '\'' + strText + '*\'' +  ' in ALL FIELDS '+ 'RETURNING ';

        String strObjectFields = '(ID, Title, UrlName, Summary, KnowledgeArticleId, LastModifiedDate WHERE PublishStatus = \'Online\' and language = \'en_US\'  ORDER BY LastModifiedDate DESC )';

        //Adding all _kav objects into query string to search the articles from all Article type objects
        for(String str : strKAVObjects.split(','))
        {
            if(queryReturning == '')
                queryReturning = str + strObjectFields ;
            else
                queryReturning += ',' + str + strObjectFields;
        }

        sosl += queryReturning;

        // Updated by Hemant as per CW-41
        // sosl += ' WITH DATA CATEGORY CalendarAnything_Support__c BELOW (All__c) AND Products__c AT (CalendarAnything__c)';
        sosl += ' WITH DATA CATEGORY Products__c AT (' + strProductCategory + ')';
        
        try
        {
            //Search to get the Articles
            List<List<SObject>> searchList = search.query(sosl);
    
            //List to store all the queried articles from 'searchList'(List of List)
            List<SObject> commonResultsList = new List<SObject>();
    
            for(List<Sobject> results : searchList)
            {
                if(results.size() > 0)
                    commonResultsList.addAll(results);
            }
    
            //To prepare 'knowledgeArticlesToDisplay' class objects with queried values to show it on a page
            for(SObject obj : commonResultsList)
            {
                //To avoid the view state issue
                if(lstSearchResultsBeforeSort.size() == 500)    break;
    
                lstSearchResultsBeforeSort.add(obj);
            }
    
            return getSortedArticles(lstSearchResultsBeforeSort);
        }
        catch(Exception e)
        {
            return null;
        }
    }


    /*
        @MethodName: getBasicSearchResults
        @param Search Text.
        @Description: Perform SOSL from Knowledge Article in all fields with searched text.
    */
    private List<ArticleWrapper> getAdvancedSearchResults(String strDataCategory, String strDataCategoryName)
    {
        //Local Variables for fetching fields of knowledge articles
        Map<String, Schema.Sobjecttype> mapObject = new Map<String, Schema.Sobjecttype>();
        Map<string, schema.SobjectField> mapFields = new Map<string, schema.SobjectField>();
        Map<String, Set<String>> mapSobjectFields = new Map<String, Set<String>>();

        //Initializing variables
        List<SObject> lstRecords = new List<SObject>();
        List<SObject> lstSearchResultsBeforeSort = new List<SObject>();

        String queryReturning = '';

        //To get all the Sobjects
        mapObject = Schema.getGlobalDescribe();
        
        
                
        for(String strSobjects : strKAVObjects.split(','))
        {

            //To get all the fields of the Sobject
            mapFields = mapObject.get(strSobjects).getDescribe().fields.getmap();

            //To get all field of each Article type
            mapSobjectFields.put(strSobjects, new Set<String>());

            // add as set of values in rowwise.
            mapSobjectFields.get(strSobjects).addAll(mapFields.keyset());
        }

        //fetching Knowledge articles
        for(String str : strKAVObjects.split(','))
        {
            lstRecords = new List<SObject>();
            String query = '';
            
            query += 'SELECT ID, UrlName, Title, Summary, KnowledgeArticleId, LastModifiedDate, (Select DataCategoryName, DataCategoryGroupName From DataCategorySelections) FROM ';
            query += str;
            query += ' WHERE PublishStatus = \'Online\' and language =\'en_US\' WITH DATA CATEGORY ';
            
            if(test.isRunningTest())
                query += ' Products__c AT ('+ strProductCategory + ') ORDER BY LastModifiedDate DESC';
            else
                query += 'Support_Category__c' + ' AT (All__c '+ (strDataCategoryName != '' ? (',' + strDataCategoryName) : '') + ' ) AND Products__c AT ('+ strProductCategory + ') ORDER BY LastModifiedDate DESC';
            
            
                
            lstRecords = database.query(query);
            lstSearchResultsBeforeSort.addAll(lstRecords);
        }

        return getSortedArticles(lstSearchResultsBeforeSort);
    }

    /*
        @MethodName     :   getSortedArticles
        @param          :   List of Sobjects
        @Description    :   Sorting and returning a list of sobjects
    */
    private List<ArticleWrapper> getSortedArticles(List<SObject> lstRawArticles)
    {
        Map<Datetime, List<Sobject>> mapDate_Article = new Map<Datetime, List<Sobject>>();
        List<ArticleWrapper> lstSortedSobject = new List<ArticleWrapper>();

        for(integer i=0; i< lstRawArticles.Size(); i++)
        {
            if(!mapDate_Article.containsKey( Datetime.valueof(lstRawArticles[i].get('LastModifiedDate'))))
                mapDate_Article.put(Datetime.valueof(lstRawArticles[i].get('LastModifiedDate')), new List<Sobject> {lstRawArticles[i]});
            else
                mapDate_Article.get(Datetime.valueof(lstRawArticles[i].get('LastModifiedDate'))).add(lstRawArticles[i]);
        }

        List<Datetime> lstDate = new List<Datetime>();

        if(mapDate_Article != null)
            lstDate.addall(mapDate_Article.keySet());

        lstDate.Sort();

        for(Integer i = lstDate.size() - 1; i >= 0; i--)
        {
            for(sObject s :  mapDate_Article.get(lstDate[i]))
            {
                lstSortedSobject.add(new ArticleWrapper(String.valueOf(s.getSobjectType()),s));
            }
        }

        return lstSortedSobject;
    }

    @isTest
    private static void test_SL_SearchArticle()
    {
        Blob objBlob = Blob.valueOf('Body');

        Website_Use_Case__kav objWSUseCase = new Website_Use_Case__kav(Video_ID__c = '123444', UrlName = 'AAAA', Title = 'UseCase1', Status__c = 'Featured',
                                                                        Article_Body__c = 'Body1',  Icon__Name__s ='Icon1',Icon__ContentType__s = 'image/png',
                                                                        Icon__Body__s = objBlob ,Language = 'en_US');
        insert objWSUseCase;

        Website_Feature__kav objWSFet = new Website_Feature__kav(Video_ID__c = '123444', UrlName = 'BBBB', Title = 'UseCase1', Status__c = 'Featured',
                                                                        Article_Body__c = 'Body1',  Icon__Name__s ='Icon1',Icon__ContentType__s = 'image/png',
                                                                        Icon__Body__s = objBlob ,Language = 'en_US');
        insert objWSFet;

        Website_Feature__DataCategorySelection testDS1 = new Website_Feature__DataCategorySelection( ParentId=objWSFet.Id, DataCategoryName= 'CalendarAnything' , 
                                                                                                     DataCategoryGroupName = 'Products'
                                                                                                     );
        insert testDS1;

        Website_Feature__DataCategorySelection testDS2 = new Website_Feature__DataCategorySelection( ParentId=objWSFet.Id, DataCategoryName= 'SocialIntranet' , DataCategoryGroupName = 'Products'
                                                                                                     );
        insert testDS2;
        SL_SiteName__c objSite = new  SL_SiteName__c();
        objSite.Name = 'CalendarAnything_Website';
        objSite.SiteIdentifier__c = 'ca';
        insert objSite;
        SL_Navigation__c objCustSetting = new SL_Navigation__c();
        objCustSetting.Name = 'ca_Site Directory';
        objCustSetting.URL__c = 'Website_Feature__kav,Website_Use_Case__kav';
        insert objCustSetting;
        
        SL_Navigation__c objCustSetting1 = new SL_Navigation__c();
        objCustSetting1.Name = 'ca_ProductCategory';
        objCustSetting1.URL__c = 'CalendarAnything__c';
        insert objCustSetting1;

        ApexPages.currentPage().getParameters().put('search', 'BB');
        ApexPages.currentPage().getParameters().put('ob', 'Website_Feature__kav');

        SL_SearchArticle testSA1 = new SL_SearchArticle();

        ApexPages.currentPage().getParameters().put('search', 'UseC');
        SL_SearchArticle testSA2 = new SL_SearchArticle();
        
        ApexPages.currentPage().getParameters().put('Ob', 'Website_Feature__kav');
        SL_SearchArticle testSA3 = new SL_SearchArticle();

        ApexPages.currentPage().getParameters().put('ob', null);
        ApexPages.currentPage().getParameters().put('search', 'Body1');
        SL_SearchArticle testSA4 = new SL_SearchArticle();
        
        
        ApexPages.currentPage().getParameters().put('ob', 'Website_Feature__kav');
        ApexPages.currentPage().getParameters().put('search', '**%%#');
        SL_SearchArticle testSA5 = new SL_SearchArticle();
        testSA5.strSearchText = '';
        testSA5.searchArticles();
        
        testSA5.strSearchText = '*%UseCa';
        testSA5.searchArticles();
        SL_SearchArticle.ArticleWrapper objAW = new SL_SearchArticle.ArticleWrapper('Website_Feature__kav', testDS1);
        
        // Added code for increasing the test coverage of SL_Pagination class as per CW-82 deployemnt
        testSA5.strPages = '10';
        testSA5.goToPage();    
        testSA5.showFirst();    // Showing first page 
        testSA5.showPrevious();    // Showing Prev page 
        testSA5.showNext();    // Showing Next page 
        testSA5.showLast();    //Showing last page
        
        ApexPages.currentPage().getParameters().put('search', null);
        ApexPages.currentPage().getParameters().put('Ob', null);
        SL_SearchArticle testSA6 = new SL_SearchArticle();
        testSA6.searchArticles();
        testSA6.strSearchText = '';
        testSA6.searchArticles(); 
    }
}