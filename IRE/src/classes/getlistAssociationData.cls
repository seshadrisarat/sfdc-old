public class getlistAssociationData {
  
  //  public getlistAssociationData ()    {        }
    public list<Association__c> listAssociation1{get;set;}
    public list<Association__c> listAssociation2{get;set;}
    public Contact listContact{get;set;}
    String conId = ApexPages.currentPage().getParameters().get('id');
//    String conId = '003q000000AdwqO';

    public getlistAssociationData(ApexPages.StandardController controller)
    { 
      if(conId !=null)
       {
         populateAssociationdata();
       }
    }  
    
  public  void  populateAssociationdata()
  {
        listAssociation1 = new list<Association__c>();
        listAssociation2 = new list<Association__c>();
        listContact = new Contact();
               
        listAssociation1 = [select ID, ContactOne__c, Name, ContactTwo__c, ContactTwo__r.Name, Contact_One_Relation__c, Contact_One_Notes__c, Contact_Two_Relation__c, Contact_Two_Notes__c from Association__c where ContactOne__c =:conId];
        listAssociation2 = [select ID, ContactTwo__c, Name, ContactOne__c, ContactOne__r.Name, Contact_One_Relation__c, Contact_One_Notes__c, Contact_Two_Relation__c, Contact_Two_Notes__c from Association__c where ContactTwo__c =:conId];
        listContact = [select ID,Name from Contact where ID =:conId];
  }
}