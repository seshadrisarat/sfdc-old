/**
	*  ClassName      : SL_Test_OpportunityHandler
	*  JIRATicket     : STARGAS-5, STARGAS-19, STARGAS-20, STARGAS-21, STARGAS-24, STARGAS-26, STARGAS-32, STARGAS-35 and STARGAS-39
	*  CreatedOn      : 15/MAY/2014
	*  LastModifiedOn : 10/Feb/2015
	*  CreatedBy      : Pankaj Ganwani
	*  ModifiedBy     : Pankaj Ganwani
	*  Description    : This test class is used for checking the functionality of Zone data, Zone AR, Service Company, Sold by, Sold By - RepID and Owner Id field values on Opportunity record for SL_Opportunity trigger.
*/
@isTest
private class SL_Test_OpportunityHandler 
{
    static testMethod void SL_Opportunity_Handler() 
    {
		Profile objProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
		
		User objUSer = new User(Alias = 'User1', Email='user1@user.com', EmailEncodingKey='UTF-8', LastName='Testing', 
	    						LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = objProfile.Id, 
	    						TimeZoneSidKey='America/Los_Angeles', UserName='us1er211.79874@user.com', Sales_Rep_ID__c = 'IF');
	    insert objUSer;
	    
	    User objUSer1 = new User(Alias = 'User1', Email='user1@user.com', EmailEncodingKey='UTF-8', LastName='Testing', 
	    						LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = objProfile.Id, 
	    						TimeZoneSidKey='America/Los_Angeles', UserName='us1e11r211.79874@user.com', Sales_Rep_ID__c = '45');
	    insert objUSer1;
	    						
		String strAccountRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =: 'Prospect' AND SobjectType =: 'Account' AND IsPersonType = true LIMIT 1].Id;
		String strOilRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =:'Oil' AND SobjectType =: 'Opportunity' LIMIT 1].Id;
		String strEquipmentRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =:'Equipment_Sale' AND SobjectType =: 'Opportunity' LIMIT 1].Id; 
		
		DivOilPriceGrp__c objDivOilPriceGrp = new DivOilPriceGrp__c(Name = 'Test DivOilPrice');
		insert objDivOilPriceGrp;
		
		Price_Table__c objPriceType = new Price_Table__c(Division_Group__c = '2', Variable_Price__c = 123, IsActive__c = true);
		insert objPriceType;
		
		Division__c objDiv = new Division__c(Name='test', Division__c ='41', Database__c = '10',Service_Company__c = 'DivCompany', DivOilPriceGrpLU__c = objDivOilPriceGrp.Id, Division_Oil_Pricing_Group__c = '2');
		insert objDiv;
		
		Territory__c objTerr = new Territory__c(Name='TestTerriority', Division__c = objDiv.Id, Zip_Postal_Code__c = '1140',RESS_Rep__c = objUSer.Id);
		insert objTerr;
		
		Account objAcc = new Account(LastName='TestAcc', Territory__c = objTerr.Id);
		insert objAcc;
		
		Zone_Data__c objZoneData = new Zone_Data__c(Name = '41114010' , Delivery_Zone__c = '1114' );
		insert  objZoneData;
		
		Zone_AR__c objZoneAR = new Zone_AR__c(Name = '10411114' );
		insert  objZoneAR;
		
		Opportunity objOpp = new Opportunity(Name='TestOppt', CloseDate=Date.today(), RecordTypeId = strEquipmentRecordTypeId, StageName='Open', Territory__c = objTerr.Id, AccountId = objAcc.Id, Delivery_Street2__c = '10', HHAU__c = 'Email');
		insert objOpp;
		
		//stargas 26 test 
		Account objAcc2 = new Account(LastName = 'Test Account 2', RecordTypeId = strAccountRecordTypeId, Territory__c = objTerr.Id, HHAU__c = 'Email', Source_Client_Account__c = objAcc.id);
		insert objAcc2;
		
		Service_Contract__c objSC = new Service_Contract__c(Client_Prospect__c = objAcc.id);
		insert objSC;
		
		Opportunity objOpp2 = new Opportunity(Name = 'TestOpp2', AccountId = objAcc2.id, RecordTypeId = strOilRecordTypeId, Territory__c = objTerr.Id, StageName = 'Open', HHAU__c = 'Email', CloseDate=Date.today());
		insert objOpp2;
		
		
		//end
		
		system.assertEquals('DivCompany',[select Service_Company_picklist__c from Opportunity where Id =: objOpp.Id].Service_Company_picklist__c);
		
		system.assertEquals(objZoneData.Id,[select Zone_Data__c from Opportunity where Id =: objOpp.Id].Zone_Data__c );
		
		//System.assertEquals(123, [select Variable__c from Opportunity where Id =: objOpp.Id].Variable__c);
		
		system.assertEquals(objZoneAR.Id,[select Zone_AR__c from Opportunity where Id =: objOpp.Id].Zone_AR__c );
		
		system.assertEquals(objUSer.Id,[select OwnerId from Opportunity where Id =: objOpp.Id].OwnerId);
		
		//System.assertEquals(Userinfo.getUserId(), [select Sold_By__c from Opportunity where Id =: objOpp.Id].Sold_By__c);
		
		Price_Table__c objPriceType1 = new Price_Table__c(Division_Group__c = '3', Variable_Price__c = 2.903, IsActive__c = true);
		insert objPriceType1;
		
		Division__c objDiv1 = new Division__c(Name='test1', Division__c ='82', Database__c = '20',Service_Company__c = 'DivCompany1', DivOilPriceGrpLU__c = objDivOilPriceGrp.Id, Division_Oil_Pricing_Group__c = '3');
		insert objDiv1;
		
		Territory__c objTerr1 = new Territory__c(Name='TestTerriority1', Division__c = objDiv1.Id, Zip_Postal_Code__c = '2280', RESS_Rep__c = objUSer.Id);
		insert objTerr1;
		
		Zone_Data__c objZoneData1 = new Zone_Data__c(Name = '82228020' , Delivery_Zone__c = '2228' );
		insert  objZoneData1;
		
		Zone_AR__c objZoneAR1 = new Zone_AR__c(Name = '20822228' );
		insert  objZoneAR1;
		
		//Id = objOpp.Id, 
		objOpp.Territory__c = objTerr1.Id;
		objOpp.Delivery_Street2__c = '20';
		objOpp.Sold_By__c = objUSer1.Id;
		update objOpp;
		
		system.assertEquals('DivCompany1',[select Service_Company_picklist__c from Opportunity where Id =: objOpp.Id].Service_Company_picklist__c);
		
		system.assertEquals(objZoneData1.Id,[select Zone_Data__c from Opportunity where Id =: objOpp.Id].Zone_Data__c );
		
		//System.assertEquals(2.903, [select Variable__c from Opportunity where Id =: objOpp.Id].Variable__c);
		
		system.assertEquals(objZoneAR1.Id,[select Zone_AR__c from Opportunity where Id =: objOpp.Id].Zone_AR__c );
		
		//system.assertEquals('45',[select Sold_By_RepID__c from Opportunity where Id =: objOpp.Id].Sold_By_RepID__c );
		
		objOpp.Territory__c = null;
		update objOpp;
		
		//System.assertEquals(null, [select Variable__c from Opportunity where Id =: objOpp.Id].Variable__c);
		
    }
}