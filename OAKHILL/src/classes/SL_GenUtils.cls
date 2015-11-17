/**
 
* \author Volodymyr Babin
 
* \date 08/12/2014
 
* \see http://silverline.jira.com/browse/LIB-226
 
* \brief Silverline's general utilities class. Contains methods which are of a general nature, 
            often used in different projects.
 
* \test SL_Test_GenUtils
 
*/
public with sharing class SL_GenUtils {
	
    // <editor-fold defaultstate="collapsed" desc="Methods to work with Field Sets">
    
	/**
    * Retrieves list of fields from a field set, by its name and the name of the object.
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
    
    // </editor-fold> - Field sets.

}