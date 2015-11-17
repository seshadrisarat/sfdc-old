public with sharing class CompanyList_Search_Filter {
    public static Map<String, Map<String, Schema.SObjectField>> describeFieldsMap;
    static{
        describeFieldsMap = new Map<String, Map<String, Schema.SObjectField>>();
        describeFieldsMap.put('Account', Schema.SObjectType.Account.fields.getMap());
    }
    private String FILTER_TYPE;
    public List<Filter> filters {get; set;}
    private List<SelectOption> fieldsLst = new List<SelectOption>();
    private Map<String, List<SelectOption>> fieldOperatorsMap = new Map<String, List<SelectOption>>();
    private Map<String, String> fieldExamplesMap = new Map<String, String>();
    public Integer currentIndex {get; set;}
    
    public CompanyList_Search_Filter(String ftp){
        FILTER_TYPE = ftp;
        List<SelectOption> allOperators = new List<SelectOption>{
                     new SelectOption('', '-- NONE --')
                    ,new SelectOption('g', 'greater')
                    ,new SelectOption('ge', 'greater or equal')
                    ,new SelectOption('l', 'less')
                    ,new SelectOption('le', 'less or equal')
                    ,new SelectOption('bt', 'between')
        };
        List<SelectOption> stringOperators = new List<SelectOption>{
                     new SelectOption('', '-- NONE --')
                    ,new SelectOption('e', 'equals')
                    ,new SelectOption('ne', 'not equals')
        };
        List<SelectOption> doubleOperators = new List<SelectOption>{
                     new SelectOption('', '-- NONE --')
                    ,new SelectOption('e', 'equals')
                    ,new SelectOption('ne', 'not equals')
                    ,new SelectOption('g', 'greater')
                    ,new SelectOption('ge', 'greater or equal')
                    ,new SelectOption('l', 'less')
                    ,new SelectOption('le', 'less or equal')
                    ,new SelectOption('bt', 'between')
        };
        
        
        Map<String, SelectOption> tmpFields = new Map<String, SelectOption>();
        for (String s : describeFieldsMap.get(FILTER_TYPE).keySet()){
            Schema.SObjectField f = describeFieldsMap.get(FILTER_TYPE).get(s);
            if (!f.getDescribe().isFilterable()) continue;
            String l = f.getDescribe().getLabel();
            String n = f.getDescribe().getName();
            String t = f.getDescribe().getSoapType().name();
            tmpFields.put(l, new SelectOption(n, l));
            String example = '';
            if (f.getDescribe().getSoapType()==Schema.SOAPType.STRING) {
                fieldOperatorsMap.put(n, stringOperators); 
            } else 
            if (f.getDescribe().getSoapType()==Schema.SOAPType.DOUBLE) {
                fieldOperatorsMap.put(n, doubleOperators);
                example = 'ex. "2.0" or "3"';
            } else 
            if (f.getDescribe().getSoapType()==Schema.SOAPType.INTEGER) {
                fieldOperatorsMap.put(n, doubleOperators);
                example = 'ex. "3"';
            } else
            if (f.getDescribe().getSoapType()==Schema.SOAPType.DATETIME) {
                fieldOperatorsMap.put(n, doubleOperators);
                example = 'ex. "2010-09-28 13:45:15"';
            } else 
            if (f.getDescribe().getSoapType()==Schema.SOAPType.DATE) {
                fieldOperatorsMap.put(n, doubleOperators);
                example = 'ex. "2010-09-28"';
            } else
            if (f.getDescribe().getSoapType()==Schema.SOAPType.TIME) {
                fieldOperatorsMap.put(n, doubleOperators);
                example = 'ex. "13:45:15"';
            } else {
                fieldOperatorsMap.put(n, allOperators);
            }
            fieldExamplesMap.put(n, example);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, s + ' :: ' + l + ' :: ' + t));
        }
        tmpFields.put('-- NONE --', new SelectOption('', '-- NONE --'));
        List<String> fls = new List<String>(tmpFields.keySet());
        fls.sort();
        for (String s : fls){
            fieldsLst.add(tmpFields.get(s));
        }
        filters = new List<Filter>();
        addFilter();
    }
    
    public String getSimpleQuery(){
        if (FILTER_TYPE=='Account') return 'SELECT Id, Name FROM Account';
        throw new FilterNotFoundException('Cannot get base query for FILTER_TYPE :: ' + FILTER_TYPE);
    }
    
    public String prepareQuery(){
        String query = getSimpleQuery();
        String whereStr = '';
        for (Filter f : filters){
            String q = f.prepareCondition();
            if (q.length()==0) continue;
            whereStr += ' AND ' + q;
        }
        if (whereStr.length()>0) {
            whereStr = whereStr.substring(4);
            query += ' WHERE ' + whereStr;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'query :: ' + query));
        return query;       
    }
    
    public void recalcFilterValues(){
        if (filters==null) return;
        for (integer i=0; i<filters.size(); i++){
            if (i==0) filters[i].name = 'Where ';
            else filters[i].name = '<b>AND</b> ';
            filters[i].index = i;
            if (filters[i].field!=null) {
                filters[i].operators = fieldOperatorsMap.get(filters[i].field);
                filters[i].example = fieldExamplesMap.get(filters[i].field);
            }
        }
    }
    
    public void addFilter(){
        Filter f = new Filter(FILTER_TYPE);
        f.fieldLabels = fieldsLst;
        filters.add(f);
        recalcFilterValues();
    }
    
    public void removeFilter(){
        filters.remove(currentIndex);
        recalcFilterValues();
    }
    
    public class Filter {
        public String name {get; set;}
        public List<SelectOption> fieldLabels {get; set;}
        public List<SelectOption> operators {get; set;}
        public String field {get; set;}
        public String operator {get; set;}
        public String param1 {get; set;}
        public String param2 {get; set;}
        public String example {get; set;}
        public Integer index {get; set;}
        private String FILTER_TYPE; 
        public Filter(String ftp){
            this.FILTER_TYPE = ftp;
            this.operator = '';
        }
        
        public String prepareCondition(){
            if (field==null || field.trim().length()==0) return '';
            if (operator==null || operator.trim().length()==0) return '';
            Schema.SObjectField f = CompanyList_Search_Filter.describeFieldsMap.get(FILTER_TYPE).get(field);
            String pr = prepareParam(f.getDescribe().getSOAPType(), param1);
            String pr2 = prepareParam(f.getDescribe().getSOAPType(), param2);
            if (pr.length()==0) return '';
            if (operator=='e') return '( ' + field + ' = ' + pr + ' )';
            if (operator=='ne') return '( ' + field + ' != ' + pr + ' )';
            if (operator=='g') return '( ' + field + ' > ' + pr + ' )';
            if (operator=='ge') return '( ' + field + ' >= ' + pr + ' )';
            if (operator=='l') return '( ' + field + ' < ' + pr + ' )';
            if (operator=='le') return '( ' + field + ' <= ' + pr + ' )';
            if (operator=='bt') return '( ' + field + ' >= ' + pr + ' AND ' + field + ' <= ' + pr2 + ')';
            return '';
        }
        
        private String prepareParam(Schema.SOAPType st, String param){
            if (param==null) return '';
            if (st==Schema.SOAPType.STRING) return '\'' + param + '\'';
            if (st==Schema.SOAPType.DATE){
                try {
                    Date valueDate = date.valueOf(param);
                    DateTime valueDatetime = datetime.newInstance(valueDate, time.newInstance(0,0,0,0));
                    return valueDatetime.formatGMT('yyyy-MM-dd');
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Cannot parse "' + param + '" to date. Use <YYYY-MM-DD> format...'));
                }
                return '';
            }
            if (st==Schema.SOAPType.DATETIME){
                try {
                    DateTime valueDatetime = datetime.valueOf(param);
                    return valueDatetime.formatGMT('yyyy-MM-dd')+'T'+ valueDatetime.formatGMT('HH:mm:ss.SSS')+'Z';
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Cannot parse "' + param + '" to datetime. Use <YYYY-MM-DD HH:mm:ss> format...')); 
                }
                return '';
            }
            if (st==Schema.SOAPType.TIME){
                try {
                    DateTime valueDatetime = datetime.valueOf('2010-01-01 '+param);
                    return valueDatetime.formatGMT('HH:mm:ss.SSS');
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Cannot parse "' + param + '" to time. Use <HH:mm:ss> format...')); 
                }
                return '';
            }
            if (st==Schema.SOAPType.INTEGER){
                try {
                    Integer value = integer.valueOf(param);
                    return ''+value;
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Cannot parse "' + param + '" to integer.')); 
                }
                return '';
            }
            if (st==Schema.SOAPType.DOUBLE){
                try {
                    double value = double.valueOf(param);
                    return ''+value;
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Cannot parse "' + param + '" to decimal.')); 
                }
                return '';
            }
            if (st==Schema.SOAPType.ID){
                try {
                    Id val = (Id)param;
                    return ''+val;
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Cannot parse "' + param + '" to Id.')); 
                }
                return '';
            }
            if (st==Schema.SOAPType.BOOLEAN){
                try {
                    boolean value = boolean.valueOf(param);
                    return ''+value;
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Cannot parse "' + param + '" to boolean. Use "true" or "false"...')); 
                }
                return '';
            }
            return param;
        }
    }
    
    public class FilterNotFoundException extends Exception{
    } 
}