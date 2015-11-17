/*
Modified: Privlad 02/23/2010 - task: 956
modified: Vika 03/19/2010 - Task #10065
modified: yuguziy 04/08/2010 - Task #10249
modified: Vika 05/12/2010 - Task #10350
*/
public class MilestoneTracker 
{
        public String testName = '';
        public boolean isTest {get;set;}
        public List<selectOption> lProjects = null;
        public String SelProjItem {get; set;}
        public String testData {get; set;}
        public boolean canDelete { get; set; }
        public string jsonContent { get; set; }
        
        public Ibanking_Project__c getCurrDealObj() 
        {
            if(SelProjItem!=null && SelProjItem!='') {
                Ibanking_Project__c retObj = [select ID,Name from Ibanking_Project__c where id=:SelProjItem limit 1]; 
                return retObj; 
            }
            return null;
        }
        public MilestoneTracker() {
            isTest = false;
            if(System.currentPageReference().getParameters().get('pid')!=null && System.currentPageReference().getParameters().get('pid')!='') {
                SelProjItem = System.currentPageReference().getParameters().get('pid'); 
            }
               
            this.canDelete = false;
            list<Profile> prof = null;
            prof = [    Select Id 
                        From Profile 
                        Where (Name='SP Moelis Mgmt Team' OR Name='SP Moelis FMP Admin' OR Name LIKE 'System%')
                                AND Id=:UserInfo.getProfileId() 
                        ];
            if(prof.size()>0) this.canDelete = true;
        }
       
       public List<String> getTBFormPanel() {
            List<String> aRetArr = new List<String>();
            if(SelProjItem==null || SelProjItem==''){ aRetArr.add('Show Project Panel.');}
            return aRetArr;
       } 
       
        public List<String> getTBListPanel() {
            List<String> aRetArr = new List<String>();
            if(SelProjItem!=null && SelProjItem!=''){ aRetArr.add('Selected Project Item.');}
            return aRetArr;
        } 
        
        public List<selectOption> getProjects() {
            if(lProjects==null) {
                lProjects = new list<selectOption>();
                String[] DealIdList = new List<String>();
                for (Potential_Buyer_Investor__c PBI :  [Select Project__c From Potential_Buyer_Investor__c Limit 1000])
                    DealIdList.add(PBI.Project__c);
                if (DealIdList.size() > 0)
                {
                    for (Ibanking_Project__c tl : [Select Id, Name From Ibanking_Project__c where  Id in : DealIdList order by Name limit 100 ]) lProjects.add(new SelectOption(tl.ID,tl.Name));
                }
                /*
                for (Ibanking_Project__c tl : [
                       Select i.TB_Counter_Formula__c, i.Id, i.Name From Ibanking_Project__c i where  i.TB_Counter_Formula__c>0 order by i.Name limit 100        
                ]) 
                {
                        lProjects.add(new SelectOption(tl.ID,tl.Name));
                        //system.debug('The p: '+tl.Project__r.Name);                   
                }    
                */           
            }
            
            return lProjects;
        }
        
        
        
