public with sharing class dcr_scorecard_pdf_page_controller {
    String deal_id;
    String sch_id;
    String DealTeam;
    String WPSeats;
    String WPSeatsTotal;
    String WPSeatsBoth;
    String WPOwnership;
    String OtherConsider;
    String TeamRecommend;
    String Sector;
    List<String> Investment_Thesis{get; set;}
    List<String> Investment_Risks{get; set;}
    List<String> Key_Value_Creation_Drivers{get; set;}
    List<String> Key_Company_Goals_and_Milestones{get; set;}
    List<String> Management_Team_and_Board_Additions_and_or_Development_Goals{get; set;}
    List<String> WP_Team_Action_Items{get; set;}
    //List<DCR_Metric_Info> DcrMetrics{get; set;}
    List<String> Financial_Targets{get; set;}
    
    public dcr_scorecard_pdf_page_controller(ApexPages.StandardController controller) {
      this.deal_id= ((Deal__c)controller.getRecord()).Id;
      this.sch_id= System.currentPagereference().getParameters().get('sch_id');
      this.DealTeam='';  
      this.WPSeats='';
      this.WPSeatsTotal='';
      this.WPSeatsBoth='';
      this.WPOwnership='';
      this.OtherConsider='';
      this.TeamRecommend='';
      this.Sector='';
      this.Investment_Thesis= new List<String>();
      this.Investment_Thesis.clear();

      this.Investment_Risks= new List<String>();
      this.Investment_Risks.clear();

      this.Key_Value_Creation_Drivers= new List<String>();
      this.Key_Value_Creation_Drivers.clear();

      this.Key_Company_Goals_and_Milestones= new List<String>();
      this.Key_Company_Goals_and_Milestones.clear();

      this.Management_Team_and_Board_Additions_and_or_Development_Goals= new List<String>();
      this.Management_Team_and_Board_Additions_and_or_Development_Goals.clear();

      this.WP_Team_Action_Items= new List<String>();
      this.WP_Team_Action_Items.clear();
      
      this.Financial_Targets= new List<String>();
      this.Financial_Targets.clear();
      
      //this.DcrMetrics = new List<DCR_Metric_Info>();
      //this.DcrMetrics.clear();
      system.debug('dcr_sample_pdf_page_controller:deal_id:sch_id:'+deal_id+':'+sch_id);
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
    public String isNull (String myValue){
        String newValue='';
        if (myValue!=null){
                newValue = myValue;
        }
        return newValue;
    }    
    public String maskField (String fieldValue){
        Integer fieldWidth=0;
        String newValue ='';
        Integer maskWidth=10;
                Integer count=0;
        Integer countTotal=0;
                
        fieldWidth = fieldValue.length();
        countTotal = maskWidth-fieldWidth;              
                do {
                        newValue = newValue + '&nbsp;&nbsp;';
                        count++;
                } while (count < countTotal);
                newValue = newValue + fieldValue;
        return newValue;
    }
    public String getOtherConsider() {
                String otherConsider='';    
            List<DealScoreHeader__c> deal_hdr = [
                SELECT id,Date_Received__c,Type_of_Report__c,OtherConsiderations__c
                FROM DealScoreHeader__c
                WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Follow Up' )
                ];                
                    if(deal_hdr.size() != 1){
                       system.debug('otherConsider:Deal not found:'+deal_hdr.size());
                       otherConsider='\n';
                    }
                    else{
                        if(deal_hdr.size() == 1) {
                        DealScoreHeader__c header_item = deal_hdr[0];
                        system.debug('Followup Header exists, now get :'+ header_item);
                        otherConsider = String.valueOf(header_item.OtherConsiderations__c);  
                }     
                    }    
                return otherConsider;
    }
    public String getTeamRecommend() {
                String teamRecommend='';    
            List<DealScoreHeader__c> deal_hdr = [
                SELECT
                id,Date_Received__c,Type_of_Report__c,TeamRecommendations__c
                FROM DealScoreHeader__c
                WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Follow Up' )
                ];                
                    if(deal_hdr.size() != 1){
                       system.debug('teamRecommend:Deal not found:'+deal_hdr.size());
                       teamRecommend='\n';
                    }
                    else{
                        if(deal_hdr.size() == 1) {
                        DealScoreHeader__c header_item = deal_hdr[0];
                        system.debug('Followup Header exists, now get :'+ header_item);
                        teamRecommend = String.valueOf(header_item.TeamRecommendations__c);  
                }     
                    }    
                return teamRecommend;
    }
    public String getWPSeats() {
                String wpString='';    
            List<DealScoreHeader__c> deal_hdr = [
                SELECT
                id,Date_Received__c,Type_of_Report__c,WP_Board_Seats__c
                FROM DealScoreHeader__c
                WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Copy' )
                ];                
                    if(deal_hdr.size() != 1){
                       system.debug('getWPSeats:Deal not found:'+deal_hdr.size());
                       wpString='\n';
                    }
                    else{
                        if(deal_hdr.size() == 1) {
                        DealScoreHeader__c header_item = deal_hdr[0];
                        system.debug('Closing Header exists, now get :'+ header_item);
                        wpString = String.valueOf(header_item.WP_Board_Seats__c);  
                }     
                    }    
                return wpString;
    }
    public String getWPSeatsTotal() {
                String wpString='';    
            List<DealScoreHeader__c> deal_hdr = [
                SELECT
                id,Date_Received__c,Type_of_Report__c,WP_Board_Seats__c,WP_Board_Seats_Total__c
                FROM DealScoreHeader__c
                WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Copy' )
                ];                
                    if(deal_hdr.size() != 1){
                       system.debug('getWPSeats:Deal not found:'+deal_hdr.size());
                       wpString='\n';
                    }
                    else{
                        if(deal_hdr.size() == 1) {
                        DealScoreHeader__c header_item = deal_hdr[0];
                        system.debug('Closing Header exists, now get :'+ header_item);
                        wpString = String.valueOf(header_item.WP_Board_Seats_Total__c);  
                }     
                    }    
                return wpString;
    }    
    public String getWPSeatsBoth() {
                String wpString='';    
            List<DealScoreHeader__c> deal_hdr = [
                SELECT
                id,Date_Received__c,Type_of_Report__c,WP_Board_Seats__c,WP_Board_Seats_Total__c
                FROM DealScoreHeader__c
                WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Copy' )
                ];                
                    if(deal_hdr.size() != 1){
                       system.debug('getWPSeats:Deal not found:'+deal_hdr.size());
                       wpString='\n';
                    }
                    else{
                        if(deal_hdr.size() == 1) {
                        DealScoreHeader__c header_item = deal_hdr[0];
                        system.debug('Closing Header exists, now get :'+ header_item);
                        if (header_item.WP_Board_Seats_Total__c==null){
                                wpString = String.valueOf(header_item.WP_Board_Seats__c);  
                        }else{
                                wpString = String.valueOf(header_item.WP_Board_Seats__c) + ' of ' + String.valueOf(header_item.WP_Board_Seats_Total__c); 
                        }
                        
                }     
                    }    
                return wpString;
    } 
    public String getWPOwnership() {
                String wpString='';    
            List<DealScoreHeader__c> deal_hdr = [
                SELECT
                id,Date_Received__c,Type_of_Report__c,WP_Ownership_Fully_Diluted__c
                FROM DealScoreHeader__c
                WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Copy' )
                ];                
                    if(deal_hdr.size() != 1){
                       system.debug('getWPSeats:Deal not found:'+deal_hdr.size());
                       wpString='\n';
                    }
                    else{
                        if(deal_hdr.size() == 1) {
                        DealScoreHeader__c header_item = deal_hdr[0];
                        system.debug('Closing Header exists, now get :'+ header_item);
                        if (header_item.WP_Ownership_Fully_Diluted__c==null){
                                wpString = '';  
                        }else{
                                wpString = String.valueOf(header_item.WP_Ownership_Fully_Diluted__c); 
                        }
                        
                }     
                    }    
                return wpString;
    }    
    public String getDealTeam() {
    String deal_team_string='';
    
    List<Deal__c> deal_list =  [        
            SELECT 
            id,
            (SELECT Id,
                Employee__r.Name, Employee__r.Employee_Level__r.Rank__c,
                Employee__r.ISSENIORTEAMMEMBER__c, 
                Employee__r.Employee_Level_Precedence_Sorter__c, Role__c
                From Deal_Team__r
                                ORDER By Employee__r.Employee_Level__r.Rank__c DESC NULLS LAST,Role__c ASC NULLS LAST, Employee__r.Employee_Level_Precedence_Sorter__c DESC NULLS LAST)
            FROM Deal__c 
            WHERE Id =:deal_id];
                    if(deal_list.size() != 1){
                       system.debug('getDealTeam:Deal not found:'+deal_list.size());
                       deal_team_string='\n';
                    }
                    else{
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
    
    public String getSector() {
        String sector_string='';
        List<Deal__c> deal_list =  [        
            SELECT 
            id,Sector__c
            FROM Deal__c 
            WHERE Id =:deal_id];
                    if(deal_list.size() != 1){
                       system.debug('getSector:Deal not found:'+deal_list.size());
                       sector_string='\n';
                    }
                    else{
                           sector_string = deal_list[0].Sector__c;
                           sector_string = sector_string.replace(';','; ');
                       if(String.isBlank(sector_string)||String.isEmpty(sector_string)) {
                         sector_string='\n';
                       }       
                    }       
                return sector_string;
    }              
    
    public List<String> getFinancial_Targets()
    {
        String OneRowValue ='';
        String FollowupValue='';
        String OneRowColor ='';
        String oldFinMetrixName='';
        String newFinMetrixName='';
        String followupString='';
        String negativeValue='';
        String targetValue='';
        Integer upIndex=0;
        Integer targetIndex=0;
        String metricUnit='';
        
        if((deal_id == null) || (sch_id ==null)){
          return Financial_Targets;
        }        
        List<Deal__c> deal = [
            SELECT
            id,Name       
            FROM Deal__c
            WHERE Id = :deal_id
        ];
        List<DealScoreHeader__c> deal_hdr_list = [
            SELECT id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE Deal__c=:deal_id AND Type_of_Report__c='Copy'];
        
                if(deal_hdr_list.size()==1){
                        sch_id = deal_hdr_list[0].Id;
                } 
        if((deal.size() ==0) || (deal.size() !=1)) {
          system.debug('getFinancial_Targets:Invalid deal id received..returning null');
          return null;
        }        
        if((deal_hdr_list.size() ==0) || (deal_hdr_list.size() !=1)) {
          system.debug('getFinancial_Targets:Invalid score header id received..returning null');
          return null;
        }
        if((deal_hdr_list[0].Deal__c!=deal_id)||((deal_hdr_list[0].Type_of_Report__c != 'Copy') && (deal_hdr_list[0].Type_of_Report__c != 'Closing') && (deal_hdr_list[0].Type_of_Report__c != 'Follow Up'))) {
          system.debug('getFinancial_Targets:Invalid elements in score header ..returning null');
          return null;      
        }        
        List<Deal_Score_Line_Item__c> closing_list = [
          SELECT Id,CreatedDate,LastModifiedDate,Line_Item_Order__c,Is_Financial_Metric_Imported__c,
                 Deal_Score_Header__c, Line_Item_Color__c,Line_Item_Title__c,Financial_Metric_Period_Ended__c,
                 Financial_Metric_Name__c,Financial_Metric_Period_Text__c,Financial_Metric_Value__c,Financial_Metric_Unit__c
          FROM Deal_Score_Line_Item__c
          WHERE Deal_Score_Header__c =:sch_id AND Line_Item_Title__c='Financial Metric'
          ORDER BY Is_Financial_Metric_Imported__c DESC, Financial_Metric_Name__c ASC, Financial_Metric_Period_Ended__c ASC];         
          
          for(Deal_Score_Line_Item__c citem :closing_list) {
           OneRowValue='';
           OneRowColor='customTableRowWhite';
           FollowupValue = '&nbsp;';
           negativeValue='';
           targetValue='';
           upIndex =0;
           targetIndex=0;
           metricUnit='';
           if(citem.Line_Item_Title__c == 'Financial Metric') {     
                 //Now - fetch the related id and get the value
                 List<Deal_Score_Line_Item__c> followup_item = [
                 SELECT Id,Related_Score_Line_Item_Id__c,Financial_Metric_Name__c,Financial_Metric_Period_Text__c,
                        Financial_Metric_Value__c,Line_Item_Color__c
                 FROM Deal_Score_Line_Item__c
                 WHERE Related_Score_Line_Item_Id__c =:citem.Id];
                 system.debug('getFinancial_Targets:Related_Score_Line_Item_Id__c=>'+ citem.Id + ' sch_id=' + sch_id);
                 
                 if (followup_item.size()==1){
                        if (followup_item[0].Line_Item_Color__c=='#ebf1de'){
                                OneRowColor = 'customTableRowPink';
                        }
                        if(followup_item[0].Line_Item_Color__c=='#f2dcdb'){
                                OneRowColor = 'customTableRowGreen';
                        }
                        //citem
                        targetValue = String.valueOf(citem.Financial_Metric_Value__c);
                        targetValue = targetValue.replace('.00','');
                        targetIndex  = targetValue.indexOf('-');
                        if (targetIndex != -1){
                                targetValue = targetValue.replace('-','');
                                targetValue = '('+ targetValue +')';
                        }else{
                                targetValue = targetValue;
                        }                               
                        
                        if (followup_item[0].Financial_Metric_Value__c==null || followup_item[0].Financial_Metric_Value__c==''){
                                FollowupValue = '&nbsp;';
                        }else{
                                negativeValue = String.valueOf(followup_item[0].Financial_Metric_Value__c);
                                negativeValue = negativeValue.replace('.00','');
                                upIndex  = negativeValue.indexOf('-');
                                if (upIndex != -1){
                                        negativeValue = negativeValue.replace('-','');
                                        FollowupValue = '('+ negativeValue +')';
                                }else{
                                        FollowupValue = negativeValue;
                                }                               
                        }
                        newFinMetrixName = citem.Financial_Metric_Name__c + ':';
                        metricUnit = citem.Financial_Metric_Unit__c;
                        if (newFinMetrixName==oldFinMetrixName){
                                newFinMetrixName = '';
                                OneRowValue = '<tr class=\'' + OneRowColor + '\'>' +
                                '<td class=\'financialTableRowLeftTopNone\'>' + newFinMetrixName +'</td>' +
                                '<td class=\'financialTableRowCenterNone\'>'    + citem.Financial_Metric_Period_Text__c + '</td>' +
                                '<td class=\'financialTableRowRight\'>'  + targetValue +'</td>' +
                                '<td class=\'financialTableRowCenterNone\'>'  + metricUnit +'</td>' +                               
                                '<td class=\'financialTableRowLeftTopNone\'>' + newFinMetrixName +'</td>' +
                                '<td class=\'financialTableRowCenterNone\'>'    + citem.Financial_Metric_Period_Text__c +'</td>' +
                                '<td class=\'financialTableRowRight\'>'      + FollowupValue +'</td>' +
                                '<td class=\'financialTableRowCenterNone\'>'  + metricUnit +'</td></tr>';                             
                        }else{
                                OneRowValue = '<tr class=\'' + OneRowColor + '\'>' +
                                '<td class=\'financialTableRowLeftTop topbar\' >' + newFinMetrixName +'</td>' +
                                '<td class=\'financialTableRowCenter topbar\' >'  + citem.Financial_Metric_Period_Text__c +'</td>' +
                                '<td class=\'financialTableRowRight topbar\'>'  + targetValue + '</td>' +
                                '<td class=\'financialTableRowCenter topbar\'>'  + metricUnit + '</td>' +
                                '<td class=\'financialTableRowLeftTop topbar\'>' + newFinMetrixName +'</td>' +
                                '<td class=\'financialTableRowCenter topbar\'>'    + citem.Financial_Metric_Period_Text__c +'</td>' +
                                '<td class=\'financialTableRowRight topbar\'>'  + FollowupValue +'</td>' +
                                '<td class=\'financialTableRowCenter topbar\'>'  + metricUnit +'</td></tr>';
                        }
                 }//end of size i.e. no followup rec found     
                 Financial_Targets.add(OneRowValue);         
                 oldFinMetrixName = newFinMetrixName;    
           }//end of Line_Item_Title__c
           else {
             system.debug('getFinancial_Targets:ignore item->' + citem.Id);
          }           
        }//for end
            system.debug('getFinancial_Targets:Final list is:size:list'+Financial_Targets.size());
        return Financial_Targets;
    }   
    
    public List<String> getInvestment_Thesis()
    {
        String OneRowValue ='';
        String FollowupValue='';
        String OneRowColor ='';
        
        if((deal_id == null) || (sch_id ==null)){
          return Investment_Thesis;
        }        
        List<Deal__c> deal = [
            SELECT
            id,Name       
            FROM Deal__c
            WHERE Id = :deal_id
        ];
        List<DealScoreHeader__c> deal_hdr_list = [
            SELECT id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE Deal__c=:deal_id AND Type_of_Report__c='Follow Up'];
        
                if(deal_hdr_list.size()==1){
                        sch_id = deal_hdr_list[0].Id;
                } 
        if((deal.size() ==0) || (deal.size() !=1)) {
          system.debug('getInvestment_Thesis:Invalid deal id received..returning null');
          return null;
        }        
        if((deal_hdr_list.size() ==0) || (deal_hdr_list.size() !=1)) {
          system.debug('getInvestment_Thesis:Invalid score header id received..returning null');
          return null;
        }
        if((deal_hdr_list[0].Deal__c!=deal_id)||((deal_hdr_list[0].Type_of_Report__c != 'Copy') && (deal_hdr_list[0].Type_of_Report__c != 'Closing') && (deal_hdr_list[0].Type_of_Report__c != 'Follow Up'))) {
          system.debug('getInvestment_Thesis:Invalid elements in score header ..returning null');
          return null;      
        }        
        
        List<Deal_Score_Line_Item__c> followup_list = [
          SELECT Id,Line_Item_Order__c,Deal_Score_Header__c,Related_Score_Line_Item_Id__c, Line_Item_Color__c,Line_Item_Title__c,Line_Item_Value__c 
          FROM Deal_Score_Line_Item__c
          WHERE Deal_Score_Header__c =:sch_id
          ORDER BY Line_Item_Order__c ASC];         
          
         if (followup_list.size()>0){
                for(Deal_Score_Line_Item__c citem :followup_list) {
                        OneRowValue='';
                        OneRowColor='customTableRowWhite';
                        FollowupValue = '&nbsp;';
                        if(citem.Line_Item_Title__c == 'Investment Thesis') {     
                                //Now - fetch the related id and get the value
                                List<Deal_Score_Line_Item__c> copy_item = [
                                SELECT Id,Line_Item_Value__c,Line_Item_Color__c,Related_Score_Line_Item_Id__c
                                FROM Deal_Score_Line_Item__c
                                WHERE Id =:citem.Related_Score_Line_Item_Id__c];
                                system.debug('getInvestment_Thesis:Related_Score_Line_Item_Id__c=>'+ citem.Id + ' sch_id=' + sch_id);
                                if (copy_item.size()==1){
                                        if (citem.Line_Item_Color__c=='#ebf1de'){
                                                OneRowColor = 'customTableRowPink';
                                        }
                                        if(citem.Line_Item_Color__c=='#f2dcdb'){
                                                OneRowColor = 'customTableRowGreen';
                                        }
                                        if (citem.Line_Item_Value__c==null || citem.Line_Item_Value__c==''){
                                                FollowupValue = '&nbsp;';
                                        }else{
                                                FollowupValue = citem.Line_Item_Value__c;
                                        }
                                        OneRowValue = '<tr class=\'' + OneRowColor + '\'><td class=\'reportTD\'><ul><li>' + copy_item[0].Line_Item_Value__c + '</ul></li></td><td class=\'reportTD\'><ul><li>' + FollowupValue + '</li></ul></td></tr>';
                                        }else{
                                        OneRowValue = '<tr class=\'' + OneRowColor + '\'><td class=\'reportTD\'><ul><li>' + '&nbsp;' + '</ul></li></td><td class=\'reportTD\'><ul><li>' + FollowupValue + '</li></ul></td></tr>';
                                } 
                        }//citem.Line_Item_Title__c    
                        Investment_Thesis.add(OneRowValue);  
                }//for    
          }//if size>0   
          return Investment_Thesis;
    }    

    public List<String> getInvestment_Risks()
    {
        String OneRowValue ='';
        String FollowupValue='';
        String OneRowColor ='';
        
        if((deal_id == null) || (sch_id ==null)){
          return Investment_Risks;
        }        
        List<Deal__c> deal = [
            SELECT
            id,Name       
            FROM Deal__c
            WHERE Id = :deal_id
        ];
        List<DealScoreHeader__c> deal_hdr_list = [
            SELECT id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE Deal__c=:deal_id AND Type_of_Report__c='Follow Up'];
        
                if(deal_hdr_list.size()==1){
                        sch_id = deal_hdr_list[0].Id;
                } 
        if((deal.size() ==0) || (deal.size() !=1)) {
          return null;
        }        
        if((deal_hdr_list.size() ==0) || (deal_hdr_list.size() !=1)) {
          return null;
        }
        if((deal_hdr_list[0].Deal__c!=deal_id)||((deal_hdr_list[0].Type_of_Report__c != 'Copy') && (deal_hdr_list[0].Type_of_Report__c != 'Closing') && (deal_hdr_list[0].Type_of_Report__c != 'Follow Up'))) {
          return null;      
        }        
        
        List<Deal_Score_Line_Item__c> followup_list = [
          SELECT Id,Line_Item_Order__c,Deal_Score_Header__c,Related_Score_Line_Item_Id__c, Line_Item_Color__c,Line_Item_Title__c,Line_Item_Value__c 
          FROM Deal_Score_Line_Item__c
          WHERE Deal_Score_Header__c =:sch_id
          ORDER BY Line_Item_Order__c ASC];         
          
         if (followup_list.size()>0){
                for(Deal_Score_Line_Item__c citem :followup_list) {
                        OneRowValue='';
                        OneRowColor='customTableRowWhite';
                        FollowupValue = '&nbsp;';
                        if(citem.Line_Item_Title__c == 'Investment Risks') {     
                                //Now - fetch the related id and get the value
                                List<Deal_Score_Line_Item__c> copy_item = [
                                SELECT Id,Line_Item_Value__c,Line_Item_Color__c,Related_Score_Line_Item_Id__c
                                FROM Deal_Score_Line_Item__c
                                WHERE Id =:citem.Related_Score_Line_Item_Id__c];
                                if (copy_item.size()==1){
                                        if (citem.Line_Item_Color__c=='#ebf1de'){
                                                OneRowColor = 'customTableRowPink';
                                        }
                                        if(citem.Line_Item_Color__c=='#f2dcdb'){
                                                OneRowColor = 'customTableRowGreen';
                                        }
                                        if (citem.Line_Item_Value__c==null || citem.Line_Item_Value__c==''){
                                                FollowupValue = '&nbsp;';
                                        }else{
                                                FollowupValue = citem.Line_Item_Value__c;
                                        }
                                        OneRowValue = '<tr class=\'' + OneRowColor + '\'><td class=\'reportTD\'><ul><li>' + copy_item[0].Line_Item_Value__c + '</ul></li></td><td class=\'reportTD\'><ul><li>' + FollowupValue + '</li></ul></td></tr>';
                                        }else{
                                        OneRowValue = '<tr class=\'' + OneRowColor + '\'><td class=\'reportTD\'><ul><li>' + '&nbsp;' + '</ul></li></td><td class=\'reportTD\'><ul><li>' + FollowupValue + '</li></ul></td></tr>';
                                } 
                        }//citem.Line_Item_Title__c    
                        Investment_Risks.add(OneRowValue);  

                }//for    
          }//if size>0   
          return Investment_Risks;
    }    

     public List<String> getKey_Value_Creation_Drivers()
    {
        String OneRowValue ='';
        String FollowupValue='';
        String OneRowColor ='';
        
        if((deal_id == null) || (sch_id ==null)){
          return Key_Value_Creation_Drivers;
        }        
        List<Deal__c> deal = [
            SELECT
            id,Name       
            FROM Deal__c
            WHERE Id = :deal_id
        ];
        List<DealScoreHeader__c> deal_hdr_list = [
            SELECT id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE Deal__c=:deal_id AND Type_of_Report__c='Follow Up'];
        
                if(deal_hdr_list.size()==1){
                        sch_id = deal_hdr_list[0].Id;
                } 
        if((deal.size() ==0) || (deal.size() !=1)) {
          return null;
        }        
        if((deal_hdr_list.size() ==0) || (deal_hdr_list.size() !=1)) {
          return null;
        }
        if((deal_hdr_list[0].Deal__c!=deal_id)||((deal_hdr_list[0].Type_of_Report__c != 'Copy') && (deal_hdr_list[0].Type_of_Report__c != 'Closing') && (deal_hdr_list[0].Type_of_Report__c != 'Follow Up'))) {
          return null;      
        }        
        
        List<Deal_Score_Line_Item__c> followup_list = [
          SELECT Id,Line_Item_Order__c,Deal_Score_Header__c,Related_Score_Line_Item_Id__c, Line_Item_Color__c,Line_Item_Title__c,Line_Item_Value__c 
          FROM Deal_Score_Line_Item__c
          WHERE Deal_Score_Header__c =:sch_id
          ORDER BY Line_Item_Order__c ASC];         
          
         if (followup_list.size()>0){
                for(Deal_Score_Line_Item__c citem :followup_list) {
                        OneRowValue='';
                        OneRowColor='customTableRowWhite';
                        FollowupValue = '&nbsp;';
                        if(citem.Line_Item_Title__c == 'Key Value Creation Drivers') {     
                                //Now - fetch the related id and get the value
                                List<Deal_Score_Line_Item__c> copy_item = [
                                SELECT Id,Line_Item_Value__c,Line_Item_Color__c,Related_Score_Line_Item_Id__c
                                FROM Deal_Score_Line_Item__c
                                WHERE Id =:citem.Related_Score_Line_Item_Id__c];
                                if (copy_item.size()==1){
                                        if (citem.Line_Item_Color__c=='#ebf1de'){
                                                OneRowColor = 'customTableRowPink';
                                        }
                                        if(citem.Line_Item_Color__c=='#f2dcdb'){
                                                OneRowColor = 'customTableRowGreen';
                                        }
                                        if (citem.Line_Item_Value__c==null || citem.Line_Item_Value__c==''){
                                                FollowupValue = '&nbsp;';
                                        }else{
                                                FollowupValue = citem.Line_Item_Value__c;
                                        }
                                        OneRowValue = '<tr class=\'' + OneRowColor + '\'><td class=\'reportTD\'><ul><li>' + copy_item[0].Line_Item_Value__c + '</ul></li></td><td class=\'reportTD\'><ul><li>' + FollowupValue + '</li></ul></td></tr>';
                                        }else{
                                        OneRowValue = '<tr class=\'' + OneRowColor + '\'><td class=\'reportTD\'><ul><li>' + '&nbsp;' + '</ul></li></td><td class=\'reportTD\'><ul><li>' + FollowupValue + '</li></ul></td></tr>';
                                } 
                        }//citem.Line_Item_Title__c    
                        Key_Value_Creation_Drivers.add(OneRowValue);  

                }//for    
          }//if size>0   
          return Key_Value_Creation_Drivers;
    }    

    public List<String> getKey_Company_Goals_and_Milestones()
    {
        String OneRowValue ='';
        String FollowupValue='';
        String OneRowColor ='';
        
        if((deal_id == null) || (sch_id ==null)){
          return Key_Company_Goals_and_Milestones;
        }        
        List<Deal__c> deal = [
            SELECT
            id,Name       
            FROM Deal__c
            WHERE Id = :deal_id
        ];
        List<DealScoreHeader__c> deal_hdr_list = [
            SELECT id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE Deal__c=:deal_id AND Type_of_Report__c='Follow Up'];
        
                if(deal_hdr_list.size()==1){
                        sch_id = deal_hdr_list[0].Id;
                } 
        if((deal.size() ==0) || (deal.size() !=1)) {
          return null;
        }        
        if((deal_hdr_list.size() ==0) || (deal_hdr_list.size() !=1)) {
          return null;
        }
        if((deal_hdr_list[0].Deal__c!=deal_id)||((deal_hdr_list[0].Type_of_Report__c != 'Copy') && (deal_hdr_list[0].Type_of_Report__c != 'Closing') && (deal_hdr_list[0].Type_of_Report__c != 'Follow Up'))) {
          return null;      
        }        
        
        List<Deal_Score_Line_Item__c> followup_list = [
          SELECT Id,Line_Item_Order__c,Deal_Score_Header__c,Related_Score_Line_Item_Id__c, Line_Item_Color__c,Line_Item_Title__c,Line_Item_Value__c 
          FROM Deal_Score_Line_Item__c
          WHERE Deal_Score_Header__c =:sch_id
          ORDER BY Line_Item_Order__c ASC];         
          
         if (followup_list.size()>0){
                for(Deal_Score_Line_Item__c citem :followup_list) {
                        OneRowValue='';
                        OneRowColor='customTableRowWhite';
                        FollowupValue = '&nbsp;';
                        if(citem.Line_Item_Title__c == 'Key Company Goals and Milestones') {     
                                //Now - fetch the related id and get the value
                                List<Deal_Score_Line_Item__c> copy_item = [
                                SELECT Id,Line_Item_Value__c,Line_Item_Color__c,Related_Score_Line_Item_Id__c
                                FROM Deal_Score_Line_Item__c
                                WHERE Id =:citem.Related_Score_Line_Item_Id__c];
                                if (copy_item.size()==1){
                                        if (citem.Line_Item_Color__c=='#ebf1de'){
                                                OneRowColor = 'customTableRowPink';
                                        }
                                        if(citem.Line_Item_Color__c=='#f2dcdb'){
                                                OneRowColor = 'customTableRowGreen';
                                        }
                                        if (citem.Line_Item_Value__c==null || citem.Line_Item_Value__c==''){
                                                FollowupValue = '&nbsp;';
                                        }else{
                                                FollowupValue = citem.Line_Item_Value__c;
                                        }
                                        OneRowValue = '<tr class=\'' + OneRowColor + '\'><td class=\'reportTD\'><ul><li>' + copy_item[0].Line_Item_Value__c + '</ul></li></td><td class=\'reportTD\'><ul><li>' + FollowupValue + '</li></ul></td></tr>';
                                        }else{
                                        OneRowValue = '<tr class=\'' + OneRowColor + '\'><td class=\'reportTD\'><ul><li>' + '&nbsp;' + '</ul></li></td><td class=\'reportTD\'><ul><li>' + FollowupValue + '</li></ul></td></tr>';
                                } 
                        }//citem.Line_Item_Title__c    
                        Key_Company_Goals_and_Milestones.add(OneRowValue);  

                }//for    
          }//if size>0   
          return Key_Company_Goals_and_Milestones;
    }  

        public List<String> getManagement_Team_and_Board_Additions_and_or_Development_Goals()
    {
        String OneRowValue ='';
        String FollowupValue='';
        String OneRowColor ='';
        
        if((deal_id == null) || (sch_id ==null)){
          return Management_Team_and_Board_Additions_and_or_Development_Goals;
        }        
        List<Deal__c> deal = [
            SELECT
            id,Name       
            FROM Deal__c
            WHERE Id = :deal_id
        ];
        List<DealScoreHeader__c> deal_hdr_list = [
            SELECT id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE Deal__c=:deal_id AND Type_of_Report__c='Follow Up'];
        
                if(deal_hdr_list.size()==1){
                        sch_id = deal_hdr_list[0].Id;
                } 
        if((deal.size() ==0) || (deal.size() !=1)) {
          return null;
        }        
        if((deal_hdr_list.size() ==0) || (deal_hdr_list.size() !=1)) {
          return null;
        }
        if((deal_hdr_list[0].Deal__c!=deal_id)||((deal_hdr_list[0].Type_of_Report__c != 'Copy') && (deal_hdr_list[0].Type_of_Report__c != 'Closing') && (deal_hdr_list[0].Type_of_Report__c != 'Follow Up'))) {
          return null;      
        }        
        
        List<Deal_Score_Line_Item__c> followup_list = [
          SELECT Id,Line_Item_Order__c,Deal_Score_Header__c,Related_Score_Line_Item_Id__c, Line_Item_Color__c,Line_Item_Title__c,Line_Item_Value__c 
          FROM Deal_Score_Line_Item__c
          WHERE Deal_Score_Header__c =:sch_id
          ORDER BY Line_Item_Order__c ASC];         
          
         if (followup_list.size()>0){
                for(Deal_Score_Line_Item__c citem :followup_list) {
                        OneRowValue='';
                        OneRowColor='customTableRowWhite';
                        FollowupValue = '&nbsp;';
                        if(citem.Line_Item_Title__c == 'Management Team and Board Additions and/or Development Goals') {     
                                //Now - fetch the related id and get the value
                                List<Deal_Score_Line_Item__c> copy_item = [
                                SELECT Id,Line_Item_Value__c,Line_Item_Color__c,Related_Score_Line_Item_Id__c
                                FROM Deal_Score_Line_Item__c
                                WHERE Id =:citem.Related_Score_Line_Item_Id__c];
                                if (copy_item.size()==1){
                                        if (citem.Line_Item_Color__c=='#ebf1de'){
                                                OneRowColor = 'customTableRowPink';
                                        }
                                        if(citem.Line_Item_Color__c=='#f2dcdb'){
                                                OneRowColor = 'customTableRowGreen';
                                        }
                                        if (citem.Line_Item_Value__c==null || citem.Line_Item_Value__c==''){
                                                FollowupValue = '&nbsp;';
                                        }else{
                                                FollowupValue = citem.Line_Item_Value__c;
                                        }
                                        OneRowValue = '<tr class=\'' + OneRowColor + '\'><td class=\'reportTD\'><ul><li>' + copy_item[0].Line_Item_Value__c + '</ul></li></td><td class=\'reportTD\'><ul><li>' + FollowupValue + '</li></ul></td></tr>';
                                        }else{
                                        OneRowValue = '<tr class=\'' + OneRowColor + '\'><td class=\'reportTD\'><ul><li>' + '&nbsp;' + '</ul></li></td><td class=\'reportTD\'><ul><li>' + FollowupValue + '</li></ul></td></tr>';
                                } 
                        }//citem.Line_Item_Title__c    
                        Management_Team_and_Board_Additions_and_or_Development_Goals.add(OneRowValue);  

                }//for    
          }//if size>0   
          return Management_Team_and_Board_Additions_and_or_Development_Goals;
    }  
    
        public List<String> getWP_Team_Action_Items()
    {
        String OneRowValue ='';
        String FollowupValue='';
        String OneRowColor ='';
        if((deal_id == null) || (sch_id ==null)){
          return WP_Team_Action_Items;
        }        
        List<Deal__c> deal = [
            SELECT
            id,Name       
            FROM Deal__c
            WHERE Id = :deal_id
        ];
        List<DealScoreHeader__c> deal_hdr_list = [
            SELECT id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE Deal__c=:deal_id AND Type_of_Report__c='Follow Up'];
        
                if(deal_hdr_list.size()==1){
                        sch_id = deal_hdr_list[0].Id;
                } 
        if((deal.size() ==0) || (deal.size() !=1)) {
          return null;
        }        
        if((deal_hdr_list.size() ==0) || (deal_hdr_list.size() !=1)) {
          return null;
        }
        if((deal_hdr_list[0].Deal__c!=deal_id)||((deal_hdr_list[0].Type_of_Report__c != 'Copy') && (deal_hdr_list[0].Type_of_Report__c != 'Closing') && (deal_hdr_list[0].Type_of_Report__c != 'Follow Up'))) {
          return null;      
        }        
        
        List<Deal_Score_Line_Item__c> followup_list = [
          SELECT Id,Line_Item_Order__c,Deal_Score_Header__c,Related_Score_Line_Item_Id__c, Line_Item_Color__c,Line_Item_Title__c,Line_Item_Value__c 
          FROM Deal_Score_Line_Item__c
          WHERE Deal_Score_Header__c =:sch_id
          ORDER BY Line_Item_Order__c ASC];         
          
         if (followup_list.size()>0){
                for(Deal_Score_Line_Item__c citem :followup_list) {
                        OneRowValue='';
                        OneRowColor='customTableRowWhite';
                        FollowupValue = '&nbsp;';
                        if(citem.Line_Item_Title__c == 'WP Team Action Items') {     
                                //Now - fetch the related id and get the value
                                List<Deal_Score_Line_Item__c> copy_item = [
                                SELECT Id,Line_Item_Value__c,Line_Item_Color__c,Related_Score_Line_Item_Id__c
                                FROM Deal_Score_Line_Item__c
                                WHERE Id =:citem.Related_Score_Line_Item_Id__c];
                                if (copy_item.size()==1){
                                        if (citem.Line_Item_Color__c=='#ebf1de'){
                                                OneRowColor = 'customTableRowPink';
                                        }
                                        if(citem.Line_Item_Color__c=='#f2dcdb'){
                                                OneRowColor = 'customTableRowGreen';
                                        }
                                        if (citem.Line_Item_Value__c==null || citem.Line_Item_Value__c==''){
                                                FollowupValue = '&nbsp;';
                                        }else{
                                                FollowupValue = citem.Line_Item_Value__c;
                                        }
                                        OneRowValue = '<tr class=\'' + OneRowColor + '\'><td class=\'reportTD\'><ul><li>' + copy_item[0].Line_Item_Value__c + '</ul></li></td><td class=\'reportTD\'><ul><li>' + FollowupValue + '</li></ul></td></tr>';
                                        }else{
                                        OneRowValue = '<tr class=\'' + OneRowColor + '\'><td class=\'reportTD\'><ul><li>' + '&nbsp;' + '</ul></li></td><td class=\'reportTD\'><ul><li>' + FollowupValue + '</li></ul></td></tr>';
                                } 
                        }//citem.Line_Item_Title__c    
                        WP_Team_Action_Items.add(OneRowValue);  

                }//for    
          }//if size>0   
          return WP_Team_Action_Items;
    }    
}