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
private class TestClassNewCIFSplit3 {

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

billing__c b = new billing__c(Opportunity_Name__c = o.id, billing_amount__c = 0, billing_date__c = date.newinstance(2020, 8, 10), billing_description__c = 'Test', billing_type__c = 'Split');
insert b;

billing__c b2 = new billing__c(Opportunity_Name__c = o.id, billing_amount__c = 0, billing_date__c = date.newinstance(2020, 8, 10), billing_description__c = 'Test', billing_type__c = 'Master');
insert b2;

delete b;
delete b2;
} catch(exception e) {
}

}
}