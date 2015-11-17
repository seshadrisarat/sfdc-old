/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestClassNewCIFSplit2 {

static testMethod void myTest() {

try {

opportunity o = new opportunity();
o = [select id, amount, billing_split_project_2__c, billing_split_project_3__c, billing_split_project_4__c, billing_split_project_5__c, billing_split_project_6__c, billing_split_project_7__c, billing_split_project_8__c, billing_split_project_9__c, billing_split_project_10__c, billing_split_project_11__c, billing_split_project_12__c, billing_split_project_13__c from opportunity where id = '00600000008VgUo'];

o.billing_split_project_2__c = 'CCCXXX0011';
o.billing_split_project_3__c = 'DDDXXX0011';
o.billing_split_project_4__c = 'EEEXXX0011';
o.billing_split_project_5__c = 'FFFXXX0011';
o.billing_split_project_6__c = 'GGGXXX0011';
o.billing_split_project_7__c = 'HHHXXX0011';
o.billing_split_project_8__c = 'IIIXXX0011';
o.billing_split_project_9__c = 'JJJXXX0011';
o.billing_split_project_10__c = 'KKKXXX0011';
o.billing_split_project_11__c = 'LLLXXX0011';
o.billing_split_project_12__c = 'MMMXXX0011';
o.billing_split_project_13__c = 'NNNXXX0011';
update o;

opportunitylineitem oli1 = new opportunitylineitem(opportunityid = o.id, servicedate = date.newinstance(2020, 8, 10),pricebookentryid = '01u000000006foPAAQ',quantity = 1,unitprice = 0,data_type__c = 'On-Going');
insert oli1;

opportunitylineitem oli2 = new opportunitylineitem(opportunityid = o.id, servicedate = date.newinstance(2020, 8, 10),pricebookentryid = '01u000000006foQAAQ',quantity = 1,unitprice = 0,data_type__c = 'On-Going');
insert oli2;

opportunitylineitem oli3 = new opportunitylineitem(opportunityid = o.id, servicedate = date.newinstance(2020, 8, 10),pricebookentryid = '01u000000006fqdAAA',quantity = 1,unitprice = 0,data_type__c = 'On-Going');
insert oli3;

opportunitylineitem oli4 = new opportunitylineitem(opportunityid = o.id, servicedate = date.newinstance(2020, 8, 10),pricebookentryid = '01u000000006h4gAAA',quantity = 1,unitprice = 0);
insert oli4;

opportunitylineitem oli5 = new opportunitylineitem(opportunityid = o.id, servicedate = date.newinstance(2020, 8, 10),pricebookentryid = '01u000000006hapAAA',quantity = 1,unitprice = 0,data_type__c = 'On-Going');
insert oli5;

opportunitylineitem oli6 = new opportunitylineitem(opportunityid = o.id, servicedate = date.newinstance(2020, 8, 10),pricebookentryid = '01u000000006hcJAAQ',quantity = 1,unitprice = 0,data_type__c = 'On-Going');
insert oli6;

opportunitylineitem oli7 = new opportunitylineitem(opportunityid = o.id, servicedate = date.newinstance(2020, 8, 10),pricebookentryid = '01u000000006hcKAAQ',quantity = 1,unitprice = 0,data_type__c = 'On-Going');
insert oli7;

opportunitylineitem oli8 = new opportunitylineitem(opportunityid = o.id, servicedate = date.newinstance(2020, 8, 10),pricebookentryid = '01u000000006hgrAAA',quantity = 1,unitprice = 0);
insert oli8;

opportunitylineitem oli9 = new opportunitylineitem(opportunityid = o.id, servicedate = date.newinstance(2020, 8, 10),pricebookentryid = '01u000000006hh2AAA',quantity = 1,unitprice = 0,data_type__c = 'Trend Data (Prior to IPP)');
insert oli9;

opportunitylineitem oli10 = new opportunitylineitem(opportunityid = o.id, servicedate = date.newinstance(2020, 8, 10),pricebookentryid = '01u000000006hMJAAY',quantity = 1,unitprice = 0,data_type__c = 'On-Going');
insert oli10;

opportunitylineitem oli11 = new opportunitylineitem(opportunityid = o.id, servicedate = date.newinstance(2020, 8, 10),pricebookentryid = '01u000000006hMMAAY',quantity = 1,unitprice = 0,data_type__c = 'On-Going');
insert oli11;

opportunitylineitem oli12 = new opportunitylineitem(opportunityid = o.id, servicedate = date.newinstance(2020, 8, 10),pricebookentryid = '01uA0000000PaJOIA0',quantity = 1,unitprice = 0);
insert oli12;

delete oli1;
delete oli2;
delete oli3;
delete oli4;
delete oli5;
delete oli6;
delete oli7;
delete oli8;
delete oli9;
delete oli10;
delete oli11;
delete oli12;

} catch(exception e) {
}

}
}