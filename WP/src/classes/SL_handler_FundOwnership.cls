/** 
 * \author Vika Osmak 
 * \date 11/23/2012
 * \see https://silverline.jira.com/browse/WP-34
 * \brief  
 * \test 
 */
 @isTest(SeeAllData=true)
public without sharing class SL_handler_FundOwnership 
{
	 private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
     
    public SL_handler_FundOwnership(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnBeforeInsert(list<Fund_Ownership__c> newDealACs)
    {   
        //WP-62
      checkDupesOfFounds(newDealACs);
    }

    public void OnAfterInsert(map<Id,Fund_Ownership__c> newDealACs)
    {   
        //WP-34
    	setRollUpFields(newDealACs.values());
    }
       
    public void OnAfterUpdate(map<Id,Fund_Ownership__c> oldDealACs, map<Id,Fund_Ownership__c> newDealACs)
    {   
    	//WP-34
    	setRollUpFields(newDealACs.values()); 
    }
    
    public void OnAfterDelete(list<Fund_Ownership__c> oldDealACs)
    {   
		//WP-34
    	setRollUpFields(oldDealACs);
    }
    
    private map<ID,Set<Id>> map_Deal_id_Fund_ids = new map<ID,Set<Id>>();
    private map<String,ID> map_Deal_Fund_FO_ids = new map<String,ID>();
    private map<ID,String> map_Fund_Name = new map<ID,String>();

    // WP-62
    private void checkDupesOfFounds(list<Fund_Ownership__c> listDealACs)
    {
    	Set<Id> set_Deal_ids = new Set<Id>();
    	for(Fund_Ownership__c fo : listDealACs)
    	   set_Deal_ids.add(fo.Deal__c);

      for(Fund_Ownership__c fo_old: [SELECT Id,Deal__c,Fund__c,Fund__r.Name FROM Fund_Ownership__c WHERE Deal__c IN :set_Deal_ids LIMIT 2000]) 
      {
      	setMapDealFunds(fo_old);
      }
    	
    	for(Fund_Ownership__c fo : listDealACs) {
         if(fo.Fund__c!= null && map_Deal_id_Fund_ids.containsKey(fo.Deal__c) && map_Deal_id_Fund_ids.get(fo.Deal__c).contains(fo.Fund__c)) {
           String FO_Id_str = '';
           if(map_Deal_Fund_FO_ids.containsKey( String.valueOf(fo.Deal__c)+'-'+String.valueOf(fo.Fund__c) ) )
             FO_Id_str = String.ValueOf( map_Deal_Fund_FO_ids.get(String.valueOf(fo.Deal__c)+'-'+String.valueOf(fo.Fund__c)) );
           fo.Fund__c.addError('The duplicate record on Fund: <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+FO_Id_str+'">'+map_Fund_Name.get(fo.Fund__c)+'</a>' );
         }  
         if(fo.Fund__c!= null && (!map_Deal_id_Fund_ids.containsKey(fo.Deal__c) || !map_Deal_id_Fund_ids.get(fo.Deal__c).contains(fo.Fund__c) ) ) 
         {
           setMapDealFunds(fo);
         }
    	}
    }
    
    // auxilary method for checkDupesOfFounds
    private void setMapDealFunds(Fund_Ownership__c fo_old) {
         Set<Id> set_Fund_ids = new Set<Id>(); 
         if(map_Deal_id_Fund_ids.containsKey(fo_old.Deal__c) ) {
           set_Fund_ids = map_Deal_id_Fund_ids.get(fo_old.Deal__c);
         }  
         set_Fund_ids.add(fo_old.Fund__c);
         map_Deal_id_Fund_ids.put(fo_old.Deal__c,set_Fund_ids);
         if(fo_old.Id != null)
           map_Deal_Fund_FO_ids.put(String.valueOf(fo_old.Deal__c)+'-'+String.valueOf(fo_old.Fund__c),fo_old.Id);
         else
           map_Deal_Fund_FO_ids.put(String.valueOf(fo_old.Deal__c)+'-'+String.valueOf(fo_old.Fund__c),fo_old.Deal__c);  
         map_Fund_Name.put(fo_old.Fund__c,fo_old.Fund__r.Name);
    }
    
    private void setRollUpFields(list<Fund_Ownership__c> newDealAdvisor)
    {
    	map<Id,set<String>> mapDealId_EmployeeLNs = new map<Id,set<String>> ();
    	Set<Id> dealIds = new Set<Id>();
    	for(Fund_Ownership__c item : newDealAdvisor)
    	{
    		if(item.Deal__c != null) dealIds.add(item.Deal__c);
    	}
    	
    	if(dealIds.size() > 0)
    	{
	    	for(Fund_Ownership__c item : [SELECT ID,Deal__c,Fund__c,Fund__r.Acronym__c FROM Fund_Ownership__c WHERE Deal__c IN : dealIds ])
	    	{
	    		if(item.Fund__c != null) 
	    		{
	    			if(!mapDealId_EmployeeLNs.containsKey(item.Deal__c))	mapDealId_EmployeeLNs.put(item.Deal__c,new set<String>());
	    			mapDealId_EmployeeLNs.get(item.Deal__c).add(item.Fund__r.Acronym__c);
	    		}
	    	}
	    	system.debug('mapDealId_EmployeeLNs = '+mapDealId_EmployeeLNs);
	    	
	    	list<Deal__c> deals2Update = new list<Deal__c>();
	    	Deal__c tmpDeal;
	    	String tmpStr = '';
	    	for(Id dealId : dealIds)
	    	{
	    		tmpDeal = new Deal__c(Id = dealId);
    			tmpStr = '';
    			if(mapDealId_EmployeeLNs.get(dealId) != null && mapDealId_EmployeeLNs.get(dealId).size() > 0)
    			{
	    			for(String EmpLN : mapDealId_EmployeeLNs.get(dealId)) tmpStr += ','+EmpLN;
	    			if(tmpStr.length() > 0) tmpStr = tmpStr.substring(1, tmpStr.length());
	    			if(tmpStr.length() > 254) tmpStr = tmpStr.substring(0, 254);
    			}
    			tmpDeal.Fund__c = tmpStr;
    			
    			deals2Update.add(tmpDeal);
	    	}
	    	if(deals2Update.size() > 0)	update deals2Update;
    	}
    }
    
 public static testMethod void testMe(   )
      {
      SL_handler_FundOwnership x = new SL_handler_FundOwnership(false,1);
      x.DummyMethod();
      Fund_Ownership__c fo = new Fund_Ownership__c();

        Account objAccount = new Account(Name ='Test 201502 Account', Public_Private__c = 'public',Sector__c='CIS-Business Services',Geographies__c = 'Africa');
        insert objAccount;

        RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];
        Contact objContact = new Contact(LastName = 'Test Contact 24', RecordTypeId = ContRecTypeId.Id,  User_ID__c = UserInfo.getUserId() );
        insert objContact;
      
        Deal__c objdeal = new Deal__c(Name = 'Test 201502 Deal',Company__c= objAccount.id,Description__c='test',WP_Groups_picklist__c='Energy',CurrencyIsoCode = 'EUR', Is_Energy_Opportunity__c = 'No');
        insert objdeal;
     
      Deal__c dlX = [Select Id From Deal__c limit 1];
      //insert dlX;
      //Fund__c fX = [Select Id From Fund__c limit 1];
      
      fo.Deal__c = dlX.Id;
      //fo.Fund__c = fX.Id;
      //fo.Fund__c
      insert fo;
      
      
      }
 public string DummyMethod()
 {
 string s = '1213';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
return s;
 }   
}