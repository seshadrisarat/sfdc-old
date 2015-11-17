/*
    ClassName : TrackingCheckboxController
    
    Requirement No : 770
    
    Description : Display the Custom Tracking Link records respecting the Hierarchy on inline page, on click of CTLink toggle the value and change of symbol,
                  change text and color etc..
    Maintence History :
    
    Created Date : 24/April/2014 

*/
public with sharing class TrackingCheckboxController 
{
    /* Global variable declaration*/

    /* List holds the Custom Tracking Link records to be dispalyed on left side of Left Page*/
    public List<CustomTrackingLinks__c> lstCTLayoutLeftOfLeftPage { get;set; }
     /* List holds the Custom Tracking Link records to be dispalyed on right side of Left Page*/
    public List<CustomTrackingLinks__c> lstCTLayoutRightOfLeftPage { get;set; }
     /* List holds the Custom Tracking Link records to be dispalyed on left side of Right Page */
    public List<CustomTrackingLinks__c> lstCTLayoutLeftOfRightPage { get;set; }
    /* List holds the Custom Tracking Link records to be dispalyed on left side of Right Page */
    public List<CustomTrackingLinks__c> lstCTLayoutRightOfRightPage { get;set; }
    
    /* Map holds the CTlink name and respective boolean value */
    public Map<String, Boolean> mapCustomTrackingLinkToBlnValue { get;set; }
    /* Map holds the CTlink name and checked symbol*/
    public Map<String, String> mapCTlinkRecordToSymbolChk { get;set; }
    /* Map holds the CTlink name and static  resource found or not(Boolean) */
    public Map<String, Boolean> mapCTLinkToIsStaticResChk { get;set; }
    /* Map holds the CTlink name and Unchecked symbol*/
    public Map<String, String> mapCTlinkRecordToSymbolUnchk { get;set; }
    /* Map holds the CTlink name and static  resource found or not(Boolean)*/
    public Map<String, Boolean> mapCTLinkToIsStaticResUnchk { get;set; }
    
    /* CTLink name passed from page to controller onClick of CTLink*/
    public String strSelectdCTLink { get;set; }
    /* CTLink name passed from page to controller onClick of CTLink*/
    public String strErrorMessage { get;set; }
    
    /* Holds the actual value of a field*/
    public Boolean isTracked { get;set;}
    
    private CustomTrackingPages__c objCustomTrackingPages;
    private Account objAccount ;
    private Id accId;
    private Set<String> setFieldAPIs ;
    
    private static final String LEFTLAYOUT = 'LEFT';
    private static final String RIGHTLAYOUT = 'RIGHT';
    
    private static final String PAGE_CUSTOM_SETTING_ERROR_MESSAGE = '<b>Custom Tracking Pages</b> custom setting is not defined for current user.';
    
    
    //////////////////////////////////////////////////////////////////////
    ///
    /// Constructor 
    ///
    //////////////////////////////////////////////////////////////////////
    
    public TrackingCheckboxController(Apexpages.StandardController controller)
    {
        accId = controller.getId();
        initGloableVars();
        /* Get custom setting defined for logged in user*/
        objCustomTrackingPages =  GetCusttomSettingForLoggedInUser.getCustomSetting();
        
        if(objCustomTrackingPages == null) {
            
            strErrorMessage = PAGE_CUSTOM_SETTING_ERROR_MESSAGE;
        }
    }
    
    //////////////////////////////////////////////////////////////////////
    ///
    /// Method initializes the blobal variables
    ///
    //////////////////////////////////////////////////////////////////////
    
    private void initGloableVars()
    {
        mapCustomTrackingLinkToBlnValue = new Map<String, Boolean>();
        mapCTLinkToIsStaticResChk = new Map<String, Boolean>();
        mapCTlinkRecordToSymbolUnchk = new Map<String, String>();
        mapCTLinkToIsStaticResUnchk = new Map<String, Boolean>();
        mapCTlinkRecordToSymbolChk = new Map<String, String>();
        
        lstCTLayoutLeftOfLeftPage =  new List<CustomTrackingLinks__c>();
        lstCTLayoutRightOfLeftPage = new List<CustomTrackingLinks__c>();
        lstCTLayoutLeftOfRightPage = new List<CustomTrackingLinks__c>();
        lstCTLayoutRightOfRightPage = new List<CustomTrackingLinks__c>();
        
        strSelectdCTLink = strErrorMessage = '';  
        setFieldAPIs = new Set<String>();
        
        /* Quering all the boolean fields of Accountto avoid Argument not found excpetion*/
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Account.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        
        String strQuery = 'SELECT ';
        for(Schema.SObjectField s : fldObjMapValues)
        {
            if(String.valueOf(s.getDescribe().getType()) == 'BOOLEAN')
            {
                 String theName = s.getDescribe().getName();
                 strQuery += theName + ',';
                 setFieldAPIs.add(theName);
            }
        }
        strQuery = strQuery.subString(0, strQuery.length() - 1);
        strQuery += ' FROM Account where Id =: accId Limit 1' ;
        objAccount = Database.query(strQuery);//AJL_Tracking__c
    }
   
    //////////////////////////////////////////////////////////////////////
    ///
    /// Method called from action attribute of page TrackingCheckbioxLeft 
    /// to process only the layoutLeft of CustomTracking Page
    ///
    //////////////////////////////////////////////////////////////////////
    
    public void leftPageAction() 
    {
        /* Retrive all the custom tracking link records falls under left page*/
        if(objCustomTrackingPages != null && objCustomTrackingPages.Custom_Tracking_Layout__c != null)
        {
            CustomTrackingLayout__c objCustomTrackingPageLeft = CustomTrackingLayout__c.getInstance(String.valueOf(objCustomTrackingPages.Custom_Tracking_Layout__c));
            
            if(objCustomTrackingPageLeft != null)
                getCustomTrackingLayouts(objCustomTrackingPageLeft, LEFTLAYOUT);
        }
        
    }
    
    //////////////////////////////////////////////////////////////////////
    ///
    /// Method called from action attribute of page TrackingCheckbioxRight Page
    /// to process only the layoutRight of CustomTracking Page
    ///
    //////////////////////////////////////////////////////////////////////
    
    public void rightPageAction() 
    {
        /* Retrive all the custom tracking link records falls under right page*/
        if(objCustomTrackingPages != null && objCustomTrackingPages.Custom_Tracking_Layout__c != null)
        {
            CustomTrackingLayout__c objCustomTrackingPageRight = CustomTrackingLayout__c.getInstance(String.valueOf(objCustomTrackingPages.Custom_Tracking_Layout__c));
            
            if(objCustomTrackingPageRight != null)
                getCustomTrackingLayouts(objCustomTrackingPageRight, RIGHTLAYOUT);
        }
    }
    
    //////////////////////////////////////////////////////////////////////
    ///
    /// Processes the Custom Tracking Layouts and retrives all the Custom Tracking Link records
    ///
    //////////////////////////////////////////////////////////////////////
    
    public void getCustomTrackingLayouts(CustomTrackingLayout__c objCustomTrackingLayouts, String strPageSide)
    {
        List<CustomTrackingLinks__c> lstCTLinks = new List<CustomTrackingLinks__c>();
        /*Handling the case when Layout contains morethan one CT Link record seperated by ; */
        
        if(strPageSide == LEFTLAYOUT && objCustomTrackingLayouts.Layout_Left__c != null) {
            
            if(objCustomTrackingLayouts.Layout_Left__c.contains('; ')) {
                
                List<CustomTrackingLinks__c> lstMultipleCTLinks = new  List<CustomTrackingLinks__c>();
                
                for(String strCustTrackLink : objCustomTrackingLayouts.Layout_Left__c.split('; ')) {
                     
                    lstMultipleCTLinks = getCustomTrackingLinks(strCustTrackLink);
                    
                    if(lstMultipleCTLinks != null)
                        lstCTLinks.addAll(lstMultipleCTLinks);
                }
            }
            else {
                
                List<CustomTrackingLinks__c> lstSingleCTLinks = new  List<CustomTrackingLinks__c>();
                lstSingleCTLinks = getCustomTrackingLinks(objCustomTrackingLayouts.Layout_Left__c);
                if(lstSingleCTLinks != null)
                    lstCTLinks.addAll(lstSingleCTLinks);
            }
        }
        else if(strPageSide == RIGHTLAYOUT && objCustomTrackingLayouts.Layout_Right__c != null) {
            
            if(objCustomTrackingLayouts.Layout_Right__c.contains('; ')) {
                
                List<CustomTrackingLinks__c> lstMultipleCTLinks = new  List<CustomTrackingLinks__c>();
                
                for(String strCustTrackLink : objCustomTrackingLayouts.Layout_Right__c.split('; ')) {
                     
                    lstMultipleCTLinks = getCustomTrackingLinks(strCustTrackLink);
                    
                    if(lstMultipleCTLinks != null)
                        lstCTLinks.addAll(lstMultipleCTLinks);
                }
            }
            else {
                
                List<CustomTrackingLinks__c> lstSingleCTLinks = new  List<CustomTrackingLinks__c>();
                lstSingleCTLinks = getCustomTrackingLinks(objCustomTrackingLayouts.Layout_Right__c);
                if(lstSingleCTLinks != null)
                    lstCTLinks.addAll(lstSingleCTLinks);
            }
        }
        
        /* Assigning the CTLinks records to respective pages(the CTLinks under Left layout of CTLayout record processed)*/
        if(strPageSide == LEFTLAYOUT) {
            
            Boolean flag = true;
            
            for(CustomTrackingLinks__c objCTLink : lstCTLinks) {
                
                if(flag) {
                    
                    lstCTLayoutLeftOfLeftPage.add(objCTLink);
                }
                else {
                    
                    lstCTLayoutRightOfLeftPage.add(objCTLink);
                }
                
                flag = !flag;
            }
        }
        else if(strPageSide == RIGHTLAYOUT) {
            
            Boolean flag = true;
            
            for(CustomTrackingLinks__c objCTLink : lstCTLinks) {
                
                if(flag) {
                    
                    lstCTLayoutLeftOfRightPage.add(objCTLink);
                }
                else {
                    
                    lstCTLayoutRightOfRightPage.add(objCTLink);
                }
                
                flag = !flag;
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////////
    ///
    /// Called from getCustomTrackingLayouts to retrive respective CTLink records
    ///
    //////////////////////////////////////////////////////////////////////
    
    public List<CustomTrackingLinks__c> getCustomTrackingLinks(String strCusromTrackingLayout)
    {
        CustomTrackingLinks__c  objCustomTrackingLinks = new CustomTrackingLinks__c();
        List<CustomTrackingLinks__c> lstCustomTracking = new List<CustomTrackingLinks__c>();
        objCustomTrackingLinks = CustomTrackingLinks__c.getInstance(strCusromTrackingLayout);
        
        if(objCustomTrackingLinks == null)
            return null;
        
        /* Checks if the CTLink is present and the the field API specified is correct and the Target object is Account if so the process*/
        if(strCusromTrackingLayout != null && setFieldAPIs.contains(objCustomTrackingLinks.Target_Field__c) && String.valueOf(objCustomTrackingLinks.Target_Object__c) == 'Account')
        {
            /* To handle when Custom Tracking Link record's reversed field is checked*/
            if(objCustomTrackingLinks.Is_Reversed__c)
            {
                isTracked = Boolean.valueOf(objAccount.get(objCustomTrackingLinks.Target_Field__c));
                mapCustomTrackingLinkToBlnValue.put(strCusromTrackingLayout, !isTracked );
                objAccount.put(objCustomTrackingLinks.Target_Field__c, !isTracked );
            }
            /* To handle when Custom Tracking Link record's reversed field is Unchecked*/
            else
            {
                isTracked = Boolean.valueOf(objAccount.get(objCustomTrackingLinks.Target_Field__c));
                mapCustomTrackingLinkToBlnValue.put(strCusromTrackingLayout, isTracked);
            }
            
            /*To check Checked symbol field of custom setting contains static resource or Unicode or its empty*/
            if(objCustomTrackingLinks.Checked_Symbol__c != null)
            {
                GetResourceURLOrUnicodeChk(objCustomTrackingLinks.Checked_Symbol__c, strCusromTrackingLayout, objCustomTrackingLinks );
            }       
            else 
            {
                mapCTLinkToIsStaticResChk.put(strCusromTrackingLayout, false);
                mapCTlinkRecordToSymbolChk.put(strCusromTrackingLayout, '');
            }
            
            /*To check UnChecked symbol field of custom setting contains static resource or Unicode or its empty*/
            if(objCustomTrackingLinks.Unchecked_Symbol__c != null)
            {
                GetResourceURLOrUnicodeUnchk(objCustomTrackingLinks.Unchecked_Symbol__c, strCusromTrackingLayout, objCustomTrackingLinks );
            }
            else 
            {
                mapCTLinkToIsStaticResUnchk.put(strCusromTrackingLayout, false);
                mapCTlinkRecordToSymbolUnchk.put(strCusromTrackingLayout, '');   
            }
            
            lstCustomTracking.add(objCustomTrackingLinks);
            return lstCustomTracking;
        } 
        /* Throws an error oevr page if Field API is wrong */
        else if(!setFieldAPIs.contains(objCustomTrackingLinks.Target_Field__c))
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Field API name is Inapproriate for Custom Tracking Link record : '+ strCusromTrackingLayout);
            ApexPages.addmessage(myMsg);
            return null;
        }
        else
            return null;
    }
   
    /////////////////////////////////////////////////////////////////////
    ///
    /// Called on click of CTLink which toggeles(Switches) the field value and
    /// respective CTLink attributes gets associated with it
    ///
    //////////////////////////////////////////////////////////////////////
   
    public void processCustomSettingrecords()
    {
        try
        {
            Map<String, Schema.SObjectType> mapGlobalDescribe = Schema.getGlobalDescribe();
            CustomTrackingLinks__c objCTLink = CustomTrackingLinks__c.getInstance(strSelectdCTLink);
            SObject sobj = mapGlobalDescribe.get(objCTLink.Target_Object__c).newSobject();
            sobj.put('Id',accId);
            
            String strQuery ='Select ' + objCTLink.Target_Field__c + ' FROM Account where Id =: accId Limit 1' ;
            Account objAccReverese = Database.Query(strQuery);
            
            /*Logic to switch between the Boolean values on click*/ 
            if(Boolean.valueOf(objAccount.get(objCTLink.Target_Field__c)))
            {
                sobj.put(objCTLink.Target_Field__c, false);
                objAccReverese.put(objCTLink.Target_Field__c, false);
                objAccount.put(objCTLink.Target_Field__c, false);
            }
            else
            {
                sobj.put(objCTLink.Target_Field__c, true);
                objAccReverese.put(objCTLink.Target_Field__c, true);
                objAccount.put(objCTLink.Target_Field__c, true);
            }
            update sObj;
            
            if(Boolean.valueOf(objCTLink.Is_Reversed__c))
            {
                Boolean isValue = Boolean.valueOf(objAccReverese.get(objCTLink.Target_Field__c));
                objAccReverese.put(objCTLink.Target_Field__c, !isValue);
            }
            update objAccReverese ;
            
            isTracked = Boolean.valueOf(sobj.get(objCTLink.Target_Field__c)); 
            mapCustomTrackingLinkToBlnValue.put(strSelectdCTLink, isTracked ); 
        }
        Catch(Exception e)  
        {  
            ApexPages.addMessages(e) ;   
        }  
    }
    
    /////////////////////////////////////////////////////////////////////
    ///
    /// Associates the CTLink with Static resource or Unicode for Checked Symbol
    ///
    //////////////////////////////////////////////////////////////////////
    
    public  void GetResourceURLOrUnicodeChk(String resourceName, String CSLinkRecordName, CustomTrackingLinks__c objCTLink) 
    {
        List<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];
        
        if (!resourceList.isEmpty()) 
        {
           String namespace = resourceList[0].NamespacePrefix;
           String strStaticResourcePath = '/resource/' 
                                        + resourceList[0].SystemModStamp.getTime() + '/' 
                                          + (namespace != null && namespace != '' ? namespace + '__' : '') 
                                          + resourceName; 
           mapCTLinkToIsStaticResChk.put(CSLinkRecordName, true);
           mapCTlinkRecordToSymbolChk.put(CSLinkRecordName, strStaticResourcePath);
        } 
        else 
        {
            mapCTLinkToIsStaticResChk.put(CSLinkRecordName, false);
            mapCTlinkRecordToSymbolChk.put(CSLinkRecordName, String.valueOf(objCTLink.Checked_Symbol__c));
        }
    }
    
    /////////////////////////////////////////////////////////////////////
    ///
    /// Associates the CTLink with Static resource or Unicode for Unchecked Symbol
    ///
    //////////////////////////////////////////////////////////////////////
    
    public  void GetResourceURLOrUnicodeUnchk(String resourceName, String CSLinkRecordName, CustomTrackingLinks__c objCTLink) 
    {
        List<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName limit 1];
        
        if (!resourceList.isEmpty()) 
        {
           String namespace = resourceList[0].NamespacePrefix;
           String strStaticResourcePath = '/resource/' 
                                        + resourceList[0].SystemModStamp.getTime() + '/' 
                                          + (namespace != null && namespace != '' ? namespace + '__' : '') 
                                          + resourceName; 
           mapCTLinkToIsStaticResUnchk.put(CSLinkRecordName, true);
           mapCTlinkRecordToSymbolUnchk.put(CSLinkRecordName, strStaticResourcePath);
        } 
        else 
        {
            mapCTLinkToIsStaticResUnchk.put(CSLinkRecordName, false);
            mapCTlinkRecordToSymbolUnchk.put(CSLinkRecordName, String.valueOf(objCTLink.Unchecked_Symbol__c));
        } 
    }
}