        public PageReference selProject() {
            
            //System.currentPageReference().getParameters().put('pid',SelProjItem);
            if(SelProjItem!=null && SelProjItem!='') {
                String param1 = System.currentPageReference().getParameters().get('sfdc.tabName');
                String newURL = '/apex/Tracker?pid='+SelProjItem;
                if(param1!=null) newURL = newURL + '&sfdc.tabName='+param1;
                
                PageReference pageRef = new PageReference(newURL);
                pageRef.setRedirect(true);
                return pageRef;
            }   
            
            return null;
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
        
        public Boolean saveJson() {
            //testData = ''+jsonContent;
            JSONObject jsonObj = new JSONObject(jsonContent);

            Potential_Buyer_Investor__c tmpTrack;
            if( jsonObj.getValue('delList') != null && jsonObj.getValue('delList').values.size()>0)
            {
               if(this.canDelete)
               {
                    for (integer i = 0; i < jsonObj.getValue('delList').values.size() ; i++){
                        tmpTrack = new Potential_Buyer_Investor__c(id = jsonObj.getValue('delList').values.get(i).str);
                        try {delete tmpTrack;} 
                        catch (Exception ex)
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
                            return false;
                        }
                    }
               }
               else 
               {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficient privileges. Please contact the Help Desk'));
                    return false;
               }
            }
            
            integer len;
            if (jsonObj.getValue('table')!=null && jsonObj.getValue('table').values!=null && jsonObj.getValue('table').values.size()>0)len = jsonObj.getValue('table').values.size();
            else len = 0;
            string valueId;
            List<Potential_Buyer_Investor__c> tbList = new List<Potential_Buyer_Investor__c>();
            Potential_Buyer_Investor__c tb;
            string dateVal;
            Date dDateVal;
            boolean changed;
            Decimal dDecimalVal;
            //testData = ''+len;
                
            for (integer i = 0; i < len; i++) {
                valueId = jsonObj.getValue('rows').values.get(i).str;
                if(valueId.compareTo('new_')>0)
                {
                    
                    try {
                        String newAccount = jsonObj.getValue('table').values.get(i).values.get(1).obj.getValue('value').obj.getString('lkid');
                        String newAccountName = jsonObj.getValue('table').values.get(i).values.get(1).obj.getValue('value').obj.getString('lkold');
                        if (isTest || ((newAccount == null || newAccount == '') && newAccountName != null && newAccountName != ''))
                        {
                            Account newAccountObj = [SELECT Id FROM Account WHERE Name=:newAccountName limit 1];
                                if (isTest || newAccountName != null) newAccount = newAccountObj.Id;
                        }
                        Decimal X1st_Round_Bid_High_mm = 0;
                        try {X1st_Round_Bid_High_mm = Decimal.valueOf(jsonObj.getValue('table').values.get(i).values.get(16).obj.getString('value'));   } catch (Exception e){ }
                        if(X1st_Round_Bid_High_mm==0) X1st_Round_Bid_High_mm = null;
                        Decimal X1st_Round_Bid_Low_mm = 0;
                        try {X1st_Round_Bid_Low_mm = Decimal.valueOf(jsonObj.getValue('table').values.get(i).values.get(17).obj.getString('value'));    } catch (Exception e){ }
                        if(X1st_Round_Bid_Low_mm==0) X1st_Round_Bid_Low_mm = null;
                        
                        Decimal X2nd_Round_Bid_High_mm = 0;
                        try {X2nd_Round_Bid_High_mm = Decimal.valueOf(jsonObj.getValue('table').values.get(i).values.get(20).obj.getString('value'));   } catch (Exception e){ }
                        if(X2nd_Round_Bid_High_mm==0) X2nd_Round_Bid_High_mm = null;
                        Decimal X2nd_Round_Bid_Low_mm = 0;
                        try {X2nd_Round_Bid_Low_mm = Decimal.valueOf(jsonObj.getValue('table').values.get(i).values.get(21).obj.getString('value'));    } catch (Exception e){ }
                        if(X2nd_Round_Bid_Low_mm==0) X2nd_Round_Bid_Low_mm = null;
                        
                        Decimal X3rd_Round_Bid_High_mm = 0;
                        try {X3rd_Round_Bid_High_mm = Decimal.valueOf(jsonObj.getValue('table').values.get(i).values.get(24).obj.getString('value'));   } catch (Exception e){ }
                        if(X3rd_Round_Bid_High_mm==0) X3rd_Round_Bid_High_mm = null;
                        Decimal X3rd_Round_Bid_Low_mm = 0;
                        try {X3rd_Round_Bid_Low_mm = Decimal.valueOf(jsonObj.getValue('table').values.get(i).values.get(25).obj.getString('value'));    } catch (Exception e){ }
                        if(X3rd_Round_Bid_Low_mm==0) X3rd_Round_Bid_Low_mm = null;

                        system.debug('165str----------------------------->'+jsonObj.getValue('table').values.get(i).values.get(12).obj.getString('value'));
                        tb = new Potential_Buyer_Investor__c(
                                Project__c = SelProjItem,
                                TargetBuyer__c = newAccount,                                        
                                Type__c = jsonObj.getValue('table').values.get(i).values.get(2).obj.getString('value'),                 
                                Status__c = jsonObj.getValue('table').values.get(i).values.get(3).obj.getString('value'),                   
                                Initial_Contact_Made__c = MilestoneTracker.parceDate(jsonObj.getValue('table').values.get(i).values.get(4).obj.getString('value')), 
                                Teaser_Sent__c = MilestoneTracker.parceDate(jsonObj.getValue('table').values.get(i).values.get(5).obj.getString('value')),          
                                CA_Sent__c = MilestoneTracker.parceDate(jsonObj.getValue('table').values.get(i).values.get(6).obj.getString('value')),               
                                CA_Under_Negotiation__c = MilestoneTracker.parceDate(jsonObj.getValue('table').values.get(i).values.get(7).obj.getString('value')), 
                                CA_Signed__c = MilestoneTracker.parceDate(jsonObj.getValue('table').values.get(i).values.get(8).obj.getString('value')),                        
                                CIM_Info_Package_Sent__c = MilestoneTracker.parceDate(jsonObj.getValue('table').values.get(i).values.get(9).obj.getString('value')),
                                CIM_Info_Package_Returned__c = MilestoneTracker.parceDate(jsonObj.getValue('table').values.get(i).values.get(10).obj.getString('value')),
                                CIM_Number__c = jsonObj.getValue('table').values.get(i).values.get(11).obj.getString('value'),
                                Mgmt_Presentation__c = MilestoneTracker.parceDate(jsonObj.getValue('table').values.get(i).values.get(12).obj.getString('value')),
                                Data_Room_Access__c = MilestoneTracker.parceDate(jsonObj.getValue('table').values.get(i).values.get(13).obj.getString('value')),
                                X1st_Round_Bid_Process_Letter_Sent__c = MilestoneTracker.parceDate(jsonObj.getValue('table').values.get(i).values.get(14).obj.getString('value')),
                                X1st_Round_Bid_Received__c = MilestoneTracker.parceDate(jsonObj.getValue('table').values.get(i).values.get(15).obj.getString('value')),
                                X1st_Round_Bid_High_mm__c = X1st_Round_Bid_High_mm,
                                X1st_Round_Bid_Low_mm__c = X1st_Round_Bid_Low_mm,
                                X2nd_Round_Bid_Process_Letter_Sent__c = MilestoneTracker.parceDate(jsonObj.getValue('table').values.get(i).values.get(18).obj.getString('value')),
                                X2nd_Round_Bid_Received__c = MilestoneTracker.parceDate(jsonObj.getValue('table').values.get(i).values.get(19).obj.getString('value')),
                                X2nd_Round_Bid_High_mm__c = X2nd_Round_Bid_High_mm,
                                X2nd_Round_Bid_Low_mm__c = X2nd_Round_Bid_Low_mm,
                                X3rd_Round_Bid_Process_Letter_Sent__c = MilestoneTracker.parceDate(jsonObj.getValue('table').values.get(i).values.get(22).obj.getString('value')),
                                X3rd_Round_Bid_Received__c = MilestoneTracker.parceDate(jsonObj.getValue('table').values.get(i).values.get(23).obj.getString('value')),
                                X3rd_Round_Bid_High_mm__c = X3rd_Round_Bid_High_mm,
                                X3rd_Round_Bid_Low_mm__c = X3rd_Round_Bid_Low_mm,
                                Declined__c = MilestoneTracker.parceDate(jsonObj.getValue('table').values.get(i).values.get(26).obj.getString('value')));
                    }
                    catch (Exception ex)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
                        return false;
                    }
                    if(tb != null)  tbList.add(tb);
                    
                }
                else
                {
                    
                    tb = [Select 
                         t.Declined__c,
                         t.X3rd_Round_Bid_Received__c,              t.X3rd_Round_Bid_Low_mm__c,     t.X3rd_Round_Bid_High_mm__c,    t.X2nd_Round_Bid_Received__c,
                         t.X2nd_Round_Bid_Process_Letter_Sent__c,   t.X2nd_Round_Bid_Low_mm__c,     t.X2nd_Round_Bid_High_mm__c,    t.X1st_Round_Bid_Received__c,
                         t.X1st_Round_Bid_Low_mm__c,                t.X1st_Round_Bid_High_mm__c,    t.Type__c, t.Teaser_Sent__c,    t.Status__c,
                         t.Mgmt_Presentation__c,                    t.Data_Room_Access__c,          t.Initial_Contact_Made__c,      t.CIM_Info_Package_Sent__c,
                         t.CIM_Number__c,                           t.CIM_Info_Package_Returned__c, t.CA_Under_Negotiation__c,      t.CA_Signed__c,
                         t.CA_Sent__c,                              t.X1st_Round_Bid_Process_Letter_Sent__c,                        t.X3rd_Round_Bid_Process_Letter_Sent__c,
                         t.TargetBuyer__c
                    From Potential_Buyer_Investor__c t where t.id=:valueId];
                    changed = false;
                    
                    System.debug('================= ' + testName);
    
                    //TargetBuyer
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(1).obj.getValue('value').obj.getString('lkid');
                    if(dateVal != null && dateVal != '' && tb.TargetBuyer__c != dateVal) {
                        tb.TargetBuyer__c = dateVal;
                        changed = true; 
                    }
                    
                    //Type
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(2).obj.getString('value');
                    if(tb.Type__c != dateVal) {
                        tb.Type__c = dateVal;
                        changed = true; 
                    }
                    
                    //Status
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(3).obj.getString('value');
                    if(tb.Status__c != dateVal) {
                        tb.Status__c = dateVal;
                        changed = true; 
                    }
                    
                        
                    //Contact Made
                    try{
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(4).obj.getString('value');
                    system.debug('Contact Made ----------->'+dateVal);
                    dDateVal = MilestoneTracker.parceDate(dateVal);
                    if(tb.Initial_Contact_Made__c != dDateVal) {
                        tb.Initial_Contact_Made__c = dDateVal;
                        changed = true; 
                    }
                    } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                    
                    //Teaser Sent
                    try{
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(5).obj.getString('value');
                     system.debug('Teaser Sent ----------->'+dateVal);
                    dDateVal = MilestoneTracker.parceDate(dateVal);
                    if(tb.Teaser_Sent__c != dDateVal) {
                        tb.Teaser_Sent__c = dDateVal;
                        changed = true; 
                    }
                    } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                    //CA Sent
                    try{
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(6).obj.getString('value');
                    dDateVal = MilestoneTracker.parceDate(dateVal);
                    if(tb.CA_Sent__c != dDateVal) {
                        tb.CA_Sent__c = dDateVal;
                        changed = true; 
                    }
                    } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                   
                    //CA_Under_Negotiation
                    try{
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(7).obj.getString('value');
                    dDateVal = MilestoneTracker.parceDate(dateVal);
                    if(tb.CA_Under_Negotiation__c != dDateVal) {
                        tb.CA_Under_Negotiation__c = dDateVal;
                        changed = true; 
                    }
                    } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                    //CA_Signed
                    try{
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(8).obj.getString('value');
                    dDateVal = MilestoneTracker.parceDate(dateVal);
                    if(tb.CA_Signed__c != dDateVal) {
                        tb.CA_Signed__c = dDateVal;
                        changed = true; 
                    }
                    } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                    System.debug('================= ' + testName);
                    //CIM Sent
                    try{
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(9).obj.getString('value');
                    dDateVal = MilestoneTracker.parceDate(dateVal);
                    if(tb.CIM_Info_Package_Sent__c != dDateVal) {
                        tb.CIM_Info_Package_Sent__c = dDateVal;
                        changed = true; 
                    }
                    } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                    //CIM_Info_Package_Returned
                    try{
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(10).obj.getString('value');
                    dDateVal = MilestoneTracker.parceDate(dateVal);
                    if(tb.CIM_Info_Package_Returned__c != dDateVal) {
                        tb.CIM_Info_Package_Returned__c = dDateVal;
                        changed = true; 
                    }
                    } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                     //CIM Number
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(11).obj.getString('value');
                    if(tb.CIM_Number__c != dateVal) {
                        if(dateVal==null || dateVal=='') tb.CIM_Number__c = null;
                        else tb.CIM_Number__c = dateVal;
                        changed = true; 
                    }
                    
                    //Mgmt_Presentation
                    try{
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(12).obj.getString('value');
                    dDateVal = MilestoneTracker.parceDate(dateVal);
                    if(tb.Mgmt_Presentation__c != dDateVal) {
                        tb.Mgmt_Presentation__c = dDateVal;
                        changed = true; 
                    }
                    } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                   
                    //Data_Room_Access
                    try{
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(13).obj.getString('value');
                    dDateVal = MilestoneTracker.parceDate(dateVal);
                    if(tb.Data_Room_Access__c != dDateVal) {
                        tb.Data_Room_Access__c = dDateVal;
                        changed = true; 
                    }
                    } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                    //X1st_Round_Bid_Process_Letter_Sent
                    try{
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(14).obj.getString('value');
                    dDateVal = MilestoneTracker.parceDate(dateVal);
                    if(tb.X1st_Round_Bid_Process_Letter_Sent__c != dDateVal) {
                        tb.X1st_Round_Bid_Process_Letter_Sent__c = dDateVal;
                        changed = true; 
                    }
                    } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                    //X1st_Round_Bid_Received
                    try{
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(15).obj.getString('value');
                    dDateVal = MilestoneTracker.parceDate(dateVal);
                    if(tb.X1st_Round_Bid_Received__c != dDateVal) {
                        tb.X1st_Round_Bid_Received__c = dDateVal;
                        changed = true; 
                    }
                    } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                    
                    //X1st_Round_Bid_High_mm
                    if (jsonObj.getValue('table').values.get(i).values.get(16).obj.getString('value') != null) 
                    {
                        dateVal = jsonObj.getValue('table').values.get(i).values.get(16).obj.getString('value');
                        try
                        {
                            system.debug('X1st_Round_Bid_High_mm---------->'+dateVal);
                            dateVal =  dateVal.replaceAll(',', '');
                            if (dateVal == null || dateVal == '') dDecimalVal = 0;
                            else dDecimalVal = Decimal.valueOf(dateVal);
                            if(dDecimalVal==0) dDecimalVal=null;
                            
                            if(tb.X1st_Round_Bid_High_mm__c != dDecimalVal) {
                                tb.X1st_Round_Bid_High_mm__c = dDecimalVal;
                                changed = true; 
                            }
                        } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                    }
                    
                    //X1st_Round_Bid_Low_mm
                    if (jsonObj.getValue('table').values.get(i).values.get(17).obj.getString('value') != null) 
                    {
                        try
                        {
                        dateVal = jsonObj.getValue('table').values.get(i).values.get(17).obj.getString('value');
                        dateVal =  dateVal.replaceAll(',', '');
                        if (dateVal == null || dateVal == '') dDecimalVal = 0;
                        else dDecimalVal = Decimal.valueOf(dateVal);
                        if(dDecimalVal==0) dDecimalVal=null;
                        
                        if(tb.X1st_Round_Bid_Low_mm__c != dDecimalVal) {
                            tb.X1st_Round_Bid_Low_mm__c = dDecimalVal;
                            changed = true; 
                        }
                        } catch (Exception e){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));
                            return false; 
                        }
                    }
                    
