/**
* \arg ClassName      : SL_Funding_Source_Handler 
* \arg JIRATicket     : FAEF-3
* \arg CreatedOn      : 8/27/2013
* \arg ModifiedBy     : -
* \arg Description    : Handler class for SL_Funding_Source trigger to do a quick rate lookup from the Rates__c table.
*/
public without sharing class SL_Funding_Source_Handler
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private static boolean FSHandlerHasRun = false;

    public SL_Funding_Source_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
         
    public void OnAfterInsert(Map<Id,Funding_Source__c> newMap)
    {
        if(!FSHandlerHasRun)
        {
            FSHandlerHasRun = true;
            getSwapsRate(newMap);        
        }
    }
    public void OnAfterUpdate(Map<Id,Funding_Source__c> newMap)
    {
        if(!FSHandlerHasRun)
        {
            FSHandlerHasRun = true;
            getSwapsRate(newMap);
        }    
    }

    private void getSwapsRate(Map<Id,Funding_Source__c> newMap)
    {
        Map<Integer,Decimal> swapsMap = new Map<Integer,Decimal>();
        List<Rates__c> listRates = [SELECT Id, Prime__c, Rate_2_Year__c,Rate_3_Year__c,Rate_4_Year__c,Rate_5_Year__c,Rate_6_Year__c,Rate_7_Year__c,Date__c FROM Rates__c ORDER BY Date__c DESC LIMIT 1];
        List<Funding_Source__c> fsToUpdate = new List<Funding_Source__c>();

        if(listRates !=null && listRates.size()>0)
        {
            Rates__c swapRate = listRates[0];
            swapsMap.put(2,swapRate.Rate_2_Year__c);
            swapsMap.put(3,swapRate.Rate_3_Year__c);
            swapsMap.put(4,swapRate.Rate_4_Year__c);
            swapsMap.put(5,swapRate.Rate_5_Year__c);
            swapsMap.put(6,swapRate.Rate_6_Year__c);
            swapsMap.put(7,swapRate.Rate_7_Year__c);
            
            for(Funding_Source__c fs: newMap.values())
            {
                // if the # of years > 7 shove 0 into the swaps rate.
                // scratch that, make the proposed swap rate default to 0 on funding source.
                // if the value is 2-7, get the value from the map.
                Funding_Source__c newFS = new Funding_Source__c(id=fs.Id);
                if(fs.Is_Dataload__c != true &&
                   fs.Number_of_Years__c !=null &&
                   fs.Number_of_Years__c < 8 &&
                   fs.Number_of_Years__c >1 &&
                   (fs.SWAPS_Rate__c == null || fs.SWAPS_Rate__c == 0))
                {
                    newFS.SWAPS_Rate__c = swapsMap.get(Integer.valueOf(fs.Number_of_Years__c));
                    fsToUpdate.add(newFS);
                }
            }

            if(!fsToUpdate.isEmpty())
            {
                update fsToUpdate;
            }
        }
    }
}