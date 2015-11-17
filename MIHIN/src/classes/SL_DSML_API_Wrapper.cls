/*
*Class: SL_RestResponseWrappers
*Description: This class serves as wrapper class for prepare responses for Organization, Provider, Affiliation and Electronic services for external systems based on the input parameters.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
global class SL_DSML_API_Wrapper extends SL_RestResponseWrappers{

        
     /****************************
            Input Wrappers
      ****************************/
    
    // Provider Directory Unique Reference     
    global class PUR extends SL_RestResponseWrappers 
    {
      	public String hpdId ;
		public String hpdRequestId;
		public Integer limits;
		public Integer offset;
		
		public PUR(String hpdId, String hpdRequestId)
		{
			this.hpdId = hpdId;
			this.hpdRequestId = hpdRequestId;
		}
		public PUR()
		{
			
		}
    }  
    
    // Affiliation Unique Reference     
    global class MUR extends SL_RestResponseWrappers 
    {
      	public String uid ;
    }
    
    // ElectronicService Unique Reference     
    global class SUR extends SL_RestResponseWrappers 
    {
      	public String uid ;
    }
    
    // Individual Data Elements 
    global class IDE extends SL_RestResponseWrappers 
    {
        public String givenName;
        public String sn;
        public String hcSpecialization;
        public String hpdProviderLanguageSupported;
        public Addresses hpdProviderPracticeAddress;
        public Addresses hpdProviderMailingAddress;
        public HcIdentifierClass hcIdentifier;
        
        public SL_ProvidersSearch createProviderSearch()
        {
            SL_ProvidersSearch objPS = new SL_ProvidersSearch();
            
            //Mapping the attributes with their respective variables of the providersSearch class.
            if(givenName != null && givenName != '')
                objPS.strFirstName = givenName;
                
            if(sn != null && sn != '')
                objPS.strLastName = sn;
                
            if(hcSpecialization != null && hcSpecialization != '')
                objPS.strSpeciality = hcSpecialization;
                
            if(hpdProviderLanguageSupported != null && hpdProviderLanguageSupported != '')
                objPS.strLanguageSupport = hpdProviderLanguageSupported;
            //mapping address fields.   
            if(hpdProviderMailingAddress != null)
                objPS.setMailingAddress(hpdProviderMailingAddress);
                
            //mapping address fields.   
            if(hpdProviderPracticeAddress != null)
                objPS.setPracticeAddress(hpdProviderPracticeAddress);
            
            //mapping hcIdentifier fields with Provider Search class variables.   
            if(hcIdentifier != null)
               objPS.setHcIdentifier(hcIdentifier);
               
            return objPS;
        }
        
    }

    // Individual Unique Reference 
    global class IUR extends SL_RestResponseWrappers 
    {
        public String uid; 
        public String npiNumber;// added by Lodhi as per MIHIN-100
        public List<LUR> lur;// added by Lodhi as per MIHIN-100
        public String error;// added by Lodhi as per MIHIN-100
        
        //added by Lodhi as per MIHIN-100
        public IUR(String uid, String npiNumber, String error, List<LUR> lur)
        {
        	this.uid = uid;
        	this.npiNumber = npiNumber;
        	this.lur = lur;
        	this.error = error;
        }
        
        
        
        public SL_ProvidersSearch createProviderSearch()
        {
            SL_ProvidersSearch objPS = new SL_ProvidersSearch();
            objPS.strProviderId = uid;  
            return objPS;
        }
    }
    
    // Organization Data Elements 
    global class ODE extends SL_RestResponseWrappers 
    {
        public String hcRegisteredName; 
        public Addresses hpdProviderPracticeAddress;
        public Addresses hpdProviderBillingAddress ;
        public HcIdentifierClass hcIdentifier;
        
        public SL_OrganizationSearch createOrganizationSearch()
        {
            SL_OrganizationSearch objOS = new SL_OrganizationSearch();
            
            if(hcRegisteredName != null && hcRegisteredName != '')
                objOS.strName = hcRegisteredName;
                
            //mapping address fields.   
            if(hpdProviderPracticeAddress != null)
                objOS.setPracticeAddress(hpdProviderPracticeAddress);
            //mapping address fields.   
            if(hpdProviderBillingAddress  != null)
                objOS.setBillingAddress(hpdProviderBillingAddress);
             //mapping hcIdentifier fields with Provider Search class variables.   
            if(hcIdentifier != null)
               objOS.setHcIdentifier(hcIdentifier);
               
            return objOS;
        }    
    }
    
    // Organization Unique Reference 
    global class OUR extends SL_RestResponseWrappers
    {
        public String uid;
        
        public SL_OrganizationSearch createOrganizationSearch()
        {
            SL_OrganizationSearch objOS = new SL_OrganizationSearch();
            if(uid != null && uid != '')
                objOS.strOrgId = uid;
                
            return objOS;
                 
        }   
    }
    
    // Individual-Organization Relationship Data Elements 
    global class IORDE extends SL_RestResponseWrappers 
    {
        public List<String> hpdMemberType; 
        public String hpdHasAProvider;//as per new version 8
        public String hpdHasAnOrg; //as per new version 8
    }
    
    /* Start- Added by Lodhi as per MIHIN-100 */
    //License Data Object 
    global class LDO
    {
    	public String npiNumber;
    	public String licenseState;
    	public String licenseNumber;
    	public String licenseStatus;
    	
    	public LDO(String npiNumber, String licenseState, String licenseNumber, String licenseStatus)
    	{
    		this.npiNumber = npiNumber;
    		this.licenseState = licenseState;
    		this.licenseNumber = licenseNumber;
    		this.licenseStatus = licenseStatus;
    	}
    }
    
    //Unique identifier of a Provider
    global class NPI extends SL_RestResponseWrappers 
    {
    	public String npiNumber;
    	public String npiStatus;
    	public String access;
    	public List<LDO> ldo;
    	
    	public NPI(String npiNumber, String npiStatus, String access, List<LDO> ldo)
    	{
    		this.npiNumber = npiNumber;
    		this.npiStatus = npiStatus;
    		this.access = access;
    		this.ldo = ldo;
    	}
    	
    }
   /* End - Added by Lodhi as per MIHIN-100 */
      
      
    /****************************
            Output Wrappers
      ****************************/
    
    // Provider Directory Object 
    public class PPO extends SL_RestResponseWrappers 
    {
        // Not to be implemented in version 1
    }
    
    global class PDO extends SL_RestResponseWrappers 
	{
		public String hpdId ;
		public String hpdRequestId;
		
		public PDO(String hpdId, String hpdRequestId)
		{
			this.hpdId = hpdId;
			this.hpdRequestId = hpdRequestId;
		}
	}
    
    // Individual Data Object 
    public class IDO extends SL_RestResponseWrappers 
    {
        public String uid;
        public String title;//as per new version 8
        public String givenName;
        public String initials;//as per new version 8
        public String sn;
        public String cn;//as per new version 8
        public String suffix;//as per new version 8
        public String displayName;//as per new version 8
        public String description;//as per new version 8
        public String hpdProviderStatus;
        public String hcProfession;
        public String gender;
        public Date dateOfBirth;//as per new version 8
        public String hpdProviderLanguageSupported;
        public String hcPracticeLocation;
        public String telephoneNumber;
        public String facimilieTelephoneNumber;
        public String mobile;
        public String pager;
        public String email;
        public String directEmail;
        public String hcSigningCertificate;
        public Addresses hpdProviderPracticeAddress;
        public Addresses hpdProviderMailingAddress;
        public List<HcIdentifierClass> hcIdentifier;
        public List<Specialties> hcSpecialization;
        public List<Credentials> hpdCredential;
        public String memberOf;
        public DateTime creationDate;
        public DateTime lastUpdateDate;
        /* Start - Added By Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110*/
        public List<SDO> hpdHasAService;    
        /* End - Added By Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110*/  

        public IDO(Contact c, HcIdentifierClass hcIdentifier, Decimal decLatitude, Decimal decLongitude, List<SDO> lstSDO)
        {
            this.uid = c.id;
            this.title = c.Title;
            this.givenName = c.FirstName;
            this.initials = c.Middle_Name__c;
            this.sn = c.LastName;
            this.cn = c.Full_Name__c;
            this.suffix = c.Name_Suffix__c;
            this.displayName = c.Name;
            this.description = c.Description;
            this.hpdProviderStatus = c.Status__c;
            this.hcProfession = c.Type__c;
            this.gender = c.Gender__c;
            this.dateOfBirth = c.Birthdate;
            this.hpdProviderLanguageSupported = (c.Languages__c != null && c.Languages__c.contains(';')) ? c.Languages__c.replaceAll(';',' \\$ ') : c.Languages__c;//as per new version 8
            this.hcPracticeLocation = (c.Location__Longitude__s != null && c.Location__Latitude__s!= null)? c.Location__Longitude__s +' $ '+ c.Location__Latitude__s:'';//as per new version 8
            this.telephoneNumber = c.Phone;
            this.facimilieTelephoneNumber = c.Fax;
            this.mobile = c.MobilePhone;
            this.pager = c.Pager__c;
            this.email = c.Email;
            this.directEmail = c.Direct_Email__c;
            this.hcSigningCertificate = c.Digital_Certificate__c;
            this.creationDate = c.CreatedDate;
            this.lastUpdateDate = c.LastModifiedDate;
            this.hpdProviderMailingAddress = new SL_RestResponseWrappers.Addresses(c.MailingStreet,
                                                                                         null,
                                                                                         c.MailingCity,
                                                                                         c.MailingCountry,
                                                                                         c.MailingState,
                                                                                         c.MailingPostalCode,
                                                                                         null);//Assingning the mailing address to IDO instance.
            Decimal dtDistance = calculateDistance(decLatitude, decLongitude, c.Location__Latitude__s, c.Location__Longitude__s);                                                                        
            this.hpdProviderPracticeAddress = new SL_RestResponseWrappers.Addresses(c.OtherStreet,
                                                                                          null,
                                                                                          c.OtherCity,
                                                                                          c.OtherCountry,
                                                                                          c.OtherState,
                                                                                          c.OtherPostalCode,
                                                                                          dtDistance);//Assigning the Practice address to IDO instance.
            List<SL_DSML_API_Wrapper.HcIdentifierClass> lstHcIdentifierClass = new List<SL_DSML_API_Wrapper.HcIdentifierClass>();//This lst to keep format Affiliation__c records.
            
            /* Start - Added By Pankaj Ganwani on 24/JUNE/2015 as per the requirement of MIHIN-113 */
            for(Provider_Identifier__c objProviderIdetifier : c.Provider_Identifiers__r)
            {
            	lstHcIdentifierClass.add(new SL_DSML_API_Wrapper.HcIdentifierClass(hcIdentifier.IssuingAuthority, objProviderIdetifier.Type__c, objProviderIdetifier.Name, 'Active')); //putting the wrapper class object with exact field mapping.
            }
            /* End - Added By Pankaj Ganwani on 24/JUNE/2015 as per the requirement of MIHIN-113 */
            
            this.hcIdentifier = lstHcIdentifierClass;//assinging the lst to the response IDO instance.
            this.memberOf = c.AccountId;//as per new version 8
                    
            
            List<SL_RestResponseWrappers.Specialties> lstSpecialties = new List<SL_RestResponseWrappers.Specialties>();//This is the lst will keep the Provider_Specialties__c in exact format.
            //Iterating the Provider_Specialty__c related list of the contact to prepare the instance of the wrapper class to send in the response.
            for(Provider_Specialty__c objPS : c.Provider_Specialties__r)
            {
                lstSpecialties.add(new SL_RestResponseWrappers.Specialties(objPS.Primary_Indicator__c, objPS.Specialty__r.Name, objPS.Specialty__r.Description__c, 
                                                                           objPS.Specialty__r.Classification__c, objPS.Specialty__r.Type__c, 
                                                                           String.valueOf(objPS.As_of_Date__c), objPS.Comments__c,objPS.Specialty__r.Specialization__c,
                                                                           objPS.Specialty__r.Specialty_Code__c));//Adding to wrapper instance to the lst to set it to the response.
            }
            this.hcSpecialization = lstSpecialties;//assigning the lst to the response IDO instance.
            
            List<SL_RestResponseWrappers.Credentials> lstCredentials = new List<SL_RestResponseWrappers.Credentials>();//This lst will keep format Provider_Credential__c records.
            //Iterating the Provider_Credential__c related list of the contact to prepare the instance of the wrapper class to send in the response.
            for(Provider_Credential__c objPC : c.Provider_Credentials__r)
            {
                lstCredentials.add(new SL_RestResponseWrappers.Credentials(objPC.Name, objPC.Credential_Number__c, objPC.RecordType.Name, objPC.Current_Status__c, 
                                                                            String.valueOf(objPC.Grant_Date__c), objPC.Granting_Organization__r.Name, 
                                                                            String.valueOf(objPC.Expiration_Date__c), String.valueOf(objPC.PHI_Suspended__c), 
                                                                            String.valueOf(objPC.Suspended_Date__c), objPC.Limitations__c, objPC.Comments__c));//Creating the wrapper instance and adding to the lst to send the response.
            }
            this.hpdCredential = lstCredentials;//assigning the lst to the response IDO instance.
            this.hpdHasAService = lstSDO;
        }
    }
    
    // Organization Data Object 
    public class ODO extends SL_RestResponseWrappers 
    {
        public String uid;
        public String o;//as per new version 8
        public String hcRegisteredName;
        public List<String> hcNames;
        public String orgTypeDesc;
        public String hpdProviderStatus;
        public String telephone;
        //public String email;	//as per new version 8
        //public String directEmail;	//as per new version 8
        public String facimilieTelephoneNumber;
        public String hcSigningCertificate;
        public String hpdProviderLanguageSupported;
        public Addresses hpdProviderBillingAddress;
        public Addresses hpdProviderPracticeAddress;
        public List<HcIdentifierClass> hcIdentifier;
        public List<Specialties> hcSpecialization;
        public List<Credentials> hpdCredential;
        public String memberOf;
        public List<String> providers;
        //public List<HcServiceClass> hpdHasAService;
        //public List<String> hpdHasAService;
        public DateTime creationDate;
        public DateTime lastUpdateDate;
        /* Start - Added By Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110*/
        public List<SDO> hpdHasAService;
        /* End - Added By Pankaj Ganwani on 17/JUNE/2015 as per the requirement of MIHIN-110*/
        
        public ODO()
        {
            //do nothing
        }
        public ODO(Account objAccount, HcIdentifierClass hcIdentifier, Decimal decLatitude, Decimal decLongitude, List<SDO> lstSDO, Set<String> setContactId)
        {
            this.uid = objAccount.Id;
            this.o =  objAccount.Name;
            this.hcRegisteredName = objAccount.Name;
            this.orgTypeDesc = objAccount.RecordType.Name;
            this.telephone = objAccount.Phone;
            this.facimilieTelephoneNumber = objAccount.Fax;
            this.creationDate = objAccount.CreatedDate;
            this.lastUpdateDate = objAccount.LastModifiedDate;
            this.hpdProviderLanguageSupported = objAccount.Language__c;
            this.hcSigningCertificate = objAccount.Digital_Certificate__c;
            this.hpdProviderStatus = objAccount.Status__c;
            this.hpdProviderBillingAddress = new SL_RestResponseWrappers.Addresses(objAccount.BillingStreet,
                                                                                     null,
                                                                                     objAccount.BillingCity,
                                                                                     objAccount.BillingCountry,
                                                                                     objAccount.BillingState,
                                                                                     objAccount.BillingPostalCode,
                                                                                     null);//Assingning the mailing address to ODO instance.
                                                                                     
            Decimal dtDistance = calculateDistance(decLatitude, decLongitude, objAccount.Location__Latitude__s, objAccount.Location__Longitude__s);                                                                          
            this.hpdProviderPracticeAddress = new SL_RestResponseWrappers.Addresses(objAccount.ShippingStreet,
                                                                                      null,
                                                                                      objAccount.ShippingCity,
                                                                                      objAccount.ShippingCountry,
                                                                                      objAccount.ShippingState,
                                                                                      objAccount.ShippingPostalCode,
                                                                                      dtDistance);//Assigning the Practice address to ODO instance.
                                                                                      
                                                                                      
                                                                                      
            List<SL_DSML_API_Wrapper.HcIdentifierClass> lstHcIdentifierClass = new List<SL_DSML_API_Wrapper.HcIdentifierClass>();//This lst to keep format Affiliation__c records.
            
            /* Start - Added By Pankaj Ganwani on 24/JUNE/2015 as per the requirement of MIHIN-114 */
            for(Organization_Identifier__c objOI : objAccount.Organization_Identifiers__r)
            {
            	lstHcIdentifierClass.add(new SL_DSML_API_Wrapper.HcIdentifierClass(hcIdentifier.IssuingAuthority, objOI.Type__c, objOI.Name, 'Active'));
            }
            /* End - Added By Pankaj Ganwani on 24/JUNE/2015 as per the requirement of MIHIN-114 */
                
            this.hcIdentifier = lstHcIdentifierClass;//assinging the lst to the response ODO instance.
            
            List<SL_RestResponseWrappers.Credentials> lstCredentials = new List<SL_RestResponseWrappers.Credentials>();//This lst will keep format Organization_Credential__c records.
            //Iterating the Provider_Credential__c related list of the contact to prepare the instance of the wrapper class to send in the response.
            for(Organization_Credential__c objOC : objAccount.Organization_Credentials__r)
            {
                lstCredentials.add(new SL_RestResponseWrappers.Credentials(objOC.Name, objOC.Credential_Number__c, objOC.Type__c, objOC.Current_Status__c, 
                                                                            String.valueOf(objOC.Grant_Date__c), objOC.Organization__r.Name, 
                                                                            String.valueOf(objOC.Expiration_Date__c), String.valueOf(objOC.PHI_Suspended__c), 
                                                                            String.valueOf(objOC.Suspended_Date__c), objOC.Limitations__c, objOC.Comments__c));//Creating the wrapper instance and adding to the lst to send the response.
            }
            this.hpdCredential = lstCredentials;//assigning the lst to the response IDO instance.
            this.memberOf = objAccount.ParentId; //as per new version 8
            
            List<SL_RestResponseWrappers.Specialties> lstSpecialties = new List<SL_RestResponseWrappers.Specialties>();//This is the lst will keep the Organization_Specialties__r in exact format.
            //Iterating the Provider_Specialty__c related list of the contact to prepare the instance of the wrapper class to send in the response.
            for(Organization_Specialty__c objOS : objAccount.Organization_Specialties__r)
            {
                lstSpecialties.add(new SL_RestResponseWrappers.Specialties(null, objOS.Specialty__r.Name,objOS.Specialty__r.Description__c, objOS.Specialty__r.Classification__c, 
                                                                           objOS.Specialty__r.Type__c, String.valueOf(objOS.As_of_Date__c), null,
                                                                           objOS.Specialty__r.Specialization__c, objOS.Specialty__r.Specialty_Code__c));//Adding to wrapper instance to the lst to set it to the response.
            }
            this.hcSpecialization = lstSpecialties;//assigning the lst to the response ODO instance.
            
            
            List<String> lstOrgName = new List<String>();//This list is used to keep all the Organization_Names__r name to keep in the API Response.
            for(Organization_Name__c objON : objAccount.Organization_Names__r)
            {
                lstOrgName.add(objON.Name);
            }
            this.hcNames = lstOrgName;//Assigning to the ODO instance.
            
         	/* Start - Updated By Pankaj Ganwani on 24/JUNE/2015 */
            this.providers = new List<String>(setContactId);
            /* End - Updated By Pankaj Ganwani on 24/JUNE/2015 */
            
            //this.hpdHasAService = new List<SL_DSML_API_Wrapper.HcServiceClass>();
            this.hpdHasAService = lstSDO;
        }
    }
    
    // Organization-Organization Relationship Object 
    public class OORO extends SL_RestResponseWrappers 
    {
        public String hpdMemberId ;
        public String hpdMemberName ;
        public String hpdHasAnOrg ;
        public String hpdMemberType ;
        public Date hpdStartDate ;
        public Date hpdEndDate ;
        public String hpdMemberStatus ;

       
        public OORO(Organization_Affiliation__c objOA)
        {
            this.hpdMemberId = objOA.Id;
            this.hpdMemberName = objOA.Member_Organization__r.Name;
            this.hpdMemberType = objOA.Affiliation_Type__c;
            this.hpdHasAnOrg = objOA.Affiliated_Organization__c;
            this.hpdStartDate = objOA.Start_Date__c;
            this.hpdEndDate = objOA.End_Date__c;
            this.hpdMemberStatus = (objOA.End_Date__c == null || objOA.End_Date__c < Date.today()) ? 'Active' : 'InActive';
        }
    }
    
    // Individual-Organization Relationship Object  
    public class IORO extends SL_RestResponseWrappers 
    {
        public String hpdMemberId ;
        public String hpdHasAProvider;//as per new version 8
        //public String hpdMemberName ;//as per new version 8
        public String hpdHasAnOrg ;
        public String hpdMemberType ;
        public Date hpdStartDate ;
        public Date hpdEndDate ;
        //public String hpdMemberStatus ;//as per new version 8
        public String telephoneNumber ;
        public String mail ;
        public List<String> hpdHasAService;
       
        public IORO(Affiliation__c objAffiliation, List<String> lstElectronicServicesId)
        {
            this.hpdMemberId = objAffiliation.Id;
            this.hpdHasAProvider = objAffiliation.Provider__c;
           // this.hpdMemberName = objAffiliation.Provider__r.Name;//as per new version 8
            this.hpdHasAnOrg = objAffiliation.Organization__c;
            this.hpdMemberType = objAffiliation.Type__c;
            this.hpdStartDate =  objAffiliation.Start_Date__c;
            this.hpdEndDate = objAffiliation.End_Date__c;
            //this.hpdMemberStatus = (objAffiliation.End_Date__c == null || objAffiliation.End_Date__c > Date.today())?'Active':'Inactive';//as per new version 8
            this.telephoneNumber =  objAffiliation.Phone__c;
            this.mail = objAffiliation.Email__c;
            this.hpdHasAService = lstElectronicServicesId;
            
            //This list is used to add hpdHasAService records.
           /* for(Affiliation_Service__c objAF : lstAffiliationServices)
            {
                hpdHasAService.add(new SL_DSML_API_Wrapper.HcServiceClass(objAF));
            }*/
        }
        /*
        public IORO(String hpdMemberId, String hpdMemberName, String hpdHasAnOrg, String hpdMemberType,  
                    Date hpdStartDate, Date hpdEndDate, String hpdMemberStatus, String hpdMemberTelephone, String hpdMemberEmail, List<String> hpdHasAService)
        {
            this.hpdMemberId = hpdMemberId;
            this.hpdMemberName = hpdMemberName;
            this.hpdHasAnOrg = hpdHasAnOrg;
            this.hpdMemberType  = hpdMemberType;
            this.hpdStartDate = hpdStartDate;
            this.hpdMemberStatus = hpdMemberStatus;
            this.hpdEndDate = hpdEndDate;
            this.hpdMemberTelephone = hpdMemberTelephone;
            this.hpdMemberEmail = hpdMemberEmail;
            this.hpdHasAService = hpdHasAService;
        }*/
    }
    
    
    public class HcIdentifierClass
    {
        public String IssuingAuthority;
        public String Type;
        public String ID;
        public String Status;
        
        public HcIdentifierClass(String auth, String type, String id, string status)
        {
            this.IssuingAuthority = auth;
            this.Type = type;
            this.ID = id;
            this.Status = status;
        }
        
    }
    
    public class HcServiceClass
    {
        public String Name;
        public String Type;
        public String Protocol;
        public String Address;
        public String Certificate;
        

        public HcServiceClass(Affiliation_Service__c objAF)
        {
            this.setService(objAF.Electronic_Service__r);                                            
        }
        public HcServiceClass(Organization_Service__c objOS)
        {
            this.setService(objOS.Electronic_Service__r);                                            
        }
        private void setService(Electronic_Service__c objES){
            this.Name= objES.Name;
            this.Type = objES.Type__c;
            this.Protocol = objES.Protocol__c;
            this.Address = objES.Address__c;
            this.Certificate = objES.Certificate__c;
        }
    }
    
    //ElectronicService Object
    public class SDO extends SL_RestResponseWrappers 
    {
    	public String hpdServiceId;
    	public String hpdIntegrationProfile;
    	public String hpdContentProfile;
    	public String hpdServiceAddress;
    	public String hpdServiceCertificate;
    	/* Start - Added By Pankaj Ganwani on 16/JUNE/2015 as per the requirement of MIHIN-110*/
    	public String hpdServiceName;
    	public String hpdServiceDestinations;
    	/* End - Added By Pankaj Ganwani on 16/JUNE/2015 as per the requirement of MIHIN-110*/
    	
    	public SDO(Electronic_Service__c objES)
    	{
    		this.hpdServiceId = objES.Id;
    		this.hpdIntegrationProfile = objES.Protocol__c;
    		this.hpdContentProfile = objES.Payload__c;
    		this.hpdServiceAddress = objES.Address__c;
    		this.hpdServiceCertificate = objES.Certificate__c;
    		/* Start - Added By Pankaj Ganwani on 16/JUNE/2015 as per the requirement of MIHIN-110*/
    		this.hpdServiceName = objES.Name;
    		this.hpdServiceDestinations = objES.Service_Destinations__c;
    		/* End - Added By Pankaj Ganwani on 16/JUNE/2015 as per the requirement of MIHIN-110*/
    	}
    }
    
    //License Unique Reference 
    public class LUR extends SL_RestResponseWrappers
    {
    	public String salesforceId;
    	public String licenseNumber;
    	public Boolean success;
    	public String error; 
    	
    	public LUR(String salesforceId, String licenseNumber, Boolean success, String error)
    	{
    		this.salesforceId = salesforceId;
    		this.licenseNumber = licenseNumber;
    		this.success = success;
    		this.error = error;
    	}
    }
    
    
    
    /*
        @MethodName : prepareElectronicServicesResponse
        @param      : Set<String> setElectronicServiceId
        @Description: This method is called to get the prepare the REST API response on the basis of the list of the Electronic_Service__c send from the calling method.
        @CreatedBy  : Lodhi
        @CreatedDate: 04/DEC/2013
    */
    public static List<SL_DSML_API_Wrapper.SDO> prepareElectronicServicesResponse(Set<String> setElectronicServiceId)
    {
    	 List<SL_DSML_API_Wrapper.SDO> lstSDO = new List<SL_DSML_API_Wrapper.SDO>();
    	 try
    	 {
    	 	for(Electronic_Service__c objES : [SELECT Id, Protocol__c, Payload__c, Address__c, Certificate__c, Name, Service_Destinations__c
    	 									   FROM Electronic_Service__c 
    	 									   WHERE Id IN: setElectronicServiceId])
    	 	{
    	 		lstSDO.add(new SL_DSML_API_Wrapper.SDO(objES));
    	 	}
    	 	return lstSDO;
    	 }
    	 catch(Exception ex)
    	 {
    	 	return new List<SL_DSML_API_Wrapper.SDO>();
    	 }
    }
    /* End */
    
    /*
        @MethodName : prepareElectronicServicesResponse
        @param      : Source and Target Latitude longitude
        @Description: This method is called get the distance between two cordinate.
        @CreatedBy  : Lodhi
        @CreatedDate: 15/MAY/2014
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
    /* End */
}