public with sharing class SL_ctrl_VendorProfile {
	
	public Profile userProfile {get;set;}	
	public Boolean canEdit {get;set;}
	public Boolean hasPhoto {get;set;}
	public String secondaryColor {get;set;}
	public String buttonColor {get;set;}
	public String buttonFontColor {get;set;}
	public String buttonHoverColor {get;set;}
	public String buttonHoverFontColor {get;set;}
	public String font {get;set;}
	public String siteName {get;set;}
	public transient Blob blobValue {get;set;}
	public transient String contentType {get;set;}
	public transient String filename {get;set;}
	public String newPhotoUrl {get;set;}
	private String userId;
	private User user;
	private CollaborationGroupMember cGroupMember;

	public SL_ctrl_VendorProfile() {
		init();		
	}

	/*
	 * Set up values for the page
	 * Call getUserProfile, isEditable
	 *
	 */
	private void init(){
		this.siteName = Site.getPathPrefix();
		setPortalBranding();
		userId = ApexPages.currentPage().getParameters().get('u');
		if(userId != null && userId.substring(0, 3) == '005'){
			userProfile = getUserProfile();
			newPhotoUrl = ApexPages.currentPage().getParameters().get('newPhoto');
			this.hasPhoto = true;
			if(userProfile.photoUrl == Site.getPathPrefix() + '/profilephoto/005/F' && newPhotoUrl == null){
				this.hasPhoto = false;
			}
			canEdit = isEditable();
			if(newPhotoUrl != null){
				userProfile.photoUrl = newPhotoUrl;
			}
		}else{
			throw new SL_CustomException('No User Id was provided in the URL');
		}
	}

	/*
	 * Get Portal Branding object, set branding
	 *
	 */
	private void setPortalBranding(){
		SL_util_VendorCommunity.PortalBrandingWrapper branding = SL_util_VendorCommunity.getPortalBranding();
		secondaryColor = branding.headerBackgroundColor;
		buttonColor = branding.inactiveNavColor;
		buttonFontColor = branding.inactiveNavFontColor;
		buttonHoverColor = branding.hoverNavColor;
		buttonHoverFontColor = branding.hoverNavFontColor;
		font = branding.font;
	}

	/*
	 * Get the user id from the url parameter with key 'u'
	 * Use the user id to select user information and the user's chatter group member
	 * Instantiate a profile object with the info retrieved and set the userProfile property
	 *
	 */
	private Profile getUserProfile(){
		user = [SELECT Id, AboutMe, City, CommunityNickname, Country, Email, Fax, FirstName, 
						 FullPhotoUrl, LastName, MobilePhone, Phone, PostalCode, State, Street, Title 
				FROM User 
				WHERE Id = : userId];
	    cGroupMember = [SELECT NotificationFrequency 
	    				FROM CollaborationGroupMember 
	    				WHERE MemberId = : userId
	    				AND CollaborationGroupId = : SL_util_VendorCommunity.getChatterGroupId()];

		return new Profile(user, cGroupMember);
	}

	/*
	 * Check if the current user is looking at their own profile page or 
	 * if the current user is an admin. In either case, return true, else return false
	 *
	 */
	private Boolean isEditable(){
		if(UserInfo.getUserId() == Id.valueOf(userId) || 
			([SELECT Name FROM Profile WHERE Id = : UserInfo.getProfileId()]).Name == 'System Administrator'){
			return true;
		} 
		return false;
	}

	/*
	 * Update the user's profile
	 *
	 */
	@remoteAction
	public static void updateProfile(Map<String, String> fieldsToValue){
		User user = [SELECT Id, AboutMe, City, CommunityNickname, Country, Email, Fax, FirstName, 
						 FullPhotoUrl, LastName, MobilePhone, Phone, PostalCode, State, Street, Title 
				  FROM User 
				  WHERE Id = : fieldsToValue.get('id')];
	    CollaborationGroupMember cGroupMember = [SELECT NotificationFrequency 
	    										FROM CollaborationGroupMember 
	    										WHERE MemberId = : fieldsToValue.get('id')];
		System.debug(LoggingLevel.ERROR, fieldsToValue);
		user.FirstName = fieldsToValue.get('firstName');
		user.LastName = fieldsToValue.get('lastName');
		user.Title = fieldsToValue.get('title');
		user.CommunityNickname = fieldsToValue.get('nickname');
		user.AboutMe = fieldsToValue.get('aboutMe');
		user.Street = fieldsToValue.get('street');
		user.City = fieldsToValue.get('city');
		user.State = fieldsToValue.get('state');
		user.Country = fieldsToValue.get('country');
		user.PostalCode = fieldsToValue.get('zip');
		user.Email = fieldsToValue.get('email');
		user.Fax = fieldsToValue.get('fax');
		user.MobilePhone = fieldsToValue.get('mobile');
		user.Phone = fieldsToValue.get('workPhone');

		cGroupMember.NotificationFrequency = fieldsToValue.get('notificationFreq');

		update user;
		update cGroupMember;
	}

	/*
	 * Update the users's chatter photo
	 *
	 */
	public PageReference uploadPhoto(){
		ConnectApi.BinaryInput photoFileInput =
            new ConnectApi.BinaryInput(blobValue, contentType, filename);
        
        ConnectApi.Photo newPhoto = ConnectApi.ChatterUsers.setPhoto(
        	Network.getNetworkId(), userId, photoFileInput);

        PageReference pageRef = new PageReference(siteName + '/SL_VendorProfile?u=' + userId + '&newPhoto=' + newPhoto.largePhotoUrl);
		pageRef.setRedirect(true);

		return pageRef;
	}

	/*
	 * Delete the users's current chatter photo
	 *
	 */
	public PageReference deletePhoto(){
		ConnectApi.ChatterUsers.deletePhoto(Network.getNetworkId(), userId);
		PageReference pageRef = new PageReference(siteName + '/SL_VendorProfile?u=' + userId);
		pageRef.setRedirect(true);
		return pageRef;
	}

	/*
	 * Wrapper class for all user profile information
	 *
	 */
	public class Profile{

		public String firstName {get;set;}
		public String lastName {get;set;}
		public String title {get;set;}
		public String nickname {get;set;}
		public String aboutMe {get;set;}
		public String street {get;set;}
		public String city {get;set;}
		public String state {get;set;}
		public String country {get;set;}
		public String zip {get;set;}
		public String email {get;set;}
		public String fax {get;set;}
		public String mobile {get;set;}
		public String workPhone {get;set;}
		public String photoUrl {get;set;}
		public String notificationFreq {get;set;}

		public Profile(User u, CollaborationGroupMember m){
			firstName = u.FirstName;
			lastName = u.LastName;
			title = u.Title;
			nickname = u.CommunityNickname;
			aboutMe = u.AboutMe;
			street = u.Street;
			city = u.City;
			state = u.State;
			country = u.Country;
			zip = u.PostalCode;
			email = u.Email;
			fax = u.Fax;
			mobile = u.MobilePhone;
			workPhone = u.Phone;
			photoUrl = u.FullPhotoUrl;
			if(m != null){			
				if(m.NotificationFrequency == 'D'){
					notificationFreq ='Daily';
				}else if(m.NotificationFrequency == 'W'){
					notificationFreq = 'Weekly';
				}else if(m.NotificationFrequency == 'N'){
					notificationFreq = 'Never';
				}else{
					notificationFreq = 'On Each Post';
				}
			}
		}

	} 
}