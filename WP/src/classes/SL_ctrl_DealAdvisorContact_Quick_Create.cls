public without sharing class SL_ctrl_DealAdvisorContact_Quick_Create 
{
	public Contact newContact {get;set;}
	public String searchContactText {get;set;}
	public String typeOpen {get;set;}
	public list<SearchContact> listSearchContacts {get;set;}
	public list<DealAdvisorContact> listNewDealAdvisorContacts {get;set;}
	private Boolean isDebug = false;
	private Deal__c curDeal;
	public Id curDealId {get;set;}
	private Deal_Advisor_Contact__c newDealAdvisorContact;
	private set<Id> immedContactsIds;
	
	public String strDealTeamIDs {get; set;}
	//public String Param;
	
	public SL_ctrl_DealAdvisorContact_Quick_Create()
	{
		this.newContact = new Contact();
		this.typeOpen = 'newadvisorcontact';
		if(isDebug)  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM , 'did = '+ApexPages.currentPage().getParameters().get('did')));
		this.curDealId = ApexPages.currentPage().getParameters().get('did');
		listNewDealAdvisorContacts = new list<DealAdvisorContact>();
		if(this.curDealId != null)
		{
			newDealAdvisorContact = new Deal_Advisor_Contact__c(Deal__c = this.curDealId);
			//newDealAdvisorContact.Deal__c = this.curDealId;
			listNewDealAdvisorContacts.add(new DealAdvisorContact(newDealAdvisorContact,false));
		}
		if(isDebug) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM , 'listNewDealAdvisorContacts = '+listNewDealAdvisorContacts));
		
		
	}
	public PageReference addDealAdvisorContact()
	{
		this.typeOpen = 'newadvisorcontact';
		if(this.curDealId != null)
		{
			newDealAdvisorContact = new Deal_Advisor_Contact__c();
			newDealAdvisorContact.Deal__c = this.curDealId;
			listNewDealAdvisorContacts.add(new DealAdvisorContact(newDealAdvisorContact,false));
		}
		return null;
	}
	
	public PageReference del()
	{
		this.typeOpen = 'newadvisorcontact';
		if(listNewDealAdvisorContacts.size() > 0)
		{
			list<Deal_Advisor_Contact__c> list2delete = new list<Deal_Advisor_Contact__c>();
			for(Integer i = 0; i < listNewDealAdvisorContacts.size(); i++)
			{
				if(listNewDealAdvisorContacts[i].isSelected)
				{
					listNewDealAdvisorContacts.remove(i);
				}
			}
		}	
		if(isDebug) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM , 'listNewDealAdvisorContacts = '+listNewDealAdvisorContacts));
		return null;
	}
	
	public PageReference save()
	{
		this.typeOpen = 'newadvisorcontact';
		if(listNewDealAdvisorContacts.size() > 0)
		{
			list<Deal_Advisor_Contact__c> list2upsert = new list<Deal_Advisor_Contact__c>();
			if(isDebug) 
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM , 'id = '+this.curDealId));
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM , 'listNewDealAdvisorContacts = '+listNewDealAdvisorContacts));
			}
			
			
           
			
			for(DealAdvisorContact item : this.listNewDealAdvisorContacts)
			{
				if(item.obj != null && item.obj.Contact__c != null)
				{
					list2upsert.add(item.obj);
				}
			}
			//if(list2upsert.size() > 0) upsert list2upsert;
			
			//system.debug('----------'+listNewDealAdvisorContacts.size());
			//system.debug('----------'+list2upsert.size());
			
			try{
		        if(list2upsert.size() > 0) 
		        {
		        	insert list2upsert;
		        	listNewDealAdvisorContacts = new list<DealAdvisorContact>();
		        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM , 'Deal Advisor Contacts have been inserted successfully!'));
		        }
		        
		        newDealAdvisorContact = new Deal_Advisor_Contact__c(Deal__c = this.curDealId);
				listNewDealAdvisorContacts.add(new DealAdvisorContact(newDealAdvisorContact,false));
		    }
		    catch(DmlException ex)
		    {
		    	//for (Integer i = 0; i < ex.getNumDml(); i++) 
        			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ex.getDmlMessage(i)));
        			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ex.getDmlMessage(0)));
		    }
			
		}
		return null;
	}
	public PageReference goToSearchContact()
	{
		this.typeOpen = 'search';
		
		for(DealAdvisorContact item : this.listNewDealAdvisorContacts)
		{
			if(item.isSelected) 
			{
				this.searchContactText = item.contactText;
				this.listSearchContacts = new list<SearchContact>();   
				break;
			}
		}
		this.searchContact();
		if(isDebug) 
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM , 'this.typeOpen = '+this.typeOpen));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM , 'listNewDealAdvisorContacts = '+listNewDealAdvisorContacts));
		}
		return null;
	}
	public PageReference searchContact()
	{
		this.typeOpen = 'search';
		
		if(this.searchContactText != null)
		{
			List<List<sObject>> searchList = new List<List<sObject>>();
			String tmpSearchKey = this.searchContactText;
			//tmpSearchKey = tmpSearchKey.replace(' ','');
			tmpSearchKey = tmpSearchKey.replace('*','');
			tmpSearchKey = tmpSearchKey.replace('"','');
			tmpSearchKey = tmpSearchKey.replace('\'','');
			if(tmpSearchKey!=null && tmpSearchKey.length()>1)
			{
				
				/*String SQLTxt = 
						'FIND \''+ tmpSearchKey +'*\' IN ALL FIELDS RETURNING ' + 
						'Contact						(Id,FirstName,LastName,Title,AccountId,Account.Name WHERE RecordType.DeveloperName=\'Contact\' AND Account.RecordType.DeveloperName=\'Intermediary\') ';*/
						String SQLTxt = 
						'FIND \''+ tmpSearchKey +'*\' IN ALL FIELDS RETURNING ' + 
						'Contact(Id,FirstName,LastName,Title,AccountId,Account.Name WHERE RecordType.DeveloperName=\'Contact\') ';
				List<String> searchQueryList = new List<String>();
				List<List<sObject>> temp;
				searchList = search.query(SQLTxt);
				system.debug('================SQLTxt=============' + SQLTxt);
				system.debug('================searchList=============' + searchList);
					//searchQueryList = searchQuery.split('&split;',0);
				for (String elem: searchQueryList) 
				{
						temp = search.query(elem);
						if (temp != null) 
							searchList.add(temp[0]);
						else 
							searchList.add(new List<Contact>());
				}
			}
				
			this.listSearchContacts = new list<SearchContact>();  
			if(searchList!=null && searchList.size()>0 && searchList[0].size()>0 ) 
			{
				for(sObject item : searchList[0])
				{
					this.listSearchContacts.add(new SearchContact((Contact)item,false));
				}
				
			}
		}
		
		return null;
	}
	
	public PageReference setContactToSelected()
	{
		if(this.listNewDealAdvisorContacts != null && this.listSearchContacts != null)
		{
			for(DealAdvisorContact item : this.listNewDealAdvisorContacts)
			{
				if(item.isSelected) 
				{	
					for(SearchContact c : this.listSearchContacts)
					{
						if(c.isSelected) 
						{
							item.obj.Contact__c = c.obj.Id;
							item.contactobj = c.obj;
							item.contactText = (c.obj.FirstName != null ? c.obj.FirstName+' ' : '')+c.obj.LastName;
							c.isSelected = false;
							item.isSelected = false;
							this.typeOpen = 'newadvisorcontact';
							break;
						}
					}
				}
			}
			//this.newContact = new Contact();
		}
		if(isDebug) 
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM , 'this.newContact = '+this.newContact));
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM , 'listNewDealAdvisorContacts = '+listNewDealAdvisorContacts));
			}
			
		return null;
	}
	public PageReference newContact()
	{
		this.typeOpen = 'newcontact';
		return null;
	}
	
	/*public set<Id> immedContactsIds(){
		
		set <Id> immedContactsIds = new set<Id>();
		
		Id intermId = [Select r.Id From RecordType r WHERE r.SobjectType = 'Account' AND r.DeveloperName = 'Intermediary' LIMIT 1].Id;
		
		if(intermId != null){
			for(Account acc :[SELECT a.Id From Account a WHERE a.RecordTypeId =: intermId]){
				immedContactsIds.add(acc.Id);
			}
		}
			for(Account acc :[SELECT Id From Account  ]){
				immedContactsIds.add(acc.Id);
		}
		return immedContactsIds;
	}*/
	
	public PageReference saveContact()
	{
		if(this.newContact != null)
		{
			/*if(this.immedContactsIds == null)
				this.immedContactsIds = immedContactsIds();*/
			
			//if(this.immedContactsIds.contains(this.newContact.AccountId)){
			
				insert this.newContact;
				for(DealAdvisorContact item : this.listNewDealAdvisorContacts)
				{
					if(item.isSelected) 
					{	
						item.obj.Contact__c = this.newContact.Id;
						item.contactobj = this.newContact;
						item.contactText = (this.newContact.FirstName != null ? this.newContact.FirstName+' ' : '')+this.newContact.LastName;
						item.isSelected = false;
						break;
					}
				}
				
				this.typeOpen = 'newadvisorcontact';
				this.newContact = new Contact();
				
		 //  }
			/*else{
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Company must have "Intermediary" record type');
				ApexPages.addMessage(myMsg);
			}*/
		}
		return null;
	}
	public PageReference backContact()
	{
		this.typeOpen = 'newadvisorcontact';
		/*for(DealAdvisorContact item : this.listNewDealAdvisorContacts)
		{
			if(item.isSelected) 
			{
				item.isSelected = false;
				break;
			}
		}*/
		return null;
	}
	public PageReference backAdvCont(){
		this.typeOpen = 'newadvisorcontact';
		for(DealAdvisorContact item : this.listNewDealAdvisorContacts)
		{ 
			if(item.isSelected) 
			{
				item.isSelected = false;
				break;
			}
		}
		return null;
	}
	public String getJSONResponse()
	{
		String retVal = '{"status":200,"list":[{"id":4,"name":"ABC"},{"id":5,"name":"IBM"},{"id":6,"name":"Facebook"},{"id":18,"name":"Adobe Systems"},{"id":26,"name":"BMC Software"},{"id":51,"name":"Toshiba"},{"id":64,"name":"Jabil Circuit"}],"next":false,"prev":false}';

		return retVal;
	}
	public class DealAdvisorContact
	{
		public Deal_Advisor_Contact__c obj {get; set;}
		public Boolean isSelected {get; set;}
		public Contact contactobj {get; set;}
		public String contactText {get; set;}
		
		public DealAdvisorContact(Deal_Advisor_Contact__c p_item, Boolean p_isSelected)
		{
			obj = p_item;
			isSelected = p_isSelected;
			contactobj = new Contact();
		}
	}
	public class SearchContact
	{
		public Contact obj {get; set;}
		public Boolean isSelected {get; set;}
		
		public SearchContact(Contact p_item, Boolean p_isSelected)
		{
			obj = p_item;
			isSelected = p_isSelected;
		}
	}
	
	public String getJSONDealTeamIDs()
	{
		String retVal = '';
		if(this.strDealTeamIDs!=null && this.strDealTeamIDs.trim()!='')
		{
			Set<ID> setContIDs = new Set<ID>();
			for(String item:this.strDealTeamIDs.split(','))
			{
				setContIDs.add(item);
			}
			for(Contact item:[select ID,Name,Account.Name from Contact where ID in :setContIDs limit 1000])
			{
				if(retVal!='') retVal += ',';
				retVal += '"'+item.ID+'" : "'+item.Name+', '+item.Account.Name+'"';
			}
		}
		
		return retVal;
	}
	
}