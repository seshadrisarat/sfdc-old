@isTest(SeeAllData=TRUE)
private class SL_Test_CreateAccess_Dispatcher {
    
    @isTest static void test_create_Affiliation() {
        SL_Test_CreateAccess testAffiliationCreation = new SL_Test_CreateAccess();
        runTestCreate(Affiliation__c.SObjectType, testAffiliationCreation);
    }

    @isTest static void test_create_Account() {
        SL_Test_CreateAccess testAccountCreation = new SL_Test_CreateAccess();
        runTestCreate(Account.SObjectType, testAccountCreation);
    }

    @isTest static void test_create_Contact() {
        SL_Test_CreateAccess testContactCreation = new SL_Test_CreateAccess();
        runTestCreate(Contact.SObjectType, testContactCreation);
    }

    @isTest static void test_create_OrganizationName() {
        SL_Test_CreateAccess testOrganizationNameCreation = new SL_Test_CreateAccess();
        runTestCreate(Organization_Name__c.SObjectType, testOrganizationNameCreation);
    }

    @isTest static void test_create_OrganizationAddress() {
        SL_Test_CreateAccess testOrganizationAddressCreation = new SL_Test_CreateAccess();
        runTestCreate(Organization_Address__c.SObjectType, testOrganizationAddressCreation);
    }

    @isTest static void test_create_OrganizationCredential() {
        SL_Test_CreateAccess testOrganizationCredentialCreation = new SL_Test_CreateAccess();
        runTestCreate(Organization_Credential__c.SObjectType, testOrganizationCredentialCreation);
    }

    @isTest static void test_create_OrganizationSpecialty() {
        SL_Test_CreateAccess testOrganizationSpecialtyCreation = new SL_Test_CreateAccess();
        runTestCreate(Organization_Specialty__c.SObjectType, testOrganizationSpecialtyCreation);
    }

    @isTest static void test_create_OrganizationService() {
        SL_Test_CreateAccess testOrganizationServiceCreation = new SL_Test_CreateAccess();
        runTestCreate(Organization_Service__c.SObjectType, testOrganizationServiceCreation);
    }

    @isTest static void test_create_CareTeam() {
        SL_Test_CreateAccess testCareTeamCreation = new SL_Test_CreateAccess();
        runTestCreate(Care_Team__c.SObjectType, testCareTeamCreation);
    }

    @isTest static void test_create_OrganizationAffiliation() {
        SL_Test_CreateAccess testOrganizationAffiliationCreation = new SL_Test_CreateAccess();
        runTestCreate(Organization_Affiliation__c.SObjectType, testOrganizationAffiliationCreation);
    }

    @isTest static void test_create_AffiliationService() {
        SL_Test_CreateAccess testAffiliationServiceCreation = new SL_Test_CreateAccess();
        runTestCreate(Affiliation_Service__c.SObjectType, testAffiliationServiceCreation);
    }

    @isTest static void test_create_ProviderAddress() {
        SL_Test_CreateAccess testProviderAddressCreation = new SL_Test_CreateAccess();
        runTestCreate(Provider_Address__c.SObjectType, testProviderAddressCreation);
    }

    @isTest static void test_create_ProviderSpecialty() {
        SL_Test_CreateAccess testProviderSpecialtyCreation = new SL_Test_CreateAccess();
        runTestCreate(Provider_Specialty__c.SObjectType, testProviderSpecialtyCreation);
    }

    @isTest static void test_create_ProviderCredential() {
        SL_Test_CreateAccess testProviderCredentialCreation = new SL_Test_CreateAccess();
        runTestCreate(Provider_Credential__c.SObjectType, testProviderCredentialCreation);
    }

    @isTest static void test_create_ProviderCareTeam() {
        SL_Test_CreateAccess testProviderCareTeamCreation = new SL_Test_CreateAccess();
        runTestCreate(Provider_Care_Team__c.SObjectType, testProviderCareTeamCreation);
    }    

    @isTest static void test_create_Cases() {
        SL_Test_CreateAccess testCaseCreation = new SL_Test_CreateAccess();
        runTestCreate(Case.SObjectType, testCaseCreation);
    }   

    public static void runTestCreate(Schema.SObjectType type, SL_Test_CreateAccess classInstance){
        SecurityTestConfig__c[] config = SecurityTestConfig__c.getAll().values();

        Map<ID,SecurityTestConfig__c[]> userToRecords = New Map<ID,SecurityTestConfig__c[]>();
        Map<ID,SecurityTestConfig__c> recordToConfig = New Map<ID,SecurityTestConfig__c>();

        //system.assertEquals(false,config.isEmpty());

        for(SecurityTestConfig__c rec : config){
            Id testRecordId = (Id)rec.Record_ID_For_Test__c;
            if(testRecordId.getSObjectType() == type){
                if(userToRecords.containsKey(rec.User_ID__c)){
                    userToRecords.get(rec.User_ID__c).add(rec);
                }
                else{
                    userToRecords.put(rec.User_ID__c,New SecurityTestConfig__c[]{rec});
                }
            }
        }


        for(ID userID : userToRecords.keySet()){

            for(SecurityTestConfig__c rec : userToRecords.get(userID)){
                system.assertEquals(false, recordToConfig.containsKey(rec.Record_ID_For_Test__c) && recordToConfig.get(rec.Record_ID_For_Test__c).User_ID__c == userID,'The record ID to Test: ' + 
                    rec.Record_ID_For_Test__c + ' is defined more than once for the user ID: ' + userID);

                recordToConfig.put(rec.Record_ID_For_Test__c,rec);
            }

        }

        classInstance.testCreateAccess(type, userToRecords, recordToConfig);
    }
    
}