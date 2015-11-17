/**
* \arg ClassName        : SL_AutoComplete_Controller
* \arg JIRATicket     	: NPD-86
* \arg CreatedOn      	: 09/03/2015
* \arg LastModifiedOn	: 
* \arg CreatededBy    	: Sandeep 
* \arg ModifiedBy     	: 
* \arg Description      : This is the class for Auto Complete
*/
global class SL_AutoComplete_Controller
{
	/**
	    @MethodName : findSObjects
	    @Param 		: Sobject name
	    @Description: this method will return the sobject records
    **/
	@RemoteAction
	global static list<Sobject> findSObjects(String strObjectName, String selectedPracticeId, String strSearchText){
		List<RecordType> lstRecordType = [SELECT Id FROM RecordType WHERE SobjectType ='Account' AND DeveloperName ='Parent_Account'];
		String strQuery = 'SELECT Id, Name FROM ' + strObjectName + ' WHERE Name LIKE \'%' + strSearchText + '%\'';
		strQuery += selectedPracticeId == '' ?  ' AND RecordTypeId =\''+ lstRecordType[0].Id +'\'' : ' AND Practice__c =:selectedPracticeId';
		return database.query(strQuery);
	}
}