/*
*Class: SL_ContactBatch
*Description: This batch class is used to update the geolocation field on Provider Address object with the field values of latitude and longitude
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
global class SL_ContactBatch implements Database.Batchable<sObject>{
 
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Latitude__c,Longitude__c FROM Provider_Address__c');
    }
 
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for (sObject s: scope){
            Provider_Address__c a = (Provider_Address__c)s;
            a.Location__Latitude__s = Decimal.valueOf(a.Latitude__c.substring(0,2)+ '.' +a.Latitude__c.substring(2));
            a.Location__Longitude__s = Decimal.valueOf('-'+a.Longitude__c.substring(0,2)+ '.' +a.Longitude__c.substring(2));
        }
        update scope;
    }
 
    global void finish(Database.BatchableContext BC){
 
    }
 
}