/**
* \arg ClassName   : SL_MassForecastEntryPage
* \arg JIRATicket  : FAEF-37
* \arg CreatedOn   : 9/25/2014  
* \arg ModifiedBy  : Dhanalakshmi
* \arg Description : 
*/
public with sharing class SL_MassForecastEntryPage 
{	  
	
	/* Start - Variables */
	public String strSelectedForecastYear 					{	get;set;	}         //To store Forecast Year selecetd from Picklist
	public List<forecastWrapper> lstforecastWrapper 		{	get;set;	}         //To store the Annual Forecast data.
	public List<String> lstHeaders							{	get;set;	}
	public Id scheduleId									{	get;set;	}
	public Decimal  decPercent								{	get;set;	}
	public Boolean saveChanges								{	get;set;	}
	
	private Map<String, Decimal> mapForeCastPercent;
	private Map<Id, Map<String, Quarterly_Forecast__c>> mapScheduleIdToMapQuarter_QuarterlyForecast;
	private Map<Id,Decimal> mapScheduleIdToForecastPercent;
	private Map<Id, String> mapScheduleIdToEndForecastQuater;
	/* End - Variables */
	
	/* Start - Main Constructor */
	public SL_MassForecastEntryPage()
	{
		intialization();
		lstHeaders = new List<String>{'Account','Schedule', 'Amount', 'Expiration','Projected Outcome','Percent','Cycles','Q1','Q2','Q3','Q4'};
		mapForeCastPercent = getForeCastPercent();
		lstforecastWrapper = getForeCastData();
	}
	/* End - Main Constructor */
	
	/* Start - Wrapper Class */
	public class forecastWrapper
	{
		public Schedule__c objSchedule		{	get;set;	}
		public Decimal decPercent			{	get;set;	}
		public Decimal decQ1				{	get;set;	}
		public Decimal decQ2				{	get;set;	}
		public Decimal decQ3				{	get;set;	}
		public Decimal decQ4				{	get;set;	}
		public String strEndForecast		{	get;set;	}
		public Boolean endQ1				{	get;set;	}
		public Boolean endQ2				{	get;set;	}
		public Boolean endQ3				{	get;set;	}
		public Boolean endQ4				{	get;set;	}
		public Boolean currentChanged		{	get;set;	}
		public Boolean futureChanged		{	get;set;	}
		private String strYear;
		
		/* Start - Inner Constructor */
		public forecastWrapper(Schedule__c objSchedule, Decimal decPercent, Decimal decQ1, Decimal decQ2, Decimal decQ3, Decimal decQ4,String strYear,
							   Boolean endQ1,Boolean endQ2,Boolean endQ3,Boolean endQ4,String strEndForecast)
		{
			this.objSchedule = objSchedule;
			this.decPercent = decPercent;
			this.decQ1 = decQ1.setScale(2);
			this.decQ2 = decQ2.setScale(2);
			this.decQ3 = decQ3.setScale(2);
			this.decQ4 = decQ4.setScale(2);
			this.strYear = strYear;
			this.endQ1 = endQ1;
			this.endQ2 = endQ2;
			this.endQ3 = endQ3;
			this.endQ4 = endQ4;
			this.strEndForecast = strEndForecast;
			this.currentChanged = false;
			this.futureChanged = false;
		}
		/* End - Inner Constructor */
	}
	/* End - Wrapper Class */
	
	
	/*
    	* MethodName 	: intialization.
        * param 		: None
        * Description	: to intialize all global variables.
    */
    private void intialization()
    {
    	strSelectedForecastYear = String.valueOf(date.today().year());
    	lstforecastWrapper = new list<forecastWrapper>();
    	lstHeaders = new List<String>();
    	mapForeCastPercent = new Map<String, Decimal>();
    	mapScheduleIdToMapQuarter_QuarterlyForecast = new Map<Id, Map<String, Quarterly_Forecast__c>>();
    	mapScheduleIdToForecastPercent = new Map<Id,Decimal>();
    	saveChanges = false;
    }
    /* End */
	
	/*
    	* MethodName 	: getForeCastYears.
        * param 		: None
        * Description	: prepare a list of years to select from dropdown.
    */
	public List<Selectoption> getForeCastYears()
	{ 
		List<SelectOption> options = new List<SelectOption>();
		
		Integer thisYear = date.today().year();
		for(integer i = 0; i<=5; i++)
		{
  			options.add(new SelectOption(String.valueOf(thisYear + i),String.valueOf(thisYear + i)));
		}
		return options;
	}
	/* End */
	
	/*
    	* MethodName 	: getForeCastPercent.
        * param 		: None
        * Description	: To get the percent value related to all the projected outcome values of schedule from custom setting Forecast_Percents__c.
    */
	private Map<String, Decimal> getForeCastPercent()
	{
		Map<String, Decimal> mapNameForeCastPercent = new Map<String, Decimal>();
		for(Forecast_Percents__c objFCPercent : Forecast_Percents__c.getall().values())
		{
			mapNameForeCastPercent.put(objFCPercent.Name, objFCPercent.Percent__c);
		}
		return mapNameForeCastPercent;
	}
	/* End */
	
	/*
    	* MethodName 	: showSelectedYearForecasts.
        * param 		: None
        * Description	: This method is called on change of selected year.
    */
	public void showSelectedYearForecasts()
	{	
		if(saveChanges){
			save3();
		}
		lstforecastWrapper = getForeCastData();
	}
	
	/*
    	* MethodName 	: getForeCastData.
        * param 		: None
        * Description	: This method is used to get the Account,Annual Forecast and Quarter Forecast records related to Schedule.
    */
	private List<forecastWrapper> getForeCastData()
	{
		List<forecastWrapper> lstForeCast = new List<forecastWrapper>();
		
		Map<Id,Annual_Forecast__c> mapScheduleIdToAnnualForecast = new Map<Id,Annual_Forecast__c>();
		mapScheduleIdToEndForecastQuater = new Map<Id, String>();
		mapScheduleIdToMapQuarter_QuarterlyForecast = new Map<Id, Map<String, Quarterly_Forecast__c>>();
		
		Date dt = Date.newInstance(Integer.valueOf(strSelectedForecastYear), 12, 31);
		
		Map<Id, Schedule__c> mapIdToSchedule = new Map<Id, Schedule__c>([SELECT Id, Name, Extension_Period_Months__c,
												   								Payment_Frequency__c, Account_Lookup__r.Name, Forecast_Outcome__c, 
																			    Forecast_Percent__c, Forecast_Renewal_Cycles__c, Total_Equipment_Cost__c, 
															 				    Base_Lease_Termination_Date__c, Financial_Product__c, FMA_Extension_Notice_Received__c,
															 				    FMA_Renewal_Run__c, Contract_Extension_Renewal_Frequency__c, Current_Lease_Expiration_Date__c,
															 				    Contract_Extension_Renewal_Rental_Amount__c, Payment_Amount__c,
															 				    (SELECT Id, Q1_Forecast__c, Q2_Forecast__c, Q3_Forecast__c, Q4_Forecast__c
															 					 FROM Annual_Forecasts__r 
															 					 WHERE Fiscal_Year__c =: strSelectedForecastYear LIMIT 1) 
															 			   FROM Schedule__c 
															 			   WHERE Final_Outcome__c = ''
															 			   AND Base_Lease_Termination_Date__c != null
															 			   AND (CALENDAR_YEAR(Base_Lease_Termination_Date__c) <=: Integer.valueOf(strSelectedForecastYear))
															 			   AND  Base_Lease_Termination_Date__c !=: dt 
															 			   AND Financial_Product__c != '$1.00 Purchase Option']);
															 			   //AND Name LIKE 'SL_TEST%' LIMIT 100]);
															 			    
	    System.debug(LoggingLevel.ERROR, mapIdToSchedule);
			
		for(Annual_Forecast__c objAFCast : [SELECT Id, 
												   Schedule__c,
												   Fiscal_Year__c, 
												   (SELECT Id,
												   		   Annual_Forecast__c,
												   		   End_Forecast__c,
												   		   Quarter__c
												   	  FROM Quarterly_Forecasts__r)
											  FROM Annual_Forecast__c 
											 WHERE Schedule__c IN: mapIdToSchedule.keySet()])
		{
			if(!objAFCast.Quarterly_Forecasts__r.isEmpty() )
			{
				for(Quarterly_Forecast__c objQFC : objAFCast.Quarterly_Forecasts__r)
				{
					if(objQFC.End_Forecast__c && objAFCast.Fiscal_Year__c == strSelectedForecastYear)
					{
						mapScheduleIdToEndForecastQuater.put(objAFCast.Schedule__c, objQFC.Quarter__c);
					}
						
					if(!mapScheduleIdToMapQuarter_QuarterlyForecast.containsKey(objAFCast.Schedule__c))	
					{
						mapScheduleIdToMapQuarter_QuarterlyForecast.put(objAFCast.Schedule__c, new Map<String, Quarterly_Forecast__c>());
					}
						
					mapScheduleIdToMapQuarter_QuarterlyForecast.get(objAFCast.Schedule__c).put(objQFC.Quarter__c, objQFC);
					
					if(mapIdToSchedule.containsKey(objAFCast.Schedule__c) && objQFC.End_Forecast__c && objAFCast.Fiscal_Year__c < strSelectedForecastYear 
					   && mapIdToSchedule.get(objAFCast.Schedule__c).Base_Lease_Termination_Date__c.year() < Integer.valueOf(strSelectedForecastYear))
					   {
				 			mapIdToSchedule.remove(objAFCast.Schedule__c);
					   }	
				}
			}
		}														 			   
		
		for(Schedule__c objSchedule : mapIdToSchedule.values())
		{
			Map<Date, Decimal> paymentMap = getPayments(objSchedule);
			
			Decimal q1 = 0.0;
			Decimal q2 = 0.0;
			Decimal q3 = 0.0;
			Decimal q4 = 0.0;
			
			/*for(Date d : paymentMap.keySet())
			{
				if(d.year() == Integer.valueOf(strSelectedForecastYear))
				{
					if(d.month() < 4)
					{
						q1 += paymentMap.get(d);
					}else if(d.month() < 7)
					{
						q2 += paymentMap.get(d);
					}else if(d.month() < 10)
					{
						q3 += paymentMap.get(d);
					}else
					{
						q4 += paymentMap.get(d);
					}
				}	
			}*/
			
			map<String , Decimal> mapQuarterToPayment = calculateQuarterlyPayments(objSchedule);
			
			if(mapQuarterToPayment.containsKey('Q1'))
				q1 = mapQuarterToPayment.get('Q1');
			if(mapQuarterToPayment.containsKey('Q2'))
				q2 = mapQuarterToPayment.get('Q2');
			if(mapQuarterToPayment.containsKey('Q3'))
				q3 = mapQuarterToPayment.get('Q3');
			if(mapQuarterToPayment.containsKey('Q4'))
				q4 = mapQuarterToPayment.get('Q4');
		
			if(objSchedule.Annual_Forecasts__r.size() > 0 || q1 != 0.0 || q2 != 0.0 || q3 != 0.0 || q4 != 0.0)
			{	
				objSchedule.Forecast_Renewal_Cycles__c = objSchedule.Forecast_Renewal_Cycles__c == null ? 0 : objSchedule.Forecast_Renewal_Cycles__c; 
				lstForeCast.add(new forecastWrapper(objSchedule,
													(objSchedule.Forecast_Percent__c!=null && objSchedule.Forecast_Percent__c!=0.00)?objSchedule.Forecast_Percent__c:
														(objSchedule.Forecast_Outcome__c != null && mapForeCastPercent.containsKey(objSchedule.Forecast_Outcome__c))? 
															mapForeCastPercent.get(objSchedule.Forecast_Outcome__c) : 0.00, 
													(objSchedule.Annual_Forecasts__r.size() > 0 && objSchedule.Annual_Forecasts__r[0].Q1_Forecast__c > 0.0) ? objSchedule.Annual_Forecasts__r[0].Q1_Forecast__c 
																								 : q1,
													(objSchedule.Annual_Forecasts__r.size() > 0 && objSchedule.Annual_Forecasts__r[0].Q2_Forecast__c > 0.0) ? objSchedule.Annual_Forecasts__r[0].Q2_Forecast__c 
																							     : q2,
													(objSchedule.Annual_Forecasts__r.size() > 0 && objSchedule.Annual_Forecasts__r[0].Q3_Forecast__c > 0.0) ? objSchedule.Annual_Forecasts__r[0].Q3_Forecast__c 
																							     : q3,
													(objSchedule.Annual_Forecasts__r.size() > 0 && objSchedule.Annual_Forecasts__r[0].Q4_Forecast__c > 0.0) ? objSchedule.Annual_Forecasts__r[0].Q4_Forecast__c 
																			                     : q4,
													strSelectedForecastYear,
													mapScheduleIdToEndForecastQuater.get(objSchedule.Id)=='Q1'?true:false,
													mapScheduleIdToEndForecastQuater.get(objSchedule.Id)=='Q2'?true:false,
													mapScheduleIdToEndForecastQuater.get(objSchedule.Id)=='Q3'?true:false,
													mapScheduleIdToEndForecastQuater.get(objSchedule.Id)=='Q4'?true:false,
													strSelectedForecastYear));
			}									
		}	
		System.debug(LoggingLevel.ERROR, lstForeCast);
		return lstForeCast;
	}
	/* End */
	
	/*
	 *  MethodName: calculateQuarterlyPayments
	 *  Param: objSchedule represents the schedule we're interested in
	 *  Description: return a map of Quarters to the amount that is to be paid 
	 *   
	 */
	 private map<String, Decimal> calculateQuarterlyPayments(Schedule__c objSchedule)
	 {
	 	Integer extensionPeriod = objSchedule.Extension_Period_Months__c!=null ? Integer.valueOf(objSchedule.Extension_Period_Months__c) : 3;
		Integer renewalCycles = objSchedule.Forecast_Renewal_Cycles__c!=null ? Integer.valueOf(objSchedule.Forecast_Renewal_Cycles__c) : 0;
		Integer renewalPeriodMonths = (Integer)(extensionPeriod * renewalCycles);//number of months in renewal period
		
		Integer paymentCount = extensionPeriod;//number of renewal payments to make
		Integer paymentMonthSpan = 1; //defines number of months between payments
		Decimal paymentRemainder = 0.0; //used when the extension term is not evenly divisble by the payment freqency
		
		Integer intRemainingMonths =  renewalPeriodMonths;
		Date dtExpirationDate = objSchedule.Base_Lease_Termination_Date__c;
		Decimal paymentAmount = (objSchedule.Payment_Amount__c != null) ? objSchedule.Payment_Amount__c : 0.00; 	
		String frequency =  (objSchedule.Payment_Frequency__c != null) ? objSchedule.Payment_Frequency__c : 'monthly' ; 
		Double dbPercent = (objSchedule.Forecast_Percent__c !=null && objSchedule.Forecast_Percent__c!=0.00) 
						    ? objSchedule.Forecast_Percent__c 
						    : mapForeCastPercent.containsKey(objSchedule.Forecast_Outcome__c)
						    ? mapForeCastPercent.get(objSchedule.Forecast_Outcome__c) : 0.00;
		
		DateTime endOfRenewalPeriod = dtExpirationDate.addMonths(renewalPeriodMonths);//last renewal month
		DateTime forecastedPurchaseDate = endOfRenewalPeriod.addMonths(1);//puchase payment month
		Decimal monthlyPayment = ((paymentAmount != null) ? (paymentAmount / 1) : 0.00);//Added by Lodhi
		Decimal dbTotalFinancedAmount = objSchedule.Total_Equipment_Cost__c;
 				
		if(frequency == 'annual')
		{
			paymentCount = paymentCount/12;
			paymentMonthSpan = 12;
			monthlyPayment = paymentAmount/12; //Added by Lodhi
		}
		else if(frequency == 'semi-annual')
		{
			paymentCount = paymentCount/6;
			paymentMonthSpan = 6;
			monthlyPayment = paymentAmount/6; //Added by Lodhi
		}
		else if(frequency == 'quarterly')
		{
			paymentCount = paymentCount/3;
			paymentMonthSpan = 3;
			monthlyPayment = paymentAmount/3; //Added by Lodhi
		}
		
		Map<String, Decimal> mapQuarterToPayment = new Map<String,Decimal>();
		
 		Date lastPaymentDate = dtExpirationDate ;
		lastPaymentDate = lastPaymentDate.addMonths(1); 
		
		/*if(frequency == 'annual' || frequency == 'semi-annual' || frequency == 'monthly')
		{*/
    		while(lastPaymentDate <= endOfRenewalPeriod )//Date.newInstance(endOfRenewalPeriod.year(), endOfRenewalPeriod.month(), endOfRenewalPeriod.day())
    		{
    			if(intRemainingMonths <= renewalPeriodMonths && intRemainingMonths > 0)
    			{
    				if(strSelectedForecastYear == String.valueOf(lastPaymentDate.year()))
    				{
    					if(mapQuarterToPayment.containsKey( monthToQuarter( lastPaymentDate.month() ) ) )
    					{
    						mapQuarterToPayment.put(monthToQuarter( lastPaymentDate.month() ) , (mapQuarterToPayment.get(monthToQuarter( lastPaymentDate.month() ))) + (monthlyPayment * paymentMonthSpan) ) ;
    					}	
    					else
    					{
    						mapQuarterToPayment.put(monthToQuarter( lastPaymentDate.month() ) , (monthlyPayment * paymentMonthSpan) ) ;
    					}	
    				}
    			}
    			if( intRemainingMonths < paymentMonthSpan && intRemainingMonths > 0)
    			{
    				if(strSelectedForecastYear == String.valueOf(lastPaymentDate.year()))
    				{
    					mapQuarterToPayment.put(monthToQuarter( lastPaymentDate.month() ) , (monthlyPayment * intRemainingMonths) ) ;
    				}
    			}
    			intRemainingMonths  -= paymentMonthSpan;
    			lastPaymentDate = lastPaymentDate.addMonths(paymentMonthSpan);
    		}
		//}
		/*else if(frequency == 'quarterly')
		{
		    for(Integer intIndex = 1 ; intIndex <= renewalPeriodMonths ; intIndex++ )
		    {
		        if(strSelectedForecastYear == String.valueOf(lastPaymentDate.year()))
    		    {      
    		        if(mapQuarterToPayment.containsKey(monthToQuarter( lastPaymentDate.month() )))
    		           mapQuarterToPayment.put(monthToQuarter( lastPaymentDate.month() ) , mapQuarterToPayment.get(monthToQuarter( lastPaymentDate.month() )) + monthlyPayment);
    		        else
        	           mapQuarterToPayment.put(monthToQuarter( lastPaymentDate.month() ) , monthlyPayment);
        	       
        	        lastPaymentDate = lastPaymentDate.addMonths(1);    
    		    }
		    }
		}*/
		
		Date dtFinalPayment = Date.newInstance(forecastedPurchaseDate.year(), forecastedPurchaseDate.month(), forecastedPurchaseDate.day());
		
		if(String.valueOf(dtFinalPayment.year()) == strSelectedForecastYear)
		{
			if(mapQuarterToPayment.containsKey(monthToQuarter(dtFinalPayment.month() )))
			{
				mapQuarterToPayment.put(monthToQuarter( dtFinalPayment.month() ) , (mapQuarterToPayment.get(monthToQuarter( dtFinalPayment.month() ))) + getQuarterValue(objSchedule) ) ;
			}
			else
			{
				mapQuarterToPayment.put(monthToQuarter( dtFinalPayment.month() ) , getQuarterValue(objSchedule) ) ;
			}
		}
		return mapQuarterToPayment;			  
	 }
	 
	 private String monthToQuarter(Integer month)
	 {
	 	if(month >= 1 && month < 4)
	 		return 'Q1';
	 	else if(month >= 4 && month < 7)
	 		return 'Q2';
	 	else if(month >= 7 && month < 10)
	 		return 'Q3';
	 	else
	 		return 'Q4';
	 }
	
	/*
	 *  MethodName: getPayments
	 *  Param: objSchedule represents the schedule we're interested in
	 *  Description: return a map of dates to the amount that is to be paid on that date 
	 *  ModifiedBy: Lodhi
	 */
	public Map<Date, Decimal> getPayments(Schedule__c objSchedule)
	{
		Integer extensionPeriod = objSchedule.Extension_Period_Months__c!=null ? Integer.valueOf(objSchedule.Extension_Period_Months__c) : 3;
		Integer renewalCycles = objSchedule.Forecast_Renewal_Cycles__c!=null ? Integer.valueOf(objSchedule.Forecast_Renewal_Cycles__c) : 0;
		Integer renewalPeriodMonths = (Integer)(extensionPeriod * renewalCycles);//number of months in renewal period
		
		Integer paymentCount = extensionPeriod;//number of renewal payments to make
		Integer paymentMonthSpan = 1; //defines number of months between payments
		Decimal paymentRemainder = 0.0; //used when the extension term is not evenly divisble by the payment freqency
		
		Integer intRemainingMonths =  renewalPeriodMonths;
		Date dtExpirationDate = objSchedule.Base_Lease_Termination_Date__c;
		Decimal paymentAmount = (objSchedule.Payment_Amount__c != null) ? objSchedule.Payment_Amount__c : 0.00; 	
		String frequency =  (objSchedule.Payment_Frequency__c != null) ? objSchedule.Payment_Frequency__c : 'monthly' ; 
		Double dbPercent = (objSchedule.Forecast_Percent__c !=null && objSchedule.Forecast_Percent__c!=0.00) 
						    ? objSchedule.Forecast_Percent__c 
						    : mapForeCastPercent.containsKey(objSchedule.Forecast_Outcome__c)
						    ? mapForeCastPercent.get(objSchedule.Forecast_Outcome__c) : 0.00;
		
		DateTime endOfRenewalPeriod = dtExpirationDate.addMonths(renewalPeriodMonths);//last renewal month
		DateTime forecastedPurchaseDate = endOfRenewalPeriod.addMonths(1);//puchase payment month
		Decimal monthlyPayment = ((paymentAmount != null) ? (paymentAmount / 1) : 0.00);//Added by Lodhi
		Decimal dbTotalFinancedAmount = objSchedule.Total_Equipment_Cost__c;
 				
		if(frequency == 'annual')
		{
			paymentCount = paymentCount/12;
			paymentMonthSpan = 12;
			monthlyPayment = paymentAmount/12; //Added by Lodhi
		}
		else if(frequency == 'semi-annual')
		{
			paymentCount = paymentCount/6;
			paymentMonthSpan = 6;
			monthlyPayment = paymentAmount/6; //Added by Lodhi
		}
		else if(frequency == 'quarterly')
		{
			paymentCount = paymentCount/3;
			paymentMonthSpan = 3;
			monthlyPayment = paymentAmount/3; //Added by Lodhi
		}
		
		Map<Date, Decimal> mapDateToPayment = new Map<Date,Decimal>();
		
 		Date lastPaymentDate = dtExpirationDate ;
		lastPaymentDate = lastPaymentDate.addMonths(1); 
		
		/*if(frequency == 'annual' || frequency == 'semi-annual' || frequency == 'monthly')
		{*/
    		while(lastPaymentDate <= endOfRenewalPeriod )//Date.newInstance(endOfRenewalPeriod.year(), endOfRenewalPeriod.month(), endOfRenewalPeriod.day())
    		{
    			if(intRemainingMonths <= renewalPeriodMonths && intRemainingMonths > 0)
    			{
    				if(mapDateToPayment.containsKey( lastPaymentDate) )
    				{
    					mapDateToPayment.put( lastPaymentDate , (mapDateToPayment.get( lastPaymentDate) + (monthlyPayment * paymentMonthSpan))) ;
    				}	
    				else
    				{
    					mapDateToPayment.put( lastPaymentDate , (monthlyPayment * paymentMonthSpan) ) ;
    				}	
    			}
    			if( intRemainingMonths < paymentMonthSpan && intRemainingMonths > 0)
    			{
    				mapDateToPayment.put( lastPaymentDate , (monthlyPayment * intRemainingMonths) ) ;	
    			}
    			intRemainingMonths  -= paymentMonthSpan;
    			lastPaymentDate = lastPaymentDate.addMonths(paymentMonthSpan);
    		}
		/*}*/
		/*else if(frequency == 'quarterly')
		{
		    for(Integer intIndex = 1 ; intIndex<= renewalPeriodMonths ; intIndex++)
		    {
		        if( mapDateToPayment.containsKey( lastPaymentDate) )
    		           mapDateToPayment.put( lastPaymentDate , mapDateToPayment.get( lastPaymentDate ) + monthlyPayment);
    		        else
        	           mapDateToPayment.put( lastPaymentDate  , monthlyPayment);
        	           
        	  lastPaymentDate = lastPaymentDate.addMonths(1);         
		    }
		}*/
		Date dtFinalPayment = Date.newInstance(forecastedPurchaseDate.year(), forecastedPurchaseDate.month(), forecastedPurchaseDate.day());
		
		if(mapDateToPayment.containsKey(dtFinalPayment))
		{
			mapDateToPayment.put(dtFinalPayment , (mapDateToPayment.get(dtFinalPayment)) + getQuarterValue(objSchedule) ) ;
		}
		else
		{
			mapDateToPayment.put( dtFinalPayment , getQuarterValue(objSchedule) ) ;
		}
		return mapDateToPayment;
	}
	
	
	/*
	 *  MethodName: getPayments
	 *  Param: objSchedule represents the schedule we're interested in
	 *  Description: return a map of dates to the amount that is to be paid on that date 
	 */
	/*public Map<Date, Decimal> getPayments(Schedule__c objSchedule){
		Integer extensionPeriod = objSchedule.Extension_Period_Months__c!=null ? Integer.valueOf(objSchedule.Extension_Period_Months__c) : 3;
		Integer renewalCycles = objSchedule.Forecast_Renewal_Cycles__c!=null ? Integer.valueOf(objSchedule.Forecast_Renewal_Cycles__c) : 0;
		Integer renewalPeriodMonths = (Integer) (extensionPeriod * renewalCycles);//number of months in renewal period
		DateTime endOfRenewalPeriod = objSchedule.Base_Lease_Termination_Date__c.addMonths(renewalPeriodMonths);//last renewal month
		DateTime forecastedPurchaseDate = endOfRenewalPeriod.addMonths(1);//puchase payment month

		Integer paymentCount = extensionPeriod;//number of renewal payments to make
		Double paymentMonthSpan = 1.0; //defines number of months between payments
		Double paymentRemainder = 0.0; //used when the extension term is not evenly divisble by the payment freqency

		String frequency = objSchedule.Contract_Extension_Renewal_Frequency__c !=null ? objSchedule.Contract_Extension_Renewal_Frequency__c : objSchedule.Payment_Frequency__c; 

		if(frequency == 'annual'){
			paymentRemainder = math.mod(paymentCount,12);
			paymentCount = paymentCount/12;
			paymentMonthSpan = 12;
		}else if(frequency == 'semi-annual'){
			paymentRemainder = math.mod(paymentCount,6);
			paymentCount = paymentCount/6;
			paymentMonthSpan = 6;
		}else if(frequency == 'quarterly'){
			paymentRemainder = math.mod(paymentCount,3);
			paymentCount = paymentCount/3;
			paymentMonthSpan = 3;
		}

		Map<Date, Decimal> dateToPayment = new Map<Date,Decimal>();

		Date lastPaymentDate = objSchedule.Current_Lease_Expiration_Date__c!=null ? objSchedule.Current_Lease_Expiration_Date__c : objSchedule.Base_Lease_Termination_Date__c;
		for(Integer i = 0; i < renewalCycles; i++){
			for(Integer j = 1; j <= paymentCount; j++){
				Date paymentDate = Date.newInstance(lastPaymentDate.year(), lastPaymentDate.month() + (Integer)(paymentMonthSpan*(j-1) + 1), 1);
				Decimal paymentAmount = (Decimal) (objSchedule.Contract_Extension_Renewal_Rental_Amount__c != null ? 
					objSchedule.Contract_Extension_Renewal_Rental_Amount__c : objSchedule.Payment_Amount__c);
				dateToPayment.put(paymentDate, paymentAmount == null ? 0 : paymentAmount);
				lastPaymentDate = j == paymentCount ? paymentDate : lastPaymentDate;
			}

			if(paymentRemainder != 0){
				Date paymentDate = Date.newInstance(lastPaymentDate.year(), lastPaymentDate.month() + (Integer)((paymentMonthSpan*paymentCount)+paymentRemainder), 1);
				Decimal paymentAmount = (Decimal) ((paymentRemainder/paymentMonthSpan)*(objSchedule.Contract_Extension_Renewal_Rental_Amount__c != null ?
					objSchedule.Contract_Extension_Renewal_Rental_Amount__c : objSchedule.Payment_Amount__c));
				dateToPayment.put(paymentDate, paymentAmount == null ? 0 : paymentAmount);
				lastPaymentDate = paymentDate;
			}
		}

		dateToPayment.put(date.newinstance(forecastedPurchaseDate.year(), 
											forecastedPurchaseDate.month(), 
											forecastedPurchaseDate.day()), 
						  getQuarterValue(objSchedule));

		return dateToPayment;
	}*/
	
	/*
    	* MethodName 	: getQuarterValue.
        * param 		: Schedule.
        * Description	: If no annual forecast quarterly forecast calculated on basis of forecast outcome.
    */
	private Decimal getQuarterValue(Schedule__c objSchedule)
	{
		Integer extensionPeriod = objSchedule.Extension_Period_Months__c!=null ? Integer.valueOf(objSchedule.Extension_Period_Months__c) : 3;
		Integer renewalCycles = objSchedule.Forecast_Renewal_Cycles__c!=null ? Integer.valueOf(objSchedule.Forecast_Renewal_Cycles__c) : 0;
		
		Integer renewalPeriodMonths = (Integer) (extensionPeriod * renewalCycles);
		DateTime endOfRenewalPeriod = objSchedule.Base_Lease_Termination_Date__c.addMonths(renewalPeriodMonths);
		DateTime forecastedPurchaseDate = endOfRenewalPeriod.addMonths(1); 

		if((objSchedule.Forecast_Percent__c == null || objSchedule.Forecast_Percent__c == 0.0) && mapForeCastPercent.containsKey(objSchedule.Forecast_Outcome__c)){
			return mapForeCastPercent.get(objSchedule.Forecast_Outcome__c)/100 * objSchedule.Total_Equipment_Cost__c; 
		}else if(objSchedule.Forecast_Percent__c != null && objSchedule.Forecast_Percent__c != 0.0){
			return (objSchedule.Forecast_Percent__c/100) * objSchedule.Total_Equipment_Cost__c; 	
		}else{
			return 0.00;
		}  
		
	}
	/* End */

	private String getQuarterFromMonth(Integer month){
		return 'Q'+(((month-1)/3)+1);
	}

	public PageReference save3()
	{	
		if(lstforecastWrapper.size() == 0)
		{
			return null;
		}
		
		List<Schedule__c> lstSchedule = new List<Schedule__c>();
		Map<Id, Map<String, ForecastWrapper>> scheduleIdToFcw = new Map<Id, Map<String, ForecastWrapper>>();
		String currentYear = lstforecastWrapper.get(0).strYear;
        
		for(ForecastWrapper fcw : lstforecastWrapper)
		{
			if(fcw.currentChanged)
			{		
				fcw.objSchedule.Forecast_Percent__c = fcw.decPercent;
				lstSchedule.add(fcw.objSchedule);
				scheduleIdToFcw.put(fcw.objSchedule.Id, new Map<String, ForecastWrapper>());
				scheduleIdToFcw.get(fcw.objSchedule.Id).put(fcw.strYear, fcw);
			}
		}
		
		update lstSchedule;
		
		for(Schedule__c objSchedule : lstSchedule)
		{
			Integer renewalPeriodMonths = (Integer) (objSchedule.Extension_Period_Months__c * objSchedule.Forecast_Renewal_Cycles__c);//number of months in renewal period
			DateTime endOfRenewalPeriod = objSchedule.Base_Lease_Termination_Date__c.addMonths(renewalPeriodMonths);//last renewal month
			DateTime forecastedPurchaseDate = endOfRenewalPeriod.addMonths(1);//puchase payment month
			String purchaseQuarter =  getQuarterFromMonth(forecastedPurchaseDate.month());
			System.debug(LoggingLevel.ERROR, 'purchaseQuarter ' + purchaseQuarter);

			Map<Date, Decimal> paymentMap = getPayments(objSchedule);
			Map<String, ForecastWrapper> yearToForecast = scheduleIdToFcw.containsKey(objSchedule.Id) ? scheduleIdToFcw.get(objSchedule.Id) : new Map<String, ForecastWrapper>();
			
			for(Date d : paymentMap.keySet())
			{
				if(''+d.year() != currentYear)
				{
					if(!yearToForecast.containsKey(''+d.year()))
					{
						yearToForecast.put(''+d.year(), new ForecastWrapper(objSchedule,
								(objSchedule.Forecast_Percent__c!=null && objSchedule.Forecast_Percent__c!=0.00)?objSchedule.Forecast_Percent__c:
									(objSchedule.Forecast_Outcome__c != null && mapForeCastPercent.containsKey(objSchedule.Forecast_Outcome__c))? 
										mapForeCastPercent.get(objSchedule.Forecast_Outcome__c) : 0.00, 
								0.0,0.0,0.0,0.0,d.year()+'',false,false,false,false,d.year()+''
							));
					}
					if(d.month() < 4)
					{
						yearToForecast.get(''+d.year()).decQ1 += paymentMap.get(d);
					}
					else if(d.month() < 7)
					{
						yearToForecast.get(''+d.year()).decQ2 += paymentMap.get(d);
					}
					else if(d.month() < 10)
					{
						yearToForecast.get(''+d.year()).decQ3 += paymentMap.get(d);
					}
					else
					{
						yearToForecast.get(''+d.year()).decQ4 += paymentMap.get(d);
					}
					
					System.debug(LoggingLevel.ERROR, 'date year ' + d.year());
					System.debug(LoggingLevel.ERROR, 'purchase year ' + forecastedPurchaseDate.year());
					System.debug(LoggingLevel.ERROR, 'date q ' + getQuarterFromMonth(d.month()));
					System.debug(LoggingLevel.ERROR, 'purchase q ' + purchaseQuarter);
					if(d.year() == forecastedPurchaseDate.year() && getQuarterFromMonth(d.month()) == purchaseQuarter)
					{
						if(purchaseQuarter == 'Q1')
						{
							yearToForecast.get(''+d.year()).endQ1 = true;
						}
						else if(purchaseQuarter == 'Q2')
						{
							yearToForecast.get(''+d.year()).endQ2 = true;						
						}
						else if(purchaseQuarter == 'Q3')
						{
							yearToForecast.get(''+d.year()).endQ3 = true;
						}
						else
						{
							yearToForecast.get(''+d.year()).endQ4 = true;
						}
					}
				}
			}	

			scheduleIdToFcw.put(objSchedule.Id, yearToForecast);
		}
		
		List<Id> aForecastIdToDelete = new List<Id>();
		Map<Id, Set<String>> forecastsToInsert = new Map<Id, Set<String>>();

		for(Id sId : scheduleIdToFcw.keySet())
		{
			if(!forecastsToInsert.containsKey(sId))
			{
				forecastsToInsert.put(sId, new Set<String>());
			}
			for(String yr : scheduleIdToFcw.get(sId).keySet())
			{
				forecastsToInsert.get(sId).add(yr);
			}
		}
		
		Map<Id, Set<String>> mapAFIdToSetQF = new Map<Id, Set<String>>();//Map of Annual forecast id to set of Quarters						
		
		//Iterating on Quarterly_Forecast__c to check whether all the quarterlyForecasts records are present on the annual forecast 
        for(Quarterly_Forecast__c objQF : [SELECT Id, Forecast_Amount__c, End_Forecast__c, 
                                                  Annual_Forecast__c, Annual_Forecast__r.Id,
	 											  Quarter__c, Annual_Forecast__r.Schedule__c, 
	 											  Annual_Forecast__r.Fiscal_Year__c
										     FROM Quarterly_Forecast__c 
						  				    WHERE Annual_Forecast__r.Schedule__c IN : lstSchedule])
        {
            if(mapAFIdToSetQF.containsKey(objQF.Annual_Forecast__c))
            {
                mapAFIdToSetQF.get(objQF.Annual_Forecast__c).add(objQF.Quarter__c);
            }
            else
            {
                mapAFIdToSetQF.put(objQF.Annual_Forecast__c, new Set<String>{objQF.Quarter__c});
            }
        }	
        
        List<Quarterly_Forecast__c> lstQF = new List<Quarterly_Forecast__c>();
        
        //If any annual forecast records  are not having quarterlyForecasts then creating new quarterlyForecasts records
        for(Id AFId : mapAFIdToSetQF.keySet())
        {
            Set<String> setQuarter = mapAFIdToSetQF.get(AFId);
            
            if(!setQuarter.contains('Q1'))
                lstQF.add(new Quarterly_Forecast__c(Annual_Forecast__c = AFId, End_Forecast__c = false, Quarter__c = 'Q1'));            
            
            if(!setQuarter.contains('Q2'))
                lstQF.add(new Quarterly_Forecast__c(Annual_Forecast__c = AFId, End_Forecast__c = false, Quarter__c = 'Q2'));
            
            if(!setQuarter.contains('Q3'))
                lstQF.add(new Quarterly_Forecast__c(Annual_Forecast__c = AFId, End_Forecast__c = false, Quarter__c = 'Q3'));
            
            if(!setQuarter.contains('Q4'))
                lstQF.add(new Quarterly_Forecast__c(Annual_Forecast__c = AFId, End_Forecast__c = false, Quarter__c = 'Q4'));
        }
        
        if(!lstQF.isEmpty())
            insert lstQF;
            
        List<Quarterly_Forecast__c> quarterlyForecasts = [SELECT Id, Forecast_Amount__c, End_Forecast__c, Annual_Forecast__c, Annual_Forecast__r.Id,
	 															 Quarter__c, Annual_Forecast__r.Schedule__c, Annual_Forecast__r.Fiscal_Year__c
														   FROM Quarterly_Forecast__c 
														   WHERE Annual_Forecast__r.Schedule__c IN : lstSchedule];
            
		
		for(Quarterly_Forecast__c qF : quarterlyForecasts)
		{	
			if(scheduleIdToFcw.get(qF.Annual_Forecast__r.Schedule__c).containsKey(qF.Annual_Forecast__r.Fiscal_Year__c)) 
			{
				if(qF.Annual_Forecast__r.Fiscal_Year__c == currentYear || scheduleIdToFcw.get(qF.Annual_Forecast__r.Schedule__c).get(currentYear).futureChanged)
				{
					if(qF.Quarter__c == 'Q1')
					{
						qF.Forecast_Amount__c = scheduleIdToFcw.get(qF.Annual_Forecast__r.Schedule__c).get(qF.Annual_Forecast__r.Fiscal_Year__c).decQ1;		
						qF.End_Forecast__c = scheduleIdToFcw.get(qF.Annual_Forecast__r.Schedule__c).get(qF.Annual_Forecast__r.Fiscal_Year__c).endQ1;
					}
					else if(qF.Quarter__c == 'Q2')
					{
						qF.Forecast_Amount__c = scheduleIdToFcw.get(qF.Annual_Forecast__r.Schedule__c).get(qF.Annual_Forecast__r.Fiscal_Year__c).decQ2;		
						qF.End_Forecast__c = scheduleIdToFcw.get(qF.Annual_Forecast__r.Schedule__c).get(qF.Annual_Forecast__r.Fiscal_Year__c).endQ2;
					}
					else if(qF.Quarter__c == 'Q3')
					{
						qF.Forecast_Amount__c = scheduleIdToFcw.get(qF.Annual_Forecast__r.Schedule__c).get(qF.Annual_Forecast__r.Fiscal_Year__c).decQ3;		
						qF.End_Forecast__c = scheduleIdToFcw.get(qF.Annual_Forecast__r.Schedule__c).get(qF.Annual_Forecast__r.Fiscal_Year__c).endQ3;				
					}
					else if(qF.Quarter__c == 'Q4')
					{
						qF.Forecast_Amount__c = scheduleIdToFcw.get(qF.Annual_Forecast__r.Schedule__c).get(qF.Annual_Forecast__r.Fiscal_Year__c).decQ4;		
						qF.End_Forecast__c = scheduleIdToFcw.get(qF.Annual_Forecast__r.Schedule__c).get(qF.Annual_Forecast__r.Fiscal_Year__c).endQ4;
					}
				}
				
				forecastsToInsert.get(qF.Annual_Forecast__r.Schedule__c).remove(qF.Annual_Forecast__r.Fiscal_Year__c);
			}
			else
			{
				aForecastIdToDelete.add(qF.Annual_Forecast__r.Id);
			}
		}
		
		update quarterlyForecasts;

		List<Annual_Forecast__c> aForecastListToDelete = [SELECT Id FROM Annual_Forecast__c WHERE Id IN : aForecastIdToDelete];
		delete aForecastListToDelete;

		List<Annual_Forecast__c> aForecastToInsert = new List<Annual_Forecast__c>();
		
		for(Id sId : forecastsToInsert.keySet())
		{
			for(String yr : forecastsToInsert.get(sId))
			{
				aForecastToInsert.add(new Annual_Forecast__c(Fiscal_Year__c = yr, Schedule__c = sId));
			}
		}
		insert aForecastToInsert;
        
		List<Quarterly_Forecast__c> qForecastToInsert = new List<Quarterly_Forecast__c>();
        
		for(Annual_Forecast__c aF : aForecastToInsert)
		{
			ForecastWrapper fcw = scheduleIdToFcw.get(aF.Schedule__c).get(aF.Fiscal_Year__c);
			qForecastToInsert.add(new Quarterly_Forecast__c(Annual_Forecast__c = aF.Id, Forecast_Amount__c = fcw.decQ1, End_Forecast__c = false, Quarter__c = 'Q1'));
			qForecastToInsert.add(new Quarterly_Forecast__c(Annual_Forecast__c = aF.Id, Forecast_Amount__c = fcw.decQ2, End_Forecast__c = false, Quarter__c = 'Q2'));
			qForecastToInsert.add(new Quarterly_Forecast__c(Annual_Forecast__c = aF.Id, Forecast_Amount__c = fcw.decQ3, End_Forecast__c = false, Quarter__c = 'Q3'));
			qForecastToInsert.add(new Quarterly_Forecast__c(Annual_Forecast__c = aF.Id, Forecast_Amount__c = fcw.decQ4, End_Forecast__c = false, Quarter__c = 'Q4'));
		}
		
		insert qForecastToInsert;
		
		return null;
	}
	
	/*
    	* MethodName 	: Cancel.
        * param 		: List of Note.
        * Description	: This function will call After Update of the note.
    */
	public PageReference Cancel()
	{
		PageReference pgRef = new PageReference('/apex/SL_MassForecastEntryPage');
  		pgRef.setRedirect(true);
  		return pgRef;
	} 
	/* End */
}