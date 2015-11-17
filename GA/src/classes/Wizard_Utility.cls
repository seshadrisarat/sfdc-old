//==============================================================================
// Class Name   : Wizard_Utility
// Author       : Nikita Jain
// Created Date : 30/10/2012
// Description  : Utility for workflow wizard
//==============================================================================
public class Wizard_Utility {
		
   //Method to check if the related contact is present  
   public static boolean isInvestorPresent(Id vehicleId) {
   	 list<Account> investorList = [Select id from Account
       							   where parentId = :vehicleId];
	 if(investorList != null && investorList.size() > 0)
	   return true;
	 else
	   return false;  
   }
   
   //Method to check if the related investor is present  
   public static boolean isContactPresent(Id vehicleId) {
   	 Account acc = [Select id ,(Select id from Contacts)
                       from Account where id = :vehicleId] ;
       if(acc != null) {		  
		   if(acc.Contacts.size() > 0){
		   	  return true;                    
		   }		   		   		  
       }
       return false;      
   }
   
   //Method to check if the related Commitment is present  
   public static boolean isCommitmentPresent(Id vehicleId) {
   	 list<Account> investorList = [Select id from Account
       							   where parentId = :vehicleId];
	 if(investorList != null && investorList.size() > 0) {
	    list<Investor_Commitment_Agreement__c> commitmentList = [Select id from
		                                                         Investor_Commitment_Agreement__c 
		                                                         where investor__c in : investorList]; 
	  	if(commitmentList != null && commitmentList.size() > 0)
	  		return true;	  
     }
     return false;
   }			   
      
    //Method to extract recordTypeId from name
    public static String fetchRecordTypeIdFromName(String recordTypeName) {
	  String recordTypeId ;
	  Schema.DescribeSObjectResult tskResult = Schema.SObjectType.Account;
	  Map<String,Schema.RecordTypeInfo> rtMapByName = tskResult.getRecordTypeInfosByName();
	  if(rtMapByName.containsKey(recordTypeName))
	  	recordTypeId = rtMapByName.get(recordTypeName).getRecordTypeId();     
	  return recordTypeId;
    }         
}