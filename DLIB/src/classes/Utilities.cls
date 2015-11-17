public with sharing class Utilities {
	
	// TODO: should be moved to configuration
    final static String NS = 'SLSI__';
    final static Integer NSLENGH = 6;
	
	static public String getClassName(Object obj)
	{
		String myStr = String.valueOf(obj);
		String className = myStr.split(':')[0];
				
		return className;
	}
	
	static public String removeNewLines(String s) {
		return s.replaceAll('\r', '') . replace('\n', '');
	}
	
	static public String removeNameSpace(String s) {
		return (!String.isEmpty(s) && s.toUpperCase().startsWith(NS)) ? s.substring(NSLENGH) : s;
	}
	
	// Collection helpers
	
	static public String extractJoinedIDs(Set<SObject> s, String separator) {
		String res = '';		
		for(SObject o : s) res += o.Id + separator;		
		return res;
	}
	
	static public String extractJoinedIDs(Set<Id> s, String separator) {
		String res = '';		
		for(Id id : s) res += id + separator;	
		return res;
	}
	
	static public String extractJoinedIDs(List<SObject> s, String separator) {
		return extractJoinedIDs(new Set<SObject>(s), separator);
	}
	
	
	static public Schema.DescribeSObjectResult sObjectDesribeHelper(String sObjectName) {
		
		if(String.isEmpty(sObjectName)) {
			throw new SL_CustomException('Empty SObject name for inspection');
		}
		
		Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
		String s = sObjectName.toLowerCase();
		
		if(String.isBlank(s) || !globalDescribeMap.containsKey(s) ) {
 			throw new SL_CustomException('SObject "' + s + '" does not exist.');
 		} 	
		
		return globalDescribeMap.get(s).getDescribe();
	}
	
		
	/**
	* Overloaded (for compatibility)
	**/	
	static public SL_UtilityWrappers.FieldSetResults buildQueryUsingFieldSet( 
			String strSobjectName, String strFieldSetName, String strFilterCriteria, 
			String strOrderClause, String strLimit, Set<String> setApiNamesNeedNotToInclude 
	) {
		return buildQueryUsingFieldSet(strSobjectName, strFieldSetName, strFilterCriteria, 
			strOrderClause, strLimit, setApiNamesNeedNotToInclude, null, null);
	}
	
	static public SL_UtilityWrappers.FieldSetResults buildQueryUsingFieldSet( 
			String strSobjectName, String strFieldSetName, String strFilterCriteria, 
			String strOrderClause, String strLimit, Set<String> setApiNamesNeedNotToInclude, 
			Set<String> setApiNamesNeedToBeIncluded) {
		return buildQueryUsingFieldSet(strSobjectName, strFieldSetName, strFilterCriteria, 
			strOrderClause, strLimit, setApiNamesNeedNotToInclude, setApiNamesNeedToBeIncluded, null);		
	}
	
	/**
	* Method to fetch the fieldset and 
	* - Form a list of fields selected in fieldset to be displayed on the widget
	* - Form a query to fetch records to be displayed on the widget
	* Params: 
	* - setApiNamesNeedToBeIncluded - Fields that have to be in the query, i.e offices or departments visibility fields 
	* - scope - SQL scope part
	**/	
	static public SL_UtilityWrappers.FieldSetResults buildQueryUsingFieldSet( 
			String strSobjectName, String strFieldSetName, String strFilterCriteria, 
			String strOrderClause, String strLimit, Set<String> setApiNamesNeedNotToInclude, 
			Set<String> setApiNamesNeedToBeIncluded, String scope) {
		
		String strQuery;
		List<SL_UtilityWrappers.FieldSetDescribe> lstFieldWrapper = new List<SL_UtilityWrappers.FieldSetDescribe>();
		
		// map to define different Name fields
		Map<String, String> mapObjectNameFields = new Map<String, String> { 
			'case' => 'CaseNumber',
			'solution' => 'SolutionName',
			'contract' => 'ContractNumber',
			'contentdocument' => 'Title',
			'contentversion' => 'Title'
		};		
		
		
		Schema.DescribeSObjectResult objDescribeSObjectResult = sObjectDesribeHelper(strSobjectName);
		
		String apiFieldSetName = strFieldSetName.toLowerCase();
            
		// Check whether the fieldset name provided is correct
		if(String.isBlank(apiFieldSetName) || !objDescribeSObjectResult.FieldSets.getMap().containsKey(apiFieldSetName))
		{
	    	// throw an error if the field set is not available.
	    	throw new SL_CustomException('Please select correct fieldset: ' + strFieldSetName);
	    }
		
	
    	strQuery = 'SELECT Id';
    	String strNameField = '';
    	Set<String> setFieldsInFieldset = new Set<String>();
		    				    	
		Schema.FieldSet objFieldSet = objDescribeSObjectResult.FieldSets.getMap().get(apiFieldSetName); // Get fieldsets for given Object		
		    	
		for(Schema.FieldSetMember objFM : objFieldSet.getFields())
		{		
			/* 
			 * objFM.getFieldPath() should be used aganst setApiNamesNeedNotToInclude collection
			 * as it returns capitalyzed values with namespaces.
			*/ 
			if( setApiNamesNeedNotToInclude.isEmpty() || !setApiNamesNeedNotToInclude.contains(objFM.getFieldPath()) )
		    {
		    	/* 
				 * objDescribeSObjectResult.fields.getMap() returns lowercase values without namespace for local. 
				 * This probably will be fixed soon. Please refer to https://silverline.jira.com/browse/SOCINT-790
				 * so we check for with namespace and for local (without)  
				*/		    	
		    	// includes namespace
				String apiFieldPath = objFM.getFieldPath().toLowerCase();				
				Boolean hasField = 	objDescribeSObjectResult.fields.getMap().containsKey(apiFieldPath);
				
				// attempt to find local
				if(!hasField) {
					apiFieldPath = removeNameSpace(apiFieldPath);
					hasField = objDescribeSObjectResult.fields.getMap().containsKey(apiFieldPath);	 
				}
		    			
		    	if(hasField)
			    {		
			    	Schema.DescribeFieldResult fieldResult = objDescribeSObjectResult.fields.getMap().get(apiFieldPath).getDescribe();
			    	Boolean isFilter = fieldResult.isFilterable();
			    		     			
		    		// If field type is Reference - define the relationship to query Name fields
		    		if(String.valueOf(objFM.getType()) == 'REFERENCE')		
		    		{				    		
		    			List <Schema.sObjectType> lstParentObjects = fieldResult.getReferenceTo();
		    			
		    			String strReferenceTo = lstParentObjects[0].getDescribe().getName().toLowerCase();
		    			
		    			if(String.isNotBlank(fieldResult.getRelationshipName()))
		    			{
			    			String strFieldAPIName = fieldResult.getRelationshipName() + 
								(mapObjectNameFields.containsKey(strReferenceTo) ? ('.' + mapObjectNameFields.get(strReferenceTo)) : '.Name');
			    				
				    		lstFieldWrapper.add(new SL_UtilityWrappers.FieldSetDescribe(strFieldAPIName, objFM.getLabel(), String.valueOf(objFM.getType()), isFilter));
				    		
			    			strQuery += ', ' + objFM.getFieldPath() + ', ' + String.escapeSingleQuotes(strFieldAPIName);
		    			}
		    		}
			    		
		    		// If field type is not of type Id - simply add them to list and query
		    		else if(String.valueOf(objFM.getType()) != 'ID')
		    		{	
		    			lstFieldWrapper.add(new SL_UtilityWrappers.FieldSetDescribe(objFM.getFieldPath(), objFM.getLabel(), String.valueOf(objFM.getType()), isFilter));
			    		strQuery += ', ' + objFM.getFieldPath();
			    		
			    		setFieldsInFieldset.add(objFM.getFieldPath());
		    		}
			    		
		    		// If Id is selected in fieldset - add Name field to list 
		    		else
		    		{	
		    			strNameField = mapObjectNameFields.containsKey(strSobjectName) ? mapObjectNameFields.get(strSobjectName) : 'Name';
		    			lstFieldWrapper.add(new SL_UtilityWrappers.FieldSetDescribe(strNameField, objFM.getLabel(), String.valueOf(objFM.getType()), isFilter));
		    				
		    			setFieldsInFieldset.add(objFM.getFieldPath());
		    		}
			    }	
			    	
 				
    			
    			
		    }	
		 }		 
		 		
		 		// check passed along additional fields for existance in field set 
		    	if(setApiNamesNeedToBeIncluded != null && !setApiNamesNeedToBeIncluded.isEmpty()) {
    				for(String aField : setApiNamesNeedToBeIncluded) {
    					if(setFieldsInFieldset.contains(aField)) continue;
    					
    					if(!objDescribeSObjectResult.fields.getMap().containsKey(aField.toLowerCase())) {
					    	throw new SL_CustomException('Please select correct field: ' + aField);
					    }
    					
    					strQuery += ', ' + String.escapeSingleQuotes(aField);
    				}
    			}
		 
		    	
		    	// If fieldset contains Id field then add Name to query string 
		    	if((setFieldsInFieldset.contains('Id') && !String.isBlank(strNameField) && !setFieldsInFieldset.contains(strNameField)))
		    		strQuery += ', ' + String.escapeSingleQuotes(strNameField);
		    	
		    	 strQuery += ' FROM ' + String.escapeSingleQuotes(strSobjectName) + 
		    	 			(!String.isEmpty(scope) ? ' USING SCOPE ' + scope : '') + 
							((strFilterCriteria != null && strFilterCriteria != '') ? ' WHERE ' + strFilterCriteria : '');
							if(String.isBlank(strFilterCriteria) || (String.isNotBlank(strFilterCriteria) && !strFilterCriteria.toLowerCase().contains('order by')))
							strQuery += ' ' + String.escapeSingleQuotes(strOrderClause);
							if(String.isBlank(strFilterCriteria) || (String.isNotBlank(strFilterCriteria) && !strFilterCriteria.toLowerCase().contains('limit')))
							strQuery += ' ' + String.escapeSingleQuotes(strLimit);

				system.debug('------strQuery---'+strQuery);
		   
 		

 		// return the fieldset describe result
		SL_UtilityWrappers.FieldSetResults objUtilitiesFieldWrapper = new SL_UtilityWrappers.FieldSetResults(strQuery, lstFieldWrapper);
		return objUtilitiesFieldWrapper;
	}
	
	public static List<SL_UtilityWrappers.FieldSetDescribe> describeDefaultFields( String strSobjectName, List<String> setDefaultFields)
	{
		Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); // describe schema
		List<SL_UtilityWrappers.FieldSetDescribe> lstFieldWrapper = new List<SL_UtilityWrappers.FieldSetDescribe>();
		Map<String, String> mapObjectNameFields = new Map<String, String> { 
				'case' => 'CaseNumber',
				'solution' => 'SolutionName',
				'contract' => 'ContractNumber'
		};	// map to define different Name fields
		 
		String apiSobjectName = strSobjectName.toLowerCase();
																			
		// Check whether the object name provided is correct
 		if(String.isBlank(apiSobjectName) || !GlobalDescribeMap.containsKey(apiSobjectName)) 		
 		{
 			// throw an error if configration not contains Sobject name
 			throw new SL_CustomException('SObject "' + apiSobjectName + '" does not exist.');
 		}
 		 		
		// describe sobject
		Schema.DescribeSObjectResult objDescribeSObjectResult = GlobalDescribeMap.get(apiSobjectName).getDescribe();	
		Map<String, Schema.SObjectField> mapSObjectFields = Schema.getGlobalDescribe().get(apiSobjectName).getDescribe().fields.getMap();
			
		for(String strField : setDefaultFields)
		{				
			// includes namespace
			String apiFieldPath = strField.toLowerCase();	
			Boolean hasField = mapSObjectFields.containsKey(apiFieldPath);
				
			// attempt to find local
			if(!hasField) {
				apiFieldPath = removeNameSpace(apiFieldPath);
				hasField = mapSObjectFields.containsKey(apiFieldPath);	 
			}
			
			if(hasField) {
						
				Schema.DescribeFieldResult FieldDescribe = mapSObjectFields.get(apiFieldPath).getDescribe();
				
				// If field type is Reference - define the relationship to query Name fields
	    		if(String.valueOf(FieldDescribe.getType()) == 'REFERENCE')		
	    		{
	    			List <Schema.sObjectType> lstParentObjects = FieldDescribe.getReferenceTo();
	    			String strReferenceTo = lstParentObjects[0].getDescribe().getName().toLowerCase();
	    			
	    			String strFieldAPIName = FieldDescribe.getRelationshipName() + 
	    										((mapObjectNameFields.containsKey(strReferenceTo)) ? ('.' + mapObjectNameFields.get(strReferenceTo)) : '.Name');
	    				
		    		lstFieldWrapper.add(new SL_UtilityWrappers.FieldSetDescribe(FieldDescribe.getName(), FieldDescribe.getLabel(), String.valueOf(FieldDescribe.getType())));
	    		}
	    		
	    		// If field type is not of type Id - simply add them to list and query
	    		else if(String.valueOf(FieldDescribe.getType()) != 'ID')
	    		{
	    			lstFieldWrapper.add(new SL_UtilityWrappers.FieldSetDescribe(FieldDescribe.getName(), FieldDescribe.getLabel(), String.valueOf(FieldDescribe.getType())));
	    		}
	    		
	    		// If Id is selected in fieldset - add Name field to list 
	    		else
	    		{
	    			String strNameField = (mapObjectNameFields.containsKey(strSobjectName) ? mapObjectNameFields.get(strSobjectName) : 'Name');
	    			lstFieldWrapper.add(new SL_UtilityWrappers.FieldSetDescribe(strNameField, FieldDescribe.getLabel(), String.valueOf(FieldDescribe.getType())));
	    		}
			}
		}
 		
 		return lstFieldWrapper;
	}
	
	public static Boolean getObjectAccess(String accessType, Schema.SObjectType sobjType) {
		if(accessType == 'read')
			return sobjType.getDescribe().isAccessible();
		else if(accessType == 'edit')
			return sobjType.getDescribe().isUpdateable();
		else if(accessType == 'delete')
			return sobjType.getDescribe().isDeletable();
		else if(accessType == 'create')
			return sobjType.getDescribe().isCreateable();
		return null;
	}
}