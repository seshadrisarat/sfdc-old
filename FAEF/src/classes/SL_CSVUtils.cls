/**
* \arg ClassName   : SL_CSVUtils
* \arg JIRATicket  : FAEF-13
* \arg CreatedOn   : 7/25/2013  
* \arg ModifiedBy  : Vivek, 12/08/2013 (Commit URL)
* \arg Description : Class is mainly cleaning the converted CSV file and giving a specific structure in term of row and column.
*					 Also, preparing sObject for each CSV record. 
*/

public class SL_CSVUtils
{   
	/**
	* Name: parseCSV
	* Parameters: 1) contents    : Converted string value of CSV file 
				  2) skipHeaders : Expected value
				  					i)  True : Columns name will escaped. Return list wont contain columns name  
				  					ii) False: Columns name wont escaped. Return list will contain columns name  
	* Description : Cleaning converted string of CSV file in term of double quotes character, new line character and preparing row and columns for record in terms of nested list.
	*/
    public static List<List<String>> parseCSV(String contents,Boolean skipHeaders)
    {
        //resultant list. Outer list represnt each row and inner list represents each column for row.
        List<List<String>> allFields = new List<List<String>>(); 
        
        //Replacing double quotes while giving double quotes at first value at first column field
        contents = contents.replaceAll('"""','DBLQT');
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try 
        {
            // Seprating each rows
            lines = contents.split('\n');
        } 
        catch (System.ListException e)
        {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for(String line : lines) 
        {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            
            List<String> fields = line.split(',');           // Getting column value for each row  
            List<String> cleanFields = new List<String>();   // Represent each row	
            String compositeField;                           // string will contain field value which contains " "
            Boolean makeCompositeField = false;
            for(String field : fields) 
            {
                if (field.startsWith('"') && field.endsWith('"')) 
                {
                    cleanFields.add(field.replaceAll('"','').replaceAll('DBLQT','"'));
                } // Start forming composite value which contains double quotes("")  
                else if (field.startsWith('"')) 
                {
                    makeCompositeField = true;
                    compositeField = field.replaceAll('"','');
                } 
                else if (field.endsWith('"')) 
                { 
                    compositeField += ',' + field.replaceAll('"','');
                    cleanFields.add(compositeField.replaceAll('DBLQT','"')); 
                    makeCompositeField = false;
                } // End forming composite value which contains double quotes("")
                else if (makeCompositeField) 
                    compositeField +=  ',' + field; // forming Composite fieid where value is seprate by comma 
                else 
                    cleanFields.add(field.replaceAll('DBLQT','"'));
            }
            allFields.add(cleanFields);
        }
        // Removing columns row
        if (skipHeaders) allFields.remove(0);
        return allFields;       
    }
    
    /**
	* Name: csvTosObject
	* Parameters: 1) parsedCSV    :  List of cleaned CSV records.
				  2) objectType   :  sObject Type
	* Description : Preparing sObject list for all CSV records.
	*/
    public static List<sObject> csvTosObject(List<List<String>> parsedCSV, string objectType)
    {
        List<sObject> objects = new List<sObject>();
        try
        {
        	// Getting all fields defination of objectType by describe call 
	        Map<String, Schema.SObjectField> mapFields = Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap();
	        // Getting definition of objectType which will help us to create new instance dynamically
	        Schema.sObjectType objectDef = Schema.getGlobalDescribe().get(objectType).getDescribe().getSObjectType();
	        List<string> headers = new List<string>();
	        List<List<String>> lstParseCSVRows = new  List<List<String>>();
	        sObject thisObj = objectDef.newSobject();
	        for(List<string> row : parsedCSV)
	        {
	            for(string col : row)
	            {
	                //Getting columns name which is coming in CSV file
	                headers.add(col);
	            }
	            break;
	        }
	        integer rowNumber = 0;
	        // Avoiding first row of the list because at 0 index, It contains columns name
	        for(List<string> row : parsedCSV)
	        {
	            if(rowNumber == 0)
	            {
	                rowNumber++;
	                continue;
	            }
	            else
	            {
	                // Preparing list of data rows
	                lstParseCSVRows.add(row);
	                rowNumber++;
	            }
            }
            // Calling generic method for forming sObject row
            if(rowNumber != 0 && lstParseCSVRows.size() > 0)
				objects = prepareSObjectRows(headers ,  mapFields , objectDef , lstParseCSVRows);        
        }
        catch(Exception e)
        {
        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
      	  	ApexPages.addMessage(myMsg);
        	
        }
        return objects;
    }
    
     /**
	* Name: prepareSObjectRows
	* Parameters: 1) lstSObjectColumns    :  list of all column name specified in CSV file like 'Quantity__c,Name,Unit_Price__c'
				  2) mapFieldDef          :  field definition of sObject
				  3) objectDef			  :  sObject definition; Determine which type of sObject we want to create.
				  4) lstRows              :  sObject data rows
	* Description : Preparing sObject rows where each row represent each CSV record and filling with column value
	*/
    public static List<sObject>  prepareSObjectRows(List<String> lstSObjectColumns , Map<String, Schema.SObjectField> mapFieldDef , Schema.sObjectType objectDef ,List<List<String>> lstRows)
    {
    	
    	List<sObject> objects = new List<sObject>();
    	for(List<string> row : lstRows)
    	{
	    	sObject thisObj  = objectDef.newSobject();
	    	integer colIndex = 0;
	    	for(string col : row)
	        {                   
	            //Gettign column name
	            string headerName = lstSObjectColumns[colIndex].trim();
	            if(headerName.length() > 0)
	            {                  
	                try
	                {
	                    Schema.SObjectField field = mapFieldDef.get(headerName);
	                    Schema.DisplayType fieldType = field.getDescribe().getType();
	                    if(col != null)
	                            col = col.trim();
	                            
	                    if(col != null && col != '')
	                    {
                         	if ((fieldType == Schema.DisplayType.DOUBLE) || (fieldType == Schema.DisplayType.CURRENCY))
                         	{
	                         	// Validating field is double or not else giving custom exception
	                         	if(col.remove('.').isNumeric())	
	                         		thisObj.put(headerName,double.valueOf(col));
	                         	else
	                         		throw new customMessageException('Incorrect value for decimal field');
                         	}
	                        else if (fieldType == Schema.DisplayType.BOOLEAN)
	                        	thisObj.put(headerName,Boolean.valueOf(col));
	                        else if (fieldType == Schema.DisplayType.INTEGER)
	                        	thisObj.put(headerName,Integer.valueOf(col));
	                        else if (fieldType == Schema.DisplayType.Date)
	                    	{
	                        		//Replacing '-' to '/'. Date.Parse() method take string in a specific format which takes '/' 
	                        		if(col.contains('-'))
	                        			thisObj.put(headerName,Date.parse(col.replaceAll('-','/')));
	                        		else
	                        			thisObj.put(headerName,Date.parse(col));
	                    	}
	                	 	else if (fieldType == Schema.DisplayType.Id)
	                	 		thisObj.put(headerName,Id.valueOf(col));
	                	 	else if(fieldType == Schema.DisplayType.DateTime)
	                	 	{
	                        		//Replacing '-' to '/'. DateTime.Parse() method take string in a specific format which takes '/'
	                        		if(col.contains('-'))	
	                        			thisObj.put(headerName,DateTime.parse(col.replaceAll('-','/')));
	                        		else
	                        			thisObj.put(headerName,DateTime.parse(col));
	                	 	}
	                        else  // Checking with field length and populating string with accommodate size
	                        	thisObj.put(headerName,String.valueOf(col).length() > field.getDescribe().getLength() ? String.valueOf(col).substring(0,field.getDescribe().getLength()) :String.valueOf(col));
	                	}
	                }
	                catch(exception e)
	                {
	                   	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, headerName +' : '+  e.getMessage());
	              	  	ApexPages.addMessage(myMsg); 
	                }
	                colIndex++;
	        	}
	        } 
	        objects.add(thisObj);
    	} 
    	return objects;      
    }
    // Custom exception
    public class customMessageException extends Exception{}
    
}