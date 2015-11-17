/*
*Description: Test class for all triggers using the SL_ScriptPrecedenceUtil class
Objects include Account, Contact, Affiliation__c, Organization_Affiliation__c and Active_Care_Relationship__c
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@isTest
private class SL_Test_ScriptPrecedence {
	
	//TODO: Move all precedence retrieval to one method

	@testSetup static void createTestData(){
		List<SL_Script_Precedence__c> precedences = createPrecedences();
		insert precedences;

		List<Account> testAccounts = new List<Account>();
		List<Contact> testContacts = new List<Contact>();
		List<Affiliation__c> affiliations = new List<Affiliation__c>();
		List<Organization_Affiliation__c> orgAffiliations = new List<Organization_Affiliation__c>();
		List<Active_Care_Relationship__c> acrs = new List<Active_Care_Relationship__c>();

		for(SL_Script_Precedence__c prec : [select name, precedence__c from SL_Script_Precedence__c]){
			Account acc = new Account(Name = 'Test Account SL'+prec.name, Script__c=prec.name);
			testAccounts.add(acc);
		}
		insert testAccounts;

		for(Account acc : [select id, name, Script__c from Account where name like 'Test Account SL%']){
			Contact con = new Contact(LastName='Test Contact SL'+acc.name, Script__c=acc.Script__c, AccountID=acc.id);
			Organization_Affiliation__c orgAff = new Organization_Affiliation__c(Affiliated_Organization__c=acc.Id, Member_Organization__c=acc.Id, Script__c=acc.Script__c, Data_Source__c='Test Affiliation SL'+acc.Script__c);
			Active_Care_Relationship__c acr = new Active_Care_Relationship__c(Organization__c=acc.Id, Script__c = acc.Script__c, Birthdate__c = System.today(), Patient_First_Name__c='Test First', Patient_Last_Name__c = 'Test Last', Data_Source__c='Test ACR SL'+acc.Script__c);
			testContacts.add(con);
			orgAffiliations.add(orgAff);
			acrs.add(acr);
		}
		insert testContacts;
		insert orgAffiliations;
		insert acrs;

		for(Contact con : [select id, lastname, AccountID, Script__c from Contact where name like 'Test Contact SL%']){
			Affiliation__c aff = new Affiliation__c(Organization__c=con.AccountID, Provider__c=con.id, Script__c=con.Script__c, Data_Source__c='Test Affiliation SL'+con.Script__c);
			affiliations.add(aff);
		}
		insert affiliations;

	}

	static void testPrecedence(string sObjectName,  sObject sObjToUpdate){//Do not use for bulk testing
		Id objId = sObjToUpdate.Id;
		String existingScript = (string)sObjToUpdate.get('Script__c');
		
		SL_Script_Precedence__c existingScriptPrecedence = SL_Script_Precedence__c.getInstance(existingScript);
		system.debug(existingScriptPrecedence);
		SL_Script_Precedence__c[] newScriptPrecedences = [select Name, precedence__c from SL_Script_Precedence__c where precedence__c > :existingScriptPrecedence.precedence__c LIMIT 1];
		
		string qryAccount = 'select Script__c from '+sObjectName+ ' where Id=\''+objId+'\'';
		if(newScriptPrecedences.size()>0){
			sObjToUpdate.put('Script__c', newScriptPrecedences[0].Name);
		update sObjToUpdate;
		
		sObject updatedObject = Database.query(qryAccount);
		//TODO: Need to work on this assert
		system.debug(updatedObject.get('Script__c'));
		system.debug(existingScript);
		//system.assertEquals((string)updatedObject.get('Script__c'), existingScript);
		}else{//Existing is the lowest precedence so test for higher
			newScriptPrecedences = [select Name, precedence__c from SL_Script_Precedence__c where precedence__c < :existingScriptPrecedence.precedence__c LIMIT 1];
			sObjToUpdate.put('Script__c', newScriptPrecedences[0].Name);
			update sObjToUpdate;

			sObject updatedObject = Database.query(qryAccount);
			system.debug(updatedObject.get('Script__c'));
			system.debug(existingScript);

			system.assertEquals((string)updatedObject.get('Script__c'), newScriptPrecedences[0].Name);
			
		}

	}

	@isTest static void testAccountPrecedence(){
		for(Account acc : [select id, name, Script__c from Account where name like 'Test Account SL%']){
			testPrecedence('Account', acc);
		}
		
	}

	@isTest static void testContactPrecedence(){
		for(Contact con : [select id, lastname, Script__c from Contact where name like 'Test Contact SL%']){
			testPrecedence('Contact', con);
		}
	}

	@isTest static void testAffiliationPrecedence(){
		for(Affiliation__c aff: [select id, Organization__c, Provider__c, Script__c from Affiliation__c where Data_Source__c like 'Test Affiliation SL%']){
			testPrecedence('Affiliation__c', aff);
		}
	}
	
	@isTest static void testOrgAffiliationPrecedence(){
		for(Organization_Affiliation__c aff: [select id, Script__c from Organization_Affiliation__c where Data_Source__c like 'Test Affiliation SL%']){
			testPrecedence('Organization_Affiliation__c', aff);
		}
	}

	@isTest static void testACRPrecedence(){
		for(Active_Care_Relationship__c acr: [select id, Script__c from Active_Care_Relationship__c where Data_Source__c like 'Test ACR SL%']){
			testPrecedence('Active_Care_Relationship__c', acr);
		}
	}

	static List<SL_Script_Precedence__c> createPrecedences(){
		List<SL_Script_Precedence__c> precedences = new List<SL_Script_Precedence__c>();
		SL_Script_Precedence__c prec1 = new SL_Script_Precedence__c(name='ACRS', precedence__c=1); precedences.add(prec1);
		SL_Script_Precedence__c prec2 = new SL_Script_Precedence__c(name='DataMotion', precedence__c=2); precedences.add(prec2);
		SL_Script_Precedence__c prec3 = new SL_Script_Precedence__c(name='LARA', precedence__c=3); precedences.add(prec3);
		SL_Script_Precedence__c prec4 = new SL_Script_Precedence__c(name='MCIR', precedence__c=4); precedences.add(prec4);
		SL_Script_Precedence__c prec5 = new SL_Script_Precedence__c(name='NPPES', precedence__c=5); precedences.add(prec5);
		SL_Script_Precedence__c prec6 = new SL_Script_Precedence__c(name='SureScripts', precedence__c=6); precedences.add(prec6);
		
		return precedences;
	}

	
}