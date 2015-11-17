public with sharing class SL_FieldLoader {
	
	private static Map<String, Schema.SObjectType> globalObjectDescribeMap = Schema.getGlobalDescribe();
	private static Map<String, Map<String, Schema.SObjectField>> objTypeFieldDescribeMap = new Map<String, Map<String, Schema.SObjectField>>();
	private Map<String, String> refNameFieldNameMap;
	private Map<String, String> fieldNameFefNameMap;
	public Map<String, Schema.SObjectField> primaryFieldDescribeMap {get; set;}
	
	
	Schema.SObjectType objectType {get; set;}
	
	public List<SelectOption> primaryObjectFields {get; private set;}
	public List<SelectOption> level2ObjectFields {get; private set;}
	public List<SelectOption> level3ObjectFields {get; private set;}
	public String primaryObjectValue {get; set;}
	public String level2ObjectValue {get; set;}
	public String level3ObjectValue {get; set;}
	public Boolean showLevel2 {get; set;}
	public Boolean showLevel3 {get; set;}
	
	public String getValue()
	{
		String result;
		
		if(level2ObjectValue != null && level2ObjectValue != '')
		{
			result = fieldNameFefNameMap.get(primaryObjectValue) + '.';
			if(level3ObjectValue != null && level3ObjectValue != '')
			{
				result += fieldNameFefNameMap.get(level2ObjectValue);
				result += '.' + level3ObjectValue;
			} else
				result += level2ObjectValue;
		} else
			result = primaryObjectValue;
		
		return result;		
	}
	
	public void setSelectedValues(String str)
	{
		if(str != null){
			List<String> valuesList = str.split('\\.');
			if(valuesList.size() > 0){
				if(refNameFieldNameMap.get(valuesList[0]) != null ){
					primaryObjectValue = refNameFieldNameMap.get(valuesList[0]);
					updateFieldLists();
					
					if(valuesList.size() > 1) {
						showLevel2 = true;
						
						if((valuesList.size() > 1) && refNameFieldNameMap.get(valuesList[1]) != null ){
							level2ObjectValue = refNameFieldNameMap.get(valuesList[1]);
							updateFieldLists();
							
							if(valuesList.size() > 2) {
								showLevel3 = true;
								if((valuesList.size() > 2) && refNameFieldNameMap.get(valuesList[2]) != null ){
									level3ObjectValue = refNameFieldNameMap.get(valuesList[2]);
								}else
									level3ObjectValue = valuesList[2];
							}
						}else
							level2ObjectValue = valuesList[1];
					}
				} else
					primaryObjectValue = valuesList[0];
			}
			
			updateFieldLists();
		}
		
		
	}
	
	
	public SL_FieldLoader()
	{
		//get object name from Custom Settings
		String targetObject;
		List<MassEditSettings__c> DefaultSettings = MassEditSettings__c.getAll().values();
        //if (DefaultSettings!= null && DefaultSettings[0] != null)
        if (!defaultSettings.isempty())
        {   
	    	targetObject = DefaultSettings[0].TargetObjectName__c;
        }
        
        objectType = globalObjectDescribeMap.get(targetObject);
        
        Schema.DescribeSObjectResult R = objectType.getDescribe();
        primaryFieldDescribeMap = R.fields.getMap();
        
        primaryObjectFields = getPrimaryFieldSelectOption();
	}
	
	public List<SelectOption> getPrimaryFieldSelectOption()
	{
		return getFieldSelectOptionByObject(objectType);
	}
	
	public void updateFieldLists()
	{
		Schema.DescribeFieldResult f;
		//Schema.SObjectField sof = primaryFieldDescribeMap.get(primaryObjectValue);
		if(primaryFieldDescribeMap.get(primaryObjectValue) != null)
		{
			f = primaryFieldDescribeMap.get(primaryObjectValue).getDescribe();
			
	    	if(f.getType() == Schema.DisplayType.Reference)
	    	{
	    		Schema.SObjectType chObj = f.getReferenceTo()[0];
	    		level2ObjectFields = getFieldSelectOptionByObject(chObj);		
	    		showLevel2 = true;
	    		if(level2ObjectValue != null && level2ObjectValue != '' && objTypeFieldDescribeMap.containsKey(String.valueOf(chObj)) && objTypeFieldDescribeMap.get(String.valueOf(chObj)).containsKey(level2ObjectValue))
	    		{	
		    		f = objTypeFieldDescribeMap.get(String.valueOf(chObj)).get(level2ObjectValue).getDescribe();
		    		
		    		if(f.getType() == Schema.DisplayType.Reference)
			    	{
			    		chObj = f.getReferenceTo()[0];
			    		level3ObjectFields = getFieldSelectOptionByObject(chObj);		
			    		showLevel3 = true;
			    	} else
			    	{
		    			showLevel3 = false;
		    			level3ObjectValue = '';
			    	}
	    		}
	    	} else
	    	{
	    		showLevel2 = false;
	    		level2ObjectValue = '';
	    		showLevel3 = false;
	    		level3ObjectFields = null;
	    		level3ObjectValue = '';
	    	}
		}else
    	{
    		showLevel2 = false;
    		level2ObjectValue = '';
    		showLevel3 = false;
    		level3ObjectFields = null;
    		level3ObjectValue = '';
    	}
	}
	
	
	public List<SelectOption> getFieldSelectOptionByObject(Schema.SObjectType tObj)
	{
		List<SelectOption> result = new List<SelectOption>(); 
	//	if(objTypeFieldDescribeMap == null)
			
		Map<String, Schema.SObjectField> fldDescribeMap = new Map<String, Schema.SObjectField>();
		objTypeFieldDescribeMap.put(String.valueOf(tObj), fldDescribeMap);
		
        
		Schema.DescribeSObjectResult R = tObj.getDescribe();
        fldDescribeMap.putAll(R.fields.getMap());
                  
        Schema.DescribeFieldResult f;
		 
		List<String> labels = new List<String>();
		Map<String, SelectOption> labelFieldMap = new Map<String, SelectOption>(); 
        for(String key : fldDescribeMap.keySet())
        {
        	f = fldDescribeMap.get(key).getDescribe();
        	//result.add(new SelectOption(key, f.getLabel()));
        	labels.add(f.getLabel());
        	if(f.getType() == Schema.DisplayType.Reference)
        	{		
        		labelFieldMap.put(f.getLabel(), new SelectOption(key, f.getLabel()+' >'));
        		if(refNameFieldNameMap == null)
        			refNameFieldNameMap = new Map<String, String>();
        		refNameFieldNameMap.put(f.getRelationshipName(), key);
        		if(fieldNameFefNameMap == null)
        			fieldNameFefNameMap = new Map<String, String>();
        		fieldNameFefNameMap.put(key, f.getRelationshipName());
        	} else
        		labelFieldMap.put(f.getLabel(), new SelectOption(key, f.getLabel()));
        		//result.add(new SelectOption(key, f.getLabel()));
        }
        
        //sort fields
        labels.sort();
        for(String lbl : labels)
        {
        	result.add(labelFieldMap.get(lbl));
        }
        
        return result;
	}

}