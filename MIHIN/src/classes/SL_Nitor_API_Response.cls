/*
*Class: SL_Nitor_API_Response
*Description: This class is used to form the response in the form of wrapper class as per the parameters passed from external system using REST API
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
global class SL_Nitor_API_Response{
    public integer totalSize;
    public boolean done;
    public List<sObject> records;
    
    public SL_Nitor_API_Response(List<sObject> sobjects, Boolean isDone){
        records = sobjects;
        totalSize = records.size();
        done = isDone;
    
    }
    

}