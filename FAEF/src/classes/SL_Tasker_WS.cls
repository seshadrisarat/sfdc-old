global class SL_Tasker_WS {

	Webservice static String createTasks(List<Schedule__c> inpList){
		String retVal = 'false';

		Boolean isSuccess = SL_Tasker.createTasks(inpList,'Project_Manager__c');

		system.debug(LoggingLevel.ERROR,isSuccess);
		if(isSuccess)
			retVal = 'true';
		return retVal;
	}
}