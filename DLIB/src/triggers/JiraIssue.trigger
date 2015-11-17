trigger JiraIssue on SF_Issue__c (
  before insert, before update, before delete, 
  after insert, after update, after delete, after undelete) {
  
  new JiraIssueHandler().run();

}