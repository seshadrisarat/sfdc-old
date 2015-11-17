@isTest
  private class kjoDealReportControllerTest { 
  	
  static testMethod void testMethod1() {
     List<Financial__c> list311 = [Select Id,Company__c from Financial__c limit 1 ];
     List<Account> accList = [Select Id,Company_Currency__c from Account where ID =:list311[0].Company__c limit 1];
     Account temp2 = kjoDealReportController.getCompany(accList[0].Id);
       List<Financial__c> list3;
       Account tempAccountItem;
       for(Account item :accList ) {
         list3 = kjoDealReportController.getCompanyFinancials(item.Id);
         if(list3.size() >0) {     
          tempAccountItem = item;
          break;
         }
   }
   List<Financial__c> list4 = kjoDealReportController.getCompanyFinancialSingle(list3[0].Id);   
   Date tempDate= Date.today();
   Financial__c tempFin = kjoDealReportController.upsertCompanyFinancial(
    tempAccountItem.Id,
    list4[0].Id,'Annual',tempDate,1.0,1.0,1.0,1.0,1.0,1.0,'',tempAccountItem.Company_Currency__c);
   Financial__c tempFin2 = kjoDealReportController.upsertCompanyFinancial(
    tempAccountItem.Id,
    '','Annual',tempDate,1.0,1.0,1.0,1.0,1.0,1.0,'',tempAccountItem.Company_Currency__c);   
   boolean tempFlag = kjoDealReportController.deleteCompanyFinancial(list4[0].Id);
}
  static testMethod void testMethod4() {
   	List<kjoDealReportController.FinanceOptions> finList = kjoDealReportController.getFinanceOptions();
       String temp1 = kjoDealReportController.getCurrencySymbolFromIso('USD'); 
       temp1 = kjoDealReportController.getCurrencySymbolFromIso('CAD'); 
       temp1 = kjoDealReportController.getCurrencySymbolFromIso('EUR'); 
       temp1 = kjoDealReportController.getCurrencySymbolFromIso('GBP'); 
       temp1 = kjoDealReportController.getCurrencySymbolFromIso('JPY'); 
       temp1 = kjoDealReportController.getCurrencySymbolFromIso('KRW'); 
       temp1 = kjoDealReportController.getCurrencySymbolFromIso('CNY'); 
       List<SelectOption> perList = kjoDealReportController.getFinancePeriods() ;
	List<String> list5 =  kjoDealReportController.getCurrencyList();
	   boolean tempFlag = kjoDealReportController.deleteCompanyFinancial(''); 
	List<SelectOption> list6 = kjoDealReportController.getFinanceCurrencies();
  }
  static testMethod void testMethod3(){
  	//updateFollowupHeaderFields String deal_id, String field_name, String field_value
  	
  	  String deal_id='123456';
  	  String deal_id2='123456789';
  	  String deal_sc_hdr_id='1234567';
      String deal_line_item_id='12345678';
      String field_name='OtherConsiderations';
      String field_Value ='Other Considerations to test';
      
    	DealScoreHeader__c header_item;
        List<DealScoreHeader__c> deal_followup_hdr = [
            SELECT id,OtherConsiderations__c, TeamRecommendations__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND Type_of_Report__c='Follow Up' ];
            
            if(deal_followup_hdr.size() == 1) {    
            	header_item = new DealScoreHeader__c();
            	header_item = deal_followup_hdr[0];
            	if (field_name=='OtherConsiderations'){
                	header_item.OtherConsiderations__c = field_value;
            	}
            	if (field_name=='TeamRecommend'){
                	header_item.TeamRecommendations__c = field_value;
            	}            	
            	update header_item;
            }
  		kjoDealReportController.updateFollowupHeaderFields(
  	  		deal_id,
	  		field_name,
	  		field_value
  		);  	
  }
  static testMethod void testMethod2() {
   List<Deal__c> dList = [Select Id from Deal__c limit 100];
   List<EMG_Comment__c> comments;
   Deal__c ditem;
   for(Deal__c item : dList) {
        comments = [ SELECT Id from EMG_Comment__c where 
            Deal__c = :item.Id];
      if(comments.size() > 0){
        ditem = item;
        break;
      }  
   }
   kjoDealReportController.DealCommentaryEMG dc1,dc2 ;
   dc1 = new kjoDealReportController.DealCommentaryEMG(comments[0].Id,ditem.Id);
   dc2 = new kjoDealReportController.DealCommentaryEMG('',ditem.Id);
   dc1 = kjoDealReportController.updateEMGComment(dc1);
   dc2 = kjoDealReportController.updateEMGComment(dc2); 
   kjoDealReportController.DealCommentary temp = kjoDealReportController.getDealCommentary(ditem.Id);
  }
  
  
  
  static testMethod void testMethod5() {
  	//addUpdateDCR_Metric_Field
  	  String deal_id='123456';
  	  String deal_id2='123456789';
  	  String deal_sc_hdr_id='1234567';
      String deal_line_item_id='12345678';
      
      String dcr_metric_name='My New Metric';
      String dcr_metric_date ='JAN 2014';
      Date dcr_sorted_date= date.today();
      String dcr_metric_value ='100.45';
      String dcr_metric_unit ='USD';
  	List<Deal__c> dealList = [Select Id from Deal__c limit 1];        
  	List<DealScoreHeader__c> headerList = [
            SELECT
            id,Deal__c,Type_of_Report__c           
            FROM DealScoreHeader__c
            WHERE (id = :deal_sc_hdr_id)
    ];  
    List<Deal_Score_Line_Item__c> lineList = [
            SELECT id, Deal_Score_Header__c,Financial_Metric_Name__c,Financial_Metric_Period_Ended__c,Financial_Metric_Period_Text__c,
            Financial_Metric_Value__c, Financial_Metric_Unit__c,Is_Financial_Metric_Imported__c, Line_Item_Title__c     
            FROM Deal_Score_Line_Item__c
            WHERE (id =:deal_line_item_id)
    ];
  	kjoDealReportController.addUpdateDCR_Metric_Field(
  	  deal_id,
  	  deal_sc_hdr_id,
  	  deal_line_item_id,
  	  dcr_metric_name,
  	  dcr_metric_date,
  	  dcr_sorted_date,
	  dcr_metric_value,
	  dcr_metric_unit
  	);  	
  	//kjoDealReportController.addUpdateDCR_Metric_Field deal_id2,deal_sc_hdr_id, deal_line_item_id, dcr_metric_name, dcr_metric_date, dcr_sorted_date,dcr_metric_value,dcr_metric_unit ;
  }
    static testMethod void testMethod6() {
    	//deleteDCR_Metric_Field
    	String deal_id='123';
    	String deal_sc_hdr_id='123';
    	String deal_line_item_id='1234';
        String result=null;
        List<Deal_Score_Line_Item__c> dcr_list = [
          SELECT Id,Deal_Score_Header__c FROM Deal_Score_Line_Item__c
          WHERE Id =:deal_line_item_id];
          if (dcr_list.size() == 1) {
            if(dcr_list[0].Deal_Score_Header__c != deal_sc_hdr_id){
              //System.debug('deleteDCR_Metric_Field: Failed to delete item due to invalid score header id:size:'+dcr_list.size()+'....'+deal_id+'....'+deal_sc_hdr_id+'...'+deal_line_item_id);
              result= null;
            } else {
            delete dcr_list[0];
            //System.debug('deleteDCR_Metric_Field: Deleted item:size:'+dcr_list.size()+'....'+deal_id+'....'+deal_sc_hdr_id+'...'+deal_line_item_id);
            /*Check if there are no more items left, inform Apex page to show back the import company list*/
            dcr_list = [
             SELECT Id,Deal_Score_Header__c,Line_Item_Title__c FROM Deal_Score_Line_Item__c
              WHERE (Deal_Score_Header__c =:deal_sc_hdr_id) AND (Line_Item_Title__c = 'Financial Metric')];
	            if (dcr_list.size() == 0) {
	              result = 'SHOW LIST';
	              //System.debug('deleteDCR_Metric_Field: All items deleted:size:'+dcr_list.size()+'....'+deal_id+'....'+deal_sc_hdr_id+'...'+deal_line_item_id+':'+result);
	              
	              /*Also set back the imported flags to false*/
	              List<DealScoreHeader__c> deal_hdr_list = [
	                 SELECT
	                 id,Deal__c,Date_Received__c,Type_of_Report__c,ISEBITDAIMPORTED__c,ISRevenueIMPORTED__c 
	                 FROM DealScoreHeader__c
	                 WHERE (id = :deal_sc_hdr_id)
	              ]; 
	              if(deal_hdr_list.size() != 1) {       
	                 result= null;
	                 //System.debug('deleteDCR_Metric_Field:More than 1 deal score header exists.Please check:size'+deal_hdr_list.size());
	              } else {
	                 deal_hdr_list[0].ISEBITDAIMPORTED__c=false;
	                 deal_hdr_list[0].ISRevenueIMPORTED__c=false;
	                 update deal_hdr_list[0];
	                 //System.debug('deleteDCR_Metric_Field:Deal score header updated for imported flags'+deal_hdr_list[0]);
	              }           
	            } else {
	              result = 'true';
	              //System.debug('deleteDCR_Metric_Field: Deleted item:size:'+dcr_list.size()+'....'+deal_id+'....'+deal_sc_hdr_id+'...'+deal_line_item_id+':'+result);
	            }
           }    
       } 
    }//testMethod6  
    
    static testMethod void testMethod7() {
   	//createDCR_ReportTypeHeaderList
    	    String deal_id='1234';
    	    String report_type='Closing';
    	    Date r_date= System.today();
    	    
      kjoDealReportController.DCR_ReportTypeHeader_CreateInfo head_list = new kjoDealReportController.DCR_ReportTypeHeader_CreateInfo();
     
       report_type= report_type.replace('[','');
       report_type= report_type.replace(']','');
      
      if(report_type == 'Closing') {     
        List<DealScoreHeader__c> deal_hdr_list_closing = [
            SELECT
            id,Date_Received__c,Type_of_Report__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Closing' )
        ];    
        List<DealScoreHeader__c> deal_hdr_list_follow = [
            SELECT
            id,Date_Received__c,Type_of_Report__c
            FROM DealScoreHeader__c
            WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Follow Up' )
        ];      
        if(deal_hdr_list_closing.size() > 1) {
          //head_list.status='More than one Closing header exists. Closing header creation failed';
          //System.debug('getDCR_ReportTypeHeaderList:'+head_list.status);
        } else if(deal_hdr_list_closing.size() == 1) {
          //head_list.status='Closing header already exists. Closing header creation failed';
          //System.debug('getDCR_ReportTypeHeaderList:'+head_list.status);
        } else if(deal_hdr_list_follow.size() > 0) {
          //head_list.status='Closing header cannot be created when follow up exists. Closing header creation failed';
          //System.debug('getDCR_ReportTypeHeaderList:'+head_list.status);
        }else {
               DealScoreHeader__c header_item = new DealScoreHeader__c();
               header_item.Date_Received__c = r_date;
               header_item.Type_of_Report__c = report_type;
               header_item.ISEBITDAIMPORTED__c = false;
               header_item.ISRevenueIMPORTED__c = false;        
           }          
      } else if(report_type == 'Add Follow Up') {
            Boolean is_allowed = true;
            List<DealScoreHeader__c> deal_hdr_list = [
                SELECT
                id,Date_Received__c,Type_of_Report__c
                FROM DealScoreHeader__c
                WHERE (Deal__c = :deal_id) AND ((Type_of_Report__c = 'Follow Up') OR (Type_of_Report__c = 'Closing'))
            ];           
            for(DealScoreHeader__c deal_hdr_item :deal_hdr_list){
              if((r_date <= deal_hdr_item.Date_Received__c)|| (r_date.format().equalsIgnoreCase(deal_hdr_item.Date_Received__c.format()))) {
                is_allowed = false;
                break;
              }
            }           
            if(is_allowed == false){
              //head_list.status='Add New Follow Up date has to beyond Closing Or Existing FollowUp Dates.Follow up header creation failed';
              //System.debug('getDCR_ReportTypeHeaderList:'+head_list.status);   
            } else {
               List<DealScoreHeader__c> deal_hdr_list_follow = [
                     SELECT
                     id,Date_Received__c,Type_of_Report__c
                     FROM DealScoreHeader__c
                     WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Follow Up' )
                ];              
               DealScoreHeader__c header_item = new DealScoreHeader__c();    
               header_item.Date_Received__c = r_date;
               header_item.Type_of_Report__c = 'Follow Up';
               header_item.Deal__c = deal_id;
               header_item.ISEBITDAIMPORTED__c = false;
               header_item.ISRevenueIMPORTED__c = false;                        
           }
       }
    }
}