/*
*Class: SL_HPD_SearchController
*Description: This is controller for SL_HPD_Search VF page.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public with sharing class SL_HPD_SearchController
{
    /* Start - global variables*/
    public Boolean isSites                              {   get;set;    }// This is used to check weather page load from the site or not.
    public String strFirstName                          {   get;set;    }// This is used to store user entered FirstName in UserInterface
    public String strLastName                           {   get;set;    }// This is used to store user entered LastName in UserInterface
    public String strNPI                                {   get;set;    }// This is used to store user entered NPI  in UserInterface
    public String strOrgName                            {   get;set;    }// This is used to store user entered OrganizationName in UserInterface
    public String strStreet                             {   get;set;    }// This is used to store user entered Street in UserInterface
    public String strCity                               {   get;set;    }// This is used to store user entered City in UserInterface
    public String strState                              {   get;set;    }// This is used to store user entered State in UserInterface
    public String strZipCode                            {   get;set;    }// This is used to store user entered Zipcodein UserInterface                  
    public SL_LIB9_Paginator objPaginatorOrganization   {   get;set;    }//This paginator object is used to paginate the Account records.
    public SL_LIB9_Paginator objPaginatorProviders      {   get;set;    }//This paginator object is used to paginate the contact records.
    public String sortExpressionForOrganization         {   get;set;    }//This is used to store fieldName of organization to implement sorting.
    public String sortDirectionForOrganization          {   get;set;    }//This is used to store SortDirection(ASC/DESC) for organization to implement sorting.
    public String sortExpressionForProvider             {   get;set;    }//This is used to store fieldName of Provider to implement sorting.
    public String sortDirectionForProvider              {   get;set;    }//This is used to store SortDirection(ASC/DESC) for Provider to implement sorting.
    public String strSpeciality                         {   get;set;    }
    public integer inttotalResultsForProviders          {   get;set;    }//This is used to store total number of Search results for providers.
    public integer intTotalResultsForOrganizations      {   get;set;    }//This is used to store total number of Search results for Organizations.
    public Decimal decWithinMilesOfLocation             {   get;set;    }//This is used to store the distance within which we have to find the providers.
    public SL_DistanceParameters__c objDistanceParameters{  get;set;    }//This custom setting object is used to fetch data from custom setting. 
    private Decimal decLatitude;                                            //This is used to store value of latitude of address
    private Decimal decLongitude;                                           //This is used to store value of longitude of address
    private string prevSortOrderFieldForOrganization;
    private string prevSortOrderFieldForProvider;
    private Set<Id> setOrganizationId;
    private Set<Id> setProviderId;
    private String strAccountQuery;
    private String strContactQuery;
    
    /* End - global variables*/ 
    /* Start - Constructor */
    public SL_HPD_SearchController()
    {
        intialize();//To intialize all the variables of the class
        
        if(Site.getName() != null)
            isSites = true;
    }
    /* End Contructor */
    
    /* 
       Method Name  : intialize
       Arguments    : NONE
       Access       : PRIVATE
       Return Type  : void
       Purpose      : This method is used to intialize all the variables of the class.
    */
    private void intialize()
    {
        // Initializing variables
        isSites = false;
        setOrganizationId = new Set<Id>();
        setProviderId = new Set<Id>();
        objDistanceParameters = new SL_DistanceParameters__c();
        if(getDistanceParameters()!=null && !getDistanceParameters().isEmpty())
        {
        	objDistanceParameters = getDistanceParameters()[0];
        }
        else
    	{
    		objDistanceParameters.minValue__c = 0;
    		objDistanceParameters.maxValue__c = 500;
    		objDistanceParameters.stepSize__c = 5;
    	}
        objPaginatorProviders =new SL_LIB9_Paginator(10,null,null,null);
        objPaginatorOrganization = new SL_LIB9_Paginator(10,null,null,null);
        sortExpressionForOrganization = 'Name';
        sortDirectionForOrganization = 'ASC NULLS FIRST';
        sortExpressionForProvider='Name';
        sortDirectionForProvider = 'ASC NULLS FIRST';
        prevSortOrderFieldForOrganization = 'Name';
        prevSortOrderFieldForProvider='Name';
        inttotalResultsForProviders =0;
        intTotalResultsForOrganizations=0;
        decWithinMilesOfLocation=0.0;
        
    }
    /* End */                                                                         
    
    
    /* 
       Method Name  : searchOrganizationsAndProviders
       Arguments    : NONE
       Access       : PUBLIC 
       Return Type  : PageReference 
       Purpose      : This method is called to search for Organization and providers when user clicks on Search button .
    */
    
    public PageReference searchOrganizationsAndProviders()
    {            
            /* Start - This code comes under MIHIN-52 ticket.*/   
            
            //Checking if street,city,state and zipcode is not null
            if((strStreet!='' || strCity!='' || strState!='' || strZipCode!='') && decWithinMilesOfLocation!=0.0)
            {
                List<String> lstAddress = new List<String>();
                lstAddress.add(strStreet + '##'+strCity+'##'+'##'+strState+'##'+strZipCode);
                List<List<String>> lstCoordinates = SL_Geocode_Batch.Geocode(lstAddress);
                
                //Iterating on List of Coordinates to get the value of Longitude and Latitude.
                for(List<String> lstCoordinate : lstCoordinates)
                {
                    decLongitude = Decimal.valueOf(lstCoordinate[0]);
                    decLatitude = Decimal.valueOf(lstCoordinate[1]);
                }
            }
            else
            {
            	decLongitude = null;
            	decLatitude = null;
            }
            /* End - This code comes under MIHIN-52 ticket. */
            
            SL_OrganizationSearch objOrgSearch = new SL_OrganizationSearch();
            SL_ProvidersSearch objProviderSearch = new SL_ProvidersSearch();
            // calling searchOrganization method in SL_OrganizationSearch class to query Organizations based on values entered by user in UserInterface
            List<Sobject> lstOrganizations = objOrgSearch.searchOrganization(strOrgName,strStreet,strCity,strState,strZipCode ,sortExpressionForOrganization,
                                                                            sortDirectionForOrganization,decLatitude,decLongitude,decWithinMilesOfLocation);
            
            //Clearing a set refill it with the updated values
            setOrganizationId.clear();
            
            //Iterating over list of organization records to collect ids into a set.
            for(Sobject objSobject : lstOrganizations)
            {
            	setOrganizationId.add(objSobject.Id);
            }
            
            // creating object for Paginator class with PageSize and list of Organizations as parameters used for Pagination of Organization Records
            objPaginatorOrganization = new SL_LIB9_Paginator(50,lstOrganizations,decLatitude,decLongitude);
            intTotalResultsForOrganizations = lstOrganizations.size();
            lstOrganizations = new List<Sobject>();
            objOrgSearch = null;

            // calling searchProvider method in SL_ProvidersSearch class to query Providers based on values entered by user in UserInterface
            List<Sobject> lstProviders = objProviderSearch.searchProvider(strLastName ,strFirstName ,strNPI,strOrgName,
                                                                        strStreet,strCity,strState,strZipCode,strSpeciality ,sortExpressionForProvider,
                                                                        sortDirectionForProvider,decLatitude,decLongitude,decWithinMilesOfLocation);
            
            //Clearing a set to refill it with updated values
            setProviderId.clear();
            
            //Iterating over list of providers to get the ids
            for(Sobject objSobject : lstProviders)
            {
            	setProviderId.add(objSobject.Id);
            }
            
            // creating object for Paginator class with PageSize and list of Providers as parameters used for Pagination of Provider Records 
            objPaginatorProviders =new SL_LIB9_Paginator(50,lstProviders,decLatitude,decLongitude);
            inttotalResultsForProviders = lstProviders.size();
            objProviderSearch = null;
            lstProviders = new List<Sobject>();
            return null;
    }
    
    
    public Pagereference redirectToLogin()
    {
        
        if(Userinfo.getUserType() == 'Guest')
           return new PageReference('/SiteLogin');
        else
           return null;

    }
    
    
    /* Start - Method
       Method Name: firstOrganizationPage
       Arguments: NONE
       Access: public 
       Return Type: void
       Purpose: Getting Organization records for the first page.
    */
    
    public void firstOrganizationPage()
    {
        SL_OrganizationSearch objOrgSearch = new SL_OrganizationSearch();
        //Calling function to fetch the records of Organization
        objPaginatorOrganization.lstSobject = getOrganiztionDetails(true);
        // calling gotoFirstPage method of Paginator class to go to first Page of Search Results
        objOrgSearch = null;
        objPaginatorOrganization.gotoFirstPage();
        
    }
    
    
    /* Start - Method
       Method Name: lastOrganizationPage
       Arguments: NONE
       Access: public 
       Return Type: void
       Purpose: Getting Organization records for the last page.
    */
    public void lastOrganizationPage()
    {
        SL_OrganizationSearch objOrgSearch = new SL_OrganizationSearch();
        //Calling function to fetch the records of Organization
        objPaginatorOrganization.lstSobject = getOrganiztionDetails(true);
        objOrgSearch = null;
        // calling gotoLastPage method of Paginator class to go to Last Page of Search Results
        objPaginatorOrganization.gotoLastPage();
        
    }
    
    /* Start - Method
       Method Name: prevOrganizationPage
       Arguments: NONE
       Access: public 
       Return Type: void
       Purpose: Getting Organization records for the Previous page.
    */
    public void prevOrganizationPage()
    {
        SL_OrganizationSearch objOrgSearch = new SL_OrganizationSearch();
        //Calling function to fetch the records of Organization
        objPaginatorOrganization.lstSobject = getOrganiztionDetails(true);
        objOrgSearch = null;
        // calling gotoPrevPage method of Paginator class to go to previous Page of Search Results
        objPaginatorOrganization.gotoPrevPage();
        
    }
    
    /* Start - Method
       Method Name: nextOrganizationPage
       Arguments: NONE
       Access: public 
       Return Type: void
       Purpose: Getting Organization records for the next page.
    */
    
    public void nextOrganizationPage()
    {
        SL_OrganizationSearch objOrgSearch = new SL_OrganizationSearch();
        //Calling function to fetch the records of Organization
        objPaginatorOrganization.lstSobject = getOrganiztionDetails(true);
        objOrgSearch = null;
        // calling gotoNextPage method of Paginator class to go to Next Page of Search Results
        objPaginatorOrganization.gotoNextPage();
        
    }
    
    /* Start - Method
       Method Name: firstProviderPage
       Arguments: NONE
       Access: public 
       Return Type: void
       Purpose: Getting Provider records for the first page.
    */
    public void firstProviderPage()
    {
        SL_ProvidersSearch objProviderSearch = new SL_ProvidersSearch();
        //Calling function to fetch the records of Provider
        objPaginatorProviders.lstSobject = getProviderDetails(true);
        objProviderSearch = null;
        // calling gotoFirstPage method of Paginator class to go to First Page of Search Results
        objPaginatorProviders.gotoFirstPage();
    }
    
    
    /* Start - Method
       Method Name: lastProviderPage
       Arguments: NONE
       Access: public 
       Return Type: void
       Purpose: Getting Provider records for the Last page.
    */
    
    public void lastProviderPage()
    {
        SL_ProvidersSearch objProviderSearch = new SL_ProvidersSearch();
        //Calling function to fetch the records of Provider
        objPaginatorProviders.lstSobject = getProviderDetails(true);
        objProviderSearch = null;
        // calling gotoLastPage method of Paginator class to go to Last Page of Search Results
        objPaginatorProviders.gotoLastPage();
    }
    
    /* Start - Method
       Method Name: prevProviderPage
       Arguments: NONE
       Access: public 
       Return Type: void
       Purpose: Getting Provider records for the previous page.
    */
    
    public void prevProviderPage()
    {
        SL_ProvidersSearch objProviderSearch = new SL_ProvidersSearch();
        //Calling function to fetch the records of Provider
        objPaginatorProviders.lstSobject = getProviderDetails(true);
        objProviderSearch = null;
        // calling gotoPrevPage method of Paginator class to go to Previous Page of Search Results
        objPaginatorProviders.gotoPrevPage();
    }
    
    /* Start - Method
       Method Name: nextProviderPage
       Arguments: NONE
       Access: public 
       Return Type: void
       Purpose: Getting Provider records for the next page.
    */
    
    public void nextProviderPage()
    {
        SL_ProvidersSearch objProviderSearch = new SL_ProvidersSearch();
        //Calling function to fetch the records of Provider
        objPaginatorProviders.lstSobject = getProviderDetails(true);
        objProviderSearch = null;
        // calling gotoNextPage method of Paginator class to go to Next Page of Search Results
        objPaginatorProviders.gotoNextPage();
    }
    
    /* Start - Method
       Method Name: getSortRecordProvide
       Arguments: NONE
       Access: public 
       Return Type: void
       Purpose: This method is used for Sortable Columns functionality for Provider Records in search results.
    */
    
    public void getSortRecordProvide()
    { 
        SL_ProvidersSearch objProviderSearch = new SL_ProvidersSearch();
        // assigning fieldName to prevSortOrderFieldForProvider.    
        prevSortOrderFieldForProvider = sortExpressionForProvider;
        objPaginatorProviders.lstSobject = getProviderDetails(false);
        objProviderSearch = null;
        objPaginatorProviders.getPageRecords();
    }
    
    /* Start - Method
       Method Name: getSortRecordOrganizer
       Arguments: NONE
       Access: public 
       Return Type: void
       Purpose: This method is used for Sortable Columns functionality for Organization Records in search results.
    */
    public void getSortRecordOrganizer()
    {    
        SL_OrganizationSearch objOrgSearch = new SL_OrganizationSearch();
        
        // assigning fieldName to prevSortOrderFieldForOrganization.       
        prevSortOrderFieldForOrganization = sortExpressionForOrganization;  
        objPaginatorOrganization.lstSobject = getOrganiztionDetails(false);
        objOrgSearch = null;
        objPaginatorOrganization.getPageRecords();
    }
    
    
    /* Start - Method
       Method Name: clearAllInputs
       Arguments: NONE
       Access: public 
       Return Type: void
       Purpose: This method is used for clearing out all the inputs given by user in search screen.
    */
    public void clearAllInputs()
    {
        //Clear all the inputs given by user for search 
        strFirstName = strLastName = strNPI = strOrgName = strStreet = strCity = strState = strZipCode = strSpeciality = '';
        
        //Clearing all the search results
        objPaginatorProviders = new SL_LIB9_Paginator(10,null,null,null);
        objPaginatorOrganization = new SL_LIB9_Paginator(10,null,null,null);
        inttotalResultsForProviders =0;
        intTotalResultsForOrganizations=0;
    }
    
    /*
        @MethodName : getDistanceParameters
        @param      : NA
        @Description: This is used to fetch data from custom setting.
    */
    private List<SL_DistanceParameters__c> getDistanceParameters()
    {
        List<SL_DistanceParameters__c> lstDistanceParameters = [SELECT minValue__c, maxValue__c, stepSize__c FROM SL_DistanceParameters__c WHERE Name=:'SL_Distance_Parameters'];
        if(lstDistanceParameters!=null)
        	return lstDistanceParameters;
        else
        	return null;
    }
    
    /*
        @MethodName : getOrganiztionDetails
        @param      : Value of Pagination to check whether this function is called for pagination or for fetching records  
        @Description: This is used to fetch the sobject details whose ids falls under setOrganizationDetails
    */
    private List<Sobject> getOrganiztionDetails(Boolean isPagination)
    {
    	String strQuery = '';//To contain the SOQL
        String strLocation = '';//To contain the expression for calculating distance and sorting the records on the basis of distance
        
        //Checking if latitude and longitude value of the location from which the distance needs to be calculated is null or not
        if(decLatitude!=null && decLongitude!=null && decWithinMilesOfLocation!=null && String.valueOf(decLatitude)!='' && String.valueOf(decLongitude)!='' && String.valueOf(decWithinMilesOfLocation)!='')
           	strLocation =  ' DISTANCE(Location__c, GEOLOCATION('+decLatitude+','+decLongitude+'),'+'\''+'mi'+'\''+')';
           		
        strQuery += 'SELECT Id, Name, ParentId, Phone, Language__c, CreatedDate, LastModifiedDate, RecordType.Name, Fax, Organizational_NPI__c,Location__Longitude__s,Location__Latitude__s, ';
        strQuery += 'ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Digital_Certificate__c, ';
        strQuery += 'BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity, Status__c, ';
        strQuery += '(SELECT Specialty__c,  Name, As_of_Date__c, Specialty__r.Description__c, Specialty__r.Name, ';
        strQuery += 'Specialty__r.Classification__c, Specialty__r.Type__c, Specialty__r.Specialization__c, Specialty__r.Specialty_Code__c From Organization_Specialties__r), ';
        strQuery += '(Select Name, Organization__c, Comments__c, Current_Status__c, Expiration_Date__c, Grant_Date__c, Credential_Number__c,  ';
        strQuery += 'Limitations__c, Suspended_Date__c, PHI_Suspended__c,Organization__r.Name, Type__c From Organization_Credentials__r), ';
        strQuery += '(Select Id, Name, Provider__c, Provider__r.Name, Organization__c, Type__c, Start_Date__c, End_Date__c, Phone__c, Email__c From Affiliations__r), ';
            
        strQuery += '(SELECT Electronic_Service__r.Name, Electronic_Service__r.Type__c, Electronic_Service__r.Protocol__c, Electronic_Service__r.Address__c, Electronic_Service__r.Certificate__c,Electronic_Service__c From Organization_Services__r), ';
        
        strQuery += '(Select Id, Name, Member_Organization__c, Member_Organization__r.Name, Affiliated_Organization__c, Affiliated_Organization__r.Name, Affiliation_Type__c, Start_Date__c, End_Date__c From Member_Affiliations__r), ';
        strQuery += '(Select Id, Name From Organization_Names__r), (Select Id, Name From Contacts) ';
        
        //Checking if hpd search page is having records or not
        if(setOrganizationId!=null && !setOrganizationId.isEmpty())
        {
        	strQuery+=' FROM Account WHERE Id IN:setOrganizationId';
        }
        
        if(isPagination==false)
        {
	        if(prevSortOrderFieldForOrganization == sortExpressionForOrganization)
	        {
	            if(sortDirectionForOrganization == 'ASC NULLS FIRST')
	                sortDirectionForOrganization = 'DESC NULLS LAST' ;// Setting the null values at last
	            else
	                sortDirectionForOrganization = 'ASC NULLS FIRST' ;// Setting the null values at first
	        }
	        else
	            sortDirectionForOrganization = 'ASC NULLS FIRST';
        }
         
        if(sortExpressionForOrganization != null && sortExpressionForOrganization != '' && sortExpressionForOrganization == 'Distance' && sortDirectionForOrganization != null && sortDirectionForOrganization != '')  
            strQuery += ' ORDER By '+ strLocation +' ' + sortDirectionForOrganization + ' LIMIT 201';
        else if(sortExpressionForOrganization != null && sortExpressionForOrganization != '' && sortExpressionForOrganization != 'Distance' && sortDirectionForOrganization != null && sortDirectionForOrganization != '')  
            strQuery += ' ORDER By ' + sortExpressionForOrganization + ' ' + sortDirectionForOrganization + ' LIMIT 201';
            
        return Database.query(strQuery);
    }
    
    /*
        @MethodName : getProviderDetails
        @param      : Value of Pagination to check whether this function is called for pagination or for fetching records
        @Description: This is used to fetch the sobject details whose ids falls under setProviderId
    */
    
    private List<Sobject> getProviderDetails(Boolean isPagination)
    {
    	String strQuery = '';//To contain the SOQL
        String strLocation = '';//To contain the expression for calculating distance and sorting the records on the basis of distance
        
        strQuery += 'SELECT Id, FirstName, LastName, Status__c, Type__c, Gender__c, Languages__c, AccountId, Phone, Fax, MobilePhone, Pager__c, Email, Direct_Email__c, ';
        strQuery += 'Title, Middle_Name__c, Full_Name__c, Name_Suffix__c, Description, Birthdate, Location__Longitude__s, Location__Latitude__s,';
        strQuery += 'NPI__c, Account.Name, Org_Practice_Zip__c, Org_Practice_State__c, Org_Practice_City__c, Org_Practice_Address_line_1__c, MailingStreet, MailingState, ';
        strQuery += 'MailingPostalCode, MailingCountry, MailingCity, Specialities__c, Digital_Certificate__c, CreatedDate, LastModifiedDate, Medicaid_Provider_Number__c, ';
        strQuery += 'Name, OtherCountry, OtherStreet, OtherCity, OtherState, OtherPostalCode, Medicare_Provider_Number__c,';
        
        strQuery += '(SELECT Id, Provider__c, Provider__r.Name, Organization__c, Type__c, Start_Date__c, End_Date__c, Phone__c, Email__c,  Provider__r.AccountId FROM Affiliations__r), ';
        strQuery += '(SELECT Id, Name, Credential_Number__c,  RecordType.Name, Type__c, Current_Status__c, Grant_Date__c, Granting_Organization__c, Granting_Organization__r.Name, ';
        strQuery += 'Expiration_Date__c, PHI_Suspended__c, Suspended_Date__c, Limitations__c, Comments__c FROM Provider_Credentials__r), ';
        
        strQuery += '(SELECT Specialty__c, Primary_Indicator__c, Name, As_of_Date__c, Comments__c, Specialty__r.Description__c, Specialty__r.Name, ';
        strQuery += 'Specialty__r.Classification__c, Specialty__r.Type__c, Specialty__r.Specialization__c, Specialty__r.Specialty_Code__c FROM provider_specialties__r) ';
        
        //Checking if latitude and longitude value of the location from which the distance needs to be calculated is null or not    
        if(decLatitude!=null && decLongitude!=null && decWithinMilesOfLocation!=null && String.valueOf(decLatitude)!='' && String.valueOf(decLongitude)!='' && String.valueOf(decWithinMilesOfLocation)!='')
           	strLocation =  ' DISTANCE(Location__c, GEOLOCATION('+decLatitude+','+decLongitude+'),'+'\''+'mi'+'\''+')';
        
        //Checking if hpd search page is having records or not
        if(setProviderId!=null && !setProviderId.isEmpty())
        {
        	strQuery+=' FROM Contact WHERE Id IN:setProviderId';
        }
        
        if(isPagination==false)
        {
	        // checking whether the field is equal to prevSortOrderFieldForProvider and then reversing the sortDirection.
	        if(prevSortOrderFieldForProvider == sortExpressionForProvider)
	        {
	            if(sortDirectionForProvider == 'ASC NULLS FIRST')
	                sortDirectionForProvider = 'DESC NULLS LAST' ;// Setting the null values at last
	            else
	                sortDirectionForProvider = 'ASC NULLS FIRST' ;// Setting the null values at first
	        }
	        else
	            sortDirectionForProvider = 'ASC NULLS FIRST';
        }
        
        if(sortExpressionForProvider != null && sortExpressionForProvider != '' && sortExpressionForProvider == 'Distance' && sortDirectionForProvider != null && sortDirectionForProvider != '')  
            strQuery += ' ORDER By '+ strLocation +' ' + sortDirectionForProvider + ' LIMIT 201';
        else if(sortExpressionForProvider != null && sortExpressionForProvider != '' && sortExpressionForProvider != 'Distance' && sortDirectionForProvider != null && sortDirectionForProvider != '')  
            strQuery += ' ORDER By ' + sortExpressionForProvider + ' ' + sortDirectionForProvider + ' LIMIT 201';
    
        return Database.query(strQuery);
    }
    
}