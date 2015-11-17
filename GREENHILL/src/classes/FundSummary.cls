public class FundSummary {
         class closeSummaryData {
                Close__c CloseRec; 
                String subReportName;
                
                String colFirst;
                
                decimal colClosed;
                decimal colCircled;
                decimal colStrongInterest;
                decimal colContInterest;
                decimal colTotal;
           
                
                public String retCorrVal(decimal val)
                {
                    String retVal = '';
                    if(colFirst==''){ retVal = '';}
                    else if(val>0){ retVal = String.valueOf(val.setScale(2));}
                    else{ retVal = '-';}
                        
                    if(colFirst=='<b>Subtotal for Completed Closes </b>'
                            || colFirst=='<b>Total for All Closes </b>'
                            || colFirst=='<b>Total Probability Weighted </b>'){
                            return  '<b>'+retVal+'</b>';
                    }
                    else return retVal;
                }
                
                public String getcolFirst() {
                        return (colFirst); 
                }
                public String getcolClosed() {
                        if(colFirst=='Probability Weighted') return '100%';
                        else return retCorrVal(colClosed);
                }
                public String getcolCircled() {
                        if(colFirst=='Probability Weighted') return '75%';
                        else return retCorrVal(colCircled); 
                }
                public String getcolStrongInterest() {
                        if(colFirst=='Probability Weighted') return '50%';
                        else return retCorrVal(colStrongInterest); 
                }
                public String getcolContInterest() {
                        if(colFirst=='Probability Weighted') return '25%';
                        else return retCorrVal(colContInterest); 
                }
                public String getcolTotal() {
                        if(colFirst=='Probability Weighted') return '';
                        else return retCorrVal(colTotal); 
                }
                
                
                //constructors
                public closeSummaryData(String title) {colFirst = title;}
                public closeSummaryData(String firstCol, decimal Closed, decimal Circled, decimal StrongInterest, decimal ContInterest, decimal Total) { 
                        colFirst = firstCol; 
                        colClosed = Closed;
                        colCircled = Circled;
                        colStrongInterest = StrongInterest; 
                        colContInterest = ContInterest;
                        colTotal = Total;
                }
                
                
        }   
    
         public List<closeSummaryData> getCloseRecordsList()
        {
             Integer pos = 0;
             boolean closeCompleted = null; 
             
            decimal completedClosesTotalClosed = 0;
            decimal completedClosesTotalCircled = 0;
            decimal completedClosesTotalStrongInterest = 0;
            decimal completedClosesTotalContInterest = 0;
            decimal completedClosesTotal = 0;
            
            decimal completedSubClosed = 0;
            decimal completedSubCircled = 0;
            decimal completedSubStrongInterest = 0;
            decimal completedSubContInterest = 0;
            decimal completedSubTotal = 0;
            
            
            decimal probClosed  = 1; 
            decimal probCircled  = .75;
            decimal probStrongInterest  = .5;
            decimal probContInterest = .25;
            
            closeSummaryData [] CloseRecordsList;
            closeSummaryData tempCloseRec; 
                
             if (CloseRecordsList== null) {
                CloseRecordsList = new closeSummaryData[]{};
                
                //run code for 1 to x closes attached to the fund
                for (Close__c c : getCloses() ) 
                {
                    if (closeCompleted == null ) { 
                        closeCompleted = c.Completed__c;
                        tempCloseRec = CloseFundSummary(c, c.Close_Order__c);
                    } else if (closeCompleted == true && c.Completed__c == false) {
                        closeCompleted = c.Completed__c;
                        
                        completedSubClosed = completedClosesTotalClosed;
                                completedSubCircled = completedClosesTotalCircled;
                                completedSubStrongInterest = completedClosesTotalStrongInterest;
                                completedSubContInterest = completedClosesTotalContInterest;
                                completedSubTotal = completedClosesTotal;
                         
                        //below moved to bottom of report per Andrew from Greenhill 9-18-08 
                        //add total for completed closes
                        //CloseRecordsList.add( new closeSummaryData('<b>Subtotal for Completed Closes </b>',completedClosesTotalClosed,completedClosesTotalCircled,completedClosesTotalStrongInterest,completedClosesTotalContInterest,completedClosesTotal));
                        //CloseRecordsList.add( new closeSummaryData(''));
                    }
                    
                    //get rolled up Opp values for Close
                    tempCloseRec = CloseFundSummary(c, c.Close_Order__c);
                    
                    //update totals
                    completedClosesTotalClosed += tempCloseRec.colClosed;
                    completedClosesTotalCircled += tempCloseRec.colCircled;
                    completedClosesTotalStrongInterest += tempCloseRec.colStrongInterest;
                    completedClosesTotalContInterest += tempCloseRec.colContInterest;
                    completedClosesTotal += tempCloseRec.colTotal; 
                    
                        
                    CloseRecordsList.add( tempCloseRec);
                }
                
                CloseRecordsList.add( new closeSummaryData(''));
                //add total for completed closes
                                CloseRecordsList.add( new closeSummaryData('<b>Subtotal for Completed Closes </b>',completedSubClosed,completedSubCircled,completedSubStrongInterest,completedSubContInterest,completedSubTotal));
                                
                CloseRecordsList.add( new closeSummaryData(''));
                //add grand total for all Closes
                CloseRecordsList.add( new closeSummaryData('<b>Total for All Closes </b>',completedClosesTotalClosed,completedClosesTotalCircled,completedClosesTotalStrongInterest,completedClosesTotalContInterest,completedClosesTotal));
                             
                CloseRecordsList.add( new closeSummaryData(''));
                                
                //add probability title line
                CloseRecordsList.add(new closeSummaryData('Probability Weighted'));
                
                //add probability weighted values 
                CloseRecordsList.add( 
                    new closeSummaryData('<b>Total Probability Weighted </b>',
                                        completedClosesTotalClosed * probClosed,
                                        completedClosesTotalCircled * probCircled,
                                        completedClosesTotalStrongInterest * probStrongInterest,
                                        completedClosesTotalContInterest * probContInterest,
                                            (
                                                (completedClosesTotalClosed * probClosed) +
                                                (completedClosesTotalCircled * probCircled) + 
                                                (completedClosesTotalStrongInterest * probStrongInterest) + 
                                                (completedClosesTotalContInterest * probContInterest)
                                            )
                                        )
                                    );
             
             }
             return CloseRecordsList;
        }
        
        public closeSummaryData CloseFundSummary (Close__c c, String CloseOrderName){
                //counters and adders
                Integer i = 0;  

                decimal closeTotalClosed = 0;
                decimal closeTotalCircled = 0;
                decimal closeTotalStrongInterest = 0;
                decimal closeTotalContInterest = 0;
                decimal closeTotal = 0;
                    
                closeSummaryData CloseRecord;
                 
                //get all the Opportunities for each Close and summarize
                for  (Opportunity fundDeal: getCloseFundDeals(c.Id) ) {
                        i++;
                        
                        closeTotal += (fundDeal.Minimum_Commitment_Size__c + fundDeal.Maximum_Commitment_Size__c)/2;                                        
                        
                        //increment the Close counters
                        if (fundDeal.StageName == 'Closed') {
                            closeTotalClosed += (fundDeal.Minimum_Commitment_Size__c + fundDeal.Maximum_Commitment_Size__c)/2;
                        } else if (fundDeal.StageName == 'Circled') {
                            closeTotalCircled += (fundDeal.Minimum_Commitment_Size__c + fundDeal.Maximum_Commitment_Size__c)/2;
                        } else if (fundDeal.StageName == 'Strong Interest') {
                            closeTotalStrongInterest += (fundDeal.Minimum_Commitment_Size__c + fundDeal.Maximum_Commitment_Size__c)/2;
                        } else if (fundDeal.StageName == 'Continued Interest') {
                            closeTotalContInterest += (fundDeal.Minimum_Commitment_Size__c + fundDeal.Maximum_Commitment_Size__c)/2;
                        } else {
                        }
                                                                            
                }
                 //add Close summary line
                CloseRecord = new closeSummaryData(''+CloseOrderName+' Close ('+ c.Date__c.month()+'/'+c.Date__c.year()+')',closeTotalClosed,closeTotalCircled,closeTotalStrongInterest,closeTotalContInterest,closeTotal);

                return CloseRecord;
        }        
            
    
        //get all closes for the fund passed in via the URL
        public Close__c[] getCloses() {
                return [select Id, Name, Close_Order__c, Fund__c, Fund__r.Name, Min_Amount__c, Max_Amount__c,Date__c, Completed__c
                                from Close__c where Fund__c = :ApexPages.currentPage().getParameters().get('fund')
                                order by Completed__c desc , CloseOrderNum__c]; 
        }
        
        //query to get the Opportunities based on passed in Close. note order by clause
        public Opportunity[] getCloseFundDeals(String currCloseId) { 
        return[Select Id, Name, Account.Name, Account.Consultant__c, Maximum_Commitment_Size__c, 
                        Minimum_Commitment_Size__c, NextStep, StageName, Description, 
                        Account.Sales_coverage__c, vced2__Fund__r.Name, Close__r.Name, Close__r.Date__c
                        from Opportunity where Close__c = :currCloseId and StageName in ('Closed','Circled','Strong Interest','Continued Interest')
                        order by StageName] ;
        }
        
        public String getFundName(){
            vced2__Fund__c Fund = [select Id, Name from vced2__Fund__c where id = :ApexPages.currentPage().getParameters().get('fund')];
            
            return Fund.Name; 
        }


public static testMethod void testMyController()  {
      
        String testFundName; 
        String testFirstColText;
        String testColClosed; 
        
        FundSummary controller = new FundSummary();
        
        vced2__Fund__c testFund = new vced2__Fund__c (Name='testFund');
        insert testFund;
        
        Close__c testClose = new Close__c (Name='testClose1',Close_Order__c='First', Fund__c = testFund.Id, 
                Date__c = System.today(), Completed__c = TRUE);
        insert testClose; 
        
        Close__c testClose2 = new Close__c (Name='testClose2',Close_Order__c='Second', Fund__c = testFund.Id, 
                Date__c = System.today(), Completed__c = FALSE);
        insert testClose2;
        
                
        Opportunity testOpp = new Opportunity(Name='testOpp',vced2__Fund__c = testFund.Id, Close__c = testClose.Id, StageName='Closed', 
                Maximum_Commitment_Size__c = 10,Minimum_Commitment_Size__c = 10, CloseDate=System.Today());
        insert testOpp;
        
        Opportunity testOpp2 = new Opportunity(Name='testOpp2',vced2__Fund__c = testFund.Id, Close__c = testClose.Id, StageName='Closed', 
                Maximum_Commitment_Size__c =50,Minimum_Commitment_Size__c =50, CloseDate=System.Today());
        insert testOpp2;
        
        
        Opportunity testOpp3 = new Opportunity(Name='testOpp3',vced2__Fund__c = testFund.Id, Close__c = testClose2.Id, StageName='Strong Interest', 
                Maximum_Commitment_Size__c = 50,Minimum_Commitment_Size__c = 10, CloseDate=System.Today());
        insert testOpp3;
        
        Opportunity testOpp4 = new Opportunity(Name='testOpp4',vced2__Fund__c = testFund.Id, Close__c = testClose2.Id, StageName='Continued Interest', 
                Maximum_Commitment_Size__c =50,Minimum_Commitment_Size__c =50, CloseDate=System.Today());
        insert testOpp4;
        
        
        
        closeSummaryData [] testCloseRecords;
        
        
        
        
        PageReference pageRef = Page.FundSummary;
        system.assert(testFund.Id != null); 
        
        // Add parameters to page URL
        pageRef.getParameters().put('fund', testFund.Id);
        
        Test.setCurrentPage(pageRef);
        
        
        //get the records for this page parameter
        testCloseRecords = controller.getCloseRecordsList(); 
         
        testFundName = controller.getFundName();
        
        for ( FundSummary.closeSummaryData i: testCloseRecords) { 
                System.assert(i.getcolFirst() <> null );
                testColClosed = i.getcolClosed();
        }
    

        
        // Verify that page fails without parameters
        System.assert(testFirstColText <> '' );
        System.assert(testFundName <> '' );
             
    }            
}