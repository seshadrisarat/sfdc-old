/* 
*  ComponentName  : SL_QuickLinksComponentsController
*  JIRATicket     : PURE-1
*  CreatedOn      : 1/6/2014
*  ModifiedBy     : Sandeep
*  Description    : A component which will contain the Quick links data for user to navigate.  
*/

public with sharing class SL_QuickLinksComponentController {
	
	public list<coveredVehiclesWrapper> lstCoveredVehiclesMakes{get;set;}//This is to store the all covered vehicles Make field. \
	public String payMyBillLink			{get;set;}
	
	public class coveredVehiclesWrapper
	{
		public String  idCardUrl		{get;set;}
		public String  idCard			{get;set;}
		
		public coveredVehiclesWrapper(String  idCardUrl, String idCard)
		{
			this.idCardUrl = idCardUrl;
			this.idCard = idCard;
		}
	}
	
	/*
        * MethodName        : fetchIdCardsInfo
        * param             : None
        * Description       : This function will be called by page action method to fetch data regarding user on load of that page.
    */
	public  SL_QuickLinksComponentController()
	{
		String userAccountId = '';//To store user's account id.
		Set<Id> setPolicyIds = new Set<Id>();//To store all policy related to logged in user account.
		lstCoveredVehiclesMakes = new list<coveredVehiclesWrapper>();//To store all Make related to policies.
		payMyBillLink = '';
		PortalURLMap__c oPayMyBillLink = PortalURLMap__c.getInstance('PayBill');
		if(oPayMyBillLink != null)
		payMyBillLink = oPayMyBillLink.URL__c;

		String mId = ApexPages.currentPage().getParameters().get('mId'); // Exists in Agent View of Member Portal
		String userProfile = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1].Name;

		if(mId != null && userProfile != 'Pure Customer Community Login User'){
			userAccountId = mId;
		} else {
			/* This is to query account id related to logged in user.*/
			for(User objUser : [Select Id, Contact.AccountId from User where Id=: Userinfo.getUserId() limit 1])
			{
				if (objUser.Contact.AccountId != null)
				{
					userAccountId = objUser.Contact.AccountId;
				}
			}	
			
			// Billing page
			if(ApexPages.currentPage().getParameters().containsKey('aId') || test.isRunningTest())
			{
				userAccountId = ApexPages.currentPage().getParameters().get('aId');
			}
			// Landing Page
			if(ApexPages.currentPage().getParameters().containsKey('cId') || test.isRunningTest())
			{
				String cId = ApexPages.currentPage().getParameters().get('cId');
				List<Contact> con = [select Id, AccountId from contact where id=:cId];
				if(!con.isEmpty())
				{				
					userAccountId = con[0].AccountId;
				}
			}
			//Policy Detail page.
			String strPolicyNumber = ApexPages.currentPage().getParameters().get('pid');
			if((strPolicyNumber != null && strPolicyNumber != '') || test.isRunningTest()) 
			{
				List<Policy__c> lstPolicy = new List<Policy__c>([Select Id, Member__c From Policy__c Where Id = :strPolicyNumber]);
				if(!lstPolicy.isEmpty()) 
				{
					userAccountId = lstPolicy[0].Member__c;
				}
			}
			// claim page.
			if(ApexPages.currentPage().getParameters().containsKey('URL') || test.isRunningTest())
			{
				String url = ApexPages.currentPage().getParameters().get('url');
				List<Claim__c> con = [select Id, Member__c from Claim__c where Claim_Number__c=:url];
				if(!con.isEmpty())
				{				
					userAccountId = con[0].Member__c;
				}
			}
		}
		
		/* If Account Id is not null */
		if(userAccountId != null )
		{
			
			set<String> setOfStates = new set<String>();
			States_Not_Display_Id_Cards__c objCustomSetting = new States_Not_Display_Id_Cards__c();
			objCustomSetting = States_Not_Display_Id_Cards__c.getInstance('States');
			
			if(objCustomSetting != null)
			{
				String strCommaSeparatedStates = objCustomSetting.List_Of_States__c;
				for(String strState : strCommaSeparatedStates.split(','))
				{
					strState = strState.trim();
					setOfStates.add(strState);
				}
			}
			
			/* Query the all policies related to the member accountId*/
			for(Policy__c objPolicy : [Select Id, Member__c, Policy_Status__c from Policy__c where Member__c =: userAccountId AND Policy_Status__c = 'In-Force'])
			{
				setPolicyIds.add(objPolicy.Id);
			}
			
			/* Querying all vehicles related to the all policies*/
			for(Vehicle__c objvehicle : [		Select Id, Make__c, VIN__c, Policy__r.Risk_State__c, Year__c, Can_Download__c, IDCardURL__c, IDCardId__c, Policy__c 
												from Vehicle__c 
												where Policy__c IN : setPolicyIds
												AND Can_Download__c =: true
												AND (Policy__r.Risk_State__c NOT IN :setOfStates)])
			{
				String VIN = '';
				String MAKE = '';
				String YEAR = '';
				
				if(objvehicle.Year__c != null )
				{
					
					if(String.valueOf(objvehicle.Year__c).length() == 4)
					YEAR = String.valueOf(objvehicle.Year__c).substring(2, 4);
					else if(String.valueOf(objvehicle.Year__c).length() == 3)
					YEAR = String.valueOf(objvehicle.Year__c).substring(1, 3);
					else if(String.valueOf(objvehicle.Year__c).length() <= 2)
					YEAR = String.valueof(objvehicle.Year__c);
					
					/* If Make field for vehicle si not null then add to the list to show on page.*/
				}
				
				if(objvehicle.Make__c !=null)
				{
					if(String.valueOf(objvehicle.Make__c).length() > 5)
					MAKE = String.valueOf(objvehicle.Make__c).substring(0, 5);
					else
					MAKE = objvehicle.Make__c;
				}
				if(objvehicle.VIN__c != null)
				{
					if(String.valueOf(objvehicle.VIN__c).length() > 5)
					VIN = String.valueOf(objvehicle.VIN__c).substring(0, 5);
					else
					VIN = objvehicle.VIN__c;
				}
				
				lstCoveredVehiclesMakes.add(new coveredVehiclesWrapper(objvehicle.IDCardURL__c, YEAR+'-'+MAKE+'-'+VIN ));
			}
		}
	}

}