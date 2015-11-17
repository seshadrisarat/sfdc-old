trigger trigCase on Case (before insert,after insert) {
if(trigger.isInsert && trigger.IsAfter)
caseHandler.runCaseAssignmentRules(trigger.new);

if(trigger.isInsert && trigger.IsBefore)
caseHandler.assignRecType(trigger.new);
}