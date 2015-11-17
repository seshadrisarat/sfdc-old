public with sharing class CustomSearch {
     //the soql without the order and limit
     private String soql {get;set;}
    
     //the collection of contacts to display
     public List<Contact> contacts {get;set;}

     



     // the current sort direction. defaults to asc
     public String sortDir {
          get { if(sortDir == null) { sortDir = 'asc'; } return sortDir; }
          set;
     }

     //the current field to sort by. defaults to last name
     public String sortField {
          get { if(sortField == null) { sortField='lastName'; } return sortField; }
          set;
     }

     // format the soql for display on the visualforce page
     public String debugSoql {
          get { return soql + ' order by ' + sortField + ' ' + sortDir + ' limit 20 per page'; }
          set;
     }

     // initiate the controller and display some sample data when the page loads
     public CustomSearch() {
          soql = 'select firstname, lastname, Company__c, Status__c,account.name from contact where account.name !=null';
          runQuery();
     }

     // toggles the sorting of query from asc <--->desc
     public void toggleSort()
     {
          //simply toggle the direction
          sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
          //run the query again
          runQuery();
     }


     public Integer Page=0;

     public void next(){
          addPage(1);
     }
     public void prev(){
          addPage(-1);
     }
     public void addPage(Integer val){
          Page += val;
          runQuery();
     }




     // Run the actual query
     public void runQuery() {
          try {
               contacts = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' limit 20');
          } catch (Exception e) {
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'));
          }
     }

     // run the search with parameters passed via Javascript
     public PageReference runSearch()
     {
          String firstName = Apexpages.currentPage().getParameters().get('firstname');
          String lastName  = Apexpages.currentPage().getParameters().get('lastname');
          String accountName = Apexpages.currentPage().getParameters().get('accountName');
          String company = Apexpages.currentPage().getParameters().get('company');
          String status  = Apexpages.currentPage().getParameters().get('status');

          soql = 'select firstname, lastname, Company__c, Status__c,account.name from contact where account.name !=null';
          if (!firstName.equals(''))
                soql += ' and firstname LIKE \''+String.escapeSingleQuotes(firstName)+'%\'';

          if(!lastname.equals(''))
               soql += ' and lastname LIKE \''+String.escapeSingleQuotes(lastName)+'%\'';

          if(!accountName.equals(''))
               soql += ' and account.name LIKE \''+String.escapeSingleQuotes(accountName)+ '%\'';
          if(!company.equals(''))
               soql += ' and company__c LIKE \''+String.escapeSingleQuotes(company)+ '%\'';
          if(!status.equals(''))
               soql += ' and Status__c includes (\''+status+'\')';

          // run the query again
          runQuery();

          return null;
     }

     // use apex describe to build the picklist values
     public List<String> statuses{
          get{
               if(statuses == null){
                    statuses= new List<String>();
                    Schema.DescribeFieldResult field = Contact.Status__c.getDescribe();

                    for (Schema.PicklistEntry f : field.getPicklistValues())
                         statuses.add(f.getLabel());
               }
               return statuses;
          }
          set;
     }
}