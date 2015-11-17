@isTest
private class Test_DescribeObject_Core {
	public static testMethod void testMethod1() {
		SL_ME_DescribeObject_Core controller = new SL_ME_DescribeObject_Core();
		
		system.debug('==== getInstance() ==== >>>> '+SL_ME_DescribeObject_Core.getInstance());
		
		system.debug('==== getAllObjects() ==== >>>> '+controller.getAllObjects());
		system.debug('==== getCustomObjects() ==== >>>> '+controller.getCustomObjects());
		system.debug('==== getStandardObjects() ==== >>>> '+controller.getStandardObjects());
		system.debug('==== getDecribedFieldsByObject(Account) ==== >>>> '+controller.getDecribedFieldsByObject('Call_Log__c'));
		system.debug('==== getFieldType() ==== >>>> '+controller.getFieldTypeByName('Account','Name'));
		system.debug('==== getFieldLabel() ==== >>>> '+controller.getFieldLabelByName('Account','Name'));
		system.debug('==== getFieldRef() ==== >>>> '+controller.getFieldReferenceByName('Account','Name'));
		system.debug('==== getFieldByName() ==== >>>> '+controller.getFieldByName('Account','Name'));
		system.debug('==== getObjLabel() ==== >>>> '+controller.getObjectLabelByName('Account'));
		system.debug('==== getFieldsByType() ==== >>>> '+controller.getObjectFieldsByType('Account','DATE'));
		system.debug('==== getNameByPrefix() ==== >>>> '+controller.getObjectNameByPrefix('Acc'));
		system.debug('==== getLabelByPrefix() ==== >>>> '+controller.getObjectLabelByPrefix('Acc'));
		system.debug('==== getObjByPrefix() ==== >>>> '+controller.getObjectByPrefix('Acc'));
		system.debug('==== getData() ==== >>>> '+controller.getData('Account','Id,Name','limit 10',''));
		
	}
}