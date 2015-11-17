/** 
* \author Vlad Gumenyuk 
* \date 02/06/2013
* \see https://silverline.jira.com/browse/LIB-20
* \    https://silverline.jira.com/browse/LIB-53
* \    https://silverline.jira.com/browse/WP-64
* \ Multi select component
* \  Description: This component allows user to make multi select from the incoming list. New list with selected items will be return. Also this component has to provide the possibility to order items.
*/
public without sharing class SL_ctrl_LIB20_Multiselect {

      public SelectOption[] input_list {get;set;}
      public SelectOption[] output_list {get;set;}

      public String sHiddenKeys {get;set {BaseParam.sHiddenKeys = value; sHiddenKeys = value; }}
      
      public SL_ctrl_LIB20_BaseParam BaseParam {get; set;}
      
      public String[] In_items {get;set;}
      
      public str_key_value[] Out_items = new str_key_value[]{};

      public class str_key_value {
      	String str_key = '';
         String str_value = '';
         
         public str_key_value(String key1, String value1) {
         	 str_key = key1;
         	 str_value = value1;
         } 
         
         public String getStr_key(){ return str_key; }
         public String getStr_value(){ return str_value; }
      }
      
      public SL_ctrl_LIB20_Multiselect() {
         In_items = new String[]{};
      	
      	input_list = new List<SelectOption>();
         output_list = new List<SelectOption>();

      	Out_items = new str_key_value[]{};
      	Out_items.add(new str_key_value('0','--None--'));
      }
      
      public list<str_key_value> getOutItems() {
      	Out_items = new list<str_key_value>();
      	Out_items.add(new str_key_value('0','--None--'));
         if(output_list.size() > 0) {
           Out_items = new list<str_key_value>();
           for ( SelectOption so : output_list ) 
               Out_items.add(new str_key_value(so.getValue(),so.getLabel()));
         }
         
      	return Out_items;
      }
    
      public List<SelectOption> getItems() {
         List<SelectOption> options = new List<SelectOption>();

         if(input_list.size() > 0)
            return input_list;

         if(options.size()==0)   
            options.add(new SelectOption('0','--None--'));
            
         return options;
      }

}