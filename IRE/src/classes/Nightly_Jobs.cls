public class Nightly_Jobs {
    Public void Update_Recent_Sales_Rating(date UpdateAfterModifiedDate){
        list<Contact> contactMap = new list<Contact>([select id from contact where LastModifiedDate_Custom__c >: UpdateAfterModifiedDate]);
        list<id> idOut = new list<id>();
        for (contact c: contactMap){
            idOut.add(c.id);
        }
        Sales_Rating(idOut);
    }
    Public void Sales_Rating(list<id> ContactIDs){
        Map<ID, Contact> contactMap = new Map<ID, Contact>([select id, sales_rating__c, IREIT_Sales__c, status__c from contact where id in :ContactIDs]);
        Map<ID, Contact> contactUpdate = new Map<ID, Contact>();
        for (contact c: contactMap.values()){
            if (c.Status__c == 'Inactive'){
                if(c.Sales_Rating__c != '6'){
                	c.Sales_Rating__c = '6';
                	contactUpdate.put(c.id, c);
                }
                continue;
            }
            //Updates non-inactive people to 5, doesn't break the loop in case
            //they have sales
            if (c.Status__c != 'Inactive' && c.Sales_Rating__c == '6'){
                c.Sales_Rating__c = '5';
                contactUpdate.put(c.id, c);
            }
            if (c.Sales_Rating__c == null){
                c.Sales_Rating__c = '5';
                contactUpdate.put(c.id, c);
            }
            if (c.IREIT_Sales__c >= 1000000){
                if (c.Sales_Rating__c != '1'){
                	c.Sales_Rating__c = '1';
                	contactUpdate.put(c.id, c);
                }
                continue;
            }
            if (c.IREIT_Sales__c >= 500000){
                if (c.Sales_Rating__c != '2'){
                	c.Sales_Rating__c = '2';
                	contactUpdate.put(c.id, c);
                }
                continue;
            }
            if (c.IREIT_Sales__c >= 250000){
                if (c.Sales_Rating__c != '3') {
	                c.Sales_Rating__c = '3';
                	contactUpdate.put(c.id, c);
                }
                continue;
            }
            if (c.IREIT_Sales__c >= 1){
                if (c.Sales_Rating__c != '4'){
                	c.Sales_Rating__c = '4';
                	contactUpdate.put(c.id, c);
                }
                continue;
            }
        }
        update contactUpdate.values();
    }
}