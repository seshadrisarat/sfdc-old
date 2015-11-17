/*
*Class: SL_ProvidersSearch
*Description: This class is used to search Providers based on inputs entered by user in SL_HPD_Search page.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public with sharing class SL_ProvidersSearch
 {
    
    /* Start - global variables*/
    public String strFirstName;   // This is used to store FirstName of Provider
    public String strLastName;    // This is used to store LastName of Provider
    public String strNPI;         // This is used to store NPI__c of Provider
    public String strOrgName;     // This is used to store Organization Name of Provider
    public String strAddress;     // This is used to store MailingStreet of Provider
    public String strCity ;       // This is used to store MailingCity of Provider
    public String strState ;      // This is used to store MailingState of Provider
    public String strZipCode ;    // This is used to store MailingPostalCode of Provider
    public String strsortExpression; // This is used to store fieldName which is to be used in OrderBy Clause Of Query.
    public String strsortDirection; // This is used to store SortDirection(ASC/DESC) which is to used in OrderBy clause of Query. 
    public String strSpeciality;  // This is used to store Specialities__c of Provider
    public Decimal decLatitude; //This is used to store value of latitude of address
    public Decimal decLongitude; //This is used to store value of longitude of address
    public Decimal decWithinMilesOfLocation;
    /* Extra variables used by the REST API Service*/
    public String strProviderId;// This variable is used to serch the contact on the basis of the Id set by the webservice.
    public String strLanguageSupport;
    public String strHcSpeciality;
    
    /* As per MIHIN-82 */
    private String strMedicaidProviderNumber;
    private String strMedicareProviderNumber;
    private String strIssueAuthority;
    private String strStatus;
    /* End */
     
    public String strPracticeCounty;
    public String strMailingStreet_1;
    public String strMailingStreet_2;
    public String strMailingCity;
    public String strMailingCounty;
    public String strMailingState;
    public String strMailingZip_Code;
    public Set<String> setProviderId;
    
    /* Start - Added by Lodhi as per MIHIN-98 */
    private Integer intOffset;
    private Integer intLimit;
    /* End - Added by Lodhi as per MIHIN-98 */
    
    /* Start - Added by Lodhi as per MIHIN-100 */
   	public Set<String> setNPI;
   	public Set<String> setLicenses;
    /* End - Added by Lodhi as per MIHIN-100 */
    
    /* End */
    
    /* End - global variables*/
    
    /* Start - Constructor */
    public SL_ProvidersSearch()
    {
        intialize();
    }
    /* End - Constructor */
    
    /*
        @MethodName : intialize
        @param      : NA
        @Description: This is method is used to intialize all the variable of the class
        @CreatedBy  : Lodhi
        @CreatedDate: 9/JULY/2013
    */
    private void intialize()
    {
        strProviderId = strLanguageSupport = '';
        strPracticeCounty = '';
        strMailingStreet_1 = strMailingStreet_2 = strMailingCity = strMailingCounty = strMailingState = strMailingZip_Code = '';
        strMedicaidProviderNumber = strMedicareProviderNumber = strIssueAuthority = strStatus = strNPI = '';
        setProviderId = new Set<String>();
    }
    /*End - Method */
    
    /*
        @MethodName : searchProvider
        @param      : First Name,Last Name,NPI,Organization Name,Services,Street Address,City,State,Zip Code ,Specialities fields Of string type and sortExpression,sortDirection .
        @Description: This is method is used to search Providers based on following fields First Name,Last Name,NPI,Organization Name,Services,Street Address,City,State,Zip Code .
    */
    
    public list<Contact> searchProvider(String strLastName , String strFirstName ,String strNPI ,String strOrgName ,String strAddress, 
                                        String strCity ,String strState ,String strZipCode,
                                        String strSpeciality ,String sortExpression,String sortDirection,
                                        Decimal decLatitude,Decimal decLongitude,Decimal decWithinMilesOfLocation)
    {
        this.strLastName  = strLastName;
        this.strFirstName = strFirstName;
        this.strNPI=strNPI;
        this.strOrgName=strOrgName;
        this.strAddress=strAddress;
        this.strCity=strCity;
        this.strState=strState;
        this.strZipCode=strZipCode;
        this.strSpeciality = strSpeciality ;
        this.strsortExpression = sortExpression;
        this.strsortDirection = sortDirection;
        this.decLatitude = decLatitude;
        this.decLongitude = decLongitude;
        this.decWithinMilesOfLocation = decWithinMilesOfLocation;
        
        return searchProvider();
    }
    /* End - Method */
    
    /*
        @MethodName : searchProvider
        @param      : NA
        @Description: This method is call from the REST API Service to get the filter Provider(Contact records).
        @CreatedBy  : Lodhi
        @CreatedDate: 8/JULY/2013
    */
    public List<Contact> searchProvider()
    {
        try
        {
            String strWhereClause = ''; 
            String strQuery = '';
            String strLocation = '';
            if(decLatitude!=null && decLongitude!=null && decWithinMilesOfLocation!=null && String.valueOf(decLatitude)!='' && String.valueOf(decLongitude)!='' && String.valueOf(decWithinMilesOfLocation)!='')
           		strLocation =  ' DISTANCE(Location__c, GEOLOCATION('+decLatitude+','+decLongitude+'),'+'\''+'mi'+'\''+')';
           		
            strQuery += 'SELECT Id, FirstName, LastName, Status__c, Type__c, Gender__c, Languages__c, AccountId, Phone, Fax, MobilePhone, Pager__c, Email, Direct_Email__c, ';
            strQuery += 'Title, Middle_Name__c, Full_Name__c, Name_Suffix__c, Description, Birthdate, Location__Longitude__s, Location__Latitude__s,';
            strQuery += 'NPI__c, Account.Name, Org_Practice_Zip__c, Org_Practice_State__c, Org_Practice_City__c, Org_Practice_Address_line_1__c, MailingStreet, MailingState, ';
            strQuery += 'MailingPostalCode, MailingCountry, MailingCity, Specialities__c, Digital_Certificate__c, CreatedDate, LastModifiedDate, Medicaid_Provider_Number__c, ';
            strQuery += 'Name, OtherCountry, OtherStreet, OtherCity, OtherState, OtherPostalCode, Medicare_Provider_Number__c,';
            
            /* Start - Added Provider_Identifier__r inner query to fetch the related Provider Identifier record by Pankaj Ganwani on 24/JUNE/2015 */
            strQuery += '(SELECT Id, Provider__c, Provider__r.Name, Organization__c, Type__c, Start_Date__c, End_Date__c, Phone__c, Email__c,  Provider__r.AccountId FROM Affiliations__r), (SELECT Id, Type__c, Name FROM Provider_Identifiers__r), ';
            /* End - Added Provider_Identifier__r inner query to fetch the related Provider Identifier record by Pankaj Ganwani on 24/JUNE/2015 */
            
            strQuery += '(SELECT Id, Provider__c, Name, Credential_Number__c,  RecordType.Name, Type__c, Current_Status__c, Grant_Date__c, Granting_Organization__c, ';
            
            strQuery += 'Granting_Organization__r.Name, Expiration_Date__c, PHI_Suspended__c, Suspended_Date__c, Limitations__c, Comments__c FROM Provider_Credentials__r ';
            
             if(setLicenses != null && !setLicenses.isEmpty())
            	strQuery += ' WHERE Credential_Number__c IN:setLicenses), ' ;
            else
            	strQuery += ' ), ' ;
            
            strQuery += '(SELECT Specialty__c, Primary_Indicator__c, Name, As_of_Date__c, Comments__c, Specialty__r.Description__c, Specialty__r.Name, ';
            strQuery += 'Specialty__r.Classification__c, Specialty__r.Type__c, Specialty__r.Specialization__c, Specialty__r.Specialty_Code__c FROM provider_specialties__r ';
                               
            
            if(strSpeciality != null && strSpeciality != '')
                strQuery += 'WHERE Specialty__r.Name LIKE ' + '\'' + '%' +  strSpeciality.trim() + '%' + '\'' + ' AND isdeleted = FALSE ) ';
                               
            else
                strQuery += 'WHERE isdeleted = FALSE ) ';
            
                    
            strQuery += 'FROM Contact';
            
            if(strWhereClause != '' && decLatitude!=null && decLongitude!=null && decWithinMilesOfLocation!=null && String.valueOf(decLatitude)!='' && String.valueOf(decLongitude)!='' && String.valueOf(decWithinMilesOfLocation)!='')
                strWhereClause += ' AND'+ strLocation +'<' + decWithinMilesOfLocation;
            else if(decLatitude!=null && decLongitude!=null && decWithinMilesOfLocation!=null && String.valueOf(decLatitude)!='' && String.valueOf(decLongitude)!='' && String.valueOf(decWithinMilesOfLocation)!='')
            	strWhereClause += strLocation + '<' + decWithinMilesOfLocation;
            
            
            if(strProviderId != null && strProviderId != '' && strWhereClause != '')
                strWhereClause += ' AND Id = \''+strProviderId +'\'';
            else if(strProviderId != null && strProviderId != '')
                strWhereClause += ' Id = \''+strProviderId +'\'';
                
            if(setProviderId.size() > 0 && strWhereClause != '')
                strWhereClause += ' AND Id IN: setProviderId';
            else if(setProviderId.size() > 0)
                strWhereClause += ' Id IN: setProviderId';
                
            if(strLastName!=null && strLastName!='' && strWhereClause != '')
                strWhereClause += ' AND LastName Like ' + '\'' + '%' + strLastName.trim() + '%' +'\'' ;
            else if(strLastName!=null && strLastName!='')
                strWhereClause += ' LastName Like ' + '\'' + '%' + strLastName.trim() + '%' +'\'' ;
               
            if(strFirstName!=null && strFirstName!=''  && strWhereClause != '')
                strWhereClause += ' AND FirstName Like ' + '\'' + '%' + strFirstName.trim() + '%' +'\'' ;
            else if(strFirstName!=null && strFirstName!='')
                strWhereClause += ' FirstName Like ' + '\'' + '%' + strFirstName.trim() + '%' +'\'' ;
                
            if(strNPI!=null && strNPI!='' && strWhereClause != '')
                strWhereClause += ' AND NPI__c Like ' + '\'' + '%' + strNPI.trim() + '%' +'\'' ;
            else if(strNPI!=null && strNPI!='')
                strWhereClause += ' NPI__c Like ' + '\'' + '%' + strNPI.trim() + '%' +'\'' ;
            
            /* Added by Lodhi as per MIHIN-100 */
            if(setNPI != null && !setNPI.isEmpty() && strWhereClause != '')
            	strWhereClause += ' AND NPI__c IN: setNPI' ;
            else if(setNPI != null && !setNPI.isEmpty()) 
                strWhereClause += ' NPI__c IN: setNPI' ;
            /* End */   
                
            /* Added by Lodhi as per MIHIN-82 */
            if(strMedicaidProviderNumber != null && strMedicaidProviderNumber != '' && strWhereClause != '')
                strWhereClause += ' AND Medicaid_Provider_Number__c Like ' + '\'' + '%' + strMedicaidProviderNumber.trim() + '%' +'\'' ;
            else if(strMedicaidProviderNumber != null && strMedicaidProviderNumber != '')
                strWhereClause += ' Medicaid_Provider_Number__c Like ' + '\'' + '%' + strMedicaidProviderNumber.trim() + '%' +'\'' ;
                
           	if(strMedicareProviderNumber != null && strMedicareProviderNumber != '' && strWhereClause != '')
                strWhereClause += ' AND Medicare_Provider_Number__c Like ' + '\'' + '%' + strMedicareProviderNumber.trim() + '%' +'\'' ;
            else if(strMedicareProviderNumber != null && strMedicareProviderNumber != '')
                strWhereClause += ' Medicare_Provider_Number__c Like ' + '\'' + '%' + strMedicareProviderNumber.trim() + '%' +'\'' ;
            /* End */    
            
            if(strOrgName!=null && strOrgName!='' && strWhereClause != '')
               strWhereClause += ' AND Account.Name Like ' + '\''+ '%' +strOrgName.trim() + '%' + '\'';
            else if(strOrgName!=null && strOrgName!='')
               strWhereClause += ' Account.Name Like ' + '\''+ '%' +strOrgName.trim() + '%' + '\'';
               
            if(strAddress!=null && strAddress!='' && strWhereClause != '')  
               strWhereClause += ' AND OtherStreet Like ' + '\'' + '%' + strAddress.trim() + '%' +'\'' ;
            else if(strAddress!=null && strAddress!='') 
               strWhereClause += ' OtherStreet Like ' + '\'' + '%' + strAddress.trim() + '%' +'\'' ;
               
            if(strCity!=null && strCity!='' && strWhereClause != '')
                strWhereClause += ' AND OtherCity Like ' + '\'' + '%' + strCity.trim() + '%' +'\'' ;
            else if(strCity!=null && strCity!='')
                strWhereClause += ' OtherCity Like ' + '\'' + '%' + strCity.trim() + '%' +'\'' ;
               
            if(strState!=null && strState!='' && strWhereClause != '')
                strWhereClause += ' AND OtherState Like ' + '\'' + '%' + strState.trim() + '%' +'\'' ;
            else  if(strState!=null && strState!='')
                strWhereClause += ' OtherState Like ' + '\'' + '%' + strState.trim() + '%' +'\'' ;
             
            if(strZipCode!=null && strZipCode!='' && strWhereClause != '')  
                strWhereClause += ' AND OtherPostalCode Like ' + '\'' + '%' + strZipcode.trim() + '%' +'\'' ; 
            else if(strZipCode!=null && strZipCode!='' )    
                strWhereClause += ' OtherPostalCode Like ' + '\'' + '%' + strZipcode.trim() + '%' +'\'' ; 
             
            if(strSpeciality!= null && strSpeciality!='' && strWhereClause != '')   
                strWhereClause += ' AND ID IN ( SELECT Provider__c  From Provider_Specialty__c where Specialty__r.name LIKE ' + '\'' + '%' +  strSpeciality.trim() + '%' + '\'' + ')';
            else  if(strSpeciality!= null && strSpeciality!='' )   
                strWhereClause += ' ID IN ( SELECT Provider__c  From Provider_Specialty__c where Specialty__r.name LIKE ' + '\'' + '%' +  strSpeciality.trim() + '%' + '\'' + ')';
               
            if(strLanguageSupport!=null && strLanguageSupport!='' && strWhereClause != '')
                strWhereClause += ' AND Languages__c INCLUDES( ' + '\''  + strLanguageSupport.trim()  +'\')' ;
            else if(strLanguageSupport!=null && strLanguageSupport!='')
                strWhereClause += ' Languages__c INCLUDES( ' + '\'' + strLanguageSupport.trim() +'\')' ;
                
            if(strMailingStreet_1 != null && strMailingStreet_1 !='' && strWhereClause != '')
                strWhereClause += ' AND MailingStreet Like ' + '\'' + '%' + strMailingStreet_1.trim() + '%' +'\'' ;
            else if(strMailingStreet_1 != null && strMailingStreet_1 !='')
                strWhereClause += ' MailingStreet Like ' + '\'' + '%' + strMailingStreet_1.trim() + '%' +'\'' ;
                
            if(strMailingCity != null && strMailingCity !='' && strWhereClause != '')
                strWhereClause += ' AND MailingCity Like ' + '\'' + '%' + strMailingCity.trim() + '%' +'\'' ;
            else if(strMailingCity != null && strMailingCity !='')
                strWhereClause += ' MailingCity Like ' + '\'' + '%' + strMailingCity.trim() + '%' +'\'' ;
            
            if(strMailingCounty != null && strMailingCounty !='' && strWhereClause != '')
                strWhereClause += ' AND MailingCountry Like ' + '\'' + '%' + strMailingCounty.trim() + '%' +'\'' ;
            else if(strMailingCounty != null && strMailingCounty !='')
                strWhereClause += ' MailingCountry Like ' + '\'' + '%' + strMailingCounty.trim() + '%' +'\'' ;
                
            if(strMailingState != null && strMailingState !='' && strWhereClause != '')
                strWhereClause += ' AND MailingState Like ' + '\'' + '%' + strMailingState.trim() + '%' +'\'' ;
            else if(strMailingState != null && strMailingState !='')
                strWhereClause += ' MailingState Like ' + '\'' + '%' + strMailingState.trim() + '%' +'\'' ;
            
            if(strMailingZip_Code != null && strMailingZip_Code !='' && strWhereClause != '')
                strWhereClause += ' AND MailingPostalCode Like ' + '\'' + '%' + strMailingZip_Code.trim() + '%' +'\'' ;
            else if(strMailingZip_Code != null && strMailingZip_Code !='')
                strWhereClause += ' MailingPostalCode Like ' + '\'' + '%' + strMailingZip_Code.trim() + '%' +'\'' ;
                
            if(strPracticeCounty != null && strPracticeCounty !='' && strWhereClause != '')
                strWhereClause += ' AND OtherCountry Like ' + '\'' + '%' + strPracticeCounty.trim() + '%' +'\'' ;
            else if(strPracticeCounty != null && strPracticeCounty !='')
                strWhereClause += ' OtherCountry Like ' + '\'' + '%' + strPracticeCounty.trim() + '%' +'\'' ;
            
            /* Start - Added by Pankaj Ganwani as per the requirement of MIHIN-118 on 1/Sept/2015 */
            if(String.isNotEmpty(strWhereClause))
            	strWhereClause+=' AND RecordType.DeveloperName = \'Provider\'';
            else
            	strWhereClause+=' RecordType.DeveloperName = \'Provider\'';
            /* End - Added by Pankaj Ganwani as per the requirement of MIHIN-118 on 1/Sept/2015 */
            
            if(strsortExpression != null && strsortExpression != '' && strsortExpression == 'Distance' && strLocation != '' && strsortDirection != null && strsortDirection != '')  
                strWhereClause += ' ORDER By '+ strLocation +' ' + strsortDirection;
            else  if(strsortExpression != null && strsortExpression != '' && strsortExpression != 'Distance' && strsortDirection != null && strsortDirection != '')  
                strWhereClause += ' ORDER By ' + strsortExpression + ' ' + strsortDirection;
           
                
           	if(intLimit != null && intOffset != null)
            	strWhereClause += ' LIMIT ' + intLimit + ' OFFSET ' + intOffset;
            else
            	strWhereClause += ' LIMIT 201';
    
            if(strWhereClause != null && strWhereClause != '')
                strQuery += ' WHERE ' + strWhereClause;
            
            System.debug('==============strQueryContact================='+strQuery);
            if(strQuery != null && strQuery !='')
                return Database.query(strQuery);
            else
                return new List<Contact>();
            
        }
        catch(Exception ex)
        {
            System.debug('==================Exception=============='+ex); 
            return new List<Contact>();
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
        this.strPracticeCounty = objAddress.County;
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
     @MethodName : setMailingAddress 
     @param      : SL_RestResponseWrappers.Addresses
     @Description: This method will call to sete the Mailing address.
   */
    public void setMailingAddress(SL_RestResponseWrappers.Addresses objAddress)
    {
        this.strMailingStreet_1 = objAddress.Street_1;
        this.strMailingStreet_2 = objAddress.Street_2;
        this.strMailingCity = objAddress.City;
        this.strMailingCounty = objAddress.County;
        this.strMailingState = objAddress.State;
        this.strMailingZip_Code = objAddress.Zip_Code; 
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
   		else if(hcIdentifier.Type == 'Medicaid Provider Number')
   			this.strMedicaidProviderNumber = hcIdentifier.ID;
   		else if(hcIdentifier.Type == 'Medicare Provider Number')
   			this.strMedicareProviderNumber = hcIdentifier.ID;
   		
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
     @MethodName : test_SL_ProvidersSearch 
     @param      : NA
     @Description: This is the test Method.
   */
  
    @isTest()
    private static void test_SL_ProvidersSearch()
    {
      
    	RecordType objaccountRecordType =[ Select SobjectType,Id,DeveloperName 
                                           From RecordType 
                                           where SobjectType='Account' and DeveloperName='Provider_Organization'];

        list<Account> lstAccounts = new list<Account>{new Account(RecordTypeID=objaccountRecordType.id ,Name='TestOpportunity' ,
                                                     BillingStreet='201',BillingCity='Banglore',
                                                     BillingState='Karnataka',BillingPostalCode='6778987'), 
                                                     new Account(RecordTypeID=objaccountRecordType.id ,Name='TestOpportunity1' ,
                                                     BillingStreet='202',BillingCity='Banglore',
                                                     BillingState='Karnataka',BillingPostalCode='6778987')};
        insert lstAccounts; 
        system.assert(lstAccounts.size()==2);
        
        RecordType objContactRecordType =[ Select SobjectType,Id,DeveloperName 
                                           From RecordType 
                                           where SobjectType='Contact' and DeveloperName='Provider'];   
                                           
        list<Contact> lstContacts = new list<Contact>{new Contact(RecordTypeID=objContactRecordType.id,AccountId=lstAccounts.get(0).id,FirstName='TestName',LastName='TestProvider',NPI__c='Test',MailingCity='Banglore',MailingState='karnataka',MailingPostalCode='345678') 
                                                      ,new Contact(RecordTypeID=objContactRecordType.id,AccountId=lstAccounts.get(1).id,FirstName='TestName',LastName='TestProvider1',NPI__c='Test1',MailingCity='Banglore',MailingState='karnataka',MailingPostalCode='345678')};
                                                      
        insert lstContacts;     
         system.assert(lstContacts.size()==2);
        
        SL_ProvidersSearch objProviderSearch = new SL_ProvidersSearch();
        list<Contact> lstContacts1 = objProviderSearch.searchProvider('TestProvider','TestName','Test','','','Banglore','Karnataka','345678','','Name','ASC',0.0,0.0,0.0);
        
        objProviderSearch.strLanguageSupport = 'English';
        objProviderSearch.strHcSpeciality = 'test';
        objProviderSearch.strPracticeCounty = 'country';
        objProviderSearch.strMailingStreet_1 = 'street';
        objProviderSearch.strMailingStreet_2 = 'street2';
        objProviderSearch.strMailingCity = 'city';
        objProviderSearch.strMailingCounty = 'country';
        objProviderSearch.strMailingState = 'state';
        objProviderSearch.strMailingZip_Code = 'code';
        objProviderSearch.searchProvider();      
        
        SL_ProvidersSearch objProviderSearch3 = new SL_ProvidersSearch();  
        objProviderSearch3.strPracticeCounty = 'country';
        objProviderSearch3.searchProvider();      
         
        SL_ProvidersSearch objProviderSearch6 = new SL_ProvidersSearch();  
        objProviderSearch6.strMailingStreet_1 = 'street';
        objProviderSearch6.searchProvider();     
        
        SL_ProvidersSearch objProviderSearch7 = new SL_ProvidersSearch();  
        objProviderSearch7.strMailingCity = 'city';
        objProviderSearch7.searchProvider();    
         
        SL_ProvidersSearch objProviderSearch8 = new SL_ProvidersSearch();  
        objProviderSearch8.strMailingCounty = 'country';
        objProviderSearch8.searchProvider(); 
         
        SL_ProvidersSearch objProviderSearch9 = new SL_ProvidersSearch();  
        objProviderSearch9.strMailingState = 'state';
        objProviderSearch9.searchProvider();  
         
        SL_ProvidersSearch objProviderSearch10 = new SL_ProvidersSearch();  
        objProviderSearch10.strMailingZip_Code = 'code';
        objProviderSearch10.searchProvider(); 
         
        SL_ProvidersSearch objProviderSearch10a = new SL_ProvidersSearch();  
        objProviderSearch10a.strMailingZip_Code = 'code';
        objProviderSearch10a.searchProvider();   
         
        SL_ProvidersSearch objProviderSearch11 = new SL_ProvidersSearch();  
        objProviderSearch11.strFirstName = 'first';
        objProviderSearch11.searchProvider();
         
        SL_ProvidersSearch objProviderSearch12 = new SL_ProvidersSearch();  
        objProviderSearch12.strLastName = 'first';
        objProviderSearch12.searchProvider();
         
        SL_ProvidersSearch objProviderSearch13 = new SL_ProvidersSearch();  
        objProviderSearch13.strNPI = 'first';
        objProviderSearch13.searchProvider();
         
        SL_ProvidersSearch objProviderSearch14 = new SL_ProvidersSearch();  
        objProviderSearch14.strOrgName = 'first';
        objProviderSearch14.searchProvider();
         
        SL_ProvidersSearch objProviderSearch14a = new SL_ProvidersSearch();  
        objProviderSearch14a.strOrgName = 'first';
        objProviderSearch14a.searchProvider();
         
        SL_ProvidersSearch objProviderSearch15 = new SL_ProvidersSearch();  
        objProviderSearch15.strAddress = 'first';
        objProviderSearch15.searchProvider();
         
        SL_ProvidersSearch objProviderSearch16 = new SL_ProvidersSearch();  
        objProviderSearch16.strCity = 'first';
        objProviderSearch16.searchProvider();
         
        SL_ProvidersSearch objProviderSearch17 = new SL_ProvidersSearch();  
        objProviderSearch17.strState = 'first';
        objProviderSearch17.searchProvider();
         
        SL_ProvidersSearch objProviderSearch18 = new SL_ProvidersSearch();  
        objProviderSearch18.strZipCode = 'first';
        objProviderSearch18.searchProvider();
         
        SL_ProvidersSearch objProviderSearch19 = new SL_ProvidersSearch();  
        objProviderSearch19.strZipCode = 'first';
        objProviderSearch19.searchProvider();
        objProviderSearch19.setMailingAddress( new SL_RestResponseWrappers.Addresses('Street_1','Street-2', 'City','County', 'State', 'Zip_Code',5));
        objProviderSearch19.setPracticeAddress( new SL_RestResponseWrappers.Addresses('Street_1','Street-2', 'City','County', 'State', 'Zip_Code', 5));
        SL_DSML_API_Wrapper.PUR pur = new SL_DSML_API_Wrapper.PUR();
        pur.limits = 10;
        pur.offset = 0;
        objProviderSearch19.setOffSetLimit(pur);
    }
    
 }