@isTest
private class CustomerFinancialTrackingTest {

    static testMethod void test() {
       Account a = new Account(name = 'Test');
       insert a;
       
       Task t = new Task();
       t.subject = 'Test';
       t.whatID = a.id;
       insert t;
       
       Attachment att = new Attachment();
       att.Name = 'Test Attachment';
       Blob myBlob = Blob.valueof('test');
       att.Body = myBlob;
       att.ParentID = t.id;
       insert att;
       
       /*
       Note n = new Note();
       n.Title = 'Test Note';
       n.Body = 'This is the body of the note';
       n.ParentID = t.id;
       insert n;
       */
       
       CustomerFinancialTracking.createFinancialRecord(t.id, t.whatID);
    }
}