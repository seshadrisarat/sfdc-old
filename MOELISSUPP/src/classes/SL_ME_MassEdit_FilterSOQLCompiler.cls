public with sharing class SL_ME_MassEdit_FilterSOQLCompiler extends FilterSOQLCompiler {
    public Id recordId {get; set;}
    public String targetObject {get; set;} 
    
    protected override String getFilterValue(FilterSet p_filter_set){
        String value = '';
        Boolean is_multipicklist = isMultipicklist(p_filter_set);
        Boolean is_picklist = isPicklist(p_filter_set);
        Boolean is_number = isNumber(p_filter_set);
        Boolean is_boolean = isBoolean(p_filter_set);
        Boolean is_dateORtime = isDateOrTime(p_filter_set);
        Boolean is_reference = isReference(p_filter_set);
        
        if (is_reference || p_filter_set.Field=='recordtypeid'){
            Id v = getReferenceId(p_filter_set);
            //if (v==null) value = null; else 
            value = Q(v);
            p_filter_set.ValueId = value;
        }
        else
        if (isNotQuoteOperator(p_filter_set) || is_number || is_boolean || is_dateORtime) {
            value = p_filter_set.Value;
            if (value.trim().length()==0){
                value = 'null';
            }
        } else if (is_multipicklist) {
            value = splitMultiPicklist2Equal(p_filter_set.Value);
        } else {
            value = Q(p_filter_set.Value);
        }
        
        if(is_number && value == '') {
            value = '0';
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'getFilterValue :: ' + value));
        return value;
    }
    
    protected override String compileFilter(FilterSet p_filter_set) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'IN OVERRIDE'));
        
        String result = '';
        String value = '';
        Boolean is_multipicklist = isMultipicklist(p_filter_set);
        Boolean is_picklist = isPicklist(p_filter_set);
        Boolean is_number = isNumber(p_filter_set);
        Boolean is_boolean = isBoolean(p_filter_set);
        Boolean is_dateORtime = isDateOrTime(p_filter_set);
        Boolean is_reference = isReference(p_filter_set);
        
        value = getFilterValue(p_filter_set);
         
        if(p_filter_set.Operator == 'equal') {
            result = p_filter_set.Field + ' = ' + value;
        } else if(p_filter_set.Operator == 'notEqual') {
            result = p_filter_set.Field + ' != ' + value;
        } else if(p_filter_set.Operator == 'lessThan') {
            result = p_filter_set.Field +  ' < ' + value;
        } else if(p_filter_set.Operator == 'greaterThan') {
            result = p_filter_set.Field + ' > ' + value;
        } else if(p_filter_set.Operator == 'lessOrEqual') {
            result = p_filter_set.Field + ' <= ' + value;
        } else if(p_filter_set.Operator == 'greaterOrEqual') {
            result = p_filter_set.Field + ' >= ' + value;
        }else if(p_filter_set.Operator == 'startsWith') {
            result = p_filter_set.Field + ' LIKE ' + Q(value+'%');
        }else if(p_filter_set.Operator == 'contains') {
            result = p_filter_set.Field +  ' LIKE ' + Q('%' + value + '%');  
        }else if(p_filter_set.Operator == 'notContain') {
            result = 'NOT('+p_filter_set.Field +  ' LIKE ' + Q('%' + value + '%')+')';
        }else if(p_filter_set.Operator == 'includes' && !is_multipicklist && !is_picklist) {
            result =  p_filter_set.Field +  ' IN ( ' + Q(value) +  ' )';
        }else if(p_filter_set.Operator == 'excludes' && !is_multipicklist && !is_picklist) {
            result = 'NOT('+p_filter_set.Field +  ' IN ( ' + Q(value) +  ' )'+')';
        }else if(p_filter_set.Operator == 'includes' && is_picklist) {
            result =  p_filter_set.Field +  ' IN ( ' + splitMultiPicklist2Includes(value) +  ' )';
        }else if(p_filter_set.Operator == 'excludes' && is_picklist) {
            result = 'NOT('+p_filter_set.Field +  ' IN ( ' + splitMultiPicklist2Includes(value) +  ' ))';
        }else if(p_filter_set.Operator == 'includes' && is_multipicklist) {
            result =  p_filter_set.Field +  ' INCLUDES ( ' + splitMultiPicklist2Includes(value) +  ' )';
        }else if(p_filter_set.Operator == 'excludes' && is_multipicklist) {
            result = p_filter_set.Field +  ' EXCLUDES ( ' + splitMultiPicklist2Includes(value) +  ' )';
        }
        system.debug('Field!!!: ' + p_filter_set.Field + '; FilterType: ' + p_filter_set.FilterType +'!!!') ; 
         
        return '('+result+')';
    }
    
    public override String getSOQL() {
        m_parse_result = remapAdvanced(m_advenced);
        //trace = 'remapAdvanced: ' + remapAdvanced(m_advenced);
        try {
            for( Integer i = 0; i < m_filter_set.size(); i++ ) {
                trace = 'getSOQL::['+ i +']::Compile...'; 
                m_filter_set[i].Compiled = compileFilter(m_filter_set[i]);
                trace = 'getSOQL::['+ i +']::Compile result: ' + m_filter_set[i].Compiled;
                m_parse_result = compileFilters(m_filter_set[i].Order, m_filter_set[i].Compiled);
                System.debug('m_parse_result______'+m_parse_result);
            }
        }catch (Exception e) {
            trace = 'getSOQL error::' + e.getMessage();
        }
        return m_parse_result;
    }
     
    protected override String remapAdvanced(String p_advenced) {
        return p_advenced.replaceAll('([0-9]+)', '{#$1}');
    }
    
    protected override String compileFilters(String p_filter_order, String p_filter_compiled) {
        //trace = 'compileFilters: ' + '{#'+ p_filter_order +'}' + '; filter: ' + p_filter_compiled;
        System.debug('+++++++++++++++++++'+m_parse_result);
        System.debug('==================compileFilters: ' + '{#'+ p_filter_order +'}' + '; filter: ' + p_filter_compiled);
        return m_parse_result.replaceAll('\\{#'+ p_filter_order +'\\}', p_filter_compiled);
    }
}