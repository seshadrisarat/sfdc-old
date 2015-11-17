/**  
* \arg ClassName        : SL_Gift
* \arg JIRATicket       : HL-37
* \arg CreatedOn        : 10/NOV/2014
* \arg LastModifiedOn   : 19/NOV/2014
* \arg CreatededBy      : Edward Rivera
* \arg ModifiedBy       : -
* \arg Description      : Class for encapsulating Gift data
*/

public with sharing class SL_Gift {
    /* Start - Variables */
    public Gift__c gift {get; set;}
    public Boolean selected {get; set;}
    public Decimal GiftYTD {get; set;}
    public Decimal GiftPrevYTD {get; set;}
    public SL_GiftRecipient recipient {get; set;}
    /* End - Variables */
    /* Start - Constructor */
    public SL_Gift(Gift__c gift, Decimal YTD, Decimal PrevYTD, SL_GiftRecipient recipient) {
            this.gift = gift;
            this.recipient = recipient;
            selected = false;
            GiftYTD = YTD;
            GiftPrevYTD = PrevYTD;
    }
    /* End - Constructor */
}