/**
	* \arg \b ClassName      : SL_Batch_CreateProceedRecords
	* \arg \b JIRATicket     : FAEF-38
	* \arg \b CreatedOn      : 11/Sep/2014
	* \arg \b ModifiedBy     : Pankaj Ganwani
	* \arg \b Description    : This batch class is used to create the Proceeds records from Schedule if notice given date field is blank	
*/
global class SL_Batch_CreateProceedRecords implements Database.Batchable<sObject>
{
     /* Start - Constructor */
     global SL_Batch_CreateProceedRecords()
	 {
		//Do Nothing
     }
     /* End - Constructor */
	 
	 /*!
        * MethodName : start
        * param      : Database.BatchableContext
        * Description: This is the start method to pass the query records to execute method
    */
     global Database.QueryLocator start(Database.BatchableContext BC) 
     {   
      	return Database.getQueryLocator('SELECT Id, Name, Date_Written_Notice_Received__c, FMA_Renewal_Run__c, Selected_FMA_Option__c, Financial_Product__c, Contract_Extension_Renewal_Rental_Amount__c, Contract_Extension_Renewal_Frequency__c, Payment_Frequency__c, Base_Lease_Termination_Date__c, FMA_Extension_Period_in_Months__c, EOT_Status__c, Renewal_Term__c, Initial_Residual_Notice_Date__c, Lease_Term__c, FMA_Extension_Notice_Received__c, Base_Lease_Commencement_Date__c, Extension_Period_Months__c, Current_Lease_Expiration_Date__c, Current_Residual_Notice_Date__c, Notice_Days_Required__c, Payment_Amount__c  FROM Schedule__c WHERE Stage__c = \'Booked\' AND Base_Lease_Termination_Date__c!=null  AND Initial_Residual_Notice_Date__c <  TODAY  AND Financial_Product__c IN (\'Fair Market Value\',\'First Amendment Deal\')  AND (Current_Residual_Notice_Date__c = null OR Current_Residual_Notice_Date__c < TODAY) AND Lease_Status_from_Data_Warehouse__c != \'Disposed\' AND IsRenewal__c = FALSE');
     }
	 
	 /*!
        * MethodName : execute
        * param      : Database.BatchableContext and list of sobject records
        * Description: This method is used to update the schedule records and create the corresponding proceed records
    */
     global void execute(Database.BatchableContext BC, List<sObject> scope) 
     {
		//Checking if scope is not empty
		if(!scope.isEmpty())
		{
			List<Proceeds__c> lstProceeds = new List<Proceeds__c>();// list of proceed records that needs to be inserted
			List<Schedule__c> lstSchedule = new List<Schedule__c>();//list of schedule records that needs to be iterated
			lstSchedule.addAll((List<Schedule__c>) scope);
			List<Schedule__c> lstScheduleToUpdate = new List<Schedule__c>();//list of schedule records that needs to be updated
			
			//Iterating over schedule object to update the schedule records with renewal date and create the corresponding Proceed records
			for(Schedule__c objSchedule : lstSchedule)
			{		
				//getting new renewal date 
				Date dtRenewalStartDate = objSchedule.Base_Lease_Termination_Date__c.addDays(1);
				
				//getting extension period in months
				Integer extensionPeriod = objSchedule.Extension_Period_Months__c!=null ? Integer.valueOf(objSchedule.Extension_Period_Months__c) : 3;
				
				//getting current lease expiration date
				Date dtCurrentLeaseExpirationDate = objSchedule.Current_Lease_Expiration_Date__c!=null ? getEndOfMonth(objSchedule.Current_Lease_Expiration_Date__c.addMonths(extensionPeriod)) : getEndOfMonth(objSchedule.Base_Lease_Termination_Date__c.addMonths(extensionPeriod));
				
				Integer paymentCount;//defines the number of proceed records to create
				Boolean setFmaRun = false;
				Boolean isFma = false;
				
				/*Start - Added by Lodhi on 09/JAN/2015 as per Steve comment on 7/JAN/2015*/
				if(objSchedule.Financial_Product__c == 'First Amendment Deal' && objSchedule.FMA_Extension_Notice_Received__c != null && objSchedule.FMA_Renewal_Run__c == false)
				{
					dtCurrentLeaseExpirationDate = getEndOfMonth(objSchedule.Current_Lease_Expiration_Date__c.addMonths(objSchedule.FMA_Extension_Period_in_Months__c !=null ? Integer.valueOf(objSchedule.FMA_Extension_Period_in_Months__c) : 0));		
					paymentCount = objSchedule.FMA_Extension_Period_in_Months__c !=null ? Integer.valueOf(objSchedule.FMA_Extension_Period_in_Months__c) : 0;
					setFmaRun = true;
					isFma = true;
				}//remove
				else{
					dtCurrentLeaseExpirationDate = getEndOfMonth(objSchedule.Current_Lease_Expiration_Date__c.addMonths(extensionPeriod));
					paymentCount = extensionPeriod; 
				}
				/*End - Added by Lodhi on 09/JAN/2015 as per Steve comment on 7/JAN/2015*/ 
				
				//getting current residual notice date
				Date dtCurrentResidualNoticeDate = dtCurrentLeaseExpirationDate.addDays(-(objSchedule.Notice_Days_Required__c!=null ? Integer.valueOf(objSchedule.Notice_Days_Required__c) : 90));

				if(
					(objSchedule.Financial_Product__c == 'Fair Market Value' &&
						(	(objSchedule.Date_Written_Notice_Received__c == Null && objSchedule.Current_Residual_Notice_Date__c < Date.Today()
							) || 
							objSchedule.Date_Written_Notice_Received__c > objSchedule.Current_Residual_Notice_Date__c
						)
					) ||
					(objSchedule.Financial_Product__c == 'First Amendment Deal' &&
						(	(objSchedule.FMA_Extension_Notice_Received__c == Null && objSchedule.Current_Residual_Notice_Date__c < Date.Today()
							) ||
							objSchedule.FMA_Extension_Notice_Received__c > objSchedule.Current_Residual_Notice_Date__c
						)
					)
				){	
					Schedule__c updSched = new Schedule__c(Id = objSchedule.Id, EOT_Status__c = 'Extension', 
															Renewal_Start_Date__c = dtRenewalStartDate, 
															Current_Residual_Notice_Date__c = dtCurrentResidualNoticeDate, 
															Current_Lease_Expiration_Date__c = dtCurrentLeaseExpirationDate,
															Extension_Period_Months__c = extensionPeriod,
															Payment_Frequency__c = objSchedule.Payment_Frequency__c !=null ? objSchedule.Payment_Frequency__c : 'monthly',
															Notice_Days_Required__c = objSchedule.Notice_Days_Required__c!=null ? Integer.valueOf(objSchedule.Notice_Days_Required__c) : 90,
														    Extended_Lease_Term__c = objSchedule.Notice_Days_Required__c!=null ? dtRenewalStartDate.addDays(- Integer.valueOf(objSchedule.Notice_Days_Required__c)) : dtRenewalStartDate,
															FMA_Renewal_Run__c = (setFmaRun && !objSchedule.FMA_Renewal_Run__c) ? true : false,
															FMA_Renewal_Run_Date__c = (setFmaRun && !objSchedule.FMA_Renewal_Run__c) ? Date.today() : null);
					if(objSchedule.Date_Written_Notice_Received__c <= objSchedule.Current_Residual_Notice_Date__c){
						updSched.isRenewal__c = true;
					}
					if(	objSchedule.Financial_Product__c == 'First Amendment Deal' && 
						objSchedule.FMA_Extension_Notice_Received__c <= objSchedule.Current_Residual_Notice_Date__c &&
						objSchedule.Selected_FMA_Option__c == 'Option 1 - Purchase'
					){
						updSched.Final_Outcome__c = 'Lessee Equipment Purchase';
					}
					lstScheduleToUpdate.add(updSched);
				}
				else if(objSchedule.Financial_Product__c == 'Fair Market Value' && 
						objSchedule.Date_Written_Notice_Received__c <= objSchedule.Current_Residual_Notice_Date__c){
					lstScheduleToUpdate.add(new Schedule__c(Id = objSchedule.Id,
															isRenewal__c = true));
				}
				else if(objSchedule.Financial_Product__c == 'First Amendment Deal' && 
						objSchedule.FMA_Extension_Notice_Received__c <= objSchedule.Current_Residual_Notice_Date__c &&
						objSchedule.Selected_FMA_Option__c == 'Option 1 - Purchase' 
				){
					lstScheduleToUpdate.add(new Schedule__c(Id = objSchedule.Id,
															Final_Outcome__c = 'Lessee Equipment Purchase'));
				}

				if(objSchedule.Financial_Product__c == 'Fair Market Value' &&
					(	(objSchedule.Date_Written_Notice_Received__c == Null && objSchedule.Current_Residual_Notice_Date__c < Date.Today()
						) || 
						objSchedule.Date_Written_Notice_Received__c != null
					)
				){										
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
					}//monthSpan already set to 1 in the case that it's monthly

					for(Integer i = 1; i <= paymentCount; i++){
						Date expirationDate = getEndOfMonth(objSchedule.Current_Lease_Expiration_Date__c!=null ? objSchedule.Current_Lease_Expiration_Date__c: objSchedule.Base_Lease_Termination_Date__c);
						Date datePosted = Date.newInstance(expirationDate.year(), expirationDate.month() + (Integer)(paymentMonthSpan*(i-1) + 1), 1);
						lstProceeds.add(new Proceeds__c(Schedule__c = objSchedule.Id, 
							Amount__c = objSchedule.Contract_Extension_Renewal_Rental_Amount__c != null ? objSchedule.Contract_Extension_Renewal_Rental_Amount__c : objSchedule.Payment_Amount__c, 
							Date_Posted__c = datePosted, Type__c = 'Renewal Rent', Renewal_Type__c = isFma ? 'FMA' : 'FMV'));
					}

					if(paymentRemainder != 0){
						Date expirationDate = getEndOfMonth(objSchedule.Current_Lease_Expiration_Date__c!=null ? objSchedule.Current_Lease_Expiration_Date__c: objSchedule.Base_Lease_Termination_Date__c);
						Date datePosted = Date.newInstance(expirationDate.year(), expirationDate.month() + (Integer)(paymentMonthSpan*paymentCount + 1), 1);

						System.debug('!!objSchedule.Id: ' + objSchedule.Id);
						System.debug('!!paymentRemainder: ' + paymentRemainder);
						System.debug('!!paymentMonthSpan: ' + paymentMonthSpan);
						System.debug('!!objSchedule.Contract_Extension_Renewal_Rental_Amount__c: ' + objSchedule.Contract_Extension_Renewal_Rental_Amount__c);
						System.debug('!!objSchedule.Payment_Amount__c: ' + objSchedule.Payment_Amount__c);
						System.debug('!!datePosted: ' + datePosted);
						System.debug('!!isFma: ' + isFma);
						System.debug('!!paymentRemainder/paymentMonthSpan: ' + (paymentRemainder/paymentMonthSpan));
						lstProceeds.add(new Proceeds__c(Schedule__c = objSchedule.Id, 
							Amount__c = (paymentRemainder/paymentMonthSpan)*(objSchedule.Contract_Extension_Renewal_Rental_Amount__c != null ? objSchedule.Contract_Extension_Renewal_Rental_Amount__c : objSchedule.Payment_Amount__c), 
							Date_Posted__c = datePosted, Type__c = 'Renewal Rent', Renewal_Type__c = isFma ? 'FMA' : 'FMV'));	
					}
				}
			}
			
			if(!lstScheduleToUpdate.isEmpty())
				Database.update(lstScheduleToUpdate, false);//updating the existing schedules
			
			if(!lstProceeds.isEmpty())
				Database.insert(lstProceeds,false);//inserting the processes
		}
     }
	 
	 /*!
        * MethodName : finish
        * param      : Database.BatchableContext
        * Description: This is the finish method of this batch process
    */
     global void finish(Database.BatchableContext BC)
     {
   		//Do Nothing
     }


     public static Date getEndOfMonth(Date inputDate){
     	return inputDate.addMonths(1).toStartOfMonth().addDays(-1);
     }
}