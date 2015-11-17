public with sharing class CompanyList_Search_Paging {
    List<CompanyWrapper> companies;
    public String query {get; set;}
    public boolean compiled {get; set;}
    private Database.Querylocator qloc;
    public List<Account> qres {get; set;}
    private Set<Id> inIds, notInIds;
    
    public CompanyList_Search_Paging(){
        compiled = false;
        con = new ApexPages.StandardSetController([SELECT Id, Name, Activity_Score__c FROM Account LIMIT 20]);
    }
    
    /*public CompanyList_Search_Paging(String q){
        query = q + ' LIMIT 100';
        try {
            ApexPages.StandardSetController c = this.con;
            compiled = true;
        } catch (Exception e){
            compiled = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
        
    }   */
    
    public CompanyList_Search_Paging(Set<Id> p_inIds, Set<Id> p_notInIds){
        inIds = p_inIds;
        notInIds = p_notInIds;
        con = new ApexPages.StandardSetController([SELECT Id, Name, Type FROM Account WHERE Id IN :inIds AND Id NOT IN :notInIds LIMIT 20]);
        try {
            
            con.setPageSize(5);
            con.first();
            compiled = true;
        } catch (Exception e){
            compiled = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
        
    }   
 
    // instantiate the StandardSetController from a query locator
    public ApexPages.StandardSetController con {get;set;}
 
    // returns a list of wrapper objects for the sObjects in the current page set
    public List<CompanyWrapper> getCompanies() {
        companies = new List<CompanyWrapper>();
        List<SObject> lst = con.getRecords();
        if (lst==null || lst.size()==0) return companies;
        for (SObject acc : lst){
            CompanyWrapper cw = new CompanyWrapper((Account)acc);
            companies.add(cw);
        }
        return companies;
    }
 
    // displays the selected items
    public PageReference process() {
        for (CompanyWrapper cw : companies) {
            if (cw.checked)
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,cw.acc.name));
        }
        return null;
    }
 
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }
 
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }
    
    public Integer pageSize {
        get {
            
            Integer prefix =  (Math.mod((Long)con.getResultSize(),(Long)con.getPageSize()) != 0)? 1 : 0;
            return  (con.getResultSize()/con.getPageSize())+prefix;
        }
        set;
    }
    
 
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
 
    // returns the first page of records
    public void first() {
        con.first();
    }
 
    // returns the last page of records
    public void last() {
        con.last();
    }
 
    // returns the previous page of records
    public void previous() {
        con.previous();
    }
 
    // returns the next page of records
    public void next() {
        con.next();
    }
 
    // returns the PageReference of the original page, if known, or the home page.
    public void cancel() {
        con.cancel();
    }
    
    public class CompanyWrapper {
        public Boolean checked{ get; set; }
        public Account acc { get; set;}
 
        public CompanyWrapper(){
            acc = new Account();
            checked = false;
        }
 
        public CompanyWrapper(Account c){
            acc = c;
            checked = false;
        }
    }
}