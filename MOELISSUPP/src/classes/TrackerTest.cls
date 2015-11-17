/**
* Test methods are in Test_Timetracker.cls // should be in another class...
**/
public with sharing class TrackerTest 
{
		public String testName = '';
        public boolean isTest {get;set;}

        public String SelProjItem {get; set;}
        
        public boolean canDelete { get; set; }
        public String jsonContent { get; set; }
        
        public Ibanking_Project__c getCurrDealObj() 
        {
            if(SelProjItem!=null && SelProjItem!='') {
                Ibanking_Project__c retObj = [select ID,Name from Ibanking_Project__c where id=:SelProjItem limit 1]; 
                return retObj; 
            }
            return null;
        }
        public TrackerTest() {
            isTest = false;
            if(System.currentPageReference().getParameters().get('pid')!=null && System.currentPageReference().getParameters().get('pid')!='') {
                SelProjItem = System.currentPageReference().getParameters().get('pid'); 
            }
	           
            this.canDelete = false;
	        list<Profile> prof = null;
	        prof = [	Select Id 
	           			From Profile 
	           			Where (Name='SP Moelis IT' OR Name = 'System Administrator' OR Name='SP Moelis Mgmt Team' OR Name='SP Moelis Project Admin' OR Name='System Admin w/o IR permissions')
	           					AND Id=:UserInfo.getProfileId() 
	           			];
	        if(prof.size()>0) this.canDelete = true;
        }

        public PageReference cancel() {
            return null;
        }        

        public static Date parceDate(String dateVal) {
            Date contactDate = null;
                try {
                	system.debug('Date parceDate --- value (dateVal) '+dateVal);
                	if(dateVal != '')
                	{
                    	String[] parVal = dateVal.split('/');
                    	if(parVal!=null && parVal.size()==3)
                    	{
                    		integer dayVal = integer.valueOf(parVal[1]);
                    		integer monthVal = integer.valueOf(parVal[0]);
		                    integer yearVal = integer.valueOf(parVal[2]);
		                    
        		            contactDate = date.newInstance(yearVal, monthVal, dayVal);
                    	}
                	}
                } catch (Exception e) {}
            return contactDate;
        }
        
        
        
        
        public String deleleString{ get; set; }
        public String rowsString { get; set; }
        public String tableString { get; set; }
        
        public void saveObj() 
        {
        	system.debug('Save Time Start -------------->'+System.now());
        	system.debug('rowsString -------------->'+rowsString);
        	system.debug('tableString -------------->'+tableString);
        	
        	
        	this.deleteObj();
        	
        	List<Potential_Buyer_Investor__c> tbList = new List<Potential_Buyer_Investor__c>();
            Potential_Buyer_Investor__c tb;
            string dateVal;
            Date dDateVal;
            boolean changed;
            Decimal dDecimalVal;
           
        	
        	
        	String[] rowList = new List<String>();
        	if(rowsString!= null && rowsString != '')
        	{
		        if(rowsString.contains(':')) rowList = rowsString.split(':');
		        else rowList.add(rowsString);
        	}
        	String[] tableList = new List<String>();
        	if(tableString != null && tableString != '')
        	{
		        if(tableString.contains(':')) tableList = tableString.split(':');
		        else tableList.add(tableString);
        	}
        	Integer rowList_size = rowList.size(); 
        	Integer tableList_size = tableList.size(); 
        	system.debug('rowList_size---------------tableList_size-------------'+rowList_size+' '+tableList_size);
        	if(rowList_size > 0 && tableList_size  > 0 && rowList_size == tableList_size )
        	{
	        	Decimal X1st_Round_Bid_High_mm;
	        	Decimal X1st_Round_Bid_Low_mm;
	        	Decimal X2nd_Round_Bid_High_mm;
	        	Decimal X2nd_Round_Bid_Low_mm;
	        	Decimal X3rd_Round_Bid_High_mm;
	        	Decimal X3rd_Round_Bid_Low_mm;
	        	for (integer i = 0; i < tableList_size; i++)
		        {
		        	String valueId = rowList[i]; // Potential_Buyer_Investor record Id (row)
		        	system.debug('valueId------------------->'+valueId);
		        	if(tableList[i].contains('|')) 
		        	{	
		        		String[] tablerowList0 = tableList[i].split('\\|',28);
		        		system.debug('valueId---------------'+valueId);
		        		system.debug('tableList[i]---------------'+tableList[i]);
		        		system.debug('tablerowList0---------------'+tablerowList0);
		        		system.debug('tablerowList0[26]---------------'+tablerowList0[26]);
		        		if(tablerowList0.size() > 0)
		        		{
			        		// Insert new rows
			        		if(valueId.compareTo('new_')>0)
							{
								try {
									X1st_Round_Bid_High_mm = X1st_Round_Bid_Low_mm = X2nd_Round_Bid_High_mm = X2nd_Round_Bid_Low_mm = X3rd_Round_Bid_High_mm = X3rd_Round_Bid_Low_mm = null;
									try	{X1st_Round_Bid_High_mm = Decimal.valueOf(tablerowList0[16].replaceAll(',', ''));	} catch (Exception e){ }
									try	{X1st_Round_Bid_Low_mm = Decimal.valueOf(tablerowList0[17].replaceAll(',', ''));	} catch (Exception e){ }
									try	{X2nd_Round_Bid_High_mm = Decimal.valueOf(tablerowList0[20].replaceAll(',', ''));	} catch (Exception e){ }
									try	{X2nd_Round_Bid_Low_mm = Decimal.valueOf(tablerowList0[21].replaceAll(',', ''));	} catch (Exception e){ }
									try	{X3rd_Round_Bid_High_mm = Decimal.valueOf(tablerowList0[24].replaceAll(',', ''));	} catch (Exception e){ }
									try	{X3rd_Round_Bid_Low_mm = Decimal.valueOf(tablerowList0[25].replaceAll(',', ''));	} catch (Exception e){ }
									tb = new Potential_Buyer_Investor__c(
										Project__c = SelProjItem,
										TargetBuyer__c = (tablerowList0[1]!=null ? tablerowList0[1] : null),										
										Type__c = (tablerowList0[2]!=null ? tablerowList0[2] : null),					
										Status__c = (tablerowList0[3]!=null ? tablerowList0[3] : null),					
										Initial_Contact_Made__c = MilestoneTracker.parceDate(tablerowList0[4]),	
										Teaser_Sent__c = MilestoneTracker.parceDate(tablerowList0[5]),			
										CA_Sent__c = MilestoneTracker.parceDate(tablerowList0[6]),				 
										CA_Under_Negotiation__c = MilestoneTracker.parceDate(tablerowList0[7]),	
										CA_Signed__c = MilestoneTracker.parceDate(tablerowList0[8]),						
										CIM_Info_Package_Sent__c = MilestoneTracker.parceDate(tablerowList0[9]),
										CIM_Info_Package_Returned__c = MilestoneTracker.parceDate(tablerowList0[10]),
										CIM_Number__c = tablerowList0[11],
										Mgmt_Presentation__c = MilestoneTracker.parceDate(tablerowList0[12]),
										Data_Room_Access__c = MilestoneTracker.parceDate(tablerowList0[13]),
										X1st_Round_Bid_Process_Letter_Sent__c = MilestoneTracker.parceDate(tablerowList0[14]),
										X1st_Round_Bid_Received__c = MilestoneTracker.parceDate(tablerowList0[15]),
										X1st_Round_Bid_High_mm__c = X1st_Round_Bid_High_mm,
										X1st_Round_Bid_Low_mm__c = X1st_Round_Bid_Low_mm,
										X2nd_Round_Bid_Process_Letter_Sent__c = MilestoneTracker.parceDate(tablerowList0[18]),
										X2nd_Round_Bid_Received__c = MilestoneTracker.parceDate(tablerowList0[19]),
										X2nd_Round_Bid_High_mm__c = X2nd_Round_Bid_High_mm,
										X2nd_Round_Bid_Low_mm__c = X2nd_Round_Bid_Low_mm,
										X3rd_Round_Bid_Process_Letter_Sent__c = MilestoneTracker.parceDate(tablerowList0[22]),
										X3rd_Round_Bid_Received__c = MilestoneTracker.parceDate(tablerowList0[23]),
										X3rd_Round_Bid_High_mm__c = X3rd_Round_Bid_High_mm,
										X3rd_Round_Bid_Low_mm__c = X3rd_Round_Bid_Low_mm,
										Declined__c = MilestoneTracker.parceDate(tablerowList0[26])
									);
								}	catch	(Exception ex){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));}
								if(tb != null)	tbList.add(tb);
							}
							else // Update rows
							{
								tb = [Select 
				                	 t.Declined__c,
				                	 t.X3rd_Round_Bid_Received__c,				t.X3rd_Round_Bid_Low_mm__c,		t.X3rd_Round_Bid_High_mm__c,	t.X2nd_Round_Bid_Received__c,
				                     t.X2nd_Round_Bid_Process_Letter_Sent__c,	t.X2nd_Round_Bid_Low_mm__c, 	t.X2nd_Round_Bid_High_mm__c,	t.X1st_Round_Bid_Received__c,
				                     t.X1st_Round_Bid_Low_mm__c,				t.X1st_Round_Bid_High_mm__c,	t.Type__c, t.Teaser_Sent__c,	t.Status__c,
				                     t.Mgmt_Presentation__c,					t.Data_Room_Access__c,			t.Initial_Contact_Made__c,		t.CIM_Info_Package_Sent__c,
				                     t.CIM_Number__c,							t.CIM_Info_Package_Returned__c,	t.CA_Under_Negotiation__c,		t.CA_Signed__c,
				                     t.CA_Sent__c,								t.X1st_Round_Bid_Process_Letter_Sent__c,						t.X3rd_Round_Bid_Process_Letter_Sent__c,
				                     t.TargetBuyer__c
				                From Potential_Buyer_Investor__c t where t.id=:valueId];
				                changed = false;
				                //TargetBuyer
				                try {
					                system.debug('TargetBuyer ----------->');//+tablerowList0[1]);
					                if(tablerowList0[1] != null && tablerowList0[1] != '' && tb.TargetBuyer__c != tablerowList0[1]) {
					                    tb.TargetBuyer__c = tablerowList0[1];
					                    changed = true; 
					                }
				                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
				                //Type
				                try {
					                system.debug('Type ----------->');//+tablerowList0[2]);
					                if(tablerowList0[2] != null && tb.Type__c != tablerowList0[2]) {
					                    tb.Type__c = tablerowList0[2];
					                    changed = true; 
					                }
				                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
				                //Status
				                try {
				                	system.debug('Status ----------->');//+tablerowList0[3]);
					                if(tablerowList0[3] != null && tb.Status__c != tablerowList0[3]) {
					                    tb.Status__c = tablerowList0[3];
					                    changed = true; 
					                }
				                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
				                //Contact Made
				                try{
				                	if(tablerowList0[4] != null)
				                	{
					                system.debug('Contact Made ----------->'+tablerowList0[4]);
					                dDateVal = MilestoneTracker.parceDate(tablerowList0[4]);
					                system.debug('dDateVal ----------->'+dDateVal);
					                if(tb.Initial_Contact_Made__c != dDateVal) {
					                	tb.Initial_Contact_Made__c = dDateVal;
					                    changed = true; 
					                }
				                	}
				                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
								//Teaser Sent
	                try{
	                 system.debug('Teaser Sent ----------->'+tablerowList0[5]);
		                dDateVal = MilestoneTracker.parceDate(tablerowList0[5]);
		                if(tb.Teaser_Sent__c != dDateVal) {
		                    tb.Teaser_Sent__c = dDateVal;
		                    changed = true; 
		                }
	                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
	                //CA Sent
	                try{
		                dDateVal = MilestoneTracker.parceDate(tablerowList0[6]);
		                if(tb.CA_Sent__c != dDateVal) {
		                    tb.CA_Sent__c = dDateVal;
		                    changed = true; 
		                }
	                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
	               
	                //CA_Under_Negotiation
	                try{
		                dDateVal = MilestoneTracker.parceDate(tablerowList0[7]);
		                if(tb.CA_Under_Negotiation__c != dDateVal) {
		                    tb.CA_Under_Negotiation__c = dDateVal;
		                    changed = true; 
		                }
	                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
	                //CA_Signed
	                try{
		                dDateVal = MilestoneTracker.parceDate(tablerowList0[8]);
		                if(tb.CA_Signed__c != dDateVal) {
		                    tb.CA_Signed__c = dDateVal;
		                    changed = true; 
		                }
	                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
	                System.debug('================= ' + testName);
	                //CIM Sent
	                try{
		                dDateVal = MilestoneTracker.parceDate(tablerowList0[9]);
		                if(tb.CIM_Info_Package_Sent__c != dDateVal) {
		                    tb.CIM_Info_Package_Sent__c = dDateVal;
		                    changed = true; 
		                }
	                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
	                //CIM_Info_Package_Returned
	                try{
		                dDateVal = MilestoneTracker.parceDate(tablerowList0[10]);
		                if(tb.CIM_Info_Package_Returned__c != dDateVal) {
		                    tb.CIM_Info_Package_Returned__c = dDateVal;
		                    changed = true; 
		                }
	                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
	                 //CIM Number
	                try{
		                dateVal = tablerowList0[11];
		                if(tb.CIM_Number__c != dateVal) {
		                    if(dateVal==null || dateVal=='') tb.CIM_Number__c = null;
		                    else tb.CIM_Number__c = dateVal;
		                    changed = true; 
		                }
	                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
	                
	                //Mgmt_Presentation
	                try{
		                dDateVal = MilestoneTracker.parceDate(tablerowList0[12]);
		                if(tb.Mgmt_Presentation__c != dDateVal) {
		                    tb.Mgmt_Presentation__c = dDateVal;
		                    changed = true; 
		                }
	                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
	               
	                //Data_Room_Access
	                try{
		                dDateVal = MilestoneTracker.parceDate(tablerowList0[13]);
		                if(tb.Data_Room_Access__c != dDateVal) {
		                    tb.Data_Room_Access__c = dDateVal;
		                    changed = true; 
		                }
	                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
	                //X1st_Round_Bid_Process_Letter_Sent
	                try{
		                dDateVal = MilestoneTracker.parceDate(tablerowList0[14]);
		                if(tb.X1st_Round_Bid_Process_Letter_Sent__c != dDateVal) {
		                    tb.X1st_Round_Bid_Process_Letter_Sent__c = dDateVal;
		                    changed = true; 
		                }
	                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
	                //X1st_Round_Bid_Received
	                try{
		                dDateVal = MilestoneTracker.parceDate(tablerowList0[15]);
		                if(tb.X1st_Round_Bid_Received__c != dDateVal) {
		                    tb.X1st_Round_Bid_Received__c = dDateVal;
		                    changed = true; 
		                }
	                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
	                
	                //X1st_Round_Bid_High_mm
						try
						{
							if (tablerowList0[16] != null) 
							{
								dateVal = tablerowList0[16];
								system.debug('X1st_Round_Bid_High_mm---------->'+dateVal);
								dateVal =  dateVal.replaceAll(',', '');
								if (dateVal == null || dateVal == '') dDecimalVal = 0;
				                else dDecimalVal = Decimal.valueOf(dateVal);
				                if(dDecimalVal==0) dDecimalVal=null;
				                
								if(tb.X1st_Round_Bid_High_mm__c != dDecimalVal) {
			                    	tb.X1st_Round_Bid_High_mm__c = dDecimalVal;
			                    	changed = true; 
			                	}
							}
						} catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
	                
	                //X1st_Round_Bid_Low_mm
						try
						{
							if (tablerowList0[17] != null) 
							{
				                dateVal = tablerowList0[17];
				                dateVal =  dateVal.replaceAll(',', '');
				                if (dateVal == null || dateVal == '') dDecimalVal = 0;
				                else dDecimalVal = Decimal.valueOf(dateVal);
				                if(dDecimalVal==0) dDecimalVal=null;
				                
				                if(tb.X1st_Round_Bid_Low_mm__c != dDecimalVal) {
				                    tb.X1st_Round_Bid_Low_mm__c = dDecimalVal;
				                    changed = true; 
				                }
							}
		            	} catch (Exception e){
		            		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));
						}
					
					
	                 //X2nd_Round_Bid_Process_Letter_Sent
	                try{
		                dDateVal = MilestoneTracker.parceDate(tablerowList0[18]);
		                if(tb.X2nd_Round_Bid_Process_Letter_Sent__c != dDateVal) {
		                    tb.X2nd_Round_Bid_Process_Letter_Sent__c = dDateVal;
		                    changed = true; 
		                }
	                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
	                 //X2nd_Round_Bid_Received
	                try{
		                dDateVal = MilestoneTracker.parceDate(tablerowList0[19]);
		                if(tb.X2nd_Round_Bid_Received__c != dDateVal) {
		                    tb.X2nd_Round_Bid_Received__c = dDateVal;
		                    changed = true; 
		                }
	                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
	               
	                //X2nd_Round_Bid_High_mm
						try
						{
							if (tablerowList0[20] != null) 
							{
			                dateVal = tablerowList0[20];
			                dateVal =  dateVal.replaceAll(',', '');
			                if (dateVal == null || dateVal == '') dDecimalVal = 0;
			                else dDecimalVal = Decimal.valueOf(dateVal);
			                if(dDecimalVal==0) dDecimalVal=null;
			                
			                if(tb.X2nd_Round_Bid_High_mm__c != dDecimalVal) {
			                    tb.X2nd_Round_Bid_High_mm__c = dDecimalVal;
			                    changed = true; 
			                }
							}
	                	} catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
					
	                //X2nd_Round_Bid_Low_mm
						try
						{
							if (tablerowList0[21] != null) 
							{
				                dateVal = tablerowList0[21];
				                dateVal =  dateVal.replaceAll(',', '');
				                if (dateVal == null || dateVal == '') dDecimalVal = 0;
			                	else dDecimalVal = Decimal.valueOf(dateVal);
			                	if(dDecimalVal==0) dDecimalVal=null;
			                	
				                if(tb.X2nd_Round_Bid_Low_mm__c != dDecimalVal) {
				                    tb.X2nd_Round_Bid_Low_mm__c = dDecimalVal;
				                    changed = true; 
				                }
							}
	                	} catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
					
					
	                //X3rd_Round_Bid_Process_Letter_Sent
	                try{
		                dDateVal = MilestoneTracker.parceDate(tablerowList0[22]);
		                if(tb.X3rd_Round_Bid_Process_Letter_Sent__c != dDateVal) {
		                    tb.X3rd_Round_Bid_Process_Letter_Sent__c = dDateVal;
		                    changed = true; 
		                }
	                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
	                //X3rd_Round_Bid_Received
	                try{
		                dDateVal = MilestoneTracker.parceDate(tablerowList0[23]);
		                if(tb.X3rd_Round_Bid_Received__c != dDateVal) {
		                    tb.X3rd_Round_Bid_Received__c = dDateVal;
		                    changed = true; 
		                }
	                } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
	                 
	                 //X3rd_Round_Bid_High_mm
						try
						{
							if (tablerowList0[24] != null) 
							{
			                dateVal = tablerowList0[24];
			                dateVal =  dateVal.replaceAll(',', '');
			                if (dateVal == null || dateVal == '') dDecimalVal = 0;
		               		else dDecimalVal = Decimal.valueOf(dateVal);
		               		if(dDecimalVal==0) dDecimalVal=null;
		               		
			                if(tb.X3rd_Round_Bid_High_mm__c != dDecimalVal) {
			                    tb.X3rd_Round_Bid_High_mm__c = dDecimalVal;
			                    changed = true; 
			                }
							}
	                	} catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
					
	                 //X3rd_Round_Bid_Low_mm
	               
						try
						{ 
							if (tablerowList0[25] != null) 
							{
			                dateVal = tablerowList0[25];
			                dateVal =  dateVal.replaceAll(',', '');
			                if (dateVal == null || dateVal == '') dDecimalVal = 0;
		                	else dDecimalVal = Decimal.valueOf(dateVal);
		                	if(dDecimalVal==0) dDecimalVal=null;
		                	
			                if(tb.X3rd_Round_Bid_Low_mm__c != dDecimalVal) {
			                    tb.X3rd_Round_Bid_Low_mm__c = dDecimalVal;
			                    changed = true; 
			                }
							}
	                	} catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));}
					
	
				                if (isTest == false) {
				                    //Final Bid
				                    try{
				                    	if(tablerowList0[26] != null)
					                	{
						                    dDateVal = MilestoneTracker.parceDate(tablerowList0[26]);
						                    if(tb.Declined__c != dDateVal) 
						                    {
						                        tb.Declined__c = dDateVal;
						                        changed = true; 
						                    }
				                		}
				                    } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() )); }
				    
				                    if (changed)  tbList.add(tb);
				                    
				                }
							}
		        		}
		        	}
		        }// end for
		        if(tbList.size()>0) try{ upsert tbList; } catch (Exception e){}
        	}
        	system.debug('Save Time End -------------->'+System.now());
        }
        
        public void deleteObj() 
        {
        	system.debug('deleleList -------------->'+deleleString);
        	if( deleleString != null && deleleString != '')
	        {
	        	String[] deleleList = new List<String>();
	        	if(deleleString.contains(','))  deleleList = deleleString.split(',');
	        	else deleleList.add(deleleString);
	        	
	        	Potential_Buyer_Investor__c tmpTrack;
	        	List<Potential_Buyer_Investor__c> delListObj= new List<Potential_Buyer_Investor__c>();
	        	for (integer i = 0; i < deleleList.size() ; i++)
	        	{
	                system.debug('deleleList['+i+'] -------------->'+deleleList[i]);
	                tmpTrack = new Potential_Buyer_Investor__c(id = deleleList[i]);
	                delListObj.add(tmpTrack);
	                //delete tmpTrack;
	           }
	           if(delListObj.size() > 0) 
	           {
	           		try {delete delListObj;} 
	                catch (Exception ex){}
	           }
	        }
        }
        
    public PageReference save()
    {
     	this.saveObj(); 
        return null;
    }
     
    public PageReference save_close()
    {
     	this.saveObj(); 
     	PageReference pageRef = new PageReference('/'+SelProjItem);
		pageRef.setRedirect(true);
        return pageRef;
    } 
        
}