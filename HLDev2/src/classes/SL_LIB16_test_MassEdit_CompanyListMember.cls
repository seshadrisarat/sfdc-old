@isTest(SeeAllData=true)
private class SL_LIB16_test_MassEdit_CompanyListMember
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
    
    public static testMethod void coverage_SL_LIB16_MassEdit_CompanyListMember()
    {
 		SL_LIB16_install controller_pre = new SL_LIB16_install();
		controller_pre.runChecker();

        createData();
        test.startTest();
        
      //  try {
        
        
        SL_Mass_Implementation__c DefaultSettings = null;
        for(SL_Mass_Implementation__c item:[Select targetObjectSearchFieldName__c, targetObjectParentFieldName__c, targetObjectName__c, searchObjectName__c, 
							parentObjectName__c, Show_Views_on_MassEdit_Page__c, Show_Views_on_MassAdd_Page__c, Search_Page_Title__c, Search_Object_Title__c, Name, 
							Id, Get_Element_from_List_Tab__c From SL_Mass_Implementation__c where Name='CompanyList' limit 1])
		{
			DefaultSettings = item;
		}

		SL_Mass_Implementation__c SL_ME1;
        if(DefaultSettings == null)
        {
            SL_ME1 = new SL_Mass_Implementation__c();
            SL_ME1.targetObjectParentFieldName__c = 'Company_List__c';
            SL_ME1.targetObjectName__c = 'Company_List_Member__c';
            SL_ME1.parentObjectName__c = 'Company_List__c';
            SL_ME1.Name = 'CompanyList';
			try{ insert SL_ME1;}
			catch(Exception e){ }
        }
        else 
        {
            if(DefaultSettings!=null)
            {
                SL_ME1 = DefaultSettings;
                //SL_ME1.targetObjectParentFieldName__c = 'Company_List__c';
                //SL_ME1.targetObjectName__c = 'Company_List_Member__c';
                //SL_ME1.parentObjectName__c = 'Company_List__c';
                //SL_ME1.Name = 'CompanyList';
    
                //update SL_ME1;
            }
      
        }
        
        ApexPages.currentPage().getParameters().put('clId',companyLists.get(0).id);
    	ApexPages.currentPage().getParameters().put('target','Main');
    	ApexPages.currentPage().getParameters().put('implId',''+controller_pre.ME_CompanyList_ObjID);
        
            SL_LIB16_MassEdit_CompanyListMember controller = new SL_LIB16_MassEdit_CompanyListMember();
            controller.strColumnsAndFiltersTemplate = 'All';
            
            system.debug('==== getConverterCallLogs() ==== >>>> '+controller.getConvertedCallLogs());
            //system.debug('==== getConvertedFilters() ==== >>>> '+controller.getConvertedFilters());
            //system.debug('==== getCasted_me_object() ==== >>>> '+controller.getCasted_me_object());
            
            SL_LIB16_MassEdit.MemberContainer mc = new SL_LIB16_MassEdit.MemberContainer();
            SL_LIB16_MassEdit_CompanyListMember.MemberContainerCasted meclm = 
                    new SL_LIB16_MassEdit_CompanyListMember.MemberContainerCasted(mc);
            meclm.getCastedSObject();
            
            List<SObject> lst = new List<SObject>();
            system.debug('==== castAndSave() ==== >>>> '+controller.castAndSave(lst));
            system.debug('==== getNewTargetObject() ==== >>>> '+controller.getNewTargetObject());
            
            controller.columns = new List<SL_LIB16_MassEdit.ColumnInfo>();
            controller.columns.add(new SL_LIB16_MassEdit.ColumnInfo('NameInv','','NameInv',true,true));
            controller.columns.add(new SL_LIB16_MassEdit.ColumnInfo('NameInv','','NameInv',true));
            //controller.customSettingCount = 1;
            controller.selectedColumnsCallback = 'Name';
            controller.saveSelectedColumns();
            controller.getMassEditSettings();
            controller.hasNoError = false;
            controller.loadDefaults();
            
            controller.getCurrentUrlEncoded();
            controller.getConvertedCallLogs();
            controller.dummyFunction();
            controller.doCusSave();
            controller.doDelete();
            
            SL_LIB209_ctrl_SearchBlockParams tmpVal = controller.getSearchCompParams();
                      
            //controller.getShowColumn_Company();
            //controller.getShowColumn_Name();
            //controller.getShowColumn_CompanyType();
            //controller.getShowColumn_Contact();
        
        test.stopTest();
    }
}