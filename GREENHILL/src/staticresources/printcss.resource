@page:first
{
	size: landscape;
	@top-center {content: ""}
	@top-right { content: ""}
}

@page
{
	size: landscape;
	font-family:Arial,Helvetica,sans-serif;
	@top-left
	{
		date: "m/d/Y";
		font-weight : bolder;
		border-bottom : 1px solid #000;
	}
	@top-center
	{
		content: "Phonebook Report";
		font-weight : bolder;
		border-bottom : 1px solid #000;
	}
	@top-left
	{
		content: "" date(dd-MMM-yyyy, UTC);
	}
	@bottom-right
	{
		content: "Page " counter(page);
		font-weight : bolder;
		border-bottom : 1px solid #000;
	}
}

table th
{
	text-align:center;
	background-color : #386E78;
	padding: 0px 1px 0px 1px;
	margin: 4px 4px 4px 4px;
	color : White;
}



