/**
* \arg \b ClassName      : SL_Proceeds_Handler
* \arg \b JIRATicket     : FAEF-35
* \arg \b CreatedOn      : 18/09/2014
* \arg \b ModifiedBy     : Harsh
* \arg \b Description    : This is the handler class for Proceeds trigger.When an Proceed is Inserted, Updated, Deleted 
                            and Undeleted, aggregate the amount field for all proceed records that were posted in the same
                            quarter as the modified record, and put that aggregated value on the corresponding quarterly
                            forecast record. 
*/
public with sharing class SL_Proceeds_Handler 
{
    /* This Map will store the Quarter for Month. */
    private static final Map<Integer, String> mapMonthToQuarter = new Map<integer, String>{ 1 => 'Q1', 2 => 'Q1', 3 => 'Q1',
                                                                                            4 => 'Q2', 5 => 'Q2', 6 => 'Q2',
                                                                                            7 => 'Q3', 8 => 'Q3', 9 => 'Q3',
                                                                                            10 => 'Q4', 11 => 'Q4', 12 => 'Q4'};//This map will be utilize to get the Quarter based on month.
    
    private map<String, Decimal> mapYearQuarterSchedukedIdToAF = new map<String, Decimal>();// This map will Store the Proceed Year, Quarter and ScheduleId as Key and related aggregate Forecast Amount as Value.
    private set<String> setScheduleId = new set<String>();//It will store all the schedule Id into set from Proceeds records.
    private String strformat = '';  //To store the format as Year-Quarter-SchedlueId from Proceeds.
    
    
    /* Constructor */
    public SL_Proceeds_Handler() 
    {
        // Do Nothing
    } 
    
    public void onBeforeInsert(list<Proceeds__c> newProceeds){
        set<Id> parentScheduleIDs = new set<Id>();
        for(Proceeds__c p : newProceeds){
            parentScheduleIDs.add(p.Schedule__c);
        }

        map<Id,Schedule__c> parentschedules = new map<Id,Schedule__c>([SELECT Id, Residual_Balance__c FROM Schedule__c WHERE Id = :parentScheduleIDs]);
        map<Id, List<SL_SortProceeds>> scheduleToProceeds = new map<Id, List<SL_SortProceeds>>();
        for(Proceeds__c p : newProceeds){
            if(scheduleToProceeds.containsKey(p.Schedule__c)){
                scheduleToProceeds.get(p.Schedule__c).add(new SL_SortProceeds(p));
            }
            else{
                scheduleToProceeds.put(p.Schedule__c, new list<SL_SortProceeds>{new SL_SortProceeds(p)});
            }
        }
        for(Id i : scheduleToProceeds.keyset()){
            if(((String)i).startsWith('a3HZ000000044go')){
            }
            scheduleToProceeds.get(i).sort();

            Schedule__c schedule = parentschedules.get(i);

            Decimal residualBalance = Schedule.Residual_Balance__c;

            for(SL_SortProceeds p : scheduleToProceeds.get(i)){
                Proceeds__c proceed = p.proceed;
                Decimal proceedResidual = getProceedResidual(residualBalance, proceed.Amount__c);
                Proceed.Residual_Recovery__c = proceedResidual;
                residualBalance -= proceed.Amount__c;
            }
        }
    }

    /*!
      *  @MethodName    : onAfterInsert.
      *  @param         : List of Proceeds.
      *  @Description   : Called After insert of the Proceeds.
    */
    public void onAfterInsert(list<Proceeds__c> lstProceeds) 
    {
        mapYearQuarterSchedukedIdToAF.clear();
        setScheduleId.clear();
        
        List<Proceeds__c> lstUpdatedProceeds = new List<Proceeds__c>();
        
        /* Iterating through the list of inserted proceeds and preapring a Map of ProceedYearQuarterScheduledId to Aggregated Forecast Amount within tha quarter and year.*/
        for(Proceeds__c objProceed : lstProceeds)
        {
            if(objProceed.Date_Posted__c != NULL)
            {
                lstUpdatedProceeds.add(objProceed);
                
                setScheduleId.add(objProceed.schedule__c);
                
                /*Creating a unique combination to agg the amount for same quarter and same year..*/
                strformat = objProceed.Date_Posted__c.year() +'--' +mapMonthToQuarter.get(objProceed.Date_Posted__c.month()) + '--'+ objProceed.Schedule__c;
                
                /* Adding in to the map with this format : YYYY-Quarter-SchId.*/
                if(mapYearQuarterSchedukedIdToAF.containskey(strformat)){
                    //System.debug(LoggingLevel.ERROR, strformat);
                    //System.debug(LoggingLevel.ERROR, mapYearQuarterSchedukedIdToAF.get(strformat));
                    //System.debug(LoggingLevel.ERROR, objProceed.Amount__c);
                    mapYearQuarterSchedukedIdToAF.put(strformat, mapYearQuarterSchedukedIdToAF.get(strformat) + objProceed.Amount__c);
                }
                else
                {
                	if(objProceed.Amount__c != null)
                    	mapYearQuarterSchedukedIdToAF.put(strformat, objProceed.Amount__c);
                    else
                    	mapYearQuarterSchedukedIdToAF.put(strformat, 0.0);
                }    
            }
        }
        /* Calling this method to update the Quarterly Forecast Amount considering the inserted Proceeds  */
        UpdateQuarterlyForecast(lstUpdatedProceeds);
    }


    /*!
      *  @MethodName    : onAfterUpdate.
      *  @param         : List of Proceeds.
      *  @Description   : Called After Update of the Proceeds.
    */
    public void onAfterUpdate(map<Id, Proceeds__c> oldMap, map<Id, Proceeds__c> newMap) 
    {
        Decimal ProceedAmountToUpdate = 0;//This is to store the Amount which needs to update for old schedule and quarter.
        mapYearQuarterSchedukedIdToAF.clear();
        setScheduleId.clear();
        
        List<Proceeds__c> lstProceedsToUpdate = new List<Proceeds__c>();
        for(Proceeds__c objProceed : newMap.values())
        {
        	 if(objProceed.Amount__c != oldMap.get(objProceed.Id).Amount__c 
            	|| objProceed.Date_Posted__c != oldMap.get(objProceed.Id).Date_Posted__c
            	|| objProceed.Schedule__c != oldMap.get(objProceed.Id).Schedule__c)
              {
              	lstProceedsToUpdate.add(objProceed);
              }
        }
        
        /* Iterating through the list of inserted proceeds and preapring a Map of ProceedYearQuarterScheduledId to Aggregated Forecast Amount within tha quarter and year.*/
        for(Id objProceedId : newMap.keyset())
        {
            /* Common unique format which is always required to aggregate Forecast Amount whenever an proceed record is updated. */
            strformat = newMap.get(objProceedId).Date_Posted__c.year() +'--' +mapMonthToQuarter.get(newMap.get(objProceedId).Date_Posted__c.month()) + '--'+ newMap.get(objProceedId).Schedule__c;
            
            setScheduleId.add(newMap.get(objProceedId).schedule__c);
            setScheduleId.add(oldMap.get(objProceedId).schedule__c);
                
            /* If Schedule, DatePosted and forecastAmount updated for an proceed record.  */    
            if(newMap.get(objProceedId).Schedule__c != oldMap.get(objProceedId).Schedule__c && newMap.get(objProceedId).Amount__c != oldMap.get(objProceedId).Amount__c && newMap.get(objProceedId).Date_Posted__c != oldMap.get(objProceedId).Date_Posted__c)
            {
                addForecastAmount(strformat, newMap.get(objProceedId).Amount__c);//Add forecast Amount on related QF.
                /* preparing the format to remove the value from old QF. */
                strformat = oldMap.get(objProceedId).Date_Posted__c.year() +'--' +mapMonthToQuarter.get(oldMap.get(objProceedId).Date_Posted__c.month()) + '--'+ oldMap.get(objProceedId).Schedule__c;
                removeForecastAmount(strformat, oldMap.get(objProceedId).Amount__c);//Remove forecast Amount from older QF.
            }
            /* If only Date Posted and Amount is updated for Proceed records.*/
            else if(newMap.get(objProceedId).Date_Posted__c != oldMap.get(objProceedId).Date_Posted__c && newMap.get(objProceedId).Amount__c != oldMap.get(objProceedId).Amount__c)
            {
                addForecastAmount(strformat, newMap.get(objProceedId).Amount__c);//Add forecast Amount on QF.
                /* preparing the format to remove the value from old QF. */
                strformat = oldMap.get(objProceedId).Date_Posted__c.year() +'--' +mapMonthToQuarter.get(oldMap.get(objProceedId).Date_Posted__c.month()) + '--'+ newMap.get(objProceedId).Schedule__c;
                removeForecastAmount(strformat, oldMap.get(objProceedId).Amount__c);//Add forecast Amount on QF.
                
            }
            /* If Schedule and Amount is updated for Proceed */
            else if(newMap.get(objProceedId).Schedule__c != oldMap.get(objProceedId).Schedule__c && newMap.get(objProceedId).Amount__c != oldMap.get(objProceedId).Amount__c)
            {
                addForecastAmount(strformat, newMap.get(objProceedId).Amount__c);//Add forecast Amount on QF.
                /* preparing the format to remove the value from old QF. */
                strformat = newMap.get(objProceedId).Date_Posted__c.year() +'--' +mapMonthToQuarter.get(newMap.get(objProceedId).Date_Posted__c.month()) + '--'+ oldMap.get(objProceedId).Schedule__c;
                removeForecastAmount(strformat, oldMap.get(objProceedId).Amount__c);//Add forecast Amount on QF
            }
            /* If Schedule and Date posted is updated for Proceed records. */
            else if(newMap.get(objProceedId).Schedule__c != oldMap.get(objProceedId).Schedule__c && newMap.get(objProceedId).Date_Posted__c != oldMap.get(objProceedId).Date_Posted__c)
            {
                addForecastAmount(strformat, newMap.get(objProceedId).Amount__c);//Add forecast Amount on QF.
                /* preparing the format to remove the value from old QF. */
                strformat = oldMap.get(objProceedId).Date_Posted__c.year() +'--' +mapMonthToQuarter.get(oldMap.get(objProceedId).Date_Posted__c.month()) + '--'+ oldMap.get(objProceedId).Schedule__c;
                removeForecastAmount(strformat, oldMap.get(objProceedId).Amount__c);//Add forecast Amount on QF.
            }
            /* If only Amount field is updated for Porceed records. */
            else if(newMap.get(objProceedId).Amount__c != oldMap.get(objProceedId).Amount__c)
            {
                ProceedAmountToUpdate = newMap.get(objProceedId).Amount__c - oldMap.get(objProceedId).Amount__c;
                addForecastAmount(strformat, ProceedAmountToUpdate);//Add forecast Amount on QF.
            }
            /* If only Schedule is updated for Proceed records. */
            else if(newMap.get(objProceedId).Schedule__c != oldMap.get(objProceedId).Schedule__c)
            {
                addForecastAmount(strformat, newMap.get(objProceedId).Amount__c);//Add forecast Amount on QF.
                /* preparing the format to remove the value from old QF. */
                strformat = newMap.get(objProceedId).Date_Posted__c.year() +'--' +mapMonthToQuarter.get(newMap.get(objProceedId).Date_Posted__c.month()) + '--'+ oldMap.get(objProceedId).Schedule__c;
                removeForecastAmount(strformat, oldMap.get(objProceedId).Amount__c);
            }
            /* If only Date Posted is updated for Proceeds Records. */
            else if(newMap.get(objProceedId).Date_Posted__c != oldMap.get(objProceedId).Date_Posted__c)
            {
                addForecastAmount(strformat, newMap.get(objProceedId).Amount__c);//Add forecast Amount on QF
                /* preparing the format to remove the value from old QF. */
                strformat = oldMap.get(objProceedId).Date_Posted__c.year() +'--' +mapMonthToQuarter.get(oldMap.get(objProceedId).Date_Posted__c.month()) + '--'+ newMap.get(objProceedId).Schedule__c;
                removeForecastAmount(strformat, oldMap.get(objProceedId).Amount__c);//Removing the forecast Amount from older one.
            }
        }
        
        /* Calling this method to update the Quarterly Forecast Amount considering the inserted Proceeds */
        UpdateQuarterlyForecast(lstProceedsToUpdate);
    }
    
    /*!
      *  @MethodName    : onAfterUpdate.
      *  @param         : List of Proceeds.
      *  @Description   : Called Before Delete of the Proceeds.
    */
    public void onBeforeDelete(list<Proceeds__c> lstOldProceeds) 
    {
        mapYearQuarterSchedukedIdToAF.clear();
        setScheduleId.clear();
        
        /* Iterating through the list of inserted proceeds and preapring a Map of ProceedYearQuarterScheduledId to Aggregated Forecast Amount within tha quarter and year.*/
        for(Proceeds__c objProceed : lstOldProceeds)
        {
            if(objProceed.Date_Posted__c != NULL)
            {
                setScheduleId.add(objProceed.schedule__c);
                
                strformat = objProceed.Date_Posted__c.year() +'--' +mapMonthToQuarter.get(objProceed.Date_Posted__c.month()) + '--'+ objProceed.Schedule__c;
                
                /* Adding in to the map with this format : YYYY-Quarter-SchId. */
                if(mapYearQuarterSchedukedIdToAF.containskey(strformat))
                    mapYearQuarterSchedukedIdToAF.put(strformat, mapYearQuarterSchedukedIdToAF.get(strformat) - objProceed.Amount__c);
                else
                {
                	if(objProceed.Amount__c != null)
                    	mapYearQuarterSchedukedIdToAF.put(strformat, -objProceed.Amount__c);
                    else
                    	mapYearQuarterSchedukedIdToAF.put(strformat, -0.0);	
                }    
            }
        }
        
        /* Calling this method to update the Quarterly Forecast Amount considering the inserted Proceeds */
        UpdateQuarterlyForecast(NULL);
    }
    
    /*!
      *  @MethodName    : onAfterUnDelete.
      *  @param         : List of Proceeds.
      *  @Description   : Called After Undelete of the Proceeds.
    */
    public void onAfterUnDelete(list<Proceeds__c> lstProceeds) 
    {
        mapYearQuarterSchedukedIdToAF.clear();
        setScheduleId.clear();
        
        List<Proceeds__c> lstProceedsToUpdate = new List<Proceeds__c>();
        
        /* Iterating through the list of inserted proceeds and preapring a Map of ProceedYearQuarterScheduledId to Aggregated Forecast Amount within tha quarter and year.*/
        for(Proceeds__c objProceed : lstProceeds)
        {
            if(objProceed.Date_Posted__c != NULL)
            {
                lstProceedsToUpdate.add(objProceed);
                
                setScheduleId.add(objProceed.schedule__c);
                
                strformat = objProceed.Date_Posted__c.year() +'--' +mapMonthToQuarter.get(objProceed.Date_Posted__c.month()) + '--'+ objProceed.Schedule__c;
                
                /* Adding in to the map with this format : YYYY-Quarter-SchId. */
                if(mapYearQuarterSchedukedIdToAF.containskey(strformat))
                    mapYearQuarterSchedukedIdToAF.put(strformat, mapYearQuarterSchedukedIdToAF.get(strformat) + objProceed.Amount__c);
                else
                {
                	if(objProceed.Amount__c != null)
                    	mapYearQuarterSchedukedIdToAF.put(strformat, objProceed.Amount__c);
                    	
                    else
                    	mapYearQuarterSchedukedIdToAF.put(strformat, 0.0);
                }    
            }
        }
        
        /* Calling this method to update the Quarterly Forecast Amount considering the inserted Proceeds */
        UpdateQuarterlyForecast(lstProceedsToUpdate);
    }

    public Static Decimal getProceedResidual(Decimal residualBalance, Decimal amount){
        Decimal proceedResidual;
        if(residualBalance < 1){
            proceedResidual = 0;
        }
        else if(residualBalance >= amount){
            proceedResidual = amount;
        }
        else{
            proceedResidual = residualBalance;
        }
        return proceedResidual;
    }
    
    
    /*!
      *  @MethodName    : addForecastAmount.
      *  @param         : YYYY-Quarter-SchId format and ForecastAmount
      *  @Description   : This method will check the format inside map and Add the ForecastAMount for new QF.
    */
    private void addForecastAmount(String strformat, Decimal ForecastAmount)
    {
        if(mapYearQuarterSchedukedIdToAF.containskey(strformat))
            mapYearQuarterSchedukedIdToAF.put(strformat, mapYearQuarterSchedukedIdToAF.get(strformat) + ForecastAmount);
        else
        {
        	if(ForecastAmount != null)
           		mapYearQuarterSchedukedIdToAF.put(strformat, ForecastAmount); 
           	else
           		mapYearQuarterSchedukedIdToAF.put(strformat, 0.0);	
        }  
    }
    
    /*!
      *  @MethodName    : removeForecastAmount.
      *  @param         : YYYY-Quarter-SchId format and ForecastAmount
      *  @Description   : This method will check the format inside map and remove the ForecastAMount for older QF.
    */
    private void removeForecastAmount(String strformat, Decimal ForecastAmount)
    {
        
        if(mapYearQuarterSchedukedIdToAF.containskey(strformat))
            mapYearQuarterSchedukedIdToAF.put(strformat, mapYearQuarterSchedukedIdToAF.get(strformat) - ForecastAmount);
        else
        {
        	if(ForecastAmount != null)
            	mapYearQuarterSchedukedIdToAF.put(strformat, - ForecastAmount);
            	
            else
            	mapYearQuarterSchedukedIdToAF.put(strformat, -0.0);	
        }    
    }
    
    /*!
      *  @MethodName    : UpdateQuarterlyForecast.
      *  @param         : None
      *  @Description   : Called After Insert, Update, Delete and Undelete of the Proceeds records to update the Quarterly Forecast Amount.
    */
    private void UpdateQuarterlyForecast(List<Proceeds__c> lstUpdatedProceed) 
    {
        system.debug('mapYearQuarterSchedukedIdToAF------------------>>> ' +mapYearQuarterSchedukedIdToAF);
        
        map<String, Annual_Forecast__c> mapScheduleIdYearToAF = new map<String, Annual_Forecast__c>();
        map<String, Set<String>> mapScheduledIdToSetForecastYear = new map<String, Set<String>>(); 
        map<Annual_Forecast__c, List<String>> mapAFToLst = new map<Annual_Forecast__c, List<String>>();
        
        list<String> lstSplitValues = new list<String>();
        list<Quarterly_Forecast__c> lstQFToInsert = new list<Quarterly_Forecast__c>();
        list<Quarterly_Forecast__c> lstQFToUpdate = new list<Quarterly_Forecast__c>(); 
        list<Annual_Forecast__c> lstAFToInsert = new list<Annual_Forecast__c>();
        
        
        /* Iterating Over Annual Forecast where Schedule In setScheduleId and preparing MapScheduledId&YearToAFObject and MapScheduledIdToSetForecastYear.*/
        for(Annual_Forecast__c objAF : [    Select Id, Fiscal_Year__c, Schedule__c,
                                            (Select Id, Annual_Forecast__r.Fiscal_Year__c, Quarter__c, Annual_Forecast__r.Schedule__c from Quarterly_Forecasts__r) 
                                            from  Annual_Forecast__c
                                            where Schedule__c IN :setScheduleId
                                        ])
        {
            /* Adding the ScheduleId--YYYY To AF record */
            if(objAF.Fiscal_Year__c != NULL)
            {
                String strScheduleIdYear = objAF.Schedule__c + '--' + objAF.Fiscal_Year__c;
                mapScheduleIdYearToAF.put(strScheduleIdYear, objAF);
            }
            
            if(!mapScheduledIdToSetForecastYear.containskey(objAF.Schedule__c))
                mapScheduledIdToSetForecastYear.put(objAF.Schedule__c, new set<String>{objAF.Fiscal_Year__c});
            else
                mapScheduledIdToSetForecastYear.get(objAF.Schedule__c).add(objAF.Fiscal_Year__c);
        }
        
        Map<String, Set<String>> MapOfYesrScheduleIdToQyarter = new Map<String, Set<String>>();
        
        /* If there is no AF for Schedule than create the AF and then Create the QF and upodate the Forecast Amount Field. */
        for(String strYearQuarterScheduleId : mapYearQuarterSchedukedIdToAF.keyset())
        {
            Quarterly_Forecast__c objQFNew = null;
            lstSplitValues = strYearQuarterScheduleId.split('--');//Spliting the Year, Quarter and ScheduledId.
            
            if(mapScheduledIdToSetForecastYear.containskey(lstSplitValues[2]) && mapScheduledIdToSetForecastYear.get(lstSplitValues[2]).contains(lstSplitValues[0])) 
            {
                for(Quarterly_Forecast__c objQF : mapScheduleIdYearToAF.get(lstSplitValues[2]+'--'+lstSplitValues[0]).Quarterly_Forecasts__r)
                {
                    String strFormatCheck = objQF.Annual_Forecast__r.Fiscal_Year__c+ '--'+objQF.Quarter__c + '--'+ objQF.Annual_Forecast__r.Schedule__c;
                    if(strFormatCheck == strYearQuarterScheduleId)
                        objQFNew = objQF;
                }
                
                Decimal decAmount = mapYearQuarterSchedukedIdToAF.get(strYearQuarterScheduleId);
                if(objQFNew != Null){
                    lstQFToUpdate.add(new Quarterly_Forecast__c(Id = objQFNew.Id));
                   // break;
                }   
                else
                {
                    String strScheduleIdYear = lstSplitValues[2]+'--'+lstSplitValues[0];
                    lstQFToInsert.add(new Quarterly_Forecast__c(Proceeds_Total__c = decAmount, Quarter__c = lstSplitValues[1], Annual_Forecast__c = mapScheduleIdYearToAF.get(strScheduleIdYear).Id));
                }
            }
            else
            {
                /*Creating Annual forecast records.
                Annual_Forecast__c objAF = new Annual_Forecast__c(Schedule__c =lstSplitValues[2], Fiscal_Year__c = lstSplitValues[0]); */
                
                if(!MapOfYesrScheduleIdToQyarter.containsKey(lstSplitValues[0]+ '--' +lstSplitValues[2]))
                    MapOfYesrScheduleIdToQyarter.put(lstSplitValues[0]+ '--' +lstSplitValues[2], new Set<String>{lstSplitValues[1]});
                else
                    MapOfYesrScheduleIdToQyarter.get(lstSplitValues[0]+ '--' +lstSplitValues[2]).add(lstSplitValues[1]);
            }
            
        }
        
        /* If no Annual forecast found then it will insert the annual forecast. */
        if(!MapOfYesrScheduleIdToQyarter.isEmpty())
        {
            for(String strYear : MapOfYesrScheduleIdToQyarter.keySet())
            {   
                List<String> lstsplittedString = new List<String>();
                lstsplittedString = strYear.split('--');
                
                lstAFToInsert.add(new Annual_Forecast__c(Schedule__c =lstsplittedString[1], Fiscal_Year__c = lstsplittedString[0]));
            }
        }
        
        
        if(!lstAFToInsert.isEmpty())
        {
            insert lstAFToInsert;
        }
        
        /* Preparing QF records for the newly inserted ANNUAL FORECAST RECORDS. */
        for(Annual_Forecast__c objAf : lstAFToInsert)
        {
            String strFormatNew = objAf.Fiscal_Year__c+ '--' +objAf.Schedule__c;//Creating a combination so if there is no AF created then we will be creating AF.
            if(MapOfYesrScheduleIdToQyarter.containsKey(strFormatNew))
            {
                for(String str : MapOfYesrScheduleIdToQyarter.get(strFormatNew))
                {
                    String strYearQuarterScheduleIdFormat = objAf.Fiscal_Year__c + '--' +str+ '--' +objAf.Schedule__c;
                    if(mapYearQuarterSchedukedIdToAF.containsKey(strYearQuarterScheduleIdFormat))
                        lstQFToInsert.add(new Quarterly_Forecast__c(Quarter__c = str, Annual_Forecast__c = objAf.Id, Proceeds_Total__c =  mapYearQuarterSchedukedIdToAF.get(strYearQuarterScheduleIdFormat))); 
                }
            }
            
        }
        
        
        List<Quarterly_Forecast__c> lstQFForUPDATE = new List<Quarterly_Forecast__c>();//It will store the QF which needs to be updated.
        for(Quarterly_Forecast__c objQF :  [    Select Annual_Forecast__r.Fiscal_Year__c, Annual_Forecast__r.Schedule__c, Proceeds_Total__c, Quarter__c,
                                                Annual_Forecast__c 
                                                From Quarterly_Forecast__c 
                                                Where Id IN : lstQFToUpdate
                                                
                                            ])
        {
            String strFormatNew = objQF.Annual_Forecast__r.Fiscal_Year__c+ '--' +objQF.Quarter__c+ '--' +objQF.Annual_Forecast__r.Schedule__c;
            
            if(mapYearQuarterSchedukedIdToAF.containsKey(strFormatNew))
            {
                Decimal decAmount = mapYearQuarterSchedukedIdToAF.get(strFormatNew);
                
                if(decAmount == null)
                	decAmount = 0.0;
                	
                objQF.Proceeds_Total__c = objQF.Proceeds_Total__c!= NULL ? objQF.Proceeds_Total__c + decAmount : decAmount;
                lstQFForUPDATE .add(objQF);
            }
        }
    
        if(!lstQFForUPDATE.isEmpty())
            update lstQFForUPDATE ;
    
        if(!lstQFToInsert.isEmpty())   
            insert lstQFToInsert;   
        
        
        // For updating the QF field on Proceed record
        Map<String, String> mapOfFormatToQFId = new Map<String, String>();
        
        for(Quarterly_Forecast__c objQF : [Select Id, Annual_Forecast__r.Fiscal_Year__c, Quarter__c, Annual_Forecast__r.Schedule__c from Quarterly_Forecast__c Where Id IN : lstQFForUPDATE])
        {
			String strFormatNew = objQF.Annual_Forecast__r.Fiscal_Year__c+ '--' +objQF.Quarter__c+ '--' +objQF.Annual_Forecast__r.Schedule__c;
			mapOfFormatToQFId.put(strFormatNew, objQF.Id);
        }
		
		for(Quarterly_Forecast__c objQF : [Select Id, Annual_Forecast__r.Fiscal_Year__c, Quarter__c, Annual_Forecast__r.Schedule__c from Quarterly_Forecast__c Where Id IN : lstQFToInsert])
        {
			String strFormatNew = objQF.Annual_Forecast__r.Fiscal_Year__c+ '--' +objQF.Quarter__c+ '--' +objQF.Annual_Forecast__r.Schedule__c;
			mapOfFormatToQFId.put(strFormatNew, objQF.Id);
        }       
        
        
        List<Proceeds__c> lstProceedsToUpdateQF = new List<Proceeds__c>();
        if(lstUpdatedProceed != NULL && !lstUpdatedProceed.isEmpty())
        {
        	for(Proceeds__c objProceed : [Select Id, Date_Posted__c, Schedule__c, Quarterly_Forecast__c from Proceeds__c Where Id IN : lstUpdatedProceed])
        	{
        		String strFormatLatest =   objProceed.Date_Posted__c.year() +'--' +mapMonthToQuarter.get(objProceed.Date_Posted__c.month()) + '--'+ objProceed.Schedule__c;
        		if(mapOfFormatToQFId.containsKey(strFormatLatest))
        		{
        			objProceed.Quarterly_Forecast__c = mapOfFormatToQFId.get(strFormatLatest);
        			lstProceedsToUpdateQF.add(objProceed);
        		}
        	}
        }
        
        if(!lstProceedsToUpdateQF.isEmpty()){
        	update lstProceedsToUpdateQF;
        }
    }
}