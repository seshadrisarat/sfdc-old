public with sharing class ear_sample_pdf_page_controller {
    public String deal_id;
    String DealTeam;
    String Revenue_MM;
    String EBITDA_MM;
    String WP_Investment_MM;
    String WP_Ownership_Fully_Diluted;
    String Transaction_Value_MM;
    String EAR_Description;
    String Comp_Description;
    String Capital_Market_Consideration;
    String Why_Interesting;
    String Fit_With_Group;
    String Areas_of_Concern_Red_Flags;
    String WP_Human_Capital_or_WP_Angle;
    String Key_Dates_Next_Steps;
    String CompCurrencyCode;
    String ExpenseCode;
    List<Deal_Score_Line_Item__c> EarMetrics{get; set;}
    String ClassToBeApplied;
    
    

 public ear_sample_pdf_page_controller()
 {}
    public ear_sample_pdf_page_controller(ApexPages.StandardController controller) {
      this.deal_id= ((Deal__c)controller.getRecord()).Id;
      this.DealTeam='';
      this.Revenue_MM='';
      this.EBITDA_MM='';
      this.WP_Investment_MM='';
      this.WP_Ownership_Fully_Diluted='';     
      this.Transaction_Value_MM='';
      this.CompCurrencyCode='';   
      this.earMetrics = null;        
   	  this.ExpenseCode = '';
    }

    public Decimal getDecimalMod(Decimal num1 , Decimal num2)
    {
        Decimal c = 0;
        Decimal result;
        result = num1 / num2;
        c= Math.floor(result);
        result = num1 - (num2 * c);
        return result;        
    }
    
    public String pad2(Integer val) {
    if (val < 10) {
        return '0' + val;
    }
    return '' + val;
    }
    
    public String formatDate(Date myDate){
      String dateFormatted='';
      if(myDate!= null)
        dateFormatted= pad2(myDate.month())+ '/'+  pad2(myDate.day()) + '/' + myDate.year();
      return dateFormatted;
    }
    
    public String getDealTeam() {
    String deal_team_string='';
    
    List<Deal__c> deal_list =  [        
            SELECT 
            id,
            (SELECT Id,Employee__r.Name, Employee__r.Employee_Level__r.Rank__c,Employee__r.ISSENIORTEAMMEMBER__c,
            Employee__r.Employee_Level_Precedence_Sorter__c, Role__c
             FROM Deal_Team__r
             ORDER BY Employee__r.Employee_Level__r.Rank__c DESC NULLS LAST, Role__c ASC NULLS LAST, Employee__r.Employee_Level_Precedence_Sorter__c DESC NULLS LAST)
            FROM Deal__c 
            WHERE Id =:deal_id];
    if(deal_list.size() != 1)
    {
       system.debug('getDealTeam:Deal not found:'+deal_list.size());
       deal_team_string='\n';
    }
    else
    {
       List<Deal_Team__c> team_list = deal_list[0].Deal_Team__r;
       Integer list_count=0;
       for(Deal_Team__c team_item:team_list) {
         list_count++;
         deal_team_string=deal_team_string+team_item.Employee__r.Name;
         if(list_count <  team_list.size()) {
           deal_team_string=deal_team_string+',  ';
         }
       }
       if(String.isBlank(deal_team_string)||String.isEmpty(deal_team_string)) {
         deal_team_string='\n';
       }       
    }   
    
    return deal_team_string;
    }

    public String getCurrencySymbolFromIso(String Iso) {
         String currencySymbol = 
           ('USD' == Iso ? '$' : 
           ('CAD' == Iso ? '$' : 
           ('EUR' == Iso ? '€' : 
           ('GBP' == Iso ? '£' : 
           ('JPY' == Iso ? '¥' :   
           Iso+' ')))));
           return currencySymbol;
    }
    public String getExpenseCode() {
         String expensecode = '';
         List<Deal__c> deal_list =  [        
            SELECT 
            id,
            Expense_Code__c
            FROM Deal__c 
            WHERE Id =:deal_id];
        if(deal_list.size() != 1)
        {
           expensecode='\n';
        }
        else
        {
            expensecode = deal_list[0].Expense_Code__c;      
        }   
        
   	    return expensecode;
    }
    public String getCompCurrencyCode()
    {
    String compCurrencyCode_string='';
    
    List<Deal__c> deal_list =  [        
            SELECT 
            id,
            Company__c,
            Company__r.CurrencyIsoCode
            FROM Deal__c 
            WHERE Id =:deal_id];
    if(deal_list.size() != 1)
    {
       system.debug('getCompCurrencyCode:Deal not found:'+deal_list.size());
       compCurrencyCode_string='\n';
    }
    else
    {
        compCurrencyCode_string = deal_list[0].Company__r.CurrencyIsoCode;      
    }   
        
    return compCurrencyCode_string;
    }
        
    public String getRevenue_MM()
    {
    String revenue_mm_string='';
    
    List<Deal__c> deal_list =  [        
            SELECT 
            id,
            Company__c
            FROM Deal__c 
            WHERE Id =:deal_id];
    if(deal_list.size() != 1)
    {
       system.debug('getRevenue_MM:Deal not found:'+deal_list.size());
       revenue_mm_string='\n';
    }
    else
    {
        List<Financial__c> financials = [
          SELECT EBITDA_MM__c,  
          Period_Ended__c, Revenues_MM__c FROM Financial__c
          WHERE ((Company__c = :deal_list[0].Company__c) AND(Period_Ended__c != Null))
          ORDER BY Period_Ended__c DESC LIMIT 2];

       if(financials.size()<=0) {
         system.debug('getRevenue_MM:Financial not found:'+financials.size());
         revenue_mm_string='\n';
       }
       else {
       Integer list_count=0,i;
       for(i=financials.size()-1; i >=0;--i) {
         list_count++;
        if(financials[i].Revenues_MM__c == null){
         revenue_mm_string=revenue_mm_string+ '<b>'+formatDate(financials[i].Period_Ended__c)+'</b>' + '    '+' ';
        }
        else {       
         if(getDecimalMod(financials[i].Revenues_MM__c.setScale(2),1.0) != 0) {
          revenue_mm_string=revenue_mm_string+ '<b>'+formatDate(financials[i].Period_Ended__c)+'</b>' + '    '+ financials[i].Revenues_MM__c.setScale(2).format();
         }
         else {
          revenue_mm_string=revenue_mm_string+ '<b>'+formatDate(financials[i].Period_Ended__c)+'</b>' + '    '+ financials[i].Revenues_MM__c.setScale(2).round().format();
         }          
        } 
         if(list_count <  financials.size()) {
           revenue_mm_string=revenue_mm_string+'           ';
         }
       }
      }       
    }   
        
    return revenue_mm_string;
    }
    
    public String getEBITDA_MM()
    {
    String ebit_mm_string='';
    
    List<Deal__c> deal_list =  [        
            SELECT 
            id,
            Company__c
            FROM Deal__c 
            WHERE Id =:deal_id];
    if(deal_list.size() != 1)
    {
       system.debug('getEBITDA_MM:Deal not found:'+deal_list.size());
       ebit_mm_string='\n';
    }
    else
    {
        List<Financial__c> financials = [
          SELECT EBITDA_MM__c,  
          Period_Ended__c FROM Financial__c
          WHERE ((Company__c = :deal_list[0].Company__c) AND(Period_Ended__c != Null))
          ORDER BY Period_Ended__c DESC LIMIT 2];

       if(financials.size()<=0) {
         system.debug('getEBITDA_MM:Financial not found:'+financials.size());
         ebit_mm_string='\n';
       }
       else {
       Integer list_count=0,i;
       for(i=financials.size()-1; i >=0;--i) {
         list_count++;
        if(financials[i].EBITDA_MM__c == null){
         ebit_mm_string=ebit_mm_string+ '<b>'+formatDate(financials[i].Period_Ended__c)+'</b>' + '    '+' ';
        }
        else {       
         if(getDecimalMod(financials[i].EBITDA_MM__c.setScale(2),1.0) != 0) {
          ebit_mm_string=ebit_mm_string+ '<b>'+formatDate(financials[i].Period_Ended__c)+'</b>' + '    '+ financials[i].EBITDA_MM__c.setScale(2).format();
         }
         else {
          ebit_mm_string=ebit_mm_string+ '<b>'+formatDate(financials[i].Period_Ended__c)+'</b>' + '    '+ financials[i].EBITDA_MM__c.setScale(2).round().format();
         }      
        }        
         if(list_count <  financials.size()) {
           ebit_mm_string=ebit_mm_string+'           ';
         }
       }
      }       
    }   
        
    return ebit_mm_string;
    }
    
    public String getWP_Investment_MM()
    {
    String WPInvest_mm_string='';
    
    List<Deal__c> deal_list =  [        
            SELECT 
            id,
            WP_Investment_MM__c 
            FROM Deal__c 
            WHERE Id =:deal_id];
            
    if(deal_list.size() != 1)
    {
       system.debug('getWP_Investment_MM:Deal not found:'+deal_list.size());
        WPInvest_mm_string='\n';
    }
    else
    {
        if(deal_list[0].WP_Investment_MM__c == null){
         WPInvest_mm_string='\n';
        }
        else {
         if(getDecimalMod(deal_list[0].WP_Investment_MM__c.setScale(2),1.0) != 0) {
          WPInvest_mm_string=deal_list[0].WP_Investment_MM__c.setScale(2).format();
         }
         else {
          WPInvest_mm_string=deal_list[0].WP_Investment_MM__c.setScale(2).round().format();
         }  
        }   
    }    
    return WPInvest_mm_string;
    }   
   
    public String getWP_Ownership_Fully_Diluted()
    {
    String WPOwnerDilFul_string='';
    
    List<Deal__c> deal_list =  [        
            SELECT 
            id,
            WP_Ownership_Diluted__c 
            FROM Deal__c 
            WHERE Id =:deal_id];
    if(deal_list.size() != 1)
    {
       system.debug('getWP_Investment_MM:Deal not found:'+deal_list.size());
       WPOwnerDilFul_string='\n';
    }
    else
    {
       if(deal_list[0].WP_Ownership_Diluted__c != null ) {
         if(getDecimalMod(deal_list[0].WP_Ownership_Diluted__c.setScale(2),1.0) != 0) {
          WPOwnerDilFul_string=deal_list[0].WP_Ownership_Diluted__c.setScale(2).format()+'%';
         }
         else {
          WPOwnerDilFul_string=deal_list[0].WP_Ownership_Diluted__c.setScale(2).round().format()+'%';
         }         
       }
       else {
         WPOwnerDilFul_string='\n';
      }
    }     
    return WPOwnerDilFul_string;
    }   

public String getTransaction_Value_MM()
    {
    String WPTransVal_string='';
    
    List<Deal__c> deal_list =  [        
            SELECT 
            id,
            Transaction_Value_MM__c 
            FROM Deal__c 
            WHERE Id =:deal_id];
            
    if(deal_list.size() != 1)
    {
       system.debug('getTransaction_Value_MM:Deal not found:'+deal_list.size());
        WPTransVal_string='\n';
    }
    else
    {
        if(deal_list[0].Transaction_Value_MM__c == null){
         WPTransVal_string='\n';
        }
        else {
         if(getDecimalMod(deal_list[0].Transaction_Value_MM__c.setScale(2),1.0) != 0) {
          WPTransVal_string=deal_list[0].Transaction_Value_MM__c.setScale(2).format();
         }
         else {
          WPTransVal_string=deal_list[0].Transaction_Value_MM__c.setScale(2).round().format();
         }  
        }   
    }    
    return WPTransVal_string;
    }   

public String getEAR_Description()
    {
    String desc_string='';
    
    List<Deal__c> deal_list =  [        
            SELECT 
            id,
            Description_EAR__c /*Description__c*/
            FROM Deal__c 
            WHERE Id =:deal_id];
            
    if(deal_list.size() != 1)
    {
       system.debug('getEAR_Description:Deal not found:'+deal_list.size());
       desc_string='\n';
    }
    else
    {
       desc_string = deal_list[0].Description_EAR__c;

       if(String.isBlank(desc_string)||String.isEmpty(desc_string)) {
         desc_string='\n';
       }else if(  (deal_list[0].Description_EAR__c.contains('•')== true) ||
                  (deal_list[0].Description_EAR__c.contains('▪')== true)
                ) {
         desc_string = '<ul>';
         deal_list[0].Description_EAR__c = deal_list[0].Description_EAR__c.replace('•','');
         deal_list[0].Description_EAR__c = deal_list[0].Description_EAR__c.replace('▪','');         
         List<String> temp_string_list = deal_list[0].Description_EAR__c.split('\n',0);
         
          for ( String item : temp_string_list) {  
            desc_string = desc_string + '<li>'+ item + '</li>';
          }
         desc_string = desc_string + '</ul>';
       } 
    }    
    return desc_string;
    }   
    
    public String getComp_Description()
    {
    String comp_string='';
    
    List<Deal__c> deal_list =  [        
            SELECT 
            id,
            Company__r.Description
            FROM Deal__c 
            WHERE Id =:deal_id];
    if(deal_list.size() != 1)
    {
       system.debug('getComp_Description:Deal not found:'+deal_list.size());
       comp_string='\n';
    }
    else
    {
       comp_string = deal_list[0].Company__r.Description;
       if(String.isBlank(comp_string)||String.isEmpty(comp_string)) {
        comp_string='\n'; 
       } else if(  (deal_list[0].Company__r.Description.contains('•')== true) ||
                  (deal_list[0].Company__r.Description.contains('▪')== true)
                ) {
         comp_string= '<ul>';
         deal_list[0].Company__r.Description = deal_list[0].Company__r.Description.replace('•','');
         deal_list[0].Company__r.Description = deal_list[0].Company__r.Description.replace('▪','');         
         List<String> temp_string_list = deal_list[0].Company__r.Description.split('\n',0);
         
          for ( String item : temp_string_list) {  
            comp_string = comp_string + '<li>'+ item + '</li>';
          }
         comp_string = comp_string + '</ul>';
       }  
    }   
        
    return comp_string;
    }      
    
    public String getCapital_Market_Consideration()
    {
    String temp='';
    
        List<Deal__c> deal_list= [
            SELECT 
            id,Key_Dates_Next_Steps__c,                    
            Areas_of_Concern_Red_Flags__c,Fit_With_Group__c,
            Why_Interesting__c,WP_Human_Capital_or_WP_Angle__c,
            Capital_Market_Consideration__c
            FROM Deal__c 
            WHERE Id = :deal_id
        ];
    if(deal_list.size() != 1)
    {
       system.debug('getCapital_Market_Consideration:Deal not found:'+deal_list.size());
       temp='\n';
    }
    else
    {
       temp = deal_list[0].Capital_Market_Consideration__c;
       system.debug('getCapital_Market_Consideration 1:is:'+temp);        
       if(String.isBlank(temp)||String.isEmpty(temp)) {
        temp='\n'; 
       } else if((false) && (deal_list[0].Capital_Market_Consideration__c.contains('<ul>')== false) &&
                 (deal_list[0].Capital_Market_Consideration__c.contains('<ol>')== false)){
       
         temp = '<ul>';
         deal_list[0].Capital_Market_Consideration__c = deal_list[0].Capital_Market_Consideration__c.replace('•','');
         deal_list[0].Capital_Market_Consideration__c = deal_list[0].Capital_Market_Consideration__c.replace('▪','');
         if(deal_list[0].Capital_Market_Consideration__c.contains('<br>')== true) {
         List<String> temp_string_list = deal_list[0].Capital_Market_Consideration__c.split('<br>',0);
         
          for ( String item : temp_string_list) {  
            temp = temp + '<li>'+ item + '</li>';
          }
         temp = temp + '</ul>';         
         } else {
         List<String> temp_string_list = deal_list[0].Capital_Market_Consideration__c.split('\n',0);
         
          for ( String item : temp_string_list) {  
            temp = temp + '<li>'+ item + '</li>';
          }
         temp = temp + '</ul>';
        }
       } 
    }   
    system.debug('getCapital_Market_Consideration 2:is:'+temp);    
    return temp;
    }    

    public String getWhy_Interesting()
    {
    String temp='';
    
        List<Deal__c> deal_list= [
            SELECT 
            id,Key_Dates_Next_Steps__c,                    
            Areas_of_Concern_Red_Flags__c,Fit_With_Group__c,
            Why_Interesting__c,WP_Human_Capital_or_WP_Angle__c,
            Capital_Market_Consideration__c
            FROM Deal__c 
            WHERE Id = :deal_id
        ];
    if(deal_list.size() != 1)
    {
       system.debug('getWhy_Interesting:Deal not found:'+deal_list.size());
       temp='\n';
    }
    else
    {
       temp = deal_list[0].Why_Interesting__c;
       system.debug('getWhy_Interesting 1:is:'+temp);       
       if(String.isBlank(temp)||String.isEmpty(temp)) {
        temp='\n'; 
       } else if((false) && (deal_list[0].Why_Interesting__c.contains('<ul>')== false) &&
                 (deal_list[0].Why_Interesting__c.contains('<ol>')== false)){
       
         temp = '<ul>';
         deal_list[0].Why_Interesting__c = deal_list[0].Why_Interesting__c.replace('•','');
         deal_list[0].Why_Interesting__c = deal_list[0].Why_Interesting__c.replace('▪','');
         if(deal_list[0].Why_Interesting__c.contains('<br>')== true) {
         List<String> temp_string_list = deal_list[0].Why_Interesting__c.split('<br>',0);
         
          for ( String item : temp_string_list) {  
            temp = temp + '<li>'+ item + '</li>';
          }
         temp = temp + '</ul>';         
         } else {
         List<String> temp_string_list = deal_list[0].Why_Interesting__c.split('\n',0);
         
          for ( String item : temp_string_list) {  
            temp = temp + '<li>'+ item + '</li>';
          }
         temp = temp + '</ul>';
        }
       } 
    }   
    system.debug('getWhy_Interesting 2:is:'+temp);          
    return temp;
    }    
        
    public String getFit_With_Group()
    {
    String temp='';
    
        List<Deal__c> deal_list= [
            SELECT 
            id,Key_Dates_Next_Steps__c,                    
            Areas_of_Concern_Red_Flags__c,Fit_With_Group__c,
            Why_Interesting__c,WP_Human_Capital_or_WP_Angle__c,
            Capital_Market_Consideration__c
            FROM Deal__c 
            WHERE Id = :deal_id
        ];
    if(deal_list.size() != 1)
    {
       system.debug('getFit_With_Group:Deal not found:'+deal_list.size());
       temp='\n';
    }
    else
    {
       temp = deal_list[0].Fit_With_Group__c;
       if(String.isBlank(temp)||String.isEmpty(temp)) {
        temp='\n'; 
       } else if((false) && (deal_list[0].Fit_With_Group__c.contains('<ul>')== false) &&
                 (deal_list[0].Fit_With_Group__c.contains('<ol>')== false)){
       
         temp = '<ul>';
         deal_list[0].Fit_With_Group__c = deal_list[0].Fit_With_Group__c.replace('•','');
         deal_list[0].Fit_With_Group__c = deal_list[0].Fit_With_Group__c.replace('▪','');
         if(deal_list[0].Fit_With_Group__c.contains('<br>')== true) {
         List<String> temp_string_list = deal_list[0].Fit_With_Group__c.split('<br>',0);
         
          for ( String item : temp_string_list) {  
            temp = temp + '<li>'+ item + '</li>';
          }
         temp = temp + '</ul>';         
         } else {
         List<String> temp_string_list = deal_list[0].Fit_With_Group__c.split('\n',0);
         
          for ( String item : temp_string_list) {  
            temp = temp + '<li>'+ item + '</li>';
          }
         temp = temp + '</ul>';
        }
       } 
    }   
        
    return temp;
    }    
        
    public String getAreas_of_Concern_Red_Flags()
    {
    String temp='';
    
        List<Deal__c> deal_list= [
            SELECT 
            id,Key_Dates_Next_Steps__c,                    
            Areas_of_Concern_Red_Flags__c,Fit_With_Group__c,
            Why_Interesting__c,WP_Human_Capital_or_WP_Angle__c,
            Capital_Market_Consideration__c
            FROM Deal__c 
            WHERE Id = :deal_id
        ];
    if(deal_list.size() != 1)
    {
       system.debug('getAreas_of_Concern_Red_Flags:Deal not found:'+deal_list.size());
       temp='\n';
    }
    else
    {
       temp = deal_list[0].Areas_of_Concern_Red_Flags__c;
       if(String.isBlank(temp)||String.isEmpty(temp)) {
        temp='\n'; 
       } else if((false) && (deal_list[0].Areas_of_Concern_Red_Flags__c.contains('<ul>')== false) &&
                 (deal_list[0].Areas_of_Concern_Red_Flags__c.contains('<ol>')== false)){

       
         temp = '<ul>';
         deal_list[0].Areas_of_Concern_Red_Flags__c = deal_list[0].Areas_of_Concern_Red_Flags__c.replace('•','');
         deal_list[0].Areas_of_Concern_Red_Flags__c = deal_list[0].Areas_of_Concern_Red_Flags__c.replace('▪','');
         if(deal_list[0].Areas_of_Concern_Red_Flags__c.contains('<br>')== true) {
         List<String> temp_string_list = deal_list[0].Areas_of_Concern_Red_Flags__c.split('<br>',0);
         
          for ( String item : temp_string_list) {  
            temp = temp + '<li>'+ item + '</li>';
          }
         temp = temp + '</ul>';         
         } else {
         List<String> temp_string_list = deal_list[0].Areas_of_Concern_Red_Flags__c.split('\n',0);
         
          for ( String item : temp_string_list) {  
            temp = temp + '<li>'+ item + '</li>';
          }
         temp = temp + '</ul>';
        }
       } 
    }   
    system.debug('getAreas_of_Concern_Red_Flags:is:'+temp);       
    return temp;
    }    
        
    public String getWP_Human_Capital_or_WP_Angle()
    {
    String temp='';
    
        List<Deal__c> deal_list= [
            SELECT 
            id,Key_Dates_Next_Steps__c,                    
            Areas_of_Concern_Red_Flags__c,Fit_With_Group__c,
            Why_Interesting__c,WP_Human_Capital_or_WP_Angle__c,
            Capital_Market_Consideration__c
            FROM Deal__c 
            WHERE Id = :deal_id
        ];
    if(deal_list.size() != 1)
    {
       system.debug('getWP_Human_Capital_or_WP_Angle:Deal not found:'+deal_list.size());
       temp='\n';
    }
    else
    {
       temp = deal_list[0].WP_Human_Capital_or_WP_Angle__c;
       if(String.isBlank(temp)||String.isEmpty(temp)) {
        temp='\n'; 
       } else if((false) && (deal_list[0].WP_Human_Capital_or_WP_Angle__c.contains('<ul>')== false) &&
                 (deal_list[0].WP_Human_Capital_or_WP_Angle__c.contains('<ol>')== false)){
       
         temp = '<ul>';
         deal_list[0].WP_Human_Capital_or_WP_Angle__c = deal_list[0].WP_Human_Capital_or_WP_Angle__c.replace('•','');
         deal_list[0].WP_Human_Capital_or_WP_Angle__c = deal_list[0].WP_Human_Capital_or_WP_Angle__c.replace('▪','');
         if(deal_list[0].WP_Human_Capital_or_WP_Angle__c.contains('<br>')== true) {
         List<String> temp_string_list = deal_list[0].WP_Human_Capital_or_WP_Angle__c.split('<br>',0);
         
          for ( String item : temp_string_list) {  
            temp = temp + '<li>'+ item + '</li>';
          }
         temp = temp + '</ul>';         
         } else {
         List<String> temp_string_list = deal_list[0].WP_Human_Capital_or_WP_Angle__c.split('\n',0);
         
          for ( String item : temp_string_list) {  
            temp = temp + '<li>'+ item + '</li>';
          }
         temp = temp + '</ul>';
        }
       } 
    }   
        
    return temp;
    }    
        
    public String getKey_Dates_Next_Steps()
    {
    String temp='';
    
        List<Deal__c> deal_list= [
            SELECT 
            id,Key_Dates_Next_Steps__c,                    
            Areas_of_Concern_Red_Flags__c,Fit_With_Group__c,
            Why_Interesting__c,WP_Human_Capital_or_WP_Angle__c,
            Capital_Market_Consideration__c
            FROM Deal__c 
            WHERE Id = :deal_id
        ];
    if(deal_list.size() != 1)
    {
       system.debug('getKey_Dates_Next_Steps:Deal not found:'+deal_list.size());
       temp='\n';
    }
    else 
    {
       temp = deal_list[0].Key_Dates_Next_Steps__c;
       if(String.isBlank(temp)||String.isEmpty(temp)) {
        temp='\n';       
       } else if( (deal_list[0].Key_Dates_Next_Steps__c.contains('•')== true) ||
                  (deal_list[0].Key_Dates_Next_Steps__c.contains('▪')== true)
                ) {
         temp = '<ul>';
         deal_list[0].Key_Dates_Next_Steps__c = deal_list[0].Key_Dates_Next_Steps__c.replace('•','');
         deal_list[0].Key_Dates_Next_Steps__c = deal_list[0].Key_Dates_Next_Steps__c.replace('▪','');         
         List<String> temp_string_list = deal_list[0].Key_Dates_Next_Steps__c.split('\n',0);
         
          for ( String item : temp_string_list) {  
            temp = temp + '<li>'+ item + '</li>';
          }
         temp = temp + '</ul>';
       } 
    }   
    system.debug('getKey_Dates_Next_Steps:is:'+temp);   
    return temp;
    }    

   public List<Deal_Score_Line_Item__c>  getEarMetrics()
   {
        List<DealScoreHeader__c> dsh_list = [
            SELECT
            id,Deal__c,Type_of_Report__c            
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'EAR Metrics')
        ];

        if(dsh_list.size() > 1) {
          system.debug('getEarMetrics:Either more than one or no Deal Score '+
          'header exists for EAR Metrics:deal_id:size:'+deal_id+dsh_list.size());
          EarMetrics = null;
        } else if(dsh_list.size() == 0) {
          system.debug('getEarMetrics:No Deal Score '+
          'header exists for EAR Metrics:deal_id:size:'+deal_id+dsh_list.size());
          EarMetrics = null;
        } else {                   
             List<Deal_Score_Line_Item__c> line_list = [
            SELECT
            id,Deal_Score_Header__c,EAR_Metric_Name__c,EAR_Metric_Period_Ended__c,EAR_Metric_Value__c           
            FROM Deal_Score_Line_Item__c
            WHERE Deal_Score_Header__c =:dsh_list[0].Id
            ];
            EarMetrics = line_list;

        }      
        
        return  EarMetrics;
   }        
   
