/*
    Silverline modified an existing package to fit the business requirements of Hilliard Lyons.
    Code modifications include additions and removal of elements from the following package:
    https://github.com/SalesforceFoundation/Relationships/. See link for details about original code.
*/

trigger RelationshipAccounts on Account (after delete) {
    if (trigger.isAfter && trigger.isDelete){
        Relationships.deleteEmptyRelationships();   
    }
}