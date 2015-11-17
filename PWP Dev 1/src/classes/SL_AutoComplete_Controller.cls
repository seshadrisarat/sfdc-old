/**
* \arg ClassName        : SL_AutoComplete_Controller
* \arg JIRATicket     	: PWP-83
* \arg CreatedOn      	: 24/JULY/2015
* \arg LastModifiedOn	: 14/SEP/2015
* \arg CreatededBy    	: Prakash 
* \arg ModifiedBy     	: Lodhi
* \arg Description      : This is the class for Auto Complete
*/
global class SL_AutoComplete_Controller
{
	/**
	    @MethodName : findSObjects
	    @Param 		: Sobject name, user ids to avoid, search string   
	    @Description: this method will return the sobject records
    **/
	@RemoteAction
	global static List<Sobject> findSObjects(String strObjectName, String selectedIds, String strSearchText){
		Set<string> setSelectedIds = new Set<string>();
		String strIdentifier = '';
		if(strObjectName.contains('-') && strObjectName.split('-').size() == 2)
		{
		    strIdentifier = strObjectName.split('-')[1];
		    strObjectName = strObjectName.split('-')[0];
		}
		
		String strQuery = 'SELECT Id, Name FROM ' + strObjectName + ' WHERE Name LIKE \'%' + strSearchText + '%\'';
		if(strObjectName == 'User' || strObjectName == 'Opportunity')
		{
    		for(String strId : selectedIds.replace('[','').replace(']','').replace(' ','').split(',')){
    			setSelectedIds.add(strId);
    		}
		    strQuery += (strIdentifier == '') ? ' AND IsActive = TRUE AND Id NOT IN : setSelectedIds' : ' AND Id IN : setSelectedIds';   
		}
		return database.query(strQuery);
	}
}