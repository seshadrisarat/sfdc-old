/*
 *  Documentation 
 *
 *  Author: E.Kryvobok
 *  Date:   8/28/2009
 *
 *  This controller provides support for Target Buyers List
 *  In this supporting take part following modules:
 *
 *  - TargetBuyersReport.page
 *  - TargetBuyersReport_PDF.page
 *  - TargetBuyersReport_Included.page
 *  - TargetBuyersReportController.cls (this file)
 *
 
 Modified: Privlad 02/23/2010 - task: 956
modified: Vika 03/19/2010 - Task #10065
modified: yuguziy 08/04/2010 - Task #10249
modified: Vika 05/14/2010 - Task #10350
 */
/**
* Test methods are in Test_Reports.cls
**/

public class TargetBuyersReportController {

    public boolean isTest = false;
    private List<Potential_Buyer_Investor__c> financialBuyersList = null;
    private List<Potential_Buyer_Investor__c> strategicBuyersList = null;
    private List<Potential_Buyer_Investor__c> declinedBuyersList  = null;
    
    // Controller. Prepares deal name by dealId from URL
    public TargetBuyersReportController () {
        
        
        if (getDealIdStr() == null) this.lProjectList = '';
        else this.lProjectList = [select Name from Ibanking_Project__c where Id = :getDealIdStr()].Name;
    }
    
    // variable for choosen item of the deal selected list on the page
    public String lProjectList {get; set;}  

