/**
 * @Author      : Edward Rivera
 * @ClassName   : SL_OpportunityTopicCleanUpBatch
 * @CreatedOn   : 3 Oct 2014
 * @Test        : SL_Test_TopicAssignment
 * @Description : This is a batch executable for updating all related topics fields on Opportunities
 */
global class SL_OpportunityTopicCleanUpBatch implements Database.Batchable<sObject>, Database.Stateful {
  private String query;
  private String [] emailRecipients;
  private static User [] user = [SELECT email FROM USER where ID = :UserInfo.getUserId()]; 
  private List<SL_Opportunity_Error> errors=new List<SL_Opportunity_Error>();
    
  global SL_OpportunityTopicCleanUpBatch(String query, String[]emailRecipients) {
      //'SELECT EntityId, TopicId, EntityKeyPrefix FROM TopicAssignment where EntityKeyPrefix=\'006\''
      this.query = query;
      this.emailRecipients = emailRecipients;
  }
    
  global SL_OpportunityTopicCleanUpBatch(String query) {
      // default email recipient to current user
      this(query, new String[]{user[0].email});
  }

  global Database.QueryLocator start( Database.BatchableContext BC ) {
      return Database.getQueryLocator( query );
  }

  global void execute( Database.BatchableContext BC, List<TopicAssignment> scope ) {
      List<SL_Opportunity_Error> newErrors;
      // grab the errors from the updater
      newErrors = SL_Opportunity_Topic_Updater.updateTopicsOnOpportunities(scope);
      // and add them to the list to be emailed
      if (newErrors!=null){
    	  errors.addAll(newErrors);
      }
  }

  global void finish( Database.BatchableContext BC ) {
      // send an email containing all of the errors
      Messaging.SingleEmailMessage [] mail = new Messaging.SingleEmailMessage[]{};
      mail.add(new Messaging.SingleEmailMessage());
      mail[0].setToAddresses(emailRecipients);
      mail[0].setSubject('Opportunities that failed related topics batch process');
      String body='';
      for (SL_Opportunity_Error e: errors){
          body+='ID: '+e.getId()+' Name: '+ e.getName() + ' Error: ' + e.getError() + '\n';
      }
      mail[0].setPlainTextBody(body);
      Messaging.sendEmail(mail);        
  }
}