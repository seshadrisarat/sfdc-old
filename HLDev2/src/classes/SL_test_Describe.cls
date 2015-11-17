/**
 * \author Vladimir Dobrelya
 * \date Nov 26, 2014
 * \brief The test class for SL_Describe
 */
@isTest
private class SL_test_Describe {
	
	static String objectName = 'Account', fieldName = 'Name', incorrectName = '&^%!@SAD';

	@isTest static void test_getObjectFieldsDescribes() {
		system.assert( SL_Describe.isExisting( objectName ) ); // assertion of object existing
		system.assert( SL_Describe.isExisting( objectName, fieldName ) ); // assertion of field existing

		// --- CORRECT --- //
		// object describe
		system.assertNotEquals( null, SL_Describe.getToken( objectName ) );
		system.assertNotEquals( null, SL_Describe.getDescribe( objectName ) );

		// field describe
		system.assertNotEquals( null, SL_Describe.getToken( objectName, fieldName ) );
		system.assertNotEquals( null, SL_Describe.getDescribe( objectName, fieldName ) );

		// --- INCORRECT --- //
		// object describe
		system.assertEquals( null, SL_Describe.getToken( null ) );
		system.assertEquals( null, SL_Describe.getDescribe( null ) );

		system.assertEquals( null, SL_Describe.getToken( incorrectName ) );
		system.assertEquals( null, SL_Describe.getDescribe( incorrectName ) );

		// field describe
		system.assertEquals( null, SL_Describe.getToken( null, null ) );
		system.assertEquals( null, SL_Describe.getDescribe( null, null ) );

		system.assertEquals( null, SL_Describe.getToken( objectName, incorrectName ) );
		system.assertEquals( null, SL_Describe.getToken( incorrectName, incorrectName ) );

		system.assertEquals( null, SL_Describe.getDescribe( objectName, incorrectName ) );
		system.assertEquals( null, SL_Describe.getDescribe( incorrectName, incorrectName ) );
	}

	@isTest static void test_other() {
		SL_Describe.isAccessible( objectName, fieldName );
		SL_Describe.isUpdateable( objectName, fieldName );
		SL_Describe.isSortable( objectName, fieldName );
		SL_Describe.isFilterable( objectName, fieldName );
		SL_Describe.isRequired( objectName, fieldName );
		system.assertEquals( false, SL_Describe.isRequired( objectName, incorrectName ) );
		SL_Describe.getType( objectName, fieldName );
		SL_Describe.getRelationshipName( objectName, fieldName );
		system.assertEquals( 'Account', SL_Describe.getReferenceTo( 'Contact', 'AccountId' ) );
	}
}