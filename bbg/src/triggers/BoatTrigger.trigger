/*
Developer   : Poundarik, Shruti
Company     : Bluewolf LLC
*/
trigger BoatTrigger on Boat__c (before insert,before update,after insert, after update, before delete) {
    if (BoatServices.disableTriggerProcessing) {
        system.debug('Disabling boat trigger processing');
        return;
    }
     
    new BoatTriggerHandler().run();
}