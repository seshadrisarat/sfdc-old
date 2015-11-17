/*
*Class: SL_OrganizationSearch
*Description: This class is used to search Organizations based on inputs entered by user in SL_HPD_Search page.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public with sharing class SL_OrganizationSearch 
{
    /* Start - global variables*/
    public String strName;   // This is used to store OrganizationName .
    public String strAddress; // This is used to store BillingStreet of Organization
    public String strCity;   // This is used to store BillingCity of organization
    public String strState;  // This is used to store BillingState of Organization
    public String strZipcode; // This is used to store BillingPostalCode of Organization
    public String strsortExpression;// This is used to store fieldName which is to be used in OrderBy Clause Of Query.
    public String strsortDirection;// This is used to store SortDirection(ASC/DESC) which is to used in OrderBy clause of Query. 
    public Decimal decLatitude; //This is used to store value of latitude of address
    public Decimal decLongitude; //This is used to store value of longitude of address
    public Decimal decWithinMilesOfLocation;
    public String strOrgId;//This variable used to keeo the Account Id.
    public String strCountry;//This variable is used to filter the Shipping country.
    public String strBillingStreet;//This variable is used to filter the Billing Street.
    public String strBillingCity;//This variable is used to filter the Billing city.
    public String strBillingCountry;//This variable is used to filter the Billing country.
    public String strBillingZipCode;//This variable is used to filter the Billing zip code.
    public String strBillingState;//This variable is used to filter the Billing State.
    public Set<String> setAccountId;//This set is used to keep the Id of the 
    
    /* As per MIHIN-82 */
    private String strNPI;
    private String strStatus;
    private String strIssueAuthority;
    /* End */
    
    /* Start - Added by Lodhi as per MIHIN-98 */
    private Integer intOffset;
    private Integer intLimit;
    /* End - Added by Lodhi as per MIHIN-98 */
    
    /* End - global variables*/
    
    /* Start - Constructor */
    public SL_OrganizationSearch()
    {
        intialize();
    }
    /* End - Constructor */
    
    /*
        @MethodName : intialize
        @param      : NA
        @Description: This is method is used to intialize all the variable of the class
        @CreatedBy  : Lodhi
        @CreatedDate: 15/JULY/2013
    */
    private void intialize()
    {
        strOrgId = '';
        strCountry = strBillingCity = strBillingStreet = strBillingCountry = strBillingZipCode = strBillingState = strNPI = strStatus = strIssueAuthority = '';
        setAccountId = new Set<String>();
    }
    /*End - Method */
    
    
    
    /*
        @MethodName : searchOrganization 
        @param      : Organization Name,Services,Street Address,City,State,Zip Code fields of String type and sortExpression,sortDirection .
        @Description: This mehod is used to search Organization based on following fields Organization Name,Services,Street Address,City,State,Zip Code. 
    */
    
    public list<Sobject> searchOrganization(String strName,String strAddress ,String strCity ,String strState ,
    										String strZipcode,String sortExpression,String sortDirection,
    										Decimal decLatitude,Decimal decLongitude,Decimal decWithinMilesOfLocation)
    {
        
        this.strName = strName ;
        this.strAddress = strAddress;
        this.strCity = strCity; 
        this.strState = strState;
        this.strZipcode = strZipcode;
        this.strsortExpression = sortExpression;
        this.strsortDirection = sortDirection;
        this.decLatitude = decLatitude;
        this.decLongitude = decLongitude;
        this.decWithinMilesOfLocation = decWithinMilesOfLocation;
        return searchOrganization();
    }
    
    
    /*
        @MethodName : searchProvider
        @param      : NA
        @Description: This method is call from the REST API Service to get the filter Organization(Account records).
        @CreatedBy  : Lodhi
        @CreatedDate: 15/JULY/2013
    */
    public list<Sobject> searchOrganization()
    {
        String strQuery = '';
        String strWhereClause = '';
         String strLocation = '';
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
            
        strQuery += '(SELECT Id, Electronic_Service__r.Name, Electronic_Service__r.Type__c, Electronic_Service__r.Protocol__c, Electronic_Service__r.Address__c, Electronic_Service__r.Certificate__c,Electronic_Service__c From Organization_Services__r), ';
        
        strQuery += '(Select Id, Name, Member_Organization__c, Member_Organization__r.Name, Affiliated_Organization__c, Affiliated_Organization__r.Name, Affiliation_Type__c, Start_Date__c, End_Date__c From Member_Affiliations__r), ';
        strQuery += '(Select Id, Name From Organization_Names__r), (SELECT Id, Name, Type__c FROM Organization_Identifiers__r)'; /* Removed (Select Id, Name From Contacts) from this SOQL to avoid violation of salesforce limitation(which is 200 child records per parent) if number of contact records are more than 200 corresponding to single Account and added (SELECT Id, Name, Type__c FROM Organization_Identifiers__r) for fetching the hcidentifier records - Updated By Pankaj Ganwani on 24/JUNE/2015 */
        
        strQuery += ' FROM Account ' ;
        
        
        try
        {
        	if(decLatitude!=null && decLongitude!=null && decWithinMilesOfLocation!=null && String.valueOf(decLatitude)!='' && String.valueOf(decLongitude)!='' && String.valueOf(decWithinMilesOfLocation)!='')
                strWhereClause += 'AND'+ strLocation + '<' + decWithinMilesOfLocation;        	
        	
            if(strOrgId != null && strOrgId != '')
                strWhereClause += ' AND Id = \''+strOrgId +'\'';
            
            if(setAccountId.size() > 0)
                strWhereClause += ' AND Id IN : setAccountId';
                
            if(strName!=null && strName!='')
               strWhereClause += ' AND Name Like ' + '\'' + '%' + strName.trim() +'%' +'\'' ;
        
                // checking whether this field is null or not .if it is not null then only we are including that field in where clause of SOQL query    
            if(strAddress!=null && strAddress!='')
               strWhereClause += ' AND ShippingStreet Like ' + '\'' + '%' + strAddress.trim() + '%' +'\'' ;
              
            if(strCity!=null && strCity!='')
               strWhereClause += ' AND ShippingCity Like ' + '\'' + '%' + strCity.trim() + '%' +'\'' ;
              
            if(strState!=null && strState!='')
               strWhereClause += ' AND ShippingState Like ' + '\'' + '%' + strState.trim() + '%' +'\'' ;
           
            if(strZipcode!=null && strZipcode!='')  
               strWhereClause += ' AND ShippingPostalCode Like ' + '\'' + '%' + strZipcode.trim() + '%' +'\'' ;
            
             if(strCountry!=null && strCountry!='') 
               strWhereClause += ' AND ShippingCountry Like ' + '\'' + '%' + strCountry.trim() + '%' +'\'' ;
               
               
             if(strBillingStreet!=null && strBillingStreet!='')
               strWhereClause += ' AND BillingStreet Like ' + '\'' + '%' + strBillingStreet.trim() + '%' +'\'' ;
              
            if(strBillingCity!=null && strBillingCity!='')
               strWhereClause += ' AND BillingCity Like ' + '\'' + '%' + strBillingCity.trim() + '%' +'\'' ;
              
            if(strBillingState!=null && strBillingState!='')
               strWhereClause += ' AND BillingState Like ' + '\'' + '%' + strBillingState.trim() + '%' +'\'' ;
           
            if(strBillingZipCode!=null && strBillingZipCode!='')    
               strWhereClause += ' AND BillingPostalCode Like ' + '\'' + '%' + strBillingZipCode.trim() + '%' +'\'' ;
            
            if(strBillingCountry!=null && strBillingCountry!='')    
               strWhereClause += ' AND BillingCountry Like ' + '\'' + '%' + strBillingCountry.trim() + '%' +'\'' ;
               
            if(strNPI != null && strNPI != '' && strWhereClause != '')
                strWhereClause += ' AND Organizational_NPI__c Like ' + '\'' + '%' + strNPI.trim() + '%' +'\'' ;
            else if(strNPI != null && strNPI != '')
                strWhereClause += ' Organizational_NPI__c Like ' + '\'' + '%' + strNPI.trim() + '%' +'\'' ;
            
            /* Start - Added by Pankaj Ganwani as per the requirement of MIHIN-118 on 1/Sept/2015 */
            if(String.isNotEmpty(strWhereClause))
            	strWhereClause+=' AND (RecordType.DeveloperName = \'MIHIN_Organizations\' OR RecordType.DeveloperName = \'Provider_Organization\')';
            else
            	strWhereClause+=' (RecordType.DeveloperName = \'MIHIN_Organizations\' OR RecordType.DeveloperName = \'Provider_Organization\')';
            /* End - Added by Pankaj Ganwani as per the requirement of MIHIN-118 on 1/Sept/2015 */
            
            strWhereClause = strWhereClause.replaceFirst('AND',''); 
               
           /* if(strsortExpression != null && strsortExpression != '' && strsortDirection != null && strsortDirection != '')  
                strWhereClause += ' ORDER By ' + strsortExpression + ' ' + strsortDirection + ' LIMIT 201';
            else
                strWhereClause += ' LIMIT 201';*/
                
                
            if(strsortExpression != null && strsortExpression != '' && strsortExpression == 'Distance' && strLocation != '' && strsortDirection != null && strsortDirection != '')  
                strWhereClause += ' ORDER By '+ strLocation +' ' + strsortDirection ;
            else  if(strsortExpression != null && strsortExpression != '' && strsortExpression != 'Distance' && strsortDirection != null && strsortDirection != '')  
                strWhereClause += ' ORDER By ' + strsortExpression + ' ' + strsortDirection;
                
            if(intLimit != null && intOffset != null)
            	strWhereClause += ' LIMIT ' + intLimit + ' OFFSET ' + intOffset;
            else
            	strWhereClause += ' LIMIT 201';
            
            if(strWhereClause != null && strWhereClause != '')
                strQuery += ' WHERE ' + strWhereClause;
                
            System.debug('==================strQueryAccount===================='+strQuery);
            
            if(strQuery != null && strQuery != '')      
                return Database.query(strQuery);
            else
                return new List<Account>();
           
        }
        
        catch(Exception e)
        {
            return new List<Account>();
        }
    }
    /* End Method */
    
    
    /*
     @MethodName : setPracticeAddress 
     @param      : SL_RestResponseWrappers.Addresses
     @Description: This method will call to sete the Other address.
   */
    public void setPracticeAddress(SL_RestResponseWrappers.Addresses objAddress)
    {
        this.strAddress = objAddress.Street_1;
        this.strCity = objAddress.City;
        this.strCountry= objAddress.County;
        this.strState = objAddress.State;
        this.strZipCode = objAddress.Zip_Code; 
        
        if(objAddress.Distance != null)
        {
			List<String> lstAddress = new List<String>();
			lstAddress.add(objAddress.Street_1 + '##'+objAddress.City+'##'+'##'+objAddress.State+'##'+objAddress.Zip_Code);
			List<List<String>> lstCoordinates = SL_Geocode_Batch.Geocode(lstAddress);
			
			//Iterating on List of Coordinates to get the value of Longitude and Latitude.
			for(List<String> lstCoordinate : lstCoordinates)
			{
				this.decLongitude = Decimal.valueOf(lstCoordinate[0]);
				this.decLatitude = Decimal.valueOf(lstCoordinate[1]);
				this.decWithinMilesOfLocation = objAddress.Distance;
			}
        }
    }
   
   /* End */
   
    /*
     @MethodName : setBillingAddress 
     @param      : SL_RestResponseWrappers.Addresses
     @Description: This method will call to sete the Billing address.
   */
    public void setBillingAddress(SL_RestResponseWrappers.Addresses objAddress)
    {
        this.strBillingStreet = objAddress.Street_1;
        this.strBillingCity = objAddress.City;
        this.strBillingCountry = objAddress.County;
        this.strBillingState = objAddress.State;
        this.strBillingZipCode = objAddress.Zip_Code; 
    }
   
   /* End */
   
    /*
     @MethodName : setMailingAddress 
     @param      : SL_DSML_API_Wrapper.HcIdentifierClass
     @Description: This method will call to set the hcIdentifier variables from REST API
   */
	public void setHcIdentifier(SL_DSML_API_Wrapper.HcIdentifierClass hcIdentifier)
   	{
   		if(hcIdentifier.Type == 'NPI')
   			this.strNPI = hcIdentifier.ID;
   		/*else if(hcIdentifier.Type == 'Medicaid Provider Number')
   			this.strMedicaidProviderNumber = hcIdentifier.ID;
   		else if(hcIdentifier.Type == 'Medicare Provider Number')
   			this.strMedicareProviderNumber = hcIdentifier.ID;*/
   		
   		this.strStatus = hcIdentifier.Status;
   		this.strIssueAuthority = hcIdentifier.IssuingAuthority;
   	}
   /* End */
   
   /*
     @MethodName : setOffSetLimit 
     @param      : SL_RestResponseWrappers.PUR
     @Description: This method is used to set the Offset and Limit.
   */
   public void setOffSetLimit(SL_DSML_API_Wrapper.PUR pur) 
   {
   		if(pur != null && pur.limits != null && pur.offset != null)
   		{
   			Set<String> setProfileName = new Set<String>();
   			for(API_Settings__c objAPISetting : [SELECT Id, Name FROM API_Settings__c])
   			{
   				setProfileName.add(objAPISetting.Name);
   			}
   			List<Profile> lstProfile = [SELECT Id, 
   											   Name 
   										  FROM Profile 
   										 WHERE Id =: Userinfo.getProfileId() 
   										   AND Name IN:setProfileName];
   			if(!lstProfile.isEmpty())
   			{
   				this.intLimit = pur.limits;
   				this.intOffset = pur.offset;
   			}
   		}
   }
   /* End */
   
  /*
    @MethodName : test_SL_OrganizationSearch 
    @param      : NA
    @Description: This is the test Method.
  */
   @isTest()
   private static void test_SL_OrganizationSearch()
   {
      
        RecordType objaccountRecordType =[ Select SobjectType,Id,DeveloperName 
                                           From RecordType 
                                           where SobjectType='Account' and DeveloperName='Provider_Organization'];

        list<Account> lstAccounts = new list<Account>{new Account(RecordTypeID=objaccountRecordType.id ,Name='TestOpportunity' ,
                                                     BillingStreet='201',BillingCity='Banglore',
                                                     BillingState='Karnataka',BillingPostalCode='6778987'), 
                                                     new Account(RecordTypeID=objaccountRecordType.id ,Name='TestOpportunity' ,
                                                     BillingStreet='202',BillingCity='Banglore',
                                                     BillingState='Karnataka',BillingPostalCode='6778987')};
        insert lstAccounts;     
        system.assert(lstAccounts.size()==2);             
 
        SL_OrganizationSearch objOrgSearch = new SL_OrganizationSearch();
        list<Sobject> lstAccounts1 = objOrgSearch.searchOrganization('TestOpportunity','','Banglore','Karnataka','6778987','Name' ,'Asc',0.0,0.0,0.0);
        
        objOrgSearch.strAddress = 'Test Address 1';
        objOrgSearch.strBillingCity = 'Test Billing City 1';
        objOrgSearch.strBillingCountry = 'Test Billing Country 1';
        objOrgSearch.strBillingState = 'Test Billing State 1';
        objOrgSearch.strBillingStreet = 'Test Billing Street 1';
        objOrgSearch.strBillingZipCode = 'Test Billing Zip Code 1';
        objOrgSearch.strCity = 'Test City 1';
        objOrgSearch.strCountry = 'Test Country 1';
        objOrgSearch.strName = 'Test Name 1';
        objOrgSearch.strOrgId = 'Test Org Id 1';
        objOrgSearch.strState = 'Test State 1';
        objOrgSearch.strZipcode = 'Test Zip Code 1';
        objOrgSearch.strsortDirection = 'ASC';
        objOrgSearch.strsortExpression = 'Test Expression 1';
        
        objOrgSearch.searchOrganization();
        objOrgSearch.setBillingAddress( new SL_RestResponseWrappers.Addresses('Street_1','Street-2', 'City','County', 'State', 'Zip_Code', 5));
        objOrgSearch.setPracticeAddress( new SL_RestResponseWrappers.Addresses('Street_1','Street-2', 'City','County', 'State', 'Zip_Code', 5));
        SL_DSML_API_Wrapper.PUR pur = new SL_DSML_API_Wrapper.PUR();
        pur.limits = 10;
        pur.offset = 0;
        objOrgSearch.setOffSetLimit(pur);
        
        
   }
}