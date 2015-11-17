@isTest
private class Test_SL_MassEdit_CompanyListMember 
{
	public static List<Account> accounts = new List<Account>();
	/*public static List<Project__c> projects = new List<Project__c>();
	public static List<Call_Log__c> calLogs = new List<Call_Log__c>();*/
	public static List<Company_List__c> companyLists = new List<Company_List__c>();
	public static List<Company_List_Member__c> companyListMembers = new List<Company_List_Member__c>();
	
	static void createData(){
		accounts.add(new Account(name='test1', BillingCountry = 'USA', BillingState = 'CA'));
        insert accounts;
        
        companyLists.add(new Company_List__c(Name = 'Test company list 1'));
        insert companyLists;

	}
	
	public static testMethod void coverage_SL_MassEdit_CompanyListMember() {
		createData();
	    test.startTest();
	    
	  //  try {
	  List<SL_MassEdit1__c> DefaultSettings = new List<SL_MassEdit1__c>();
	  DefaultSettings = SL_MassEdit1__c.getAll().values();
	  SL_MassEdit1__c SL_ME1;
	  //if(DefaultSettings == null)
	  if(DefaultSettings.isempty())
	  {
	  				SL_ME1 = new SL_MassEdit1__c(	name = 'TEST',
	  												customSettingName__c = 'Company_List_Member',
	  												customSettingCount__c = 5,
	  												targetObjectName__c = 'Company_List_Member__c',
	  												targetObjectParentFieldName__c = 'Company_List__c',
	  												parentObjectName__c = 'Company_List__c',
	  												fieldNamesNotColumns__c = 'Company__c',
	  												fieldNamesNotNulls__c = 'Company__c',
	  												fieldsAsPicklists__c = 'Company__c',
	  												fieldsFilterIgnored__c = 'Company__c'
	  												);
	  		insert SL_ME1;
	  }
	  else 
	  {
	  	if(DefaultSettings[0]!=null)
	  	{
	  		SL_ME1 = DefaultSettings[0];
	  		SL_ME1.name = 'TEST';
	  		SL_ME1.customSettingName__c = 'Company_List_Member';
	  		SL_ME1.customSettingCount__c = 5;
	  		SL_ME1.targetObjectName__c = 'Company_List_Member__c';
	  		SL_ME1.targetObjectParentFieldName__c = 'Company_List__c';
	  		SL_ME1.parentObjectName__c = 'Company_List__c';
	  		SL_ME1.fieldNamesNotColumns__c = 'Company__c;Name';
	  		SL_ME1.fieldNamesNotNulls__c = 'Company__c;Name';
	  		SL_ME1.fieldsAsPicklists__c = 'Company__c;Name';
	  		SL_ME1.fieldsFilterIgnored__c = 'Company__c;Name';
	  		update SL_ME1;
	  	}
	  
	  }
	  ApexPages.currentPage().getParameters().put('clId',companyLists.get(0).id);
			SL_MassEdit_CompanyListMember controller = new SL_MassEdit_CompanyListMember();
			
			system.debug('==== getConverterCallLogs() ==== >>>> '+controller.getConvertedCallLogs());
			//system.debug('==== getConvertedFilters() ==== >>>> '+controller.getConvertedFilters());
			//system.debug('==== getCasted_me_object() ==== >>>> '+controller.getCasted_me_object());
			
			SL_MassEdit.MemberContainer mc = new SL_MassEdit.MemberContainer();
			SL_MassEdit_CompanyListMember.MemberContainerCasted meclm = 
					new SL_MassEdit_CompanyListMember.MemberContainerCasted(mc);
			meclm.getCastedSObject();
			
			List<SObject> lst = new List<SObject>();
			system.debug('==== castAndSave() ==== >>>> '+controller.castAndSave(lst));
			system.debug('==== getNewTargetObject() ==== >>>> '+controller.getNewTargetObject());
			
			controller.columns = new List<SL_MassEdit.ColumnInfo>();
			controller.columns.add(new SL_MassEdit.ColumnInfo('NameInv','','NameInv',true,true));
			controller.columns.add(new SL_MassEdit.ColumnInfo('NameInv','','NameInv',true));
			controller.customSettingCount = 1;
			controller.selectedColumnsCallback = 'Name';
			controller.saveSelectedColumns();
						
			controller.getShowColumn_Company();
			controller.getShowColumn_Name();
			controller.getShowColumn_CompanyType();
			controller.getShowColumn_Contact();
        
	    test.stopTest();
	}
}