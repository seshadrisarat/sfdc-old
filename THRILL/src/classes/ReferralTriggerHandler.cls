/**
* ReferralTriggerHandler : Class that contains code for the Referral Trigger
*/
public with sharing class ReferralTriggerHandler {
 public static set<Id> inverseReferralsInProcess;
    
    static{
        inverseReferralsInProcess = new set<Id>();
    }
    public ReferralTriggerHandler(){
    }

    // Trigger Methods ----------------------------------------------------
    //public void onBeforeInsert(list<Agency_Company__c> listNew){
    //    lookupReferredByAccount_Before(listNew);
  //  }
    public void onAfterInsert(list<Agency_Company__c> listNew){
        inverseOnInsert_After(listNew);
    }
    
    public void onBeforeUpdate(map<Id,Agency_Company__c> oldMap, list<Agency_Company__c> listNew){
      //  lookupReferredByAccount_Before(listNew);
        inverseOnUpdate(oldMap, listNew);
    }
//  public void onAfterUpdate(map<Id,Agency_Company__c> oldMap, list<Agency_Company__c> listNew){
//  }
    
    public void onBeforeDelete(map<Id,Agency_Company__c> oldMap){
        inverseOnDelete(oldMap);
    }
//  public void onAfterDelete(map<Id,Agency_Company__c> oldMap){
//  }
    
    public void onAfterUndelete(list<Agency_Company__c> listNew){
        inverseOnInsert_After(listNew);
    }

    // -----------------------------------------------------------------------------------------------------------
    // Custom business logic
    
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // if a contact was added in the Referred By Contact - lookup their account and add it to the Referred By Account
    //  Method must be in a before trigger instance
   /**    private void lookupReferredByAccount_Before(list<Agency_Company__c> listNew){
        list<Agency_Company__c> workingList = new list<Agency_Company__c>();
        set<Id> contactIds = new set<Id>();
        
        for (Agency_Company__c currReferral : listNew){
            if (currReferral.Referred_By_Contact__c!=null && currReferral.Company_Brand__c==null){
                workingList.add(currReferral);
                contactIds.add(currReferral.Referred_By_Contact__c);
            }
        }
        
        map<Id, Contact> contactMap = new map<Id, Contact>([select id, AccountId from Contact where id in :contactIds]); 
        
        for (Agency_Company__c currReferral : workingList){
            Contact currContact = contactMap.get(currReferral.Referred_By_Contact__c);
            if (currContact!=null)
                currReferral.Company_Brand__c = currContact.AccountId;
        }
    }
   **/
  
   
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // generate the inverse referral
    //  Should come after the lookupReferredByAccount logic has run
    private void inverseOnInsert_After(list<Agency_Company__c> listNew){
        map<id, Agency_Company__c> referralMap = new map<Id, Agency_Company__c>();
        list<Agency_Company__c> newInvRefs = new list<Agency_Company__c>();
        
        for(Agency_Company__c currReferral : listNew){
            if (currReferral.Inverse_Referral__c == null){
                referralMap.put(currReferral.Id, currReferral);
                
                Agency_Company__c newRef = new Agency_Company__c();
                newInvRefs.add(newRef);
                
                mapReferralInverse(currReferral, newRef);
            }
        }
        
        if (newInvRefs.size()>0){
            insert newInvRefs;
        
            list<Agency_Company__c> updateReferrals = new list<Agency_Company__c>();
             
            for(Agency_Company__c currReferral : newInvRefs){
                Agency_Company__c trigReferral = referralMap.get(currReferral.Inverse_Referral__c);
                if (trigReferral!=null){
                    updateReferrals.add(new Agency_Company__c(
                        id = trigReferral.Id,
                        Inverse_Referral__c = currReferral.Id
                    ));
                }
            }
            
            inverseReferralsInProcess.addAll(referralMap.keySet());
            update updateReferrals;
            inverseReferralsInProcess.removeAll(referralMap.keySet());
        }
    }
    private void mapReferralInverse(Agency_Company__c trigReferral, Agency_Company__c invReferral){
        String invRelationship = Utility_Common.inverseRelationshipMap.get(trigReferral.Type__c);
        
        invReferral.Company_Brand__c = trigReferral.Agency__c;
      //  invReferral.Referred_By_Contact__c      = trigReferral.Contact__c;
        invReferral.Agency__c             = trigReferral.Company_Brand__c;
       // invReferral.Contact__c                  = trigReferral.Referred_By_Contact__c;
        invReferral.Type__c                     = invRelationship;
        invReferral.Inverse_Referral__c         = trigReferral.Id;
    }
    private void inverseOnUpdate(map<Id,Agency_Company__c> oldMap, list<Agency_Company__c> listNew){
        list<Agency_Company__c> workingList = new list<Agency_Company__c>();
        for(Agency_Company__c currReferral : listNew){
            if(inverseReferralsInProcess.contains(currReferral.Id)==false &&
                (currReferral.Type__c                       != oldMap.get(currReferral.Id).Type__c                      ||
            //    currReferral.Contact__c                     != oldMap.get(currReferral.Id).Contact__c                   ||
                currReferral.Agency__c                != oldMap.get(currReferral.Id).Agency__c              ||
             //   currReferral.Referred_By_Contact__c         != oldMap.get(currReferral.Id).Referred_By_Contact__c       ||
                currReferral.Company_Brand__c    != oldMap.get(currReferral.Id).Company_Brand__c)
            ){
                workingList.add(currReferral);
            }
        }
        
        if (workingList.size()>0){
            map<Id,Agency_Company__c> inverseReferralMap = new map<Id, Agency_Company__c>([select id from Agency_Company__c where Inverse_Referral__c in :workinglist]);
            
            for(Agency_Company__c currReferral : workingList){
                mapReferralInverse(currReferral, inverseReferralMap.get(currReferral.Inverse_Referral__c));
            }
            
            inverseReferralsInProcess.addAll(inverseReferralMap.keySet());
            update inverseReferralMap.values();
            inverseReferralsInProcess.removeAll(inverseReferralMap.keySet());
        }
    }
    private void inverseOnDelete(map<Id,Agency_Company__c> oldMap){
        set<id> deleteIds = new set<Id>();
        list<Agency_Company__c> deleteList = new list<Agency_Company__c>();
        
        for(Agency_Company__c currReferral : oldMap.values()){
            if (currReferral.Inverse_Referral__c != null && 
                inverseReferralsInProcess.contains(currReferral.Id)==false){
                    
                deleteIds.add(currReferral.Inverse_Referral__c);
                deleteList.add(new Agency_Company__c(id = currReferral.Inverse_Referral__c));
            }
        }
        
        if(deleteIds.size()>0){
            inverseReferralsInProcess.addAll(deleteIds);
            delete deleteList;
            inverseReferralsInProcess.removeAll(deleteIds);
        }
    }

}