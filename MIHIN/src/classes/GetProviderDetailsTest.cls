@isTest

private class GetProviderDetailsTest{
    static testmethod void GetProviderDetailsTest(){
        
         List<recordtype> lstrecordtype= new List<recordtype>([select id,developername from 
                                                             recordtype where developername = 'Provider']);
        
         List<recordtype> lstAccrecordtype= new List<recordtype>([select id,developername from 
                                                 recordtype where developername = 'MIHIN_Organizations']);
        
        account objAccount = new Account();
        objAccount.Name = 'TestAccountName';
        objAccount.Recordtypeid = lstAccrecordtype[0].id;
        objAccount.ShippingCity = 'TestShipCity';
        objAccount.ShippingCountry = 'TestShipCnt';
        objAccount.ShippingPostalCode = '12345'; 
        objAccount.ShippingState = 'TestShipState';
        objAccount.ShippingStreet = '123456';
        insert objAccount;
        
        system.debug('@@@@@@@@@@@' + objAccount.ShippingCity);
        system.debug('@@@@@@@@@@@....' + objAccount.ShippingState ); 
        
        contact objcon = new contact();
        objcon.Firstname='TestFName';
        objcon.LastName='TestLName';
        objcon.Status__c = 'Active';
        objcon.Type__c= 'Care Coordinator';
        objcon.gender__c= 'Male';
        objcon.Accountid = objAccount.id;    
        objcon.recordtypeid = lstrecordtype[0].id;
        insert objcon;
        
        //System.assertEquals(objcon.Org_Practice_City__c, 'TestShipCity');
        //System.assertEquals(objcon.Org_Practice_State__c, 'TestShipState');
        
        system.debug('@@@@@@@@@@@' + objcon.Org_Practice_City__c);
        system.debug('@@@@@@@@@@@....' + objcon.Org_Practice_State__c); 
        
        Affiliation__c objAffiliation = new Affiliation__c();
        objAffiliation.Provider__c = objcon.id;
        objAffiliation.Organization__c = objAccount.id;
        objAffiliation.Email__c = 'Test@gmail.com';
        insert objAffiliation;
        
        Provider_Address__c objProviderAdrs = new Provider_Address__c();
        objProviderAdrs.Provider__c = objcon.id;
        objProviderAdrs.Street_Address_1__c = 'TestAdr1';
        objProviderAdrs.City__c = 'TestAdr1';
        objProviderAdrs.State__c = 'MA';
        objProviderAdrs.Postal_Code__c = '1234';
        insert objProviderAdrs;
        
        Specialty__c objSpecialty = new Specialty__c();
        objSpecialty.Name = 'TestSpec';
        objSpecialty.Classification__c = 'TestClass';
        objSpecialty.Type__c ='TestType';
        insert objSpecialty;
        
        Provider_Specialty__c objProviderSpecialty = new Provider_Specialty__c();
        objProviderSpecialty.Provider__c = objcon.id;
        objProviderSpecialty.Specialty__c = objSpecialty.id;
        objProviderSpecialty.Primary_Indicator__c = true;
        insert objProviderSpecialty;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/viewprovider';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        Contact ObjNewcon = [ select id, name, AccountId,Org_Practice_City__c, Org_Practice_State__c,
            Type__c, gender__c, Status__c, Account.ShippingCity, Account.ShippingState 
            from contact where id =: objcon.id];
            
        //System.debug('@@@@' + lstcon);
        System.debug('@@@@ objAccount.ShippingCity: ' + objAccount.ShippingCity);
        System.debug('@@@@ ObjNewcon.AccountId: ' + ObjNewcon.AccountId);
        System.debug('@@@@ ObjNewcon.Org_Practice_State__c: ' + ObjNewcon.Org_Practice_State__c);
        System.debug('@@@@ ObjNewcon.Org_Practice_City__c: ' + ObjNewcon.Org_Practice_City__c);
        //System.debug('@@@@' + string.valueof(lstcon[0].Org_Practice_State__c));
        
        req.addParameter('provider_name',string.valueof(ObjNewcon.Name));
        req.addParameter('provider_city',string.valueof(objAccount.ShippingCity));
        req.addParameter('provider_state',string.valueof(objAccount.ShippingState));
        req.addParameter('organization_name',string.valueof(objAccount.Name));
        req.addParameter('status',string.valueof(ObjNewcon.Status__c));

        req.addParameter('type',string.valueof(ObjNewcon.Type__c));
        req.addParameter('gender',string.valueof(ObjNewcon.gender__c));
        req.addParameter('practice_address',string.valueof(objProviderAdrs.Street_Address_1__c));
        req.addParameter('specialities',string.valueof(objSpecialty.Name));

        GetProviderDetails objGPD = new GetProviderDetails();
        GetProviderDetails.GetProviderDetail();
    }
    
    static testmethod void GetProviderDetailsTestProviderValid(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/viewprovider';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('provider_name','');

        GetProviderDetails.GetProviderDetail();
    }
    
    static testmethod void GetProviderDetailsTestPrCityValid(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/viewprovider';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('provider_name','1111');
        req.addParameter('provider_city','');        

        GetProviderDetails.GetProviderDetail();
    }
    
     static testmethod void GetProviderDetailsTestPrstateValid(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/viewprovider';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('provider_name','TestName');
        req.addParameter('provider_city','TestCity');
        req.addParameter('provider_state','');        

        GetProviderDetails.GetProviderDetail();
    }
}