global without sharing class SROCUtilities {

	public static Owner_Boat_Relationship__c queryOwnerBoatRelationship()
	{
		Owner_Boat_Relationship__c obr;
		
		User u = [SELECT Id, Contact.AccountId, Contact.Account.HIN_Number__c FROM User WHERE id = :UserInfo.getUserId() LIMIT 1];
		
		List<Owner_Boat_Relationship__c> obrList = [SELECT 
											Id, 
											Owner__c, 
											SROC_Selected_Boat_Image__c, 
											SROC_Boat_Name__c,
											Purchase_Date__c,
											HIN_Number__c, 
											HIN_Number__r.Name,
											HIN_Number__r.Model_Year__c,
											HIN_Number__r.Model_Description__c, 
											HIN_Number__r.Purchase_Date__c,
											HIN_Number__r.Boat_Model__c,
											HIN_Number__r.Boat_Class__c,
											Owner__r.PersonMailingPostalCode, 
											Owner__r.SROC_Preferred_Dealer__c, 
											Owner__r.SROC_Preferred_Dealer__r.ShippingStreet,
											Owner__r.SROC_Preferred_Dealer__r.ShippingCity, 
											Owner__r.SROC_Preferred_Dealer__r.ShippingState, 
											Owner__r.SROC_Preferred_Dealer__r.ShippingPostalCode,
											Owner__r.SROC_Preferred_Dealer__r.ShippingCountry, 
											Owner__r.SROC_Preferred_Dealer__r.Website, 
											Owner__r.SROC_Preferred_Dealer__r.Phone, 
											Owner__r.SROC_Preferred_Dealer__r.Dealer_1_Primary_Email__c, 
											Owner__r.SROC_Preferred_Dealer__r.Name,
											Owner__r.SROC_Preferred_Dealer__r.Sea_Ray_Boat_Categories__c
											FROM Owner_Boat_Relationship__c 
											WHERE Owner__c = :u.Contact.AccountId AND HIN_Number__r.Name = :u.Contact.Account.HIN_Number__c];
		
		if(obrList != null && obrList.size() > 0)
		{
			obr = obrList[0];
		}
		
		return obr;
	}
	
	public static List<Boat_Component__c> queryBoatEngineComponents(Id boatId) {
		
		List<Boat_Component__c> boatCompList;
		Id devRecordTypeId = Schema.SObjectType.Boat_Component__c.getRecordTypeInfosByName().get('Engine Record Type').getRecordTypeId();
		
		if(boatId != null && devRecordTypeId != null)
		{
			boatCompList = [SELECT Id, Name, Engine_Number__c FROM Boat_Component__c WHERE Boat__c = :boatId AND RecordTypeId = :devRecordTypeId];
		}
		
		return boatCompList;
		
	}
	
	public static Geocode_Data_Row__c postalCodeToGeocodeData(string postalCode) {
		
		if(String.isEmpty(postalCode))
		{
			return null;
		}
		
		Geocode_Data_Row__c gdr;
		
		List<Geocode_Data_Row__c> geocodeDataList = [SELECT Id, Name, Geocode__Latitude__s,Geocode__Longitude__s 
													FROM Geocode_Data_Row__c 
													WHERE Name = :postalCode OR Postal_Code__c = :postalCode];
		
		if(geocodeDataList != null && geocodeDataList.size() > 0)
		{
			gdr = geocodeDataList[0];
		}
		else
		{
			GeocodeService gs = new GeocodeService();
			
			try {
				gdr = gs.getGeocodeData(postalCode);
			    if(gdr != Null)
				    insert gdr;
				else 
				    return Null;
			}catch(Exception e) {
				System.debug('Error: ' + e);
				return null;
			}
			
		}
		
		return gdr;
		
	}
	
	public static ApexPages.StandardSetController queryDealersNear(String zipcode, Integer withinDistance) {
		
		ApexPages.StandardSetController setController;
		
		if(String.isEmpty(zipcode) || withinDistance == null)
		{
			return null;
		}
		
		Geocode_Data_Row__c gdr = SROCUtilities.postalCodeToGeocodeData(zipcode);
		
		if(gdr == null)
		{
			return null;
		}
		
		Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
		
		if(devRecordTypeId != null && devRecordTypeId+'' != '')
		{
			
			String QUERY = 'SELECT Id, Name, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Website, Dealer_1_Primary_Email__c,Sea_Ray_Boat_Categories__c, Phone FROM Account WHERE RecordTypeId = :devRecordTypeId AND Brand_Relationships__c LIKE \'SR\' ';
			QUERY += 'AND  (DISTANCE(GeoLocation__c, GEOLOCATION(' + gdr.Geocode__Latitude__s + ', ' + gdr.Geocode__Longitude__s + '), \'mi\') < :withinDistance)';
			QUERY += ' ORDER BY DISTANCE(GeoLocation__c, GEOLOCATION('+gdr.Geocode__Latitude__s+','+gdr.Geocode__Longitude__s+'), \'mi\') ASC LIMIT 12';
			System.debug('Dealer QUERY: '+QUERY);
			setController = new ApexPages.StandardSetController(Database.getQueryLocator(QUERY));
			
		}
		
		return setController;
		
	}
	
	public static Map<String,String> queryLinkIcons() {
		
		List<CORECONNECT__CC_Link_Icons__c> iconList = [SELECT Id, Name, CORECONNECT__Icon_Url__c FROM CORECONNECT__CC_Link_Icons__c];
		
		Map<String,String> linkIconsMap = new Map<String,String>();
		
		for(CORECONNECT__CC_Link_Icons__c icon: iconList)
		{
			linkIconsMap.put(icon.Name, icon.CORECONNECT__Icon_Url__c);
		}
		
		return linkIconsMap;
		
	}
	
	public static Boolean isOwner() {
		
		SROC_System_Settings__c setting = SROC_System_Settings__c.getInstance(Site.GetName());
		
		Id ownerCCU, ownerCCL;
		
		try {
			ownerCCU = (Id)setting.Owner_CCU_Profile_Id__c;
			ownerCCL = (Id)setting.Owner_CCL_Profile_Id__c;
		}catch(Exception e) {
			
		}
		
		if(SROCUtilities.isCCU())
		{
			if(ownerCCU == null)
			{
				return false;
			}
			else if (UserInfo.getProfileId() == ownerCCU)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			if(ownerCCL == null)
			{
				return false;
			}
			else if (UserInfo.getProfileId() == ownerCCL)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
	
	}
	
	public static Boolean isOwner(String userId) {
		
		SROC_System_Settings__c setting = SROC_System_Settings__c.getInstance(Site.GetName());
		
		User u;
		try {
			 u = [SELECT Id, ProfileId FROM USER WHERE Id = :userId LIMIT 1];
		} catch(Exception e) {
				
		}
		
		if(u == null)
		{
			return false;
		}
		
		Id ownerCCU, ownerCCL;
		
		try {
			ownerCCU = (Id)setting.Owner_CCU_Profile_Id__c;
			ownerCCL = (Id)setting.Owner_CCL_Profile_Id__c;
		}catch(Exception e) {
			
		}
		
		if(SROCUtilities.isCCU(userId))
		{
			if(ownerCCU == null)
			{
				return false;
			}
			else if (u.ProfileId == ownerCCU)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			if(ownerCCL == null)
			{
				return false;
			}
			else if (u.ProfileId == ownerCCL)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
	
	}
	
	public static Boolean isDealer() {
		
		SROC_System_Settings__c setting = SROC_System_Settings__c.getInstance(Site.GetName());
		
		Id dealerCCU, dealerCCL;
		
		try {
			dealerCCU = (Id)setting.Dealer_CCU_Profile_Id__c;
			dealerCCL = (Id)setting.Dealer_CCL_Profile_Id__c;
		}catch(Exception e) {
			
		}
		
		if(SROCUtilities.isCCU())
		{
			if(dealerCCU == null)
			{
				return false;
			}
			else if (UserInfo.getProfileId() == dealerCCU)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			if(dealerCCL == null)
			{
				return false;
			}
			else if (UserInfo.getProfileId() == dealerCCL)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
	
	}
	
	public static Boolean isDealer(String userId) {
		
		User u;
		try {
			 u = [SELECT Id, ProfileId FROM USER WHERE Id = :userId LIMIT 1];
		} catch(Exception e) {
				
		}
		
		if(u == null)
		{
			return false;
		}
		
		SROC_System_Settings__c setting = SROC_System_Settings__c.getInstance(Site.GetName());
		
		Id dealerCCU, dealerCCL;
		
		try {
			dealerCCU = (Id)setting.Dealer_CCU_Profile_Id__c;
			dealerCCL = (Id)setting.Dealer_CCL_Profile_Id__c;
		}catch(Exception e) {
			
		}
		
		if(SROCUtilities.isCCU(userId))
		{
			if(dealerCCU == null)
			{
				return false;
			}
			else if (u.ProfileId == dealerCCU)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			if(dealerCCL == null)
			{
				return false;
			}
			else if (u.ProfileId == dealerCCL)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
	
	}
	
	public static Boolean isCCU() {
		
		User u = [SELECT Id, ProfileId, Profile.UserLicense.LicenseDefinitionKey, Profile.UserLicense.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		
		if(u.Profile.UserLicense.LicenseDefinitionKey == 'PID_Customer_Community' || u.Profile.UserLicense.Name == 'Customer Community')
		{
			return true;
		}
		else
		{
			return false;
		}
		
	}
	
	public static Boolean isCCU(String userId) {
		
		User u;
		try {
			 u = [SELECT Id, ProfileId, Profile.UserLicense.LicenseDefinitionKey, Profile.UserLicense.Name FROM User WHERE Id = :userId LIMIT 1];
		} catch (Exception e) {
			
		}
		
		if(u == null)
		{
			return false;
		}
		
		if(u.Profile.UserLicense.LicenseDefinitionKey == 'PID_Customer_Community' || u.Profile.UserLicense.Name == 'Customer Community')
		{
			return true;
		}
		else
		{
			return false;
		}
		
	}
	
	public static Boolean isCCL() {
		
		User u = [SELECT Id, ProfileId, Profile.UserLicense.LicenseDefinitionKey, Profile.UserLicense.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		
		if(u.Profile.UserLicense.LicenseDefinitionKey == 'PID_Customer_Community_Login' || u.Profile.UserLicense.Name == 'Customer Community Login')
		{
			return true;
		}
		else
		{
			return false;
		}
		
	}
	
	public static Boolean isCCL(String userId) {
		
		User u;
		try {
			 u = [SELECT Id, ProfileId, Profile.UserLicense.LicenseDefinitionKey, Profile.UserLicense.Name FROM User WHERE Id = :userId LIMIT 1];
		} catch (Exception e) {
			
		}
		
		if(u == null)
		{
			return false;
		}
		
		if(u.Profile.UserLicense.LicenseDefinitionKey == 'PID_Customer_Community_Login' || u.Profile.UserLicense.Name == 'Customer Community Login')
		{
			return true;
		}
		else
		{
			return false;
		}
		
	}
	
	public static Map<String,String> createDescribeMap() {
		Map<String,String> describeMap = new Map<String,String>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Set<String> keySet = gd.keySet();
        for (String key : keySet) {
            Schema.SObjectType objectType = gd.get(key);
            if (key.endsWith('kav')) {
                describeMap.put(objectType.getDescribe().getKeyPrefix(), objectType.getDescribe().getName());
            }
        }
        
        return describeMap;
    }
    
    public static Map<String,String> createDescribeMapLabel() {
		Map<String,String> describeMapLabel = new Map<String,String>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Set<String> keySet = gd.keySet();
        for (String key : keySet) {
            Schema.SObjectType objectType = gd.get(key);
            if (key.endsWith('kav')) {
                describeMapLabel.put(objectType.getDescribe().getKeyPrefix(), objectType.getDescribe().getLabel());
            }
        }
        
        return describeMapLabel;
    }
	
	//Util method to get Article Type from article Id.
    public static String retrieveArticleType(String articleId) {
        Map<String,String> describeMap = SROCUtilities.createDescribeMap();
        String articlePrefix = articleId.substring(0,3);
        Set<String> keySet = describeMap.keySet();
        String articleType = null;
        for(String key: keySet) {
            if(articlePrefix.equalsIgnoreCase(key)) {
                articleType = describeMap.get(key);
                return articleType;
            }
        }
        return articleType;
    }
    
    public static String retrieveArticleTypeLabel(String articleId) {
    	Map<String,String> describeMapLabel = SROCUtilities.createDescribeMapLabel();
        String articlePrefix = articleId.substring(0,3);
        Set<String> keySet = describeMapLabel.keySet();
        String articleType = null;
        for(String key: keySet) {
            if(articlePrefix.equalsIgnoreCase(key)) {
                articleType = describeMapLabel.get(key);
                return articleType;
            }
        }
        return articleType;
    }
	
	public static Integer  countBookmarkItem(String articleId, String articleTitle) {
		
		if(articleId != null && articleTitle != null)
		{
			Id devRecordTypeId = Schema.SObjectType.CORECONNECT__CC_Personal_Item__c.getRecordTypeInfosByName().get('Support Documentation').getRecordTypeId();
			
			
			Integer countResult = [SELECT COUNT() FROM CORECONNECT__CC_Personal_Item__c WHERE RecordTypeId = :devRecordTypeId
															AND OwnerId = :UserInfo.getUserId()
															AND (Knowledge_Article_Id__c = :articleId OR CORECONNECT__My_Links_Title__c = :articleTitle)];
			return countResult;
		}
		else
		{
			return 0;
		}
		
	}
	
	public static void deleteContentDocuments(List<ContentDocument> cdList) {
		if(cdList != null && cdList.size() > 0)
		{
			delete cdList;
		}
	}
	
	webService static String bookmarkArticle(String articleId) {
		
		Id devRecordTypeId = Schema.SObjectType.CORECONNECT__CC_Personal_Item__c.getRecordTypeInfosByName().get('Support Documentation').getRecordTypeId();
				
        SObject article;
    	 
    	String articleType = SROCUtilities.retrieveArticleType(articleId);
		
		String articleTypeLabel = SROCUtilities.retrieveArticleTypeLabel(articleId);
		
		String QUERY = 'SELECT '; 
						QUERY += 'ArchivedById,';
						QUERY += 'ArchivedDate,';
						QUERY += 'ArticleNumber,';
						QUERY += 'ArticleType,';
						QUERY += 'Boat_Category__c,';
						QUERY += 'Brand__c,';
						QUERY += 'CreatedById,';
						QUERY += 'CreatedDate,';
						QUERY += 'Filename__c,';
						QUERY += 'File_Url__c,';
						QUERY += 'FirstPublishedDate,';
						QUERY += 'Id,';
						QUERY += 'IsDeleted,';
						QUERY += 'IsLatestVersion,';
						QUERY += 'IsVisibleInApp,';
						QUERY += 'IsVisibleInCsp,';
						QUERY += 'IsVisibleInPkb,';
						QUERY += 'IsVisibleInPrm,';
						QUERY += 'KnowledgeArticleId,';
						QUERY += 'Language,';
						QUERY += 'LastModifiedDate,';
						QUERY += 'LastModifiedById,';
						QUERY += 'LastPublishedDate,';
						QUERY += 'Manual_Type__c,';
						QUERY += 'Model_Description__c,';
						QUERY += 'Model__c,';
						QUERY += 'Other_Data__c,';
						QUERY += 'OwnerId,';
						QUERY += 'PublishStatus,';
						QUERY += 'SourceId,';
						QUERY += 'Summary,';
						QUERY += 'SystemModstamp,';
						QUERY += 'Title,';
						QUERY += 'UrlName,';
						QUERY += 'VersionNumber,';
						QUERY += 'Year__c';
		QUERY += ' FROM ' + articleType; 
		QUERY += ' WHERE knowledgeArticleId = \'' + articleId + '\' AND PublishStatus = \'online\' LIMIT 1';
		
		System.debug('KAV QUERY: ' + QUERY);
		
		
			try {
				
				article = Database.query(QUERY)[0];
				String fileurl = (String)article.get('File_Url__c');
				String articleTitle = (String)article.get('Title');
				
				if(SROCUtilities.countBookmarkItem(articleId, articleTitle) > 0)
				{
					return 'Already added to My Boat Page!';
				}
				
				CORECONNECT__CC_Personal_Item__c bookmarkItem = new CORECONNECT__CC_Personal_Item__c();
				bookmarkItem.CORECONNECT__My_Links_Title__c = articleTitle;
				bookmarkItem.CORECONNECT__My_Links_URL__c = Site.getBaseUrl() + '/SROC_Tech_ResourcesDetail?id=' + articleId;
				System.debug('bookmarkItem Link: '+bookmarkItem.CORECONNECT__My_Links_URL__c);
				bookmarkItem.Knowledge_Article_Id__c = articleId;
				bookmarkItem.CORECONNECT__Category__c = articleTypeLabel;
				bookmarkItem.RecordTypeId = devRecordTypeId;
			
				insert bookmarkItem;
				
				return 'Successfully added to My Boat Page!';
				
				
			} catch(QueryException qe) {
				return 'Error: Could not add to My Boat Page.';
			}
			
			
        
    }
    
    webService static Integer queryBookmarkItem(String articleId, String articleTitle) {
		return countBookmarkItem(articleId, articleTitle);
	}
	

}