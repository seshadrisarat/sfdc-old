/**
* @ClassName          : SL_SeeAllTasksController
* @JIRATicket         : GA-17
* @CreatedOn          : 10/APR/2015
* @LastModifiedOn     : -
* @CreatedBy          : Pankaj Ganwani
* @ModifiedBy         : -
* @Description        : This class is used to fetch the task records corresponding to the current job order record.
*/
public with sharing class SL_SeeAllTasksController 
{
	/* Start - Page Variables */
	public List<Task> lstTask	{get; private set;}// list to hold task object records.
	public Boolean isRender		{get; private set;}// flag variable to determine whether the form should be displayed or not.
	/* End - Page Variables */
	
	/* Start - Class Variables */
	String jobOrderId;// job order record id
	static String strQuery = 'SELECT Id';// variable to hold dynamic soql
    static final String SOBJECT_NAME = 'Task';// sobject referred in describe call
    static final String FIELDSET_NAME = 'SeeAllTasks';// field set referred in describe call
	/* End - Class Variables */
	
	/* Start - static Block*/
	static
	{
		for(Schema.FieldSetMember objFieldSetMember : Schema.getGlobalDescribe().get(SOBJECT_NAME).getDescribe().FieldSets.getMap().get(FIELDSET_NAME).getFields())
		{
			if(objFieldSetMember.getFieldPath()!='Id')
				strQuery+= ', '+objFieldSetMember.getFieldPath();
		}
		strQuery+=' FROM Task';
	}
	/* End - static Block*/
	
	/* Start - Constructor */
	public SL_SeeAllTasksController()
	{
		initialize();
	}
	/* End - Constructor */
	
	/*
        * MethodName   : initialize
        * Param        : -
        * Description  : This method is used to initialize the page and class variables and fetching the records from Task object to display on vf page.
    */
	private void initialize()
	{
		lstTask = new List<Task>();
		isRender = true;
		Map<String,String> mapPageParameters = Apexpages.currentPage().getParameters();
		if(!mapPageParameters.containskey('jobOrderid') || String.isEmpty(mapPageParameters.get('jobOrderid')))
		{
			isRender = false;
			Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, Label.Insufficient_Parameters));
			return;
		}
		jobOrderId = mapPageParameters.get('jobOrderid');
		lstTask = Database.query(String.format('{0}{1}', new String[]{strQuery,' WHERE WhatId =:jobOrderId  LIMIT 100 ALL ROWS '}));
	}
	
	/*
        * MethodName   : cancel
        * Param        : -
        * Description  : This method is used to redirect the page to the detail page of Job order.
    */
	public Pagereference cancel()
	{
		return new Pagereference('/'+jobOrderId);
	}
}