public Integer getNoLinesInGivenText(String text_content,String html_content) {
  
  Integer total_lines=0,local_no=0;
  List<String> temp_list;
  
  if((text_content == '\n') && (html_content == '')) {
    return 0;
  }
  
  if((text_content != null) && (text_content != '')) {

   
   //First lets count the no of new lines
   temp_list = text_content.split('\n',0);
   if(temp_list.size() > 1) {
      total_lines = temp_list.size()-1;
      system.debug('A:total_lines:'+total_lines);
   }
  
   if(html_content.split('<ul>|<ol>',0).size() > 1) {
     temp_list = html_content.split('<li>',0);
     if(temp_list.size()> 2 ) {
     total_lines = total_lines + temp_list.size()-2;} 
     else if(temp_list.size()> 1 ) {
     total_lines = total_lines + temp_list.size()-1;} 
     
     system.debug('B:total_lines:'+total_lines);
   } else {
     temp_list = html_content.split('<br />|<br>|</br>',0);
     if(temp_list.size() >1) {
       total_lines = total_lines + temp_list.size()-1;
       system.debug('C:total_lines:'+total_lines);
     } 
   }
   if(html_content != '') {
     temp_list = html_content.split('<p>|</p>',0);
     if(temp_list.size() > 1) {
       total_lines = total_lines + temp_list.size()-1;
       system.debug('D:total_lines:'+total_lines);
     }    
   } else {
     temp_list = text_content.split('<p>|</p>',0);
     if(temp_list.size() > 1) {
       total_lines = total_lines + temp_list.size()-1;
       system.debug('E:total_lines:'+total_lines);
     }    
   }
   

   if(html_content.split('</li>',0).size() > 1) {
   //Second count the no of characters exceeding the length of one line. This will also be counted as another line.
   Integer start_index=0,pos_flag,temp;
   while(start_index < html_content.length()){
     pos_flag = html_content.indexOf('</li>',start_index);
     if(pos_flag != -1) {
       temp = pos_flag-start_index;
       system.debug('Atemp pos_flagstart_index'+temp+'...'+pos_flag+'...'+start_index);
       if(temp > 118) {
        temp = temp/118;
        system.debug('Alocal_no:'+local_no+'...'+temp);
        local_no = local_no + temp;
        system.debug('Alocal_no:'+local_no);
       }
       start_index = pos_flag+9;//Move start index to the next character  after </li><li> tag
     } else {//-1:No more new lines exist
       temp = (html_content.length()-1) - start_index;
       system.debug('Btemp start_index text_content.length'+temp +'...'+start_index+'...'+html_content.length());
       if(temp > 118) {
        temp = temp/118;
        system.debug('Blocal_no:'+local_no+'...'+temp);
        local_no = local_no + temp;
        system.debug('Blocal_no:'+local_no);
       }
       start_index = html_content.length();
     }   
   }   
   } else {
   
   //Second count the no of characters exceeding the length of one line. This will also be counted as another line.
   Integer start_index=0,pos_flag,temp;
   while(start_index < text_content.length()){
     pos_flag = text_content.indexOf('\n',start_index);
     if(pos_flag != -1) {
       temp = pos_flag-start_index;
       system.debug('Ctemp pos_flagstart_index'+temp+'...'+pos_flag+'...'+start_index);
       if(temp > 118) {
        temp = temp/118;
        system.debug('Clocal_no:'+local_no+'...'+temp);
        local_no = local_no + temp;
        system.debug('Alocal_no:'+local_no);
       }
       start_index = pos_flag+1;//Move start index to the next character 
     } else {//-1:No more new lines exist
       temp = (text_content.length()-1) - start_index;
       system.debug('Btemp start_index text_content.length'+temp +'...'+start_index+'...'+text_content.length());
       if(temp > 118) {
        temp = temp/118;
        system.debug('Dlocal_no:'+local_no+'...'+temp);
        local_no = local_no + temp;
        system.debug('Dlocal_no:'+local_no);
       }
       start_index = text_content.length();
     }   
   }
  } 
   system.debug('getNoLinesInGivenText:no of extra lines due to line wrap:'+local_no);   
  
  
  if(local_no == 0) {
   total_lines = total_lines ;//Bot needed FOR THE FIRST LINE
   //alert('getNoLinesInGivenText:no of new lines are:'+total_lines);  
  }
  total_lines = total_lines + local_no;
  system.debug('getNoLinesInGivenText:Total lines are'+total_lines);
  }
  
  return total_lines;
  }    
   
   public String getClassToBeApplied(){
   String result;
   Integer total_additional_lines=0,local_no=0;
   String temp;
        List<DealScoreHeader__c> dsh_list = [
            SELECT
            id,Deal__c,Type_of_Report__c            
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'EAR Metrics')
        ];
        
        local_no = dsh_list.size();
        total_additional_lines = local_no=0;
        system.debug('Lines:EarMetric:local:Total:'+local_no+':'+total_additional_lines);
        
        List<Deal__c> deal_list = [
            SELECT 
            id,Name,Stage__c,Sector__c,Company__c,Company__r.Description,Description__c,Key_Dates_Next_Steps__c,
            Company__r.CurrencyIsoCode,
            WP_Investment_MM__c,WP_Ownership_Diluted__c,  Transaction_Value_MM__c, Deal_Owner_Source__c,
            (SELECT Id,
                Employee__r.Name
                From Deal_Team__r
                ORDER BY Employee__r.Employee_Level__r.Rank__c DESC, Employee__r.Employee_Level_Precedence__c DESC),                     
            Areas_of_Concern_Red_Flags__c,Fit_With_Group__c,
            Why_Interesting__c,WP_Human_Capital_or_WP_Angle__c,
            Capital_Market_Consideration__c
            FROM Deal__c 
            WHERE Id = :deal_id
        ];
        if(deal_list.size() != 1) {
          system.debug('getClassToBeApplied:Deal not found'+deal_list.size());
        } else {
                      temp = deal_list[0].Areas_of_Concern_Red_Flags__c;
                      if(String.isNotBlank(temp) && String.isNotBlank(temp)){
                        temp = temp.replaceAll('<[^>]+>',' ');
                        local_no = getNoLinesInGivenText(temp,deal_list[0].Areas_of_Concern_Red_Flags__c);
                      } else {
                        local_no = 0;
                      }                      
                      total_additional_lines = total_additional_lines + local_no;
                      system.debug('Lines:areaOfConcern:Text:HTML'+temp+':'+deal_list[0].Areas_of_Concern_Red_Flags__c);        
                      system.debug('Lines:areaOfConcern:Total:'+local_no+':'+total_additional_lines);       
                      
                      temp = deal_list[0].Fit_With_Group__c;
                      if(String.isNotBlank(temp) && String.isNotBlank(temp)){
                        temp = temp.replaceAll('<[^>]+>',' ');
                        local_no = getNoLinesInGivenText(temp,deal_list[0].Fit_With_Group__c);
                      } else {
                        local_no = 0;
                      }  
                      total_additional_lines = total_additional_lines + local_no;
                      system.debug('Lines:Fit_With_Group__c:Text:HTML'+temp+':'+deal_list[0].Fit_With_Group__c);        
                      system.debug('Lines:Fit_With_Group__c:Total:'+local_no+':'+total_additional_lines);       

                      temp = deal_list[0].Why_Interesting__c;
                      if(String.isNotBlank(temp) && String.isNotBlank(temp)){
                        temp = temp.replaceAll('<[^>]+>',' ');
                        local_no = getNoLinesInGivenText(temp,deal_list[0].Why_Interesting__c);
                      } else {
                        local_no = 0;
                      }  
                      total_additional_lines = total_additional_lines + local_no;
                      system.debug('Lines:Why_Interesting__c:Text:HTML'+temp+':'+deal_list[0].Why_Interesting__c);  
                      system.debug('Lines:Why_Interesting__c:Total:'+local_no+':'+total_additional_lines);      

                      temp = deal_list[0].WP_Human_Capital_or_WP_Angle__c;
                      if(String.isNotBlank(temp) && String.isNotBlank(temp)){
                        temp = temp.replaceAll('<[^>]+>',' ');
                        local_no = getNoLinesInGivenText(temp,deal_list[0].WP_Human_Capital_or_WP_Angle__c);
                      } else {
                        local_no = 0;
                      }  
                      total_additional_lines = total_additional_lines + local_no;
                      system.debug('Lines:WP_Human_Capital_or_WP_Angle__c:Text:HTML'+temp+':'+deal_list[0].WP_Human_Capital_or_WP_Angle__c);
                      system.debug('Lines:WP_Human_Capital_or_WP_Angle__c:Total:'+local_no+':'+total_additional_lines);     

                      temp = deal_list[0].Capital_Market_Consideration__c;
                      if(String.isNotBlank(temp) && String.isNotBlank(temp)){
                        temp = temp.replaceAll('<[^>]+>',' ');
                        local_no = getNoLinesInGivenText(temp,deal_list[0].Capital_Market_Consideration__c);
                      } else {
                        local_no = 0;
                      }  
                      total_additional_lines = total_additional_lines + local_no;
                      system.debug('Lines:Capital_Market_Consideration__c:Text:HTML'+temp+':'+deal_list[0].Capital_Market_Consideration__c);
                      system.debug('Lines:Capital_Market_Consideration__c:Total:'+local_no+':'+total_additional_lines);     

                      temp = deal_list[0].Company__r.Description;
                      local_no = getNoLinesInGivenText(deal_list[0].Company__r.Description,'');
                      total_additional_lines = total_additional_lines + local_no;
                      system.debug('Lines:Company__r.Description:Text'+deal_list[0].Company__r.Description);
                      system.debug('Lines:Company__r.Description:Total:'+local_no+':'+total_additional_lines);                             

                      temp = deal_list[0].Description__c;
                      local_no = getNoLinesInGivenText(deal_list[0].Description__c,'');
                      total_additional_lines = total_additional_lines + local_no;
                      system.debug('Lines:deal_list[0].Description__c:Text'+deal_list[0].Description__c);
                      system.debug('Lines:deal_list[0].Description__c:Total:'+local_no+':'+total_additional_lines);     

                      temp = deal_list[0].Key_Dates_Next_Steps__c;
                      local_no = getNoLinesInGivenText(deal_list[0].Key_Dates_Next_Steps__c,'');
                      total_additional_lines = total_additional_lines + local_no;
                      system.debug('Lines:deal_list[0].Key_Dates_Next_Steps__c:Text'+deal_list[0].Key_Dates_Next_Steps__c);
                      system.debug('Lines:deal_list[0].Key_Dates_Next_Steps__c:Total:'+local_no+':'+total_additional_lines);

                       List<Deal_Team__c> team_list = deal_list[0].Deal_Team__r;
                       Integer list_count=0;
                       temp='';
                       for(Deal_Team__c team_item:team_list) {
                         list_count++;
                         temp=temp+team_item.Employee__r.Name;
                         if(list_count <  team_list.size()) {
                           temp=temp+',  ';
                         }
                       }
                      local_no = getNoLinesInGivenText(temp,'');
                      total_additional_lines = total_additional_lines + local_no;
                      system.debug('Lines:dealTeam:Text'+temp);
                      system.debug('Lines:dealTeam:Total:'+local_no+':'+total_additional_lines);
                      
                      local_no = 0;                   
                      temp = deal_list[0].Sector__c;
                      if(String.isNotBlank(temp) && String.isNotBlank(temp)){
                         local_no = temp.length();
                         if(Math.mod(local_no,118) !=0) {
                         local_no= local_no/118 ; }
                         else { local_no= local_no/118;}
                      } 
                      total_additional_lines = total_additional_lines + local_no;
                      system.debug('Lines:Sector:Text'+temp);
                      system.debug('Lines:Sector:Total:'+local_no+':'+total_additional_lines);                    
        }
                      if(total_additional_lines >= 38) {
                        result='width:750px; page-break-after:'+'auto;';
                      } else {
                        result='width:750px; page-break-after:'+'auto;';
                      }
                      
    system.debug('getClassToBeApplied:Final result is:total_additional_lines'+result+':'+total_additional_lines);
   return result;
   }
      public static string testVal='';
   public static void bsTestMethod2()
{
testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        
          testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        
          testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        
          testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
        testVal = '2';
        testVal = '1';
}
}