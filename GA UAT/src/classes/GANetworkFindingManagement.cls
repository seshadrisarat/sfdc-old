/*Created By - Anuradha Suthar
Created on - May 20, 2013
Story - S-117095*/

public class GANetworkFindingManagement{

//Method to be called on GA Network Finding update and Insert and delete
public static void afterGAFindingUpdateInsertDelete(List<GA_Network_Finding__c> newGAFinding, Map<ID,GA_Network_Finding__c> oldGAFindingMap, boolean isInsert, boolean isDelete){
    //Update detail on Master GA Network Request
    updateGANetworkRequest(newGAFinding, oldGAFindingMap, isInsert, isDelete);
}

//Update detail on Master GA Network Request
//Update Hired Candiate information on master GA Network Request to show comma separated contact names
//of the related child GA Network Finding if GA Network Finding has Status 'Hired'
private static void updateGANetworkRequest(List<GA_Network_Finding__c> newGAFinding, Map<ID,GA_Network_Finding__c> oldGAFindingMap, boolean isInsert, boolean isDelete){
    //Get all GA Network Request which needs to be updated
    Set<ID> setGARequest = new Set<ID>();
    if(isDelete)
        for(GA_Network_Finding__c nf  : oldGAFindingMap.values()){
            //If GA Finding is deleted
            if(oldGAFindingMap.get(nf.ID).status__c == 'Hired' && oldGAFindingMap.get(nf.ID).Contact__c != null)
                setGARequest.add(oldGAFindingMap.get(nf.ID).GA_Network_Request__c);
        }
    else
        for(GA_Network_Finding__c nf  : newGAFinding){    
            //If GA Finding is inserted
            if(isInsert && nf.status__c == 'Hired' && nf.Contact__c != null)
                setGARequest.add(nf.GA_Network_Request__c);
            
            //If GA Finding is updated
            else if(!isInsert && nf.GA_Network_Request__c != oldGAFindingMap.get(nf.ID).GA_Network_Request__c){
                if(nf.GA_Network_Request__c!=null)
                    setGARequest.add(nf.GA_Network_Request__c);
                if(oldGAFindingMap.get(nf.ID).GA_Network_Request__c!=null)
                    setGARequest.add(oldGAFindingMap.get(nf.ID).GA_Network_Request__c);
            }
            else if(!isInsert && ((nf.status__c != oldGAFindingMap.get(nf.ID).status__c  && nf.Contact__c != null && (oldGAFindingMap.get(nf.ID).status__c== 'Hired' || nf.status__c == 'Hired')) || (nf.contact__c != oldGAFindingMap.get(nf.ID).contact__c && nf.status__c == 'Hired')))
                setGARequest.add(nf.GA_Network_Request__c);    
        } 
    
    //Assign Hired Candidate on GA Network Request
    List<GA_Network_Request__c> listGARequestToUpdated = new List<GA_Network_Request__c>();
    for(GA_Network_Request__c nr : [Select id,(Select id,contact__c,contact__r.name from GA_Network_Contact__r where status__c='Hired' and Contact__c != null) from GA_Network_Request__c where id in :setGARequest]){
        String hiredCandidates = '';
        Set<ID> uniqueContact = new Set<ID>();
        for(GA_Network_Finding__c gaFinding : nr.GA_Network_Contact__r){
            if(gaFinding.contact__c == null)
                continue;
            if(!uniqueContact.contains(gaFinding.contact__c)){
                if(hiredCandidates == '')
                    hiredCandidates = gaFinding.contact__r.name;
                else
                    hiredCandidates += ','+gaFinding.contact__r.name;
            }
            uniqueContact.add(gaFinding.contact__c);
        }        
        nr.Hired_Candidate_s__c = hiredCandidates;
        listGARequestToUpdated.add(nr);
    }
    
    //Update GA Network Request
    if(listGARequestToUpdated.size() > 0)
        update listGARequestToUpdated;
}

}