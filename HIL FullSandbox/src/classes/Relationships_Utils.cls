/*
    Silverline modified an existing package to fit the business requirements of Hilliard Lyons.
    Code modifications include additions and removal of elements from the following package:
    https://github.com/SalesforceFoundation/Relationships/. See link for details about original code.
*/

/**
* \arg ClassName      		: Relationships_Utils
* \arg JIRATicket       	: HIL-9
* \arg CreatedOn        	: 16/DEC/2013
* \arg LastModifiedOn   	: 13/MAR/2015
* \arg CreatededBy      	: -
* \arg LastModifiedBy       : Pankaj Ganwani
* \arg Description      	: This util class is used to hold the generic functions related to Relationship trigger that can be called from handler class.
*/

public class Relationships_Utils {

     public enum triggerAction {beforeInsert, beforeUpdate, beforeDelete, afterInsert, afterUpdate, afterDelete, afterUndelete}
     
     /**
		* @author Pankaj Ganwani
		* @date 13/MAR/2015
		* @description Used to return fields of fieldset corresponding to the passed field set name and object name
	*/
     public static List<Schema.FieldSetMember> getFieldSetFlds(String fieldSetName, String objectName)
     {
        Map<String, Schema.SObjectType> gdm = Schema.getGlobalDescribe(); 
        Schema.SObjectType objType = gdm.get(objectName);
        if(objType!=null){
            Schema.DescribeSObjectResult describe = objType.getDescribe();
            Schema.FieldSet fieldSetObj = describe.FieldSets.getMap().get(fieldSetName);
            if (fieldSetObj!=null){
                return fieldSetObj.getFields(); 
            }
        }
        return null;
    }    
}