/**
* @author Alan Talanoa, Tamarack Consulting, Inc.
* @date 07/14/2014
* @description This class handles basic interaction with the CSC web services.
* ©Copyright 2003 - 2014 Tamarack Consulting, Inc.  All Rights Reserved.
*/
public class UccController {
 
  public String[] uccs { get; set; }
  public String debtor{get;set;}
  public Account account{get;set;}
  public String accountId { get; set; }
  public String xml { get;set; }
  public List<Ucc> uccItems{set;get;}
  public UCCController() {

    this.accountId = ApexPages.currentPage().getParameters().get('id');
    this.debtor = ApexPages.currentPage().getParameters().get('debtor');
    if (this.accountId != null) {

      Account customObject = [Select CSC_Order_Number__c, BillingState, ucc_name_search__c from Account where id = : accountId limit 1][0];
      this.account = customObject;
            System.debug('submitUCCsearch started');
      submitUccSearch();
      System.debug('submitUCCsearch done');
      submitOrder();
    }
 
  }

  public PageReference submitUccSearch() {
    this.xml = Csc.getDetailResults(account.CSC_Order_Number__c);
    PageReference pageRef = new PageReference('/apex/ucc_integration?id=' + accountId);
    pageRef.setRedirect(true);
    return (pageRef);
  }

/**
* @author Alan Talanoa, Tamarack Consulting, Inc.
* @date 07/14/2014
* @description Initial Debtor Selection
* ©Copyright 2003 - 2014 Tamarack Consulting, Inc.  All Rights Reserved.
*/
  public void submitOrder() {
    if (this.accountId != null) {
    	System.debug(this.xml);
      this.uccItems = Csc.getSecuredNames(this.xml, this.debtor);
    }
  }

/**
* @author Alan Talanoa, Tamarack Consulting, Inc.
* @date 07/14/2014
* @description UCC Selection
* @return return response of the web service
* ©Copyright 2003 - 2014 Tamarack Consulting, Inc.  All Rights Reserved.
*/
  public PageReference createUcs() {
  
    for (Ucc r: this.uccItems) {
      if (r.isSelected) {
        Ucc__c ucc = new Ucc__c();
        ucc.Secured_Party_name__c = r.name;
        ucc.Account__c = account.id;
        ucc.Notes__c = r.collateral;
        ucc.Date_Filed_Cal__c = date.valueOf((r.filingDate.split('T', 0)[0]) + ' 00:00:00');//String.valueOf(DateTime.parse(r.filingDate));
        ucc.debtor_name__c = r.DebtorName;
        ucc.debtor_address1__c = r.DebtorAddress1;
        ucc.debtor_city__c = r.DebtorCity;
        ucc.debtor_state__c = r.DebtorState;
        ucc.debtor_zip__c = r.DebtorZip;
        ucc.secured_address1__c = r.SecuredAddress1;
        ucc.secured_city__c = r.SecuredCity;
        ucc.secured_state__c = r.SecuredState;
        ucc.secured_zip__c = r.SecuredZip;
        ucc.filing_cat__c = r.FilingCat;
        ucc.filing_date_exp__c = r.FilingDateExp;
        ucc.orig_filing_num__c = r.OrigFilingNum;
        ucc.filing_num__c = r.FilingNum;
        ucc.orig_filing_date__c = r.OrigFilingDate;
        ucc.orig_filing_cat__c = r.OrigFilingCat;
        
        insert ucc;
      }
    }
    return returnToAccount();
  }
  public String getOrderId() {
    return account.CSC_Order_Number__c;
  }
  public PageReference returnToAccount(){
  	Pagereference pg = new Pagereference('/' + this.accountId); // Include name of page where user should be navigated after clicking on Back button
    pg.setRedirect(true);
    return pg;
  }
  public pagereference Cancel() {
    return returnToAccount();
  }

  public String getDebtor() {
    return this.debtor;
  }
  public void setDebtor(String debtor) {
  		this.debtor = debtor;	
  }
  public String[] getUccs() {
    return this.uccs;
  }
  public void setUccs(String[] uccs) {
    this.uccs = uccs;
  }
  public Account getAccount(){
  	return account;
  }
  // a custom (generic) exception class
  public class applicationException extends Exception {}
  // helper method to populate selectOptions from CSC request
  public List < SelectOption > getItems() {
    List < SelectOption > options = new List < SelectOption > ();
    options.add(new SelectOption('', 'Please Select'));
    Integer counter = 0;
    for (String name: Csc.getNames(this.xml)) {
    	counter = counter + 1;
      String[] a = name.split(' - ');
      a.remove(a.size() - 1);
 
      options.add(new SelectOption(System.String.join(a, ' - '), name));
      if(counter > 500){ //sanity check
      	break;
      }
    }

    return options;
  }
  // get debtor from params
  public String getSelectedDebtor() {
    return ApexPages.currentPage().getParameters().get('debtor');
  }

}