public class SL_DataSource_Handler 
{
   public void onBeforeInsert(list<Data_Source__c> newDataSources){
        checkLatestDataSourceSummary(newDataSources);
   }
   public void onBeforeUpdate(list<Data_Source__c> newDataSources){
        checkLatestDataSourceSummary(newDataSources);
   }

   public void onAfterInsert(map<Id,Data_Source__c> newDataSources){
        uncheckLatestDataSourceSummaryForPriorSummaries(newDataSources);
   }
   public void onAftereUpdate(map<Id,Data_Source__c> newDataSources){
        uncheckLatestDataSourceSummaryForPriorSummaries(newDataSources);
   }

   public void checkLatestDataSourceSummary(list<Data_Source__c> newDataSources){
        set<String> latestSummaries = new set<String>();
        for(Data_Source__c ds : newDataSources){
            if( !String.isBlank(ds.Data_Source__c) 
                && !latestSummaries.contains(ds.Data_Source__c)
            ){
                latestSummaries.add(ds.Data_Source__c);
                ds.Latest_Data_Source_Summary__c = TRUE;
            }
            else{
                ds.Latest_Data_Source_Summary__c = FALSE;
            }
        }
   }


   public void uncheckLatestDataSourceSummaryForPriorSummaries(map<Id, Data_Source__c> newDataSources){
        set<String> summarizedDataSources = new set<String>();

        for(Id dsId : newDataSources.keyset()){
            Data_Source__c ds = newDataSources.get(dsId);

            if(ds.Latest_Data_Source_Summary__c == TRUE){
                summarizedDataSources.add(ds.Data_Source__c);
            }
        }

        list<Data_Source__c> oldDataSourceSummaries = [ SELECT Id, Latest_Data_Source_Summary__c
                                                        FROM Data_Source__c
                                                        WHERE Data_Source__c = :summarizedDataSources
                                                        AND Latest_Data_Source_Summary__c = TRUE
                                                        AND ID != :newDataSources.keySet()  ];
        
        if(oldDataSourceSummaries.size() > 0){
            for(Data_Source__c ds : oldDataSourceSummaries) {
                ds.Latest_Data_Source_Summary__c = FALSE;
            }
            Update oldDataSourceSummaries;
        }

   }
}