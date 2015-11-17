/**
 * author Vlad Gumenyuk 
 * date 02/18/2013
 * see https://silverline.jira.com/browse/LIB-20 , https://silverline.jira.com/browse/LIB-53
 * Test for class SL_ctrl_LIB20_Multiselect, SL_ctrl_LIB20_BaseParam
 */
@isTest
private class SL_test_LIB20_Multiselect {
   
   public static SL_ctrl_LIB20_BaseParam BaseParam;
   public static SL_ctrl_LIB20_Multiselect multisel;

@isTest(SeeAllData=true)
   static void test_LIB20_Multiselect() 
   {
      BaseParam = new SL_ctrl_LIB20_BaseParam(); 

      Test.startTest();
         multisel = new SL_ctrl_LIB20_Multiselect();

         multisel.getItems();

         List<Contact> contacts = [SELECT Name, Id FROM Contact LIMIT 500];
         Integer i = 0;    
         for ( Contact c : contacts ) {
            multisel.input_list.add(new SelectOption(c.Id, c.Name));
            if(i<5)
               multisel.output_list.add(new SelectOption(c.Id, c.Name));
            i++;
         }

         multisel.getOutItems();
         multisel.getItems();
         
         SL_ctrl_LIB20_Multiselect.str_key_value skv = new SL_ctrl_LIB20_Multiselect.str_key_value('1','text 1');
         skv.getStr_key();
         skv.getStr_value();
         
      Test.stopTest();
   }

}