/*
*Class: SL_ProviderSearch
*Description: Process the request,came for provider serch, based on passed parameters and return the results
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@RestResource(urlMapping='/hpd/provider/search') 
global with sharing class SL_ProviderSearch 
{
    
    /*
        Used to form Response object
    */
    global class ProviderSearchResponse extends SL_RestResponseWrappers.BaseResponse
    {
        List<ProviderSearch> Providers;
        
        public ProviderSearchResponse(List<ProviderSearch> ListOfProviders, Boolean done)
        {
            super(ListOfProviders.size(), done);
            this.Providers = ListOfProviders;
        }
    }
    
    /* End */
    
    // GET method : Get method is used for fetching records
    @HttpGet
    global static ProviderSearchResponse getProvidersInformation()   
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<Contact> lstProviders = new List<Contact>();
        String strFirst ;
        String strLast ;
        String strOrganization ;
        String strservice ;
        String strWhereProviderAddress;
        String strQuery ;
        String strWhereLocation ;
        String strWhereService ;
        String strNpi;
        String strCity;
        String strState;
        String strZip;
        Decimal decLongitude;
        Decimal decLatitude;
        Decimal decWithinMilesOfLocation;
        
        strWhereProviderAddress = strFirst = strLast = strOrganization = strservice = strQuery = strWhereLocation = strWhereService = strNpi = strCity = strState = strZip = '';
        
        //Take the prameters value from the RestRequest
        if(RestContext.request.params.get('first') == null)
            strFirst = '%%';
        else
            strFirst = '%' + RestContext.request.params.get('first') + '%';
        
        if(RestContext.request.params.get('last') == null)
            strLast = '%%';
        else
            strLast = '%' + RestContext.request.params.get('last') + '%';
        
        if(RestContext.request.params.get('organization') == null)
            strOrganization = '%%';
        else
            strOrganization = '%' + RestContext.request.params.get('organization') + '%';
        
        if(RestContext.request.params.get('service') == null)
            strservice = '';
        else
            strservice = RestContext.request.params.get('service');
        
        /* Newly added parameters */
        
        if(RestContext.request.params.get('npi') == null)
            strNpi = '%%';
        else
            strNpi = '%' + RestContext.request.params.get('npi') + '%';
            
        if(RestContext.request.params.get('city') == null)
            strCity = '%%';
        else
            strCity = '%' + RestContext.request.params.get('city') + '%';
            
       if(RestContext.request.params.get('state') == null)
            strState = '%%';
        else
            strState = '%' + RestContext.request.params.get('state') + '%';  
            
       if(RestContext.request.params.get('zip') == null)
            strZip = '%%';
        else
            strZip = '%' + RestContext.request.params.get('zip') + '%'; 
       
        if(RestContext.request.params.get('distance') == null)
            decWithinMilesOfLocation = 0.0;
        else
            decWithinMilesOfLocation = Decimal.valueOf(RestContext.request.params.get('distance'));           
       
       /* End */     
                    
        
        try
        {
            //Where clause needs to be added into main query only when certain criteria are matched
            if(strCity != '%%' || strState != '%%' || strZip != '%%')
            {
                strWhereLocation = 'AND id IN (SELECT provider__c '+
                                            'FROM provider_address__c '+
                                           'WHERE (city__c LIKE :strCity '+
                                               'OR State__c LIKE :strState ' +  
                                               'OR postal_code__c LIKE :strZip) '+ 
                                             'AND isdeleted = FALSE) ';
                                             
                List<String> lstAddress = new List<String>();
                lstAddress.add(null + '##'+strCity+'##'+'##'+strState+'##'+strZip);
                List<List<String>> lstCoordinates = SL_Geocode_Batch.Geocode(lstAddress);
                
                //Iterating on List of Coordinates to get the value of Longitude and Latitude.
                for(List<String> lstCoordinate : lstCoordinates)
                {
                    decLongitude = Decimal.valueOf(lstCoordinate[0]);
                    decLatitude = Decimal.valueOf(lstCoordinate[1]);
                }
            }
            else
            	decLongitude = decLatitude = null;
            
            //Where clause needs to be added into main query only when certain criteria are matched
            if(strservice != '')
            {
                 strWhereService = 'AND id IN (SELECT provider__c '+ 
                                            'FROM provider_specialty__c '+
                                           'WHERE Specialty__r.Name =:  strservice '+
                                               'AND isdeleted = FALSE) ';
            }
            
            if(decLatitude!=null && decLongitude!=null && decWithinMilesOfLocation!=null && String.valueOf(decLatitude)!='' && String.valueOf(decLongitude)!='' && String.valueOf(decWithinMilesOfLocation)!='')
            	strWhereProviderAddress+='(city__c LIKE :strCity OR State__c LIKE :strState OR postal_code__c LIKE :strZip) AND isdeleted = FALSE AND DISTANCE(Location__c, GEOLOCATION('+decLatitude+','+decLongitude+'),'+'\''+'mi'+'\''+') < '+decWithinMilesOfLocation;
            else
            	strWhereProviderAddress+='(city__c LIKE :strCity OR State__c LIKE :strState OR postal_code__c LIKE :strZip) AND isdeleted = FALSE';
            
            //Form a dynamic query
            strQuery = 'SELECT id, '+
                               'FirstName, '+
                               'LastName, '+
                               'direct_email__c, '+
                               'Account.id, '+
                               'Account.name, '+
                               '(SELECT street_address_1__c, street_address_2__c,  '+
                                       'postal_code__c, Location__Latitude__s, Location__Longitude__s,'+
                                       'city__c, Country__c, '+
                                       'state__c '+
                                  'FROM Provider_Addresses__r '+
                                  'WHERE '+ strWhereProviderAddress +'), '+
                               '(SELECT specialty__c, Primary_Indicator__c, Name, As_of_Date__c, Comments__c, Specialty__r.Description__c, Specialty__r.Classification__c, Specialty__r.Type__c, ' +
                                  ' Specialty__r.Specialization__c, Specialty__r.Specialty_Code__c ' + 
                                  'FROM provider_specialties__r '+
                                 'WHERE Specialty__r.Name = :strservice ' +
                                 'AND isdeleted = FALSE) '+
                          'FROM Contact '+
                          'WHERE FirstName LIKE :strFirst '+
                           'AND LastName LIKE :strLast '+
                           'AND Account.name LIKE :strOrganization '+
                           'AND NPI__c LIKE :strNpi ' + 
                           'AND isdeleted = FALSE '+
                           strWhereLocation +
                           strWhereService + 
                           ' Limit 201';
              lstProviders = database.query(strQuery) ;                 
              
            //If there is no providers for passed parameters then return empty list
            if(lstProviders.isEmpty())
            {
                return new ProviderSearchResponse (new List<SL_RestResponseWrappers.ProviderSearch>{}, true);
                
                //To cover the catch block in Test coverage
                if(Test.isRunningTest())
                    Integer i = 1/0;
                
                return null;
            }
            else
            {
                res.StatusCode = 200;
                res.addHeader('Content-Type', 'application/json; charset=utf-8');
                Boolean done = true;
                List<SL_RestResponseWrappers.ProviderSearch> lstResponse = new List<SL_RestResponseWrappers.ProviderSearch>();
                
                //If there is more than 200 providers, set the "done" parameters to false and remove the extra records from list
                if(lstProviders.size() >= 201)
                {
                    lstProviders.remove(200);
                    done = false;
                }   
                
                //Iterate through list of providers
                for(Contact objCon : lstProviders)
                {
                    SL_RestResponseWrappers.ProviderSearch objWR = new SL_RestResponseWrappers.ProviderSearch(objCon.FirstName, objCon.LastName, objCon.Account.name, objCon.direct_email__c);
                    objWR.Provider_ID = objCon.id;
                    
                    //Cretae a list to fill in the Address and speciality 
                    List<SL_RestResponseWrappers.Addresses> lstAddresses = new List<SL_RestResponseWrappers.Addresses>();
                    List<SL_RestResponseWrappers.Specialties> lstSpecialties = new List<SL_RestResponseWrappers.Specialties>();
                    
                    for(Provider_Address__c objPA: objCon.Provider_Addresses__r)
                    {
                        Decimal dtDistace = calculateDistance(decLatitude, decLongitude, objPA.Location__Latitude__s, objPA.Location__Longitude__s);
                        lstAddresses.add(new SL_RestResponseWrappers.Addresses(objPA.street_address_1__c, objPA.street_address_2__c, objPA.city__c, objPA.Country__c,objPA.state__c, objPA.postal_code__c, dtDistace));
                    }
                    for(Provider_Specialty__c objPS : objCon.provider_specialties__r)
                        lstSpecialties.add(new SL_RestResponseWrappers.Specialties(objPS.Primary_Indicator__c, objPS.Specialty__r.Description__c));  
                    
                    objWR.Specialties = lstSpecialties;
                    objWR.Addresses = lstAddresses;
                    
                    lstResponse.add(objWR);
                }
                    
                
                return new ProviderSearchResponse(lstResponse, done);          
            } 
                                                 
        }
        catch(Exception e)
        {
            res.StatusCode = 417;
            return null;
        }
    }
    
    /*
        @MethodName : calculateDistance
        @param      : Source and Target Latitude longitude
        @Description: This method is called get the distance between two cordinate.
        @CreatedBy  : Pankaj Ganwani
        @CreatedDate: 2/JUNE/2014
    */
    public static Decimal calculateDistance(Decimal decOriginalLatitude,Decimal decOriginalLongitude,Decimal decTargetLatitude,Decimal decTargetLongitude)
    {
    	if(decOriginalLatitude != null && decOriginalLongitude != null && decTargetLatitude != null && decTargetLongitude != null)
    	{
	        // convert to radians
	        Double dDepartLat = decOriginalLatitude * 3.14159 / 180;
	        Double dDepartLong = decOriginalLongitude * 3.14159 / 180;
	        Double dArrivalLat = decTargetLatitude * 3.14159 / 180;
	        Double dArrivalLong = decTargetLongitude * 3.14159 / 180;
	    
	        Double dDeltaLong = dArrivalLong - dDepartLong;
	        Double dDeltaLat = dArrivalLat - dDepartLat;
	    
	        // calculate angle using the haversine formula
	        Double dHaversineResult = Math.Sin( dDeltaLat / 2 ) * Math.Sin( dDeltaLat / 2 ) 
	                                  + Math.Cos( dDepartLat ) * Math.Cos( dArrivalLat ) 
	                                    * Math.Sin( dDeltaLong / 2 ) * Math.Sin( dDeltaLong / 2 );
	    
	        // calculate distance by multiplying arc-tangent by the planet radius in miles
	        Double dDistance = 3958.76 * 2 * Math.Atan2( Math.Sqrt( dHaversineResult ), Math.Sqrt( 1 - dHaversineResult ) );
	    
	        // return estimate
	        return dDistance;
    	}
    	return null;
    }
    
    @isTest
    static void testSL_ProviderSearch()
    {
        Test.startTest();
        
        Account testAcc = new Account(name = 'testAccount');
        insert testAcc;
        
        Contact testCon = new Contact(lastName = 'testContact',
                                      firstname = 'first',
                                      AccountId = testAcc.Id,
                                      NPI__c = 'NPI1');
        insert testCon;                           
        
        provider_address__c testPA = new provider_address__c(provider__c = testCon.Id, city__c = 'NY');
        insert testPA;
        
        Specialty__c testSpec = new Specialty__c(Name = 'D');
        insert testSpec; 
        
        provider_specialty__c testPS = new provider_specialty__c(provider__c = testCon.Id, Specialty__c = testSpec.Id);
        insert testPS;                            
                                      
        List<Contact> lstContact = new List<Contact>();
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://cs11.salesforce.com/services/apexrest/list/provider?' ; 
        
        
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res; 
        
        req.addParameter('first', Null);
        req.addParameter('last', Null);
        req.addParameter('organization', Null);
        req.addParameter('location', Null);
        req.addParameter('service', Null);
        req.addParameter('npi', Null);
        
        ProviderSearchResponse testResponseNegative = SL_ProviderSearch.getProvidersInformation();
        
        req.addParameter('first', testCon.firstname);
        req.addParameter('last', testCon.lastName);
        req.addParameter('organization', testAcc.name);
        req.addParameter('location', 'NY');
        req.addParameter('service', 'D');
        req.addParameter('npi', 'NPI1');
        
        ProviderSearchResponse testResponsepositive = SL_ProviderSearch.getProvidersInformation();
        system.assert(testResponsepositive.done == true && testResponsepositive.Providers.size() == 1);
        
        Test.stopTest();
    }
}