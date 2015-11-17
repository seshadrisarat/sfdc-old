public with sharing class SL_MassEdit_CompanyListMember extends SL_MassEdit {
	public SL_MassEdit_CompanyListMember(){
		super();

	    String clId = ApexPages.currentPage().getParameters().get('clId');
	    
	    
	    List<SL_MassEdit1__c> DefaultSettings = SL_MassEdit1__c.getAll().values();
	    if (DefaultSettings!= null && DefaultSettings[0] != null)
	    {   
	            if(DefaultSettings[0].customSettingName__c != null)    customSettingName = DefaultSettings[0].customSettingName__c.toLowerCase();
			    if(DefaultSettings[0].customSettingCount__c != null)  customSettingCount = Integer.valueOf(DefaultSettings[0].customSettingCount__c);
			    if(DefaultSettings[0].targetObjectName__c != null)    targetObjectName = DefaultSettings[0].targetObjectName__c.toLowerCase();
			    if(DefaultSettings[0].targetObjectParentFieldName__c != null)  targetObjectParentFieldName = DefaultSettings[0].targetObjectParentFieldName__c.toLowerCase();
			    if(DefaultSettings[0].parentObjectName__c != null)    
			    {
			    	parentObjectName = DefaultSettings[0].parentObjectName__c.toLowerCase();
			    	
			    	if(parentObjectName != null)
			    	{
			    		parentObject = [SELECT Id, Name FROM Company_List__c WHERE Id = :clId];
			    		//String query = 'SELECT Id, Name FROM '+ parentObjectName +' WHERE Id = \''+ clId + '\' LIMIT 1'; 
			    		//sObject parentObject = Database.query(query);
			    	}
			    }
			    List<String> lTemp = new List<String>();
			    if(DefaultSettings[0].fieldNamesNotColumns__c != null)  
			    {
			        if(DefaultSettings[0].fieldNamesNotColumns__c.contains(';'))
			        {
			        	lTemp = DefaultSettings[0].fieldNamesNotColumns__c.split(';');
			        	for(String s : lTemp)
			        		fieldNamesNotColumns.add(s.toLowerCase());
			        } 
			        else fieldNamesNotColumns.add(DefaultSettings[0].fieldNamesNotColumns__c.toLowerCase());
			    }
			    if(DefaultSettings[0].fieldNamesNotNulls__c != null)  
			    {
			        if(DefaultSettings[0].fieldNamesNotNulls__c.contains(';'))
			        {
			        	lTemp = new List<String>();
			        	lTemp = DefaultSettings[0].fieldNamesNotNulls__c.split(';');
			        	for(String s : lTemp)
			        		fieldNamesNotNulls.add(s.toLowerCase());
			        } 
			        else fieldNamesNotNulls.add(DefaultSettings[0].fieldNamesNotNulls__c.toLowerCase());
			    }
			    if(DefaultSettings[0].fieldsAsPicklists__c != null)  
			    {
			        if(DefaultSettings[0].fieldsAsPicklists__c.contains(';'))
			        {
			        	lTemp = new List<String>();
			        	lTemp = DefaultSettings[0].fieldsAsPicklists__c.split(';');
			        	for(String s : lTemp)
			        		fieldsAsPicklists.add(s.toLowerCase());
			        } 
			        else fieldsAsPicklists.add(DefaultSettings[0].fieldsAsPicklists__c.toLowerCase());
			    }
			    if(DefaultSettings[0].fieldsFilterIgnored__c != null)  
			    {
			        if(DefaultSettings[0].fieldsFilterIgnored__c.contains(';'))
			        {
			        	lTemp = new List<String>();
			        	lTemp = DefaultSettings[0].fieldsFilterIgnored__c.split(';');
			        	for(String s : lTemp)
			        		fieldsFilterIgnored.add(s.toLowerCase());
			        } 
			        else fieldsFilterIgnored.add(DefaultSettings[0].fieldsFilterIgnored__c.toLowerCase());
			    }
			if(DefaultSettings[0].isViewState__c != null)    isViewState = DefaultSettings[0].isViewState__c;
	    }
	    
    	columns = new List<ColumnInfo>();
    	for(Mass_Edit_Settings__c item : [  
            SELECT ID, Field__c, Sort_Field__c, Label__c, Show__c
                        FROM Mass_Edit_Settings__c 
                        ORDER BY Number__c
                        ])
        {
          //add ColumnInfo(Field   SortExpr    Label     show)
      	columns.add(new ColumnInfo(item.Field__c.toLowerCase(), item.Sort_Field__c.toLowerCase(), item.Label__c, item.Show__c));
        }
        
        system.debug('!!!!!!!!!!!! columns = '+columns);
		refetchColumnHeaders();
		refetchMembers();

		//inEditColumns = true;
	}
	
	public override List<LookUpPickListValue> getCustomPicklistValues(String recordId, String picklistName){
		return new List<LookUpPickListValue>();
	}
	
	public List<MemberContainerCasted> getConvertedCallLogs(){
		List<MemberContainerCasted> res = new List<MemberContainerCasted>();
		/*for (MemberContainer member : membersList){
			member.index = res.size();
			res.add(new MemberContainerCasted(member));
		}*/
		Integer first = Math.min(pageNumber*pageSize, membersList.size());
		Integer last = Math.min(pageNumber*pageSize + pageSize, membersList.size());
		ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'first: ' + first));
		ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'last: ' + last));
		for (Integer i=first; i<last; i++) {
			MemberContainer member = membersList.get(i);
			member.index = res.size();
			//MemberContainerCasted mcc = new MemberContainerCasted(member);
			//ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'mcc: ' + mcc));
			//res.add(mcc);
			res.add(new MemberContainerCasted(member));
		}
		return res; 
	}
	
	public override SObject getNewTargetObject(){
		return new Company_List_Member__c(Company_List__c = parentObject.Id);
	} 
	
	public override boolean castAndSave(List<SObject> lst){
		List<Company_List_Member__c> upd = new List<Company_List_Member__c>();
		for (SObject obj : lst){
			upd.add((Company_List_Member__c)obj);
		}
		try{
			upsert upd;
		}
		catch (Exception e){
			return false;
		}		
		return true;
	}
	
	public class MemberContainerCasted {
		public MemberContainer member {get; set;}
		
		public MemberContainerCasted(MemberContainer member){
			this.member = member;
		}
		
		public Company_List_Member__c getCastedSObject(){
			return (Company_List_Member__c)member.obj;
		}
	}
	
	public void doDelete(){
		List<Company_List_Member__c> delLogs = new List<Company_List_Member__c>();
		for (MemberContainer member : membersList){
			if (member.isSelected) delLogs.add((Company_List_Member__c)member.obj);
		}
		if (delLogs.size()>0) delete delLogs;
		refetchMembers();
	}
	
	public Boolean getShowColumn_Name() {
		return shownColumnNames.contains('name');
	}
	
	public Boolean getShowColumn_Company() {
		return shownColumnNames.contains('company__c');
	}
	
	public Boolean getShowColumn_CompanyType() {
		return shownColumnNames.contains('company__r.type');
	}

	public Boolean getShowColumn_Contact() {
		return shownColumnNames.contains('contact__c');
	}
	public Boolean getShowColumn_Tier() {
		return shownColumnNames.contains('tier__c');
	}
}