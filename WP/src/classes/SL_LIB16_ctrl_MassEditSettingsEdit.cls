public with sharing class SL_LIB16_ctrl_MassEditSettingsEdit
{
    public Mass_Edit_Settings__c CurMESettings {get; set;}
    public String CurMESettingsId {get; set;}
    
    public SL_LIB16_FieldLoader fieldLoader {get; set;}
    public SL_LIB16_FieldLoader sortedFieldLoader {get; set;} 

    
    public SL_LIB16_ctrl_MassEditSettingsEdit(ApexPages.StandardController stdController)
    {
        Mass_Edit_Settings__c tmpObj = (Mass_Edit_Settings__c)stdController.getRecord();
        this.CurMESettingsId = tmpObj.Id;
        init();
    }

	public SL_LIB16_ctrl_MassEditSettingsEdit()
	{
		if(Apexpages.currentPage().getParameters().containsKey('id') && Apexpages.currentPage().getParameters().get('id')!=null && Apexpages.currentPage().getParameters().get('id')!='')
        {
        	this.CurMESettingsId = Apexpages.currentPage().getParameters().get('id');
        }
        init();
	}
    
    void init()
    {       
		if(this.CurMESettingsId != null && this.CurMESettingsId != '')
        {
      //    this.isEdit = true;
          this.CurMESettings = [  SELECT ID, Name, Field__c, Sort_Field__c, Label__c, Show__c, Number__c, RecordTypeId 
                        FROM Mass_Edit_Settings__c 
                        WHERE ID = : this.CurMESettingsId];
        } else
        {
        //  this.isEdit = false;
          this.CurMESettings = new Mass_Edit_Settings__c();
        }      
        
        if(Apexpages.currentPage().getParameters().containsKey('RecordType') && Apexpages.currentPage().getParameters().get('RecordType')!=null && Apexpages.currentPage().getParameters().get('RecordType')!='')
        {
        	this.CurMESettings.RecordTypeId = (ID)Apexpages.currentPage().getParameters().get('RecordType');
        	//system.debug('save URL >>>>>>>>>>>>>> '+this.CurMESettings.RecordTypeId);
        }
        
        
        
        if(this.CurMESettings.RecordTypeId!=null)
        {
        	for(RecordType item : [Select SobjectType, Name, Id, DeveloperName From RecordType where ID=:this.CurMESettings.RecordTypeId limit 1])
        	{
        		//system.debug('RecordType DeveloperName >>>>>>>>>>>>>> '+item.DeveloperName);
        		fieldLoader = new SL_LIB16_FieldLoader(item.DeveloperName);
        		sortedFieldLoader = new SL_LIB16_FieldLoader(item.DeveloperName);
        	}
        }
        if(fieldLoader==null || sortedFieldLoader==null)
        {
        	fieldLoader = new SL_LIB16_FieldLoader();
        	sortedFieldLoader = new SL_LIB16_FieldLoader();
        }       

 		try{
            fieldLoader.setSelectedValues(this.CurMESettings.Field__c);
        } catch(Exception e){}
        try{
            sortedFieldLoader.setSelectedValues(this.CurMESettings.Sort_Field__c);
        } catch(Exception e){}

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
        PageReference pageRef = new PageReference('/apex/SL_LIB16_MassEditSettingsEdit' );
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    

}