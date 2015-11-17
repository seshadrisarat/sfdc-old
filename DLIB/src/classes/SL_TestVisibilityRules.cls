@isTest
private with sharing class SL_TestVisibilityRules {
	
	static testMethod void testOfficesVisibility() {
		Office_Locations__c officeA = new Office_Locations__c(Name = 'Test Office A');
    	insert officeA;
    	Office_Locations__c officeB = new Office_Locations__c(Name = 'Test Office B');
    	insert officeB;
    	    	
    	OfficesSpecification specEmpty = new OfficesSpecification(null);
    	OfficesSpecification specOfficeA = new OfficesSpecification(new Set<String>{officeA.Id});
    	OfficesSpecification specOfficeB = new OfficesSpecification(new Set<String>{officeB.Id});
    	OfficesSpecification specOfficeAB = new OfficesSpecification(new Set<String>{officeA.Id, officeB.Id});
    	
    	Intranet_Event__c itemOfOfficeA = new Intranet_Event__c(
    		Name = 'test Event of office A',  
    		For_All_Offices__c = false, 
    		Selected_Offices_Ids__c = officeA.Id, 
    		Selected_Department_Ids__c = null
    	);
    	Intranet_Event__c itemOfOfficeB = new Intranet_Event__c(
    		Name = 'test Event of Office B', 
    		For_All_Offices__c = false, 
    		Selected_Offices_Ids__c = officeB.Id, 
    		Selected_Department_Ids__c = null
    	);
    	Intranet_Event__c itemOfOfficeAB = new Intranet_Event__c(
    		Name = 'test Event of Office AB',  
    		For_All_Offices__c = false, 
    		Selected_Offices_Ids__c = officeB.Id + ';' + officeA.Id, 
    		Selected_Department_Ids__c = null
    	);
    	Intranet_Event__c itemForAllOffices = new Intranet_Event__c(
    		Name = 'test Event of Office ForAll', 
    		For_All_Offices__c = true, 
    		Selected_Offices_Ids__c = officeB.Id + ';' + officeA.Id, 
    		Selected_Department_Ids__c = null
    	);
    	Intranet_Event__c itemUnassigned = new Intranet_Event__c(
    		Name = 'test Event of Unassigned Offices', 
    		For_All_Offices__c = false, 
    		Selected_Offices_Ids__c = null, 
    		Selected_Department_Ids__c = null
    	);
    	
    	
    	
    	
    	Intranet_App__c itemOfAppA = new Intranet_App__c(
    		Name = 'test App of office A',  
    		For_All_Offices__c = false, 
    		Selected_Office_Ids__c = officeA.Id, 
    		Selected_Department_Ids__c = null
    	);
    	Intranet_App__c itemOfAppB = new Intranet_App__c(
    		Name = 'test App of Office B', 
    		For_All_Offices__c = false, 
    		Selected_Office_Ids__c = officeB.Id, 
    		Selected_Department_Ids__c = null
    	);
    	Intranet_App__c itemOfAppAB = new Intranet_App__c(
    		Name = 'test App of Office AB',  
    		For_All_Offices__c = false, 
    		Selected_Office_Ids__c = officeB.Id + ';' + officeA.Id, 
    		Selected_Department_Ids__c = null
    	);
    	Intranet_App__c itemForAllApps = new Intranet_App__c(
    		Name = 'test App of Office ForAll', 
    		For_All_Offices__c = true, 
    		Selected_Office_Ids__c = officeB.Id + ';' + officeA.Id, 
    		Selected_Department_Ids__c = null
    	);
    	Intranet_App__c itemAppUnassigned = new Intranet_App__c(
    		Name = 'test App of Unassigned Offices', 
    		For_All_Offices__c = false, 
    		Selected_Office_Ids__c = null, 
    		Selected_Department_Ids__c = null
    	);
    	
    	Notification__c itemNotification = new Notification__c(
    		Name = 'test Notification for Office visibilty',
    		For_All_Offices__c = false, 
    		Selected_Offices_Ids__c = officeB.Id, 
    		Selected_Department_Ids__c = null
    	);
    	
    	Test.startTest();
    	
    	//For Sobject method coverage
    	system.assert(specOfficeB.satisfiedBy(itemNotification));
    	
    	// empty specification allows FOR ALL OFFICES documents only
    	system.assert(
    		!specEmpty.satisfiedBy(itemOfOfficeA) && 
    		!specEmpty.satisfiedBy(itemOfOfficeB) && 
    		!specEmpty.satisfiedBy(itemOfOfficeAB) && 
    		!specEmpty.satisfiedBy(itemForAllOffices) && 
    		!specEmpty.satisfiedBy(itemUnassigned) 
    	);
    	
    	// office related specification allows only respective office or FOR ALL
    	system.assert(
    		specOfficeB.satisfiedBy(itemOfOfficeB) && 
    		specOfficeB.satisfiedBy(itemOfOfficeAB) && 
    		specOfficeB.satisfiedBy(itemForAllOffices) && 
    		!specOfficeB.satisfiedBy(itemOfOfficeA) && 
    		!specOfficeB.satisfiedBy(itemUnassigned) 	 
    	);
    	// offices related specification allows only respective offices or FOR ALL
    	system.assert(
    		specOfficeAB.satisfiedBy(itemOfOfficeA) && 
    		specOfficeAB.satisfiedBy(itemOfOfficeB) && 
    		specOfficeAB.satisfiedBy(itemOfOfficeAB) && 
    		specOfficeAB.satisfiedBy(itemForAllOffices) && 
    		!specOfficeAB.satisfiedBy(itemUnassigned)
    	);
    	
    	
    	
    	//----Test code for Intranet App related method in Office Specification
    	
    	// empty specification allows FOR ALL OFFICES documents only
    	system.assert(
    		!specEmpty.satisfiedBy(itemOfAppA) && 
    		!specEmpty.satisfiedBy(itemOfAppB) && 
    		!specEmpty.satisfiedBy(itemOfAppAB) && 
    		!specEmpty.satisfiedBy(itemForAllApps) && 
    		!specEmpty.satisfiedBy(itemAppUnassigned) 
    	);
    	
    	// office related specification allows only respective office or FOR ALL
    	system.assert(
    		specOfficeB.satisfiedBy(itemOfAppB) && 
    		specOfficeB.satisfiedBy(itemOfAppAB) && 
    		specOfficeB.satisfiedBy(itemForAllApps) && 
    		!specOfficeB.satisfiedBy(itemOfAppA) && 
    		!specOfficeB.satisfiedBy(itemAppUnassigned) 	 
    	);
    	// offices related specification allows only respective offices or FOR ALL
    	system.assert(
    		specOfficeAB.satisfiedBy(itemOfAppA) && 
    		specOfficeAB.satisfiedBy(itemOfAppB) && 
    		specOfficeAB.satisfiedBy(itemOfAppAB) && 
    		specOfficeAB.satisfiedBy(itemForAllApps) && 
    		!specOfficeAB.satisfiedBy(itemAppUnassigned)
    	);
    	
    	
    	
    	
    	Test.stopTest();
	}
	
	static testMethod void testDepartmentsVisibility() {    	
    	Department__c departmentA = new Department__c(Name = 'Test Department A');
    	insert departmentA;
    	Department__c departmentB = new Department__c(Name = 'Test Department B');
    	insert departmentB;
    	
    	DepartmentSpecification specEmpty = new DepartmentSpecification(null);
    	DepartmentSpecification specDepartmentA = new DepartmentSpecification(departmentA.Id);
    	DepartmentSpecification specDepartmentB = new DepartmentSpecification(departmentB.Id);
    	DepartmentSpecification specAllDept = new DepartmentSpecification('All');
    	
    	
    	Intranet_Event__c itemOfDepartmentA = new Intranet_Event__c(
    		Name = 'test Event of Department A', 
    		For_All_Departments__c = false, 
    		Selected_Department_Ids__c = departmentA.Id
    	);
    	Intranet_Event__c itemOfDepartmentB = new Intranet_Event__c(
    		Name = 'test Event of Department B', 
    		For_All_Departments__c = false, 
    		Selected_Department_Ids__c = departmentB.Id
    	);
    	Intranet_Event__c itemOfDepartmentAB = new Intranet_Event__c(
    		Name = 'test Event of Department AB', 
    		For_All_Departments__c = false,
    		Selected_Department_Ids__c = departmentB.Id + ';' + departmentA.Id
    	);
    	Intranet_Event__c itemForAllDepartments = new Intranet_Event__c(
    		Name = 'test Event of all Department', 
    		For_All_Departments__c = true,
    		Selected_Department_Ids__c = ''
    	);
    	Intranet_Event__c itemForAllDepartmentsNotEmpty = new Intranet_Event__c(
    		Name = 'test Event of all Department', 
    		For_All_Departments__c = true,
    		Selected_Department_Ids__c = departmentB.Id + ';' + departmentA.Id
    	);
    	Intranet_Event__c itemUnassigned = new Intranet_Event__c(
    		Name = 'test Event of Unassigned Department',  
    		For_All_Departments__c = false,
    		Selected_Department_Ids__c = null
    	);
    	
    	
    	Intranet_App__c intraAppOfDepartmentA = new Intranet_App__c(
    		Name = 'test App of Department A', 
    		For_All_Departments__c = false, 
    		Selected_Department_Ids__c = departmentA.Id
    	);
    	Intranet_App__c intraAppOfDepartmentB = new Intranet_App__c(
    		Name = 'test App of Department B', 
    		For_All_Departments__c = false, 
    		Selected_Department_Ids__c = departmentB.Id
    	);
    	Intranet_App__c intraAppOfDepartmentAB = new Intranet_App__c(
    		Name = 'test App of Department AB', 
    		For_All_Departments__c = false,
    		Selected_Department_Ids__c = departmentB.Id + ';' + departmentA.Id
    	);
    	Intranet_App__c intraAppForAllDepartments = new Intranet_App__c(
    		Name = 'test App of all Department', 
    		For_All_Departments__c = true,
    		Selected_Department_Ids__c = ''
    	);
    	Intranet_App__c intraAppForAllDepartmentsNotEmpty = new Intranet_App__c(
    		Name = 'test App of all Department', 
    		For_All_Departments__c = true,
    		Selected_Department_Ids__c = departmentB.Id + ';' + departmentA.Id
    	);
    	Intranet_App__c intraAppUnassigned = new Intranet_App__c(
    		Name = 'test App of Unassigned Department',  
    		For_All_Departments__c = false,
    		Selected_Department_Ids__c = null
    	);
    	
    	   	   	
    	    	    	
    	
    	Test.startTest();
    	
    	// empty specification allows FOR ALL DEPARTMENTS documents or documents with no departments assigned
    	system.assert(
    		!specEmpty.satisfiedBy(itemOfDepartmentA) && 
    		!specEmpty.satisfiedBy(itemOfDepartmentB) && 
    		!specEmpty.satisfiedBy(itemOfDepartmentAB) && 
    		specEmpty.satisfiedBy(itemForAllDepartments) &&
    		!specEmpty.satisfiedby(itemForAllDepartmentsNotEmpty) &&  
    		specEmpty.satisfiedBy(itemUnassigned) 
    	);
    	
    	// department related specification allows only respective department or FOR ALL
    	system.assert(
    		specDepartmentB.satisfiedBy(itemOfDepartmentB) && 
    		specDepartmentB.satisfiedBy(itemOfDepartmentAB) && 
    		specDepartmentB.satisfiedBy(itemForAllDepartments) && 
    		!specDepartmentB.satisfiedBy(itemOfDepartmentA) && 
    		!specDepartmentB.satisfiedBy(itemUnassigned) 	 
    	);
    	system.assert(
    		specDepartmentA.satisfiedBy(itemOfDepartmentA) && 
    		specDepartmentA.satisfiedBy(itemOfDepartmentAB) && 
    		specDepartmentA.satisfiedBy(itemForAllDepartments) && 
    		!specDepartmentA.satisfiedBy(itemOfDepartmentB) && 
    		!specDepartmentA.satisfiedBy(itemUnassigned) 	 
    	);    	
    	
    	
    	system.assert(
    		specAllDept.satisfiedBy(itemOfDepartmentA) && 
    		specAllDept.satisfiedBy(itemOfDepartmentB) &&
    		specAllDept.satisfiedBy(itemOfDepartmentAB) && 
    		!specAllDept.satisfiedBy(itemForAllDepartments) && 
    		specAllDept.satisfiedby(itemForAllDepartmentsNotEmpty) &&  
    		!specAllDept.satisfiedBy(itemUnassigned) 	 
    	); 
    	
    	
    	//-----Test code for Intranet App Department Specfication-----//
    	// empty specification allows FOR ALL DEPARTMENTS documents or documents with no departments assigned
    	system.assert(
    		!specEmpty.satisfiedBy(intraAppOfDepartmentA) && 
    		!specEmpty.satisfiedBy(intraAppOfDepartmentB) && 
    		!specEmpty.satisfiedBy(intraAppOfDepartmentAB) && 
    		specEmpty.satisfiedBy(intraAppForAllDepartments) &&
    		!specEmpty.satisfiedby(intraAppForAllDepartmentsNotEmpty) &&  
    		specEmpty.satisfiedBy(intraAppUnassigned) 
    	);
    	
    	// department related specification allows only respective department or FOR ALL
    	system.assert(
    		specDepartmentB.satisfiedBy(intraAppOfDepartmentB) && 
    		specDepartmentB.satisfiedBy(intraAppOfDepartmentAB) && 
    		specDepartmentB.satisfiedBy(intraAppForAllDepartments) && 
    		!specDepartmentB.satisfiedBy(intraAppOfDepartmentA) && 
    		!specDepartmentB.satisfiedBy(intraAppUnassigned) 	 
    	);
    	system.assert(
    		specDepartmentA.satisfiedBy(intraAppOfDepartmentA) && 
    		specDepartmentA.satisfiedBy(intraAppOfDepartmentAB) && 
    		specDepartmentA.satisfiedBy(intraAppForAllDepartments) && 
    		!specDepartmentA.satisfiedBy(intraAppOfDepartmentB) && 
    		!specDepartmentA.satisfiedBy(intraAppUnassigned) 	 
    	);    	
    	
    	
    	system.assert(
    		specAllDept.satisfiedBy(intraAppOfDepartmentA) && 
    		specAllDept.satisfiedBy(intraAppOfDepartmentB) &&
    		specAllDept.satisfiedBy(intraAppOfDepartmentAB) && 
    		!specAllDept.satisfiedBy(intraAppForAllDepartments) && 
    		specAllDept.satisfiedby(intraAppForAllDepartmentsNotEmpty) &&  
    		!specAllDept.satisfiedBy(intraAppUnassigned) 	 
    	); 
    	
    	
    	Test.stopTest();
    }
}