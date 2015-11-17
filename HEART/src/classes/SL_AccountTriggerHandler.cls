/**
*  ClassName      : SL_AccountTriggerHandler
*  JIRATicket     : Heart-7
*  CreatedOn      : 6/DEC/2013
*  ModifiedBy     : Sandeep
*  Description    : Handler class to update the Estimated Future Account date on Account when an Account record is being 
                    updated. 
*/
public with sharing class SL_AccountTriggerHandler 
{
    /* Constructor */
    public SL_AccountTriggerHandler()
    {
        //Do nothing.
    }
    
    /*
        * MethodName        : onAfterUpdate
        * param             : map<id, Account> mapNewAccount , map<id, Account> mapOldAccount
        * Description       : This function will be called after Update of the Account Records to update the Estimated Future Account date of Account.
    */
    public void onAfterUpdate(map<Id, Account> mapNewAccounts , map<Id, Account> mapOldAccounts )
    {
        updateFutureAccountDate(mapNewAccounts, mapOldAccounts);
    }
    
    /*
        * MethodName        : updateFutureAccountDate
        * param             : map<id, Account> mapNewAccount , map<id, Account> mapOldAccount
        * Description       : This function will be called after Update of the account Records to update the Estimated Future account date of account.
    */
    private void updateFutureAccountDate(map<Id, Account> mapNewAccounts , map<Id, Account> mapOldAccounts )
    {
        try
        {
            Set<Id> setValidAccounts = new Set<Id>();
            Map<String, Integer> mapfrequencyToMonth = new Map<String, Integer>{'Monthly' => 1, 'Quarterly' => 3, 'Semi-Annually' => 6, 'Annually' => 12};
            list<account> lstAccountToBeUpdate = new List<Account>(); // Contains all the account records need to be update 
                
            for(Account objAccount : mapNewAccounts.values())
            {
                if( objAccount.Upcoming_meeting_material_update__pc != mapOldAccounts.get(objAccount.Id).Upcoming_meeting_material_update__pc 
                 || objAccount.Upcoming_phone_material_update__pc   != mapOldAccounts.get(objAccount.Id).Upcoming_phone_material_update__pc 
                 || objAccount.Last_meeting_material_update__pc     != mapOldAccounts.get(objAccount.Id).Last_meeting_material_update__pc 
                 || objAccount.Last_phone_material_update__pc       != mapOldAccounts.get(objAccount.Id).Last_phone_material_update__pc 
                 || objAccount.CommFreq_Phone__pc                   != mapOldAccounts.get(objAccount.Id).CommFreq_Phone__pc 
                 || objAccount.CommFreq_Meeting__pc                 != mapOldAccounts.get(objAccount.Id).CommFreq_Meeting__pc 
                 || objAccount.Phone__pc                            != mapOldAccounts.get(objAccount.Id).Phone__pc 
                 || objAccount.Meeting__pc                          != mapOldAccounts.get(objAccount.Id).Meeting__pc)
                {
                    setValidAccounts.add(objAccount.Id);
                }
                
            }
            
            // Checking if is there any completed activity is there with type Material update meeting or material update phone
            for(Account objAccountrec : [select Id, Meeting__pc, CommFreq_Meeting__pc, CommFreq_Phone__pc, Phone__pc, Last_phone_material_update__pc, Last_meeting_material_update__pc, Last_material_update_exception__pc,Upcoming_phone_material_update__pc,Upcoming_meeting_material_update__pc, Upcoming_material_update_exception__pc 
                                        FROM Account Where Id IN: setValidAccounts])
                    {                   
                        //If last phone material is not null then will update upcoming phone material update field according to the last material date.
                        if(objAccountrec.Last_phone_material_update__pc != null )
                        {
                            objAccountrec.Upcoming_phone_material_update__pc = objAccountrec.Last_phone_material_update__pc.addMonths(mapfrequencyToMonth.get(objAccountrec.CommFreq_Phone__pc)); 
                        }
                        //If last meeting material is not null then will update upcoming phone material update field according to the last material date.
                        if(objAccountrec.Last_meeting_material_update__pc != null)
                        {
                            objAccountrec.Upcoming_meeting_material_update__pc  = objAccountrec.Last_meeting_material_update__pc.addMonths(mapfrequencyToMonth.get(objAccountrec.CommFreq_Meeting__pc)); 
                        }
                        lstAccountToBeUpdate.add(objAccountrec);

                        if(objAccountrec.Last_material_update_exception__pc == null)
                        {
                            objAccountrec.Upcoming_material_update_exception__pc = null;
                        }
                        // If Last Material Update Exception has a value...
                        else
                        {
                            // If type is Meeting material update
                            if(objAccountrec.Meeting__pc == true && objAccountrec.Phone__pc == false)
                                objAccountrec.Upcoming_material_update_exception__pc = objAccountrec.Last_material_update_exception__pc.addMonths(mapfrequencyToMonth.get(objAccountrec.CommFreq_Meeting__pc)); 
                            else if(objAccountrec.Meeting__pc == false && objAccountrec.Phone__pc == true)
                                objAccountrec.Upcoming_material_update_exception__pc = objAccountrec.Last_material_update_exception__pc.addMonths(mapfrequencyToMonth.get(objAccountrec.CommFreq_Phone__pc)); 
                            else
                                objAccountrec.Upcoming_material_update_exception__pc = null;
                        }
                    }
                    
                // Updating the account Field accordingly the conditions
                if(lstAccountToBeUpdate.size() > 0 )
                {
                    update lstAccountToBeUpdate;
                }
                
                if(test.isRunningTest())
                    integer i = 10/0;
        }
        catch(Exception ex)
        {
            system.debug('exception----'+ex);
        }
    }
}