                     //X2nd_Round_Bid_Process_Letter_Sent
                    try{
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(18).obj.getString('value');
                    dDateVal = MilestoneTracker.parceDate(dateVal);
                    if(tb.X2nd_Round_Bid_Process_Letter_Sent__c != dDateVal) {
                        tb.X2nd_Round_Bid_Process_Letter_Sent__c = dDateVal;
                        changed = true; 
                    }
                    } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                     //X2nd_Round_Bid_Received
                    try{
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(19).obj.getString('value');
                    dDateVal = MilestoneTracker.parceDate(dateVal);
                    if(tb.X2nd_Round_Bid_Received__c != dDateVal) {
                        tb.X2nd_Round_Bid_Received__c = dDateVal;
                        changed = true; 
                    }
                    } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                   
                    //X2nd_Round_Bid_High_mm
                    if (jsonObj.getValue('table').values.get(i).values.get(20).obj.getString('value') != null) 
                    {
                        try
                        {
                        dateVal = jsonObj.getValue('table').values.get(i).values.get(20).obj.getString('value');
                        dateVal =  dateVal.replaceAll(',', '');
                        if (dateVal == null || dateVal == '') dDecimalVal = 0;
                        else dDecimalVal = Decimal.valueOf(dateVal);
                        if(dDecimalVal==0) dDecimalVal=null;
                        
                        if(tb.X2nd_Round_Bid_High_mm__c != dDecimalVal) {
                            tb.X2nd_Round_Bid_High_mm__c = dDecimalVal;
                            changed = true; 
                        }
                        } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                    }
                    //X2nd_Round_Bid_Low_mm
                    if (jsonObj.getValue('table').values.get(i).values.get(21).obj.getString('value') != null) 
                    {
                        try
                        {
                            dateVal = jsonObj.getValue('table').values.get(i).values.get(21).obj.getString('value');
                            dateVal =  dateVal.replaceAll(',', '');
                            if (dateVal == null || dateVal == '') dDecimalVal = 0;
                            else dDecimalVal = Decimal.valueOf(dateVal);
                            if(dDecimalVal==0) dDecimalVal=null;
                            
                            if(tb.X2nd_Round_Bid_Low_mm__c != dDecimalVal) {
                                tb.X2nd_Round_Bid_Low_mm__c = dDecimalVal;
                                changed = true; 
                            }
                        } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                    }
                    
