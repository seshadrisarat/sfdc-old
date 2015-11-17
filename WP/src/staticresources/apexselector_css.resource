/* 
    Document   : apexselector
    Created on : 16 oct 2012, 17:28:28
    Author     : den
    Description:
        Purpose of the stylesheet follows.
*/

.apex_filter_base
{
	position: relative;
	margin-left:-10px;
}


.apex_filter { 
    background-color: #fff;
    padding:3px;
    z-index:99;
    box-shadow: 0 0 3px 0 #ddd;
}

.apex_filter .title{
/*
    height:20px;
    text-align: left;
    float: right;
*/
    background-color:#eee;
    text-align: right;
    padding-left: 5px;
} 

.apex_filter .title span{
    border-radius: 2px;
    cursor:pointer;
    border:1px solid #ddd;
    background-color: #fff;
    margin:2px;
    display:inline-block;
    padding:2px 5px 0px 5px;
}

.apex_filter .list{
    max-height: 150px;
    overflow-y: auto;
    overflow-x: hidden;
    padding-right:16px;
}


.apex_filter .list div{
    margin:2px;
    padding:2px;
    text-decoration: none;
    text-align: left;
    cursor: pointer;
    font-size: 80%;
    width:100%;
}

.apex_filter .list div:hover, .apex_filter .list div.sel{
    background-color: #eee;
    
}


.added_list div {
    font-size: 12px;
/*    
    cursor: pointer;
*/    
    float:left;
    display:inline;   
    margin-right:20px;
}

.input_list div{
    font-size: 12px;
/*    
    cursor: pointer;
*/    
    /*float:left;*/
    display: block;   
}

/*
.title div {
    position: relative; top: 20px
}
*/
   /* width: 300px !important; */

#input_id input, .apex_filter_base {
    width: 300px !important;
    display: block;
    clear: both;
}

.apex_filter_base .title span {
/*    
    float: right;
    display:inline;
*/    
    display: inline-block;
}

.list_item_added {
    border:1px solid #ccc;
    background-color: #eee;
    margin-bottom:4px;
}

.removeIcon1 {
    background-image: url("/img/func_icons/remove12.gif");
    background-position: right top;
    display:inline;
    float: right;
    height: 12px;
    width: 12px;
    margin-right:0px;
    cursor: pointer;
}