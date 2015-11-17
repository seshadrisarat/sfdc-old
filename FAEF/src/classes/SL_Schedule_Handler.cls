/**
* \arg ClassName      : SL_Schedule_Handler
* \arg JIRATicket     : FAEF-3
* \arg CreatedOn      : 03/07/2013
* \arg ModifiedOn     : 03/23/2015
* \arg ModifiedBy     : Lodhi
* \arg Description    : Handler class for SL_ScheduleTrigger trigger to calculate the total 
*                       number of Schedules present within the same Account and update the 
*                       Schedule_Number__c and Name fields on the Schedule record with formula 
*                       "Schedule_c.Letter_of_Intent__r.Account__r.Master_Lease_Number__c & ”-” & (totalNumOfSchedulesOnThisAccount+1).toString()".
*/
public without sharing class SL_Schedule_Handler 
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public static Boolean isFirstUpdateCall = true;
    
    // Constructor
    public SL_Schedule_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    // After Insert
    public void onAfterInsert(Map<Id,Schedule__c> newMap){
    	
        UpdateScheduleNumber(newMap);
    }

    private void UpdateScheduleNumber(Map<Id,Schedule__c> newMap)
    {
        //map of loi id to fund source id
        /* Start- This code comes under FAEF-19*/
        Map<Id,Id> mapLOIIdToFundingSourceId = new Map<Id,Id>();
        Set<Id> setLOIIds = new Set<Id>();//set of all LOI ids which belong to the inserted schedules
        /* End- This code comes under FAEF-19*/
        
         Set<Id> setAccountIdToCreateGuarantor = new Set<Id>();//To create the Guarantor records.
        // Get all accounts for any schedule in this trigger.
        // Add the account ids to a set.
        Map<Id,Schedule__c> fullTriggerSchMap = new Map<Id,Schedule__c>([SELECT Id,
                                                                                Letter_of_Intent__c,
                                                                                Letter_of_Intent__r.Account__r.Id,
                                                                                Letter_of_Intent__r.Account__r.Master_Lease_Number__c,
                                                                                Project_Manager__c
                                                                           FROM Schedule__c 
                                                                          WHERE Id IN :newMap.keySet()]);
        
        //System.Debug(LoggingLevel.ERROR,'fullTriggerSchMap size: ' + fullTriggerSchMap.size());
        Set<Id> acctIds = new Set<Id>();
       
        for(Schedule__c sch : fullTriggerSchMap.values())
        {
            acctIds.add(sch.Letter_of_Intent__r.Account__r.Id);
            /* Start- This code comes under FAEF-19*/
            setLOIIds.add(sch.Letter_of_Intent__c);//Collecting LOI ids in set to create a map of loi id to latest fund source id
            /* End - This code comes under FAEF-19*/
        }
        //System.Debug(LoggingLevel.ERROR,'acctIds size: ' + acctIds.size());

        // Get all the fields we need for all the schedules associated with any account associated with any schedule in this trigger.
        // Add them to a map.
        Map<Id,Schedule__c> allSchedules = new Map<Id,Schedule__c>([SELECT Id,Name,Schedule_Number__c, Is_Dataload__c, Letter_of_Intent__r.Account__c,
                                                                    Letter_of_Intent__r.Account__r.Master_Lease_Number__c,Letter_of_Intent__c,
                                                                    Letter_of_Intent__r.Account__r.Id,Project_Manager__c,Funding_Source__c, Account_Lookup__c
                                                                    FROM Schedule__c 
                                                                    WHERE Letter_of_Intent__r.Account__r.Id IN :acctIds]);
                                                                    
       //Iterating over Fund Source object to create a map of LOI id to the earliest created internal funding source id 
       /* Start- This code comes under FAEF-19*/
       for(Funding_Source__c objFundingSource : [SELECT Id, Letter_of_Intent__c FROM Funding_Source__c 
                                                 WHERE Letter_of_Intent__c IN:setLOIIds AND RecordType.DeveloperName =:'Internal' ORDER BY CreatedDate DESC])
       {
            mapLOIIdToFundingSourceId.put(objFundingSource.Letter_of_Intent__c,objFundingSource.Id);
       }
       /* End- This code comes under FAEF-19*/
        //System.Debug(LoggingLevel.ERROR,'allSchedules size: ' + allSchedules.size());

        // Init a map to hold an MLN and the max schedule number for that MLN.
        Map<String,Integer> mapMLN_MaxSchNum = new Map<String,Integer>();
        for(Schedule__c sch : allSchedules.values())
        {
            //System.Debug(LoggingLevel.ERROR,'sch: ' + sch);
            Integer maxSchNum;
            String schMLN = sch.Letter_of_Intent__r.Account__r.Master_Lease_Number__c;
            String schNum = sch.Schedule_Number__c;

            if((!String.isBlank(schMln)) && (!String.isBlank(schNum)))
            {
                if(!mapMLN_MaxSchNum.containsKey(schMLN))
                    mapMLN_MaxSchNum.put(schMLN, 0);

                maxSchNum = mapMLN_MaxSchNum.get(schMLN);

                // make sure the schedule number is trimmed appropriately and then typecast it.
                schNum = schNum.substringAfterLast(schMLN);
                schNum = schNum.replaceAll('\\W', '');
                schNum = schNum.replaceAll('[a-z]', '');
                schNum = schNum.replaceAll('[A-Z]', '');
                Integer schNumInteger = (String.isBlank(schNum)?0:Integer.valueOf(schNum));

                if(schNumInteger > maxSchNum)
                {
                    maxSchNum = schNumInteger;
                    mapMLN_MaxSchNum.put(schMln, maxSchNum);
                }
            }
        }
        //System.Debug(LoggingLevel.ERROR,'mapMLN_MaxSchNum: ' + mapMLN_MaxSchNum);

        List<Schedule__c> listToUpdate = new List<Schedule__c>();

        for(Schedule__c sch : newMap.values())
        {
            //System.Debug(LoggingLevel.ERROR,'sch: ' + sch);
            Schedule__c fullSch = allSchedules.get(sch.Id);
            if(fullSch.Letter_of_Intent__c != null && 
               fullSch.Letter_of_Intent__r.Account__c !=null && 
               fullSch.Letter_of_Intent__r.Account__r.Master_Lease_Number__c  !=null &&
               fullSch.Is_Dataload__c == false )
            {
                
                Integer max = mapMLN_MaxSchNum.get(fullSch.Letter_of_Intent__r.Account__r.Master_Lease_Number__c);
                String schNumber = fullSch.Letter_of_Intent__r.Account__r.Master_Lease_Number__c +'-'+ zeroFillInteger(1 + (max == null?0:max));
                /* Start- This code comes under FAEF-18*/
                fullSch.Account_Lookup__c = fullSch.Letter_of_Intent__r.Account__c;
                /* End- This code comes under FAEF-18*/
                fullSch.Schedule_Number__c = schNumber;
                //Checking if fund source field is null or not
                
                /* Start- This code comes under FAEF-19*/
                if(fullSch.Funding_Source__c==null)
                {
                    fullSch.Funding_Source__c = mapLOIIdToFundingSourceId.get(sch.Letter_of_Intent__c);
                }
                /* End- This code comes under FAEF-19*/
                
                fullSch.Name= schNumber;
                listToUpdate.add(fullSch);
            }
            setAccountIdToCreateGuarantor.add(fullSch.Account_Lookup__c);
        }
        
        if(!listToUpdate.isEmpty()){
            //System.Debug(LoggingLevel.ERROR,'Schedules NOT Updated');
            update listToUpdate;
            //System.Debug(LoggingLevel.ERROR,'Schedules Updated');
            Boolean result = SL_Tasker.createTasks(listToUpdate, 'Project_Manager__c');
            //System.Debug(LoggingLevel.ERROR,'result: ' +result);
        }
        
        if(!setAccountIdToCreateGuarantor.isEmpty())
            createGuarantorRecords(setAccountIdToCreateGuarantor, newMap.values());
    }
    private String zeroFillInteger(Integer myInt)
    {
        String over9  = '';
        String under10 = '0';

        String outputString = String.valueOf(0);

        if(myInt > 0)
            outputString = (myInt > 9?over9:under10) + String.valueOf(myInt);

        return outputString;
    }
    
    /*
     @JIRA Ticket  : FAEF-26
     @CreatedBy    : Lodhi
     @MethodName   : createGuarantorRecords
     @param        : set of AccountIds and list of Schedule
     @Description  : This method is used to create the Guarantor for Schedules related list
     
    */
    private void createGuarantorRecords(Set<Id> setAccountIds, List<Schedule__c> lstSchedule)
    {
        List<Guarantor__c> lstGuarantorToInsert = new List<Guarantor__c>();
        Map<Id, List<Guarantor_Co_Lessee__c>> mapAccountIdToLstOfGuarantorLessee = new Map<Id, List<Guarantor_Co_Lessee__c>>();

        Map<String,String> recordTypes = new Map<String,String>();
        for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType ='Guarantor__c'])
        {
            recordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        for(Guarantor_Co_Lessee__c objGL : [SELECT Id,Account__c,
                                                   Address__c,Co_Lessee__c,Co_Lessee_Account__c,
                                                   Federal_Tax_ID__c,Guarantor_Account__c,
                                                   Guarantor_Contact__c,Guarantor_Type__c,
                                                    Schedule__c,RecordTypeId,RecordType.DeveloperName
                                              FROM Guarantor_Co_Lessee__c
                                             WHERE Account__c IN: setAccountIds])
        {
            if(!mapAccountIdToLstOfGuarantorLessee.containskey(objGL.Account__c))
                mapAccountIdToLstOfGuarantorLessee.put(objGL.Account__c, new List<Guarantor_Co_Lessee__c>());
            mapAccountIdToLstOfGuarantorLessee.get(objGL.Account__c).add(objGL);
        }
        
        for(Schedule__c objSchedule : lstSchedule)
        {
            if(objSchedule.Account_Lookup__c != null && mapAccountIdToLstOfGuarantorLessee.containsKey(objSchedule.Account_Lookup__c))
            {
                for(Guarantor_Co_Lessee__c objGL : mapAccountIdToLstOfGuarantorLessee.get(objSchedule.Account_Lookup__c))
                {
                    String recType = recordTypes.get(objGL.RecordType.DeveloperName);
                    lstGuarantorToInsert.add(new Guarantor__c(Address__c = objGL.Address__c,
                                                              Co_Lessee__c = objGL.Co_Lessee__c,
                                                              Co_Lessee_Account__c = objGL.Co_Lessee_Account__c,
                                                              Federal_Tax_ID__c = objGL.Federal_Tax_ID__c,
                                                              Guarantor_Account__c = objGL.Guarantor_Account__c,
                                                              Guarantor_Contact__c = objGL.Guarantor_Contact__c,
                                                              Guarantor_Type__c = objGL.Guarantor_Type__c,
                                                              Schedule__c = objSchedule.Id,
                                                              RecordTypeId = recType));
                }
            }
        }
        
        if(!lstGuarantorToInsert.isEmpty())
            insert lstGuarantorToInsert;
    }
    /* End */

    public void onBeforeUpdate(Map<Id, Schedule__c> newMap, Map<Id, Schedule__c> oldMap)
    {
        Set<Id> fmaSchedules = new Set<Id>();
        List<Proceeds__c> newProceeds = new List<Proceeds__c>();
        for(Id sId : newMap.keySet())
        {
            if(newMap.get(sId).Stage__c == 'Booked'){
            	/* Added for FAEF-65 */
            	//Avoiding FMA_Extension_Notice_Received__c and FMA_Extension_Notice_Received__c becomes null by validation rule
            	if(oldMap.get(sId).Selected_FMA_Option__c != newMap.get(sId).Selected_FMA_Option__c 
            		&& newMap.get(sId).Selected_FMA_Option__c == 'Option 1 - Purchase')
            	{
            		newMap.get(sId).FMA_Renewal_Run__c = true;
            		newMap.get(sId).FMA_Renewal_Run_Date__c = Date.today();
            	}
            	/* Added for FAEF-65 */	
            	
            	if(newMap.get(sId).Financial_Product__c == 'First Amendment Deal' && newMap.get(sId).Selected_FMA_Option__c == 'Option 1 - Purchase'
        		   && newMap.get(sId).FMA_Extension_Notice_Received__c != null && newMap.get(sId).FMA_Renewal_Effective_Date__c != null 
        		   && (oldMap.get(sId).Financial_Product__c != newMap.get(sId).Financial_Product__c 
        		   || oldMap.get(sId).Selected_FMA_Option__c != newMap.get(sId).Selected_FMA_Option__c
        		   || oldMap.get(sId).FMA_Extension_Notice_Received__c != newMap.get(sId).FMA_Extension_Notice_Received__c 
        		   || oldMap.get(sId).FMA_Renewal_Effective_Date__c != newMap.get(sId).FMA_Renewal_Effective_Date__c))
    			{
    			    newMap.get(sId).FMA_Renewal_Run__c = true;   
    			    newMap.get(sId).FMA_Renewal_Run_Date__c = Date.today();
    			    newMap.get(sId).Final_Outcome__c = 'Lessee Equipment Purchase';
    			}
            	
                if(newMap.get(sId).FMA_Renewal_Effective_Date__c != null && newMap.get(sId).FMA_Extension_Notice_Received__c != null 
                    && oldMap.get(sId).FMA_Renewal_Effective_Date__c == null && oldMap.get(sId).FMA_Extension_Notice_Received__c == null
                    && !newMap.get(sId).FMA_Renewal_Run__c && newMap.get(sId).Selected_FMA_Option__c != 'Option 1 - Purchase')
                {   
                    newMap.get(sId).FMA_Renewal_Run__c = true;
                    //newMap.get(sId).RMA_Renewal_Run_Date__c = newMap.get(sId).FMA_Renewal_Effective_Date__c;
                    newMap.get(sId).FMA_Renewal_Run_Date__c = newMap.get(sId).FMA_Renewal_Effective_Date__c;
                    //newMap.get(sId).Current_Lease_Expiration_Date__c = newMap.get(sId).FMA_Renewal_Effective_Date__c.addMonths((newMap.get(sId).FMA_Extension_Period_in_Months__c != null) ? (Integer)newMap.get(sId).FMA_Extension_Period_in_Months__c : 0);
                    Date dtEndMonth = newMap.get(sId).FMA_Renewal_Effective_Date__c.addMonths((newMap.get(sId).FMA_Extension_Period_in_Months__c != null) ? (Integer)newMap.get(sId).FMA_Extension_Period_in_Months__c : 0);
                    newMap.get(sId).Current_Lease_Expiration_Date__c = Date.newInstance(dtEndMonth.year(), dtEndMonth.month()-1, (Date.daysInMonth(dtEndMonth.year(), (dtEndMonth.month()-1))));
                    newMap.get(sId).Current_Residual_Notice_Date__c = newMap.get(sId).Current_Lease_Expiration_Date__c.addDays((Integer)(-1*( (newMap.get(sId).Notice_Days_Required__c != null) ? newMap.get(sId).Notice_Days_Required__c : 0)));

                }
            }
        }
    }

    public void onAfterUpdate(Map<Id, Schedule__c> newMap, Map<Id, Schedule__c> oldMap)
    {
        System.debug(LoggingLevel.ERROR, '##isFirstUpdateCall: ' + isFirstUpdateCall);
    	//Create proceed records
    	if(isFirstUpdateCall){
        
	        //System.debug(LoggingLevel.ERROR, 'helper method called');
	        Set<Id> fmaSchedules = new Set<Id>();
	        List<Proceeds__c> newProceeds = new List<Proceeds__c>();
	        for(Id sId : newMap.keySet())
	        {
	            if( newMap.get(sId).Stage__c == 'Booked' && newMap.get(sId).Financial_Product__c == 'First Amendment Deal'
                    && newMap.get(sId).FMA_Renewal_Effective_Date__c != null && newMap.get(sId).FMA_Extension_Notice_Received__c != null
	                && (newMap.get(sId).Selected_FMA_Option__c == 'Option 1 - Purchase'  || newMap.get(sId).Selected_FMA_Option__c == 'Option 2 - Extension') 
                    && oldMap.get(sId).FMA_Renewal_Effective_Date__c !=  newMap.get(sId).FMA_Renewal_Effective_Date__c 
                    && newMap.get(sId).Current_Residual_Notice_Date__c != null)
	            {
                    /*
                    system.debug(LoggingLevel.ERROR, '##newMap.get(sId).FMA_Renewal_Effective_Date__c.addDays(-1) == (newMap.get(sId).Current_Lease_Expiration_Date__c: ' + (Boolean)(newMap.get(sId).FMA_Renewal_Effective_Date__c.addDays(-1) == (newMap.get(sId).Current_Lease_Expiration_Date__c)));
                    if( newMap.get(sId).FMA_Renewal_Effective_Date__c >= newMap.get(sId).Current_Residual_Notice_Date__c )
                    {   
	                   fmaSchedules.add(sId);
                    }
                    */
                }
                else if(newMap.get(sId).FMA_Renewal_Effective_Date__c < newMap.get(sId).Current_Residual_Notice_Date__c
                    && (Boolean)(newMap.get(sId).FMA_Renewal_Effective_Date__c.addDays(-1) == (newMap.get(sId).Current_Lease_Expiration_Date__c))
                    && newMap.get(sId).Selected_FMA_Option__c != 'Option 1 - Purchase')
                {
                    //newProceeds.addAll(getFmaProceeds(newMap.get(sId)));
                }
	        }
	        
            /*
	        if(fmaSchedules.size() > 0 ){        
	            for(Proceeds__c pro : [SELECT Id, type__c, Date_Posted__c, Amount__c, Schedule__r.FMA_Renewal_Effective_Date__c 
	                                  FROM Proceeds__c
	                                  WHERE Schedule__c IN : fmaSchedules
	                                  AND Type__c IN ('Renewal Rent', 'Lessee Equipment Purchase')])
	            {
	                if(pro.Date_Posted__c >= pro.Schedule__r.FMA_Renewal_Effective_Date__c)
	                {
	                    newProceeds.add(new Proceeds__c(Amount__c = -1*pro.Amount__c, 
	                                                    Date_Posted__c = pro.Date_Posted__c,
	                                                    Renewal_Type__c = 'FMA', Type__c = pro.Type__c,
	                                                    Schedule__c = pro.Schedule__c,
	                                                    Related_Proceeds__c = pro.Id));//Populating the related lookup on Proceed records
	                }
	            }
	        }
            */
            if(newProceeds.size() > 0){
                insert newProceeds;
            }
	        createProceedRecords(newMap, oldMap);
    	}
    }

    private List<Proceeds__c> getFmaProceeds(Schedule__c schedule) //Need to comment out this method
    {
        system.debug(LoggingLevel.ERROR, '##getFmaProceeds called');
        List<Proceeds__c> fmaProceeds = new List<Proceeds__c>();

        Integer paymentCount = schedule.FMA_Extension_Period_in_Months__c !=null ? Integer.valueOf(schedule.FMA_Extension_Period_in_Months__c) : 0;
        Double paymentMonthSpan = 1.0; //defines number of months between payments
        Double paymentRemainder = 0.0; //used when the extension term is not evenly divisble by the payment freqency 

        String frequency = schedule.Contract_Extension_Renewal_Frequency__c !=null ? schedule.Contract_Extension_Renewal_Frequency__c : schedule.Payment_Frequency__c; 

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
        }//monthSpan already set to 1 in the case that it's monthly

        system.debug(LoggingLevel.ERROR, '##paymentRemainder: ' + paymentRemainder);
        system.debug(LoggingLevel.ERROR, '##paymentCount: ' + paymentCount);
        system.debug(LoggingLevel.ERROR, '##paymentMonthSpan: ' + paymentMonthSpan);

        Decimal residualBalance; //Need to move residualbalance logic to proceeds trigger
        if(Schedule.Residual_Balance__c + Schedule.Payment_Amount__c < 1){
            residualBalance = 0;
        }
        else if(Schedule.Residual_Balance__c + schedule.Payment_Amount__c < schedule.Payment_Amount__c){
            residualBalance = Schedule.Residual_Balance__c + Schedule.Payment_Amount__c;
        }
        else{
            residualBalance = Schedule.Payment_Amount__c;
        }
        for(Integer i = 1; i <= paymentCount; i++){
            System.debug(LoggingLevel.ERROR, '##getFmaProceeds loop 1 entered');
            Date expirationDate = schedule.FMA_Renewal_Effective_Date__c;
            Date datePosted = Date.newInstance(expirationDate.year(), expirationDate.month() + (Integer)(paymentMonthSpan*(i-1)), i == 1 ? expirationDate.day() : 1);
            
            Decimal proceedResidual = getProceedResidual(residualBalance, Schedule, Schedule.Payment_Amount__c);
            residualBalance -= Schedule.Payment_Amount__c;
            
            fmaProceeds.add(new Proceeds__c(Schedule__c = schedule.Id, 
                Amount__c = schedule.Contract_Extension_Renewal_Rental_Amount__c != null ? schedule.Contract_Extension_Renewal_Rental_Amount__c : schedule.Payment_Amount__c != null ? schedule.Payment_Amount__c : 0.0, 
                Date_Posted__c = datePosted, Type__c = 'Renewal Rent', Renewal_Type__c = 'FMA', Residual_Recovery__c = proceedResidual));
        }

        if(paymentRemainder != 0){
            System.debug(LoggingLevel.ERROR, '##getFmaProceeds loop 1 entered');
            Date expirationDate = schedule.FMA_Renewal_Effective_Date__c;
            Date datePosted = Date.newInstance(expirationDate.year(), expirationDate.month() + (Integer)((paymentMonthSpan*paymentCount)+paymentRemainder), 1);

            Decimal proceedResidual = getProceedResidual(residualBalance, Schedule, Schedule.Payment_Amount__c);
            residualBalance -= Schedule.Payment_Amount__c;

            fmaProceeds.add(new Proceeds__c(Schedule__c = schedule.Id, 
                Amount__c = (paymentRemainder/paymentMonthSpan)*(schedule.Contract_Extension_Renewal_Rental_Amount__c != null ? schedule.Contract_Extension_Renewal_Rental_Amount__c : schedule.Payment_Amount__c != null ? schedule.Payment_Amount__c : 0.0), 
                Date_Posted__c = datePosted, Type__c = 'Renewal Rent', Renewal_Type__c = 'FMA', Residual_Recovery__c = proceedResidual));   
        }

        return fmaProceeds;
    }

    public Static Decimal getProceedResidual(Decimal residualBalance, Schedule__c Schedule, Decimal amount){
        Decimal proceedResidual;
        if(residualBalance + amount < 1){
            proceedResidual = 0;
        }
        else if(residualBalance + amount < amount){
            proceedResidual = Schedule.Residual_Balance__c + amount;
        }
        else{
            proceedResidual = amount;
        }
        return proceedResidual;
    }
	
	/*
     @JIRA Ticket  : FAEF-65
     @CreatedBy    : Lodhi
     @MethodName   : createProceedRecords
     @param        : Old and new map of Proceeds__c
     @Description  : Creating the Proceeds__c records 
    */
    private void createProceedRecords(Map<Id, Schedule__c> mapIdToScheduleNew, Map<Id, Schedule__c> mapIdToScheduleOld)
    {
    	List<Proceeds__c> lstProceeds = new List<Proceeds__c>();
    	Set<Id> setScheduleId = new Set<Id>(); 
    	
    	//Iterating over schedule to created proceed records  
    	for(Schedule__c obSchedule : mapIdToScheduleNew.values())
    	{
            if(obSchedule.Stage__c == 'Booked'){
        		if(obSchedule.Financial_Product__c == 'First Amendment Deal'
                       && (obSchedule.Selected_FMA_Option__c == 'Option 1 - Purchase')
            		   && obSchedule.FMA_Extension_Notice_Received__c != null && obSchedule.FMA_Renewal_Effective_Date__c != null && obSchedule.Stage__c == 'Booked' 
            		   && (mapIdToScheduleOld.get(obSchedule.Id).Financial_Product__c != obSchedule.Financial_Product__c 
            		   || mapIdToScheduleOld.get(obSchedule.Id).Selected_FMA_Option__c != obSchedule.Selected_FMA_Option__c
            		   || mapIdToScheduleOld.get(obSchedule.Id).FMA_Extension_Notice_Received__c != obSchedule.FMA_Extension_Notice_Received__c 
            		   || mapIdToScheduleOld.get(obSchedule.Id).FMA_Renewal_Effective_Date__c != obSchedule.FMA_Renewal_Effective_Date__c)
                       )
    			{
            		setScheduleId.add(obSchedule.Id);
    				lstProceeds.add(new Proceeds__c(Schedule__c = obSchedule.Id, Date_Posted__c = obSchedule.FMA_Renewal_Effective_Date__c, 
    												Amount__c = obSchedule.FMA_Purchase_Option_dollars__c, Type__c = 'Lessee Equipment Purchase'));
    			}
            }    		   
    	}
    	
    	//creating the negative schedule records for each of the future renewal proceeds at and beyond the FMA Effective Date
    	if(setScheduleId.size() > 0)
    	{ 
            /*       
            for(Proceeds__c objProceed : [SELECT Id, 
            							  		 Date_Posted__c, 
            							  		 Amount__c, 
            							  		 Schedule__r.FMA_Renewal_Effective_Date__c 
                                  			FROM Proceeds__c
                                  		   WHERE Schedule__c IN : setScheduleId
                                  			 AND Type__c = 'Renewal Rent'])
            {
                if(objProceed.Date_Posted__c >= objProceed.Schedule__r.FMA_Renewal_Effective_Date__c)
                {
                    lstProceeds.add(new Proceeds__c(Amount__c = -1 * objProceed.Amount__c, 
                                                    Date_Posted__c = objProceed.Date_Posted__c,
                                                    Renewal_Type__c = 'FMA', Type__c = 'Renewal Rent',
                                                    Schedule__c = objProceed.Schedule__c,
                                                    Related_Proceeds__c = objProceed.Id));//Populating the related lookup on Proceed records
                }
            }
            */
            insert lstProceeds;	
        }
    	isFirstUpdateCall = false;//avoiding recursive update call
    }
    /* End */

}