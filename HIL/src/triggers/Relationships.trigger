/*
    Silverline modified an existing package to fit the business requirements of Hilliard Lyons.
    Code modifications include additions and removal of elements from the following package:
    https://github.com/SalesforceFoundation/Relationships/. See link for details about original code.
*/
/**
* \arg TriggerName      	: Relationships
* \arg JIRATicket       	: HIL-9
* \arg CreatedOn        	: 16/DEC/2013
* \arg LastModifiedOn   	: 13/MAR/2015
* \arg CreatededBy      	: -
* \arg LastModifiedBy       : Pankaj Ganwani
* \arg Description      	: This trigger is used to manage inverse relationship records corresponding to relationships.
*/

trigger Relationships on Relationship__c (before insert, before update, before delete, 
after insert, after update, after delete, after undelete) {
    if (Relationships_ProcessControl.hasRun != true){  
        if(Trigger.isBefore && Trigger.isInsert){          
            Relationships process = new Relationships(Trigger.new, Trigger.old, Relationships_Utils.triggerAction.beforeInsert);
        }        
        else if(Trigger.isBefore && Trigger.isUpdate){      
            Relationships process = new Relationships(Trigger.new, Trigger.old, Relationships_Utils.triggerAction.beforeUpdate);
        }
        else if(Trigger.isAfter && Trigger.isInsert){         
            Relationships process = new Relationships(Trigger.new, Trigger.old, Relationships_Utils.triggerAction.afterInsert);
        }    
        else if(Trigger.isAfter && Trigger.isUpdate){          
            Relationships process = new Relationships(Trigger.new, Trigger.old, Relationships_Utils.triggerAction.afterUpdate);
        }
        else if(Trigger.isAfter && Trigger.isDelete){
            Relationships process = new Relationships(Trigger.old, null, Relationships_Utils.triggerAction.afterDelete);
        }
        else if(Trigger.isAfter && Trigger.isUnDelete)
        {
        	Relationships process = new Relationships(Trigger.new, null, Relationships_Utils.triggerAction.afterUndelete);
        }
    }
}