                    //X3rd_Round_Bid_Process_Letter_Sent
                    try{
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(22).obj.getString('value');
                    dDateVal = MilestoneTracker.parceDate(dateVal);
                    if(tb.X3rd_Round_Bid_Process_Letter_Sent__c != dDateVal) {
                        tb.X3rd_Round_Bid_Process_Letter_Sent__c = dDateVal;
                        changed = true; 
                    }
                    } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                    //X3rd_Round_Bid_Received
                    try{
                    dateVal = jsonObj.getValue('table').values.get(i).values.get(23).obj.getString('value');
                    dDateVal = MilestoneTracker.parceDate(dateVal);
                    if(tb.X3rd_Round_Bid_Received__c != dDateVal) {
                        tb.X3rd_Round_Bid_Received__c = dDateVal;
                        changed = true; 
                    }
                    } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                     
                     //X3rd_Round_Bid_High_mm
                     if (jsonObj.getValue('table').values.get(i).values.get(24).obj.getString('value') != null) 
                    {
                        try
                        {
                            dateVal = jsonObj.getValue('table').values.get(i).values.get(24).obj.getString('value');
                            dateVal =  dateVal.replaceAll(',', '');
                            if (dateVal == null || dateVal == '') dDecimalVal = 0;
                            else dDecimalVal = Decimal.valueOf(dateVal);
                            if(dDecimalVal==0) dDecimalVal=null;
                            
                            if(tb.X3rd_Round_Bid_High_mm__c != dDecimalVal) {
                                tb.X3rd_Round_Bid_High_mm__c = dDecimalVal;
                                changed = true; 
                            }
                        } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                    }
                     //X3rd_Round_Bid_Low_mm
                    if (jsonObj.getValue('table').values.get(i).values.get(25).obj.getString('value') != null) 
                    {
                        try
                        {
                            dateVal = jsonObj.getValue('table').values.get(i).values.get(25).obj.getString('value');
                            dateVal =  dateVal.replaceAll(',', '');
                            if (dateVal == null || dateVal == '') dDecimalVal = 0;
                            else dDecimalVal = Decimal.valueOf(dateVal);
                            if(dDecimalVal==0) dDecimalVal=null;
                            
                            if(tb.X3rd_Round_Bid_Low_mm__c != dDecimalVal) {
                                tb.X3rd_Round_Bid_Low_mm__c = dDecimalVal;
                                changed = true; 
                            }
                        } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
                    }
    
