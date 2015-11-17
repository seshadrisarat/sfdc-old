/**
* \arg ClassName      : SL_Location_Handler
* \arg JIRATicket     : FAEF-5
* \arg CreatedOn      : 23/07/2013
* \arg ModifiedBy     : -
* \arg Description    : Handler class for SL_Location trigger to calculate the total number of Location 
*						present within the same Account and update the number field of Location
*						record with formula(totalNumOfLocationOnThisAccount +1).toString()".
*						This handler also updates equipment tax rates for equipment on non-funded schedules
*/
public without sharing class SL_Location_Handler 
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private static boolean LocHandlerHasRun = false;
    
    // Constructor
    public SL_Location_Handler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    // Before Insert
    public void onAfterInsert(Map<Id,Location__c> mapNew){
        CalcLocationNumberAndName(mapNew);
    }
    
    // Before Update
    public void onAfterUpdate(Map<Id,Location__c> mapNew, map<Id, Location__c> mapOld)
    {
        if(!LocHandlerHasRun)
        {
            LocHandlerHasRun = true;
            updateNameField(mapNew);
            updateScheduleEquipment(mapNew, mapOld);
        }
        
    }

    public void CalcLocationNumberAndName(Map<Id,Location__c> mapNew)
    {
        // Get all accounts for any location in this trigger.
        // Add the account ids to a set.
        Set<Id> acctIds = new Set<Id>();
        for(Location__c loc : mapNew.values())
        {
            System.Debug(LoggingLevel.FINEST, 'location.account__c: '+loc.Account__c);
            acctIds.add(loc.Account__c);
        }

        // Get all the fields we need for all the schedules associated with any account associated with any schedule in this trigger.
        // Add them to a map.
        Map<Id,Location__c> allLocations = new Map<Id,Location__c>([SELECT Id,Name,Is_Dataload__c, Account__c,City__c,County__c,Location_Number__c,LSMId__c,State__c,Street__c,Tax_Rate__c,Zip__c
                                                 FROM Location__c 
                                                 WHERE Account__r.Id IN :acctIds]);

        // Init a map to hold an MLN and the max schedule number for that MLN.
        Map<Id,Integer> mapAcct_MaxLocNum = new Map<Id,Integer>();
        Integer maxLocationNum;
        for(Location__c loc : allLocations.values())
        {
            String locationNum = loc.Location_Number__c;
            String locationAccount = loc.Account__c;

            if(!String.isBlank(locationNum))
            {
                // make sure the location number is trimmed appropriately and then typecast it.
                locationNum = locationNum.trim();
                locationNum = locationNum.replaceFirst( '^0+', '');
                locationNum = locationNum.replaceAll('\\W', '');
                locationNum = locationNum.replaceAll('[a-z]', '');
                locationNum = locationNum.replaceAll('[A-Z]', '');
                Integer locationNumInteger = (String.isBlank(locationNum)?1:Integer.valueOf(locationNum));


                if(!mapAcct_MaxLocNum.containsKey(locationAccount))
                    mapAcct_MaxLocNum.put(locationAccount, locationNumInteger);

                maxLocationNum = mapAcct_MaxLocNum.get(locationAccount);

                if(locationNumInteger > maxLocationNum)
                {
                    maxLocationNum = locationNumInteger;
                    mapAcct_MaxLocNum.put(loc.Account__c, maxLocationNum);
                }
            }
        }
        List<Location__c> listToUpdate = new List<Location__c>();

        for(Location__c locInTrigger : mapNew.values())
        {
            Location__c locToUpdate = new Location__c(Id=locInTrigger.Id);
            if(mapAcct_MaxLocNum.containsKey(locInTrigger.Account__c) && (locInTrigger.Is_Dataload__c != true))
            {
                locToUpdate.Location_Number__c = zeroFillInteger(1+mapAcct_MaxLocNum.get(locInTrigger.Account__c));
            }

            String nameField = getLocationName(locInTrigger.Street__c !=null ? locInTrigger.Street__c : '',
                                                locInTrigger.City__c !=null ? locInTrigger.City__c : '',
                                                locInTrigger.State__c !=null ? locInTrigger.State__c :'',
                                                locInTrigger.Zip__c !=null ? locInTrigger.Zip__c : '');
            if(nameField!= null)
            {
                locToUpdate.Name = nameField;
            }
            listToUpdate.add(locToUpdate);
        }

        if(!listToUpdate.isEmpty())
        {
            update listToUpdate;
        }

    }

    private void updateNameField(Map<Id,Location__c> mapNew)
    {

        List<Location__c> listToUpdate = new List<Location__c>();

        for(Location__c location : mapNew.values())
        {
            if(location.Is_Dataload__c != true)
            {
                String nameField = getLocationName(location.Street__c !=null ? location.Street__c : '',
                                                    location.City__c !=null ? location.City__c : '',
                                                    location.State__c !=null ? location.State__c :'',
                                                    location.Zip__c !=null ? location.Zip__c : '');
                if(nameField!= null)
                {
                    Location__c locToAdd = new Location__c(Id=location.Id, Name = nameField);
                    listToUpdate.add(locToAdd);
                }
            }
        }

        if(!listToUpdate.isEmpty())
        {
            update listToUpdate;
        }

    }

    
    /*!
    * MethodName	: updateScheduleEquipment
    * param 		: List of Location__c
    * Description	: Used in onBeforeInsert and on before update method to update all tax rates on equipment on schedules that are related to this location. 
    				  This should only be happening on insert or when the location tax rate changes.
                      This should only happen on schedules that aren't funded. The list of funded statuses is in a custom setting.
    */
    private void updateScheduleEquipment(Map<Id,Location__c> mapNew, Map<Id, Location__c> mapOld)
    {
        // Custom setting holding all the statuses that are considered funded.
        Map<String,SL_FundedScheduleStatuses__c> fundedStatuses = SL_FundedScheduleStatuses__c.getAll();	 						   

        //if the new location tax rate doesn't match the old, add it to a list of Id's that need to have their equipment updated.
        Set<Id> locIdsToCauseUpdate = new Set<Id>();
        for(Location__c loc : mapNew.values())
        {
            if(loc.Tax_Rate__c != mapOld.get(loc.Id).Tax_Rate__c)
            {
                locIdsToCauseUpdate.add(loc.Id);
            }
        }
        
        // List of equipment that need their tax rates updated.
        List<Equipment__c> eqpLst = [SELECT Id, Tax_Rate_Actual__c,TR_Current__c, Location__c
                                     FROM Equipment__c
                                     WHERE Location__c IN:locIdsToCauseUpdate AND
                                     Schedule__r.Stage__c NOT IN :fundedStatuses.keySet()]; 
        
        
        // If there are equipment records, loop through them and update their tax rates as long as the new location tax rate isn't null.
        if(eqpLst!=null)
        {
            for(Equipment__c eqp : eqpLst)
            {
                if((eqp.Tax_Rate_Actual__c != eqp.TR_Current__c) && (mapNew.get(eqp.Location__c).Tax_Rate__c != null))
                {
                    eqp.Tax_Rate_Actual__c = mapNew.get(eqp.Location__c).Tax_Rate__c;
                }
            }
            
            //Update the list of equipment.
            update eqpLst;
        }
        
    }
    /*
	* MethodName	: getLocationName.
	* param 		: Street, city, state, zip.
	* Description	: This method is use to find out the location name according to other fields if they all are not blank.
	*/
    private String getLocationName(String street, String city, String state, String zip)
    {
        String locationName = street+' '+city+' '+state+' '+zip;
        /*If all values are not blank */
        if(locationName.trim()!=''){
            /*If name length exceeds 80 character then take only 80 character*/
            if(locationName.length() > 80){
                locationName = locationName.substring(0,79);
            }
            
            return locationName;
        }
        else
            return null;
    }

    private String zeroFillInteger(Integer myInt)
    {
        String over99  = '';
        String under100 = '0';
        String under10  = '00';

        String outputString = String.valueOf(0);

        if(myInt > 0)
            outputString = (myInt > 9?(myInt > 99?over99:under100):under10) + String.valueOf(myInt);

        return outputString;
    }
}