global class scheduledIPCCFlag_DailySales implements Schedulable {
   global void execute(SchedulableContext SC) {
      UpdateDailySaleIPCCDeal updatetools = new UpdateDailySaleIPCCDeal();
      UpdateTools.UpdateIPCC();
   }
}