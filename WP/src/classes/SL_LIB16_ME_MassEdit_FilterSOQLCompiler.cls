public with sharing class SL_LIB16_ME_MassEdit_FilterSOQLCompiler  extends SL_LIB16_FilterSOQLCompiler {
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
    
    public static testmethod void testSL_LIB16_ME_MassEdit_FilterSOQLCompiler()
	 {
	  Account a = new Account(Name = 'test');
	  insert a;
	  FilterSet fs = new FilterSet();
	  fs.FilterType = 'ID';   
	  fs.Value = string.valueOf(a.Id);
	  fs.Operator = 'equal';
	  fs.Order = '1';
	  SL_LIB16_ME_MassEdit_FilterSOQLCompiler objFSOQL = new SL_LIB16_ME_MassEdit_FilterSOQLCompiler();
	  objFSOQL.getFilterValue(fs);
	  objFSOQL.compileFilter(fs); 
	  objFSOQL.m_parse_result = objFSOQL.remapAdvanced('1');
	  
	  FilterSet fs1 = new FilterSet();
	  fs1.FilterType = 'DATE';   
	  fs1.Value = string.valueOf(a.Id);
	  
	  fs1.Operator = 'notEqual';
	  fs1.Order = '1';
	  fs1.field = 'Name';
	  objFSOQL.getFilterValue(fs1);
	  objFSOQL.compileFilter(fs1);
	  string s = objFSOQL.remapAdvanced('2');
	  objFSOQL.m_parse_result = objFSOQL.remapAdvanced('1');
	  objFSOQL.m_advenced = '2';
	  objFSOQL.m_parse_result = objFSOQL.getSOQL();
	  
	  FilterSet fs2 = new FilterSet();
	  fs2.FilterType = 'DATE';   
	  fs2.Value = string.valueOf(a.Id);
	  fs2.Operator = 'lessThan';
	  fs2.Order = '1';
	  objFSOQL.getFilterValue(fs2);
	  objFSOQL.compileFilter(fs2);
	  s = objFSOQL.remapAdvanced('3'); 
	  
	  FilterSet fs3 = new FilterSet();
	  fs3.FilterType = 'DATE';   
	  fs3.Value = string.valueOf(a.Id);
	  fs3.Operator = 'lessOrEqual';
	  fs3.Order = '1';
	  objFSOQL.getFilterValue(fs3);
	  objFSOQL.compileFilter(fs3);
	  
	  
	  FilterSet fs4 = new FilterSet();
	  fs4.FilterType = 'DATETIME';   
	  fs4.Value = string.valueOf(a.Id);
	  fs4.Operator = 'greaterOrEqual';
	  fs4.Order = '1';
	  objFSOQL.getFilterValue(fs4);
	  objFSOQL.compileFilter(fs4);
	  
	  FilterSet fs5 = new FilterSet();
	  fs5.FilterType = 'DATETIME';   
	  fs5.Value = string.valueOf(a.Id);
	  fs5.Operator = 'startsWith';
	  fs5.Order = '2';
	  objFSOQL.getFilterValue(fs5);
	  objFSOQL.compileFilter(fs5);
	  
	  fs5.Operator = 'contains';
	  fs5.Order = '2';
	  objFSOQL.getFilterValue(fs5);
	  objFSOQL.compileFilter(fs5);
	  
	  fs5.Operator = 'notContain';
	  fs5.Order = '1';
	  objFSOQL.getFilterValue(fs5);
	  objFSOQL.compileFilter(fs5);
	  
	  fs5.Operator = 'includes';
	  fs5.Order = '8';
	  objFSOQL.getFilterValue(fs5);
	  objFSOQL.compileFilter(fs5);
	  
	  fs5.Operator = 'excludes';
	  fs5.Order = '8';
	  objFSOQL.getFilterValue(fs5);
	  objFSOQL.compileFilter(fs5);
	  
	  FilterSet fs7 = new FilterSet();
	  fs7.FilterType = 'MULTIPICKLIST';   
	  fs7.Value = string.valueOf(a.Id);
	  fs7.Operator = 'includes';
	  fs7.Order = '2';
	  objFSOQL.getFilterValue(fs7);
	  objFSOQL.compileFilter(fs7);
	  
	  fs7.FilterType = 'MULTIPICKLIST';   
	  fs7.Value = string.valueOf(a.Id);
	  fs7.Operator = 'excludes';
	  fs7.Order = '2';
	  objFSOQL.getFilterValue(fs7);
	  objFSOQL.compileFilter(fs7);
	  
	  fs7.FilterType = 'PICKLIST';   
	  fs7.Value = string.valueOf(a.Id);
	  fs7.Operator = 'includes';
	  fs7.Order = '2';
	  objFSOQL.getFilterValue(fs7);
	  objFSOQL.compileFilter(fs7);
	  
	  fs7.FilterType = 'PICKLIST';   
	  fs7.Value = string.valueOf(a.Id);
	  fs7.Operator = 'excludes';
	  fs7.Order = '2';
	  objFSOQL.getFilterValue(fs7);
	  objFSOQL.compileFilter(fs7);
	  
	  fs7.FilterType = 'BOOLEAN';   
	  fs7.Value = string.valueOf(a.Id);
	  fs7.Operator = 'excludes';
	  fs7.Order = '2';
	  objFSOQL.getFilterValue(fs7);
	  objFSOQL.compileFilter(fs7);
	  
	  fs7.FilterType = 'BOOLEAN';   
	  fs7.Value = string.valueOf(a.Id);
	  fs7.Operator = 'includes';
	  fs7.Order = '2';
	  objFSOQL.getFilterValue(fs7);
	  objFSOQL.compileFilter(fs7);
	  
	  fs7.FilterType = 'BOOLEAN';   
	  fs7.Value = string.valueOf(a.Id);
	  fs7.Operator = 'greaterThan';
	  fs7.Order = '2';
	  objFSOQL.getFilterValue(fs7);
	  objFSOQL.compileFilter(fs7);
	  
	  FilterSet fs8 = new FilterSet();
	  fs8.FilterType = 'DATE';   
	  fs8.Value = string.valueOf(a.Id);
	  fs8.Operator = 'includes';
	  fs8.Order = '2#';
	  fs8.Compiled = 'yes';
	  string str1 = objFSOQL.compileFilters(fs8.Order,fs8.Compiled);
	  
	  
	  //String s1 = objFSOQL.compileFilters(fs8,'');
	  //objFSOQL.getSOQL();
	  
	 }

}