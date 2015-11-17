public with sharing class SL_Company_Project_Quick_Create
{
    public Account currentAccount {get; set;}
    public Contact ceoContact {get; set;}
    public Deal__c currentDeal {get; set;}
    public Financial__c currentFin {get; set;}
    public boolean isShowAddCompInfo {get; set;}
    public boolean isShowAddDealInfo {get; set;}

    public String strDealTeamIDs {get; set;}
    public String newStrDealTeamIDs {get; set;}

    public String strFundOwnIDs {get; set;}
    public String newStrFundOwnIDs {get; set;}
    public boolean isAddDealInfo {get; set;}
    public boolean isAddFinInfo {get; set;}


    public String DealRecordID {get; set;}

    public SL_Company_Project_Quick_Create(ApexPages.StandardController stdController)
    {
        currentAccount = (Account)stdController.getRecord();
        init();
    }

    public SL_Company_Project_Quick_Create()
    {
        init();
    }
    
    public void init()
    {
        if(currentAccount == null){ currentAccount = new Account();}
        currentAccount.Company_Type__c = 'Early-Prospect';
        if(ceoContact == null){ ceoContact = new Contact();}
        if(currentDeal == null){ currentDeal = new Deal__c(Stage__c='Early-Prospect');}
        if(currentFin == null){ currentFin = new Financial__c();}
        
        isAddDealInfo = true;
        
        
        ID RelContactID = null;
        for(User item:[Select u.Related_Contact_Id__c, u.Id From User u where u.id=:UserInfo.getUserId() limit 1])
        {
        	if(item.Related_Contact_Id__c!=null && item.Related_Contact_Id__c!='') RelContactID = (ID)item.Related_Contact_Id__c;
        }
        
        if(RelContactID!=null)
        {
        	for(Contact item:[Select c.WP_Group__c, c.Id From Contact c where c.Id=:RelContactID limit 1])
        	{
        		if(item.WP_Group__c!=null && item.WP_Group__c!='') currentDeal.WP_Groups_picklist__c  = item.WP_Group__c;
        	}
        }
        /*
        for(Contact item:[select ID,])
        {
        	
        }
        */
        
        isShowAddCompInfo = false;
        strDealTeamIDs = '';
        DealRecordID = '';
        //Platform Deal
        for(RecordType item:[Select Name, ID From RecordType where SobjectType='Deal__c' and IsActive=true and DeveloperName='Platform_Deal' limit 1])
        {
            DealRecordID = ''+item.ID;
        }
    }
    
    public List<Schema.FieldSetMember> getQuickCreateCEOFields() 
    {
        return SObjectType.Contact.FieldSets.Quick_Create_CEO.getFields();
    }
    
    public List<Schema.FieldSetMember> getQuickCreateFinancialLeftFields() 
    {
        return SObjectType.Financial__c.FieldSets.Quick_Create_2_Column_Left.getFields();
    }
    public List<Schema.FieldSetMember> getQuickCreateFinancialRightFields() 
    {
        return SObjectType.Financial__c.FieldSets.Quick_Create_2_Column_Right.getFields();
    }
    
    public List<Schema.FieldSetMember> getQuickCreateDealLeftFields() 
    {
        return SObjectType.Deal__c.FieldSets.Quick_Create_2_Column_Left.getFields();
    }
    public List<Schema.FieldSetMember> getQuickCreateDealRightFields() 
    {
        return SObjectType.Deal__c.FieldSets.Quick_Create_2_Column_Right.getFields();
    }
    public List<Schema.FieldSetMember> getQuickCreateDealAddLeftFields() 
    {
        return SObjectType.Deal__c.FieldSets.Quick_Create_Add_Info_Left.getFields();
    }
    public List<Schema.FieldSetMember> getQuickCreateDealAddRightFields() 
    {
        return SObjectType.Deal__c.FieldSets.Quick_Create_Add_Info_Right.getFields();
    }
    public List<Schema.FieldSetMember> getQuickCreateDealCenterFields() 
    {
        return SObjectType.Deal__c.FieldSets.Quick_Create_1_Column.getFields();
    }
    
    public List<SelectOption> getDealRecordIDs()
    {
        List<SelectOption> options = new List<SelectOption>();
        for(RecordType item:[Select Name, ID From RecordType where SobjectType='Deal__c' and IsActive=true])
        {
            options.add(new SelectOption(item.ID,item.Name));
        }
        
        return options;
    }
    
    
    public PageReference save()
    {
        boolean isSaveWOError = true;
        
        ID AccountDefaultRecordTypeID = null;
        ID ContactDefaultRecordTypeID = null;
        for(RecordType item:[Select Name, ID, SobjectType, DeveloperName  From RecordType where SobjectType in ('Account','Contact') and IsActive=true and DeveloperName in ('Operating_Company','Contact')])
        {
            if(item.SobjectType=='Account' && item.DeveloperName=='Operating_Company') AccountDefaultRecordTypeID = item.ID;
            else if(item.SobjectType=='Contact' && item.DeveloperName=='Contact') ContactDefaultRecordTypeID = item.ID;
        }
        

        if(AccountDefaultRecordTypeID!=null) currentAccount.RecordTypeId = AccountDefaultRecordTypeID;
        upsert currentAccount;

        if(ContactDefaultRecordTypeID!=null) ceoContact.RecordTypeId = ContactDefaultRecordTypeID;
        ceoContact.AccountId = currentAccount.ID;
        ceoContact.MailingCity = currentAccount.BillingCity;
        ceoContact.MailingState = currentAccount.BillingState;
        ceoContact.MailingCountry = currentAccount.BillingCountry;
        ceoContact.Title = 'CEO';
        if(ceoContact.LastName != null )upsert ceoContact;
        
        
        if(isAddDealInfo==true)
		{
	        if(DealRecordID!=null && DealRecordID!='')
	        {
	            try
	            {
	                currentDeal.RecordTypeId = (ID)DealRecordID;
	            }
	            catch (Exception e) {}
	        }
	        currentDeal.Company__c = currentAccount.ID;
	        
	        upsert currentDeal;
	        
	        //Select d.Role__c, d.Employee__c, d.Deal__c From Deal_Team__c d
	
	        // SAVING DEAL TEAM ITEMS!!!!!!!!!!!
	        List<Deal_Team__c> lst2Insert = new List<Deal_Team__c>();
	        List<Deal_Team__c> lst2Delete = new List<Deal_Team__c>();
	        for(Deal_Team__c item:[select Id from Deal_Team__c where Deal__c=:currentDeal.ID]){ lst2Delete.add(item);}
	        if(lst2Delete.size()>0){ delete lst2Delete;}
	        if(this.strDealTeamIDs!=null && this.strDealTeamIDs!='undefined' && this.strDealTeamIDs.trim()!='')
	        {
	            set<ID> setContactIDs = new set<ID>();
	            for(String item:this.strDealTeamIDs.split(','))
	            {
	            	try{ setContactIDs.add((ID)item);}
		            catch (Exception e) {}
	            }
	            if(setContactIDs.size()>0)
	            {
	            	Map<ID, Contact> mapContactInfo = new Map<ID, Contact>([SELECT Id, ISSENIORTEAMMEMBER__c FROM Contact where ID in :setContactIDs limit 1000]);
	            
		            for(ID item:setContactIDs)
		            {
		                if(mapContactInfo.containsKey(item))
		                {
			                Deal_Team__c dtItem = new Deal_Team__c();
			                dtItem.Deal__c = currentDeal.ID;
			                dtItem.Employee__c = item;
//			                dtItem.Status__c = 'Active';

			                if(mapContactInfo.get(item).ISSENIORTEAMMEMBER__c==1){dtItem.Role__c = 'Senior Team Member';}
			                else{dtItem.Role__c = 'Team Member';}
			                lst2Insert.add(dtItem);
						}
		            }
				}
	        }
	        if(lst2Insert.size()>0){ insert lst2Insert;}
	        if(lst2Insert.size()==0)
	        {
	        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Quick Create must require at least 1 deal team member.'));
	        	isSaveWOError = false;
	        }
	        
	        // END SAVING DEAL TEAM ITEMS!!!!!!!!!!!
	
	        // SAVING Fund Ownership ITEMS!!!!!!!!!!!
	        List<Fund_Ownership__c> lstFO2Insert = new List<Fund_Ownership__c>();
	        List<Fund_Ownership__c> lstFO2Delete = new List<Fund_Ownership__c>();
	        for(Fund_Ownership__c item:[select Id from Fund_Ownership__c where Deal__c=:currentDeal.ID and Portfolio_Company__c=:currentAccount.ID]){ lstFO2Delete.add(item);}
	        if(lstFO2Delete.size()>0){ delete lstFO2Delete;}
	        if(this.strFundOwnIDs!=null && this.strFundOwnIDs!='undefined' && this.strFundOwnIDs.trim()!='')
	        {
	            for(String item:this.strFundOwnIDs.split(','))
	            {
	                Fund_Ownership__c dtItem = new Fund_Ownership__c();
	                dtItem.Deal__c = currentDeal.ID;
	                dtItem.Portfolio_Company__c = currentAccount.ID;
	                dtItem.Fund__c = item;      
	                lstFO2Insert.add(dtItem);
	            }
	        }
	        if(lstFO2Insert.size()>0){ insert lstFO2Insert;}
	        // END Fund Ownership ITEMS!!!!!!!!!!!
		}
        
		if(isAddFinInfo==true)
		{
			currentFin.Company__c = currentAccount.ID;
			upsert currentFin;
		}
        
        

        // Send the user to the detail page for the new account.
        PageReference acctPage = null;  
        
        if(isSaveWOError)
        {
        	acctPage = new ApexPages.StandardController(currentAccount).view();
        	acctPage.setRedirect(true);
        }
        return acctPage;
    }
    
    public void loadDealTeamItems()
    {
        strDealTeamIDs = newStrDealTeamIDs;
        strFundOwnIDs = newStrFundOwnIDs;
    }
    
    public String getJSONDealTeamIDs()
    {
        String retVal = '';
        if(this.strDealTeamIDs!=null && this.strDealTeamIDs.trim()!='' &&  this.strDealTeamIDs.trim()!='undefined')
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

    public String getJSONFundOwnIDs()
    {
        String retVal = '';
        if(this.strFundOwnIDs!=null && this.strFundOwnIDs.trim()!='' &&  this.strFundOwnIDs.trim()!='undefined')
        {
            Set<ID> setContIDs = new Set<ID>();
            for(String item:this.strFundOwnIDs.split(','))
            {
                setContIDs.add(item);
            }
            for(Fund__c item:[select ID,Name from Fund__c where ID in :setContIDs limit 1000])
            {
                if(retVal!='') retVal += ',';
                retVal += '"'+item.ID+'" : "'+item.Name+'"';
            }
        }
        
        return retVal;
    }
    
    public void showMoreCompDetail()
    {
        isShowAddCompInfo = true;
    }

    public void showMoreDealDetail()
    {
        isShowAddDealInfo = true;
    }
    
    public void hideMoreCompDetail()
    {
        isShowAddCompInfo = false;
    }
    public void hideMoreDealDetail()
    {
        isShowAddDealInfo = false;
    }
}