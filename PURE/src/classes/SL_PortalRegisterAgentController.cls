/*
*  PageName       : SL_PoratalRegisterAgentController
*  CreatedOn      : 12/23/2014
*  ModifiedBy     : Kyle Lawson
*  Description    : A custom registration page for allow the member to register for portal access.  
*/
public with sharing class SL_PortalRegisterAgentController 
{
	// User entered details
	public String brokerId {get; set{brokerId = value == null ? value : value.trim(); } }
	public String dragonUserID {get; set{dragonUserID = value == null ? value : value.trim(); } }
	public String email {get; set{email = value == null ? value : value.trim(); } }
	public String password {get; set {password = value == null ? value : value.trim(); } }
	public String errorMessage {get; set;}
	public String pureTermsLinks {get;set;}

	private String formattedUsername {get;set;}
	
	// Constructor 
	public SL_PortalRegisterAgentController()
	{
		pureTermsLinks = '';
		PortalURLMap__c oPureTerms = new PortalURLMap__c();
		oPureTerms = PortalURLMap__c.getInstance('PureTerms');
		pureTermsLinks = (oPureTerms != null) ? oPureTerms.URL__c : '#';
		password = '';	
	}
	
	public Pagereference register()
	{
		system.debug('--------------- email: ' + email + ' --- brokerId: ' + brokerId + ' dragonUserId: ' + dragonUserId);
		errorMessage = '';
		
		// first look for an Agency Contact that has the input email, broker ID, and Dragon Id.
		List<Agency_Contact__c> agencyContact = [SELECT Id, Contact__r.Id, Contact__r.Email,
														Contact__r.FirstName, Contact__r.LastName, 
														Agency__r.Broker_ID__c, DragonID__c
							 					 FROM Agency_Contact__c
							 					 WHERE Contact__r.Email = :email 
							 					 		AND Agency__r.Broker_ID__c = :brokerId 
							 					 		AND DragonID__c = :dragonUserId
							 					 		AND User_Status__c = 'Active'
							 					 		AND (Agency__r.Broker_Status__c = 'Active'
							 					 			OR Agency__r.Broker_Status__c = 'Suspended With Access')
							 					 LIMIT 1];
							
		if(!agencyContact.isEmpty())
		{

			List<User> u = [SELECT Id, Username, ContactId
							FROM User
							WHERE Username = :email OR ContactId = :agencyContact[0].Contact__r.Id
							LIMIT 1];
			if(u.isEmpty()){
				String contactFirstName = agencyContact[0].Contact__r.FirstName;
				String contactLastName = agencyContact[0].Contact__r.LastName;
				String communityNickname = (contactFirstName !=null ? contactFirstName.mid(0,1):'') + 
											contactLastName.mid(0,5) + 
											agencyContact[0].Agency__r.Broker_ID__c;

				formattedUsername = email.replace('@','.') + '@brokerview.pureinsurance.com';
				System.debug('---- formattedUsername: ' + formattedUsername);

				String createUserSuccess = createPortalUser(agencyContact[0].Contact__r, agencyContact[0].Id, communityNickname);

				if (createUserSuccess == '') { 
						return Site.login(formattedUsername, password, '/BrokerHomePage?isRegistered=true');
				}
				else
				{
					errorMessage = createUserSuccess;
				}
			} else {

				if(u[0].Username == formattedUsername)
					errorMessage = 'A user already exists for that email address.';
				else
					errorMessage = 'A user already exists for your contact. Please contact PURE.';
			}
		}
		else
		{
			errorMessage = 'Unable to find the given IDs and email combination on any active agencies in our system.';
		}
		return null;
	}

	public String createPortalUser(Contact agentContact, Id acctId, String communityNickname){
		User newUser = new User();
		newUser.Alias = agentContact.firstName.mid(0,1) + agentContact.lastName.mid(0,6);
		newUser.CommunityNickname = communityNickname;
		newUser.ContactId = agentContact.Id;
		newUser.DefaultGroupNotificationFrequency = 'N';
		newUser.DigestFrequency = 'N';
		newUser.Email = email;
		newUser.EmailEncodingKey = 'ISO-8859-1';
		newUser.FirstName = agentContact.FirstName;
		newUser.LanguageLocaleKey = 'en_US';
		newUser.LastName = agentContact.LastName;
		newUser.LocaleSidKey = 'en_US';

		List<Profile> brokerProfile = [SELECT Id 
									   FROM Profile 
									   WHERE Name = 'PURE Broker View Partner Login User' LIMIT 1];
		if(brokerProfile.size() == 0){
			newUser.ProfileId = '00eq0000000HjVU'; // Pure Broker View Partner Login User
		} else {
			newUser.ProfileId = brokerProfile[0].Id;
		}

		newUser.TimeZoneSidKey = 'GMT';
		newUser.UserPermissionsChatterAnswersUser = false;

		//Brokers use the Partner Community license so need to ensure that usernames are unique
		String updatedUsername = formattedUsername;
		newUser.Username = updatedUsername;

		try {
			insert newUser;
		} catch (DmlException e){
			System.debug('Failed to insert new user, received error message: ' + e.getMessage());
			errorMessage = 'There was a problem creating a new user: ' + e.getDmlMessage(0) + '. Please contact PURE.';
			return errorMessage;
		} catch (Exception e){
			System.debug('Failed to insert new user, received error message: ' + e.getMessage());
			errorMessage = 'There was a problem creating a new user: ' + e.getMessage() + '. Please contact PURE.';
			return errorMessage;
		}
		
		// Causes the user to be redirected to the change password screen on login, 
		// so they can change their password from the auto-generated salesforce password
		password = System.resetPassword(newUser.Id, false).getPassword();

		return errorMessage;
	}
}