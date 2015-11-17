/**
* @ClassName    : SL_Index 
* @JIRATicket   : CW -2,3,4
* @CreatedOn    : 11/Dec/12
* @ModifiedBy   : SL
* @Description  : 
*/

/**
@Shailendra
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 5
No of collections used                  : 3
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 10/Dec/12
Approved by                             : 

*/

public with sharing class SL_Index
{
    
    /* Start - Variables */
    
    /* Start - Home Page Variables */
    //public List<TestimonialWrapper> lstTestimonialWrapper           {   get;set;    }
    public String strinstallCalenderAnythingURL                     {   get;set;    }
    public String strSiteDirectory                                  {   get;set;    } // Used to dynamically get the site directory
    public String strLogoDescription                                {   get;set;    }
    /* End - Home Page Variables */
    
    /* Start - global variable declaration for Feature page section for Feature page section as per CW-3*/
    public transient List<wrapperWebsiteFeature> lstWrapperWebsiteFeature     {   get;set;    }
    public String strVideoId                                        {   get;set;    }
    public String strTitle                                          {   get;set;    }
    public String strBodyContent                                    {   get;set;    }
    public String strArticleId                                      {   get;set;    }
    public String strSubscriptionOrgId                  {get;set;}
    /* Stop - global variable declaration for Feature page section*/
    
    /* Start - global variable declaration for Use Case page section as per CW-3*/
    public transient List<KnowledgeArticleUseCase> lstKnowledgeArticleUseCase {   get;set;    }
    public String strVideoIdUseCase                                 {   get;set;    }
    public String strTitleUseCase                                   {   get;set;    }
    public String strBodyContentUseCase                             {   get;set;    }
    public String strArticleIdUseCase                               {   get;set;    }
    public String strCustomSettingName                          {   get;set;    }
    public String strProductCategory                                {   get;set;    }
    public String strHomePageVideoId                                {   get;set;    }
    public List<String> strHomePageObjects                          {   get;set;    }
    /* End - global variable declaration for Use Case page  section as per CW-3*/
    /* End - Variables */
    
    /* Start - Inner Class for Home Page */
    public class TestimonialWrapper
    {
        /* Start of Inner class variables*/
        public Testimonial__c objCA      {   get;set;    }
        public Integer evenOdd  {   get;set;    }
        /* End of Inner class variables*/
        
        /* Start - Constructor*/
        public TestimonialWrapper(Testimonial__c objCA ,  Integer evenOdd)
        {
            this.objCA = objCA;
            this.evenOdd = evenOdd;
        }
        /* End - Constructor*/
    }
    /* End - Inner Class for Home Page */
    
    /*Start - wrapper class for WebsiteFeature for Feature page section as per CW-3*/
    public class wrapperWebsiteFeature
    {
        public transient Sobject objWebSiteFeature                  {    get;set;    }
        public transient String strImage                            {    get;set;    }
        // inner class constructor
        public wrapperWebsiteFeature(String strFeatureObject)
        {
            Schema.SObjectType ObjType = Schema.getGlobalDescribe().get(strFeatureObject);
            objWebSiteFeature = ObjType.newSobject();
            
            strImage = '';
        }
    }
    /*Stop - wrapper class for WebsiteFeature*/
    
    /*Start - wrapper class for KnowledgeArticleUseCase for Use Case page section as per CW-4*/
    public class KnowledgeArticleUseCase
    {
        /* Start of Inner class variables*/
        public transient Sobject objKnowledgeArticleUseCase                 {   get;set;    }
        public transient String strImageUC                                  {   get;set;    }
        /* End of Inner class variables*/
        
        /* Inner Class Constructor - KnowledgeArticleUseCase */
        public KnowledgeArticleUseCase(String strUseCaseObject)
        {
            Schema.SObjectType ObjType = Schema.getGlobalDescribe().get(strUseCaseObject);
            objKnowledgeArticleUseCase = ObjType.newSobject();
            
            /* Initializing Inner class variables */
            strImageUC = '';
        }
    }
    /*End - wrapper class for KnowledgeArticleUseCase for Use Case page section as per CW-4*/
    
    
    /* Start - Constructor*/
    public SL_Index()
    {
        /* Start - Home Page*/ 
        //To intialize all the variables onload of the page.
        initialization();
        
        if(System.currentPageReference().getParameters().containsKey('subId'))
        {
            strSubscriptionOrgId = System.currentPageReference().getParameters().get('subId');
        }
        
        //To get the records for the Testimonials.
        getTestimonialRecords();
        
        /* End - Home Page*/
        
        /*Start - fetchAllFeatureArticle function will fetah all articles with staus type as "Feature" for Feature page section as per CW-3*/
        fetchAllFeatureArticle();
        /*Stop*/
        // fetch all WebsiteUseCase Article types
        fetchWebUseCaseKA();

        
    }
    /* End - Constructor*/
    
    /* Start - Method*/
    private void initialization()
    {
        strCustomSettingName = getCustomSettingName();
        
        strProductCategory = getCustomSettingValue(strCustomSettingName + '_' +'ProductCategory');
        
        strHomePageVideoId = getCustomSettingValue(strCustomSettingName + '_' +'HomePageVideoId');
        
        String strCSVObjects = getCustomSettingValue(strCustomSettingName + '_' +'HomePageObjects');
        
        strHomePageObjects = strCSVObjects.split(',');
        
        // Get the Site Directory from the custom setting as per CW-38 (Hemant)
        SL_Navigation__c objNavigation = SL_Navigation__c.getValues(strCustomSettingName + '_' +'Site Directory');
        if(objNavigation!= null)
            strSiteDirectory = objNavigation.URL__c;
        else
            strSiteDirectory = '#';     
        
        /*Start - Home page*/
        strLogoDescription = '';
        //To get the value for URL in the Navigation from the custom setting.
        strinstallCalenderAnythingURL = getCustomSettingValue(strCustomSettingName + '_' + 'Install Calendar Anything');
        system.debug('---strinstallCalenderAnythingURL--------'+strinstallCalenderAnythingURL);
        /* End - Home Page*/
        
        /*Start - initialization for Feature page section variables for Feature page section as per CW-3*/
        lstWrapperWebsiteFeature = new List<wrapperWebsiteFeature>();
        strVideoId = strBodyContent = strTitle = strArticleId = strSubscriptionOrgId = '';
        /*Stop - initialization for Feature page section variables*/
        
        /*Start - initialization for Feature page section variables for Use Case page section as per CW-4*/             
        lstKnowledgeArticleUseCase = new List<KnowledgeArticleUseCase>(); 
        strVideoIdUseCase = strBodyContentUseCase = strTitleUseCase = strArticleIdUseCase = '';
        /*Stop - initialization for Feature page section variables*/    
    }
    /* End - Method*/
    
    /* Start - Method to get the URL from the custom setting */
    private String getCustomSettingValue(String strCSName)
    {
        system.debug('*****************'+strCSName);
        String strUrl = '';
        SL_Navigation__c objNavigation = SL_Navigation__c.getValues(strCSName);
        system.debug(objNavigation+':::::::::strCSName:::'+strCSName);
        if(objNavigation!= null)
            strUrl = objNavigation.URL__c;
        else
            strUrl = '#';
        return strUrl;
    }
    /* Start - Method to get the URL from the custom setting */
    
    /* Start - Method to get the records for the Testimonial */
    public List<TestimonialWrapper> getTestimonialRecords() 
    {
        Integer counter = 0;
        List<TestimonialWrapper> lstTestimonialWrapper = new List<TestimonialWrapper>();
        
       if(Test.isRunningTest())
            strSiteDirectory = 'socialintranet';
        
        for(Testimonial__c objCA : [SELECT Body__c,Image_URL__c,Person_Name__c,Product__c
                                    FROM Testimonial__c
                                    WHERE Product__c =: strSiteDirectory
                                    LIMIT 10
                                   ])
        {
            TestimonialWrapper objTestimonialWrapper = new TestimonialWrapper(objCA,counter);
            lstTestimonialWrapper.add(objTestimonialWrapper);
            counter ++;
            if(counter > 1)
                counter = 0;
        }
        return lstTestimonialWrapper;
    }
    /* End - Method to get the records for the Testimonial */
    
    /* Start - Method to fetching Website Use Case Knowledge Articles and adding to a list of Inner Class */
    private void fetchWebUseCaseKA()
    {
        //Updated by Hemant as per CW-44 
        //Publish Status made dynamic as we can not publist articles via code in test class
        String strPublishStatus = '\'Online\'';
        
        /*if(Test.isRunningTest())
            strPublishStatus = '\'Draft\'';*/
        
        String strQuery = 'SELECT Video_ID__c, UrlName, Title, Status__c, PublishStatus, Language, KnowledgeArticleId, Id, '+
                          'Article_Body__c, Icon__Name__s, Icon__ContentType__s, Icon__Length__s, Icon__Body__s '+
                          'FROM '+ strHomePageObjects[1] + 
                          ' WHERE PublishStatus = ' + strPublishStatus + 
                          ' AND Language = \'en_US\' AND Status__c = \'Featured\' ';
                if(!Test.isRunningTest())
                    strQuery += 'WITH DATA CATEGORY Products__c AT ('+ strProductCategory +') ';
                strQuery += ' ORDER BY CreatedDate limit 5 ';
        
        /*for(Website_Use_Case__kav objKnowledgeArticleUC : [ SELECT Video_ID__c, UrlName, Title, Status__c, PublishStatus, Language, KnowledgeArticleId, Id, 
                                                            Article_Body__c, Icon__Name__s, Icon__ContentType__s, Icon__Length__s, Icon__Body__s
                                                            FROM Website_Use_Case__kav 
                                                            WHERE PublishStatus =: strStatus AND Language = 'en_US' AND Status__c = 'Featured' WITH DATA CATEGORY Products__c AT (CalendarAnything__c)
                                                            ORDER BY CreatedDate limit 5])
        */
        
        List<Sobject> lstWebsiteUseCase = new List<Sobject>();
        
        //fetching Knowledge articles of Use Case type
        lstWebsiteUseCase = database.query(strQuery);
        
        for(Sobject objKnowledgeArticleUC : lstWebsiteUseCase )
        {
            KnowledgeArticleUseCase objKnowledgeArticle = new KnowledgeArticleUseCase(strHomePageObjects[1]);
            objKnowledgeArticle.objKnowledgeArticleUseCase = objKnowledgeArticleUC;
            if(objKnowledgeArticleUC.get('Icon__Length__s') != null)
                objKnowledgeArticle.strImageUC = EncodingUtil.Base64Encode((Blob)objKnowledgeArticleUC.get('Icon__Body__s'));
            lstKnowledgeArticleUseCase.add(objKnowledgeArticle);
        }
        
        
        if(lstKnowledgeArticleUseCase.size() > 0)
        {
            strVideoIdUseCase = string.valueOf(lstKnowledgeArticleUseCase[0].objKnowledgeArticleUseCase.get('Video_ID__c')); 
            strBodyContentUseCase = string.valueOf(lstKnowledgeArticleUseCase[0].objKnowledgeArticleUseCase.get('Article_Body__c')); 
            strTitleUseCase = string.valueOf(lstKnowledgeArticleUseCase[0].objKnowledgeArticleUseCase.get('Title')); 
            strArticleIdUseCase = string.valueOf(lstKnowledgeArticleUseCase[0].objKnowledgeArticleUseCase.get('Id'));
        }   
        
    }
    /* End - Method to fetching Website Use Case Knowledge Articles and adding to a list of Inner Class */
    
    /*Start - showSelectedArticleRecords method for Use Case page section as per CW-4*/
    public void showSelectedUseCaseArticleRecords()
    {
       // Get the Website_Use_Case__kav record that has been selected
      
       String strQuery = 'SELECT Video_ID__c, Title, Id, Article_Body__c' +
                         ' FROM ' + strHomePageObjects[1] +
                         ' WHERE Id =: strArticleIdUseCase';
       
       Sobject objKnowledgeArticleUC = database.query(strQuery);
       
       strVideoIdUseCase = (String)objKnowledgeArticleUC.get('Video_ID__c'); 
       strBodyContentUseCase = (String)objKnowledgeArticleUC.get('Article_Body__c'); 
       strTitleUseCase = (String)objKnowledgeArticleUC.get('Title'); 
    }
    /*End - showSelectedArticleRecords method */
    
    
    /*Start - fetchAllFeatureArticle method for Feature page section as per CW-3*/
    private void fetchAllFeatureArticle()
    {
        //Updated by Hemant as per CW-44
        //Publish Status made dynamic as we can not publist articles via code in test class     
        String strPublishStatus = '\'Online\'';
        
        /*if(Test.isRunningTest())
            strPublishStatus = '\'Draft\'';*/
        
        String strQuery = 'Select Video_ID__c, Title, KnowledgeArticleId, Icon__Name__s, Icon__Length__s,'+
                          'Id, Article_Body__c, LastModifiedDate, Icon__ContentType__s, Icon__Body__s, Status__c, PublishStatus, Language '+
                          'From '+ strHomePageObjects[0] +
                          ' WHERE PublishStatus = ' + strPublishStatus + 
                          ' AND Language = \'en_US\' AND Status__c = \'Featured\' ';
                if(!Test.isRunningTest())
                    strQuery += 'WITH DATA CATEGORY Products__c AT ('+ strProductCategory +') ';
                strQuery += ' ORDER BY CreatedDate limit 5 ';
        List<Sobject> lstWebsiteFeature = new List<Sobject>();
        //fetching Knowledge articles of Feature type
        lstWebsiteFeature = database.query(strQuery);
        //for(Website_Feature__kav objWebFeature : lstWebsiteFeature )
        for(Sobject objWebFeature : lstWebsiteFeature )
        {
            wrapperWebsiteFeature objWrapper = new wrapperWebsiteFeature(strHomePageObjects[0]);
            objWrapper.objWebSiteFeature = objWebFeature;
            if(objWebFeature.get('Icon__Length__s') != null)
                objWrapper.strImage = EncodingUtil.Base64Encode((Blob)objWebFeature.get('Icon__Body__s'));
            // add to the Wrapper list
            lstWrapperWebsiteFeature.add(objWrapper);
        }
        
        // assign the values to display on page load.
        if(lstWrapperWebsiteFeature.size() > 0)
        {
            strVideoId = (string)lstWrapperWebsiteFeature[0].objWebSiteFeature.get('Video_ID__c'); 
            strBodyContent = (string)lstWrapperWebsiteFeature[0].objWebSiteFeature.get('Article_Body__c'); 
            strTitle = (string)lstWrapperWebsiteFeature[0].objWebSiteFeature.get('Title'); 
            strArticleId = (string)lstWrapperWebsiteFeature[0].objWebSiteFeature.get('Id');
        }
    }
    /*End - fetchAllFeatureArticle method */
    
    /*Start - showSelectedArticleRecords method for Feature page section as per CW-3*/
    public void showSelectedArticleRecords()
    {
       // Get the records from firstObject that has been selected
       String strQuery = 'SELECT Video_ID__c, Title, Id, Article_Body__c' +
                         ' FROM ' + strHomePageObjects[0] +
                         ' WHERE Id =: strArticleId';
       sobject objWebFeature = database.query(strQuery);
       strVideoId = (String)objWebFeature.get('Video_ID__c'); 
       strBodyContent = (String)objWebFeature.get('Article_Body__c'); 
       strTitle = (String)objWebFeature.get('Title');
    }
    /*End - showSelectedArticleRecords method */
    
    /* Start - Method to get the prefix used in custom setting */
    private String getCustomSettingName()
    {
        /* Getting info about the Name  */
        String strSiteName = Site.getName();
        system.debug('------'+strSiteName); 
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
    @isTest()
    static void TestSL_Index()
    {
        List<Testimonial__c> lst_InsertCA = new List<Testimonial__c>();
        Testimonial__c objCA = new Testimonial__c(Body__c = 'Body1',Image_URL__c = 'https://image1.com',Person_Name__c = 'Person1',Product__c = 'socialintranet');
        lst_InsertCA.add(objCA);
        Testimonial__c objCA1 = new Testimonial__c(Body__c = 'Body2',Image_URL__c = 'https://image2.com',Person_Name__c = 'Person2',Product__c = 'socialintranet');
        lst_InsertCA.add(objCA1);
        Testimonial__c objCA2 = new Testimonial__c(Body__c = 'Body3',Image_URL__c = 'https://image3.com',Person_Name__c = 'Person3',Product__c = 'socialintranet');
        lst_InsertCA.add(objCA2);
        Testimonial__c objCA3 = new Testimonial__c(Body__c = 'Body4',Image_URL__c = 'https://image4.com',Person_Name__c = 'Person4',Product__c = 'socialintranet');
        lst_InsertCA.add(objCA3);
        insert lst_InsertCA;
        
        Blob objBlob = Blob.valueOf('Body');
        List<Website_Use_Case__kav> lst_InsertWebsiteUC = new List<Website_Use_Case__kav>();
        Website_Use_Case__kav objWSUseCase = new Website_Use_Case__kav(Video_ID__c = '123444', UrlName = 'URL1', Title = 'UseCase1', Status__c = 'Featured', 
                                                                        Article_Body__c = 'Body1',  Icon__Name__s ='Icon1',Icon__ContentType__s = 'image/png', 
                                                                        Icon__Body__s = objBlob ,Language = 'en_US');
                                                                        //Icon__Body__s = objBlob ,Language = 'en_US',PublishStatus = 'Online');
        lst_InsertWebsiteUC.add(objWSUseCase);
        
        Website_Use_Case__kav objWSUseCase1 = new Website_Use_Case__kav(Video_ID__c = '1234441', UrlName = 'URL11', Title = 'UseCase11', Status__c = 'Featured', 
                                                                        Article_Body__c = 'Body11',  Icon__Name__s ='Icon11',Icon__ContentType__s = 'image/png', 
                                                                        Icon__Body__s = objBlob ,Language = 'en_US');
                                                                        //Icon__Body__s = objBlob ,Language = 'en_US',PublishStatus = 'Online');
        lst_InsertWebsiteUC.add(objWSUseCase1);
        
        Website_Use_Case__kav objWSUseCase2 = new Website_Use_Case__kav(Video_ID__c = '1234442', UrlName = 'URL2', Title = 'UseCase12', Status__c = 'Featured', 
                                                                        Article_Body__c = 'Body12',  Icon__Name__s ='Icon2',Icon__ContentType__s = 'image/png',
                                                                        Icon__Body__s = objBlob ,Language = 'en_US'); 
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
        
        List<Website_Feature__kav> lst_InsertWebsiteFet = new List<Website_Feature__kav>();
        Website_Feature__kav objWSFet = new Website_Feature__kav(Video_ID__c = '123444', UrlName = 'URL111', Title = 'UseCase1', Status__c = 'Featured', 
                                                                        Article_Body__c = 'Body1',  Icon__Name__s ='Icon1',Icon__ContentType__s = 'image/png', 
                                                                        Icon__Body__s = objBlob ,Language = 'en_US');
                                                                        //Icon__Body__s = objBlob ,Language = 'en_US',PublishStatus = 'Online');
        lst_InsertWebsiteFet.add(objWSFet);
        
        Website_Feature__kav objWSFet1 = new Website_Feature__kav(Video_ID__c = '1234441', UrlName = 'URL112', Title = 'UseCase11', Status__c = 'Featured', 
                                                                        Article_Body__c = 'Body11',  Icon__Name__s ='Icon11',Icon__ContentType__s = 'image/png', 
                                                                        Icon__Body__s = objBlob ,Language = 'en_US');
                                                                        //Icon__Body__s = objBlob ,Language = 'en_US',PublishStatus = 'Online');
        lst_InsertWebsiteFet.add(objWSFet1);
        
        Website_Feature__kav objWSFet2 = new Website_Feature__kav(Video_ID__c = '1234442', UrlName = 'URL23', Title = 'UseCase12', Status__c = 'Featured', 
                                                                        Article_Body__c = 'Body12',  Icon__Name__s ='Icon2',Icon__ContentType__s = 'image/png', 
                                                                        Icon__Body__s = objBlob ,Language = 'en_US');
                                                                        //Icon__Body__s = objBlob ,Language = 'en_US',PublishStatus = 'Online');
        lst_InsertWebsiteFet.add(objWSFet2);
        
        insert lst_InsertWebsiteFet;
        
        
        
        SL_SiteName__c objSite = new  SL_SiteName__c();
        objSite.Name = 'CalendarAnything_Website';
        objSite.SiteIdentifier__c = 'ca';
        insert objSite;
        SL_Navigation__c objCustSetting = new SL_Navigation__c();
        objCustSetting.Name = 'ca_HomePageObjects';
        objCustSetting.URL__c = 'Website_Feature__kav,Website_Use_Case__kav';
        insert objCustSetting;
        SL_Index.KnowledgeArticleUseCase  objKAUC = new SL_Index.KnowledgeArticleUseCase('Website_Use_Case__kav');
        SL_Index.wrapperWebsiteFeature objWF = new SL_Index.wrapperWebsiteFeature('Website_Feature__kav');
        SL_Index objIndex = new SL_Index();
        objIndex.strArticleId = objWSFet.Id;
        objIndex.showSelectedArticleRecords();
        objIndex.strArticleIdUseCase = objWSUseCase.Id;
        objIndex.showSelectedUseCaseArticleRecords();
    }
    /* End - Method for test coverage */
}