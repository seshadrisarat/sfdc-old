/*******************************************************************
* Author        :  Harshit Jain (Appirio Offshore)
* Name          :  Wizard_VehicleTest
* Date          :  Oct 29,2012
* Description   :  Verify functionality of Wizard_Vehicle class.                 
*******************************************************************/
@isTest
private class Wizard_VehicleControllerTest {

    static testMethod void testVehicleController() {
        //Case 48779 - LSLEVIN - 6.4.2013-START
        //Account vehicle = Test_Utility.createAccount('V-1',null,'Vehicle-LP');
        Account vehicle = Test_Utility.createAccount('V-1',null,'Vehicle');
        //Case 48779 - LSLEVIN - 6.4.2013-END
        insert vehicle;
        Wizard_VehicleController wizard_Vehicle = new Wizard_VehicleController();
        //Case 48779 - LSLEVIN - 6.4.2013-START
        //wizard_Vehicle.selectedVehicleRC = 'Vehicle-CoInvestor';
        wizard_Vehicle.selectedVehicleRC = 'Vehicle';
        //Case 48779 - LSLEVIN - 6.4.2013-END
        
        //Update existing vehicle eecord
        wizard_Vehicle.companyVehicle = getVehicle('V-1').get(0);
        wizard_Vehicle.companyVehicle.Phone = '9875744874';        
        wizard_Vehicle.saveVehicle();
        system.assertEquals(getVehicle(wizard_Vehicle.companyVehicle.Name).get(0).phone, '9875744874');
        
        
        //verify with existing vehicle
        //Done for Story # 105960 start (5/23/2013) Hemant
        //wizard_Vehicle.vehicleLookup.AccountId = vehicle.Id;
        wizard_Vehicle.vehicleLookup.Vehicle_Account__c = vehicle.Id;
        //Done for Story # 105960 end
        wizard_Vehicle.setVehicleField();
        system.assertEquals( wizard_Vehicle.companyVehicle.Name , 'V-1');
        
        ApexPages.currentPage().getParameters().put('Id', vehicle.Id);
        Wizard_VehicleController wizard_VehicleObj = new Wizard_VehicleController();
    }
    
    private static List<Account> getVehicle(String name) {
        return [select Id,Name,Phone from Account where Name =: name];
    }
}