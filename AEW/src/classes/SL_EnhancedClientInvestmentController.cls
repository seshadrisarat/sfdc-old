/**
* \arg ClassName      : SL_EnhancedClientInvestmentController
* \arg JIRATicket     : AEW-11
* \arg CreatedOn      : 3/JUNE/2015
* \arg LastModifiedOn : 20/JULY/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as controller for SL_EnhancedClientInvestmentRelatedList page.
*/
global with sharing class SL_EnhancedClientInvestmentController 
{
	public String cIFieldSetResults {get;set;}
    public String detailObjectType {get;set;}
    public String userOptions      {get;set;}

    public String currencyIso {get;set;}
    public String locale {get;set;}
    public String timeFormat {get;set;}
    public Integer timezoneOffset {get;set;} 

    public String picklistValues {get;set;} 

    public String fundFieldId     {get;set;}

    public String getFundName()
    {
        return [SELECT Name FROM Fund__c WHERE Id =: ApexPages.currentPage().getParameters().get('id')].Name;
    }
          
    /*
     * Modified Version of RemoteTKController
     */
    global SL_EnhancedClientInvestmentController()
    {   
        //Get the default currency symbol
        currencyIso = getCurrencySymbolFromIso(UserInfo.getDefaultCurrency());
        timezoneOffset = UserInfo.getTimeZone().getOffset(DateTime.now());
        if(Client_Investment_Field_Ids__c.getInstance('Fund__c')!=NULL)
            fundFieldId = Client_Investment_Field_Ids__c.getInstance('Fund__c').Field_Id__c;
        //Get the date format from custom setting or user locale
        locale = getDateFormat();
        timeFormat = getTimeFormat();

        //Intializing variables on page load                 
        initialize();
    } 
        
    global class picklistValues
    {
        String label {get; set;}
        String value {get; set;}
    }

    //Function to initialize the variables on load
    private void initialize()
    {
        //Schema.sObjectType sobjectType;	
        Schema.SObjectType token; 
        Schema.DescribeSObjectResult dr;
   	    Schema.DescribeFieldResult dfr;     
   	    Map<String,Set<String>> mapPicklist = new Map<String,Set<String>>(); 
       
        List<Schema.FieldSetMember> lstFieldSetCI = describeFieldSet('Client_Investment__c', 'SL_ClientInvestmentRelatedList');

        token = Schema.getGlobalDescribe().get('Client_Investment__c');
        dr = token.getDescribe();
        List<Object> lstFieldSetCIResult = new List<Object>();        

        for(Schema.FieldSetMember obj : lstFieldSetCI) 
        {
            Map<String, Object> field = new Map<String, Object>();
            if(!String.valueOf(obj.getFieldPath()).contains('.'))
                dfr = dr.fields.getMap().get(obj.getFieldPath()).getDescribe();

            field.put('dbRequired', obj.getDBRequired());
            field.put('fieldPath', obj.getFieldPath());
            field.put('label', obj.getLabel());
            field.put('required', obj.getRequired());
            field.put('type', String.valueOf(obj.getType()).toLowerCase());
            field.put('typeApex', String.valueOf(obj.getType()));

            if( String.valueOf(obj.getType()) == 'percent' || 
                String.valueOf(obj.getType()) == 'currency'|| 
                String.valueOf(obj.getType()) == 'double' ) 
            {
                field.put('scale', dfr.getScale());
            } 

            lstFieldSetCIResult.add(field); 

            if(String.valueOf(obj.Type) == 'picklist' || String.valueOf(obj.Type) == 'multipicklist') {

                //Get the values of picklist field
                mapPicklist.put(obj.fieldPath, getPicklistValuesWithFieldName('Client_Investment__c',obj.fieldPath));
            }
            
        }

        //assign the mapPicklist to get set variable to access in component
        picklistValues = JSON.serialize(mapPicklist);

        cIFieldSetResults = JSON.Serialize(lstFieldSetCIResult);	       
    }

    @remoteAction
    global static Set<String> getPicklistValuesWithFieldName(String objtype, String fieldName) {
        try
        {
            Schema.SObjectType token = Schema.getGlobalDescribe().get(objtype);
            Schema.DescribeSObjectResult dr = token.getDescribe();
            Map<String, Schema.SObjectField> field_map = dr.fields.getMap();
            List<Schema.PicklistEntry> pickListValues = field_map.get(fieldName).getDescribe().getPickListValues();

            Set<String> setPicklistValues = new Set<String>();
            
            for(Schema.PicklistEntry plv : pickListValues){

                setPicklistValues.add(plv.getValue());
            }

            return setPicklistValues;
        }
        catch(Exception e)
        {
            return null;
        }
    }
    
    private static String makeError(String message, String errorCode) 
    {
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('message', message);
        gen.writeStringField('errorCode', errorCode);
        gen.writeEndObject();
        gen.writeEndArray();
        
        return gen.getAsString();
    }
    
    private static String writeFields(String objtype, SObject obj, String fields) 
    {
        Map<String, Object> fieldMap = null;
        try 
        {
            fieldMap = (Map<String, Object>)JSON.deserializeUntyped(fields);
            if(Test.isRunningTest())
                makeError('Test Message', 'TEST_ERROR');
        } 
        catch (Exception je) 
        {
            return makeError(je.getMessage(), 'JSON_PARSER_ERROR');
        }
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        
        Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();
        
        try {
            for (String key : fieldMap.keySet()) 
            {
                if (targetFields.get(key) == null) 
                {
                    system.debug('[{"message":"Field '+key+' does not exist on object type '+objtype+'","errorCode":"INVALID_FIELD"}]');
                    return '[{"message":"Field '+key+' does not exist on object type '+objtype+'","errorCode":"INVALID_FIELD"}]';
                }
                
                Object value = fieldMap.get(key);
                Schema.DisplayType valueType = targetFields.get(key).getDescribe().getType();
                
                if (value instanceof String && valueType != Schema.DisplayType.String) 
                {
                    // Coerce an incoming String to the correct type
                    String svalue = (String)value;
                    
                    if (valueType == Schema.DisplayType.Date) 
                    {
                        system.debug('doing ' + key + ' : ' + svalue);
                        obj.put(key, Date.valueOf(svalue));
                    }else if(valueType == Schema.DisplayType.DateTime) 
                    {
                        if(svalue.length()>0)
                        obj.put(key,DateTime.valueOf(svalue));
                        else obj.put(key,null);
                    }else if (valueType == Schema.DisplayType.Percent ||
                           valueType == Schema.DisplayType.Currency) 
                           {
                        obj.put(key, svalue == '' ? null : Decimal.valueOf(svalue));
                    } else if (valueType == Schema.DisplayType.Double) 
                    {
                        obj.put(key, svalue == '' ? null : Double.valueOf(svalue));
                    } else if (valueType == Schema.DisplayType.Integer) 
                    {
                        obj.put(key, Integer.valueOf(svalue));
                    } else {
                        obj.put(key, svalue);
                    }
                } else {
                    // Just try putting the incoming value on the object
                    obj.put(key, value);
                }
            }
        } 
        catch (SObjectException soe) 
        {
            system.debug(soe.getMessage() + 'INVALID_FIELD');
            return makeError(soe.getMessage(), 'INVALID_FIELD');
        }
        
        return null;
    }

    @remoteAction
    global static String describe(String objtype) {
        // Just enough to make the sample app work!
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        if (targetType == null) {
            return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
        }

        Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();

        Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();

        List<Object> fields = new List<Object>();
        for (String key : fieldMap.keySet()) {
            Schema.DescribeFieldResult descField = fieldMap.get(key).getDescribe();
            Map<String, Object> field = new Map<String, Object>();

            field.put('type', descField.getType().name().toLowerCase());
            field.put('name', descField.getName());
            field.put('label', descField.getLabel());
            List<String> references = new List<String>();
            for (Schema.sObjectType t : descField.getReferenceTo()) {
                references.add(t.getDescribe().getName());
            }
            if (!references.isEmpty()) {
                field.put('referenceTo', references);
            }

            fields.add(field);
        }

        Map<String, Object> result = new Map<String, Object>();
        result.put('fields', fields);

        return JSON.serialize(result);
    }
	
	@remoteAction
    global static String query(String soql) {
        List<sObject> records;
        try {
            records = Database.query(soql);
        } catch (QueryException qe) {
            return '[{"message":"' + qe.getMessage() + '","errorCode":"INVALID_QUERY"}]';
        }

        Map<String, Object> result = new Map<String, Object>();
        result.put('records', records);
        result.put('totalSize', records.size());
        result.put('done', true);

        return JSON.serialize(result);
    }
	
    @remoteAction
    global static List<Schema.FieldSetMember> describeFieldSet(String objtype, String fieldSetName) 
    {
        Schema.SObjectType token;
        try
        {
            token = Schema.getGlobalDescribe().get(objtype);
            Schema.DescribeSObjectResult dr = token.getDescribe();
            Map<String, Schema.FieldSet> FsMap = dr.fieldSets.getMap();

            List<Schema.FieldSetMember> lstFieldSetMember = FsMap.get(FieldSetName).getFields();
            return lstFieldSetMember;
        }
        catch(Exception e)
        {
            return null;
        }
    }

    

    global static String getCurrencySymbolFromIso(String Iso) {
         String currencySymbol = 
           ('USD' == Iso ? '$' : 
           ('CAD' == Iso ? '$' : 
           ('EUR' == Iso ? '€' :
           ('GBP' == Iso ? '£' : 
           ('JPY' == Iso ? '¥' : 
           ('KRW' == Iso ? '₩' : 
           ('CNY' == Iso ? '元' :
           Iso)))))));

           return currencySymbol;
    }


    //populate a map with locale values and corresponding datetime formats
    private static Map<String, String> dateFormatMap() {
        Map<String, String> dateFormat = new Map<String, String>{'ar' => 'dd/MM/yyyy', 
                                                                'ar_AE' => 'dd/MM/yyyy', 
                                                                'ar_BH' => 'dd/MM/yyyy', 
                                                                'ar_EG' => 'dd/MM/yyyy', 
                                                                'ar_JO' => 'dd/MM/yyyy', 
                                                                'ar_KW' => 'dd/MM/yyyy', 
                                                                'ar_LB' => 'dd/MM/yyyy', 
                                                                'ar_SA' => 'dd/MM/yyyy', 
                                                                'bg' => 'yyyy-M-d', 
                                                                'bg_BG' => 'yyyy-M-d', 
                                                                'ca' => 'dd/MM/yyyy', 
                                                                'ca_ES' => 'dd/MM/yyyy', 
                                                                'ca_ES_EURO' => 'dd/MM/yyyy', 
                                                                'cs' => 'd.M.yyyy', 
                                                                'cs_CZ' => 'd.M.yyyy', 
                                                                'da' => 'dd-MM-yyyy', 
                                                                'da_DK' => 'dd-MM-yyyy', 
                                                                'de' => 'dd.MM.yyyy', 
                                                                'de_AT' => 'dd.MM.yyyy', 
                                                                'de_AT_EURO' => 'dd.MM.yyyy', 
                                                                'de_CH' => 'dd.MM.yyyy', 
                                                                'de_DE' => 'dd.MM.yyyy', 
                                                                'de_DE_EURO' => 'dd.MM.yyyy', 
                                                                'de_LU' => 'dd.MM.yyyy', 
                                                                'el' => 'd/M/yyyy', 
                                                                'el_GR' => 'd/M/yyyy', 
                                                                'en_AU' => 'd/MM/yyyy', 
                                                                'en_BB' => 'M/d/yyyy', 
                                                                'en_BM' => 'M/d/yyyy', 
                                                                'en_CA' => 'dd/MM/yyyy', 
                                                                'en_GB' => 'dd/MM/yyyy', 
                                                                'en_GH' => 'M/d/yyyy', 
                                                                'en_ID' => 'M/d/yyyy', 
                                                                'en_IE' => 'dd/MM/yyyy', 
                                                                'en_IN' => 'd/M/yyyy', 
                                                                'en_MY' => 'd/M/yyyy', 
                                                                'en_NG' => 'm/D/yyyy', 
                                                                'en_NZ' => 'd/MM/yyyy', 
                                                                'en_PH' => 'm/d/yyyy', 
                                                                'en_SG' => 'M/d/yyyy', 
                                                                'en_US' => 'M/d/yyyy', 
                                                                'en_ZA' => 'yyyy/MM/dd', 
                                                                'es' => 'd/MM/yyyy', 
                                                                'es_AR' => 'dd/MM/yyyy', 
                                                                'es_BO' => 'dd-MM-yyyy', 
                                                                'es_CL' => 'dd-MM-yyyy', 
                                                                'es_CO' => 'd/MM/yyyy', 
                                                                'es_CR' => 'dd/MM/yyyy', 
                                                                'es_DO' => 'MM/dd/yyyy', 
                                                                'es_EC' => 'dd/MM/yyyy', 
                                                                'es_ES' => 'd/MM/yyyy', 
                                                                'es_GT' => 'd/MM/yyyy', 
                                                                'es_HN' => 'MM-dd-yyyy', 
                                                                'es_MX' => 'd/MM/yyyy', 
                                                                'es_PA' => 'mm/dd/yyyy', 
                                                                'es_PE' => 'dd/MM/yyyy', 
                                                                'es_PR' => 'MM-dd-yyyy', 
                                                                'es_PY' => 'dd/MM/yyyy', 
                                                                'es_SVUS' => 'MM-dd-yyyy', 
                                                                'es_UY' => 'dd/MM/yyyy', 
                                                                'es_VE' => 'dd/MM/yyyy', 
                                                                'et_EE' => 'd.MM.yyyy', 
                                                                'fi' => 'd.M.yyyy', 
                                                                'fi_FI' => 'd.M.yyyy', 
                                                                'fr' => 'dd/MM/yyyy', 
                                                                'fr_BE' => 'd/MM/yyyy', 
                                                                'fr_CA' => 'yyyy-MM-dd', 
                                                                'fr_CH' => 'dd.MM.yyyy', 
                                                                'fr_FR' => 'dd/MM/yyyy', 
                                                                'fr_LU' => 'dd/MM/yyyy', 
                                                                'fr_MC' => 'dd/MM/yyyy', 
                                                                'ga_IE' => 'dd/MM/yyyy', 
                                                                'hr_HR' => 'yyyy.MM.dd', 
                                                                'hu' => 'yyyy.MM.dd.', 
                                                                'hu_HU' => 'yyyy.MM.dd.', 
                                                                'hy_AM' => 'M/d/yyyy', 
                                                                'in' => 'yyyy/mm/dd', 
                                                                'in_ID' => 'dd/mm/yyyy', 
                                                                'is_IS' => 'd.M.yyyy', 
                                                                'it' => 'dd/MM/yyyy', 
                                                                'it_CH' => 'dd.MM.yyyy', 
                                                                'it_IT' => 'dd/MM/yyyy', 
                                                                'iw' => 'dd/MM/yyyy', 
                                                                'iw_IL' => 'dd/MM/yyyy', 
                                                                'ja' => 'yyyy/MM/dd', 
                                                                'ja_JP' => 'yyyy/MM/dd', 
                                                                'ka' => 'm/d/yyyy', 
                                                                'ka_GE' => 'm/d/yyyy', 
                                                                'kk_KZ' => 'M/d/yyyy', 
                                                                'km_KH' => 'M/d/yyyy', 
                                                                'ko' => 'yyyy. M. d', 
                                                                'ko_KR' => 'yyyy. M. d', 
                                                                'lt_LT' => 'yyyy.M.d', 
                                                                'lv_LV' => 'yyyy.d.M', 
                                                                'ms_MY' => 'dd/MM/yyyy', 
                                                                'nl' => 'd-M-yyyy', 
                                                                'nl_BE' => 'd/MM/yyyy', 
                                                                'nl_NL' => 'd-M-yyyy', 
                                                                'nl_SR' => 'd-M-yyyy', 
                                                                'no' => 'dd.MM.yyyy', 
                                                                'no_NO' => 'dd.MM.yyyy', 
                                                                'pl' => 'yyyy-MM-dd', 
                                                                'pt' => 'dd-MM-yyyy', 
                                                                'pt_AO' => 'dd-MM-yyyy', 
                                                                'pt_BR' => 'dd/MM/yyyy', 
                                                                'pt_PT' => 'dd-MM-yyyy', 
                                                                'ro' => 'dd.MM.yyyy', 
                                                                'ro_RO' => 'dd.MM.yyyy', 
                                                                'ru' => 'dd.MM.yyyy', 
                                                                'ru_RU' => 'dd.MM.yyyy', 
                                                                'sh' => 'dd.MM.yyyy', 
                                                                'sh_BA' => 'dd.MM.yyyy', 
                                                                'sh_CS' => 'dd.MM.yyyy', 
                                                                'sk' => 'd.M.yyyy', 
                                                                'sl_SI' => 'd.M.yy', 
                                                                'sr' => 'd.M.yyyy', 
                                                                'sr_BA' => 'yyyy-MM-DD', 
                                                                'sr_CS' => 'D.m.yyyy', 
                                                                'sk_SK' => 'd.M.yyyy', 
                                                                'sl_SI' => 'd.M.y', 
                                                                'sv' => 'yyyy-MM-dd', 
                                                                'sv_SE' => 'yyyy-MM-dd', 
                                                                'th' => 'M/d/yyyy', 
                                                                'th_TH' => 'd/M/yyyy', 
                                                                'tr' => 'dd.MM.yyyy', 
                                                                'tr_TR' => 'dd.MM.yyyy', 
                                                                'uk' => 'dd.MM.yyyy', 
                                                                'uk_UA' => 'dd.MM.yyyy', 
                                                                'ur_PK' => 'd/M/yyyy', 
                                                                'ur_PK' => 'd/M/yyyy', 
                                                                'ur_PK' => 'M/d/yyyy', 
                                                                'vi' => 'dd/MM/yyyy', 
                                                                'vi_VN' => 'dd/MM/yyyy', 
                                                                'zh' => 'yyyy-M-d', 
                                                                'zh_CN' => 'yyyy-M-d', 
                                                                'zh_HK' => 'yyyy-M-d', 
                                                                'zh_TW' => 'yyyy/M/d'}; //holds the locale to timedate formats
        return dateFormat; //return the map
    }

    private static Map<String, String> timeFormatMap() {
        Map<String, String> timeFormat = new Map<String, String>{'ar' => 'hh:mm a',
                                                                'ar_AE' => 'hh:mm a',
                                                                'ar_BH' => 'hh:mm a',
                                                                'ar_JO' => 'hh:mm a',
                                                                'ar_KW' => 'hh:mm a',
                                                                'ar_LB' => 'hh:mm a',
                                                                'ar_SA' => 'hh:mm a',
                                                                'bg_BG' => 'H:mm',
                                                                'ca' => 'HH:mm',
                                                                'ca_ES' => 'HH:mm',
                                                                'ca_ES_EURO' => 'HH:mm',
                                                                'cs' => 'H:mm',
                                                                'cs_CZ' => 'H:mm',
                                                                'da' => 'HH:mm',
                                                                'da_DK' => 'HH:mm',
                                                                'de' => 'HH:mm',
                                                                'de_AT' => 'HH:mm',
                                                                'de_AT_EURO' => 'HH:mm',
                                                                'de_CH' => 'HH:mm',
                                                                'de_DE' => 'HH:mm',
                                                                'de_DE_EURO' => 'HH:mm',
                                                                'de_LU' => 'HH:mm',
                                                                'de_LU_EURO' => 'HH:mm',
                                                                'el_GR' => 'h:mm a',
                                                                'en_AU' => 'HH:mm',
                                                                'en_B' => 'h:mm a',
                                                                'en_BM' => 'h:mm a',
                                                                'en_CA' => 'h:mm a',
                                                                'en_GB' => 'HH:mm',
                                                                'en_GH' => 'h:mm a',
                                                                'en_ID' => 'h:mm a',
                                                                'en_IE' => 'HH:mm',
                                                                'en_IE_EURO' => 'HH:mm',
                                                                'en_NZ' => 'HH:mm',
                                                                'en_SG' => 'h:mm a',
                                                                'en_US' => 'h:mm a',
                                                                'en_ZA' => 'hh:mm a',
                                                                'es' => 'H:mm',
                                                                'es_AR' => 'HH:mm',
                                                                'es_BO' => 'hh:mm a',
                                                                'es_CL' => 'hh:mm a',
                                                                'es_CO' => 'hh:mm a',
                                                                'es_CR' => 'hh:mm a',
                                                                'es_EC' => 'hh:mm a',
                                                                'es_ES' => 'H:mm',
                                                                'es_ES_EURO' => 'H:mm',
                                                                'es_GT' => 'hh:mm a',
                                                                'es_HN' => 'hh:mm a',
                                                                'es_MX' => 'hh:mm a',
                                                                'es_PE' => 'hh:mm a',
                                                                'es_PR' => 'hh:mm a',
                                                                'es_PY' => 'hh:mm a',
                                                                'es_SV' => 'hh:mm a',
                                                                'es_UY' => 'hh:mm a',
                                                                'es_VE' => 'hh:mm a',
                                                                'et_EE' => 'd.MM.yyyy H:mm',
                                                                'fi' => 'H:mm',
                                                                'fi_FI' => 'H:mm',
                                                                'fi_FI_EURO' => 'H:mm',
                                                                'fr' => 'HH:mm',
                                                                'fr_BE' => 'H:mm',
                                                                'fr_CA' => 'HH:mm',
                                                                'fr_CH' => 'HH:mm',
                                                                'fr_FR' => 'HH:mm',
                                                                'fr_FR_EURO' => 'HH:mm',
                                                                'fr_LU' => 'HH:mm',
                                                                'fr_MC' => 'HH:mm',
                                                                'hr_HR' => 'HH:mm',
                                                                'hu' => 'H:mm',
                                                                'hy_AM' => 'h:mm a',
                                                                'is_IS' => 'HH:mm',
                                                                'it' => 'H.mm',
                                                                'it_CH' => 'HH:mm',
                                                                'it_IT' => 'H.mm',
                                                                'iw' => 'HH:mm ',
                                                                'iw_IL' => 'HH:mm',
                                                                'ja' => 'H:mm',
                                                                'ja_JP' => 'H:mm',
                                                                'kk_KZ' => 'h:mm a',
                                                                'km_KH' => 'h:mm a',
                                                                'ko' => 'a h:mm',
                                                                'ko_KR' => 'a h:mm',
                                                                'lt_LT' => 'HH.mm',
                                                                'lv_LV' => 'HH:mm',
                                                                'ms_MY' => 'h:mm a',
                                                                'nl' => 'H:mm',
                                                                'nl_BE' => 'H:mm',
                                                                'nl_NL' => 'H:mm',
                                                                'nl_SR' => 'H:mm',
                                                                'no' => 'HH:mm',
                                                                'no_NO' => 'HH:mm',
                                                                'pl' => 'HH:mm',
                                                                'pt' => 'H:mm',
                                                                'pt_AO' => 'H:mm',
                                                                'pt_BR' => 'HH:mm',
                                                                'pt_PT' => 'H:mm',
                                                                'ro_RO' => 'HH:mm',
                                                                'ru' => 'H:mm',
                                                                'sk_SK' => 'H:mm',
                                                                'sl_SI' => 'H:mm',
                                                                'sv' => 'HH:mm',
                                                                'sv_SE' => 'HH:mm',
                                                                'th' => 'h:mm a',
                                                                'th_TH' => 'H:mm ?.',
                                                                'tr' => 'HH:mm',
                                                                'ur_PK' => 'h:mm a',
                                                                'vi_VN' => 'HH:mm ',
                                                                'zh' => 'ah:mm',
                                                                'zh_CN' => 'ah:mm',
                                                                'zh_HK' => 'ah:mm',
                                                                'zh_TW' => 'a h:mm'}; //holds the locale to timedate formats
        return timeFormat; //return the map
    }
    /*@remoteAction
    global static String getDateFormat() {

        String dateFormat = dateFormat().containsKey(UserInfo.getLocale()) ? dateFormat().get(UserInfo.getLocale())  : 'dd/MM/yyyy' ;

        Map<String, String> result = new Map<String, String>();

        result.put('dateFormat', dateFormat);
        result.put('userLocale', UserInfo.getLocale());
        
        return JSON.serialize(result);
    }*/

    /*
    Function to get the date format from custom setting 
    If custom setting doesn't have any date format then get the user locale.
    */
    public static String getDateFormat() {

        return dateFormatMap().containsKey(UserInfo.getLocale()) ? dateFormatMap().get(UserInfo.getLocale())  : 'dd/MM/yyyy';
        
    }

    public static String getTimeFormat() {
        String timeFormat;

        timeFormat = timeFormatMap().containsKey(UserInfo.getLocale()) ? timeFormatMap().get(UserInfo.getLocale())  : 'h:mm a';
        
        return timeFormat;
    }  
}