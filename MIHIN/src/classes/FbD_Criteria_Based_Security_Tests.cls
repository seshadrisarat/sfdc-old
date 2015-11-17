/*
*Class: FbD_Criteria_Based_Security_Tests
*Description: This test class is used to test the User Access on records that have been stored in SecurityTestConfig__c custom setting.
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@isTest(SEEALLDATA=TRUE)
private class FbD_Criteria_Based_Security_Tests {


	private static testmethod void Criteria_Based_Tests(){

		SecurityTestConfig__c[] config = SecurityTestConfig__c.getAll().values();

		Map<ID,SecurityTestConfig__c[]> userToRecords = New Map<ID,SecurityTestConfig__c[]>();
		Map<ID,SecurityTestConfig__c> recordToConfig = New Map<ID,SecurityTestConfig__c>();

		//system.assertEquals(false,config.isEmpty());

		for(SecurityTestConfig__c rec : config){
			if(userToRecords.containsKey(rec.User_ID__c))
				userToRecords.get(rec.User_ID__c).add(rec);
			else
				userToRecords.put(rec.User_ID__c,New SecurityTestConfig__c[]{rec});
		}

		system.assertEquals(true,userToRecords.size() < 100, 'A Maximum of 100 Users can be tested. There are: ' + userToRecords.size() + ' user configured' );


		for(ID userID : userToRecords.keySet()){
			recordToConfig.clear();
			ID[] recIDs = New ID[]{};

			for(SecurityTestConfig__c rec : userToRecords.get(userID)){
				system.assertEquals(false,recordToConfig.containsKey(rec.Record_ID_For_Test__c),'The record ID to Test: ' + 
					rec.Record_ID_For_Test__c + ' is defined more than once for the user ID: ' + userID);

				recordToConfig.put(rec.Record_ID_For_Test__c,rec);
			}

			recIDs.addAll(recordToConfig.keySet());

			system.assertEquals(true,recordToConfig.size() < 200,'A maximum of 200 records can be tested for a specified user. There were ' + recordToConfig.size() + ' records for the user ' + UserID);

			UserRecordAccess[] uras = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess, HasTransferAccess, MaxAccessLevel 
									FROM UserRecordAccess WHERE UserId = :userID AND RecordId IN :recIDs];

			//system.assertEquals(false,uras.isEmpty(),'No User Record Access record were returned');

			for(UserRecordAccess ura : uras){
				SecurityTestConfig__c security_record = recordToConfig.get(ura.RecordID);
				system.assertEquals(security_record.Max_Access_Level__c,ura.MaxAccessLevel, 'For the Security Configuration Record ' + recordToConfig.get(ura.RecordID).id + ' Max Access Level');
				system.assertEquals(security_record.Has_Read_Access__C,ura.HasReadAccess, 'For the Security Configuration Record ' + recordToConfig.get(ura.RecordID).id + ' Has Read Access');
				system.assertEquals(security_record.Has_Edit_Access__C,ura.HasEditAccess, 'For the Security Configuration Record ' + recordToConfig.get(ura.RecordID).id + ' Has Edit Access');
				system.assertEquals(security_record.Has_Delete_Access__C,ura.HasDeleteAccess, 'For the Security Configuration Record ' + recordToConfig.get(ura.RecordID).id + ' Has Delete Access');
				system.assertEquals(security_record.Has_Transfer_Access__C,ura.HasTransferAccess, 'For the Security Configuration Record ' + recordToConfig.get(ura.RecordID).id + ' Has Transfer Access');
			}

		}


	}


}