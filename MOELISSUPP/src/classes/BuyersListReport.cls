public without sharing class BuyersListReport {
    Integer columnCount = 15; //34; 
    Decimal maxHeight = 1040;
    Decimal headHeight = 132; 
    Decimal curHeight = 0.0;
    List<Potential_Buyer_Investor__c> target_buyers;
    Ibanking_Project__c deal;
    Map<Id, Account> accounts = new Map<Id, Account>();
    Id prjId;
    public String strImageURL{   get;set;  }
    List<Integer> curCount = new List<Integer>();
    List<Integer> globalCount = new List<Integer>();
    Date todayD;
    String repeatHeader = 'false';
    
    public BuyersListReport(){
        maxHeight = 1040;
        headHeight = 132;
        todayD = Date.today();
        
        strImageURL = Url.getSalesforceBaseUrl().toExternalForm().replace('visual.force','content.force')+'/servlet/servlet.ImageServer?id=';
        List<Document> lstDocument = [SELECT Id FROM Document WHERE DeveloperName=:'MOELIS_and_Company' LIMIT 1];
        
        if(!lstDocument.isEmpty())
            strImageURL+=lstDocument[0].Id+'&oid='+Userinfo.getOrganizationId();
            
        repeatHeader = ApexPages.currentPage().getParameters().get('repeatHeader');
        prjId = ApexPages.currentPage().getParameters().get('did');
        deal = [SELECT id, name FROM Ibanking_Project__c WHERE id=:prjId LIMIT 1];
        target_buyers = [Select t.Data_Room_Access__c, t.Type__c, t.Teaser_Sent__c, t.Status__c, t.TargetBuyer__c, t.Name, t.Id, t.Initial_Contact_Made__c, t.CA_Under_Negotiation__c, t.CA_Signed__c, t.CA_Sent__c, t.CIM_Info_Package_Sent__c, t.CIM_Number__c, t.CIM_Info_Package_Returned__c, t.Declined__c, t.Mgmt_Presentation__c
                            ,t.X3rd_Round_Bid_Received__c, t.X3rd_Round_Bid_Process_Letter_Sent__c, t.X2nd_Round_Bid_Received__c, t.X2nd_Round_Bid_Process_Letter_Sent__c, t.X1st_Round_Bid_Received__c, t.X1st_Round_Bid_Process_Letter_Sent__c  From Potential_Buyer_Investor__c t WHERE t.Project__c=:prjId
                            ORDER BY t.Status__c, t.TargetBuyer__r.Name];
        List<Id> ids = new List<Id>();
        for (Potential_Buyer_Investor__c buyer : target_buyers){
            ids.add(buyer.TargetBuyer__c);
        }
        List<Account> accountsLst = [SELECT Id, name, Status__c FROM Account WHERE Id IN :ids];
        for (Account acc : accountsLst){
            accounts.put(acc.Id, acc);
        }
    }
    
    public String getXLSDescription(){
        String s = '<!--[if gte mso 9]><xml xmlns:x="urn:schemas-microsoft-com:office:excel"><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>Milestone Tracking Report</x:Name>';
        /*s += '<x:Table>';
        for (integer i=0; i<34; i++){
            s += '<x:Column></x:Column x:Width="80">';
        }
        s += '</x:Table>';*/
        s += '<x:WorksheetOptions><x:Print><x:ValidPrinterInfo/></x:Print></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]-->';
        return s;
    }
    
    public String getHeader(){
        curHeight = headHeight;
        String res = '';
        res += '<tr style="height: 75.0pt;"><td><h3><img src="'+ strImageURL +'" width="3.37in" height="0.23in"/>';
        res += '<br/><br/>' + getDealName() + '<br/>';
        res += 'Milestone Tracking Report<br/>';
        res += todayD.month() + '/' + todayD.day() + '/' + todayD.year();
        res += '</h3></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>';
        
        res += getEmptyRow('t_pad1');
        res += '<tr class="t_head">';
        res += '<td class="t_head_first" style="background-color:#015A6E;">Potential Buyer/Investor Name</td>';
        res += '<td style="background-color:#015A6E;">Status</td>';
        res += '<td class="t_body_pad" style="background-color:#015A6E;"/>';
        res += '<td style="background-color:#015A6E;">Initial<br/> Contact</td>';
        res += '<td class="t_body_pad" style="background-color:#015A6E;"/>';
        res += '<td style="background-color:#015A6E;">Teaser Sent</td>';
        res += '<td class="t_body_pad" style="background-color:#015A6E;"/>';
        res += '<td style="background-color:#015A6E;">CA Sent</td>';
        res += '<td class="t_body_pad" style="background-color:#015A6E;"/>';
        res += '<td style="background-color:#015A6E;">CA Under<br/> Negotiation</td>';
        res += '<td class="t_body_pad" style="background-color:#015A6E;"/>';
        res += '<td style="background-color:#015A6E;">CA Signed</td>';
        res += '<td class="t_body_pad" style="background-color:#015A6E;"/>';
        res += '<td style="background-color:#015A6E;">CIM / Info<br/> Package<br/> Sent</td>';
        res += '<td class="t_body_pad" style="background-color:#015A6E;"/>';
        res += '<td style="background-color:#015A6E;">CIM / Info Package<br/> Returned</td>';
        res += '<td class="t_body_pad" style="background-color:#015A6E;"/>';
        res += '<td style="background-color:#015A6E;">Management<br/> Presentation</td>';
        res += '<td class="t_body_pad" style="background-color:#015A6E;"/>';
        res += '<td style="background-color:#015A6E;">Data Room<br/> Access</td>';
        res += '<td class="t_body_pad" style="background-color:#015A6E;"/>';
        res += '<td style="background-color:#015A6E;">1st Round Bid<br/> Process Letter Sent</td>';
        res += '<td class="t_body_pad" style="background-color:#015A6E;"/>';
        res += '<td style="background-color:#015A6E;">1st Round Bid<br/> Received</td>';
        res += '<td class="t_body_pad" style="background-color:#015A6E;"/>';
        res += '<td style="background-color:#015A6E;">2nd Round Bid<br/> Process Letter Sent</td>';
        res += '<td class="t_body_pad" style="background-color:#015A6E;"/>';
        res += '<td style="background-color:#015A6E;">2nd Round Bid<br/> Received</td>';
        res += '<td class="t_body_pad" style="background-color:#015A6E;"/>';
        res += '<td style="background-color:#015A6E;">3rd Round Bid<br/> Process Letter Sent</td>';
        res += '<td class="t_body_pad" style="background-color:#015A6E;"/>';
        res += '<td style="background-color:#015A6E;">3rd Round Bid<br/> Received</td>';
        res += '<td class="t_body_pad" style="background-color:#015A6E;"/>';
        res += '<td style="background-color:#015A6E;">Declined</td>';
        res += '</tr>';         
        return res;
    }
    
    public String addTr(Integer tp){
        Integer cs = 15;
        if (tp==1) cs = 6;
        curHeight += cs;
        if (curHeight>maxHeight){
            if (repeatHeader=='true') return getHeader();
        }
        return '';
    }
    
    public String getTable(){
        for (integer i=0; i<18; i++){
            curCount.add(0);
            globalCount.add(0);
        }
        for (integer i=0; i<18; i++){
            globalCount[i] = 0;
        }
        
        String res = '<table>';
        double scale = 5.35;
        res += '<col style="mso-width-source:userset; width:'+(36*scale)+'pt">';
        res += '<col style="mso-width-source:userset; width:'+(15.35*scale)+'pt">';
        for (integer i=0; i<16; i++){
            //res += '<col style="mso-width-source:userset; width:'+(0.84111*scale)+'pt">';
            res += '<col style="mso-width-source:userset; width:'+(1.4*scale)+'pt">';
            res += '<col style="mso-width-source:userset; width:'+(15.35*scale)+'pt">';
        }
        
        res += getHeader();
        
        List<String> typeRes = new List<String>();      
        typeRes.add(getTableType('Financial', 'Financial Buyers', 'Financial Buyers Subtotal'));    
        typeRes.add(getTableType('Strategic', 'Strategic Buyers', 'Strategic Buyers Subtotal'));
        typeRes.add(getTableType('Asset Management', 'Asset Management Buyers', 'Asset Management Buyers Subtotal'));
        typeRes.add(getTableType('Bank / Lender', 'Bank / Lender Buyers', 'Bank / Lender Buyers Subtotal'));
        typeRes.add(getTableType('Credit', 'Credit Buyers', 'Credit Buyers Subtotal'));
        typeRes.add(getTableType('Debt', 'Debt Buyers', 'Debt Buyers Subtotal'));
        typeRes.add(getTableType('Equity', 'Equity Buyers', 'Equity Buyers Subtotal'));
        typeRes.add(getTableType('Hedge Fund', 'Hedge Fund Buyers', 'Hedge Fund Buyers Subtotal'));
        typeRes.add(getTableType('High Yield', 'High Yield Buyers', 'High Yield Buyers Subtotal'));
        typeRes.add(getTableType('Mezzanine', 'Mezzanine Buyers', 'Mezzanine Buyers Subtotal'));
        typeRes.add(getTableType('Shell', 'Shell Buyers', 'Shell Buyers Subtotal'));
        typeRes.add(getTableType('Sovereign Wealth Fund', 'Sovereign Wealth Fund Buyers', 'Sovereign Wealth Fund Buyers Subtotal'));
        typeRes.add(getTableType('SPAC', 'SPAC Buyers', 'SPAC Buyers Subtotal'));
        typeRes.add(getTableType('Special Situation', 'Special Situation Buyers', 'Special Situation Buyers Subtotal'));
        typeRes.add(getTableType('Other', 'Other Buyers', 'Other Buyers Subtotal'));
        integer typeCount = 0;
        while (typeCount<typeRes.size()){
            if (typeRes[typeCount]=='') typeRes.remove(typeCount);
            else typeCount++;
        }
        typeCount = 0;
        for (integer i=0; i<typeRes.size(); i++){
            if (typeCount>0) {
                res += getEmptyRow('t_pad1');               
                res += getEmptyRow('t_pad2');
            } else {
                res += getEmptyRow('t_pad1');
            }
            typeCount++;
            res += typeRes[i]; 
        }
        
        //if (globalCount[0]>0){
            if (typeCount>0) {
                res += getEmptyRow('t_pad1');
            } else {
                res += getEmptyRow('t_pad1');
            }
             
            if (typeCount>0) {              
                res += getEmptyRow('t_pad3');
            }
            res += '<tr>';
            //String s = '<tr></tr><tr>';
            res += '<td style="background-color:#dddddd;"><b>Total</b></td>';
            for (Integer i=1; i<18; i++){
                if (i>1) res += '<td class="t_body_pad" style="background-color:#dddddd;"/>'; 
                res += '<td class="t_body_total"><b>' + globalCount[i] + '</b></td>';
            }
            res += '</tr>';         
            //s += '</tr>';
            //res += s;
        //}
         
        res += '</table>';
        return res;
    }
    
    private String getTableType(String typeName, String label1, String label2){
        String res = '';
        //for (integer i=0; i<18; i++) globalCount[i] += curCount[i];
        for (integer i=0; i<18; i++) curCount[i] = 0;       
        String tres = addTr(0);
        tres += '<tr class="t_body"><td class="t_body_first"><b>' + label1 + '</b></td></tr>';
        for (Potential_Buyer_Investor__c buyer : target_buyers){
            if (buyer.Type__c != typeName) continue;
            String s = addTr(0) + '<tr class="t_body">';
            curCount[0]++; curCount[1]++;
            s += '<td class="t_body_first">' + accounts.get(buyer.TargetBuyer__c).Name + '</td>';
            s += '<td>' + (buyer.Status__c==null?'':buyer.Status__c) + '</td>';
            s += '<td class="t_body_pad"/>';
            s += '<td>' + formatDate(buyer.Initial_Contact_Made__c, 2) + '</td>';
            s += '<td class="t_body_pad"/>';
            s += '<td>' + formatDate(buyer.Teaser_Sent__c, 3) + '</td>';
            s += '<td class="t_body_pad"/>';
            s += '<td>' + formatDate(buyer.CA_Sent__c, 4) + '</td>';
            s += '<td class="t_body_pad"/>';
            s += '<td>' + formatDate(buyer.CA_Under_Negotiation__c, 5) + '</td>';
            s += '<td class="t_body_pad"/>';
            s += '<td>' + formatDate(buyer.CA_Signed__c, 6) + '</td>';
            s += '<td class="t_body_pad"/>';
            s += '<td>' + formatDate(buyer.CIM_Info_Package_Sent__c, 7) + '</td>';
            s += '<td class="t_body_pad"/>';
            s += '<td>' + formatDate(buyer.CIM_Info_Package_Returned__c, 8) + '</td>';
            s += '<td class="t_body_pad"/>';
            s += '<td>' + formatDate(buyer.Mgmt_Presentation__c, 9) + '</td>';
            s += '<td class="t_body_pad"/>';
            s += '<td>' + formatDate(buyer.Data_Room_Access__c, 10) + '</td>';
            s += '<td class="t_body_pad"/>';
            s += '<td>' + formatDate(buyer.X1st_Round_Bid_Process_Letter_Sent__c, 11) + '</td>';
            s += '<td class="t_body_pad"/>';
            s += '<td>' + formatDate(buyer.X1st_Round_Bid_Received__c, 12) + '</td>';
            s += '<td class="t_body_pad"/>';
            s += '<td>' + formatDate(buyer.X2nd_Round_Bid_Process_Letter_Sent__c, 13) + '</td>';
            s += '<td class="t_body_pad"/>';
            s += '<td>' + formatDate(buyer.X2nd_Round_Bid_Received__c, 14) + '</td>';
            s += '<td class="t_body_pad"/>';
            s += '<td>' + formatDate(buyer.X3rd_Round_Bid_Process_Letter_Sent__c, 15) + '</td>';
            s += '<td class="t_body_pad"/>';
            s += '<td>' + formatDate(buyer.X3rd_Round_Bid_Received__c, 16) + '</td>';
            s += '<td class="t_body_pad"/>';
            s += '<td>' + formatDate(buyer.Declined__c, 17) + '</td>';
            s += '</tr>';
            tres += s;
        }
        if (curCount[0]>0){
            res += tres;
            //String s = addTr(0) + '<tr class="t_body t_body_total" style="background-color:#dddddd;">';
            String s = addTr(0) + '<tr class="t_body">';
            s += '<td class="t_body_first" style="background-color:#dddddd;"><b>' + label2 + '</b></td>';
            for (Integer i=1; i<18; i++){ 
                if (i>1) s += '<td class="t_body_pad" style="background-color:#dddddd;"/>';
                s += '<td class="t_body_total"><b>' + curCount[i] + '</b></td>';
            }
            for (integer i=0; i<18; i++) globalCount[i] += curCount[i];         
            s += '</tr>';
            res += s;
            //res += '<tr><td> </td></tr>';
        }
        return res;
    }
    
    public String getDealName(){
        return deal.Name;
    }
    
    public String formatDate(Date d, Integer n){
        if (d==null) return '';
        String s = '' + d.month() + '/' + d.day() + '/' + d.year();
        curCount[n]++;
        //if (s.length()>10) s = s.substring(0, 10);
        return s;
    }
    
    public String formatDateTime(DateTime d){
        if (d==null) return '';
        String s = '' + d.month() + '/' + d.day() + '/' + d.year();
        if (d.time()!=null && d.time().hour()!=0 && d.time().minute()!=0)
            s += ' ' + formatTime(d.time());
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
        return new Pagereference('/apex/BuyersListReport_XLS?did=' + prjId);
    }
    
    public String getEmptyRow(String cls){
        String res = '';
        if (cls==null || cls.trim()=='') res += addTr(0) + '<tr>';
        else res += addTr(1) + '<tr class="' + cls + '">';
        for (integer i=0; i<30; i++){
            res += '<td/>';
        }
        res += '</tr>';
        return res; 
    }
}