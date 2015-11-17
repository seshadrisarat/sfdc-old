/**
* \arg ClassName      : SL_Autocomplete
* \arg JIRATicket     : AMSEC-39
* \arg CreatedOn      : 09/APRIL/2015
* \arg LastModifiedOn : 09/APRIL/2015
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : Lodhi
* \arg Description    : Controller class for SL_Autocomplete component.
*/
global class SL_Autocomplete 
{
    static Map<String, Schema.SObjectType> globalDescribe ; 
    static Map<String, Schema.Displaytype> mapFieldApiNameToType;
    static String strRecordTypeId;
    static
    {
        globalDescribe = Schema.getGlobalDescribe();
        mapFieldApiNameToType = new Map<String, Schema.Displaytype>();
        strRecordTypeId = [SELECT Id FROM RecordType  WHERE RecordType.DeveloperName = 'Portfolio_Company' LIMIT 1].Id;
    }
    
    @RemoteAction
    global static SObject[] findSObjects(String objName, String sObjectFieldName, String strSearch)
    {
        strSearch = strSearch.trim();
        Set<String> setSpecialChars = new Set<String>{'*','?',')','('};
        //Validating search string contains two character or not apart from above special character.
        //In SOSL,at least two character must contain by search string.
        string strSearchWithoutSpecialCharacter =  '' ; // 
        for(Integer i=0 ; i<=strSearch.length() -1; i++)
        {
            if(setSpecialChars.contains(strSearch.substring(i,i+1)))
            {
                continue;
            }
            strSearchWithoutSpecialCharacter  += strSearch.substring(i,i+1);
        }
        //There must be 2 character for SOSL    
        if(strSearch != '' && strSearch.length() > 1 && strSearchWithoutSpecialCharacter.length() > 1)
        {
            boolean isSOQL = false; 
            String strSOSL = '';
            String strWhere = '';
            String strSOQLWhereClause = '' ;
            String strSOQLFields = '';
            // check to see if the object passed is valid
            try
            {
                Schema.SObjectType sObjectTypeFetched = globalDescribe.get(objName);
                Schema.DescribeSObjectResult DescribeSObjectResultObj = sObjectTypeFetched.getDescribe();
                Map<String, Schema.SObjectField> objectFields = DescribeSObjectResultObj.fields.getMap();
                for(String fieldApiName  :  objectFields.keySet())
                {
                    mapFieldApiNameToType.put(objectFields.get(fieldApiName).getDescribe().getName(),objectFields.get(fieldApiName).getDescribe().getType());
                }
            }
            catch(Exception ex)
            {
                return null;
            }
            
            
            //Getting fields  from custom setting on which search to be perform.  
            //SL_sObjectName_AutoComplete__c objCustomSetting = SL_sObjectName_AutoComplete__c.getOrgDefaults();
            //String strFields = objCustomSetting.sObjectFieldName__c;
            String strFields = sObjectFieldName;

            //In SOSL ,Like clause does not work with some data types like : 
            //      1)NUMBER
            //      2)PICKLIST
            //      3)DATE
            //      4)PHONE
            //      5)DOUBLE
            //          For above datatypes,we are performing SOQL for getting optimal results.For rest of the data,performing SOSL.
            
            for(String strField : strFields.split(','))
            {
                strField = strField.trim();
                strSOQLFields += strField + ',';
                if(string.valueOf(mapFieldApiNameToType.get(strField)) == 'PICKLIST')
                {   
                    //If datatype of one of the field is picklist then adding like cluase in dynamic soql/
                    strSOQLWhereClause += strSOQLWhereClause.contains('where') ? ' OR '+strField+' like \'%'+strSearch+'%\'' :' where '+strField+' like \'%'+strSearch+'%\''    ;       
                    isSOQL = true;
                }
                else if(string.valueOf(mapFieldApiNameToType.get(strField)) == 'NUMBER' 
                        || string.valueOf(mapFieldApiNameToType.get(strField)) == 'PHONE')
                {
                    //Since Like clause in soql accept only string value If datatype is NUMBER,
                    strSOQLWhereClause += strSOQLWhereClause.contains('where') ? ' OR '+strField+' = \''+strSearch + '\'' :' where '+strField+' = \''+strSearch + '\''  ;
                    isSOQL = true;
                }
                else if(string.valueOf(mapFieldApiNameToType.get(strField)) == 'DOUBLE')
                {
                    //Checking double 
                    string strSearchTemp = strSearch.remove('.');
                    if(strSearchTemp.isNumeric())
                    {
                        strSOQLWhereClause += strSOQLWhereClause.contains('where') ? ' OR '+strField+' = '+strSearch :' where '+strField+' = '+strSearch ;
                        isSOQL = true;
                    }
                }
                else if(string.valueOf(mapFieldApiNameToType.get(strField)) == 'DATE')
                {
                    try
                    {
                        Date dt = Date.valueOf(strSearch);
                        string strDate = string.valueOf(dt).substring(0,10);
                        strSOQLWhereClause += strSOQLWhereClause.contains('where') ? ' OR '+strField+' = '+strDate :' where '+strField+' = '+strDate;
                        isSOQL = true;
                    }
                    catch(Exception ex)
                    {
                        
                    }
                }
                else    
                    strWhere += ' '+ strField + ' like \'%' + String.escapeSingleQuotes(strSearch) + '%\' OR';
                    
            }
            if(strSearch.contains('\''))
                strSearch = strSearch.replaceAll('\'', '\\\\\'');
            //Stripping last ',' character from strSOQLFields
            if(strSOQLFields.contains(','))
            {
                strSOQLFields = strSOQLFields.subString(0,strSOQLFields.lastIndexOf(','));              
            }
            String strQuery  = 'Select '+strSOQLFields+ ' From '+objName + strSOQLWhereClause; 
            System.debug('===========strQuery========'+strQuery);
            if(strWhere.length() >= 2)
                strWhere = strWhere.substring(0, strWhere.length()-2);
            //Dynamic SOSL query string
            strSOSL = 'FIND \'' + string.escapeSingleQuotes(strSearch)  + '*\'' +  ' IN ALL FIELDS '+ 'RETURNING '+ objName +' ';
            if(objName != 'Deal__c' && objName != 'Contact')
                strSOSL += '(ID, '+ string.escapeSingleQuotes(strFields) +' Where ' + strWhere + ' AND RecordTypeId = '+'\'' + strRecordTypeId + '\')';
            else
                strSOSL += '(ID, '+ string.escapeSingleQuotes(strFields) +' Where ' + strWhere +')';
            system.debug('=======strSOSL========'+strSOSL);
            List<SObject> commonResultsList = new List<SObject>();
            List<List<SObject>> lstSobjectNested = new List<List<SObject>>();
            List<sObject> lstSObject = new List<sObject>();
            try
            {
                // Sosl for each text character with min length of 2
                lstSobjectNested = search.query(strSOSL);
                //If there will one of the field in the custom setting field set which has been added for SOQL,then only query will exceuting.
                if(isSOQL)
                    lstSObject = Database.query(strQuery);
            }
            catch (QueryException e)
            {
                return null;
            }
            //iterate the sobject list and get the result
            for(List<Sobject> results : lstSobjectNested)
            {
                if(!results.isEmpty())
                    commonResultsList.addAll(results);
            }
            //Same record may come from both query.
            //To ensure that there should no any duplicacy of record. 
            set<string> setResultsId = new set<string>();
            for(sObject sObj : commonResultsList)
            {   
                setResultsId.add(sObj.id);
            }
            for(sObject s : lstSObject)
            {
                if(!setResultsId.contains(s.id))
                    commonResultsList.add(s);
            }
            return commonResultsList;
        }
        else
            return null;
    }
    /* End - Method */
}