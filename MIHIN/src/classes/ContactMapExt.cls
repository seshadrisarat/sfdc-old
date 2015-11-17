public with sharing class ContactMapExt {
public String searchText {get;set;}
public List<Contact> contacts{get; private set;}
public List<Provider_Address__c> addresses {get;set;}

public static final String GEOCODING_URI_BASE = 'https://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=';

// For purposes of this demo I'll geocode only couple of addresses server-side. Real code can use the commented out value.
public static final Integer MAX_CALLOUTS_FROM_APEX = 3; // Limits.getLimitCallouts()



public ContactMapExt(ApexPages.StandardController controller) {
    searchText = ApexPages.currentPage().getParameters().get('q');
    addresses = [SELECT Location__Latitude__s, Location__Longitude__s FROM Provider_Address__c WHERE Provider__c =: controller.getId()];
}

public void find() {
    
}

public void clearGeocodedData(){
  
}

public String getContactsJson(){
    return JSON.serialize(addresses);
}
public String getDebugContactsJson(){
    return JSON.serializePretty(contacts);
}

private void serverSideGeocode(){
   /* List<Contact> contactsToUpdate = new List<Contact>();
    Http h = new Http();  
    HttpRequest req = new HttpRequest();
    req.setMethod('GET'); 
    req.setTimeout(10000);

    for(Contact c : contacts){
        if((c.Location__Latitude__s == null || c.Location__Longitude__s == null)){
            String address = c.MailingStreet != null ? c.MailingStreet + ' ' : '' +
                c.MailingCity != null ? c.MailingCity + ' ' : '' +
                c.MailingState != null ? c.MailingState + ' ' : '' +
                c.MailingPostalCode != null ? c.MailingPostalCode + ' ' : '' +
                c.MailingCountry != null ? c.MailingCountry : '';
            if(address != ''){
                req.setEndpoint(GEOCODING_URI_BASE + EncodingUtil.urlEncode(address, 'UTF-8'));
                try{
                    HttpResponse res = h.send(req);
                    GResponse gr = (GResponse) JSON.deserialize(res.getBody(), ContactMapExt.GResponse.class);
                    if(gr.status == 'OK'){
                        LatLng ll = gr.results[0].geometry.location;
                        c.Location__Latitude__s = ll.lat;
                        c.Location__Longitude__s = ll.lng;
                        contactsToUpdate.add(c);
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Geocoding of "' + address + '" failed:' + gr.status));
                    }
                }catch(Exception e){
                    ApexPages.addMessages(e);
                }
            }
            // Bail out if we've reached limit of callouts (not all contacts might have been processed).
            if(Limits.getCallouts() == MAX_CALLOUTS_FROM_APEX) {
                break;
            }
        }
    }
    if(!contactsToUpdate.isEmpty()) {
        Database.update(contactsToUpdate, false); // some data in Developer editions is invalid (on purpose I think).
        // If update fails because "j.davis@expressl&amp;t.net" is not a valid Email, I want the rest to succeed
    } */
}

// Helper class - template into which results of lookup will be parsed. Some fields are skipped!
// Visit https://developers.google.com/maps/documentation/geocoding/#Results if you need to create full mapping.
/*public class GResponse{
    public String status;
    public GComponents[] results;
}
public class GComponents{
   public String formatted_address;
   public GGeometry geometry;
}
public class GGeometry {
    public LatLng location;
}
public class LatLng{
    public Double lat, lng;
}*/
 @isTest
    public static void test_ContactMap()
    {
        Test.startTest();
        
        Account testAcc = new Account(name = 'testAccount');
        insert testAcc;
        
        Contact testCon = new Contact(lastName = 'testContact',
                                      firstname = 'first',
                                      AccountId = testAcc.Id);
        insert testCon;                           
        
        provider_address__c testPA = new provider_address__c(provider__c = testCon.Id, city__c = 'NY');
        insert testPA;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(testCon); 
            
        ContactMapExt cme = new ContactMapExt(controller);
        cme.getContactsJson();
        cme.getDebugContactsJson();
        
        Test.stopTest();

    }
}