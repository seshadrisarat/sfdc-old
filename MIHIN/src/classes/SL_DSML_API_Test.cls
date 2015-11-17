/*
*Class: SL_DSML_API_Test
*Description: This class serves as test class for checking the functionality of DSML API and its code coverage
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@isTest
private class SL_DSML_API_Test {
    public static testmethod void testWrappers() {
        Test.startTest();
        
        Account testAcc = new Account(name = 'testAccount');
        insert testAcc;
        
        Contact testCon = new Contact(lastName = 'testContact',
                                      firstname = 'first',
                                      AccountId = testAcc.Id,
                                      NPI__c = 'NPI1',
                                      Medicaid_Provider_Number__c = '1234',
                                      Medicare_Provider_Number__c = '5678');
        insert testCon;            
        
        
        Specialty__c objSpecialty = new Specialty__c(Name='Specialty-01');
        insert objSpecialty;
        
        Provider_Specialty__c objPS = new Provider_Specialty__c(Provider__c = testCon.Id,Specialty__c = objSpecialty.Id);
        insert objPS;
        
        Affiliation__c objAFF = new Affiliation__c(Organization__c = testAcc.Id, Provider__c= testCon.Id, Type__c = 'NPI');        
        insert objAFF;
        
        Provider_Credential__c objPC = new Provider_Credential__c(Provider__c=testCon.Id);
        insert objPC;
         
        Electronic_Service__c objES = new Electronic_Service__c(Name='ES-01',Address__c ='Address-01',Certificate__c='Certificate-01', Payload__c='Payload-01',
        														Protocol__c= 'Protocol-01', Type__c='Type-01');
     	insert objES;
     	
        Affiliation_Service__c objAS = new Affiliation_Service__c();
        objAS.Affiliation__c = objAFF.Id;
        objAS.Electronic_Service__r = objES;
        
        //List<Affiliation_Service__c> lstAS = new List<Affiliation_Service__c>{ new Affiliation_Service__c(Affiliation__c = objAFF.Id, Electronic_Service__c = objES.Id)};   
     	//insert lstAS;
        List<String> lstAS = new List<String>();   
     	lstAS.add(objES.Id);
        
        Organization_Affiliation__c testOrgAff = new Organization_Affiliation__c();
        // Inputs
        SL_DSML_API_Wrapper.PUR pur = new SL_DSML_API_Wrapper.PUR();
        SL_DSML_API_Wrapper.IDE ide = new SL_DSML_API_Wrapper.IDE();
        SL_DSML_API_Wrapper.IUR iur = new SL_DSML_API_Wrapper.IUR(null, null, null, null);
        SL_DSML_API_Wrapper.ODE ode = new SL_DSML_API_Wrapper.ODE();
        SL_DSML_API_Wrapper.OUR our = new SL_DSML_API_Wrapper.OUR();
        SL_DSML_API_Wrapper.IORDE iorde = new SL_DSML_API_Wrapper.IORDE();
        
        
        
        // Outputs
        
        // IDO
        SL_DSML_API_Wrapper.IDO ido = new SL_DSML_API_Wrapper.IDO(testCon, new SL_DSML_API_Wrapper.HcIdentifierClass(null, null, null, null), null, null, new List<SL_DSML_API_Wrapper.SDO>());
        
        // ODO
        SL_DSML_API_Wrapper.ODO odo = new SL_DSML_API_Wrapper.ODO(testAcc, new SL_DSML_API_Wrapper.HcIdentifierClass(null, null, null, null), null, null, new List<SL_DSML_API_Wrapper.SDO>(), new Set<String>());
        
        // OORO
        SL_DSML_API_Wrapper.OORO ooro = new SL_DSML_API_Wrapper.OORO(testOrgAff);
        
        // IORO
        SL_DSML_API_Wrapper.IORO ioro = new SL_DSML_API_Wrapper.IORO(objAFF, lstAS);
        
        Test.stopTest();
    }
    
    public static testmethod void testProviderSearch() 
    {
    	 Account testAcc = new Account(name = 'testAccount');
         insert testAcc;
        
         Contact testCon = new Contact(lastName = 'testContact',
                                      firstname = 'first',
                                      AccountId = testAcc.Id,
                                      NPI__c = 'NPI1',
                                      Medicaid_Provider_Number__c = '1234',
                                      Medicare_Provider_Number__c = '5678');
         insert testCon;            
        
        
         Specialty__c objSpecialty = new Specialty__c(Name='Specialty-01');
         insert objSpecialty;
        
         Provider_Specialty__c objPS = new Provider_Specialty__c(Provider__c = testCon.Id,Specialty__c = objSpecialty.Id);
         insert objPS;
        
         Affiliation__c objAFF = new Affiliation__c(Organization__c = testAcc.Id, Provider__c= testCon.Id, Type__c = 'NPI');        
         insert objAFF;
        
         Provider_Credential__c objPC = new Provider_Credential__c(Provider__c=testCon.Id);
         insert objPC; 
         
         Contact testCon1 = new Contact(lastName = 'testContact1',
                                      firstname = 'first1',
                                      AccountId = testAcc.Id,
                                      NPI__c = 'NPI',
                                      Medicaid_Provider_Number__c = '1234',
                                      Medicare_Provider_Number__c = '5678');
         insert testCon1;            
        
        
         Specialty__c objSpecialty1 = new Specialty__c(Name='Specialty-01');
         insert objSpecialty1;
        
         Provider_Specialty__c objPS1 = new Provider_Specialty__c(Provider__c = testCon1.Id,Specialty__c = objSpecialty1.Id);
         insert objPS1;
        
         Affiliation__c objAFF1 = new Affiliation__c(Organization__c = testAcc.Id, Provider__c= testCon1.Id, Type__c = 'NPI');        
         insert objAFF1;
        
         Provider_Credential__c objPC1 = new Provider_Credential__c(Provider__c=testCon1.Id);
         insert objPC1; 
         
         List<Provider_Identifier__c> lstPI = new List<Provider_Identifier__c>{
         																			new Provider_Identifier__c(Name = '1222', Type__c = 'NPI', Provider__c = testCon.Id),
         																			new Provider_Identifier__c(Name = '12221', Type__c = 'Medicaid', Provider__c = testCon.Id),
         																			new Provider_Identifier__c(Name = '12222', Type__c = 'Medicare', Provider__c = testCon.Id)
         																	  };
         
         String purJSON = '{'+
         					'	"hpdRequestId":"test000000", '+
         					'	"hpdId":"123456767888990000"'+
    					  '}';
    						
         String ideJSON = '{'+
						  	'"sn":"testContact",'+
							'"hpdProviderPracticeAddress":{'+
							'								"Zip_Code":"",'+
							'								"Street_2":"",'+
							'								"Street_1":"",'+
							'								"State":"",'+
							'								"County":"",'+
							'								"City":""'+
							'								},'+
							'"hpdProviderMailingAddress":{'+
							'								"Zip_Code":"",'+
							'								"Street_2":"",'+
							'								"Street_1":"",'+
							'								"State":"",'+
							'								"County":"",'+
							'								"City":""'+
							'							},'+
							'"hpdProviderLanguageSupported":"",'+
							'"hcSpecialization":"",'+
							'"givenName":"first"'+
							'}';
         String iursJSON = '['+
							 ' 	{'+
							 '		"uid":"'+testCon.Id+'"'+
							 '	},'+
							 '	{'+
							 '		"uid":"'+testCon1.Id+'"'+
							 '	}'+
						   ']';
        
    	 SL_DSML_API_Wrapper.PUR pur = (SL_DSML_API_Wrapper.PUR)JSON.deserialize(purJSON,  SL_DSML_API_Wrapper.PUR.class);
         SL_DSML_API_Wrapper.IDE ide = (SL_DSML_API_Wrapper.IDE)JSON.deserialize(ideJSON,  SL_DSML_API_Wrapper.IDE.class);
         List<SL_DSML_API_Wrapper.IUR> iurs = (List<SL_DSML_API_Wrapper.IUR>)JSON.deserialize(iursJSON,  List<SL_DSML_API_Wrapper.IUR>.class);
         
        // null
         SL_DSML_API_ProviderSearch.DslmProviderSearchResponse objPSR = SL_DSML_API_ProviderSearch.dslmProviderSearch(null, null, null);
         System.assertEquals(objPSR.ido.size(), 0);
         
        // Q1
         objPSR = SL_DSML_API_ProviderSearch.dslmProviderSearch(null, ide, pur);
         System.assertEquals(objPSR.ido.size(), 2);
         System.assertEquals(objPSR.ido[0].uid, testCon.Id);
         System.assertEquals(objPSR.ido[0].givenName, testCon.FirstName);
         System.assertEquals(objPSR.ido[0].sn, testCon.LastName);
        
         
        // Q2
         objPSR = SL_DSML_API_ProviderSearch.dslmProviderSearch(iurs, null, pur);
         System.assertEquals(objPSR.ido.size(), 2);
         
         String ideJSON1 = '{'+
						  		'"hcIdentifier":{"IssuingAuthority":"Test","ID":"1222"}'+
							'}';
							
		 SL_DSML_API_Wrapper.IDE ide1 = (SL_DSML_API_Wrapper.IDE)JSON.deserialize(ideJSON1,  SL_DSML_API_Wrapper.IDE.class);
         SL_DSML_API_ProviderSearch.DslmProviderSearchResponse objPSR1 = SL_DSML_API_ProviderSearch.dslmProviderSearch(null, ide1, pur);
         
          String ideJSON2 = '{'+
						  		'"hcIdentifier":{"IssuingAuthority":"Test","ID":"12222","Type":"Medicare"}'+
							'}';
							
		 SL_DSML_API_Wrapper.IDE ide2 = (SL_DSML_API_Wrapper.IDE)JSON.deserialize(ideJSON2,  SL_DSML_API_Wrapper.IDE.class);
         SL_DSML_API_ProviderSearch.DslmProviderSearchResponse objPSR2 = SL_DSML_API_ProviderSearch.dslmProviderSearch(null, ide2, pur);
         
         new SL_DSML_API_ProviderSearch.DslmProviderSearchResponse();
    }
    
    public static testmethod void testOrgSearch() 
    {
        Account objAccount = new Account(name = 'Test Account 1', 
                                         Organizational_NPI__c = 'ORG NPI1');
        
        insert objAccount;
        
        Account objAccount1 = new Account(name = 'Test Account 2', 
                                         Organizational_NPI__c = 'ORG NPI');
        
        insert objAccount1;
        Contact objContact = new Contact(lastName = 'Test Contact 1',
                                      firstname = 'first',
                                      AccountId = objAccount.Id,
                                      NPI__c = 'NPI1');
        insert objContact; 
        
        Specialty__c objSpecialty = new Specialty__c(Name='Specialty-01');
        insert objSpecialty;
        
        Organization_Specialty__c objOrgSpeciality = new Organization_Specialty__c(Organization__c = objAccount.Id,
        																			Specialty__c = objSpecialty.Id);
		insert objOrgSpeciality;

        																			
        Organization_Credential__c objOrgCredentials = new Organization_Credential__c(Name = 'Test Organization Credentials', 
        																				Organization__c = objAccount.Id,
        																				Credential_Number__c = '12345');
		insert objOrgCredentials;
		
		Affiliation__c objAffiliation = new Affiliation__c(Organization__c = objAccount.Id,
															Provider__c = objContact.Id,
															Type__c='Type');
		insert objAffiliation;
		Affiliation__c objAffiliation1 = new Affiliation__c(Organization__c = objAccount.Id,
															Provider__c = objContact.Id, Type__c='Type');
		insert objAffiliation1;
		Affiliation__c objAffiliation2 = new Affiliation__c(Organization__c = objAccount.Id,
															Provider__c = objContact.Id, Type__c='Type');
		insert objAffiliation2;
		
		Organization_Affiliation__c objOrgAffiliation = new Organization_Affiliation__c(Member_Organization__c = objAccount.Id,
																						Affiliated_Organization__c = objAccount.Id);
		insert objOrgAffiliation;
		
		Organization_Name__c objOrgName = new Organization_Name__c(Name = 'Test OrgName 1', 
																	Organization__c = objAccount.Id);
																	
		insert objOrgName;
        
        Organization_Identifier__c objOI = new Organization_Identifier__c(Name = 'NPI1', Organization__c = objAccount.Id, Type__c = 'NPI');
        insert objOI;
        
        Electronic_Service__c objES = new Electronic_Service__c(Name='ES-01',Address__c ='Address-01',Certificate__c='Certificate-01', Payload__c='Payload-01',
        														Protocol__c= 'Protocol-01', Type__c='Type-01');
     	insert objES;
     	
     	 String purJSON = '{'+
         					'	"hpdRequestId":"test000000", '+
         					'	"hpdId":"123456767888990000"'+
    					  '}';
    						
         String odeJSON = '{'+
						  	'"hcRegisteredName":"Test",'+
							'"hpdProviderPracticeAddress":{'+
							'								"Zip_Code":"",'+
							'								"Street_2":"",'+
							'								"Street_1":"",'+
							'								"State":"",'+
							'								"County":"",'+
							'								"City":""'+
							'								},'+
							'"hpdProviderBillingAddress":{'+
							'								"Zip_Code":"",'+
							'								"Street_2":"",'+
							'								"Street_1":"",'+
							'								"State":"",'+
							'								"County":"",'+
							'								"City":""'+
							'							}'+
						  '}';
							
         String oursJSON = '['+
							 ' 	{'+
							 '		"uid":"'+objAccount.Id+'"'+
							 '	},'+
							 '	{'+
							 '		"uid":"'+objAccount1.Id+'"'+
							 '	}'+
						   ']';
     	
        SL_DSML_API_Wrapper.PUR pur = (SL_DSML_API_Wrapper.PUR)JSON.deserialize(purJSON,  SL_DSML_API_Wrapper.PUR.class);
        SL_DSML_API_Wrapper.ODE ode = (SL_DSML_API_Wrapper.ODE)JSON.deserialize(odeJSON,  SL_DSML_API_Wrapper.ODE.class);
        List<SL_DSML_API_Wrapper.OUR> ours = (List<SL_DSML_API_Wrapper.OUR>)JSON.deserialize(oursJSON,  List<SL_DSML_API_Wrapper.OUR>.class);
		
		// null
        SL_DSML_API_OrgSearch.dslmOrgSearch(null, null, null);
        
        // Q3
        SL_DSML_API_OrgSearch.DslmOrgSearchResponse objOSR= SL_DSML_API_OrgSearch.dslmOrgSearch(null, ode ,pur);
        System.assertEquals(objOSR.odo.size(), 2);
        
        // Q4
        objOSR= SL_DSML_API_OrgSearch.dslmOrgSearch(ours, null, pur);
        System.assertEquals(objOSR.odo.size(), 2);
        System.assertEquals(objOSR.odo[0].uid, objAccount.Id);
        System.assertEquals(objOSR.odo[0].hcRegisteredName, objAccount.Name);
        new SL_DSML_API_OrgSearch.DslmOrgSearchResponse();
        
        String odeJSON1 = '{'+
        						'"hcIdentifier":{"IssuingAuthority":"Test", "ID":"NPI1"}'+
        				   '}';
        
        SL_DSML_API_Wrapper.ODE ode1 = (SL_DSML_API_Wrapper.ODE)JSON.deserialize(odeJSON1,  SL_DSML_API_Wrapper.ODE.class);
        SL_DSML_API_OrgSearch.DslmOrgSearchResponse objOSR1 = SL_DSML_API_OrgSearch.dslmOrgSearch(null, ode1 ,pur);
        System.assertEquals(objOSR1.odo.size(), 1);
        
        String odeJSON2 = '{'+
        						'"hcIdentifier":{"IssuingAuthority":"Test", "ID":"NPI1", "Type":"NPI"}'+
        				   '}';
        				   
        SL_DSML_API_Wrapper.ODE ode2 = (SL_DSML_API_Wrapper.ODE)JSON.deserialize(odeJSON2,  SL_DSML_API_Wrapper.ODE.class);
        SL_DSML_API_OrgSearch.DslmOrgSearchResponse objOSR2 = SL_DSML_API_OrgSearch.dslmOrgSearch(null, ode2 ,pur);
        System.assertEquals(objOSR2.odo.size(), 1);
    }
    
    public static testmethod void testProOrgsSearch()
	{
        Account objAccount = new Account(name = 'Test Account 1');
        insert objAccount;
        
        Contact objContact = new Contact(lastName = 'Test Contact 1',
                                      firstname = 'first',
                                      AccountId = objAccount.Id,
                                      NPI__c = 'NPI1');
        insert objContact; 
        
        Specialty__c objSpecialty = new Specialty__c(Name='Specialty-01');
        insert objSpecialty;
        
        Organization_Specialty__c objOrgSpeciality = new Organization_Specialty__c(Organization__c = objAccount.Id,
        																			Specialty__c = objSpecialty.Id);
		insert objOrgSpeciality;

        																			
        Organization_Credential__c objOrgCredentials = new Organization_Credential__c(Name = 'Test Organization Credentials', 
        																				Organization__c = objAccount.Id,
        																				Credential_Number__c = '12345');
		insert objOrgCredentials;
		
		Affiliation__c objAffiliation = new Affiliation__c(Organization__c = objAccount.Id,
															Provider__c = objContact.Id,
															Type__c = 'Type');
		insert objAffiliation;
		
		Organization_Affiliation__c objOrgAffiliation = new Organization_Affiliation__c(Member_Organization__c = objAccount.Id,
																						Affiliated_Organization__c = objAccount.Id);
		insert objOrgAffiliation;
		
		Organization_Name__c objOrgName = new Organization_Name__c(Name = 'Test OrgName 1', 
																	Organization__c = objAccount.Id);
																	
		insert objOrgName;
		
		Electronic_Service__c objES = new Electronic_Service__c(Name='ES-01',Address__c ='Address-01',Certificate__c='Certificate-01', Payload__c='Payload-01',
        														Protocol__c= 'Protocol-01', Type__c='Type-01');
     	insert objES;
        
        Organization_Service__c objOS = new Organization_Service__c(Organization__c = objAccount.Id, Electronic_Service__c = objES.id);
        insert objOS;
     	
     	List<Affiliation_Service__c> lstAS = new List<Affiliation_Service__c>{ new Affiliation_Service__c(Affiliation__c = objAffiliation.Id, Electronic_Service__c = objES.Id)};   
     	insert lstAS;
     	
     	
     	String purJSON = '{'+
         				   '	"hpdRequestId":"test000000", '+
         				   '	"hpdId":"123456767888990000"'+
    					 '}';
    					  
        String iurJSON =  '{'+
							'	"uid":"'+objContact.Id+'"'+
						  '}';
						  
     	String odeJSON =  '{'+
						  	'"hcRegisteredName":"Test",'+
							'"hpdProviderPracticeAddress":{'+
							'								"Zip_Code":"",'+
							'								"Street_2":"",'+
							'								"Street_1":"",'+
							'								"State":"",'+
							'								"County":"",'+
							'								"City":""'+
							'								},'+
							'"hpdProviderBillingAddress":{'+
							'								"Zip_Code":"",'+
							'								"Street_2":"",'+
							'								"Street_1":"",'+
							'								"State":"",'+
							'								"County":"",'+
							'								"City":""'+
							'							}'+
						  '}';
						 
		String iordeJSON =  '{'+
							  '"hpdMemberType":[ "Type"],'+
							  '"hpdHasAProvider" :null,'+
							  '"hpdHasAnOrg":null'+
	 						'}';
	 						
        SL_DSML_API_Wrapper.PUR pur = (SL_DSML_API_Wrapper.PUR)JSON.deserialize(purJSON,  SL_DSML_API_Wrapper.PUR.class);
        SL_DSML_API_Wrapper.IUR objIUR = (SL_DSML_API_Wrapper.IUR)JSON.deserialize(iurJSON,  SL_DSML_API_Wrapper.IUR.class);
		SL_DSML_API_Wrapper.ODE objODE = (SL_DSML_API_Wrapper.ODE)JSON.deserialize(odeJSON,  SL_DSML_API_Wrapper.ODE.class);
		SL_DSML_API_Wrapper.IORDE objIORDE = (SL_DSML_API_Wrapper.IORDE)JSON.deserialize(iordeJSON,  SL_DSML_API_Wrapper.IORDE.class);
		
		//null
		 SL_DSML_API_ProOrgsSearch.DslmProOrgsSearchResponse objPOS= SL_DSML_API_ProOrgsSearch.dslmProviderSearch(null, null, null, null);
		 
        // Q5
        objPOS= SL_DSML_API_ProOrgsSearch.dslmProviderSearch(objIUR, objODE, objIORDE, pur);
        System.assertEquals(objPOS.odo.size(), 1);
        System.assertEquals(objPOS.odo[0].uid,objAccount.id);
        System.assertEquals(objPOS.odo[0].hcRegisteredName,objAccount.Name );
        System.assertEquals(objPOS.odo[0].hpdHasAService.size(), 1);
        new SL_DSML_API_ProOrgsSearch.DslmProOrgsSearchResponse();
    }
    
    public static testmethod void testOrgProsSearch() 
    {
    	
    	Account objAccount = new Account(name = 'Test Account 1');
        insert objAccount;
        
        Contact objContact = new Contact(lastName = 'Test Contact 1',
                                      firstname = 'first',
                                      AccountId = objAccount.Id,
                                      NPI__c = 'NPI1');
        insert objContact; 
        
        Contact objContact1 = new Contact(lastName = 'Test Contact 1',
                                      firstname = 'first',
                                      AccountId = objAccount.Id,
                                      NPI__c = 'NPI1117861');
        insert objContact1; 
        
        Contact objContact2 = new Contact(lastName = 'Test Contact 1',
                                      firstname = 'first',
                                      AccountId = objAccount.Id,
                                      NPI__c = 'NPI22213331');
        insert objContact2; 
        
        Specialty__c objSpecialty = new Specialty__c(Name='Specialty-01');
        insert objSpecialty;
        
        Organization_Specialty__c objOrgSpeciality = new Organization_Specialty__c(Organization__c = objAccount.Id,
        																			Specialty__c = objSpecialty.Id);
		insert objOrgSpeciality;

        																			
        Organization_Credential__c objOrgCredentials = new Organization_Credential__c(Name = 'Test Organization Credentials', 
        																				Organization__c = objAccount.Id,
        																				Credential_Number__c = '12345');
		insert objOrgCredentials;
		
		Affiliation__c objAffiliation = new Affiliation__c(Organization__c = objAccount.Id,
															Provider__c = objContact.Id,
															Type__c = 'Other');
		insert objAffiliation;
		Affiliation__c objAffiliation1 = new Affiliation__c(Organization__c = objAccount.Id,
															Provider__c = objContact1.Id,
															Type__c = 'Other');
		insert objAffiliation1;
		
		Affiliation__c objAffiliation2 = new Affiliation__c(Organization__c = objAccount.Id,
															Provider__c = objContact2.Id,
															Type__c = 'Other');
		insert objAffiliation2;
		
		Organization_Affiliation__c objOrgAffiliation = new Organization_Affiliation__c(Member_Organization__c = objAccount.Id,
																						Affiliated_Organization__c = objAccount.Id);
		insert objOrgAffiliation;
		
		Organization_Name__c objOrgName = new Organization_Name__c(Name = 'Test OrgName 1', 
																	Organization__c = objAccount.Id);
																	
		insert objOrgName;
		
		Electronic_Service__c objES = new Electronic_Service__c(Name='ES-01',Address__c ='Address-01',Certificate__c='Certificate-01', Payload__c='Payload-01',
        														Protocol__c= 'Protocol-01', Type__c='Type-01');
     	insert objES;
     	
     	List<Affiliation_Service__c> lstAS = new List<Affiliation_Service__c>{ new Affiliation_Service__c(Affiliation__c = objAffiliation.Id, Electronic_Service__c = objES.Id)};   
     	insert lstAS;
     	
     	
     	String purJSON = '{'+
         				   '	"hpdRequestId":"test000000", '+
         				   '	"hpdId":"123456767888990000"'+
    					 '}';
    					  
        String ourJSON =  '{'+
							'	"uid":"'+objAccount.Id+'"'+
						  '}';
						  
     	 String ideJSON = '{'+
						  	'"sn":"Test",'+
							'"hpdProviderPracticeAddress":{'+
							'								"Zip_Code":"",'+
							'								"Street_2":"",'+
							'								"Street_1":"",'+
							'								"State":"",'+
							'								"County":"",'+
							'								"City":""'+
							'								},'+
							'"hpdProviderMailingAddress":{'+
							'								"Zip_Code":"",'+
							'								"Street_2":"",'+
							'								"Street_1":"",'+
							'								"State":"",'+
							'								"County":"",'+
							'								"City":""'+
							'							},'+
							'"hpdProviderLanguageSupported":"",'+
							'"hcSpecialization":"",'+
							'"givenName":""'+
							'}';
						  
		String iordeJSON =  '{'+
							  '"hpdMemberType":["Other"],'+
							  '"hpdHasAProvider" :null,'+
							  '"hpdHasAnOrg":null'+
	 						'}';
	 						
        SL_DSML_API_Wrapper.PUR pur = (SL_DSML_API_Wrapper.PUR)JSON.deserialize(purJSON,  SL_DSML_API_Wrapper.PUR.class);
        SL_DSML_API_Wrapper.OUR objOUR = (SL_DSML_API_Wrapper.OUR)JSON.deserialize(ourJSON,  SL_DSML_API_Wrapper.OUR.class);
		SL_DSML_API_Wrapper.IDE objIDE  = (SL_DSML_API_Wrapper.IDE)JSON.deserialize(ideJSON,  SL_DSML_API_Wrapper.IDE.class);
		SL_DSML_API_Wrapper.IORDE objIORDE = (SL_DSML_API_Wrapper.IORDE)JSON.deserialize(iordeJSON,  SL_DSML_API_Wrapper.IORDE.class);
		
		//null
		SL_DSML_API_OrgProsSearch.DslmOrgProsSearchResponse objRes = SL_DSML_API_OrgProsSearch.dslmProviderSearch(null, null, null, null);
		
		//Q6
		objRes = SL_DSML_API_OrgProsSearch.dslmProviderSearch(objOUR, objIDE, objIORDE, pur);
		System.assertEquals(objRes.ido.size(), 3);
		System.assertEquals(objRes.ido[0].uid,objContact.Id);
		System.assertEquals(objRes.ido[0].givenName,objContact.FirstName);
		
        new SL_DSML_API_OrgProsSearch.DslmOrgProsSearchResponse();
    }
    
    public static testmethod void testListSearch() 
    {	
    	
    	Account objAccount = new Account(name = 'Test Account 1');
        insert objAccount;
        
        Contact objContact = new Contact(lastName = 'Test Contact Prime',
                                      firstname = 'first',
                                      AccountId = objAccount.Id,
                                      NPI__c = 'NPI1');
        insert objContact; 
        
        Contact objContact1 = new Contact(lastName = 'Test Contact 1',
                                      firstname = 'first',
                                      AccountId = objAccount.Id,
                                      NPI__c = 'NPI78711');
        insert objContact1; 
        
        Contact objContact2 = new Contact(lastName = 'Test Contact 2',
                                      firstname = 'first',
                                      AccountId = objAccount.Id,
                                      NPI__c = 'NPI323231');
        insert objContact2; 
        
        Specialty__c objSpecialty = new Specialty__c(Name='Specialty-01');
        insert objSpecialty;
        
        Organization_Specialty__c objOrgSpeciality = new Organization_Specialty__c(Organization__c = objAccount.Id,
        																			Specialty__c = objSpecialty.Id);
		insert objOrgSpeciality;

        																			
        Organization_Credential__c objOrgCredentials = new Organization_Credential__c(Name = 'Test Organization Credentials', 
        																				Organization__c = objAccount.Id,
        																				Credential_Number__c = '12345');
		insert objOrgCredentials;
		
		Affiliation__c objAffiliation = new Affiliation__c(Organization__c = objAccount.Id,
															Provider__c = objContact.Id,
															Type__c = 'Other');
		insert objAffiliation;
		Affiliation__c objAffiliation1 = new Affiliation__c(Organization__c = objAccount.Id,
															Provider__c = objContact1.Id,
															Type__c = 'Other');
		insert objAffiliation1;
		
		Affiliation__c objAffiliation2 = new Affiliation__c(Organization__c = objAccount.Id,
															Provider__c = objContact2.Id,
															Type__c = 'Other');
		insert objAffiliation2;
		
		Organization_Affiliation__c objOrgAffiliation = new Organization_Affiliation__c(Member_Organization__c = objAccount.Id,
																						Affiliated_Organization__c = objAccount.Id);
		insert objOrgAffiliation;
		
		Organization_Name__c objOrgName = new Organization_Name__c(Name = 'Test OrgName 1', 
																	Organization__c = objAccount.Id);
																	
		insert objOrgName;
		
		Electronic_Service__c objES = new Electronic_Service__c(Name='ES-01',Address__c ='Address-01',Certificate__c='Certificate-01', Payload__c='Payload-01',
        														Protocol__c= 'Protocol-01', Type__c='Type-01');
     	insert objES;
     	
     	List<Affiliation_Service__c> lstAS = new List<Affiliation_Service__c>{ new Affiliation_Service__c(Affiliation__c = objAffiliation.Id, Electronic_Service__c = objES.Id),
     																		   new Affiliation_Service__c(Affiliation__c = objAffiliation2.Id, Electronic_Service__c = objES.Id)};   
     	insert lstAS;
     	
     	String purJSON = '{'+
         				   '	"hpdRequestId":"test000000", '+
         				   '	"hpdId":"123456767888990000"'+
    					 '}';
    					  
        String odeJSON =  '{'+
						  	'"hcRegisteredName":"Test",'+
							'"hpdProviderPracticeAddress":{'+
							'								"Zip_Code":"",'+
							'								"Street_2":"",'+
							'								"Street_1":"",'+
							'								"State":"",'+
							'								"County":"",'+
							'								"City":""'+
							'								},'+
							'"hpdProviderBillingAddress":{'+
							'								"Zip_Code":"",'+
							'								"Street_2":"",'+
							'								"Street_1":"",'+
							'								"State":"",'+
							'								"County":"",'+
							'								"City":""'+
							'							}'+
						  '}';
     	 String ideJSON = '{'+
						  	'"sn":"Test",'+
							'"hpdProviderPracticeAddress":{'+
							'								"Zip_Code":"",'+
							'								"Street_2":"",'+
							'								"Street_1":"",'+
							'								"State":"",'+
							'								"County":"",'+
							'								"City":""'+
							'								},'+
							'"hpdProviderMailingAddress":{'+
							'								"Zip_Code":"",'+
							'								"Street_2":"",'+
							'								"Street_1":"",'+
							'								"State":"",'+
							'								"County":"",'+
							'								"City":""'+
							'							},'+
							'"hpdProviderLanguageSupported":"",'+
							'"hcSpecialization":"",'+
							'"givenName":""'+
							'}';
						  
		String iordeJSON =  '{'+
							  '"hpdMemberType":["Other"],'+
							  '"hpdHasAProvider" :null,'+
							  '"hpdHasAnOrg":null'+
	 						'}';
	 						
        SL_DSML_API_Wrapper.PUR pur = (SL_DSML_API_Wrapper.PUR)JSON.deserialize(purJSON,  SL_DSML_API_Wrapper.PUR.class);
        SL_DSML_API_Wrapper.ODE objODE = (SL_DSML_API_Wrapper.ODE)JSON.deserialize(odeJSON,  SL_DSML_API_Wrapper.ODE.class);
		SL_DSML_API_Wrapper.IDE objIDE  = (SL_DSML_API_Wrapper.IDE)JSON.deserialize(ideJSON,  SL_DSML_API_Wrapper.IDE.class);
		SL_DSML_API_Wrapper.IORDE objIORDE = (SL_DSML_API_Wrapper.IORDE)JSON.deserialize(iordeJSON,  SL_DSML_API_Wrapper.IORDE.class);
		
        // null
        SL_DSML_API_ListSearch.DslmListSearchResponse objRes = SL_DSML_API_ListSearch.dslmProviderSearch(null, null, null, null);
        System.assertEquals(objRes.ido.size(), 0);
        
        // Q7
        objRes = SL_DSML_API_ListSearch.dslmProviderSearch(objODE, objIDE, objIORDE, pur);
        System.assertEquals(objRes.ido.size(), 3);
        System.assertEquals(objRes.ido[0].uid,objContact.id);
        System.assertEquals(objRes.ido[0].givenName,objContact.FirstName );
        System.assertEquals(objRes.ioro.size(), 3);
        new SL_DSML_API_ListSearch.DslmListSearchResponse();
    }
    
    public static testmethod void testMembershipSearch ()
	{
		Account objAccount = new Account(name = 'Test Account 1');
        insert objAccount;
        
        Contact objContact = new Contact(lastName = 'Test Contact Prime',
                                      firstname = 'first',
                                      AccountId = objAccount.Id,
                                      NPI__c = 'NPI1');
        insert objContact; 
        Affiliation__c objAffiliation = new Affiliation__c(Organization__c = objAccount.Id,
															Provider__c = objContact.Id,
															Type__c = 'Other');
		insert objAffiliation;
		Affiliation__c objAffiliation1 = new Affiliation__c(Organization__c = objAccount.Id,
															Provider__c = objContact.Id,
															Type__c = 'Other');
		insert objAffiliation1;
		
		Affiliation__c objAffiliation2 = new Affiliation__c(Organization__c = objAccount.Id,
															Provider__c = objContact.Id,
															Type__c = 'Other');
		insert objAffiliation2;
		
		Electronic_Service__c objES = new Electronic_Service__c(Name='ES-01',Address__c ='Address-01',Certificate__c='Certificate-01', Payload__c='Payload-01',
        														Protocol__c= 'Protocol-01', Type__c='Type-01');
     	insert objES;
     	
     	List<Affiliation_Service__c> lstAS = new List<Affiliation_Service__c>{ new Affiliation_Service__c(Affiliation__c = objAffiliation.Id, Electronic_Service__c = objES.Id),
     																		   new Affiliation_Service__c(Affiliation__c = objAffiliation1.Id, Electronic_Service__c = objES.Id)};   
     	insert lstAS;
     	
     	String purJSON = '{'+
         				   '	"hpdRequestId":"test000000", '+
         				   '	"hpdId":"123456767888990000"'+
    					 '}';
    					 
    	String iordeJSON =  '{'+
							  '"hpdMemberType":["Other"],'+
							  '"hpdHasAProvider" :"'+ objContact.Id + '",'+
							  '"hpdHasAnOrg":"'+ objAccount.Id +'"'+
	 						'}';
	 						
	    String mursJSON = '['+
							 ' 	{'+
							 '		"uid":"'+objAffiliation.Id+'"'+
							 '	},'+
							 '	{'+
							 '		"uid":"'+objAffiliation1.Id+'"'+
							 '	},'+
							 '	{'+
							 '		"uid":"'+objAffiliation2.Id+'"'+
							 '	}'+
						   ']';
		SL_DSML_API_Wrapper.PUR pur = (SL_DSML_API_Wrapper.PUR)JSON.deserialize(purJSON, SL_DSML_API_Wrapper.PUR.class);
		SL_DSML_API_Wrapper.IORDE iorde = (SL_DSML_API_Wrapper.IORDE)JSON.deserialize(iordeJSON, SL_DSML_API_Wrapper.IORDE.class);
		List<SL_DSML_API_Wrapper.MUR> murs = (List<SL_DSML_API_Wrapper.MUR>)JSON.deserialize(mursJSON, List<SL_DSML_API_Wrapper.MUR>.class);
		
		//null
		SL_DSML_API_MembershipSearch.DslmMembershipSearchResponse objRes = SL_DSML_API_MembershipSearch.dslmMembershipSearch(null, null, null);
		System.assertEquals(objRes.ioro.size(), 0);
		
		//Q8
		objRes =  SL_DSML_API_MembershipSearch.dslmMembershipSearch(iorde, null, pur);
		System.assertEquals(objRes.ioro.size(), 3);
		//Q9
		objRes =  SL_DSML_API_MembershipSearch.dslmMembershipSearch(null, murs, pur);
		System.assertEquals(objRes.ioro.size(), 3);
		
		new SL_DSML_API_MembershipSearch();
		new SL_DSML_API_MembershipSearch.DslmMembershipSearchResponse();
	}
	
	public static testmethod void testUniqueServicesSearch()
	{
		List<Electronic_Service__c> lstESToInsert = new List<Electronic_Service__c>();
		Electronic_Service__c objES = new Electronic_Service__c(Name='ES-01',Address__c ='Address-01',Certificate__c='Certificate-01', Payload__c='Payload-01',
        														Protocol__c= 'Protocol-01', Type__c='Type-01');
     	insert objES;
     	Electronic_Service__c objES1 = new Electronic_Service__c(Name='ES-02',Address__c ='Address-01',Certificate__c='Certificate-01', Payload__c='Payload-01',
        														Protocol__c= 'Protocol-01', Type__c='Type-01');
     	insert objES1;
     	Electronic_Service__c objES2 = new Electronic_Service__c(Name='ES-03',Address__c ='Address-01',Certificate__c='Certificate-01', Payload__c='Payload-01',
        														Protocol__c= 'Protocol-01', Type__c='Type-01');
     	insert objES2;
     	Electronic_Service__c objES3 = new Electronic_Service__c(Name='ES-04',Address__c ='Address-01',Certificate__c='Certificate-01', Payload__c='Payload-01',
        														Protocol__c= 'Protocol-01', Type__c='Type-01');
     	insert objES3;
     	Electronic_Service__c objES4 = new Electronic_Service__c(Name='ES-05',Address__c ='Address-01',Certificate__c='Certificate-01', Payload__c='Payload-01',
        														Protocol__c= 'Protocol-01', Type__c='Type-01');
     	insert objES4;
     	Electronic_Service__c objES5 = new Electronic_Service__c(Name='ES-06',Address__c ='Address-01',Certificate__c='Certificate-01', Payload__c='Payload-01',
        														Protocol__c= 'Protocol-01', Type__c='Type-01');
     	insert objES5;
     	
     	
     	String purJSON = '{'+
         				   '	"hpdRequestId":"test000000", '+
         				   '	"hpdId":"123456767888990000"'+
    					 '}';
    					 
	   String sursJSON = '['+
							 ' 	{'+
							 '		"uid":"'+objES.Id+'"'+
							 '	},'+
							 '	{'+
							 '		"uid":"'+objES1.Id+'"'+
							 '	},'+
							 '	{'+
							 '		"uid":"'+objES2.Id+'"'+
							 '	},'+
							 ' 	{'+
							 '		"uid":"'+objES3.Id+'"'+
							 '	},'+
							 '	{'+
							 '		"uid":"'+objES4.Id+'"'+
							 '	},'+
							 '	{'+
							 '		"uid":"'+objES5.Id+'"'+
							 '	}'+
						   ']';
		SL_DSML_API_Wrapper.PUR pur = (SL_DSML_API_Wrapper.PUR)JSON.deserialize(purJSON, SL_DSML_API_Wrapper.PUR.class);
		List<SL_DSML_API_Wrapper.SUR> surs = (List<SL_DSML_API_Wrapper.SUR>)JSON.deserialize(sursJSON, List<SL_DSML_API_Wrapper.SUR>.class);
		
		//null
		SL_DSML_API_UniqueServicesSearch.DslmUniqueServicesSearchResponse objRes = SL_DSML_API_UniqueServicesSearch.dslmUniqueServicesSearch(null, null);
		System.assertEquals(objRes.sdo.size(), 0);
		
		//Q10
		objRes =  SL_DSML_API_UniqueServicesSearch.dslmUniqueServicesSearch(surs, pur);
		System.assertEquals(objRes.sdo.size(), 6);
		new SL_DSML_API_UniqueServicesSearch();
		new SL_DSML_API_UniqueServicesSearch.DslmUniqueServicesSearchResponse();
	}
	
	 public static testmethod void testCredentialWrite()
	 {
	 	Account objAccount = new Account(name = 'Test Account 1');
        insert objAccount;
        
        List<Contact> lstContact = new List<Contact>{new Contact(lastName = 'Test Contact Prime1', firstname = 'first', AccountId = objAccount.Id, NPI__c = 'NPI1'),
        											 new Contact(lastName = 'Test Contact Prime2', firstname = 'first', AccountId = objAccount.Id, NPI__c = 'NPI2')};
     	insert lstContact;
     	String pdoJSON = '{'+
         				   '	"hpdRequestId":"test000000", '+
         				   '	"hpdId":"123456767888990000"'+
    					 '}';
    	String npiJSON1 = '{'+
								'"npiNumber":"NPI1",'+
								'"npiStatus":"Active",'+
								'"access":"Active",'+
								'"ldo":[' + 
											'{'+
												'"licenseNumber":"1234567",' + 
												'"licenseState":"MI",'+
												'"licenseStatus":"Active"'+
											 '},'+
											 '{'+
												'"licenseNumber":"7654321",'+
												'"licenseState":"NY",'+
												'"licenseStatus":"Inactive"'+
											 '}'+
										']'+
							'}';
		String npiJSON2 =	'{'+
								'"npiNumber":"NPI2",'+
								'"npiStatus":"Suspended",'+
								'"access":"Active",'+
								'"ldo":['+
											'{'+
												'"licenseNumber":"2345678",'+
												'"licenseState":"MI",'+
												'"licenseStatus":"Active"'+
											'},'+
											'{'+
												'"licenseNumber":"8765432",'+
												'"licenseState":"NY",'+
												'"licenseStatus":"Surrendered"'+
											'}'+
									 ']'+
							'}';
    					 
    	SL_DSML_API_Wrapper.PDO pdo = (SL_DSML_API_Wrapper.PDO)JSON.deserialize(pdoJSON, SL_DSML_API_Wrapper.PDO.class);
    	SL_DSML_API_Wrapper.LDO ldo = new SL_DSML_API_Wrapper.LDO(null,null,null,null);
    	SL_DSML_API_Wrapper.NPI objNPI = new SL_DSML_API_Wrapper.NPI(null,null,null,null);
    	List<SL_DSML_API_Wrapper.NPI> npi = new List<SL_DSML_API_Wrapper.NPI>();
    	objNPI = (SL_DSML_API_Wrapper.NPI)JSON.deserialize(npiJSON1, SL_DSML_API_Wrapper.NPI.class);
    	npi.add(objNPI);
    	objNPI = (SL_DSML_API_Wrapper.NPI)JSON.deserialize(npiJSON2, SL_DSML_API_Wrapper.NPI.class);
    	npi.add(objNPI);
    	SL_DSML_API_CredentialWrite.dslmCredentialWrite(pdo, npi);
    	Contact objContact = new Contact(lastName = 'Test Contact Prime3', firstname = 'first', AccountId = objAccount.Id, NPI__c = 'NPI2992');
    	insert objContact;
    	SL_DSML_API_CredentialWrite.DslmCredentialWriteResponse objCWR = SL_DSML_API_CredentialWrite.dslmCredentialWrite(pdo, npi);
    	System.assertEquals(objCWR.iur.size(), 2);
	}
}