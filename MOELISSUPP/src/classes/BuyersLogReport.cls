public without sharing class BuyersLogReport {
    Integer columnCount = 15; //34; 
    Decimal maxHeight = 5139;
    Decimal headHeight = 124; 
    Decimal curHeight = 0.0;
    List<Potential_Buyer_Investor__c> target_buyers;
    Map<Id, List<Contact>> buyersContacts = new Map<Id, List<Contact>>();
    Ibanking_Project__c deal;
    List<Potential_Buyer_Investor_Contact__c> target_buyer_contacts;
    List<Potential_Buyer_Investor_Deal_Team__c> target_buyer_resource;
    Map<Id, Contact> contacts = new Map<Id, Contact>();
    Map<Id, Account> accounts = new Map<Id, Account>();
    Map<Id, Employee_Profile__c> employees = new Map<Id, Employee_Profile__c>();
    List<Task> tasks;
    List<Event> events;
    String strImageURL;
    Map<Id, Event> eventsMap = new Map<Id, Event>();
    Id prjId;
    Date todayD;
    
    public BuyersLogReport(){
        maxHeight = 5139;
        headHeight = 124;
        todayD = Date.today();
        strImageURL = Url.getSalesforceBaseUrl().toExternalForm().replace('visual.force','content.force')+'/servlet/servlet.ImageServer?id=';
        List<Document> lstDocument = [SELECT Id FROM Document WHERE DeveloperName=:'MOELIS_and_Company' LIMIT 1];
        
        if(!lstDocument.isEmpty())
            strImageURL+=lstDocument[0].Id+'&oid='+Userinfo.getOrganizationId();
        prjId = ApexPages.currentPage().getParameters().get('did');
        
        deal = [SELECT id, name FROM Ibanking_Project__c WHERE id=:prjId LIMIT 1];
        try{
            target_buyers = [Select (select ActivityDate, ActivityType, LastModifiedDate, Subject, Description from ActivityHistories), (Select Name, Roles__c, Contact__c From Target_Buyer_Contacts__r), t.Data_Room_Access__c, t.Type__c, t.Teaser_Sent__c, t.TargetBuyer__r.Status__c, t.TargetBuyer__c, t.Name, t.Id, t.Initial_Contact_Made__c, t.CA_Under_Negotiation__c, t.CA_Signed__c, t.CA_Sent__c, t.CIM_Info_Package_Sent__c, t.CIM_Number__c, t.CIM_Info_Package_Returned__c, t.Declined__c,  t.Mgmt_Presentation__c From Potential_Buyer_Investor__c t WHERE t.Project__c=:prjId ORDER BY t.TargetBuyer__r.Name, t.Type__c];
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'You do not have enough rights to do this action.');
            ApexPages.addMessage(msg);
        }
        List<Id> ids = new List<Id>();
        for (Potential_Buyer_Investor__c buyer : target_buyers){
            ids.add(buyer.Id);
        }
        target_buyer_contacts = [SELECT id, Name, Contact__c, Target_Buyer__c, Roles__c FROM Potential_Buyer_Investor_Contact__c WHERE Target_Buyer__c IN :ids];
        target_buyer_resource = [Select t.Title__c, t.Target_Buyer__c, t.Role__c, t.Phone__c, t.Name, t.Id, t.Email__c, t.Banker__c From Potential_Buyer_Investor_Deal_Team__c t WHERE Target_Buyer__c IN :ids];

        ids.clear();
        for (Potential_Buyer_Investor__c buyer : target_buyers){
            ids.add(buyer.TargetBuyer__c);
        }
        List<Account> accountsLst = [SELECT Id, name, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity FROM Account WHERE Id IN :ids];
        for (Account acc : accountsLst){
            accounts.put(acc.Id, acc);
        }
        ids.clear();
        for (Potential_Buyer_Investor_Contact__c tbc : target_buyer_contacts){
            ids.add(tbc.Contact__c);
        }
        List<Contact> contactsLst = [Select c.AccountId,c.Title, c.Phone, c.Name, c.MobilePhone, c.Id, c.Email, c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity From Contact c WHERE id IN :ids];
        ids.clear();
        for (Contact cnt : contactsLst){
            contacts.put(cnt.Id, cnt);
            ids.add(cnt.AccountId);
        }
        accountsLst = [SELECT Id, name, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity FROM Account WHERE Id IN :ids];
        for (Account acc : accountsLst){
            accounts.put(acc.Id, acc);
        }
        
        ids.clear();
        for (Potential_Buyer_Investor_Deal_Team__c tbr : target_buyer_resource){
            ids.add(tbr.Banker__c);
        }
        List<Id> ids2 = new List<Id>();
        for (Potential_Buyer_Investor__c buyer : target_buyers){
            ids2.add(buyer.Id);
        }
        List<Employee_Profile__c> empLst = [SELECT id, name, (Select Id, WhoId, WhatId, Subject, ActivityDate, OwnerId, Status From ActivityHistories Where WhatId IN :ids2) 
                FROM Employee_Profile__c WHERE id IN :ids];
        for (Employee_Profile__c emp : empLst){
            employees.put(emp.Id, emp);
        }
        
        tasks = [Select t.WhoId, t.WhatId, t.Type, t.Subject, t.Status, t.OwnerId, t.Id, t.CallType, t.ActivityDate, t.AccountId From Task t where whatid IN :ids2];
        events = [Select e.Subject, e.WhoId, e.WhatId, e.Type, e.StartDateTime, e.EndDateTime, e.OwnerId, e.Id, e.DurationInMinutes, e.AccountId From Event e where whatid IN :ids2];
        for (Event e : events){
            eventsMap.put(e.Id, e);
        }
    }
    
    public String getDealName(){
        return deal.Name;
    }
    
    public String getXMLDescription(){
        String s = '<!--[if gte mso 9]><xml xmlns:x="urn:schemas-microsoft-com:office:excel"><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>Detailed Buyer/Investor Report</x:Name><x:WorksheetOptions><x:Print><x:ValidPrinterInfo/></x:Print></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]-->';
        return s;
    }
    
    public List<Potential_Buyer_Investor__c> getTargetBuyers(){
        return target_buyers;
    } 
    
    public String addTr(Integer sz){
        curHeight += sz;
        if (curHeight>maxHeight){
            return getHeader();
        }
        return '';
    }
    
    public String getEmptyRow(String cls){
        String res = '';
        if (cls==null || cls.trim()=='') {
            res += addTr(0) + '<tr>';
        } else {
            res += addTr(1) + '<tr class="' + cls + '">';
        }
        for (integer i=0; i<6; i++){
            res += '<td/>';
        }
        res += '</tr>';
        return res; 
    }
    
    public String getHeader(){
        curHeight = headHeight;
        String res = '';
        res += '<tr style="height: 95.0pt;"><td><h3><img src="'+ strImageURL +'" width="3.37in" height="0.23in"/>';
        res += '<br/><br/>' + getDealName() + '<br/>';
        res += 'Detailed Buyer/Investor Report<br/>';
        res += todayD.month() + '/' + todayD.day() + '/' + todayD.year();
        res += '</h3></td><td></td><td></td><td></td><td></td><td></td><td></tr>';
        
        res += getEmptyRow('t_pad1');
        res += '<tr class="t_head">';
        res += '<td class="head">Potential Buyer/Investor Name</td>';
        res += '<td class="head">Potential Buyer/Investor Contacts</td>';
        res += '<td class="head">Potential Buyer/Investor Type</td>';
        res += '<td class="head">Potential Buyer/Investor Deal Team</td>';
        res += '<td class="head">Milestones</td>';
        res += '<td class="head">Activity Logs</td>';
        res += '</tr>'; 
        res += getEmptyRow('t_pad1');       
        return res;
    }
    
    public Integer countInside(String s, String what){
        Integer res = 0;
        Integer pos = 0;
        while (s.indexOf(what, pos)>0){
            pos = s.indexOf(what, pos)+what.length();
            res++;
        }
        return res;
    }
    
    public String getTable(){
        String res = '<table border="0" cellpadding="5" cellspacing="0"  class="tabl">';
        
        double scale = 5.35;
        for (integer i=0; i<6; i++){
            res += '<col style="mso-width-source:userset; width:'+(36*scale)+'pt">';
        }
        
        res += getHeader();
        Integer count = 0;
        for (Potential_Buyer_Investor__c buyer : target_buyers){
            String s = '';
            if (count++>0) s += getEmptyRow('t_pad1') + getEmptyRow('t_pad2');
            integer lines = 1;
            String tmp;
            s += '<tr class="t_body" style="height:==lines==pt;">';
            s += '<td>' + accounts.get(buyer.TargetBuyer__c).Name + '</td>';
            
            tmp = getContacts(buyer);
            lines = Math.max(lines, countInside(tmp, '<br/>')+1);
            s += '<td>' + tmp + '</td>';
            
            s += '<td>' + buyer.Type__c + '</td>';
            
            tmp = getDealTeam(buyer);
            lines = Math.max(lines, countInside(tmp, '<br/>')+1);
            s += '<td>' + tmp + '</td>';
            
            tmp = getMilestone(buyer);
            lines = Math.max(lines, countInside(tmp, '<br/>')+1);
            s += '<td>' + tmp + '</td>';
            
            tmp = getActivity(buyer);
            lines = Math.max(lines, countInside(tmp, '<br/>')+1);
            s += '<td>' + tmp + '</td>';
            
            s += '</tr>';
            s = s.replace('==lines==', ''+(11.5*lines));
            res += s;
        }
        
        res += getEmptyRow('t_pad3');
         
        res += '</table>';
        return res;
    }
    
    public String getContacts(Potential_Buyer_Investor__c buyer){
        String res = '';
        for (Potential_Buyer_Investor_Contact__c tbc : target_buyer_contacts){
            if (tbc.Target_Buyer__c != buyer.Id) continue;
            //res += tbc.Target_Buyer__c + '\n';
            Contact c = contacts.get(tbc.Contact__c);
            Account acc = accounts.get(c.AccountId);
            res += '\n';
            res += c.Name + '\n';
            res += (tbc.Roles__c==null ? '' : 'Role: '+tbc.Roles__c+'\n');
            res += (c.Title==null ? '' : c.Title+'\n'); 
            res += acc.Name + '\n'; 
            Boolean was = false;
            /*if (acc.BillingStreet!=null) {
                was = true;
                res += acc.BillingStreet;
            } 
            if (acc.BillingCity!=null && acc.BillingState!=null && acc.BillingPostalCode!=null){
                if (was==true){
                    res += ',\n';
                }
                res += acc.BillingCity + ',' + acc.BillingState + ' ' + acc.BillingPostalCode;
                was = true;
            }           
            if (was) res += '\n';
            if (acc.BillingCountry!=null) res += acc.BillingCountry + '\n';*/
            
            if (c.MailingStreet!=null) {
                was = true;
                res += c.MailingStreet;
            } 
            if (c.MailingCity!=null && c.MailingState!=null && c.MailingPostalCode!=null){
                if (was==true){
                    //res += ',\n';
                    res += '\n';
                }
                res += c.MailingCity + ',' + c.MailingState + ' ' + c.MailingPostalCode;
                was = true;
            }           
            if (was) res += '\n';
            if (c.MailingCountry!=null) res += c.MailingCountry + '\n';
            
            if (c.Phone!=null) res += 'Direct: ' + c.Phone + '\n';
            if (c.MobilePhone!=null) res += 'Mobile: ' + c.MobilePhone + '\n';
            if (c.Email!=null) res += 'Email: ' + c.Email + '\n';           
        }
        if (res.length()>0) res = res.substring(1);
        res = res.replaceAll('\n', '<br/>');
        return res;
    }
    
    public String getDealTeam(Potential_Buyer_Investor__c buyer){
        String res = '';
        for (Potential_Buyer_Investor_Deal_Team__c tbr : target_buyer_resource){
            if (tbr.Target_Buyer__c != buyer.Id) continue;
            Employee_Profile__c emp = employees.get(tbr.Banker__c);
            res += '\n';
            res += emp.Name + '\n';
            res += (tbr.Role__c==null ? '' : 'Role: '+tbr.Role__c+'\n');
            //res += tbr.Role__c + '\n';
            if (tbr.Title__c!=null) res += tbr.Title__c + '\n';
            if (tbr.Phone__c!=null) res += tbr.Phone__c + '\n';
            if (tbr.Email__c!=null) res += tbr.Email__c + '\n';
        }
        if (res.length()>0) res = res.substring(1);
        res = res.replaceAll('\n', '<br/>');
        return res;
    }
    
    public String getMilestone(Potential_Buyer_Investor__c buyer){
        String res = '';
        if (buyer.Initial_Contact_Made__c!=null) res += '\nInitial Contact Made: ' + formatDate(buyer.Initial_Contact_Made__c);
        if (buyer.Teaser_Sent__c!=null) res += '\nTeaser Sent: ' + formatDate(buyer.Teaser_Sent__c);
        
        if (buyer.CA_Sent__c!=null) res += '\nCA Sent: ' + formatDate(buyer.CA_Sent__c);
        if (buyer.CA_Under_Negotiation__c!=null) res += '\nCA Under Negotiation: ' + formatDate(buyer.CA_Under_Negotiation__c);
        if (buyer.CA_Signed__c!=null) res += '\nCA Signed: ' + formatDate(buyer.CA_Signed__c);
        //if (buyer.CA_Status__c!=null) res += '\nCA Status: ' + buyer.CA_Status__c;
        
        if (buyer.CIM_Info_Package_Sent__c!=null) res += '\nCIM/Info Packet Sent: ' + formatDate(buyer.CIM_Info_Package_Sent__c);
        if (buyer.CIM_Info_Package_Returned__c!=null) res += '\nCIM/Info Packet Returned: ' + formatDate(buyer.CIM_Info_Package_Returned__c);
        if (buyer.CIM_Number__c!=null) res += '\nCIM Number: ' + buyer.CIM_Number__c;
        
        if (buyer.Mgmt_Presentation__c!=null) res += '\nManagement Presentation: ' + formatDate(buyer.Mgmt_Presentation__c);
        if (buyer.Data_Room_Access__c!=null) res += '\nData Room Access: ' + formatDate(buyer.Data_Room_Access__c);
        
        if (buyer.Declined__c!=null) res += '\nDeclined on: ' + formatDate(buyer.Declined__c);
        //if (buyer.StageName__c!=null) res += '\nStage: ' + buyer.StageName__c;
        
        if (res.length()>0) res = res.substring(1);
        res = res.replaceAll('\n', '<br/>');
        return res;
    }
    
    public String getActivity(Potential_Buyer_Investor__c buyer){
        String res = '';
        /*for (Task t : tasks){
            if (t.WhatId != buyer.Id) continue;
            res += '\n';
            res += '\n' + formatDate(t.ActivityDate);
            res += '\nSubject: ' + t.Subject;
            if (t.Type!=null) res += '\nType: ' + t.Type;
            if (employees.get(t.OwnerId)!=null) res += '\n' + employees.get(t.OwnerId).Name;
            if (t.Status!=null) res += '\nStatus: ' + t.Status;
        }
        for (Event e : events){
            if (e.WhatId != buyer.Id) continue;
            res += '\n';
            if (e.StartDateTime!=null) {
                res += '\n' + formatDateTime(e.StartDateTime);
            }
            if (e.DurationInMinutes!=null) res += '\nDuration: ' + e.DurationInMinutes + ' mins';
            if (e.Subject!=null) res += '\nSubject:' + e.Subject;    
            if (e.Type!=null) res += '\nType:' + e.Type;
            if (employees.get(e.OwnerId)!=null) res += '\n' + employees.get(e.OwnerId).Name;
        }*/
        for (ActivityHistory ah : buyer.ActivityHistories){
            if (ah.LastModifiedDate!=null) res += '\n\nDate/Time: ' + formatDateTime(ah.LastModifiedDate);
            if (ah.Subject!=null) res += '\nSubject: ' + ah.Subject;
            Event e = findEvent(ah.Id);
            if (e!=null) {
                res += '\nMeeting Date/Time: ' + formatDateTime(e.StartDateTime);
            }
            if (ah.Description!=null) res += '\nNotes: ' + ((ah.Description==null)?'':ah.Description);
        }
        if (res.length()>0) res = res.substring(2);
        res = res.replaceAll('\n', '<br/>');
        return res;
    }
    
    public Event findEvent(Id id){
        return eventsMap.get(id);
    }
    
    public String formatDate(Date d){
        if (d==null) return '';
        String s = '' + d.month() + '/' + d.day() + '/' + d.year();
        //if (s.length()>10) s = s.substring(0, 10);
        return s;
    }
    
    public String formatDateTime(DateTime d){
        if (d==null) return '';
        String s = '';
        //String s = '' + d.month() + '/' + d.day() + '/' + d.year();
        if (d.time()!=null){// && d.time().hour()!=0 && d.time().minute()!=0){
            s = d.format('M/d/yyyy h:mm a');
        } else {
            s = d.format('M/d/yyyy');
        }
        //if (s.length()>10) s = s.substring(0, 10);
        return s;
    }
    
    public String formatTime(Time t){
        if (t==null) return '';
        String s = '';
        if (t.hour()<10) s += '0';
        s += t.hour();
        s += ':';
        if (t.minute()<10) s += '0';
        s += t.minute();
        return s;
    }
    
    public Pagereference toXLS() { 
        return new Pagereference('/apex/BuyersLogReport_XLS?did=' + prjId);
    }
}