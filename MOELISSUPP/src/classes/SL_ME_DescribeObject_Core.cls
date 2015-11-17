/*
 * DescribeObject_Core
 * created: Serg Brull 17.09.2010
*/

public with sharing class SL_ME_DescribeObject_Core {
    private static SL_ME_DescribeObject_Core m_instance =  null;
    
    public Map<String, Schema.SObjectType> m_objects = null; 
    protected Transient Map<String, Schema.DescribeSObjectResult> m_described_objects = null;
    protected Transient Map<String, Map<String, Schema.DescribeFieldResult>> m_described_fields_by_object = null;
    
    
    public static SL_ME_DescribeObject_Core getInstance() {
        if(m_instance == null) {
            m_instance = new  SL_ME_DescribeObject_Core();
        }
        return m_instance;
    }
    
    public SL_ME_DescribeObject_Core() {
        RefreshObjects();
    }
     
    /*
    *  Rereed objects describe information      
    */
    public void RefreshObjects() {
        if((m_described_objects == null) || (m_described_objects != null && m_described_objects.isEmpty()) ) {
            m_described_objects =  new Map<String, Schema.DescribeSObjectResult>();
            try {
                m_objects = Schema.getGlobalDescribe();
                m_described_fields_by_object = null; 
                for(String object_name : m_objects.keySet()) {
                    Schema.SObjectType object_type = m_objects.get(object_name);
                    Schema.DescribeSObjectResult object_describe_result = object_type.getDescribe();
                    m_described_objects.put(object_name, object_describe_result);
                }
            } catch(Exception e) {
                    //System.debug('CalendarAnything_Core::RefreshObjects.Exception = ' + e);       
            }
        }
    }
    
    /*
    *   Get objects Name and Label Name. p_selected_type must be 'all', 'standart' or 'custom'.
    */
    public Map<String, String> getObjects(String p_selected_type) {
        Map<String, String> result = new Map<String, String>();
        RefreshObjects();           
        for(String object_name : m_described_objects.keySet()) {
            Schema.DescribeSObjectResult object_describe_result = m_described_objects.get(object_name);
            //if (object_describe_result.fields.getMap().size()> 0)
            {
                if(p_selected_type == 'all') {
                    if( object_describe_result.isAccessible() ) {
                        result.put(object_name, object_describe_result.getLabel());
                    }       
                }
    
                if(p_selected_type == 'standard') {
                    if( object_describe_result.isAccessible() && !object_describe_result.isCustom() ) {
                        result.put(object_name, object_describe_result.getLabel());
                    }       
                }
    
                if(p_selected_type == 'custom') {
                    if( object_describe_result.isAccessible() && object_describe_result.isCustom() ) {
                        result.put(object_name, object_describe_result.getLabel());
                    }       
                }
            }
        }
        return result;  
    }
    
    /* Return all objects  Name and Label Name */
    public Map<String, String> getAllObjects() {
        return getObjects('all');       
    }
    
    /* Return custom objects  Name and Label Name */
    public Map<String, String> getCustomObjects() {
        return getObjects('custom');        
    }
    
    /* Return statdart objects  Name and Label Name */
    public Map<String, String> getStandardObjects() {
        return getObjects('standard') ;     
    }
    
    public Map<String, Schema.DescribeFieldResult> getDecribedFieldsByObject(String p_object_name) {
        Map<String, Schema.DescribeFieldResult> result = new Map<String, Schema.DescribeFieldResult>();
        try {       
            Schema.DescribeSObjectResult object_describe_result = m_described_objects.get(p_object_name);
            Map<String, Schema.SObjectField> object_fields = object_describe_result.fields.getMap();
            for(String field_name : object_fields.keySet()) {
                Schema.DescribeFieldResult field_describe_result = object_fields.get(field_name).getDescribe();
                result.put(field_name, field_describe_result);
            }
        }catch(Exception e) {
            //System.Debug('CalendarAnything_Core::getDecribedFieldsByObject = ' + e);
        }
        return result;
    }
    private boolean isTextType(String p_field_type, String p_requested_type) {
        //PICKLIST STRING DATETIME REFERENCE BOOLEAN DOUBLE TEXTAREA ID ANYTYPE INTEGER EMAIL 
        boolean result = false;
        if(p_requested_type == 'TEXT') {
            if( p_field_type == 'PICKLIST' ||
                p_field_type == 'STRING' ||
                p_field_type == 'EMAIL' ||     
                p_field_type == 'TEXTAREA' ||  
                p_field_type == 'PHONE' ||
                p_field_type == 'COMBOBOX' ||
                p_field_type == 'URL')      
            {
                result = true;
            }       
        } 
        return result;
    }
    
    private boolean isTimeType(String p_field_type, String p_requested_type) {
        boolean result = false;
        if(p_requested_type == 'TIME') {
            if( p_field_type == 'DATETIME' ||
                p_field_type == 'DATE'
            )       
            {
                result = true;
            }       
        }
        return result;
    }
    
    public String getFieldTypeByName(String p_object_name, String p_field_name) {
        RefreshObjects();
        String result = '';
        try {
            Map<String, Schema.DescribeFieldResult> described_fields = getDecribedFieldsByObject(p_object_name);
            Schema.DescribeFieldResult described_field_result = null;
            described_field_result = described_fields.get(p_field_name);
            result = described_field_result.getType().name();
        } catch(Exception e) { }
        return result;
/*
        Schema.DescribeFieldResult requiredField = getFieldByName(p_object_name, p_field_name);
        String result = '';
        if (requiredField != null)
        {
            result = requiredField.getType().name();
        }
        return result;
*/        
    }
    
    public String getFieldLabelByName(String p_object_name, String p_field_name) {
        RefreshObjects();
        String result = '';
        try {
            Map<String, Schema.DescribeFieldResult> described_fields = getDecribedFieldsByObject(p_object_name);
            Schema.DescribeFieldResult described_field_result = described_fields.get(p_field_name);
            result = described_field_result.getLabel();
        } catch(Exception e) {}
        return result;
/*      
        Schema.DescribeFieldResult requiredField = getFieldByName(p_object_name, p_field_name);
        String result = '';
        if (requiredField != null)
        {
            result = requiredField.getLabel();
        }
        return result;
*/      
    }
    
    public String getFieldReferenceByName(String p_object_name, String p_field_name) {
        RefreshObjects();
        String result = '';
        try {
            
            System.debug('--------------------------p_object_name: '+p_object_name);
            Map<String, Schema.DescribeFieldResult> described_fields = getDecribedFieldsByObject(p_object_name.toLowerCase());
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'fields:: ' + described_fields));
            Schema.DescribeFieldResult described_field_result = described_fields.get(p_field_name.toLowerCase());
            List<SObjectType> lst = described_field_result.getReferenceTo();
            result = lst.get(0).getDescribe().getName();
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'getFieldReferenceByName:: ' + e.getMessage()));
        }
        return result;
    }
    
    public Schema.DescribeFieldResult getFieldByName(String p_object_name, String p_field_name)
    {
        Schema.DescribeFieldResult result = null; 
        RefreshObjects();
        Map<String, Schema.DescribeFieldResult> described_fields = getDecribedFieldsByObject(p_object_name);
        result = described_fields.get(p_field_name);
        return result;
    }
    
    
    
    public String getObjectLabelByName(String p_object_name) {
        RefreshObjects();
        String result = '';
        try {
            Schema.DescribeSObjectResult described_object = m_described_objects.get(p_object_name);
            result = described_object.getLabel();
        } catch(Exception e) { }
        return result;
    }

    private Map<String, String> getNeededTypeFields(Map<String, Schema.DescribeFieldResult> p_described_fields,  String p_type) {
        Map<String, String> result = new Map<String, String>();
        for(String field_name : p_described_fields.keySet()) {
            Schema.DescribeFieldResult decribed_field_result = p_described_fields.get(field_name);
            String field_type_name = decribed_field_result.getType().name();
            
            
             
            if( p_type == 'ALL' ||
                field_type_name == p_type || 
                isTextType(field_type_name, p_type) || 
                isTimeType(field_type_name, p_type) 
                ) 
            {
                result.put(field_name, decribed_field_result.getLabel());
            }
        }       
        return result;      
    }
    
    public Map<String, String> getObjectFieldsByType(String p_object_name, String p_type) {
        RefreshObjects();
        Map<String, String> result = new Map<String, String>();
        //System.Debug('CalendarAnything_Core::getObjectFieldsByType::p_object_name = '+ p_object_name);
        try {
            if(m_described_fields_by_object == null) {
                    //System.Debug('CalendarAnything_Core::getObjectFieldsByType(m_described_fields_by_object == null)');
                    m_described_fields_by_object = new Map<String, Map<String, Schema.DescribeFieldResult>>();      
                    Map<String, Schema.DescribeFieldResult> described_fileds = getDecribedFieldsByObject(p_object_name);
                    m_described_fields_by_object.put(p_object_name, described_fileds);
                    result = getNeededTypeFields(described_fileds, p_type);
            } else {
                //System.Debug('CalendarAnything_Core::getObjectFieldsByType(m_described_fields_by_object != null)');
                Map<String, Schema.DescribeFieldResult> described_fields = m_described_fields_by_object.get(p_object_name);
                if(described_fields != null) {
                    //System.Debug('CalendarAnything_Core::getObjectFieldsByType(described_fields != null)');
                    result = getNeededTypeFields(described_fields, p_type);
                } else {
                    // i don`t know how reduce this dublication now :(
                    //System.Debug('CalendarAnything_Core::getObjectFieldsByType(described_fields == null)');
                    Map<String, Schema.DescribeFieldResult> described_fileds = getDecribedFieldsByObject(p_object_name);
                    m_described_fields_by_object.put(p_object_name, described_fileds);
                    result = getNeededTypeFields(described_fileds, p_type);
                }
            }
        }catch(Exception e) {
            //System.Debug('CalendarAnything_Core::getObjectFieldsByType::Exception = '+ e);
            result = null;
        }
        System.Debug(result+';'+m_described_fields_by_object);
        return result;
    }
    
    public List<SObject> getData(String p_object_name, String p_fields, String p_terms, String filter) {
        List<SObject> result = new List<SObject>();
        String query_string = 'SELECT ' + p_fields + ' FROM ' + p_object_name ;
        if(p_terms != null && p_terms.length() > 2) {
            p_terms = p_terms.trim();
            if( p_terms.substring(0,5).toLowerCase() == 'limit' ) {
                query_string += ' ' + p_terms;
            } else {
                query_string += ' WHERE ' + p_terms;
            }
            if ((filter != null) && (filter.trim() != '')) 
            {
                query_string += ' AND '+filter;
            }
        }
        //System.Debug( 'CalendarAnything_Core::getData.query_string = ' + query_string );
        result = (List<SObject>)database.query(query_string); 
        return result;      
    }

    /*
    *   Get object Name By Object prefix.
    */
    public String getObjectNameByPrefix(String prefix) {
        Schema.DescribeSObjectResult requiredObject = getObjectByPrefix(prefix);
        String result = ''; 
        if (requiredObject != null)
        {
            result = requiredObject.getName();
        }
        return result;
    }
    
    public String getObjectLabelByPrefix(String prefix) {
        Schema.DescribeSObjectResult requiredObject = getObjectByPrefix(prefix);
        String result = ''; 
        if (requiredObject != null)
        {
            result = requiredObject.getLabel();
        }
        return result;
    }
    
    public Schema.DescribeSObjectResult getObjectByPrefix(String prefix)
    {
        Schema.DescribeSObjectResult result = null;
        RefreshObjects();           
        for(String object_name : m_described_objects.keySet()) {
            Schema.DescribeSObjectResult object_describe_result = m_described_objects.get(object_name);
            if (object_describe_result.getKeyPrefix() == prefix) {
                result = object_describe_result;
            } 
        }
        return result;  
    }
    
}