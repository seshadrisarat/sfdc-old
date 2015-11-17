global class SL_CapitalExpenditureIAIbatch implements Database.Batchable<sObject> 
{
 
 global static set<Id> setApartmentIdUpdated = new Set<Id>();
 
 global Database.QueryLocator start(Database.BatchableContext BC)
 {
     String query = 'Select Id,Apartment__c from Capital_Expenditure__c where Include_to_Rider__c=true AND Apartment__c!= NULL';
      return Database.getQueryLocator(query);
 }
 
 global void execute(Database.BatchableContext BC, List<Capital_Expenditure__c> scope)
 {
    List<Apartment__c> lstApartmentToUpdate = new List<Apartment__c>();
    set<Id> setApartmentId = new set<Id>();
    set<Id> setFilteredApartmentId = new set<Id>();
    for(Capital_Expenditure__c objExpenditure : scope)
    {
        setApartmentId.add(objExpenditure.Apartment__c);
    }
	for(AggregateResult objAggregateResult:[SELECT Apartment__c,SUM(Total_IAI_Rent_Increase__c) 
	                                        FROM Capital_Expenditure__c
	                                        WHERE Apartment__c IN:setApartmentId AND Include_to_Rider__c = true AND Apartment__c NOT IN :setApartmentIdUpdated
	                                        GROUP BY Apartment__c])
	{
		Apartment__c objApartment = new Apartment__c(Id  = (Id)objAggregateResult.get('Apartment__c'), Total_IAI_Rent_Increase__c = (Decimal)objAggregateResult.get('expr0'));
		lstApartmentToUpdate.add(objApartment);
		setFilteredApartmentId.add(objApartment.Id);
		setApartmentIdUpdated.add(objApartment.Id);
	}
	
	for(Apartment__c objApartment:[SELECT Id,Total_IAI_Rent_Increase__c
			                               FROM Apartment__c
			                               WHERE Id IN:setApartmentId AND ID NOT IN:setFilteredApartmentId AND Id NOT IN :setApartmentIdUpdated])
	{
		objApartment.Total_IAI_Rent_Increase__c = null;
		lstApartmentToUpdate.add(objApartment);
		setApartmentIdUpdated.add(objApartment.Id);
	}
	
	if(!lstApartmentToUpdate.isEmpty())
	{
	    update lstApartmentToUpdate;
	}
 } 
 
 global void finish(Database.BatchableContext BC)
 {
     
 }
}