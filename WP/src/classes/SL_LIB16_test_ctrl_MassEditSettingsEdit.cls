@isTest(SeeAllData=true)
private class SL_LIB16_test_ctrl_MassEditSettingsEdit
{
	public static testmethod void test_SL_LIB16_ctrl_MassEditSettingsEdit_newRecord()
    {
        List<MassEditSettings__c> defaultSettings = [SELECT TargetObjectName__c FROM MassEditSettings__c];
        if ( defaultSettings!= null && !defaultSettings.isEmpty() ) 
        {   
             defaultSettings[0].TargetObjectName__c = 'Account';
             update defaultSettings[0];
        } else {
        	insert new MassEditSettings__c( Name = 'Target', TargetObjectName__c = 'Account' );
        }
        
        Test.startTest();
        //ApexPages.currentPage().getParameters().put('id', ICObj.Id);
        Mass_Edit_Settings__c obj = new Mass_Edit_Settings__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(obj);
        SL_LIB16_ctrl_MassEditSettingsEdit controller = new SL_LIB16_ctrl_MassEditSettingsEdit(stdController);
        
        controller.fieldLoader.primaryObjectValue = 'MasterRecord';
        controller.fieldLoader.level2ObjectValue = 'CreatedBy';
        controller.fieldLoader.level3ObjectValue = 'alias';
        
        controller.updateFieldLists();
        
        controller.sortedFieldLoader.primaryObjectValue = 'MasterRecord';
        controller.sortedFieldLoader.level2ObjectValue = 'CreatedBy';
        controller.sortedFieldLoader.level3ObjectValue = 'alias';
        
        controller.updateSortedFieldLists();
        
        controller.save();
            
        Test.stopTest();
    }
    
    public static testmethod void test_SL_LIB16_ctrl_MassEditSettingsEdit_existenRecord()
    {
        List<MassEditSettings__c> defaultSettings = [SELECT TargetObjectName__c FROM MassEditSettings__c];
        if ( defaultSettings!= null && !defaultSettings.isEmpty() ) 
        {
             defaultSettings[0].TargetObjectName__c = 'Account';
             update defaultSettings[0];
        } else {
        	insert new MassEditSettings__c( Name = 'Target', TargetObjectName__c = 'Account' );
        }
        
        Mass_Edit_Settings__c obj = new Mass_Edit_Settings__c();
        obj.Field__c = 'MasterRecord.CreatedBy.alias';
        obj.Sort_Field__c = 'name';
        insert obj;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', obj.Id);
        //Mass_Edit_Settings__c obj = new Mass_Edit_Settings__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(obj);
        SL_LIB16_ctrl_MassEditSettingsEdit controller = new SL_LIB16_ctrl_MassEditSettingsEdit(stdController);
        
        controller.fieldLoader.level2ObjectValue = 'billingcity';
        controller.updateFieldLists();
        
        controller.fieldLoader.primaryObjectValue = 'name';
        controller.updateFieldLists();
        
        controller.save_new();
            
        Test.stopTest();
    }

}