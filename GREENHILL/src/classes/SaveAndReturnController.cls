public class SaveAndReturnController{

    public Task t {get;set;}

    public SaveAndReturnController(ApexPages.StandardController ctrl){
        t = (Task)ctrl.getRecord();
    }

    public PageReference save(){
        upsert t;
        return new PageReference('/' + t.WhatId);
    }
}