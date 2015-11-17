/*
Name: AddressTranslate
Author: Daniel Llewellyn
Date: 4/11/2013
Description: Used to performing translations on addresses stored in sObjects. Changes things like apt to Apartment. or 5th ave to fifth avenue. The configuration is 
specified by a custom setting object called Address_Translation_Map__c. That controls what objects and what fields on that object get translated. The translations themselves are
held in a custom object called Address_Translation__c. 
*/
public class AddressTranslate
{    
    public list<string> fieldsToTranslate = new list<string>();
    list<Address_Translation_Map__c> translationRules = new list<Address_Translation_Map__c>();
    public string objectType;
    
    //takes two maps of sObjects (the second one can be null, as it would be for calls to this trigger made during insert).
    //if finds any objects that need to have their translations updated by comparing their new and old values for all fields defined
    //as translatable on the Address_Translation_Map__c custom setting for this object type.
    
    public void findSobjectsRequiringTranslation(map<id,sobject> newMap, map<id,sObject> oldMap)
    {      
        //list of al the objects that need to get their translations updated/set.
        list<sobject> objectsToTranslate = new list<sobject>();
        
        //figure out the type of sObject contained in the maps. This will end up being like 'account' or 'contact' or something.
        objectType = newMap.getSobjectType().getDescribe().getName();
        
        //okay now find all the translation rules for this sObject type. A translation rule is simple a list of fields on an sobject for which translation needs to occure.
        //so the custom setting might have an Object_Name__c of 'account' and it's Translations_fields__c value might containg 'billing_address,shipping_address' where the list
        //of fields to translate are comma separated.
        translationRules = [select Object_Name__c, Translation_Fields__c from Address_Translation_Map__c where Object_Name__c = :objectType];

        //if there are no translation rules, then just abort. There is nothing to do for this object.
        if(translationRules.isEmpty())
        {
            return;
        }        
        
        //turn the comma separated list of fields into an array of strings for iterating over in a loop
        fieldsToTranslate = translationRules[0].Translation_Fields__c.split(',');
        
        //if there are values in our old map (meaning this is an update call of some kind) then we have to compare the new and old values of the translation fields since
        //we don't want to translate fields if they don't need it. That would be wasteful and slow. If the oldMap is null, then this is an insert call so obviously
        //all translations would need to be performed for all objects.
        if(oldMap != null)
        {
            //loop over all the objects included in the newmap
            for(Id thisObject : newMap.keySet())
            {
                //evaluate every field on this object that is defined in our translation rules
               for(string field : fieldsToTranslate)
               {
                   //make sure the old map has an entry for this object. If it doesn't then this might have been an upsert call or something, but either way
                   //since there isn't an old value to compare against, add this object just to be safe. Otherwise
                   //compare the new and old value of this field. If they don't match then we know we need to update the translation. Add this
                   //object to the list.
                   system.debug(thisObject);
                   system.debug(oldmap);
                   system.debug(newmap);
                   system.debug(field);
                   if(!oldmap.containsKey(thisObject) ||  
                      oldMap.get(thisObject).get(field) == null || 
                      (newMap.get(thisObject).get(field)) != null && !string.valueOF(newMap.get(thisObject).get(field)).equals((string) oldMap.get(thisObject).get(field)) )
                   {
                       objectsToTranslate.add(newMap.get(thisObject));
                   }
               } 
            }
        }
        //if oldmap was null then all objects need translations because this is an insert.
        else
        {
            objectsToTranslate.addAll(newMap.values());
        }
        
        //if we have any objects that require translation send em off to the translator now.
        if(!objectsToTranslate.isEmpty())
        {
            translateSobjectAddresses(objectsToTranslate);    
        }
    }
    