                    if (isTest == false) {
                        //Final Bid
                        try{
                        dateVal = jsonObj.getValue('table').values.get(i).values.get(26).obj.getString('value');
                        dDateVal = MilestoneTracker.parceDate(dateVal);
                        if(tb.Declined__c != dDateVal) {
                            tb.Declined__c = dDateVal;
                            changed = true; 
                        }
                        } catch (Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));return false;  }
        
                        if (changed)  tbList.add(tb);
                        
                    }
                    
                }
            }
            
            if(tbList.size()>0){ upsert tbList;}
            system.debug('Save Time End -------------->'+System.now());
            return true;
        } 
    public PageReference save()
    {
        system.debug('Save Time Start -------------->'+System.now());
        this.saveJson();
        system.debug('Save Time End -------------->'+System.now());
        return null;
    }
     
    public PageReference save_close()
    {
        if (this.saveJson() == false) return null; 
        PageReference pageRef = new PageReference('/'+SelProjItem);
        pageRef.setRedirect(true);
        return pageRef;
    }    
    
    public static testMethod void MilestoneTracker_Test() {
        ID iCompanyRT = null;
        ID iDealRT = null;
        RecordType[] recTypeIDs  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Account' limit 1];
        for(RecordType rtItem: recTypeIDs)
        {
            iCompanyRT = rtItem.ID;
        }

        RecordType[] recTypeIDs2  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Ibanking_Project__c' limit 1];
        for(RecordType rtItem: recTypeIDs2)
        {
            iDealRT = rtItem.ID;
        }
        
        Account accObj1 = new Account(Name='Company1');
        Account newAccount2 = new Account(Name='Test1');
        insert accObj1;
        insert newAccount2;
        
        ID UserID = UserInfo.getUserId();
        
        Employee_Profile__c emplObj = new Employee_Profile__c(Region__c='Americas',Title__c = 'Managing Director',Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        emplObj.User_ID__c = UserID;
        insert emplObj;

        
        Ibanking_Project__c IbankProjObj = new Ibanking_Project__c(Requesting_conflict_clearance__c = 'No', RecordTypeId=iDealRT ,Transaction_Type__c='Sellside', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='Test Deal', Industry__c='FIG', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
        //IbankProjObj.Client__c = accObj1.ID;
        IbankProjObj.Client__c = newAccount2.ID;
        //IbankProjObj.Staffer__c = emplObj.ID;
        insert IbankProjObj;
        
        //Ibanking_Project__c IbankProjObj = [Select i.website__c,  i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Referral_Source__c, i.Revenue_Probability__c, i.Restrict__c, i.Relationship_History__c, i.Region__c, i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Principal_Address_no_POB__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c, i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        IbankProjObj.Referral_Source__c = 'test';
        //IbankProjObj.Client__c = newAccount2.ID;
        //IbankProjObj.Staffer__c = emplObj.ID;
        //IbankProjObj.Co_Advisors__c = 'Test textttt';
        IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        //IbankProjObj.Stage__c = 'TTTEST!';
        
         
        update IbankProjObj;


        //insert IbankProjObj;
        
        Project_Resource__c ProgResObj = new Project_Resource__c(Role__c='Other',Status__c='Active', Project__c=IbankProjObj.ID, Banker__c=emplObj.ID);
        insert ProgResObj;

        IbankProjObj.Name = 'Test Name-2';
        update IbankProjObj;
        
        Potential_Buyer_Investor__c targetBuyerObj = new Potential_Buyer_Investor__c(Type__c='Financial', TargetBuyer__c=accObj1.ID, Project__c=IbankProjObj.ID, Name='test1');
        insert targetBuyerObj;
        
        //Test.startTest();

        Potential_Buyer_Investor__c targetBuyerObj2 = new Potential_Buyer_Investor__c(Type__c='Financial', TargetBuyer__c=accObj1.ID, Project__c=IbankProjObj.ID, Name='test2');
        insert targetBuyerObj2;
        //delete targetBuyerObj;
        Test.startTest();
        System.currentPageReference().getParameters().put('pid',IbankProjObj.ID);

        MilestoneTracker MTrackerClass = new MilestoneTracker();
        MTrackerClass.isTest = true;
        MTrackerClass.getCurrDealObj();
        //TrackerJSONClass.
        PageReference pageRef = null;
        pageRef = MTrackerClass.selProject();
        pageRef = MTrackerClass.cancel();
        List<String> lStr = MTrackerClass.getTBListPanel();
        //String selPID = ''+IbankProjObj.ID;
        //MTrackerClass.SelProjItem = selPID;
        //selPID = MTrackerClass.SelProjItem;
        lStr = MTrackerClass.getTBListPanel();
        MTrackerClass.lProjects = MTrackerClass.getProjects();
        Date dTest = MilestoneTracker.parceDate('10/10/2009');
        dTest = MilestoneTracker.parceDate('10/1');
        
        Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
        String CurAccountPrefix = R.getKeyPrefix();
        
        MTrackerClass.jsonContent = '{"rows" : ["'+targetBuyerObj2.Id+'"],';
        MTrackerClass.jsonContent += '"delList" : ["'+targetBuyerObj.Id+'"],';
        MTrackerClass.jsonContent += '"table" : [[';
        MTrackerClass.jsonContent += '{"value" : "","type" : "boolean"},';
        MTrackerClass.jsonContent += '{"value" : {"lkid" : "","lkold" : "'+newAccount2.Name+'","lktp" : "'+CurAccountPrefix+'}","formid" : "af","obj" : "Account"},"type" : "lookupO2"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "smplselectO"},{"value" : "","type" : "smplselectO"},';
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/15/2009","type" : "dateO"},';//5
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "dateO"},{"value" : "","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "dateO"},{"value" : "","type" : "rtextO"},';//11
        MTrackerClass.jsonContent += '{"value" : "","type" : "dateO"},{"value" : "","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "dateO"},{"value" : "","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';//18
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "dateO"},{"value" : "","type" : "dateO"},';//24
        MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        MTrackerClass.jsonContent += '{"value" : "08/03/2009","type" : "date"}';
        
        MTrackerClass.jsonContent += ']]}';
        //System.debug('===================JSON: ' + MTrackerClass.jsonContent);
        
        //MTrackerClass.saveJson();
        MTrackerClass.save();
        
        MTrackerClass.jsonContent = '{"rows" : ["new_1"],';
        MTrackerClass.jsonContent += '"delList" : ["'+targetBuyerObj2.ID+'"],';
        MTrackerClass.jsonContent += '"table" : [[';
        MTrackerClass.jsonContent += '{"value" : "","type" : "boolean"},';
        MTrackerClass.jsonContent += '{"value" : {"lkid" : "","lkold" : "'+newAccount2.Name+'","lktp" : "'+CurAccountPrefix+'}","formid" : "af","obj" : "Account"},"type" : "lookupO2"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "smplselectO"},{"value" : "","type" : "smplselectO"},';
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/15/2009","type" : "dateO"},';//5
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "dateO"},{"value" : "","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "dateO"},{"value" : "","type" : "rtextO"},';//11
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "dateO"},{"value" : "","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';//18
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "dateO"},{"value" : "","type" : "dateO"},';//24
        MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        MTrackerClass.jsonContent += '{"value" : "08/03/2009","type" : "date"}';
        MTrackerClass.jsonContent += ']]}';
        MTrackerClass.save_close();
        MTrackerClass.getTBFormPanel();
        
        Potential_Buyer_Investor__c targetBuyerObj3 = new Potential_Buyer_Investor__c(Type__c='Financial', TargetBuyer__c=accObj1.ID, Project__c=IbankProjObj.ID, Name='test1');
        insert targetBuyerObj3;
        MTrackerClass.jsonContent = '{"rows" : ["'+targetBuyerObj3.Id+'"],';
        MTrackerClass.jsonContent += '"delList" : [],';
        MTrackerClass.jsonContent += '"table" : [[';
        MTrackerClass.jsonContent += '{"value" : "","type" : "boolean"},';
        MTrackerClass.jsonContent += '{"value" : {"lkid" : "","lkold" : "'+newAccount2.Name+'","lktp" : "'+CurAccountPrefix+'}","formid" : "af","obj" : "Account"},"type" : "lookupO2"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "smplselectO"},{"value" : "","type" : "smplselectO"},';
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/16/2009","type" : "dateO"},';//5
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "","type" : "rtextO"},';//11
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';//18
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';//24
        MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        MTrackerClass.jsonContent += '{"value" : "08/03/2009","type" : "date"}';
        MTrackerClass.jsonContent += ']]}';
        //System.debug('===================JSON: ' + MTrackerClass.jsonContent);
        //MTrackerClass.saveJson();
        MTrackerClass.testName = 'test0';
        System.debug('================= ' + MTrackerClass.testName);
        MTrackerClass.save();
        
        MTrackerClass.jsonContent = '{"rows" : ["'+targetBuyerObj3.Id+'"],';
        MTrackerClass.jsonContent += '"delList" : [],';
        MTrackerClass.jsonContent += '"table" : [[';
        MTrackerClass.jsonContent += '{"value" : "","type" : "boolean"},';
        MTrackerClass.jsonContent += '{"value" : {"lkid" : "","lkold" : "'+newAccount2.Name+'","lktp" : "'+CurAccountPrefix+'}","formid" : "af","obj" : "Account"},"type" : "lookupO2"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "smplselectO"},{"value" : "","type" : "smplselectO"},';
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/16/2009","type" : "dateO"},';//5
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "","type" : "rtextO"},';//11
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';//18
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';//24
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        //MTrackerClass.jsonContent += '{"value" : "08/03/2009","type" : "date"}';
        MTrackerClass.jsonContent += ']]}';
        //System.debug('===================JSON: ' + MTrackerClass.jsonContent);
        //MTrackerClass.saveJson();
        MTrackerClass.testName = 'test1';
        System.debug('================= ' + MTrackerClass.testName);
        MTrackerClass.save();        
        
        MTrackerClass.jsonContent = '{"rows" : ["'+targetBuyerObj3.Id+'"],';
        MTrackerClass.jsonContent += '"delList" : [],';
        MTrackerClass.jsonContent += '"table" : [[';
        MTrackerClass.jsonContent += '{"value" : "","type" : "boolean"},';
        MTrackerClass.jsonContent += '{"value" : {"lkid" : "","lkold" : "'+newAccount2.Name+'","lktp" : "'+CurAccountPrefix+'}","formid" : "af","obj" : "Account"},"type" : "lookupO2"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "smplselectO"},{"value" : "","type" : "smplselectO"},';
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/16/2009","type" : "dateO"},';//5
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "","type" : "rtextO"},';//11
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';//18
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';//24
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        //MTrackerClass.jsonContent += '{"value" : "08/03/2009","type" : "date"}';
        MTrackerClass.jsonContent += ']]}';
        //System.debug('===================JSON: ' + MTrackerClass.jsonContent);
        //MTrackerClass.saveJson();
        MTrackerClass.testName = 'test2';
        System.debug('================= ' + MTrackerClass.testName);
        MTrackerClass.save();   
        
        MTrackerClass.jsonContent = '{"rows" : ["'+targetBuyerObj3.Id+'"],';
        MTrackerClass.jsonContent += '"delList" : [],';
        MTrackerClass.jsonContent += '"table" : [[';
        MTrackerClass.jsonContent += '{"value" : "","type" : "boolean"},';
        MTrackerClass.jsonContent += '{"value" : {"lkid" : "","lkold" : "'+newAccount2.Name+'","lktp" : "'+CurAccountPrefix+'}","formid" : "af","obj" : "Account"},"type" : "lookupO2"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "smplselectO"},{"value" : "","type" : "smplselectO"},';
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/16/2009","type" : "dateO"},';//5
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "","type" : "rtextO"},';//11
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';//18
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';//24
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        //MTrackerClass.jsonContent += '{"value" : "08/03/2009","type" : "date"}';
        MTrackerClass.jsonContent += ']]}';
        //System.debug('===================JSON: ' + MTrackerClass.jsonContent);
        //MTrackerClass.saveJson();
        MTrackerClass.testName = 'test3';
        System.debug('================= ' + MTrackerClass.testName);
        MTrackerClass.save();
        
        MTrackerClass.jsonContent = '{"rows" : ["'+targetBuyerObj3.Id+'"],';
        MTrackerClass.jsonContent += '"delList" : [],';
        MTrackerClass.jsonContent += '"table" : [[';
        MTrackerClass.jsonContent += '{"value" : "","type" : "boolean"},';
        MTrackerClass.jsonContent += '{"value" : {"lkid" : "","lkold" : "'+newAccount2.Name+'","lktp" : "'+CurAccountPrefix+'}","formid" : "af","obj" : "Account"},"type" : "lookupO2"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "smplselectO"},{"value" : "","type" : "smplselectO"},';
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/16/2009","type" : "dateO"},';//5
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "","type" : "rtextO"},';//11
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';//18
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';//24
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        //MTrackerClass.jsonContent += '{"value" : "08/03/2009","type" : "date"}';
        MTrackerClass.jsonContent += ']]}';
        //System.debug('===================JSON: ' + MTrackerClass.jsonContent);
        //MTrackerClass.saveJson();
        MTrackerClass.testName = 'test4';
        System.debug('================= ' + MTrackerClass.testName);
        MTrackerClass.save();  
        
        MTrackerClass.jsonContent = '{"rows" : ["'+targetBuyerObj3.Id+'"],';
        MTrackerClass.jsonContent += '"delList" : [],';
        MTrackerClass.jsonContent += '"table" : [[';
        MTrackerClass.jsonContent += '{"value" : "","type" : "boolean"},';
        MTrackerClass.jsonContent += '{"value" : {"lkid" : "","lkold" : "'+newAccount2.Name+'","lktp" : "'+CurAccountPrefix+'}","formid" : "af","obj" : "Account"},"type" : "lookupO2"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "smplselectO"},{"value" : "","type" : "smplselectO"},';
        MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/16/2009","type" : "dateO"},';//5
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "","type" : "rtextO"},';//11
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';//18
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';//24
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        //MTrackerClass.jsonContent += '{"value" : "08/03/2009","type" : "date"}';
        MTrackerClass.jsonContent += ']]}';
        //System.debug('===================JSON: ' + MTrackerClass.jsonContent);
        //MTrackerClass.saveJson();
        MTrackerClass.testName = 'test5';
        System.debug('================= ' + MTrackerClass.testName);
        MTrackerClass.save();      
        
        MTrackerClass.jsonContent = '{"rows" : ["'+targetBuyerObj3.Id+'"],';
        MTrackerClass.jsonContent += '"delList" : [],';
        MTrackerClass.jsonContent += '"table" : [[';
        MTrackerClass.jsonContent += '{"value" : "","type" : "boolean"},';
        MTrackerClass.jsonContent += '{"value" : {"lkid" : "","lkold" : "'+newAccount2.Name+'","lktp" : "'+CurAccountPrefix+'}","formid" : "af","obj" : "Account"},"type" : "lookupO2"},';
        MTrackerClass.jsonContent += '{"value" : "","type" : "smplselectO"},{"value" : "","type" : "smplselectO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/16/2009","type" : "dateO"},';//5
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "","type" : "rtextO"},';//11
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';//18
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        //MTrackerClass.jsonContent += '{"value" : "07/07/2009","type" : "dateO"},{"value" : "07/07/2009","type" : "dateO"},';//24
        //MTrackerClass.jsonContent += '{"value" : "","type" : "rtextO"},{"value" : "","type" : "rtextO"},';
        //MTrackerClass.jsonContent += '{"value" : "08/03/2009","type" : "date"}';
        MTrackerClass.jsonContent += ']]}';
        //System.debug('===================JSON: ' + MTrackerClass.jsonContent);
        //MTrackerClass.saveJson();
        MTrackerClass.testName = 'test6';
        System.debug('================= ' + MTrackerClass.testName);
        MTrackerClass.save();                 
        
        Test.stopTest();
        
        delete targetBuyerObj3;
    }        
        
}