function checkAllpbReg(inputField, objArr) {
		        	//alert('checkAllpbReg');
		            var ArrSize = objArr.length;            
		            if (ArrSize > 0) {
		                for(var j = 0; j < ArrSize; j++) {
		                    if(document.getElementById(objArr[j]) != null) {                       
		                        if(inputField.checked) {
		                            document.getElementById(objArr[j]).checked = true;                          
		                        } else {
		                            document.getElementById(objArr[j]).checked = false;
		                        }
		                    }
		                }
		                enableDatePickersForAll(objArr);
		            }       
		        }  
		        
		        var mainPrevCheckedArraypbReg = new Array();
		        var mainTxtShowDateTimeArray = new Array();
		        var mainCmbHourArray = new Array();
   		        var mainCmbMinArray = new Array();
   		        var mainCmbMeridiemArray = new Array();
   		        var mainCmbEndHourArray = new Array();
   		        var mainCmbEndMinArray = new Array();
   		        var mainCmbEndMeridiemArray = new Array();
		        var globalRecIdspbReg = '';                 
		        
		        function fillPrevCheckedArraypbReg(btnClicked) {
		        	//alert('fillPrevCheckedArraypbReg');                               
		            var prevCheckedArray         = new Array();
		            var prevTxtShowDateTimeArray = new Array();
			        var prevCmbHourArray         = new Array();
   			        var prevCmbMinArray          = new Array();
   			        var prevCmbMeridiemArray     = new Array();
   			        var prevCmbEndHourArray      = new Array();
   			        var prevCmbEndMinArray       = new Array();
   			        var prevCmbEndMeridiemArray  = new Array();
   			        
		            var recIdarr = objRecIdspbProperties.split(",");
		            
		            if(objChkboxArrpbProperties.length > 0) {
		                for(var j = 0; j < objChkboxArrpbProperties.length; j++) {
		                     var isExist = false;
		                     if(document.getElementById(objChkboxArrpbProperties[j]) != null && document.getElementById(objChkboxArrpbProperties[j]).checked == true) {    
		                        for(var k = 0; k < prevCheckedArray.length; k++) {                           
		                            if(objChkboxArrpbProperties[j] == prevCheckedArray[k]) {
		                                isExist = true;
		                            }                            
		                        }
		                        if(!isExist) {                           
		                            prevCheckedArray.push(objChkboxArrpbProperties[j]);
		                            prevTxtShowDateTimeArray.push(objtxtShowDateTimeArr[j] + '~' + document.getElementById(objtxtShowDateTimeArr[j]).value);
		                            prevCmbHourArray.push(objcmbHourArr[j]                 + '~' + document.getElementById(objcmbHourArr[j]).value);
		                            prevCmbMinArray.push(objcmbMinArr[j]                   + '~' + document.getElementById(objcmbMinArr[j]).value);
		                            prevCmbMeridiemArray.push(objcmbMeridiemArr[j]         + '~' + document.getElementById(objcmbMeridiemArr[j]).value);		                            		                            		                            
		                            prevCmbEndHourArray.push(objcmbEndHourArr[j]           + '~' + document.getElementById(objcmbEndHourArr[j]).value);
		                            prevCmbEndMinArray.push(objcmbEndMinArr[j]             + '~' + document.getElementById(objcmbEndMinArr[j]).value);
		                            prevCmbEndMeridiemArray.push(objcmbEndMeridiemArr[j]   + '~' + document.getElementById(objcmbEndMeridiemArr[j]).value);		                            		                            		                            
		                            
		                            if(globalRecIdspbReg.indexOf(recIdarr[j]) == -1) {
		                                globalRecIdspbReg += recIdarr[j] + ",";
		                            }
		                        }
		                     } else {                      
		                        var startIndex = globalRecIdspbReg.indexOf(recIdarr[j]); 
		                        if(startIndex >= 0) {
		                            globalRecIdspbReg = globalRecIdspbReg.replace(recIdarr[j],"");
		                            globalRecIdspbReg = globalRecIdspbReg.replace(",,",",");            
		                            if(globalRecIdspbReg.indexOf(',') == 0) {                           
		                                globalRecIdspbReg = globalRecIdspbReg.replace(",",""); 
		                            }
		                        }           
		                     }
		                }
		            }            
		            mainPrevCheckedArraypbReg[intGlobalProperties] = new Array();        
		            mainPrevCheckedArraypbReg[intGlobalProperties] = prevCheckedArray ;  
		            mainTxtShowDateTimeArray[intGlobalProperties]  = new Array();
		            mainTxtShowDateTimeArray[intGlobalProperties]  = prevTxtShowDateTimeArray;
		            mainCmbHourArray[intGlobalProperties]          = new Array();
		            mainCmbHourArray[intGlobalProperties]          = prevCmbHourArray;
		            mainCmbMinArray[intGlobalProperties]           = new Array();
		            mainCmbMinArray[intGlobalProperties]           = prevCmbMinArray;
		            mainCmbMeridiemArray[intGlobalProperties]      = new Array();
		            mainCmbMeridiemArray[intGlobalProperties]      = prevCmbMeridiemArray;
		            mainCmbEndHourArray[intGlobalProperties]       = new Array();
		            mainCmbEndHourArray[intGlobalProperties]       = prevCmbEndHourArray;
		            mainCmbEndMinArray[intGlobalProperties]        = new Array();
		            mainCmbEndMinArray[intGlobalProperties]        = prevCmbEndMinArray;
		            mainCmbEndMeridiemArray[intGlobalProperties]   = new Array();
		            mainCmbEndMeridiemArray[intGlobalProperties]   = prevCmbEndMeridiemArray;
		            
		            objChkboxArrpbProperties = new Array();
		            objtxtShowDateTimeArr    = new Array();
		            objcmbHourArr            = new Array();
		            objcmbMinArr             = new Array();
		            objcmbMeridiemArr        = new Array();
		            objcmbEndHourArr         = new Array();
		            objcmbEndMinArr          = new Array();
		            objcmbEndMeridiemArr     = new Array();
		            
		            objHidRecId.value = globalRecIdspbReg;
		            objRecIdspbProperties = '';            
		            if(btnClicked == 'prev') {   
		                intGlobalProperties--;
		                previousCallForReg();
		                return false;
		            } else {
		                intGlobalProperties++;
		                nextCallForReg();
		                return false;
		            }                       
		        }       
		        function setCheckedBoxespbReg() {
		        	//alert('setCheckedBoxespbReg');
		            var count=0;
		            while(mainPrevCheckedArraypbReg.length > 0 && count <= mainPrevCheckedArraypbReg.length && count > intGlobalProperties) {
		                for(var k = 0; k < mainPrevCheckedArraypbReg[count].length; k++) {
		                    document.getElementById(mainPrevCheckedArraypbReg[count][k]).checked = false;                                               
		                }                
		                count++;
		            }           
		            if(mainPrevCheckedArraypbReg.length > 0 &&  mainPrevCheckedArraypbReg[intGlobalProperties] != null && mainPrevCheckedArraypbReg[intGlobalProperties].length > 0) {
		                for(var k = 0; k < mainPrevCheckedArraypbReg[intGlobalProperties].length; k++) {
		                    document.getElementById(mainPrevCheckedArraypbReg[intGlobalProperties][k]).checked = true;
		                    enableDatePickers(mainPrevCheckedArraypbReg[intGlobalProperties][k]);
		                    
			                var txtShowDateTime = mainTxtShowDateTimeArray[intGlobalProperties][k].split("~");
			                var cmbHour         = mainCmbHourArray[intGlobalProperties][k].split("~");
			                var cmbMin          = mainCmbMinArray[intGlobalProperties][k].split("~");
			                var cmbMeridiem     = mainCmbMeridiemArray[intGlobalProperties][k].split("~");
			                var cmbEndHour      = mainCmbHourArray[intGlobalProperties][k].split("~");
			                var cmbEndMin       = mainCmbMinArray[intGlobalProperties][k].split("~");
			                var cmbEndMeridiem  = mainCmbMeridiemArray[intGlobalProperties][k].split("~");
			                			                
			                document.getElementById(txtShowDateTime[0]).value = txtShowDateTime[1];
			                document.getElementById(cmbHour[0]).value         = cmbHour[1];
			                document.getElementById(cmbMin[0]).value          = cmbMin[1];
			                document.getElementById(cmbMeridiem[0]).value     = cmbMeridiem[1];			        
			                document.getElementById(cmbHour[0]).value         = cmbEndHour[1];
			                document.getElementById(cmbMin[0]).value          = cmbEndMin[1];
			                document.getElementById(cmbMeridiem[0]).value     = cmbEndMeridiem[1];        			                
		                }
		            }                       
		        }       
		        function enableDatePickers(objChkBox) {
		        	//alert('enableDatePickers');            	
	            	if(document.getElementById(objChkBox).checked) {
	                	var chkId = objChkBox.split(":");
		            	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':txtShowDateTime').disabled = false;
		            	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbHour').disabled = false;
		            	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbMin').disabled = false;
		            	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbMeridiem').disabled = false;
		            	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbEndHour').disabled = false;
		            	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbEndMin').disabled = false;
		            	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbEndMeridiem').disabled = false;
		        	} else {
	                	var chkId = objChkBox.split(":");
		            	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':txtShowDateTime').disabled = true;
		               	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbHour').disabled = true;
          				document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbMin').disabled = true;		            	          	          
			          	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbMeridiem').disabled = true;
			          	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbEndHour').disabled = true;
		            	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbEndMin').disabled = true;
		            	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbEndMeridiem').disabled = true;
		        	}
	            }
	            function enableDatePickersForAll(objAllChkBox) {
	            	//alert('enableDatePickersForAll');             	
					for(var i=0; i < objAllChkBox.length;i++) {
		            	if(document.getElementById(objAllChkBox[i]).checked) {
		                	var chkId = objAllChkBox[i].split(":");
			            	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':txtShowDateTime').disabled = false;
			            	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbHour').disabled = false;
			            	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbMin').disabled = false;
			            	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbMeridiem').disabled = false;
			        		document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbEndHour').disabled = false;
			            	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbEndMin').disabled = false;
			            	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbEndMeridiem').disabled = false;
			        	} else {
		                	var chkId = objAllChkBox[i].split(":");
			            	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':txtShowDateTime').disabled = true;
			               	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbHour').disabled = true;
	          				document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbMin').disabled = true;		            	          	          
				          	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbMeridiem').disabled = true;
				          	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbEndHour').disabled = true;
	          				document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbEndMin').disabled = true;		            	          	          
				          	document.getElementById(chkId[0]+ ':' + chkId[1]+ ':' + chkId[2]+ ':' + chkId[3]+ ':' + chkId[4] + ':cmbEndMeridiem').disabled = true;
			        	}
			        }
	            }	