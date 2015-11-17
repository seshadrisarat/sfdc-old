public with sharing class MassEditSettingsEdit_Controller {
    public Mass_Edit_Settings__c CurMESettings {get; set;}
    public String CurMESettingsId {get; set;}
    
    public SL_FieldLoader fieldLoader {get; set;}
    public SL_FieldLoader sortedFieldLoader {get; set;} 

    
    public MassEditSettingsEdit_Controller(ApexPages.StandardController stdController)
    {
        init();
        
        Mass_Edit_Settings__c tmpObj = (Mass_Edit_Settings__c)stdController.getRecord();
        this.CurMESettingsId = tmpObj.Id;
        if(this.CurMESettingsId != null && this.CurMESettingsId != '')
        {
      //    this.isEdit = true;
          this.CurMESettings = [  SELECT ID, Name, Field__c, Sort_Field__c, Label__c, Show__c, Number__c
                        FROM Mass_Edit_Settings__c 
                        WHERE ID = : this.CurMESettingsId];
        } else
        {
        //  this.isEdit = false;
          this.CurMESettings = new Mass_Edit_Settings__c();
        }      
        
        try{
            fieldLoader.setSelectedValues(this.CurMESettings.Field__c);
        } catch(Exception e){}
        try{
            sortedFieldLoader.setSelectedValues(this.CurMESettings.Sort_Field__c);
        } catch(Exception e){}
    }
    
    
    void init()
    {       
        fieldLoader = new SL_FieldLoader();
        sortedFieldLoader = new SL_FieldLoader();       
    }
    
    public void updateFieldLists()
    {
        fieldLoader.updateFieldLists();
    }
    
    public void updateSortedFieldLists()
    {
        sortedFieldLoader.updateFieldLists();
    }   
    
    private void saveObj()
    {
        this.CurMESettings.Name = this.CurMESettings.Label__c;
        this.CurMESettings.Field__c = fieldLoader.getValue();
        this.CurMESettings.Sort_Field__c = sortedFieldLoader.getValue();
        upsert this.CurMESettings;
        this.CurMESettingsId = this.CurMESettings.Id;   
    }
    
    public PageReference save()
    {
        this.saveObj();
        PageReference pageRef = new PageReference('/'+this.CurMESettingsId );
        pageRef.setRedirect(true);
        return pageRef;
     }
    
    public PageReference save_new()
    {
        this.saveObj();
        PageReference pageRef = new PageReference('/apex/MassEditSettingsEdit' );
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public static testmethod void test_MassEditSettingsEdit_Controller_newRecord()
    {
        List<MassEditSettings__c> defaultSettings = [SELECT TargetObjectName__c FROM MassEditSettings__c];
        //if (defaultSettings!= null && defaultSettings[0] != null) 
        if (!defaultSettings.isempty())
        {   
             defaultSettings[0].TargetObjectName__c = 'Account';
             update defaultSettings[0];
        }
        
        
        Test.startTest();
        //ApexPages.currentPage().getParameters().put('id', ICObj.Id);
        Mass_Edit_Settings__c obj = new Mass_Edit_Settings__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(obj);
        MassEditSettingsEdit_Controller controller = new MassEditSettingsEdit_Controller(stdController);
        
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
    
    public static testmethod void test_MassEditSettingsEdit_Controller_existenRecord()
    {
        List<MassEditSettings__c> defaultSettings = [SELECT TargetObjectName__c FROM MassEditSettings__c];
        //if (defaultSettings!= null && defaultSettings[0] != null) 
        if (!defaultSettings.isempty())
        {   
             defaultSettings[0].TargetObjectName__c = 'Account';
             update defaultSettings[0];
        }
        
        Mass_Edit_Settings__c obj = new Mass_Edit_Settings__c();
        obj.Field__c = 'MasterRecord.CreatedBy.alias';
        obj.Sort_Field__c = 'name';
        insert obj;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', obj.Id);
        //Mass_Edit_Settings__c obj = new Mass_Edit_Settings__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(obj);
        MassEditSettingsEdit_Controller controller = new MassEditSettingsEdit_Controller(stdController);
        
        controller.fieldLoader.level2ObjectValue = 'billingcity';
        controller.updateFieldLists();
        
        controller.fieldLoader.primaryObjectValue = 'name';
        controller.updateFieldLists();
        
        controller.save_new();
            
        Test.stopTest();
    }

}