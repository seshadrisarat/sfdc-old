@isTest
private class StringUtils_Test {

	static testMethod void isEqual_TwoNullsEqual() {
		string str1 = null;
		string str2 = null;
		
		system.assertEquals(true, StringUtils.isEqual(str1, str2));	
	}
	
	static testMethod void isEqual_OneNullAndOneEmptyEqual() {
		string str1 = null;
		string str2 = '';
		
		system.assertEquals(true, StringUtils.isEqual(str1, str2));	
	}
	
	static testMethod void isEqual_TwoEmptyEqual() {
		string str1 = '';
		string str2 = '';
		
		system.assertEquals(true, StringUtils.isEqual(str1, str2));	
	}
	
	static testMethod void isEqual_DifferentCaseNotEqual() {
		string str1 = 'a';
		string str2 = 'A';
		
		system.assertEquals(false, StringUtils.isEqual(str1, str2));	
	}
	
	static testMethod void isEqual_SameStringEqual() {
		string str1 = 'AbCdeF123';
		string str2 = 'AbCdeF123';
		
		system.assertEquals(true, StringUtils.isEqual(str1, str2));	
	}
	
	static testMethod void isNotEqual_TwoNullsNotEqual() {
		string str1 = null;
		string str2 = null;
		
		system.assertEquals(false, StringUtils.isNotEqual(str1, str2));	
	}
	
	static testMethod void isNotEqual_SameStringNotEqual() {
		string str1 = 'AbCdeF123';
		string str2 = 'AbCdeF123';
		
		system.assertEquals(false, StringUtils.isNotEqual(str1, str2));	
	}
	
	static testMethod void isEqualIgnoreCase_SameStringDifferentCaseEqual() {
		string str1 = 'abcdefg123';
		string str2 = 'ABCDEFG123';
		
		system.assertEquals(true, StringUtils.isEqualIgnoreCase(str1, str2));	
	}
	
	static testMethod void isNotEqualIgnoreCase_SameStringDifferentCaseNotEqual() {
		string str1 = 'abcdefg123';
		string str2 = 'ABCDEFG123';
		
		system.assertEquals(false, StringUtils.isNotEqualIgnoreCase(str1, str2));	
	}
}