    // prepares option list for the deal selected list on the page
    public List<SelectOption> getProjectListItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','...select...'));
        integer icount = isTest?0:20;
        List<Ibanking_Project__c> projectList = [select id, name from Ibanking_Project__c order by CreatedDate desc limit :icount];
        for(Ibanking_Project__c item: projectList) {
            options.add(new SelectOption(item.Name, item.Name));
        }
        return options;
    }
    
    // 
    public String getDealIdStr() {
        String result = System.currentPageReference().getParameters().get('dealId');
        system.debug('===> getDealIdStr()=' + result); 
        return result;
    }

    
    public String getDealName() {
        //if (getDealIdStr() == null) return '';
        String result = this.lProjectList;
        system.debug('===> getDealName()=' + result); 
        return result;
    }

    public void toNullData() {
        financialBuyersList = null;
        strategicBuyersList = null;
        declinedBuyersList  = null;
        system.debug('toNullData() =================>');
    }

    
    public Pagereference toPDF() {
        return new Pagereference('/apex/TargetBuyersReport_PDF');
    }
    
    /**
     * Lists
     */
    public List<BuyersStateClass> getFinancialBuyersList() {
        fetchingTargetBuyers();
        return getBuyersList(financialBuyersList);
    }

    public List<BuyersStateClass> getStrategicBuyersList() {
        fetchingTargetBuyers();
        return getBuyersList(strategicBuyersList);
    }

    public List<BuyersStateClass> getDeclinedBuyersList() {
        fetchingTargetBuyers();
        return getBuyersList(declinedBuyersList);
    }
    
    

    /**
     * Subtotals
     */
    public List<Integer> getFinancialSubtotal() {
        fetchingTargetBuyers();
        return getSubtotal(getFinancialBuyersList());
    }

    public List<Integer> getStrategicSubtotal() {
        fetchingTargetBuyers();
        return getSubtotal(getStrategicBuyersList());
    }

    public List<Integer> getDeclinedSubtotal() {
        fetchingTargetBuyers();
        return getSubtotal(getDeclinedBuyersList());
    }
    
    
    /**
     * Total
     */
    public List<Integer> getTotal() {
        List<Integer> total             = new List<Integer>();
        List<Integer> financialSubtotal = getFinancialSubtotal();
        List<Integer> strategicSubtotal = getStrategicSubtotal();
        List<Integer> declinedSubtotal  = getDeclinedSubtotal();
        
        for(Integer i = 0; i < financialSubtotal.size(); i++) {
            Integer sum = 0;
            sum += financialSubtotal.get(i);
            sum += strategicSubtotal.get(i);
            sum += declinedSubtotal.get(i);
            total.add(sum);
        }
        return total;
    }
    
    
    
    public class BuyersStateClass {
        public String color             { get; set; }
        public String target            { get; set; }
        public Boolean contact_made     { get; set; }
        public Boolean teaser_sent      { get; set; }
        public Boolean ca_sent          { get; set; }
        public String  ca_status        { get; set; }
        public Boolean cim_sent         { get; set; }
        public Boolean initial_bid      { get; set; }
        public Boolean final_bid        { get; set; }
        public Boolean declined         { get; set; }
    }
        
    
    /**
     * Fetching data from Database
     */
    private void fetchingTargetBuyers() {
        system.debug('lProjectList=' + lProjectList);
        if (financialBuyersList == null) {
            this.financialBuyersList = Database.query('select Name, Initial_Contact_Made__c, Teaser_Sent__c, CA_Sent__c, CIM_Info_Package_Sent__c, X1st_Round_Bid_Process_Letter_Sent__c, X3rd_Round_Bid_Process_Letter_Sent__c, Declined__c from Potential_Buyer_Investor__c where Project__r.Name = \'' + this.lProjectList + '\' and Type__c = \'Financial\' and Declined__c = null');
        }
        if (strategicBuyersList == null) {
            this.strategicBuyersList = Database.query('select Name, Initial_Contact_Made__c, Teaser_Sent__c, CA_Sent__c, CIM_Info_Package_Sent__c, X1st_Round_Bid_Process_Letter_Sent__c, X3rd_Round_Bid_Process_Letter_Sent__c, Declined__c from Potential_Buyer_Investor__c where Project__r.Name = \'' + this.lProjectList + '\' and Type__c = \'Strategic\' and Declined__c = null');
        }
        if (declinedBuyersList == null) {
            this.declinedBuyersList = Database.query('select Name, Initial_Contact_Made__c, Teaser_Sent__c, CA_Sent__c, CIM_Info_Package_Sent__c, X1st_Round_Bid_Process_Letter_Sent__c, X3rd_Round_Bid_Process_Letter_Sent__c, Declined__c from Potential_Buyer_Investor__c where Project__r.Name = \'' + this.lProjectList + '\' and Declined__c != null');
        }
    }
    
    

    private List<BuyersStateClass> getBuyersList(List<Potential_Buyer_Investor__c> inputList) {
        List<BuyersStateClass> resultList = new List<BuyersStateClass>();
        for(Integer i = 0; i < inputList.size(); i++) {
            Potential_Buyer_Investor__c item = inputList.get(i);   
            BuyersStateClass bsc        = new BuyersStateClass();
            bsc.color                   = ((i-(i/2)*2) == 0) ? '#b7c8d0' : '#ffffff'; 
            bsc.target                  = item.Name.replace(' ','&nbsp;');
            bsc.contact_made            = (item.Initial_Contact_Made__c == null) ? false: true;
            bsc.teaser_sent             = (item.Teaser_Sent__c == null) ? false: true;
            bsc.ca_sent                 = (item.CA_Sent__c == null) ? false: true;
            //bsc.ca_status               = item.CA_Status__c;// == null) ? false : true;
            bsc.cim_sent                = (item.CIM_Info_Package_Sent__c == null) ? false: true;
            bsc.initial_bid             = (item.X1st_Round_Bid_Process_Letter_Sent__c == null) ? false: true;
            bsc.final_bid               = (item.X3rd_Round_Bid_Process_Letter_Sent__c == null) ? false: true;
            bsc.declined                = (item.Declined__c == null) ? false: true;
            resultList.add(bsc);
        }
        return resultList;
    }
    


    private List<Integer> getSubtotal(List<BuyersStateClass> inputList) {
        Integer contact_made    = 0;
        Integer teaser_sent     = 0;
        Integer ca_sent         = 0;
        Integer ca_status       = 0;
        Integer cim_sent        = 0;
        Integer initial_bid     = 0;
        Integer final_bid       = 0;
        Integer declined        = 0;

        for(BuyersStateClass item: inputList) {
            contact_made    += (item.contact_made == true) ? 1 : 0;
            teaser_sent     += (item.teaser_sent == true)  ? 1 : 0;
            ca_sent         += (item.ca_sent == true)      ? 1 : 0;
            ca_status       += (item.ca_status != null)    ? 1 : 0;
            cim_sent        += (item.cim_sent == true)     ? 1 : 0;
            initial_bid     += (item.initial_bid == true)  ? 1 : 0;
            final_bid       += (item.final_bid == true)    ? 1 : 0;
            declined        += (item.declined == true)     ? 1 : 0;
        }
        List<Integer> resultList = new List<Integer>(); 
        resultList.add(contact_made);
        resultList.add(teaser_sent);
        resultList.add(ca_sent);
        resultList.add(ca_status);
        resultList.add(cim_sent);
        resultList.add(initial_bid);
        resultList.add(final_bid);
        resultList.add(declined);
        return resultList;
    }
}