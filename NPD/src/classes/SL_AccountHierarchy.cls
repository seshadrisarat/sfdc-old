/**
	*  Controller 	     : SL_AccountHierarchy
	*  CreatedOn      	 : 06/OCT/2015
	*  ModifiedBy        : Sandeep 
	*  Description       : This the account Hierarchy page Controller 
*/
public with sharing class SL_AccountHierarchy
{
	/*Global Variables*/
	public List <AccountWrapper> lstAccountWrapper 					{	get;set;	}
	public Map<String, String> mapAccountToSpace_indicatingLevel 	{	get;set;	}
	public Id idAccountId {get;set;}
	public Map<String, String> mapRecordTypeNameToColorCode         {   get;set;    }
	/*!
        * Wrapper Class : AccountWrapper
        * Description: This contains Account and unique level Id
    */
	public class AccountWrapper
	{
		public Account objAccount						            {	get;set;	}
		public String strUniqueLevel					            {	get;set;	}
		public AccountWrapper(Account objAccount, String strUniqueLevel)
		{
			this.objAccount = objAccount;
			this.strUniqueLevel = strUniqueLevel;
		}
	}
	
	/* Start - Constructor */ 
	public SL_AccountHierarchy()
	{
	    
	}
	/* End - Constructor */
    public void  fetchAccountHierarchy()
    {
        lstAccountWrapper = new List<AccountWrapper>();
		mapAccountToSpace_indicatingLevel = new Map<String, String>();
		mapRecordTypeNameToColorCode = new map<String, String>();
		for(SL_AccountRecordType__c objCustomSett: SL_AccountRecordType__c.getAll().values())
		{
		    mapRecordTypeNameToColorCode.put(objCustomSett.Name, objCustomSett.Color__c);
		}
        if(idAccountId != null)
            CreateAccountStructure(idAccountId);
    }
	
	/*!
        * MethodName : CreateAccountStructure
        * param      : Context Account Id
        * Description: fetching ultimate parent and calling setAccountHirerchyLevel method for structrd data displaying in the page
    */
	private void CreateAccountStructure(String strCurrentAccId)
	{
		Account objContextAccount;
		Id idParentCorporatId;
		// Fetching the Account based on the Id provided in the URL
		for(Account objAccount : [Select Id, Company_Account__r.Corporate_Account__c, Corporate_Account__c, Company_Account__c FROM Account WHERE Id =: strCurrentAccId])
		{
			objContextAccount = objAccount;
			idParentCorporatId = objAccount.Company_Account__c != null ? objAccount.Company_Account__r.Corporate_Account__c :
			                     objAccount.Corporate_Account__c != null ? objAccount.Corporate_Account__c:
			                     objAccount.Id;
		}
		if(objContextAccount != null)
			setAccountHirerchyLevel(new set<Id>{idParentCorporatId});
	}
    
    /*!
        * MethodName : setAccountHirerchyLevel
        * param      : Ultimate Parent Id
        * Description: Cretae the structured data for displaying in page
    */
    private void setAccountHirerchyLevel(Set <Id> setCurrentParentId)
    {
    	List <Account> lstAllAccount = new List <Account> ();
    	List<String> lstNode   = new List<String>();
    	
    	Map<ID, String> mapAccIdToUniqueNodeId =  new Map<Id, String>{};
    	Map <String, AccountWrapper> mapNodeIdToAccount = new Map <String, AccountWrapper> (); 
    	
    	String strUniqueNodeId;
    	Integer intLevel = 0;
    	Boolean endOfStructure = false;
    	List<String> lstFields = new List<String>();
    	for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.SL_SearchAccountHierarchy.getFields()) 
    	{
            lstFields.add(f.getFieldPath());
        }
    	while ( !endOfStructure )
    	{
    		if( intLevel == 0 )
    		{
    			// Fetchong the Account if the level is zero 
    			lstAllAccount = Database.query('SELECT Id, RecordType.DeveloperName, Name, Corporate_Account__c, Company_Account__c, '+ String.join(lstFields, ',') +' FROM Account WHERE Id IN : setCurrentParentId ORDER BY Name');
    		}	
    		else
    			// Fetching the Account based on the parent id set below
    			lstAllAccount = Database.query('SELECT Id, RecordType.DeveloperName, Name, Corporate_Account__c, Company_Account__c, '+ String.join(lstFields, ',') +' FROM Account WHERE Company_Account__c IN : setCurrentParentId OR Corporate_Account__c IN :setCurrentParentId ORDER BY Name');
    		
    		if(lstAllAccount.isEmpty())
                endOfStructure = true;
            else
            {
				setCurrentParentId.clear();
        	  	
        	  	for ( Integer index = 0 ; index < lstAllAccount.size(); index++ )
        	  	{
        	  		// Set the unique row id based on each level
        	  		 strUniqueNodeId = ( intLevel > 0 ) ? mapAccIdToUniqueNodeId.get( lstAllAccount[index].Company_Account__c )+String.valueOf( index )+'_0' : String.valueOf( index );
        	  		 //map of node id and Account wrapper class
        	  		 mapNodeIdToAccount.put(strUniqueNodeId, new AccountWrapper(lstAllAccount[index],strUniqueNodeId ));
        	  		 
        	  		 setCurrentParentId.add(lstAllAccount[index].Id);
        	  		 mapAccIdToUniqueNodeId.put(lstAllAccount[index].Id, strUniqueNodeId);
        	  		 lstNode.add(strUniqueNodeId);
        	  	}
        	  	intLevel++;
            }
    	}
    	
    	// Sorting the List
    	lstNode.sort();
		
		// Iterating through the list of node    	
    	for(String strNodeId : lstNode)
        {
            Integer intCount = 0;
            String strSpace ;
            if(strNodeId.contains('_'))
            {
                for(String str1 : strNodeId.split('_'))
                    intCount++;
                for(Integer managePaddingBasedOnLevel=0; managePaddingBasedOnLevel<intCount; managePaddingBasedOnLevel++)
                   strSpace = 'padding-left:'+ 38*managePaddingBasedOnLevel+'px';
                mapAccountToSpace_indicatingLevel.put(strNodeId,strSpace);
            }
            
            if(!strNodeId.contains('_'))
                mapAccountToSpace_indicatingLevel.put(strNodeId,''); 
            
           if(!mapNodeIdToAccount.isEmpty() && mapNodeIdToAccount.containsKey(strNodeId))
	       		lstAccountWrapper.add(mapNodeIdToAccount.get(strNodeId));
        }
    }
}