    //takes a list of sObjects and performs translations on their fields as defined on the custom setting for this object.
    public void translateSobjectAddresses(list<sobject> objectsToTranslate)
    {       
        //get all the translation records defined in this org. In the futuer we might want some kind of 'active' boolean flag and maybe even
        //a filter for the translations that specified what objects they are for (so not all translations have to be applied to all objects)
        //but for now we just get them all.
        list<Address_Translation__c> addressTranslations = [select name, Translations__c from Address_Translation__c];

        //this variable may have gotten set by a previous method running. If it's set, don't bother setting it again. If it's empty then set it.
        if(translationRules.isEmpty())
        {

            //figure out the type of sObject contained in the maps. This will end up being like 'account' or 'contact' or something.
            objectType = objectsToTranslate.getSobjectType().getDescribe().getName();
                
            //okay now find all the translation rules for this sObject type. A translation rule is simple a list of fields on an sobject for which translation needs to occure.
            //so the custom setting might have an Object_Name__c of 'account' and it's Translations_fields__c value might containg 'billing_address,shipping_address' where the list
            //of fields to translate are comma separated.
            translationRules = [select Object_Name__c, Translation_Fields__c from Address_Translation_Map__c where Object_Name__c = :objectType];
    
            //if there are no translation rules, then just abort. There is nothing to do for this object.
            if(translationRules.isEmpty())
            {
                return;
            }        
        }
        //turn the comma separated list of fields into an array of strings for iterating over in a loop
        fieldsToTranslate = translationRules[0].Translation_Fields__c.split(',');
        
        //create the translation map. This map has every possible SOURCE word that will be translated as the keys, and the word it will be translated to as the value.
        //so it might look like
        //apt -> Apartment
        //APARTMENT -> Apartment
        //aly -> Alley
        //ALLEY -> Alley
        //... 
        map<string,string> translationMap = createTranslationMap(addressTranslations);
        
        //okay for all the objects we got passed in iterate over all of them. 
        for(sObject thisObject : objectsToTranslate)
        {            
            //for every field that is defined as a translation field, perform the translation.
            for(string thisField : fieldsToTranslate)
            {
                thisObject.put(thisField, translateField((string) thisObject.get(thisField),translationMap));
            }
        }
        
        //update objectsToTranslate;
    }
    
    public string translateField(string fieldValue,map<string,string> translationMap)
    {
        string newValue = '';

        if(fieldValue != null)
        {
            list<string> addressWords = fieldValue.split(' ');
            
            for(string thisWord :  addressWords)
            {
                if(translationMap.containsKey(thisWord))
                {
                    system.debug('\n\n\n------------- TRANSLATION HIT! ' + thisWord + ' converted to ' + translationMap.get(thisWord));
                    newValue += translationMap.get(thisWord) + ' ';
                }
                else
                {
                    newValue += thisWord + ' ';
                }
            }
        }
        return newValue;
    }
    
    public static map<string,string> createTranslationMap(list<Address_Translation__c> addressTranslations)
    {
        map<string,string> translationMap = new map<string,string>();
        
        //first iterate over all the address translation records that get passed in. Each address translation contains a name field that represents the 'target'
        //and a semi-colon sepearted list of values that will translate to that 'target'. 
        for(Address_Translation__c thisTranslation : addressTranslations)
        {
            //break the semi colon sepearted block of 'source' into a list of strings. We can then iterate over that list to create a map entry for each 'source'
            list<string> thisTranslationsSources = thisTranslation.Translations__c != null ? thisTranslation.Translations__c.split(';') : new list<string>();
            
            //for each 'source' (such as apt, or ave) create a map entry with the translation 'target' as the value (such as apartment or avenue)
            for(string translationSource : thisTranslationsSources)
            {
                //prevent duplicates or collisions. Hopefully all translation sources are unique. God help us if they arn't.
                if(!translationMap.containsKey(translationSource))
                {
                    translationMap.put(translationSource,thisTranslation.name);
                }
            }
        }
        
        return translationMap;
    }
    
    @isTest
    public static void testAddressTranslate()
    {
        //first we create a custom setting entry for our testing object
        Address_Translation_Map__c translationMap = new Address_Translation_Map__c();
        translationMap.name = 'Account Address Translate';
        translationMap.Object_Name__c = 'Account';
        translationMap.Translation_Fields__c = 'billingStreet,shippingStreet';
        insert translationMap;
        
        //now lets create sample translation.
         Address_Translation__c sampleTranslation = new Address_Translation__c();
         sampleTranslation.name = 'Street';
         sampleTranslation.Translations__c = 'st;str;';
         insert sampleTranslation;
         
         //test to see if inserting a property causes the translation to fire. It should convert the 'st' in the name to 'Street'
         Account testAccount = new Account();
         testAccount.name = 'My accounts';
         testAccount.billingStreet = '1234 Test st';
         
         insert testAccount;
         
         map<id,account> simulateNewMap = new map<id,account>();
         simulateNewMap.put(testAccount.id,testAccount);
         
         AddressTranslate at = new AddressTranslate();
         at.findSobjectsRequiringTranslation(simulateNewMap, null);
         
         testAccount = [select id, name,billingStreet from Account where id = :testAccount.id];
         system.assertEquals('1234 Test Street',testAccount.billingStreet);
         
         //test the update version of the code to make sure that its running on update.
         testAccount.billingStreet = '1111 Test st';
         update testAccount;
        
         at.findSobjectsRequiringTranslation(simulateNewMap, simulateNewMap);     
         
    }
}