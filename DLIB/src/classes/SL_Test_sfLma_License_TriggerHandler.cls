/**
 * \author Vladimir Dobrelya
 * \date 21 Mar 2013
 * \see https://silverline.jira.com/browse/SILVERLINE-161
 * \brief Test Class for SL_sfLma_License_TriggerHandler trigger
 */
@isTest
private class SL_Test_sfLma_License_TriggerHandler {
	
	/*static testMethod void BeforeInsertLicense() {
		insert new DemoEmailDomains__c( Name = '@email.test' );
		system.assert( !SL_Settings.DemoEmailDomains.isEmpty() );
		
		Lead oLead = generateLeads( 1 )[ 0 ];
		insert oLead;
		
		sfLma__License__c oLicense = generateLicense( oLead.Id, 'Active' );
		insert oLicense;
		
		oLicense = [ SELECT sfLma__Lead__c, sfLma__Account__c, sfLma__Contact__c, Salesforce_Demo_License__c FROM sfLma__License__c WHERE Id = :oLicense.Id ];
		system.assertEquals( oLicense.Salesforce_Demo_License__c, true );
		
		system.assertNotEquals( oLicense.sfLma__Lead__c, null );
		system.assertEquals( oLicense.sfLma__Account__c, null );
		system.assertEquals( oLicense.sfLma__Contact__c, null );
	}
	
	static testMethod void InsertLicense() {
		List<Lead> aLeads = generateLeads( 2 );
		insert aLeads;
		
		sfLma__License__c oLicense = generateLicense( aLeads[0].Id, 'Trial' );
		insert oLicense;
		
		oLicense = [ SELECT sfLma__Lead__c, sfLma__Account__c, sfLma__Contact__c, sfLma__Seats__c, sfLma__Contact__r.LeadSource, sfLma__Expiration__c FROM sfLma__License__c WHERE Id = :oLicense.Id ];
		system.assertEquals( oLicense.sfLma__Account__c, null );
		system.assertEquals( oLicense.sfLma__Contact__c, null );
		
		Opportunity oInitialOpp = null;
		for ( Opportunity oItem : [
			SELECT Id
			FROM Opportunity
			WHERE Type = 'New License' AND
				License__c = :oLicense.Id AND
				RecordTypeId = :pProductRecordType.Id AND
				AccountId = :oLicense.sfLma__Account__c AND
				Number_of_Licenses__c = :oLicense.sfLma__Seats__c
			limit 1
		] ) {
			oInitialOpp = oItem;
		}
		
		system.assertEquals( oInitialOpp, null );
	}
	
	static testMethod void UpdateLicense() {
		Lead oLead = generateLeads( 1 )[0];
		insert oLead;
		
		sfLma__License__c oLicense = generateLicense( oLead.Id, 'Active' );
		insert oLicense;
		
		insert generatePayment( oLicense.Id, true, 1 );
		
		oLicense.sfLma__Lead__c = null;
		update oLicense;
		
		oLicense.sfLma__Lead__c = oLead.Id;
		oLicense.sfLma__Account__c = pAccount.Id;
        oLicense.sfLma__Contact__c = pContact.Id;
		update oLicense;
		
		for ( sfLma__License__c oItem : [ SELECT sfLma__Lead__c, sfLma__Account__c, sfLma__Contact__c FROM sfLma__License__c WHERE Id = :oLicense.Id limit 1 ] ) {
			oLicense = oItem;
		}
		system.assertNotEquals( null, oLicense.sfLma__Account__c );
		system.assertNotEquals( null, oLicense.sfLma__Contact__c );
	}
	
	private static Payment__c generatePayment( ID idLicense, Boolean bRenewal, Integer nNewLicenses ) {
        Payment__c oPayment = new Payment__c();
        oPayment.Status__c = 'approved';
        oPayment.Renewal__c = bRenewal;
        oPayment.License__c = idLicense;
        oPayment.New_Licenses__c = nNewLicenses;
        oPayment.Total__c = 10;
        return oPayment;
    }
	
	private static List<Lead> generateLeads( Integer nCount ) {
		List<Lead> aResult = new List<Lead>();
		Lead oLead = null;
		for ( Integer nI = 0; nI < nCount; nI++ ) {
			oLead = new Lead();
			oLead.LastName = 'TestLead';
			oLead.Email = 'TestLead@email.test';
			oLead.Company = 'TestLeadCompany' + nCount;
			oLead.Status = 'New Lead';
			aResult.add( oLead );
		}
		return aResult;
	}
	
	private static sfLma__License__c generateLicense( ID idLead, String sStatus ) {
		sfLma__License__c oLicense = new sfLma__License__c();
		oLicense.sfLma__Status__c = sStatus;
		oLicense.sfLma__Package_Version__c = pPackageVersion.Id;
		oLicense.sfLma__Seats__c = 5;
		oLicense.sfLma__Used_Licenses__c = 1;
		oLicense.sfLma__Install_Date__c = Date.today();
		oLicense.sfLma__Expiration__c = Date.today().addDays( 5 );
		oLicense.sfLma__Lead__c = idLead;
		return oLicense;
	}

	private static RecordType pProductRecordType {
		get {
			if ( pProductRecordType != null ) {
				return pProductRecordType;
			}
			
			pProductRecordType = [ SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'Product' LIMIT 1 ];
			
			return pProductRecordType;
		} private set;
	}

	private static sfLma__Package__c pPackage {
		get {
			if ( pPackage != null ) {
				return pPackage;
			}
			
			sfLma__Package__c oVar = new sfLma__Package__c();
			oVar.Name = 'TestPackage';
			oVar.sfLma__Developer_Name__c = 'TestPackageDN';
			oVar.sfLma__Release_Date__c = Date.today();
			insert oVar;
			
			pPackage = [
				SELECT Id
				FROM sfLma__Package__c
				WHERE Id = :oVar.Id
			];
			
			return pPackage;
		} private set;
	}

	private static sfLma__Package_Version__c pPackageVersion {
		get {
			if ( pPackageVersion != null ) {
				return pPackageVersion;
			}
			
			sfLma__Package_Version__c oVar = new sfLma__Package_Version__c();
			oVar.Name = 'TestPackageVersion';
			oVar.sfLma__Package__c = pPackage.Id;
			oVar.sfLma__Release_Date__c = Date.today();
			oVar.sfLma__Version__c = 'TestVersion';
			oVar.Version_Number__c = '1.0';
			insert oVar;
			
			pPackageVersion = [
				SELECT Id
				FROM sfLma__Package_Version__c
				WHERE Id = :oVar.Id
			];
			
			return pPackageVersion;
		} private set;
	}

    private static Account pAccount {
        get {
            if ( pAccount == null ) {
                pAccount = new Account(
                    Name = 'Test pAccount'
                );
                insert pAccount;
            }
            return pAccount;
        } set;
    }

    private static Contact pContact {
        get {
            if ( pContact == null ) {
                pContact = new Contact(
                    LastName = 'Test pContact',
                    Email = 'pContact@test.test',
                    AccountId = pAccount.Id
                );
                insert pContact;
            }
            return pContact;
        } set;
    }*/
}