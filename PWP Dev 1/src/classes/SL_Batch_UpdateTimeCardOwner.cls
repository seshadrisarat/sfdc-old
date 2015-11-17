/*
@ClassName    : SL_Batch_UpdateTimeCardOwner 
@JIRATicket   : PWP-192
@CreatedOn    : 20/August/2015
@ModifiedBy   : Sathya
@Description  : This Batch will query all Time cards where Owner is not same as the custom setting user 
				and will update owner of time cards to the user which is stored in teh cusrom setting.
*/
global class SL_Batch_UpdateTimeCardOwner implements Database.Batchable<sObject>
{
  	private Id stafferId;
  	public SL_Batch_UpdateTimeCardOwner()
    {
    	Staffer__c objStaffer = Staffer__c.getOrgDefaults();
    	stafferId = objStaffer.UserId__c;
    }
  	/*
	@MethodName: start 
	@param : Database.BatchableContext BC
	@Description: It is Database.QueryLocator method of Database.Batchable interface. 
	*/
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
     	String strQuery = 'SELECT Id FROM Time_Card__c Where OwnerId != :stafferId'; 
     	return Database.getQueryLocator(strQuery);
   	}
   	/*
    @MethodName: execute 
    @param : Database.BatchableContext BC, lstTimeCard
    @Description: It is execute method of Database.Batchable interface.
	*/
   global void execute(Database.BatchableContext BC, List<Time_Card__c>lstTimeCard)
   {
	  List<Time_Card__c>lstTimeCardtoUpadte = new List<Time_Card__c>();
	  for(Time_Card__c objTimeCard : lstTimeCard)
	  {
				objTimeCard.ownerId = stafferId;
				objTimeCard.Locked_for_Time_Entry__c = true;
				lstTimeCardtoUpadte.add(objTimeCard);		
	  }
	  update lstTimeCardtoUpadte;
    }
    /*
    @MethodName: finish 
    @param : Database.BatchableContext BC
    @Description: It is overriden method of Database.Batchable interface.
	*/ 
   global void finish(Database.BatchableContext BC)
   {
		//do nothing
   }
}