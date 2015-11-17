
@page:first
{
		page-break-before : auto !important;
		@top-center
	{
		content: "";
	}
		
}
@page
{
		page-break-before : always;


	size: landscape;
	@top-left
	{
		date: "m/d/Y";
		font-weight : bolder;
		border-bottom : 1px solid #000;
	}
	@top-center
	{
		content: "Action Plan Report";
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

table td
{
	text-align:left;
}

p {
		page-break-before : auto;
	}

div.pagebr	{
		page-break-before : always;
	}


