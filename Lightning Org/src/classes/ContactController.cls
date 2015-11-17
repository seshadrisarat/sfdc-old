public with sharing class ContactController {

    @AuraEnabled
    public static List<Contact> findNearby(Double latitude, Double longitude, Double maxDistance) {
        return Database.query('SELECT Id, Name, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Phone FROM contact' +
                       ' WHERE DISTANCE(Location__c, GEOLOCATION(' + latitude + ',' + longitude + '), \'mi\') < '+ maxDistance +
                       ' ORDER BY DISTANCE(Location__c, GEOLOCATION(' + latitude + ',' + longitude + '), \'mi\')');
        
    }

}