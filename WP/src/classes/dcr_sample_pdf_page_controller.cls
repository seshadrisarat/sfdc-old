public with sharing class dcr_sample_pdf_page_controller {
    public class DCR_Metric_Info {
        public String name {get; set;}
        public String value {get; set;}
        public String css {get; set;}
        public Boolean beginRowSwitch {get; set;}
        public Boolean endRowSwitch {get; set;}             
        public DCR_Metric_Info(){
          this.name='';
          this.value='';
          this.css='';
          this.beginRowSwitch=false;
          this.endRowSwitch=false;
        }
    }
    
    String deal_id;
    String sch_id;
    String DealTeam;
    String WPSeats;
    String WPSeatsTotal;
    String WPSeatsBoth;
    String WPOwnership;
    List<String> Investment_Thesis{get; set;}
    String Investment_Thesis_All = 'Some Investment_Thesis_All data to Display';
    List<String> Investment_Risks{get; set;}
    List<String> Key_Value_Creation_Drivers{get; set;}
    List<String> Key_Company_Goals_and_Milestones{get; set;}
    List<String> Management_Team_and_Board_Additions_and_or_Development_Goals{get; set;}
    List<String> WP_Team_Action_Items{get; set;}
    List<DCR_Metric_Info> DcrMetrics{get; set;}
    
    public dcr_sample_pdf_page_controller(ApexPages.StandardController controller) {
      this.deal_id= ((Deal__c)controller.getRecord()).Id;
      this.sch_id= System.currentPagereference().getParameters().get('sch_id');
      this.DealTeam='';  
      this.WPSeats='';
      this.WPSeatsTotal='';
      this.WPSeatsBoth='';
      this.WPOwnership='';
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
      
      this.DcrMetrics = new List<DCR_Metric_Info>();
      this.DcrMetrics.clear();
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
    public String getWPSeats() {
    		String wpString='';    
            List<DealScoreHeader__c> deal_hdr = [
            	SELECT
            	id,Date_Received__c,Type_of_Report__c,WP_Board_Seats__c
            	FROM DealScoreHeader__c
            	WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Closing' )
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
            	WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Closing' )
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
            	WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Closing' )
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
            	WHERE (Deal__c = :deal_id) AND (Type_of_Report__c = 'Closing' )
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
            (SELECT Id,Employee__c,
                Employee__r.Name, Employee__r.Employee_Level__r.Rank__c,Employee__r.ISSENIORTEAMMEMBER__c, 
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
		       //String sortOrder='';
		       for(Deal_Team__c team_item:team_list) {
		       	 //sortOrder = '('+ String.valueOf(team_item.Employee__r.Employee_Level__r.Rank__c) +'-'+ String.valueOf(team_item.Employee__r.Employee_Level_Precedence_Sorter__c) + '-' + String.valueOf(team_item.Employee__r.ISSENIORTEAMMEMBER__c) + ')';
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
       
    public List<String> getInvestment_Thesis()
    {
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
            SELECT
            id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (id = :sch_id) ];

        if((deal.size() ==0) || (deal.size() !=1)) {
          system.debug('getInvestment_Thesis:Invalid deal id received..returning null');
          return null;
        }        
        if((deal_hdr_list.size() ==0) || (deal_hdr_list.size() !=1)) {
          system.debug('getInvestment_Thesis:Invalid score header id received..returning null');
          return null;
        }
        if((deal_hdr_list[0].Deal__c!=deal_id)||((deal_hdr_list[0].Type_of_Report__c != 'Closing') && (deal_hdr_list[0].Type_of_Report__c != 'Follow Up'))) {
          system.debug('getInvestment_Thesis:Invalid elements in score header ..returning null');
          return null;      
        }        
        List<Deal_Score_Line_Item__c> line_list = [
          SELECT Id,CreatedDate,LastModifiedDate,
          Deal_Score_Header__c, Line_Item_Color__c,Line_Item_Title__c,Line_Item_Value__c FROM Deal_Score_Line_Item__c
          WHERE Deal_Score_Header__c =:sch_id
          ORDER BY Line_Item_Order__c ASC];         
         
         for(Deal_Score_Line_Item__c item :line_list) {
           if(item.Line_Item_Title__c == 'Investment Thesis') {            
             Investment_Thesis.add(item.Line_Item_Value__c);
             Investment_Thesis_All = Investment_Thesis_All + item.Line_Item_Value__c + '<br>';
             system.debug('getInvestment_Thesis:Adding size:item'+Investment_Thesis.size()+':'+item);
           } else {
             system.debug('getInvestment_Thesis:ignore item'+item);
           }           
         }
	    system.debug('getInvestment_Thesis:Final list is:size:list'+Investment_Thesis.size()+':'+Investment_Thesis);
    	return Investment_Thesis;
    }    

    public List<String> getInvestment_Risks(){
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
            SELECT
            id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (id = :sch_id) ];

        if((deal.size() ==0) || (deal.size() !=1)) {
          system.debug('getInvestment_Risks:Invalid deal id received..returning null');
          return null;
        }
        
        if((deal_hdr_list.size() ==0) || (deal_hdr_list.size() !=1)) {
          system.debug('getInvestment_Risks:Invalid score header id received..returning null');
          return null;
        }
        if((deal_hdr_list[0].Deal__c!=deal_id)||((deal_hdr_list[0].Type_of_Report__c != 'Closing')&& (deal_hdr_list[0].Type_of_Report__c != 'Follow Up'))) {
          system.debug('getInvestment_Risks:Invalid elements in score header ..returning null');
          return null;      
        }
        
        List<Deal_Score_Line_Item__c> line_list = [
          SELECT Id,CreatedDate,LastModifiedDate,
          Deal_Score_Header__c, Line_Item_Color__c,Line_Item_Title__c,Line_Item_Value__c FROM Deal_Score_Line_Item__c
          WHERE Deal_Score_Header__c =:sch_id
          ORDER BY Line_Item_Order__c ASC];         
         
         for(Deal_Score_Line_Item__c item :line_list) {
           if(item.Line_Item_Title__c == 'Investment Risks') {            
             Investment_Risks.add(item.Line_Item_Value__c);
             system.debug('getInvestment_Risks:Adding size:item'+Investment_Risks.size()+':'+item);
           } else {
             system.debug('getInvestment_Risks:ignore item'+item);
           }           
         }
	    system.debug('getInvestment_Risks:Final list is:size:list'+Investment_Risks.size()+':'+Investment_Risks);
    	return Investment_Risks;
    }   

    public List<String> getKey_Value_Creation_Drivers()
    {
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
            SELECT
            id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (id = :sch_id) ];

        if((deal.size() ==0) || (deal.size() !=1)) {
          system.debug('getKey_Value_Creation_Drivers:Invalid deal id received..returning null');
          return null;
        }
        
        if((deal_hdr_list.size() ==0) || (deal_hdr_list.size() !=1)) {
          system.debug('getKey_Value_Creation_Drivers:Invalid score header id received..returning null');
          return null;
        }
        if((deal_hdr_list[0].Deal__c!=deal_id)||((deal_hdr_list[0].Type_of_Report__c != 'Closing')&& (deal_hdr_list[0].Type_of_Report__c != 'Follow Up'))) {
          system.debug('getKey_Value_Creation_Drivers:Invalid elements in score header ..returning null');
          return null;      
        }
        
        List<Deal_Score_Line_Item__c> line_list = [
          SELECT Id,CreatedDate,LastModifiedDate,
          Deal_Score_Header__c, Line_Item_Color__c,Line_Item_Title__c,Line_Item_Value__c FROM Deal_Score_Line_Item__c
          WHERE Deal_Score_Header__c =:sch_id
          ORDER BY Line_Item_Order__c ASC];         
         
         for(Deal_Score_Line_Item__c item :line_list) {
           if(item.Line_Item_Title__c == 'Key Value Creation Drivers') {            
             Key_Value_Creation_Drivers.add(item.Line_Item_Value__c);
             system.debug('getKey_Value_Creation_Drivers:Adding size:item'+Key_Value_Creation_Drivers.size()+':'+item);
           } else {
             system.debug('getKey_Value_Creation_Drivers:ignore item'+item);
           }           
         }

    system.debug('getKey_Value_Creation_Drivers:Final list is:size:list'+Key_Value_Creation_Drivers.size()+':'+Key_Value_Creation_Drivers);
    return Key_Value_Creation_Drivers;
    }   

    public List<String> getKey_Company_Goals_and_Milestones()
    {
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
            SELECT
            id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (id = :sch_id) ];

        if((deal.size() ==0) || (deal.size() !=1)) {
          system.debug('getKey_Company_Goals_and_Milestones:Invalid deal id received..returning null');
          return null;
        }
        
        if((deal_hdr_list.size() ==0) || (deal_hdr_list.size() !=1)) {
          system.debug('getKey_Company_Goals_and_Milestones:Invalid score header id received..returning null');
          return null;
        }
        if((deal_hdr_list[0].Deal__c!=deal_id)||((deal_hdr_list[0].Type_of_Report__c != 'Closing')&& (deal_hdr_list[0].Type_of_Report__c != 'Follow Up'))) {
          system.debug('getKey_Company_Goals_and_Milestones:Invalid elements in score header ..returning null');
          return null;      
        }
        
        List<Deal_Score_Line_Item__c> line_list = [
          SELECT Id,CreatedDate,LastModifiedDate,
          Deal_Score_Header__c, Line_Item_Color__c,Line_Item_Title__c,Line_Item_Value__c FROM Deal_Score_Line_Item__c
          WHERE Deal_Score_Header__c =:sch_id
          ORDER BY Line_Item_Order__c ASC];         
         
         for(Deal_Score_Line_Item__c item :line_list) {
           if(item.Line_Item_Title__c == 'Key Company Goals and Milestones') {            
             Key_Company_Goals_and_Milestones.add(item.Line_Item_Value__c);
             system.debug('getKey_Company_Goals_and_Milestones:Adding size:item'+Key_Company_Goals_and_Milestones.size()+':'+item);
           } else {
             system.debug('getKey_Company_Goals_and_Milestones:ignore item'+item);
           }           
         }

    system.debug('getKey_Company_Goals_and_Milestones:Final list is:size:list'+Key_Company_Goals_and_Milestones.size()+':'+Key_Company_Goals_and_Milestones);
    return Key_Company_Goals_and_Milestones;
    }   

    public List<String> getManagement_Team_and_Board_Additions_and_or_Development_Goals()
    {
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
            SELECT
            id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (id = :sch_id) ];

        if((deal.size() ==0) || (deal.size() !=1)) {
          system.debug('getManagement_Team_and_Board_Additions_and_or_Development_Goals:Invalid deal id received..returning null');
          return null;
        }
        
        if((deal_hdr_list.size() ==0) || (deal_hdr_list.size() !=1)) {
          system.debug('getManagement_Team_and_Board_Additions_and_or_Development_Goals:Invalid score header id received..returning null');
          return null;
        }
        if((deal_hdr_list[0].Deal__c!=deal_id)||((deal_hdr_list[0].Type_of_Report__c != 'Closing')&& (deal_hdr_list[0].Type_of_Report__c != 'Follow Up'))) {
          system.debug('getManagement_Team_and_Board_Additions_and_or_Development_Goals:Invalid elements in score header ..returning null');
          return null;      
        }
        
        List<Deal_Score_Line_Item__c> line_list = [
          SELECT Id,CreatedDate,LastModifiedDate,
          Deal_Score_Header__c, Line_Item_Color__c,Line_Item_Title__c,Line_Item_Value__c FROM Deal_Score_Line_Item__c
          WHERE Deal_Score_Header__c =:sch_id
          ORDER BY Line_Item_Order__c ASC];         
         
         for(Deal_Score_Line_Item__c item :line_list) {
           if(item.Line_Item_Title__c == 'Management Team and Board Additions and/or Development Goals') {            
             Management_Team_and_Board_Additions_and_or_Development_Goals.add(item.Line_Item_Value__c);
             system.debug('getManagement_Team_and_Board_Additions_and_or_Development_Goals:Adding size:item'+
             Management_Team_and_Board_Additions_and_or_Development_Goals.size()+':'+item);
           } else {
             system.debug('getManagement_Team_and_Board_Additions_and_or_Development_Goals:ignore item'+item);
           }           
         }

    system.debug('getManagement_Team_and_Board_Additions_and_or_Development_Goals:Final list is:size:list'+
    Management_Team_and_Board_Additions_and_or_Development_Goals.size()+':'+Management_Team_and_Board_Additions_and_or_Development_Goals);
    return Management_Team_and_Board_Additions_and_or_Development_Goals;
    }   
    
    public List<String> getWP_Team_Action_Items()
    {
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
            SELECT
            id,Date_Received__c,Type_of_Report__c,Deal__c
            FROM DealScoreHeader__c
            WHERE (id = :sch_id) ];

        if((deal.size() ==0) || (deal.size() !=1)) {
          system.debug('getWP_Team_Action_Items:Invalid deal id received..returning null');
          return null;
        }
        
        if((deal_hdr_list.size() ==0) || (deal_hdr_list.size() !=1)) {
          system.debug('getWP_Team_Action_Items:Invalid score header id received..returning null');
          return null;
        }
        if((deal_hdr_list[0].Deal__c!=deal_id)||((deal_hdr_list[0].Type_of_Report__c != 'Closing')&& (deal_hdr_list[0].Type_of_Report__c != 'Follow Up'))) {
          system.debug('getWP_Team_Action_Items:Invalid elements in score header ..returning null');
          return null;      
        }
        
        List<Deal_Score_Line_Item__c> line_list = [
          SELECT Id,CreatedDate,LastModifiedDate,
          Deal_Score_Header__c, Line_Item_Color__c,Line_Item_Title__c,Line_Item_Value__c FROM Deal_Score_Line_Item__c
          WHERE Deal_Score_Header__c =:sch_id
          ORDER BY Line_Item_Order__c ASC];         
         
         for(Deal_Score_Line_Item__c item :line_list) {
           if(item.Line_Item_Title__c == 'WP Team Action Items') {            
             WP_Team_Action_Items.add(item.Line_Item_Value__c);
             system.debug('getWP_Team_Action_Items:Adding size:item'+WP_Team_Action_Items.size()+':'+item);
           } else {
             system.debug('getWP_Team_Action_Items:ignore item'+item);
           }           
         }

    system.debug('getWP_Team_Action_Items:Final list is:size:list'+WP_Team_Action_Items.size()+':'+WP_Team_Action_Items);
    return WP_Team_Action_Items;
    }   
    
   public List<DCR_Metric_Info>  getDcrMetrics()
   {
        if((deal_id == null) || (sch_id ==null)){
          return DcrMetrics;
        }
        
        List<DealScoreHeader__c> dsh_list = [
            SELECT
            id,Deal__c,Type_of_Report__c            
            FROM DealScoreHeader__c
            WHERE (id =:sch_id) AND (Deal__c = :deal_id)
        ];

        if(dsh_list.size() > 1) {
          system.debug('getDcrMetrics:Either more than one Deal Score '+
          'header exists for selected Dcr Metrics:deal_id:size:'+deal_id+dsh_list.size());
          DcrMetrics = null;
        } else if(dsh_list.size() == 0) {
          system.debug('getDcrMetrics:No Deal Score '+
          'header exists for selected DCR Metrics:deal_id:size:'+deal_id+dsh_list.size());
          DcrMetrics = null;
        } else {                   
             List<Deal_Score_Line_Item__c> line_list = [
            SELECT
            id,Deal_Score_Header__c,Financial_Metric_Name__c,Financial_Metric_Period_Text__c,Financial_Metric_Period_Ended__c,
            Financial_Metric_Value__c,Financial_Metric_Unit__c,Is_Financial_Metric_Imported__c, Line_Item_Title__c
            FROM Deal_Score_Line_Item__c
            WHERE ((Deal_Score_Header__c =:sch_id) AND (Line_Item_Title__c = 'Financial Metric'))
             ORDER BY Is_Financial_Metric_Imported__c DESC, Financial_Metric_Period_Ended__c DESC
            ];
 
            Integer outer_loop,inner_loop,row_count=0;
            Boolean other_metric_found,is_item_done;
            List<String> items_done = new List<String>();
            items_done.clear();
            
            for(outer_loop=0; outer_loop<line_list.size(); ++outer_loop){
              other_metric_found=is_item_done=false;
              
              for(String temp_item_name:items_done){
                if(temp_item_name.equalsIgnoreCase(line_list[outer_loop].Financial_Metric_Name__c) ){
                  is_item_done=true;
                  break;
                }               
              }
              if(is_item_done==true){
                system.debug('getDcrMetrics:item is already covered:'+line_list[outer_loop]);
                continue;/*takes to the begining of the loop*/
              }
                         
              for(inner_loop=outer_loop+1; inner_loop<line_list.size(); ++inner_loop){
                if(line_list[outer_loop].Financial_Metric_Name__c.equalsIgnoreCase(line_list[inner_loop].Financial_Metric_Name__c) ){
                  other_metric_found=true;
                  break;
                }
              }
              
              DCR_Metric_Info dcr_metric_item = new DCR_Metric_Info();
              dcr_metric_item.name  = line_list[outer_loop].Financial_Metric_Name__c;
              
              if(other_metric_found==true) {
                  
                dcr_metric_item.value = '<table style="border-collapse: collapse;" cellspacing=1 cellpadding=1 border=0 width=225><tr style=\";vertical-align:top;\">'+
                  '<td style=\"width:70px;text-align:right;\"><b>'+line_list[inner_loop].Financial_Metric_Period_Text__c+'</b></td>' +
                  '<td style=\"width:80px;text-align:right;\" >'+ isNull(line_list[inner_loop].Financial_Metric_Value__c) + '</td>' +
                  '<td style=\"width:70px;text-align:left;\">'+ isNull(line_list[inner_loop].Financial_Metric_Unit__c)  + '</td></tr></table>';              
              }

                if((row_count ==0) ||(row_count == 1) ||(Math.mod(row_count,2) ==0)){
                   if(Math.mod(row_count,2) ==0) {
                   dcr_metric_item.beginRowSwitch =true;
                   row_count=0;
                  } else {
                   dcr_metric_item.beginRowSwitch =false;
                  }               
                  if(row_count == 1) {
                    dcr_metric_item.endRowSwitch =true;
                    ++row_count;
                  } else {
                    dcr_metric_item.endRowSwitch =false;
                    ++row_count;
                  }
                } else {
                  dcr_metric_item.beginRowSwitch =false;
                  dcr_metric_item.endRowSwitch =false;
                  ++row_count;                
                }  
                 
              if(dcr_metric_item.value == '') {
                dcr_metric_item.value = dcr_metric_item.value +
                '<table style="border-collapse: collapse;" cellspacing=1 cellpadding=1 border=0 width=225><tr style=\";vertical-align:top;\">'+
                  '<td style=\"width:70px;text-align:right;\"><b>'+line_list[outer_loop].Financial_Metric_Period_Text__c+'</b></td>'+
                  '<td style=\"width:80px;text-align:right;\">'+ isNull(line_list[outer_loop].Financial_Metric_Value__c) +'</td>'+
                  '<td style=\"width:70px;text-align:left;\">'+ isNull(line_list[outer_loop].Financial_Metric_Unit__c) + '</td></tr></table>' ;  
                dcr_metric_item.css ='20px';
                  
               } else {
                dcr_metric_item.value = dcr_metric_item.value +
                  '<table style="border-collapse: collapse;" cellspacing=1 cellpadding=1 border=0 width=225><tr style=\";vertical-align:top;\">'+
                  '<td style=\"width:70px;text-align:right;\"><b>'+line_list[outer_loop].Financial_Metric_Period_Text__c+'</b></td>'+
                  '<td style=\"width:80px;text-align:right;\">'+ isNull(line_list[outer_loop].Financial_Metric_Value__c) +'</td>'+
                  '<td style=\"width:70px;text-align:left;\">'+ isNull(line_list[outer_loop].Financial_Metric_Unit__c) + '</td></tr></table>' ;
                dcr_metric_item.css ='40px';
               }               
               items_done.add(line_list[outer_loop].Financial_Metric_Name__c);
               DcrMetrics.add(dcr_metric_item);
               system.debug('getDcrMetrics:Added item to list: size:item:'+DcrMetrics.size()+':'+dcr_metric_item);
            }
        }    
        system.debug('getDcrMetrics:Final list is:size:list:'+DcrMetrics.size()+':'+DcrMetrics);        
        return  DcrMetrics;
   }        
   
   
}