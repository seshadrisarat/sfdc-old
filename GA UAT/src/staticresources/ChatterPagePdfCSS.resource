  .nameTd{
      color:#0099CC;
      font-weight:bold;
  }
  
  tr {
      vertical-align:top;
  }
  
  td {
      vertical-align:top;
  }
  
  .nameTdComment{
      color:#0099CC;
      font-size:12px;
      font-weight:bold;
  }
  
  .dateoncomment{
      font-size:10px;
      color:gray;
  }
  
  .dateTd{
      font-size:10px;
  }
  
  .commentTable{
      background:#F8F8F8; 
      width:100%;
      border-top:2px solid white;
      padding:3px;
      padding-bottom:5px;
  }
  
  .selectDate{
    background: transparent;
    padding: 5px;
    border: 1px solid #ccc;
    overflow: hidden;
    background-image:none;
  }
  
  
  .feedHr{
    color: #D1D1D1;
    background-color: #D1D1D1;
    height: 1px;
    border : 0;
  }
  
  .commentImage{
      width:35;
  }
  
  .feedImage{
      width:50;
  }
  
@page { 
               
    @top-center {                   
        content: element(header);               
    }
    
    @bottom-left {
        content: element(footer);
    } 
    margin:6em 3em 6em;         
}                       

div.header {                
    padding: 10px;              
    position: running(header);           
}           
div.footer {                
    display: block;             
    padding: 10px;               
    position: running(footer);          
}                       

.pagenumber:before {                
    content: counter(page);             
}                       
.pagecount:before {             
    content: counter(pages);            
}