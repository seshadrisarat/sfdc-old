/**  
* \arg ClassName        : SL_RollupHelper
* \arg JIRATicket       : AMSEC-334
* \arg CreatedOn        : 23/Jul/2015
* \arg LastModifiedOn   : 28/Jul/2015
* \arg CreatededBy      : Vishnu
* \arg ModifiedBy       : Harsh
* \arg Description      : Helper Class for rolling up the child record values to their parent records.
*/
public with sharing class SL_RollupHelper  
{

    public static void rollupTextField(List<sObject> updatedChildRecords, 
                                        String fieldToRollup, 
                                        String rollupField, 
                                        String parentReference, 
                                        String parentObjAPI,
                                        String childRelationShipName,
                                        String delimiter,
                                        Boolean process)
    {
        set<Id> setParentIds = new set<Id>();         // Set to keep the current records' Parent Ids..
        set<Id> setUpdateRecIds = new set<Id>();     // Set to keep the current record Id to avoid them while doing delete Operation. 
        for(sObject childRec : updatedChildRecords)
        {
            Id parentRefId = (Id)(childRec.get(parentReference));

            // Checking if re-parenting is done, only in update case.
            if(Trigger.isExecuting && Trigger.isUpdate) {
                Id oldSObjectRecordParentId = (Id) Trigger.oldMap.get(childRec.Id).get(parentReference);

                // Checking the oldSObject record's parentId is NOT NULL and also changed..then adding in to the set..
                if(oldSObjectRecordParentId != NULL && parentRefId != oldSObjectRecordParentId)
                    setParentIds.add(oldSObjectRecordParentId);
            }
            setParentIds.add(parentRefId);
            setUpdateRecIds.add((Id)childRec.get('Id'));            
        }

        //rollup all children per the respective parent
        list<string> queryParts = new List<String>{rollupField, fieldToRollup, childRelationShipName, parentObjAPI};
        string rollupQuery  = string.format('SELECT Id, {0}, (SELECT Id, {1} FROM {2}', queryParts ); 
        System.debug('rollupQuery'+rollupquery);
        // If trigger fires on Delete Event...
        if(Trigger.isExecuting && Trigger.isDelete)
            rollupQuery += ' WHERE Id NOT IN : setUpdateRecIds';
        
        rollupQuery += String.format(' ORDER BY {1}) FROM {3} WHERE Id IN :setParentIds', queryParts);
        System.debug('rollupQuery'+rollupquery);
        list<sObject> parentsToUpdate = new List<sObject>();
        
        for(sObject parent : Database.Query(rollupQuery))
        {   
            Set<string> setValuesToRollup = new Set<String>();
            List<String> lstValuesToRollup = new List<String>();
            String strPText = String.ValueOf(parent.get(rollupField));
            for(sObject child : parent.getSObjects(childRelationShipName))
            {       
                String text = String.valueOf(child.get(fieldToRollup));
                System.debug('textcheck'+text);
                if(text == NULL || String.isBlank(text)) continue;

                text = process ? processSubText(text) : text;
                // Iterating and keeping all values in the set...by trimming them..
                for(String strVal : text.split(delimiter))
                    setValuesToRollup.add(strVal.trim());
                System.debug('setvals'+setValuesToRollup);
            }
            lstValuesToRollup.addAll(setValuesToRollup);
            String rollupText = String.join(lstValuesToRollup, delimiter);
            parent.put(rollupField, rollupText);
            parentsToUpdate.add(parent);
        } 
        System.debug('testing'+parentsToUpdate);
        update parentsToUpdate;
    }
    
    private static String processSubText(String subText)
    {
        if (subText != NULL)    
            return subText.replace('*', '');
        else
            return subText;
    }
}