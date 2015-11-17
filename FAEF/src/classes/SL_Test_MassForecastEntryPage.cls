/**
* \arg ClassName  		: SL_Test_LotEntryHandler
* \arg JIRATicket 		: FAEF-37
* \arg CreatedOn  		: 10/10/2014
* \arg LastModifiedOn   : 4/8/2015
* \arg CreatedBy  		: Dhanalakshmi
* \arg ModifiedBy 		: Pankaj Ganwani
* \arg Description		: Test class for SL_MassForecastEntryPage
*/
@isTest  
private with sharing class SL_Test_MassForecastEntryPage 
{
	static testMethod void Test_MassForecastEntryPage()    
	{      
		
		Profile objProfile = [SELECT Name,
									 Id 
								FROM Profile 
								Where Name='Chatter External User'];
		
		User objUser1 = new User(Lastname = 'User-001',
								 Email = 'user0677601@gmail.com',
								 Username = 'use5666r001@gmail.com',
								 ProfileId = objProfile.Id,  
        						 Alias = 'us56er01', 
        						 TimeZoneSidKey = 'GMT', 
        						 LocaleSidKey = 'en_US',
        						 EmailEncodingKey = 'ISO-8859-1', 
        						 LanguageLocaleKey = 'en_US');
        insert objUser1;
        
        Forecast_Percents__c objFCPercent = new Forecast_Percents__c(Name='Renewal Rent',
        															 Percent__c=50);
        
        insert objFCPercent;
		
		Letter_of_Intent__c objLOI = new Letter_of_Intent__c(Facility_Rating__c='1');
		insert objLOI;
		
		Date currentLeaseExpirationDt = Date.newInstance(2014,12, 31);
		Date baseLeaseTerminationDt = Date.newInstance(2014,2, 31);
		system.debug('==dt=='+currentLeaseExpirationDt);
		Schedule__c objSchedule = new Schedule__c(Name='Test-Schedule-01',
												  Project_Manager__c=objUser1.Id,
												  Count_for_A_A__c='Yes',
												  Letter_of_Intent__c=objLOI.Id,
												  Forecast_Outcome__c='Renewal Rent',
												  Current_Lease_Expiration_Date__c=currentLeaseExpirationDt,
												  Base_Lease_Termination_Date__c=baseLeaseTerminationDt
												 );
		insert objSchedule;
		
		Equipment__c objEquipment = new Equipment__c(Name='Test-Eq-01',
													 Quantity__c=2,
													 Unit_Price__c=20,
													 Schedule__c=objSchedule.Id);
		insert objEquipment;
		
		list<String> queryFields = new list<String>();
		queryFields.addAll(getFields(Schedule__c.SObjectType, false, false));
		
		String schedQuery = 'SELECT ' + String.Join(queryFields, ', ') + ' FROM Schedule__c ';
		schedQuery += 'WHERE Id = \'' + objSchedule.Id + '\'';
		list<Schedule__c> scheds = (list<Schedule__c>)Database.Query(schedQuery);
		objSchedule = scheds.get(0);
		
		
		Annual_Forecast__c objAnnualForecast = new Annual_Forecast__c(Schedule__c=objSchedule.Id,
																	 Fiscal_Year__c='2014');
																	
		insert objAnnualForecast;
		
		Quarterly_Forecast__c objQuarterlyForecast01 = new Quarterly_Forecast__c(Annual_Forecast__c=objAnnualForecast.Id,
																			  	 Quarter__c='Q1',
																			     Forecast_Amount__c=100
																			     );
		
		insert objQuarterlyForecast01;
		
		Quarterly_Forecast__c objQuarterlyForecast02 = new Quarterly_Forecast__c(Annual_Forecast__c=objAnnualForecast.Id,
																			     Quarter__c='Q2',
																			     Forecast_Amount__c=200
																			     );
		
		insert objQuarterlyForecast02;
		
		Quarterly_Forecast__c objQuarterlyForecast03 = new Quarterly_Forecast__c(Annual_Forecast__c=objAnnualForecast.Id,
																			  	 Quarter__c='Q3',
																			  	 Forecast_Amount__c=300
																			  	 );
		
		insert objQuarterlyForecast03;
		
		Quarterly_Forecast__c objQuarterlyForecast04 = new Quarterly_Forecast__c(Annual_Forecast__c=objAnnualForecast.Id,
																			     Quarter__c='Q4',
																			     Forecast_Amount__c=400
																			     );
		
		insert objQuarterlyForecast04;
		SL_MassForecastEntryPage objSlForecastPage = new SL_MassForecastEntryPage();
		objSlForecastPage.getForeCastYears();
		objSlForecastPage.showSelectedYearForecasts();
		objSlForecastPage.save3();
		objSlForecastPage.cancel();
		objSlForecastPage.getPayments(objSchedule);  
		
		
		
		//system.assertEquals(Extend_Price__c);
		
		
	}

	public static set<string> getFields(Schema.SObjectType objectType, boolean filterNonUpdatable, 
										boolean filterUnique)
    {
        Map<String, Schema.SObjectField> fMap = objectType.getDescribe().Fields.getMap();
        set<string> validFields = new set<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if ((!filterNonUpdatable || fd.isUpdateable()) &&
                	(!filterUnique || !fd.isUnique())){ // field is creatable
                    validFields.add(fd.getName());
                }
            }
        }
        return validFields;
    }
}