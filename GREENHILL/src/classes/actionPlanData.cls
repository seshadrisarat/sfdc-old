public class actionPlanData {
        String currFundName; 
        
        //new class to support the single Data table
        class closeData {
                Integer lineNum; 
                Opportunity fundDeal; 
                Decimal footerTotal;
                String groupHeader;
                String subReportName;
                
                //constructors
                public closeData(Opportunity opp) { fundDeal = opp;}
                public closeData(String header, Decimal total) { subReportName = header; footerTotal = total;}
                public closeData(String header) { groupHeader = header;}
                public closeData(Integer line, Opportunity opp) { lineNum = line; fundDeal = opp;}  
                public Opportunity getfundDeal() { return fundDeal;}
                
                
                public String getLineNumber() {
                        return String.valueOf(lineNum); 
                } 
                
                //build the first column text dynamically to keep the grid clean
                public String getFirstColText() {
                        if (lineNum != null) {
                                return String.valueOf(lineNum) + '.    ' + fundDeal.Account.Name;
                        } else if (groupHeader != null) {
                                return '<div style="position:relative"><div style="padding:3px 0 4px 5px;position:absolute;width:920px;background-color:#E1F2F2"><b>'+groupHeader+'</b></div></div><br/>'; 
                        } else if (footerTotal != null) {
                                return '<div style="position:relative"><div style="position:absolute;width:700px"><table cellpadding="0" cellspacing="0" border="0"><tr><td width="210"><b>Total '+subReportName+'</b></td><td width="99"><div align="right" style="text-align:right;"><b>' + String.valueOf(footerTotal)+'</b></div></td></tr></table></div></div><br/><br/>';
                        } else {
                                return null;
                        } 
                } 
                
                public String getBiteSize()
                {
                    if(lineNum != null && fundDeal <> null){
                    	if(fundDeal.Minimum_Commitment_Size__c == null && fundDeal.Maximum_Commitment_Size__c == null){
                    		return '';
                    	}
                    	else if(fundDeal.Minimum_Commitment_Size__c == null){
                    		return String.valueOf(fundDeal.Maximum_Commitment_Size__c);
                    	}
                    	else if(fundDeal.Maximum_Commitment_Size__c == null){
                    		return String.valueOf(fundDeal.Minimum_Commitment_Size__c);
                    	}
                    	else{
                    		return String.valueOf((fundDeal.Minimum_Commitment_Size__c + fundDeal.Maximum_Commitment_Size__c)/2);
                    	}
                   }
                    else {
                        return null;
                    } 
                }
                
                public String getfooterTotal() {
                        return String.valueOf(footerTotal); 
                }
                
                public String getGroupHeader() {
                        return groupHeader; 
                }
                
        }
        
        class closeDataList 
        {
            Integer ItemPos; 
            Close__c CloseDataInfo;
            closeData [] CloseRecordsList;
            
            public closeDataList(Close__c inC) { CloseDataInfo = inC;}
            public void setCloseRecords(List<closeData> inCData) { CloseRecordsList = inCData;}
            
            public List<closeData> getCloseRecordsList() { return CloseRecordsList;}
            public Close__c getCloseDataInfo() { return CloseDataInfo;} 
            public String getItemStyle() {
            	
            	if(ItemPos==1) return '';
            	else return 'page-break-before:always;';
            }
            public void ItemPosSet(Integer inVal)
            {
            	ItemPos = inVal;
            }
                
            
        }
        
        

        //get all closes for the fund passed in via the URL
        public Close__c[] getCloses() {
                return [select Id, Name, Close_Order__c, Fund__c, Fund__r.Name, Min_Amount__c, Max_Amount__c,Date__c
                                from Close__c where Fund__c = :ApexPages.currentPage().getParameters().get('fund') and Completed__c=FALSE
                                order by CloseOrderNum__c]; 
        }
        
        
        //the eventual return array
        closeData [] CloseRecords; 
        closeDataList [] CloseRecordsList; 

        public List<closeDataList> getCloseRecordsList()
        {
             Integer pos = 0;
             if (CloseRecordsList== null) {
                        CloseRecordsList = new closeDataList[]{};
                        
                        //run code for 1 to x closes attached to the fund
                        for (Close__c c : getCloses() ) 
                        {
                            closeData [] CloseRecordsPre = CloseRecordsNew(c);
                            closeDataList oCloseDataList = new  closeDataList(c);
                            oCloseDataList.setCloseRecords(CloseRecordsPre);
                            pos++;
                            oCloseDataList.ItemPosSet(pos);
                            CloseRecordsList.add( oCloseDataList );
                        }
             }
             return CloseRecordsList;
        }

        
        //getter method to build the objects for the dataTable(s)
        public List<closeData> CloseRecordsNew(Close__c c){
                //counters and adders
                Integer i = 0;  
                Decimal subTotal = 0; 
                Decimal StageTotal = 0; 
                String currStage = null; 
                
                
                        CloseRecords = new closeData[]{};
                        
                                //add header row for the StageName
                                //CloseRecords.add(new closeData(c.Close_Order__c + ' Close'));
                                
                                //get all the Opportunities for each Close
                                for  (Opportunity fundDeal: getCloseFundDeals(c.Id) ) {
                                        i++;
                                        //handle the changing stages (StageName)
                                        if (currStage == null) {
                                                CloseRecords.add (new closeData(fundDeal.StageName));
                                                currStage = fundDeal.StageName; 
                                        } else if (currStage != fundDeal.StageName) {
                                                //add StageTotal record, reset value 
                                                if(currStage=='Closed'){ CloseRecords.add (new closeData(''+currStage,stageTotal));}
                                                 stageTotal = 0;
                                                 
                                                 //open new stage, reset tracker
                                                 CloseRecords.add (new closeData(fundDeal.StageName)); 
                                                 currStage = fundDeal.StageName;
                                        }
                                        if(fundDeal.StageName=='Closed')
                                        {
                                        	subTotal += (fundDeal.Minimum_Commitment_Size__c + fundDeal.Maximum_Commitment_Size__c)/2;
                                        	stageTotal += (fundDeal.Minimum_Commitment_Size__c + fundDeal.Maximum_Commitment_Size__c)/2;
                                        }
                                        
                                        //add main detail line with line number and FD object
                                        CloseRecords.add( new closeData(i, fundDeal) );
                                         
                                }
                                //add final Stage summary
                                if(currStage=='Closed'){ CloseRecords.add (new closeData(''+currStage, stageTotal));}
                                
                                //add Close summary row
                                // CloseRecords.add(new closeData(''+c.Close_Order__c+' Close',subTotal)); 
                return CloseRecords;
        }        

     //query to get the Opportunities based on passed in Close. note order by clause
     public Opportunity[] getCloseFundDeals(String currCloseId) { 
        return[Select Id, Name, Account.Name, Account.Consultant__c, Maximum_Commitment_Size__c, 
                        Minimum_Commitment_Size__c, NextStep, StageName, Description, 
                        Account.Sales_coverage__c, vced2__Fund__r.Name, Close__r.Name
                        from Opportunity where Close__c = :currCloseId
                        order by StageName];
    } 
    
    
    public void setFundName(String currFund){
            this.currFundName = currFund; 
        }
    
    public String getFundName(){
            vced2__Fund__c Fund = [select Id, Name from vced2__Fund__c where id = :ApexPages.currentPage().getParameters().get('fund')];
            
            return Fund.Name; 
        }
        
public static testMethod void testMyController()  {
      
        String testFundName; 
        String testFirstColText;
        
        actionPlanData controller = new actionPlanData();
        
        vced2__Fund__c testFund = new vced2__Fund__c (Name='testFund');
        insert testFund;
        
        Close__c testClose = new Close__c (Name='testCLose1',Close_Order__c='First', Fund__c = testFund.Id);
        insert testClose; 
        
        Opportunity testOpp = new Opportunity(Name='testOpp',vced2__Fund__c = testFund.Id, Close__c = testClose.Id, StageName='Circled', 
        	Maximum_Commitment_Size__c = 50,Minimum_Commitment_Size__c = 10, CloseDate=System.Today());
        insert testOpp;
        
        Opportunity testOpp2 = new Opportunity(Name='testOpp2',vced2__Fund__c = testFund.Id, Close__c = testClose.Id, StageName='Closed', 
        	Maximum_Commitment_Size__c =50,Minimum_Commitment_Size__c =50, CloseDate=System.Today());
        insert testOpp2;
        
        
        closeDataList [] testCloseRecords;
        
        
        
        
        PageReference pageRef = Page.ActionPlan;
        system.assert(testFund.Id != null); 
        
        // Add parameters to page URL
        pageRef.getParameters().put('fund', testFund.Id);
        
        Test.setCurrentPage(pageRef);
      // Add parameters to page URL
        pageRef.getParameters().put('fund', testFund.Id);
        
        
        //get the records for this page parameter
        testCloseRecords = controller.getCloseRecordsList(); 
         
        testFundName = controller.getFundName();
        
    	for ( actionPlanData.closeData i: testCloseRecords[0].CloseRecordsList) {
        	testFirstColText = i.getFirstColText(); 
	    	System.assert(testFirstColText <> '' );
        }
    

                
        controller.setFundName('testFund');
        
        
        // Verify that page fails without parameters
        System.assert(testCloseRecords[0].CloseRecordsList[1].fundDeal.Name <> '' );
        System.assert(testCloseRecords[0].CloseRecordsList[1].getBiteSize() <> '' );
        System.assert(testCloseRecords[0].CloseRecordsList[1].getLineNumber() <> '' );
        System.assert(testFirstColText <> '' );
        System.assert(testFundName <> '' );
             
    }            

}