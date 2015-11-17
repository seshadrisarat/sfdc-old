/*
*  ClassName  	  : Sl_ClaimDetailsController
*  JIRATicket     : PURE-10
*  CreatedOn      : 1/22/2014
*  ModifiedBy     : Hemant
*  Description    :   
*/
public without sharing class SL_ClaimDetailsController 
{	
	/* Start of variables */
	public list<Sl_ClaimsWrapper> lstOpenClaims 			{get;set;}
	public string memberName 								{get;set;}
	public string memberNumber 								{get;set;}
	public string selectedClaimNumber 						{get;set;}
	public Sl_ClaimsWrapper objSelectedClaim 				{get;set;} 
	public list<vendorsInvolved> lstVendorsInvolved 		{get;set;} 
	public list<claimActivityHistory> lstClaimActivity 		{get;set;} 
	public list<claimPaymentHistory> lstClaimPayment 		{get;set;} 		
	public String userAccountId				{get;set;}// This is to store logged in user account id.
	public String strChatterMessage 		{get;set;}// Adjustor/Member Advocate entered text for feeditem
	public String claimId; 
	public Boolean isAdjAsMemberAdvocate 	{get;set;}// Adjustor and Member Advocate are same
	public String AdjsterName 				{get;set;}// Adjuster name 
	public String MemberAdvocateName 		{get;set;}// Member advocate name 
	public String AdjsterPhoto 				{get;set;}// Adjuster Photo 
	public String MemberAdvocatePhoto 		{get;set;}// Member advocate Photo
	public String MemberEmail				{get;set;}
	public String MemberPhone				{get;set;}
	public String strMemAdvOrAdjUser        {get;set;}
	public Boolean isError		            {get;set;}
	
	public String strFileName 				{get;set;}
	public Blob attachmentBody 				{get;set;} 
    public Integer imageSize 				{get;set;}
    public Boolean isFileSelected 			{get;set;}
    public String isSuccess 				{get;set;}	// Validating the feedItem successfully posted or not
    public String strContentType 			{get;set;}
    public Boolean isPhoneSpecified			{get;set;}
	public Boolean isEmailSpecified			{get;set;}
	public Boolean isMemberEmail			{get;set;}
	public Boolean isMemberPhone			{get;set;}
	public Boolean defaultAdjustorImage		{get;set;}
	public Boolean defaultMemberImage		{get;set;}
	public Boolean isClaimAdjsutorDisplayed     {get;set;}
	private string strDefltClaimUserEmailAddr   {get;set;}    
	
	public Boolean isAdvocate				{get;set;}
	public  Boolean isDefaultForAdjuster	{get;set;}
	public  Boolean isDefaultForAdvocate	{get;set;}
        
    public String commPreferences 			{get;set;}
    private String strProfileName			{get;set;}
    private Id idDefaultClaimUser 			{get;set;}				// Chatter user id
    public list<contactInfoWrapper> lstContInfo {get;set;}
    
	/* End of Variables */
	
	/*
		Constructor
	*/
	public SL_ClaimDetailsController()
	{
		lstOpenClaims = new list<Sl_ClaimsWrapper>();
		lstVendorsInvolved = new list<vendorsInvolved>();
		lstClaimActivity = new list<claimActivityHistory>();
		lstClaimPayment = new list<claimPaymentHistory>(); 
		lstContInfo = new list<contactInfoWrapper>(); 
		system.debug('####==>'+ApexPages.currentPage().getParameters().get('url'));
		if(ApexPages.currentPage().getParameters().containsKey('url'))
			selectedClaimNumber = ApexPages.currentPage().getParameters().get('url');
		else if(ApexPages.currentPage().getParameters().containsKey('claimNumber'))
			selectedClaimNumber = ApexPages.currentPage().getParameters().get('claimNumber');

		isAdjAsMemberAdvocate  = isAdvocate = false; 
		isDefaultForAdjuster = isDefaultForAdvocate = true;
		isClaimAdjsutorDisplayed = false;
		isSuccess = 'none';
		strMemAdvOrAdjUser = '';
		AdjsterPhoto = '';
		MemberAdvocatePhoto = MemberAdvocateName = AdjsterPhoto = AdjsterName = '';
		commPreferences = '';
	}
	
	/*Wrapper Class*/
	public class Sl_ClaimsWrapper
	{
		public String policyType 			{	get;set;	}
		public String claimNumber   		{	get;set;	}
		public Decimal totalPaid			{	get;set;	}
		public String lossLocation			{	get;set;	}
		public Date   dateOfLoss 			{	get;set;	}
		public Boolean canShowDetail		{	get;set;	}
		public String claimStatus			{	get;set;	}
		 
		public String description			{	get;set;	}
		public String Adjustor				{	get;set;	}
		public String AdjustorName			{	get;set;	}
		public String AdjustorEmail			{	get;set;	}
		public String AdjustorPhone			{	get;set;	}
		public String MemAdvocate			{	get;set;	}
		public String MemAdvocateName		{	get;set;	}
		public String MemAdvocateEmail		{	get;set;	}
		public String MemAdvocatePhone		{	get;set;	}
		
		public Boolean isLPA				{	get;set;	}
		
		public Sl_ClaimsWrapper(String policyType, String claimNumber, Decimal totalPaid, String lossLocation, Date dateOfLoss,Boolean canShowDetail,String claimStatus,
								String description, String Adjustor, String AdjustorName, String AdjustorEmail, String AdjustorPhone, 
								String MemAdvocate, String MemAdvocateName, String MemAdvocateEmail, String MemAdvocatePhone, Boolean isLPA	)
		{
			this.policyType 		= 	policyType.trim().toLowerCase();
			this.claimNumber 		= 	claimNumber;
			this.totalPaid 			= 	totalPaid;
			this.lossLocation 		= 	lossLocation;
			this.dateOfLoss 		= 	dateOfLoss;
			this.canShowDetail 		= 	canShowDetail;
			this.claimStatus		=	claimStatus;	
			
			this.description 		= 	description;
			this.Adjustor	 		= 	Adjustor;
			this.AdjustorName 		= 	AdjustorName;
			this.AdjustorEmail 		= 	AdjustorEmail;
			this.AdjustorPhone 		= 	AdjustorPhone;
			this.MemAdvocate	 	= 	MemAdvocate;
			this.MemAdvocateName 	= 	MemAdvocateName;
			this.MemAdvocateEmail 	= 	MemAdvocateEmail;
			this.MemAdvocatePhone	=	MemAdvocatePhone;	
			this.isLPA 				= 	isLPA;
		}
	}
	public class vendorsInvolved
	{
		public String  role 		{	get;set;	}
		public String  company   	{	get;set;	}
		public String  phone 		{	get;set;	}
		public String  email		{	get;set;	}
		public Integer row			{	get;set;	}
		
		public vendorsInvolved(String role,String company,String phone,String email,Integer row)
		{
			this.role 		=	role;
			this.company   	=	company;
			this.phone 		=	phone;
			this.email		=	email;
			this.row 		=	row;
		}
	}
	public class claimActivityHistory
	{
		public Date activitydate	{	get;set;	}
		public String Type   		{	get;set;	}
		public String ShortDesc 	{	get;set;	}
		public String FullDesc		{	get;set;	}
		public Integer row			{	get;set;	}
		public Boolean isLong		{	get;set;	}
		
		public claimActivityHistory(Date activitydate,String Type,String ShortDesc,String FullDesc,Integer row, Boolean isLong)
		{
			this.activitydate 	=	activitydate;
			this.Type   		=	Type;
			this.ShortDesc 		=	ShortDesc;
			this.FullDesc		=	FullDesc;
			this.row 			=	row;	
			this.isLong 		=	isLong;
		}
	}
	public class claimPaymentHistory
	{
		public Date paymentDate 	{	get;set;	}
		public String CheckNumber   {	get;set;	}
		public String paidTo 		{	get;set;	}
		public Decimal amount		{	get;set;	}
		public String status		{	get;set;	}
		public Integer row			{	get;set;	}
		
		public claimPaymentHistory(Date paymentDate,String paidTo,String CheckNumber,Decimal amount,String status,Integer row)
		{
			this.paymentDate 	=	paymentDate;
			this.paidTo 		=	paidTo;
			this.CheckNumber   	=	CheckNumber;
			this.amount 		=	amount;
			this.status			=	status;
			this.row 			=	row;
		}
	}
	public class contactInfoWrapper
	{
		public String Email			{	get;set;	}
		public String Phone			{	get;set;	}
		public Boolean IsPrimary	{	get;set;	}
		public String Type			{	get;set;	}
		
		public contactInfoWrapper(String Email,String Phone,Boolean IsPrimary,String Type)
		{
			this.Email = Email;
			this.Phone = Phone;
			this.IsPrimary = IsPrimary;
			this.Type = Type;
		}
	}
		
	/*
		Name: pageAction
		Param: None
		Description: This page action method will ensure that non authenicated user can't see the page content
	*/
	public pageReference pageAction()
	{
		
		//If user is not authenticated then redirect to login page else proceed with further logic
		if(Userinfo.getUserType() == 'Guest') 
			return new Pagereference('/LoginPage');
		
		isError = false;
		
		
		if(ApexPages.currentPage().getParameters().containsKey('isSuccess'))
		{
			isSuccess = ApexPages.currentPage().getParameters().get('isSuccess');
		}
		
		
		String strBrocker = ''; 
		String strContactId = '';
		Set<Id> setAgencyContactId = new Set<Id>();
		strProfileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()].Name;
		
		/* If it is accessed from Agent home page */ 
		if(strProfileName == 'PURE Broker View Partner Login User')
		{
			
			for(User objUser : [SELECT ContactId FROM User WHERE Id =: Userinfo.getUserId() LIMIT 1])
			{
				strContactId = objUser.ContactId; 
			}
			
			for(Agency_Contact__c obj : [SELECT Agency__c 
										 FROM Agency_Contact__c 
										 WHERE Contact__c =: strContactId 
										   AND User_Status__c = 'Active' 
										   AND (Agency__r.Broker_Status__c = 'Active' 
										    OR Agency__r.Broker_Status__c = 'Suspended with Access')])
				setAgencyContactId.add(obj.Agency__c);
			
			if(!setAgencyContactId.isEmpty() && setAgencyContactId != null)
				strBrocker =  'Broker__c IN: setAgencyContactId';
			else{
				PageReference pageRef = new PageReference('/Exception');
				return pageRef;
			}
		}
		else
		{
		//if(ApexPages.currentPage().getParameters().containsKey('url'))
		//{
			/* This is to query logged in user account id.*/
			for(User objUser : [SELECT Id, Contact.AccountId 
								FROM User 
								WHERE Id=: Userinfo.getUserId() limit 1])
			{
				userAccountId = objUser.Contact.AccountId;
			}
		}	
		//}
		//else if(ApexPages.currentPage().getParameters().containsKey('claimNumber'))
		//{
			String strClaimNumber = ApexPages.currentPage().getParameters().get('url');
			if(strClaimNumber != null && strClaimNumber != '') 
			{
				List<Claim__c> lstClaim = new List<Claim__c>([Select Id, Claim_Number__c, Member__c From Claim__c Where Claim_Number__c = :strClaimNumber]);
				if(!lstClaim.isEmpty()) 
				{
					userAccountId = lstClaim[0].Member__c;
				}
				else
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Parameter'));
					isError = true;
					return null;
				}
			}
			else
			{
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Parameter');
				ApexPages.addMessage(msg);
				isError = true;
				return null;
			}
		//}
		
		for(User objClaimUser : [SELECT Id,ContactId,User_s_Email__c FROM User WHERE IsActive = true AND Default_Claims_User__c = true limit 1])
		{
			system.debug('----objClaimUser---->'+objClaimUser);
			idDefaultClaimUser = objClaimUser.Id;
			strDefltClaimUserEmailAddr = objClaimUser.User_s_Email__c;
		}
		/* Start - Contact info for email and phone*/
		isPhoneSpecified = false;
		isEmailSpecified = false;
		isMemberEmail = false;
		isMemberPhone = false;
		for(Contact_Info__c objContInfo : [SELECT Id,Email__c,Phone__c,Type__c,Is_Primary__c FROM Contact_Info__c WHERE Account__c =: userAccountId and Type__c IN ('Email','Phone-Home', 'Phone-Work', 'Phone-Mobile') ])
		{
			system.debug('----objContInfo---->'+objContInfo);
			if(objContInfo.Phone__c != null && !isPhoneSpecified)
				isPhoneSpecified = true;
			if(objContInfo.Email__c != null && !isEmailSpecified)
				isEmailSpecified = true;
			lstContInfo.add(new contactInfoWrapper(objContInfo.Email__c,objContInfo.Phone__c,objContInfo.Is_Primary__C,objContInfo.Type__c));
		}
		/* End - Contact info for email and phone*/
		
		/* Added regarding PURE-63 */
		String strQuery = 'SELECT Name, Member_Key_EDW__c, Phone, Primary_Email__c';
		List<Account> lstAccount = new List<Account>();
		
		String strMember = 'Member';
		
		if(!String.isEmpty(strBrocker) && strBrocker != '')
		{
			strQuery += ' FROM Account WHERE Id=' + '\'' + userAccountId +'\' AND ' + strBrocker + ' AND RecordType.Name =: strMember LIMIT 1';
			lstAccount = Database.query(strQuery);
			
			if(lstAccount.isEmpty() || lstAccount == null )
			{
				PageReference pageRef = new PageReference('/Exception');
				return pageRef;
			}
		}
		else
		{
			strQuery +=	' FROM Account WHERE Id=' + '\'' + userAccountId +'\' LIMIT 1';
			lstAccount = Database.query(strQuery);
		}
		
		// setting the Member Id
		if(!lstAccount.isEmpty())
		{
			for(Account objAccount :lstAccount)
			{
				memberNumber = objAccount.Member_Key_EDW__c;
				memberName = objAccount.Name;
				if(objAccount.Phone != null)
				{
					if(isPhoneSpecified == false)
						isMemberPhone = true;
					isPhoneSpecified = true;
					MemberPhone = objAccount.Phone;
				}
				if(objAccount.Primary_Email__c != null)
				{
					if(isEmailSpecified == false)
						isMemberEmail = true;
					isEmailSpecified = true;
					MemberEmail = objAccount.Primary_Email__c;
				}	
			}
		}	
		/* Start - Your active policy section */
		// As per the claim comment we are showing the member related 
		/*
		set<string> policyNumber = new set<string>();
		for(Policy__c objPolicy : [SELECT Id, Policy_Number__c, Policy_Status__c, Policy_Term_Dates__c, Effective_Date__c, Expiration_Date__c, Description__c, Line_of_Business__c 
									FROM Policy__c 
									WHERE Member__c = :userAccountId])
		{
			policyNumber.add(objPolicy.Policy_Number__c);
		}		
		*/
		/* End - Your active policy section */
		
		/* Start- Open/Close claim section */
		
		//Prepare a list of open and closed claims to display them on page	
		for(Claim__c objClaim : [Select Id, RecordType.Name, Claim_Number__c,LPA_Eligible__c, 	Total_Paid__c, Date_of_Loss__c, Claim_Status__c, CanShowDetails__c,  Line_of_Business__c, Member__r.Name, Description__c,
									 	Adjustor__c, Claim_Adjustor_Name_Calc__c, Claim_Adjustor_Email_Calc__c, Claim_Adjustor_Phone_Calc__c, 
									 	Member_Advocate__c, Claim_Mem_Advocate_Name_Calc__c, Claim_Mem_Advocate_Email_Calc__c,  Claim_Mem_Advocate_Phone_Calc__c,Loss_Location__c	   
								 from Claim__c 
								 where Member__c =: userAccountId 
								 order by Date_of_Loss__c])
		{	
			if(objClaim.Claim_Number__c == selectedClaimNumber)
			{
				objSelectedClaim = new Sl_ClaimsWrapper(objClaim.Line_of_Business__c,objClaim.Claim_Number__c,objClaim.Total_Paid__c,objClaim.Description__c,
														objClaim.Date_of_Loss__c,objClaim.CanShowDetails__c,objClaim.Claim_Status__c,
														objClaim.Description__c, objClaim.Adjustor__c, objClaim.Claim_Adjustor_Name_Calc__c, objClaim.Claim_Adjustor_Email_Calc__c, objClaim.Claim_Adjustor_Phone_Calc__c, 
														objClaim.Member_Advocate__c, objClaim.Claim_Mem_Advocate_Name_Calc__c, objClaim.Claim_Mem_Advocate_Email_Calc__c, objClaim.Claim_Mem_Advocate_Phone_Calc__c, objClaim.LPA_Eligible__c); 
				claimId = objClaim.Id;
				
				if(objClaim.Claim_Mem_Advocate_Email_Calc__c != null || objClaim.Claim_Mem_Advocate_Name_Calc__c != null || objClaim.Claim_Mem_Advocate_Phone_Calc__c != null )
				{
					isAdvocate = true;
					isAdjAsMemberAdvocate = true;
				}
					
					
				if(objClaim.Adjustor__c != null && objClaim.Member_Advocate__c != null && objClaim.Adjustor__c == objClaim.Member_Advocate__c) 
					isAdjAsMemberAdvocate = false; 
					
				if(objClaim.Claim_Adjustor_Name_Calc__c != null || objClaim.Claim_Adjustor_Email_Calc__c != null || objClaim.Claim_Adjustor_Phone_Calc__c != null)	
					isClaimAdjsutorDisplayed = true;
				
			}
			
			
			if(objClaim.Claim_Status__c != null)
				objClaim.Claim_Status__c = objClaim.Claim_Status__c.trim().toLowerCase();
			
			if(objClaim.Claim_Status__c == 'in progress' && objClaim.Claim_Number__c != selectedClaimNumber)
			{
				if(objClaim.CanShowDetails__c)
				{
					lstOpenClaims.add(new Sl_ClaimsWrapper(objClaim.Line_of_Business__c,objClaim.Claim_Number__c,objClaim.Total_Paid__c,(objClaim.Loss_Location__c == null? objClaim.Claim_Number__c: objClaim.Loss_Location__c ),
														objClaim.Date_of_Loss__c,objClaim.CanShowDetails__c,objClaim.Claim_Status__c,
														objClaim.Description__c, objClaim.Adjustor__c, objClaim.Claim_Adjustor_Name_Calc__c, objClaim.Claim_Adjustor_Email_Calc__c, objClaim.Claim_Adjustor_Phone_Calc__c, 
														objClaim.Member_Advocate__c, objClaim.Claim_Mem_Advocate_Name_Calc__c, objClaim.Claim_Mem_Advocate_Email_Calc__c, objClaim.Claim_Mem_Advocate_Phone_Calc__c	, objClaim.LPA_Eligible__c));
				}										
			}
			
		}
		
		
		system.debug('========lstOpenClaims========' + lstOpenClaims);
		
		if(objSelectedClaim != null)
		{
			String[] strAdjMemAdv = new String[]{objSelectedClaim.Adjustor,  objSelectedClaim.MemAdvocate};
			defaultAdjustorImage = false;
			defaultMemberImage = false;
			//	Block that fetches Photos of Claim Adjustor and Member Advocates
			for(Portal_Image__c objPortalImage : [Select Id, Image__c, Broker__c, Static_Resource_Image_Path__c, Static_Resource_Path__c, 
														 Use_Photo_Field__c, User__c, User__r.Name, User__r.User_s_Email__c  
												  From Portal_Image__c 
												  Where User__c IN : strAdjMemAdv
												  		])
			{
				
				system.debug('---------3---------------');
				if(objSelectedClaim.Adjustor != null && objPortalImage.User__c == objSelectedClaim.Adjustor)
				{
					isDefaultForAdjuster = false;
					system.debug('---------4--------------');
					AdjsterName = objPortalImage.User__r.name;
					
					if(objPortalImage.Use_Photo_Field__c == true) {
						if(objPortalImage.Image__c != null)
							AdjsterPhoto = objPortalImage.Image__c;
						else
							defaultAdjustorImage = false;
					}
					else {
						
						if(objPortalImage.Static_Resource_Image_Path__c != null) {
							AdjsterPhoto = objPortalImage.Static_Resource_Image_Path__c;
							defaultAdjustorImage = true;
						}
						else
							defaultAdjustorImage = false;
							
					}
				}
				
				
				if(objSelectedClaim.MemAdvocate != null && objPortalImage.User__c == objSelectedClaim.MemAdvocate)
				{
					isDefaultForAdvocate = false;
					system.debug('--------5--------------');
					MemberAdvocateName = objPortalImage.User__r.name;
					
					if(objPortalImage.Use_Photo_Field__c == true) {
						if(objPortalImage.Image__c != null)
							MemberAdvocatePhoto = objPortalImage.Image__c;
						else
							defaultMemberImage = false;
					}
					else {
						if(objPortalImage.Static_Resource_Image_Path__c != null) {
							MemberAdvocatePhoto = objPortalImage.Static_Resource_Image_Path__c;
							defaultMemberImage = true;
						}
						else
							defaultMemberImage = false;
							
					}
				}
				
				
				/*if(objPortalImage.User__c == objSelectedClaim.Adjustor)
				{
					AdjsterName = objPortalImage.User__r.name;
					AdjsterPhoto = objPortalImage.Image__c;
					if(objPortalImage.Image__c == null)
					{
						AdjsterPhoto = objPortalImage.Static_Resource_Image_Path__c;
						defaultAdjustorImage = true;
					}
					AdjsterEmail = objPortalImage.User__r.User_s_Email__c;
				}
				else if(objPortalImage.User__c == objSelectedClaim.MemAdvocate)
				{
					MemberAdvocateName = objPortalImage.User__r.name;
					MemberAdvocatePhoto = objPortalImage.Image__c;
					if(objPortalImage.Image__c == null)
					{
						MemberAdvocatePhoto = objPortalImage.Static_Resource_Image_Path__c;
						defaultMemberImage = true;
					}
					MemberAdvocateEmail = objPortalImage.User__r.User_s_Email__c;
				} */
			}
			
			Integer i = 1;
			for(Vendors_Involved__c objVendorInv : [Select Id, Role__c, DoNotShow__c,Phone__c, Email__c, Company__c from Vendors_Involved__c where Claim__r.Claim_Number__c =: selectedClaimNumber AND 	DoNotShow__c =:false])
			{
				lstVendorsInvolved.add(new vendorsInvolved(objVendorInv.Role__c,objVendorInv.Company__c,objVendorInv.Phone__c,objVendorInv.Email__c, i++));
			}
			i = 1;
			for(Claim_Activity__c objActivity : [Select Id, Date__c, Type__c, Short_Description__c, Full_Description__c from Claim_Activity__c where Claim__r.Claim_Number__c =: selectedClaimNumber AND DoNotShow__c =:false order by  Date__c desc])
			{
				lstClaimActivity.add(new claimActivityHistory(objActivity.date__c,objActivity.Type__c,objActivity.Short_Description__c,objActivity.Full_Description__c, i++, objActivity.Full_Description__c != null ? (objActivity.Full_Description__c.length() > 55 ? true : false) : false));
			} 
			i = 1;
			for(Claim_Payment__c objPayment : [Select Id, Date__c, Check_Number__c, Paid_To__c, Amount_Paid__c,Status__c from Claim_Payment__c where claim__r.Claim_Number__c =: selectedClaimNumber AND DoNotShow__c =: false])
			{
				lstClaimPayment.add(new claimPaymentHistory(objPayment.Date__c,objPayment.Paid_To__c,objPayment.Check_Number__c,objPayment.Amount_Paid__c,objPayment.Status__c, i++));
			}
		}	
		/* End - Open/Close claim section */
		
		return null;
	}
	 
	public pageReference selectedClaimDetails()
	{
		PageReference claimDetailsPage;
		if(strProfileName == 'PURE Customer Community Login User'){
			claimDetailsPage = new PageReference('/ClaimDetails?url='+selectedClaimNumber);
		} else {
			String memberId = Apexpages.currentPage().getParameters().get('mId');
			claimDetailsPage = new PageReference('/BrokerView/ClaimDetails?url='+selectedClaimNumber+'&mId='+memberId);
		}
		claimDetailsPage.setRedirect(true);
		return claimDetailsPage;
	}
		    
	// create a chatter Feed Item for this claim
	public PageReference submitPreference()
    {
        try
        {
			string communityId = ConnectApi.Communities.getCommunities().communities[0].id; // '0DBJ00000004CCbOAM'
			
			if(!string.isBlank(communityId))
			{	       
				if(strMemAdvOrAdjUser == 'cliamAdjuster')
				{
					if(!string.isBlank(objSelectedClaim.Adjustor))
					{
						postPrivateMessageInChatter(Id.valueOf(objSelectedClaim.Adjustor));
					}
					
					else if(!string.isBlank(objSelectedClaim.AdjustorEmail))
					{
						sendEmailToEmailAddressOrDefaultClaimUser(string.valueOf(objSelectedClaim.AdjustorEmail));
					}
					
					else
					{
						sendEmailToEmailAddressOrDefaultClaimUser(strDefltClaimUserEmailAddr);
					}
				}	
				
				if(strMemAdvOrAdjUser == 'cliamMemAdvicer')
				{
					if(!string.isBlank(objSelectedClaim.MemAdvocate))
					{
						postPrivateMessageInChatter(objSelectedClaim.MemAdvocate);
					}	
					
					else if(!string.isBlank(objSelectedClaim.MemAdvocateEmail))
					{
						sendEmailToEmailAddressOrDefaultClaimUser(objSelectedClaim.MemAdvocateEmail);
					}
					
					else
					{
						sendEmailToEmailAddressOrDefaultClaimUser(strDefltClaimUserEmailAddr);
					}
				}
			}
        }
        catch(Exception ee)
        {
        	isSuccess = 'false';
        	system.debug('--ee msg-->'+ee.getMessage());
        }
        
        isSuccess = 'true';
        
        PageReference claimDetailsPage = new PageReference('/ClaimDetails?url='+ selectedClaimNumber + '&isSuccess=' + isSuccess);
		claimDetailsPage.setRedirect(true);
		return claimDetailsPage;
    }
    
    private void postPrivateMessageInChatter(Id idAdjOrMemAdvUser)
    {
    	//try
    	{
	        string feedItemBody = ''; 
			string communityId = ConnectApi.Communities.getCommunities().communities[0].id; // '0DBJ00000004CCbOAM'
			system.debug('----communityId------>'+communityId);
			
			if(communityId != null || communityId != '')
			{	        
		        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
		        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
		            
		        ConnectApi.TextSegmentInput textSegment;
		        ConnectApi.MentionSegmentInput mentionSegment;
		        String subjectId = UserInfo.getUserId();
		        
	            textSegment = new ConnectApi.TextSegmentInput();
	            mentionSegment = new ConnectApi.MentionSegmentInput();
	            
	            //Member Portal – {!memberName}, {!MemberEDWID} - Question for Claim {!claimNumber}
	            
	            textSegment.text = 'Member Name: ' + memberName +  ' \n ' + 'Member Id: ' + memberNumber + ' \n ' + 'Question for Claim: ' + selectedClaimNumber + ' \n ' + 'User Selected Communication Preference: ' + commPreferences + ' \n ' + 'User Question :' + strChatterMessage + ' \n ';
	            
	            
	           // textSegment.text = commPreferences +' \n '+'Member Portal '+ selectedClaimNumber +', '+ memberName +' : '+ strChatterMessage +'\n'; 
	            
	            messageInput.messageSegments.add(textSegment);
	            
	            mentionSegment.id = idAdjOrMemAdvUser;
	            messageInput.messageSegments.add(mentionSegment);
	           
		        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
		        input.body = messageInput;
				system.debug('----input------>'+input);
				ConnectApi.BinaryInput feedBinary ; 
				system.debug('----isFileSelected------>'+isFileSelected);
				
	        	/* File attachment*/    
	            if(isFileSelected)
				{
		            ConnectApi.NewFileAttachmentInput fileIn = new ConnectApi.NewFileAttachmentInput();
		           	system.debug('----fileIn------>'+fileIn);
		            fileIn.title = strFileName; 
		            fileIn.description = '';
		            
		            input.attachment = fileIn;
		            system.debug('----attachmentBody------>'+attachmentBody);
		            feedBinary = new ConnectApi.BinaryInput(attachmentBody, strContentType, strFileName);
		            system.debug('----feedBinary------>'+feedBinary);
				}
				
	            //ConnectApi.FeedType typeFeed = ConnectApi.FeedType.Record;  
	            ConnectApi.FeedType typeFeed = ConnectApi.FeedType.UserProfile;
	            
	            system.debug('========typeFeed=========' + typeFeed);
	            system.debug('======idAdjOrMemAdvUser=======' + idAdjOrMemAdvUser);
	            
	            
		        ConnectApi.ChatterFeeds.postFeedItem(communityId, ConnectApi.FeedType.UserProfile, idAdjOrMemAdvUser , input, ((isFileSelected)?feedBinary:null));
		        
		        attachmentBody = NULL;
		        isSuccess = 'true'; 
			}
    	}
    	
    	//catch(Exception ee)
        {
        	//isSuccess = 'false';
        	//system.debug('--ee msg-->'+ee.getMessage());
        }
    }
    
    // Method used to send Email onclick of submit in Adjustor and MemAdvocate sections if there is no adjustor lookup or member advocate lookup
    private void sendEmailToEmailAddressOrDefaultClaimUser(String strAdjOrMemAdvEmailAddr)
    {
    	try 
    	{  
    		if(!string.isBlank(commPreferences) || !string.isBlank(strChatterMessage) || isFileSelected)
    		{
    			
    			EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = 'Claim_Details_Adjustor_or_Advocate_Section'];
    			
    			if(emailTemplate != null)
    			{
    				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    				String[] toAddresses = new String[] {strAdjOrMemAdvEmailAddr}; 
				    email.setToAddresses(toAddresses);  
    				
    				String htmlBody = emailTemplate.HtmlValue;
		            String plainBody = emailTemplate.Body ;
		            String subject = emailTemplate.Subject;
		            
		            subject = subject.replace('{!memberName}', memberName);
				    subject = subject.replace('{!MemberEDWID}',memberNumber);
				    subject = subject.replace('{!claimNumber}',selectedClaimNumber);
    				email.setSubject(subject);
    				
    				htmlBody = htmlBody.replace('{!Account.Name}', memberName);
    				htmlBody = htmlBody.replace('COMM_PREF_TEXT_PLACEHOLDER', commPreferences);
    				htmlBody = htmlBody.replace('QUESTION_TEXT_PLACEHOLDER', strChatterMessage);
    				
    				email.setHtmlBody(htmlBody);
    				
    				plainBody = plainBody.replace('{!Account.Name}', memberName);
    				plainBody = plainBody.replace('COMM_PREF_TEXT_PLACEHOLDER', commPreferences.stripHtmlTags());
				    plainBody = plainBody.replace('QUESTION_TEXT_PLACEHOLDER', strChatterMessage.stripHtmlTags());
				    
				    email.setPlainTextBody(plainBody);
				    
				    if(isFileSelected)
		        	{
				        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
				        efa.setFileName(strFileName);
				        efa.setBody(attachmentBody);
				        
				        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
		            }
		            
		 		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    				 
    			}
    		}	
    		isSuccess = 'true';
	 	} 
	 	
	 	catch(Exception e) 
	 	{
	 		isSuccess = 'false';
	 		system.debug('--exception-->'+e.getMessage());
	 	}  
    }
}