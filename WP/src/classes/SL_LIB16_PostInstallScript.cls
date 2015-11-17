global class SL_LIB16_PostInstallScript implements InstallHandler
{
	global void onInstall(InstallContext context)
	{
		RecordType rtOPbj;
		for(RecordType item:[Select SobjectType, Name, Id, DeveloperName, Description From RecordType where DeveloperName='CompanyList' and SobjectType='Mass_Edit_Settings__c' limit 1])
		{
			rtOPbj = item;
		}
		/*
		if(rtOPbj==null)
		{
			rtOPbj = new RecordType(Name='CompanyList', Description='CompanyList', DeveloperName='CompanyList', SobjectType='Mass_Edit_Settings__c');
			insert rtOPbj;
		}
		*/
		
		
		
		//Select m.Sort_Field__c, m.Show__c, m.RecordTypeId, m.Number__c, m.Name, m.Label__c, m.Field__c From Mass_Edit_Settings__c m
		List<Mass_Edit_Settings__c> lstMES = new List<Mass_Edit_Settings__c>();
		Mass_Edit_Settings__c itemMES1 = new Mass_Edit_Settings__c();
		itemMES1.Name = 'Name';
		itemMES1.Label__c = 'Name';
		itemMES1.Field__c = 'name';
		itemMES1.Sort_Field__c = 'name';
		itemMES1.Show__c = false;
		itemMES1.Number__c = 1.0;
		itemMES1.RecordTypeId = rtOPbj.ID;
		lstMES.add(itemMES1);
		
		Mass_Edit_Settings__c itemMES2 = new Mass_Edit_Settings__c();
		itemMES2.Name = 'Company';
		itemMES2.Label__c = 'Company';
		itemMES2.Field__c = 'company__c';
		itemMES2.Sort_Field__c = 'company__c';
		itemMES2.Show__c = false;
		itemMES2.Number__c = 2.0;
		itemMES2.RecordTypeId = rtOPbj.ID;
		lstMES.add(itemMES2);
		
		Mass_Edit_Settings__c itemMES3 = new Mass_Edit_Settings__c();
		itemMES3.Name = 'Contact Name';
		itemMES3.Label__c = 'Contact Name';
		itemMES3.Field__c = 'contact__c';
		itemMES3.Sort_Field__c = 'contact__c';
		itemMES3.Show__c = false;
		itemMES3.Number__c = 3.0;
		itemMES3.RecordTypeId = rtOPbj.ID;
		lstMES.add(itemMES3);
		
		Mass_Edit_Settings__c itemMES4 = new Mass_Edit_Settings__c();
		itemMES4.Name = 'Company Type';
		itemMES4.Label__c = 'Company Type';
		itemMES4.Field__c = 'company__r.type';
		itemMES4.Sort_Field__c = 'company__r.type';
		itemMES4.Show__c = false;
		itemMES4.Number__c = 4.0;
		itemMES4.RecordTypeId = rtOPbj.ID;
		lstMES.add(itemMES4);
		
		insert lstMES;
		

		//Select s.Order__c, s.ObjectName__c, s.Name, s.Label__c From SearchColumns__c s
		List<SearchColumns__c> lstSC = new List<SearchColumns__c>();
		SearchColumns__c itemSC1 = new SearchColumns__c();
		itemSC1.Name = 'Name';
		itemSC1.Label__c = 'Company Name';
		itemSC1.Order__c = 1.0;
		itemSC1.ObjectName__c = 'Company_List_Member__c';
		lstSC.add(itemSC1);
		
		SearchColumns__c itemSC2 = new SearchColumns__c();
		itemSC2.Name = 'RecordType.Name';
		itemSC2.Label__c = 'Record Type';
		itemSC2.Order__c = 2.0;
		itemSC2.ObjectName__c = 'Company_List_Member__c';
		lstSC.add(itemSC2);
		
		SearchColumns__c itemSC3 = new SearchColumns__c();
		itemSC3.Name = 'Type';
		itemSC3.Label__c = 'Cust Type';
		itemSC3.Order__c = 3.0;
		itemSC3.ObjectName__c = 'Company_List_Member__c';
		lstSC.add(itemSC3);

		SearchColumns__c itemSC4 = new SearchColumns__c();
		itemSC4.Name = 'Industry';
		itemSC4.Label__c = 'Industry';
		itemSC4.Order__c = 4.0;
		itemSC4.ObjectName__c = 'Company_List_Member__c';
		lstSC.add(itemSC4);

		insert lstSC;
		
		/*
		Select s.targetObjectParentFieldName__c, s.targetObjectName__c, s.parentObjectName__c, s.isViewState__c, 
		s.fieldsFilterIgnored__c, s.fieldsAsPicklists__c, s.fieldNamesNotNulls__c, s.fieldNamesNotColumns__c, 
		s.customSettingName__c, s.customSettingCount__c, s.Name From SL_MassEdit1__c s
		*/
		SL_MassEdit1__c itemMEMain = new SL_MassEdit1__c();
		itemMEMain.targetObjectParentFieldName__c = 'Company_List__c';
		itemMEMain.targetObjectName__c = 'Company_List_Member__c';
		itemMEMain.parentObjectName__c = 'Company_List__c';
		itemMEMain.isViewState__c = true;
		itemMEMain.fieldsFilterIgnored__c = '';
		itemMEMain.fieldsAsPicklists__c = '';
		itemMEMain.fieldNamesNotNulls__c = '';
		itemMEMain.fieldNamesNotColumns__c = '';
		itemMEMain.customSettingName__c = 'Company_List_Member';
		itemMEMain.customSettingCount__c = 2.0;
		itemMEMain.Name = 'CompanyList';
		
		insert itemMEMain; 
		
	}

}