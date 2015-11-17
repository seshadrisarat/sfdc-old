/**  
* \arg ClassName        : SL_GiftRecipient
* \arg JIRATicket       : HL-37
* \arg CreatedOn        : 10/NOV/2014
* \arg LastModifiedOn   : 19/NOV/2014
* \arg CreatededBy      : Edward Rivera
* \arg ModifiedBy       : -
* \arg Description      : Class for encapsulating Gift recipient data
*/

public with sharing class SL_GiftRecipient {
    /* Start - Variables */
    public Contact recipient {get; set;}
    public Decimal GiftPrevYTD {get; set;}
    public Decimal GiftValue {get; set;}
    public Boolean selected {get; set;}
    /* End - Variables */
    /* Start - Constructor */
    public SL_GiftRecipient(Contact contact) {
        recipient = contact;
        selected = false;
        
        GiftPrevYTD = 0.0;
        GiftValue = 0.0;
        if (!contact.Gifts__r.isEmpty()) {
            for(Gift__c gift: contact.Gifts__r) {
                if (gift.Approved__c == 'Approved' && gift.Desired_Date__c.year() == System.now().year() ) {
                    GiftPrevYTD += gift.Gift_Value__c;
                }
                
            }
        }
    }
    /* End - Constructor */
    /*
        @MethodName : getGiftYTD
        @param      : 
        @Description: calculates giftYTD based on the previous value in addition to the new gift value
    */
    public Decimal getGiftYTD(){
        return GiftPrevYTD + GiftValue;
    }

}