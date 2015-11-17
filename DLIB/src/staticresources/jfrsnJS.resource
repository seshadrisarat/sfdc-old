   var isExecuting = false;
    window.onbeforeunload = confirmExit;
    function confirmExit() {

        if(isExecuting) {
          return "Your processes are still executing on this page. All your running processes will be canceled if you move away. Are you sure you want to cancel the current processes?";  
        }
    }

    var isViewChanged = false;
    var isOnload = true;

    var app = angular.module('myApp', ['ngGrid', 'ngForce', 'mgcrea.ngStrap', 'ngAnimate', 'ngSanitize']);        
          
    app.directive('onlyNum', function() {
        return{
            priority:1001,
            restrict:'A',
            scope:{},
            replace:true,

            link:function(scope, element, attrs) {

                var keyCode = [8,9,37,39,48,49,50,51,52,53,54,55,56,57,96,97,98,99,100,101,102,103,104,105,110];
                element.bind("keydown", function(event) {
                    console.log($.inArray(event.which,keyCode));
                    if($.inArray(event.which,keyCode) == -1) {
                        scope.$apply(function(){
                            scope.$eval(attrs.onlyNum);
                            // event.preventDefault();
                        });
                        event.preventDefault();
                    }

                });
            }
        }
    });

    /*app.directive('totalPercent',function(){
        return{
            restrict:'E',
            template:'<div class="row" style="padding-bottom:15px;">'+
                    '<div class="col-md-3">'+
                        '<div class="input-group">'+
                            '<span class="input-group-addon">EM Total Percent</span>'+
                            '<input class="form-control" type="number" ng-model="oppty.EM_Total_Percentage__c" ng-change="updateOppty(\'EM_Total_Percentage__c\',oppty.EM_Total_Percentage__c)" only-num ng-model-onblur/>'+
                        '</div>'+
                    '</div>'+
                    '<div class="col-md-3">'+
                        '<div class="input-group">'+
                            '<span class="input-group-addon">Dev Mgmt Total Percent</span>'+
                            '<input class="form-control" type="number" ng-model="oppty.DevMgmt_Total_Percentage__c" ng-change="updateOppty(\'DevMgmt_Total_Percentage__c\',oppty.DevMgmt_Total_Percentage__c)" only-num ng-model-onblur/>'+
                        '</div>'+
                    '</div>'+
                '</div>'
        }
    });*/

    app.filter('noFractionCurrency',
  [ '$filter', '$locale',
  function(filter, locale) {
    var currencyFilter = filter('currency');
    var formats = locale.NUMBER_FORMATS;
    return function(amount, currencySymbol) {
      var value = currencyFilter(amount, currencySymbol);
      var sep = value.indexOf(formats.DECIMAL_SEP);
      if(amount >= 0) { 
        return value.substring(0, sep);
      }
      return value.substring(0, sep) + ')';
    };
  } ]);

    app.directive('ngModelOnblur', function() {
        return {
            priority: 1000,
            restrict: 'A',
            require: 'ngModel',
            link: function(scope, elm, attr, ngModelCtrl) {
                
                if (attr.type === 'radio' || attr.type === 'checkbox') return;
                elm.unbind('input').unbind('keydown').unbind('change');
                elm.bind('blur', function() {
                    scope.$apply(function() {
                        ngModelCtrl.$setViewValue(elm.val());

                    });         
                });
            }
        };
    });

    app.config(function($asideProvider) {
      angular.extend($asideProvider.defaults, {
        container: 'body',
        html: true
      });
    })

    app.controller('MyCtrl', function($scope, vfr, $sce, $timeout, $window, $filter) {
    $scope.viewMode = 'requirement';

    $scope.requirement = { Array1 : [], Array2 : []};

    $scope.phase = { Array1 : [], Array2 : []};

    /*$scope.EmAlloc = 100;
    $scope.TaAlloc = 100;
    $scope.SaAlloc = 100;
    $scope.PartnerAlloc = 100;
    $scope.DevAlloc = 100;
    $scope.BaAlloc = 100;
    $scope.SmeAlloc = 100;
    $scope.DisAlloc = 100;
    $scope.DmsAlloc = 100;
    $scope.OffshoreAlloc = 100;
    $scope.PmAlloc = 100;
    $scope.DevMgmtAlloc = 100;*/
    $scope.newFeature = {
        Include_In_Tally__c: true
    }
    $scope.newOpptyComponent = {
        Opportunity__c: sf.oppty,
        Include_In_Tally__c: true,
        Description__c: ''
    }

    $scope.saySomething = function(){
        var saying = $scope.randFromInterval(0,9);
        switch (saying) {
            case 0:
                meSpeak.speak('I am Jefferson. I come from the future to help you close that shit.');
                break;
            case 1:
                meSpeak.speak('Sell. That. Shit.');
                break;
            case 2:
                meSpeak.speak('Feed me requirements daytuh.');
                break;
            case 3:
                meSpeak.speak('Beep.')
                break;
            case 4:
                meSpeak.speak('Beep. Boop.')
                break;
            case 5:
                meSpeak.speak('Boop.')
                break;
            case 6:
                meSpeak.speak('Fill that, Pipe!');
                break;
            case 7:
                $scope.greetUser();
                break;
            default:
                meSpeak.speak('Jefferson, at your service.');
                break;
        }

    }

    $scope.greetUser = function() {
        var d = new Date()
        var time = d.getHours()
        var greettime ='';
        if (time<10) {
            greettime = 'Good morning. ';
        } else if (time>10 && time<16) {
            greettime = 'Good after noon. ';
        } else {
            greettime = 'Good evening.';
        }

        var username = sf.username;
        meSpeak.speak(greettime + ' ' + username + '.');
    }


    $scope.randFromInterval = function(min,max)
    {
        return Math.floor(Math.random()*(max-min+1)+min);
    }

    $scope.milestoneTemplates = [];
    $scope.dirtyCells = [];
    $scope.opptyComponents = [];
    $scope.products = [];
    $scope.opptyFeatures = [];
    $scope.SowGroups = [
    ];
    $scope.checkedSowGroups = [];
    $scope.oppty = {};
    $scope.btnCheckAll_Visible='true';

    $scope.updatedComponent = {
        Name: ''
    };

    $scope.initializeVariables = function () {
        
         $timeout(function () {
            angular.element($window).resize();
            }, 0);

        $scope.checkedSowGroups = [];
        $scope.newOpptyComponent.Description__c = "";

        $scope.newFeature.Description__c = "";
        $scope.newFeature.Opportunity_Component__c = "";
        $scope.newFeature.Sow_Group__c = "";
        $scope.newFeature.Product__c = "";

        $scope.EmAlloc      = $scope.oppty.EM_allocations__c;
        $scope.TaAlloc      = $scope.oppty.TA_allocations__c;
        $scope.PcAlloc      = $scope.oppty.PC_allocations__c;
        $scope.SaAlloc      = $scope.oppty.SA_allocations__c;
        $scope.DevAlloc     = $scope.oppty.Dev_allocations__c;
        $scope.BaAlloc      = $scope.oppty.BA_allocations__c;
        $scope.SmeAlloc     = $scope.oppty.SME_allocations__c;
        $scope.DisAlloc     = $scope.oppty.DIS_allocations__c;
        $scope.DmsAlloc     = $scope.oppty.DMS_allocations__c;
        //$scope.PmAlloc      = $scope.oppty.PM_allocations__c;
        $scope.DevMgmtAlloc = $scope.oppty.DevMgmt_allocations__c;
        $scope.smAlloc      = $scope.oppty.SM_Allocations__c;
    }

    $scope.isEditable = true;
  
    if(sf.stageName == 'Closed Won' || sf.stageName == 'Closed Lost') {

        $scope.isEditable = false;
    }

    $scope.gridOptions = {
  
        init: function() {

            meSpeak.loadConfig(sf.mespeakConfig);
            meSpeak.loadVoice(sf.mespeakVoice);
            var shit = $window.innerHeight;
            $('.gridStyle').height(shit - 50);

            var getOppty = vfr.query("Select id, name, EM__c, TA__c,PC__c, Dev__c, Offshore_Dev__c, SA__c, Partner__c, SME__c, SM__c, DMS__c, DIS__c, BA__c, StageName, DevMgmt__c, DevMgmt_Total_Percentage__c, EM_Total_Percentage__c,EM_allocations__c,PC_Allocations__c, TA_allocations__c,SA_allocations__c,Dev_allocations__c,BA_allocations__c,SME_allocations__c,DIS_allocations__c,DMS_allocations__c,PM_allocations__c,SM_Allocations__c, DevMgmt_allocations__c from Opportunity where id = '" + sf.oppty + "'" ).then(function(result){
                $scope.oppty = result.records[0];
            });
            
            var opptyComponents = vfr.query("Select id, name, description__c, Include_In_tally__c, JFRSNsort__c from Opportunity_Component__c where Opportunity__c = '" +sf.oppty + "'")
            .then(function(result){
                $scope.opptyComponents = result.records;
                //console.log($scope.opptyComponents);
            });

            var prods = vfr.query("Select id, name from Product2 where IsActive = true AND pse__IsServicesProduct__c = true")
            .then(function(result){
                $scope.products = result.records;
            });

            var opptyFeatures = vfr.query("Select id, CreatedDate, name, description__c, product__c, Opportunity_Component__c, Opportunity_Component__r.Description__c, Sow_Group__c, BA__c, SME__c, DMS__c, DIS__c, EM__c, SA__c, SM__c, TA__c, Dev__c, PC__c, Partner__c, Offshore_Dev__c, Include_In_tally__c, DevMgmt__c, SowSortOrder__c, ParentCompJFRSNSort__c, JFRSNsortKey__c from Opportunity_Component_Feature__c where Opportunity__c = '" + sf.oppty + "' order by Opportunity_Component__r.Description__c")
            .then(function(result){
                $scope.opptyFeatures = result.records;
                // console.log($scope.opptyFeatures);
            },function(error){
                    //$('#blurScreen').hide();
                    isExecuting = false;
                    alert('Error: '+error);
                    console.log(error);
                });

            var milestoneTemplates = vfr.query("Select id, Phase__c, Product__c, Product__r.Name from Milestone_Template__c where Status__c = 'Active' and product__c != NULL").then(function(result){
                $scope.milestoneTemplates = result.records;
                //console.log($scope.milestoneTemplates);
                for(var i = 0; i < $scope.milestoneTemplates.length; i++){
                    if($scope.SowGroups.indexOf($scope.milestoneTemplates[i].Phase__c) == -1){
                        $scope.SowGroups.push($scope.milestoneTemplates[i].Phase__c);
                    }
                }
            });

       

        },
        //plugins: [new ngGridFlexibleHeightPlugin({ minHeight: 400 })],
        //showGroupPanel: true,
        showColumnMenu: true,
        showFilter: true,
        enableCellEdit: true,
        enableCellSelection: false,
        enableRowSelection: false,
        enableColumnResize: true,
        //enableSorting: true,
        rowHeight: 50,
        enableCellEditOnFocus: $scope.isEditable,
        multiSelect: false,
        groups: ['Opportunity_Component__c', 'Sow_Group__c'],
        groupsCollapsedByDefault: false,
        data: 'opptyFeatures',
        forceSyncScrolling:false,
        sortInfo: { fields: ['CreatedDate'], directions: ['asc']},
        aggregateTemplate: '<div  ng-style="rowStyle(row)" class="ngAggregate"><div class="{{row.aggClass()}}"></div> <span class="ngAggregateText">{{getGroupHeader(row)}}<span ng-click="$event.stopPropagation()"><button type="button" ng-show="row.field != \'Sow_Group__c\' && oppty.StageName!= \'Closed Won\' && oppty.StageName != \'Closed Lost\'" class="btn btn-xs headerbutton" data-animation="am-fade-and-scale" data-template="' + sf.modalView + '"  data-placement="center" bs-modal="modal" ng-click="getComponentName(row)"><span class="glyphicon glyphicon-edit"></span></button><button type="button" ng-show="row.field == \'Sow_Group__c\' && viewMode == \'requirement\' && oppty.StageName!= \'Closed Won\' && oppty.StageName != \'Closed Lost\'" class="btn btn-xs headerbutton" data-animation="am-fade-and-scale" data-placement="center" ng-click="addNewOpptyFeature(row)"><span class="glyphicon glyphicon-plus"></span></button><button type="button" ng-show="row.field == \'Opportunity_Component__c\' && viewMode == \'phase\' && oppty.StageName!= \'Closed Won\' && oppty.StageName != \'Closed Lost\'" class="btn btn-xs headerbutton" data-animation="am-fade-and-scale" data-placement="center" ng-click="addNewOpptyFeature(row)"><span class="glyphicon glyphicon-plus"></span></button></span><button class="btn btn-xs btn-danger headerbutton" ng-click="deleteComponent(row.label)" ng-show="{{shouldShowDelButton(row)}}"><span class="glyphicon glyphicon-trash"></span></button> <span ng-show="{{shouldShowDelButton(row)}}"><button class="btn btn-xs headerbutton" ng-show="{{shouldShowTallyGrpHeader(row)}}"><span class="glyphicon glyphicon-ok" ng-click="toggleTallyForGroup(row)"></span></button><button class="btn btn-xs headerbutton" ng-show="!{{shouldShowTallyGrpHeader(row)}}"><span class="glyphicon glyphicon-ban-circle" " ng-click="toggleTallyForGroup(row)"></span></button></span></span></div>',
        columnDefs: [ 
                    {
                        field: 'Include_In_Tally__c',
                        displayName: 'Tally',
                        width: 30,
                        cellTemplate: '<span class="glyphicon glyphicon-ok" ng-show="COL_FIELD"></span><span class="glyphicon glyphicon-ban-circle" ng-show="!COL_FIELD"></span>',
                        editableCellTemplate: '<input type="checkbox" ng-model="COL_FIELD" ng-input="COL_FIELD" ng-change="updateEntity(col,row)"/>'
                    },                
                    {   
                        field: 'Opportunity_Component__c', 
                        displayName: 'Requirement', 
                        cellTemplate: '<span id="{{COL_FIELD}}">{{getComponentForId(COL_FIELD).Description__c}}</span>',
                        enableCellEdit: false,
                        visible: false
                        // ,sortFn: function(id1,id2) {

                        //     if($('#'+id1).html() == $('#'+id2).html()) return 0;
                        //     if($('#'+id1).html() < $('#'+id2).html()) return -1;
                        //     return 1; 
                        // }
                    },
                    {
                        field: 'Sow_Group__c', 
                        displayName: 'Phase', 
                        editableCellTemplate: '<select ng-change="updateEntity(col, row)" ng-cell-input ng-input="COL_FIELD" ng-model="COL_FIELD" ng-options="d for d in SowGroups"/>',
                        visible: false,
                        sortFn: function(id1, id2) {

                            var arr = ['Initiate','Discovery','Design','Build','Test','Train','Go Live','Post Go Live','General'];
                            var id1_Index = 0,id2_Index = 0;

                            for(var index=0;index<arr.length; index++) {

                                if(id1 == arr[index]) 
                                    id1_Index = index;
                                if(id2 == arr[index])
                                    id2_Index = index;
                            }
                            
                            if(id1_Index == id2_Index) return 0;
                            if(id1_Index < id2_Index) return -1;
                            return 1; 
                        }
                    },
        
                    {
                        field:'Description__c', 
                        displayName:'Description',
                        groupable: false,
                        cellTemplate: '<span ng-class="dirtyCells[row.entity.Id]">{{row.entity[col.field]}}  </span>',
                        editableCellTemplate: '<span><textarea ng-input="COL_FIELD" ng-model="COL_FIELD" ng-change="updateEntity(col, row)" cols="80" rows="2" ng-model-onblur></textarea></span>'
                    },
                    {
                        field:'Product__c', 
                        displayName: 'Product',
                        width: 150,
                        cellTemplate: '<span ng-class="dirtyCells[row.entity.Id]"> {{renderProductIdAsName(COL_FIELD)}}</span>',
                        editableCellTemplate: '<select ng-change="updateEntity(col, row)" ng-input="COL_FIELD" ng-model="COL_FIELD" data-placeholer="--Select One--" ng-options="p.Product__c as p.Product__r.Name for p in milestoneTemplates | filter: {Phase__c: row.entity.Sow_Group__c }"/> '
                    },
                    {
                        field: 'EM__c',
                        displayName: 'EM',
                        width: 65,
                        enableCellEdit: true,
                       // cellTemplate: '<div class="ngCellText calcCell" ng-class="col.colIndex()"  ng-show="!{{isInitiateRow(row)}}"><span ng-cell-text>{{row.getProperty(col.field)}}</span></div><div ng-show="{{isInitiateRow(row)}}"><input type="number" width="100%" min="0" ng-change="updateEntity(col,row)" ng-input="COL_FIELD" ng-model="COL_FIELD"/></div>'
                        editableCellTemplate:'<div class="ngCellText calcCell" ng-class="col.colIndex()"  ng-show="!{{isInitiateRow(row)}}"><span ng-cell-text>{{row.getProperty(col.field)}}</span></div><div ng-show="{{isInitiateRow(row)}}"><input type="number" width="100%" min="0" ng-change="updateEntity(col,row)" ng-input="COL_FIELD" ng-model="COL_FIELD"/></div>'
                    },
                    // {
                    //     field: 'DevMgmt__c',
                    //     displayName: 'Dev Mgmt',
                    //     width: 75,
                    //     enableCellEdit: false,
                    //     cellTemplate: '<div class="ngCellText calcCell" ng-class="col.colIndex()"><span ng-cell-text>{{row.getProperty(col.field)}}</span></div>',
                    //     editableCellTemplate: '<input type="number" min="0"  ng-change="updateEntity(col,row)" ng-input="COL_FIELD" ng-model="COL_FIELD"/>'
                    // },
                    {
                        field: 'SA__c',
                        displayName: 'SA',
                        width: 65,
                        editableCellTemplate: '<input type="number" min="0"  ng-change="updateEntity(col,row)" ng-input="COL_FIELD" ng-model="COL_FIELD" only-num ng-model-onblur/>'
                    },
                    {
                        field: 'PC__c',
                        displayName: 'PC',
                        width: 65,
                        editableCellTemplate: '<input type="number" min="0"  ng-change="updateEntity(col,row)" ng-input="COL_FIELD" ng-model="COL_FIELD" only-num ng-model-onblur/>'
                    },
                    {
                        field: 'TA__c',
                        displayName: 'TA',
                        width: 65,
                        editableCellTemplate: '<input type="number" min="0"  ng-change="updateEntity(col,row)" ng-input="COL_FIELD" ng-model="COL_FIELD" only-num ng-model-onblur/>'
                    },
                    {
                        field: 'SME__c',
                        displayName: 'SME',
                        width: 65,
                        editableCellTemplate: '<input type="number" min="0"  ng-change="updateEntity(col,row)" ng-input="COL_FIELD" ng-model="COL_FIELD" only-num ng-model-onblur/>'
                    },
                    {
                        field: 'BA__c',
                        displayName: 'BA',
                        width: 65,
                        editableCellTemplate: '<input type="number"  min="0" ng-change="updateEntity(col,row)" ng-input="COL_FIELD" ng-model="COL_FIELD" only-num ng-model-onblur/>'
                    },
                    {
                        field: 'DMS__c',
                        displayName: 'DMS',
                        width: 65,
                        editableCellTemplate: '<input type="number" min="0" ng-change="updateEntity(col,row)" ng-input="COL_FIELD" ng-model="COL_FIELD" only-num ng-model-onblur/>'
                    },
                    {
                        field: 'DIS__c',
                        displayName: 'DIS',
                        width: 65,
                        editableCellTemplate: '<input type="number" min="0"  ng-change="updateEntity(col,row)" ng-input="COL_FIELD" ng-model="COL_FIELD" only-num ng-model-onblur/>'
                    },
                    // {
                    //  field: 'Partner__c',
                    //  displayName: 'Partner',
                    //  width: 65,
                    //  editableCellTemplate: '<input type="number" ng-change="updateEntity(col,row)" ng-input="COL_FIELD" ng-model="COL_FIELD"/>'
                    // },
                    {
                        field: 'Dev__c',
                        displayName: 'Dev',
                        width: 65,
                        editableCellTemplate: '<input type="number"  min="0" ng-change="updateEntity(col,row)" ng-input="COL_FIELD" ng-model="COL_FIELD" only-num ng-model-onblur/>'
                    },
                    {
                        field: 'SM__c',
                        displayName: 'Support',
                        width: 75,
                        editableCellTemplate: '<input type="number"  min="0" ng-change="updateEntity(col,row)" ng-input="COL_FIELD" ng-model="COL_FIELD" only-num ng-model-onblur/>'
                    },
                    // {
                    //  field: 'Offshore_Dev__c',
                    //  displayName: 'Offshore Dev',
                    //  width: 75,
                    //  editableCellTemplate: '<input type="number" ng-change="updateEntity(col,row)" ng-input="COL_FIELD" ng-model="COL_FIELD"/>'

                    // },
                   {
                        field: 'Id',
                        //width: 30,
                        displayName: 'Actions',
                        cellTemplate: '<button class="btn btn-xs btn-danger" ng-click="deleteFeature(COL_FIELD)" ng-disabled="oppty.StageName == \'Closed Won\' || oppty.StageName == \'Closed Lost\'"><span class="glyphicon glyphicon-trash"></span></button></span>',
                        enableCellEdit: false,
                        width: 30
                    }
                    //, {
                    //     field: 'SowSortOrder__c',
                    //     editableCellTemplate: '<input type="number" min="0" ng-input="COL_FIELD" ng-model="COL_FIELD" only-num ng-model-onblur/>'
                    //     //width: 0
                    // },
                    ,{
                        field: 'ParentCompJFRSNSort__c',
                        displayName: 'compsort'
                                                                        ,sortable: true
                                                                        ,visible: true

                    }
                    ,{
                        field: 'JFRSNsortKey__c',
                        displayName: 'featsort'
                                                ,sortable: true

                                                ,editableCellTemplate: '<input type="number" min="0"  ng-change="updateEntity(col,row)" ng-input="COL_FIELD" ng-model="COL_FIELD" only-num ng-model-onblur/>'
                                                ,visible:true
                    }
                    ,{
                        field:'',
                        enableCellEdit: false,
                        width:50
                    }
            ]
        };

        $scope.addRequirement = {title: 'New Requirement', content: 'Hello Aside<br />This is a multiline message!'};
        $scope.addDetail = {title: 'New Requirement Detail', content: 'Hello Aside<br />This is a multiline message!'};
        $scope.allocations = {title: 'Allocations', content: 'Hello Aside<br />This is a multiline message!'};
        $scope.modal = {title: 'Edit Component', content: 'Hello Modal<br />This is a multiline message!'};

        $scope.getComponentName = function(row) {

            $scope.updatedComponent = {};

            if(row.field == 'Opportunity_Component__c') {
                
                $scope.updatedComponent.Name = $scope.getComponentForId(row.label).Description__c;
            } 

            /*else {
                $scope.updatedComponentName = row.label;
            }*/
            
        }
//view methods

    

    $scope.isInitiateRow = function(row) {
        console.log('SOW GRP:' +row.entity.Sow_Group__c);
        if(row.entity.Sow_Group__c == 'Initiate') {
            return true;
        } else {
            return false;
        }
    }

    $scope.calculateWeeksForPhase = function(phase){
        //get total weeks for roles for phase
        var emHours = 0;
        var taHours = 0;
        var saHours = 0;
        var partnerHours = 0;
        var devHours = 0;
        var offHours = 0;
        var totalHours = 0;
        var smeHours = 0;
        var disHours = 0;
        var pcHours = 0;
        var smHours = 0;
        var dmsHours =0;
        var baHours = 0;
        for(var i = 0; i < $scope.opptyFeatures.length; i++) {
            //so pretty but so ugly
            if($scope.opptyFeatures[i].Include_In_Tally__c && $scope.opptyFeatures[i].Sow_Group__c == phase){
                    emHours         += $scope.opptyFeatures[i].EM__c            ? $scope.opptyFeatures[i].EM__c             : 0;
                    taHours         += $scope.opptyFeatures[i].TA__c            ? $scope.opptyFeatures[i].TA__c             : 0;
                    pcHours         += $scope.opptyFeatures[i].PC__c            ? $scope.opptyFeatures[i].PC__c             : 0;
                    saHours         += $scope.opptyFeatures[i].SA__c            ? $scope.opptyFeatures[i].SA__c             : 0;
                    offHours        += $scope.opptyFeatures[i].Offshore_Dev__c  ? $scope.opptyFeatures[i].Offshore_Dev__c   : 0;
                    partnerHours    += $scope.opptyFeatures[i].Partner__c       ? $scope.opptyFeatures[i].Partner__c        : 0;
                    smeHours        += $scope.opptyFeatures[i].SME__c           ? $scope.opptyFeatures[i].SME__c            : 0;
                    disHours        += $scope.opptyFeatures[i].DIS__c           ? $scope.opptyFeatures[i].DIS__c            : 0;
                    dmsHours        += $scope.opptyFeatures[i].DMS__c           ? $scope.opptyFeatures[i].DMS__c            : 0;
                    baHours         += $scope.opptyFeatures[i].BA__c            ? $scope.opptyFeatures[i].BA__c             : 0; 
                    devHours        += $scope.opptyFeatures[i].Dev__c           ? $scope.opptyFeatures[i].Dev__c            : 0;
                    smHours         += $scope.opptyFeatures[i].SM__c            ? $scope.opptyFeatures[i].SM__c             : 0;

                    totalHours      += $scope.sumWithPotentialUndefinedElements([emHours, saHours, taHours, pcHours, partnerHours, devHours, offHours, baHours, smeHours, disHours, dmsHours, smHours]);
            }
        }

        var weekTallies = [(emHours / (40 * ($scope.oppty.EM_allocations__c / 100))), 
                           (saHours / (40 * ($scope.oppty.SA_allocations__c / 100))),
                           (smHours / (40 * ($scope.oppty.SM_allocations__c / 100))), 
                           (taHours / (40 * ($scope.oppty.TA_allocations__c / 100))), 
                                  (pcHours / (40 * ($scope.oppty.PC_allocations__c / 100))), 
                           (devHours / (40 * ($scope.oppty.Dev_allocations__c / 100))),
                            (baHours / (40 * ($scope.oppty.BA_allocations__c / 100))),
                            (smeHours / (40 * ($scope.oppty.SME_allocations__c / 100))),
                            (disHours / (40 * ($scope.oppty.DIS_allocations__c / 100))),
                            (dmsHours / (40 * ($scope.oppty.DMS_allocations__c / 100)))];
        var weeks = Math.max.apply(Math, weekTallies);
        weeks = Math.ceil(weeks);
        return weeks;
    }

    //TODO: this seems to be running WAY too many times, wrtie out to var on change and refernce that in ui.

    $scope.totalWeeksForOppty = function() {

        var totalWeeks = 0;
        for(var i = 0; i < $scope.SowGroups.length; i++){
            totalWeeks += $scope.calculateWeeksForPhase($scope.SowGroups[i]);
        }

        $scope.oppty.weeks = totalWeeks;

        if(isNaN(totalWeeks)) {

            $scope.oppty.weeks = 0;
            return 0;
        }

        return totalWeeks;
    }

    $scope.totalOpptyValue = function() {
        var totalVal = 0;
        for(var i = 0; i < $scope.opptyFeatures.length; i++) {
            if($scope.opptyFeatures[i].Include_In_Tally__c){
                var emCost = $scope.opptyFeatures[i].EM__c * $scope.oppty.EM__c;
                var taCost = $scope.opptyFeatures[i].TA__c * $scope.oppty.TA__c;
                var pcCost = $scope.opptyFeatures[i].PC__c * $scope.oppty.PC__c;
                var saCost = $scope.opptyFeatures[i].SA__c * $scope.oppty.SA__c;
                var baCost = $scope.opptyFeatures[i].BA__c * $scope.oppty.BA__c;
                var smeCost = $scope.opptyFeatures[i].SME__c * $scope.oppty.SME__c;
                var dmsCost = $scope.opptyFeatures[i].DMS__c * $scope.oppty.DMS__c;
                var disCost = $scope.opptyFeatures[i].DIS__c * $scope.oppty.DIS__c;
                var devCost = $scope.opptyFeatures[i].Dev__c * $scope.oppty.Dev__c;
                var smCost = $scope.opptyFeatures[i].SM__c * $scope.oppty.SM__c;

                totalVal += $scope.sumWithPotentialUndefinedElements([emCost, saCost, taCost, pcCost, devCost, disCost, smeCost, dmsCost, baCost, smCost]);
            }
        }
        return totalVal;
    }

    $scope.shouldShowDelButton = function(row) {
        return row.field == 'Opportunity_Component__c' && $scope.viewMode == 'requirement';
    }

    $scope.shouldShowTallyGrpHeader = function(row) {
        if($scope.shouldShowDelButton(row)){
            if($scope.getComponentForId(row.label).Include_In_Tally__c){
                return true;//'glyphicon-ok';
            } else {
                return false;//'glyphicon-ban-circle';
            }
        } else {
            return false;
        }
    }

    $scope.toggleTallyForGroup = function(row) {
        if($scope.getComponentForId(row.label).Include_In_Tally__c){
            $scope.setToggleTallyForChildren(row.label, false);
            //$('#blurScreen').show();
            isExecuting = true;
            vfr.update('Opportunity_Component__c', row.label, {Include_In_Tally__c: false}).then(function(){
                    
                    //$('#blurScreen').hide();
                    isExecuting = false;
                },function(error){
                    //$('#blurScreen').hide();
                    isExecuting = false;
                    alert('Error: '+error);
                    console.log(error);
                });
            $scope.getComponentForId(row.label).Include_In_Tally__c = false;
        } else {
            $scope.setToggleTallyForChildren(row.label, true);
            //$('#blurScreen').show();
            isExecuting = true;
                vfr.update('Opportunity_Component__c', row.label, {Include_In_Tally__c: true}).then(function(){
                    //$('#blurScreen').hide();
                    isExecuting = false;
                },function(error){
                    //$('#blurScreen').hide();
                    isExecuting = false;
                    alert('Error: '+error);
                    console.log(error);
                });
            $scope.getComponentForId(row.label).Include_In_Tally__c = true;
        }
    }

    $scope.setToggleTallyForChildren = function(id,val) {
        for(var i = 0; i < $scope.opptyFeatures.length; i++) {
            if($scope.opptyFeatures[i].Opportunity_Component__c == id) {
                $scope.opptyFeatures[i].Include_In_Tally__c = val;
                //$('#blurScreen').show();
                isExecuting = true;

                vfr.update('Opportunity_Component_Feature__c', $scope.opptyFeatures[i].Id, {Include_In_Tally__c: val}).then(function(){

                    //$('#blurScreen').hide();
                    isExecuting = false;
                },function(error){
                    //$('#blurScreen').hide();
                    isExecuting = false;
                    alert('Error: '+error);
                    console.log(error);
                });
            }
        }
    }

    $scope.getHourAndCostSumForGrouping = function (row){
        //this is ugly
        var sums = {
            hours: 0,
            cost: 0
        };
        if(row.aggChildren.length > 0) {
            for(var i = 0; i < row.aggChildren.length; i++) {
                if(row.aggChildren[i].children.length > 0) {
                    for(var j = 0; j < row.aggChildren[i].children.length; j++){
                        sums.hours += $scope.getTotalHoursForRow(row.aggChildren[i].children[j]);
                        sums.cost += $scope.getTotalCostForRow(row.aggChildren[i].children[j]);
                    }
                }
            }
        } else if (row.children.length > 0) {
            for(var j = 0; j < row.children.length; j++){
                sums.hours += $scope.getTotalHoursForRow(row.children[j]);
                sums.cost += $scope.getTotalCostForRow(row.children[j]);
            }
        }
        return sums;
    }

    $scope.sumWithPotentialUndefinedElements = function(arr){
        var agg = 0;
        for(var i =0; i < arr.length; i++){
            if(arr[i]){
                agg = agg + arr[i];
            }
        }
        return agg;
    }

    $scope.getTotalHoursForRow = function(row) {
        if(row.entity.Include_In_Tally__c){
            return $scope.sumWithPotentialUndefinedElements([row.entity.EM__c 
                                                                , row.entity.BA__c 
                                                                , row.entity.SME__c 
                                                                , row.entity.DMS__c 
                                                                ,  row.entity.DIS__c 
                                                                , row.entity.TA__c 
                                                                , row.entity.PC__c
                                                                , row.entity.SA__c
                                                                , row.entity.Partner__c
                                                                , row.entity.Dev__c
                                                                , row.entity.DevMgmt__c
                                                                , row.entity.SM__c
                                                                , row.entity.Offshore_Dev__c]);
        } else {
            return 0;
        }

    }

    $scope.getTotalCostForRow = function(row) {
        if(row.entity.Include_In_Tally__c){
            var emCost = row.entity.EM__c * $scope.oppty.EM__c;
            var taCost = row.entity.TA__c * $scope.oppty.TA__c;
            var saCost = row.entity.SA__c * $scope.oppty.SA__c;
            var pcCost = row.entity.PC__c * $scope.oppty.PC__c;
            var baCost = row.entity.BA__c * $scope.oppty.BA__c;
            var smeCost = row.entity.SME__c * $scope.oppty.SME__c;
            var dmsCost = row.entity.DMS__c * $scope.oppty.DMS__c;
            var disCost = row.entity.DIS__c * $scope.oppty.DIS__c;
            var devMgmtCost = row.entity.DevMgmt__c * $scope.oppty.DevMgmt__c;
            var offCost = row.entity.Offshore_Dev__c * $scope.oppty.Offshore_Dev__c
            var partnerCost = row.entity.Partner__c * $scope.oppty.Partner__c;
            var devCost = row.entity.Dev__c * $scope.oppty.Dev__c;
            var smCost = row.entity.SM__c * $scope.oppty.SM__c;

            return $scope.sumWithPotentialUndefinedElements([emCost, smeCost, baCost, pcCost, smCost, dmsCost, disCost, saCost, taCost, partnerCost, devCost, offCost, devMgmtCost]);
        } else {
            return 0;
        }

    }

    $scope.getGroupHeader = function(row) {

        var text = '';
        if(row.field == 'Opportunity_Component__c'){
            var comp = $scope.getComponentForId(row.label);
            text = comp.Description__c;
        } else if( row.field == 'Product__c') {
            text = $scope.renderProductIdAsName(row.label);
        } else {
            text = row.label;
        }

        if(isViewChanged == false) {

            if($scope.viewMode == 'requirement') {

                //console.log('first');

                var sums = $scope.getHourAndCostSumForGrouping(row);
            
                if(row.field == 'Opportunity_Component__c' && row.label != undefined) {

                    if($scope.requirement.Array1.indexOf(row.label) > -1){
                        // in array
                    } else {

                        var phasesArr = [];
                        for(var index=0;index<row.aggChildren.length;index++) {
                            phasesArr.push({'label':row.aggChildren[index].label,'sum':{}});
                        }

                        var obj = { 'sum' : sums , 'phases' : phasesArr};
                        $scope.requirement.Array1.push(row.label);
                        $scope.requirement.Array2.push(obj);

                        //console.log($scope.requirement.Array1);
                        //console.log($scope.requirement.Array2);
                        
                    }
                } else if(row.field == 'Sow_Group__c' && row.label != undefined){

                    for(var index=0;index<$scope.requirement.Array2[$scope.requirement.Array1.indexOf(row.children[0].entity.Opportunity_Component__c)].phases.length;index++) {
                        
                        if(row.label == $scope.requirement.Array2[$scope.requirement.Array1.indexOf(row.children[0].entity.Opportunity_Component__c)].phases[index].label) {
                           $scope.requirement.Array2[$scope.requirement.Array1.indexOf(row.children[0].entity.Opportunity_Component__c)].phases[index].sum = sums; 
                        }
                    }
                    //console.log($scope.requirement);
                }

                text = text + ' - ' + sums.hours + ' Hours - ' + $filter('noFractionCurrency')(sums.cost) + '     ';
                return text;
            } 

            if( $scope.viewMode == 'phase') {

                console.log('== phase ==');
                var sums = $scope.getHourAndCostSumForGrouping(row);
                text = text + ' - ' + sums.hours + ' Hours - $' + $filter('noFractionCurrency')(sums.cost) + '     ';
                return text;
            }

        } else {

            if($scope.viewMode == 'requirement') {

                console.log('view changed');

                if(row.field == 'Opportunity_Component__c') {

                    var sums = $scope.requirement.Array2[$scope.requirement.Array1.indexOf(row.label)].sum;
                }

                if(row.field == 'Sow_Group__c') {

                    for(var index=0;index<$scope.requirement.Array2[$scope.requirement.Array1.indexOf(row.children[0].entity.Opportunity_Component__c)].phases.length;index++) {
                    
                        if(row.label == $scope.requirement.Array2[$scope.requirement.Array1.indexOf(row.children[0].entity.Opportunity_Component__c)].phases[index].label) {
                            
                            var sums = $scope.requirement.Array2[$scope.requirement.Array1.indexOf(row.children[0].entity.Opportunity_Component__c)].phases[index].sum;
                        }
                    }
                }

                text = text + ' - ' + sums.hours + ' Hours - $' + $filter('noFractionCurrency')(sums.cost) + '     ';
                return text;
                return text;
            }

            if($scope.viewMode == 'phase') {

                console.log('== phase in else ==');
                var sums = $scope.getHourAndCostSumForGrouping(row);
                text = text + ' - ' + sums.hours + ' Hours - $' + $filter('noFractionCurrency')(sums.cost) + '     ';
                return text;
                return text;
            }
        }

        /*var sums = $scope.getHourAndCostSumForGrouping(row);
        
        if(row.field == 'Opportunity_Component__c' && row.label != undefined) {

            if($scope.requirement.Array1.indexOf(row.label) > -1){
                // in array
            } else {

                var phasesArr = [];
                for(var index=0;index<row.aggChildren.length;index++) {
                    phasesArr.push({'label':row.aggChildren[index].label,'sum':{}});
                }

                var obj = { 'sum' : sums , 'phases' : phasesArr};
                $scope.requirement.Array1.push(row.label);
                $scope.requirement.Array2.push(obj);

                //console.log($scope.requirement.Array1);
                //console.log($scope.requirement.Array2);
                
            }
        } else if(row.field == 'Sow_Group__c' && row.label != undefined){

            for(var index=0;index<$scope.requirement.Array2[$scope.requirement.Array1.indexOf(row.children[0].entity.Opportunity_Component__c)].phases.length;index++) {
                
                if(row.label == $scope.requirement.Array2[$scope.requirement.Array1.indexOf(row.children[0].entity.Opportunity_Component__c)].phases[index].label) {
                   $scope.requirement.Array2[$scope.requirement.Array1.indexOf(row.children[0].entity.Opportunity_Component__c)].phases[index].sum = sums; 
                }
            }
            //console.log($scope.requirement);
        }

        text = text + ' - ' + sums.hours + ' Hours - $' + sums.cost;
        return text;*/
         
    }

    $scope.$watch('oppty.weeks', function() {
        console.log('Weeks updated: ' + $scope.oppty.weeks);
        if($scope.oppty.weeks != undefined){
            var fields = {
                Number_Of_Weeks__c: $scope.oppty.weeks
            };
            isExecuting = true;
            vfr.update('Opportunity', sf.oppty, fields ).then(function(result){
                        isExecuting = false;
                        //console.log('WATCH CALLBACK');
                    },function(error){
                        isExecuting = false;
                        alert('Error: '+error);
                        console.log(error);
                    });
        }
    });



    //watch for changes to allocation percentages.....
    //TODO: is there a better way to do this?

    $scope.$watch('viewMode', function() {
        
        if($scope.viewMode == 'flat') {
            $scope.gridOptions.groupBy('');
            $scope.setVisibiltyForColumns(['Opportunity_Component__c','Sow_Group__c', 'Description__c'], true);
        } else if ($scope.viewMode == 'requirement') {
            $scope.gridOptions.groupBy('');//hacky - need to clear col groupings because '.groupBy()' is a toggle
            $scope.gridOptions.groupBy('Opportunity_Component__c');
            $scope.gridOptions.groupBy('Sow_Group__c');
            $scope.setVisibiltyForColumns(['Opportunity_Component__c','Sow_Group__c'], false);
        } else if ($scope.viewMode == 'phase') {
            $scope.gridOptions.groupBy(''); //hacky - need to clear col groupings because '.groupBy()' is a toggle
            $scope.gridOptions.groupBy('Sow_Group__c');
            $scope.gridOptions.groupBy('Opportunity_Component__c');
            $scope.setVisibiltyForColumns(['Opportunity_Component__c','Sow_Group__c'], false);
            //$scope.gridOptions.sortBy('Phase');
        }
        
        if(isOnload == true) {

            isOnload = false;
        } else {
            
            isViewChanged = true;
        }
    });
    

    $scope.setVisibiltyForColumns = function(cols, visibility) {
        for(var i = 0; i < $scope.gridOptions.$gridScope.columns.length; i++){
            for(var j = 0; j < cols.length; j++) {
                var currColField = $scope.gridOptions.$gridScope.columns[i].field;
                if(currColField == cols[j]){
                    $scope.gridOptions.$gridScope.columns[i].visible = visibility;
                }
            }
        }
    }

    //this should prolly be done w/ map()
    $scope.getComponentForId = function(componentId) {
        for(var i = 0; i < $scope.opptyComponents.length; i++ ) {

            if($scope.opptyComponents[i].Id == componentId) {
                return $scope.opptyComponents[i];
            }
        }
    }

    $scope.renderProductIdAsName = function(productId) {
        if(productId == null) {
            return 'Select a Product';
        } else {
            for(var i = 0; i < $scope.products.length; i++ ) {
                if($scope.products[i].Id == productId) {
                    return $scope.products[i].Name;
                }
            }
        }
    }

//data methods

    $scope.editComponent = function(id,updatedName) {
        
        //$('#blurScreen').show();
        isExecuting = true;
        vfr.update('Opportunity_Component__c', id , {Description__c: updatedName}).then(function(result){

                    //$('#blurScreen').hide();   
                    isExecuting = false;
                    var index = getIndexOfObject($scope.opptyComponents,id,'Id');
                    if(index != -1) {
                        $scope.opptyComponents.splice(index ,1);
                    }
                    $scope.opptyComponents.push(result.record);
                    
                },function(error){
                    //$('#blurScreen').hide();
                    isExecuting = false;
                    alert('Error: '+error);
                    console.log(error);
                });
    }

    $scope.deleteComponent = function(id){
        var really = confirm('Are you sure you *really* want to delete this component?');
        if(really){
            //$('#blurScreen').show();
            isExecuting = true;
            vfr.del('Opportunity_Component__c', id).then(
            function(){
                //$('#blurScreen').hide();
                isExecuting = false;
                var index = getIndexOfObject($scope.opptyComponents,id, 'Id');
                if(index != -1){
                    $scope.opptyComponents.splice(index ,1);
                    //remove related features
                    for(var i = $scope.opptyFeatures.length - 1; i >= 0; i--) {
                        if($scope.opptyFeatures[i].Opportunity_Component__c == id) {
                            $scope.gridOptions.selectItem(index, false);
                            $scope.opptyFeatures.splice(i, 1);
                        }
                    }
                }
            },function(error){
                //$('#blurScreen').hide();
                isExecuting = false;
                alert('Error: '+error);
                console.log(error);
            });
        }
    }

    $scope.deleteFeature = function(id) {
        console.log(id);

        var really = confirm('Are you sure you *really* want to delete this feature?');
        if(really){
            //$('#blurScreen').show();
            isExecuting = true;
            vfr.del('Opportunity_Component_Feature__c', id).then(
            function(){
                //$('#blurScreen').hide();
                isExecuting = false;
                var index = getIndexOfObject($scope.opptyFeatures, id, 'Id');
                if(index != -1){
                    $scope.gridOptions.selectItem(index, false);
                    $scope.opptyFeatures.splice(index,1);
                }
            },function(error){
                //$('#blurScreen').hide();
                isExecuting = false;
                alert('Error: '+error);
                console.log(error);
            });
        }
    }

    $scope.updateEntity = function(col, row) {
     
        // console.log(col);
        // console.log(row);
        if(row.entity[col.field] != null) {

            var managedRoles = ['BA__c', 'SA__c', 'SME__c', 'DMS__c', 'DIS__c', 'TA__c', 'Dev__c', 'SM__c', 'PC__c', 'SM__c', 'EM__c'];
            $scope.dirtyCells[row.entity.Id] = 'dirty';
            var fields = {};
            fields[col.field] = row.entity[col.field];

            //set EM to 20% of total
            if(managedRoles.indexOf(col.field) != -1 && row.entity.Sow_Group__c != 'Initiate'){
                var rowTotalHours = 0;
                for(var i = 0; i < managedRoles.length; i++){
                    if(row.entity[managedRoles[i]]){
                        rowTotalHours += row.entity[managedRoles[i]];
                    }
                }
                var emTotal = Math.ceil(rowTotalHours * ($scope.oppty.EM_Total_Percentage__c/100));
                fields['EM__c'] = emTotal;
                row.entity['EM__c'] = emTotal;
            }

            // //set Dev Mgmt
            // if(col.field == 'Dev__c' ){
            //     var mgmt = Math.ceil(row.entity['Dev__c'] * ($scope.oppty.DevMgmt_Total_Percentage__c/100));
            //     fields['DevMgmt__c'] = mgmt;
            //     row.entity['DevMgmt__c'] = mgmt;
            // }

            //don't let text fields be totally blank (HACK)
            if(col.field == 'Description__c' && row.entity[col.field] == '') {
                row.entity[col.field] = 'none';
            }

            console.log(fields);
            //$('#blurScreen').show();
            isExecuting = true;
            vfr.update('Opportunity_Component_Feature__c', row.entity.Id, fields)
            .then(function(result){
                //$('#blurScreen').hide();
                isExecuting = false;
                $scope.dirtyCells[row.entity.Id] = '';
                //console.log('UPDATE CALLBACK');
            },function(error){
                //$('#blurScreen').hide();
                isExecuting = false;
                alert('Error: '+error);
                console.log(error);
            });
        }
    }

    $scope.updateOppty = function(field,percentage) {

        if(percentage != null) {

            var fields = {};
            fields[field] = percentage;
            //$('#blurScreen').show();
            isExecuting = true;
            vfr.update('Opportunity', sf.oppty, fields ).then(function(result){
                        
                        //console.log('UPDATE OPPTY CALLBACK');
                        var count = 0;                        
                        var featureFields = {};
                        for(var index=0; index< $scope.opptyFeatures.length;index++) {
                            
                            var managedRoles = ['BA__c', 'SA__c', 'SME__c', 'DMS__c', 'DIS__c', 'TA__c', 'Dev__c', 'SM__c', 'PC__c', 'SM__c'];
                            var rowTotalHours = 0;
                            
                            for(var i = 0; i < managedRoles.length; i++){
                                
                                if($scope.opptyFeatures[index][managedRoles[i]]){
                                    rowTotalHours += $scope.opptyFeatures[index][managedRoles[i]];
                                }
                            }
                            
                            var emTotal = Math.ceil(rowTotalHours * ($scope.oppty.EM_Total_Percentage__c/100));
                            featureFields['EM__c'] = emTotal;

                            if(!isNaN($scope.opptyFeatures[index].Dev__c)) {

                                featureFields['DevMgmt__c'] = Math.ceil($scope.opptyFeatures[index].Dev__c * ($scope.oppty.DevMgmt_Total_Percentage__c/100));
                            } else {
                                featureFields['DevMgmt__c'] = 0;
                            }
                            
                            vfr.update('Opportunity_Component_Feature__c', $scope.opptyFeatures[index].Id, featureFields)
                            .then(function(result){
                                
                                //console.log('UPDATE OPPTY FEATURE CALLBACK');
                                count++;
                                if(count == $scope.opptyFeatures.length) {

                                    //$('#blurScreen').hide();
                                    isExecuting = false;
                                    console.log('update done');

                                    vfr.query("Select id, name, description__c, product__c, Opportunity_Component__c, Sow_Group__c, BA__c, SME__c, DMS__c, DIS__c, EM__c, SA__c, TA__c, Dev__c, SM__c, PC__c, Partner__c, Offshore_Dev__c, Include_In_tally__c, DevMgmt__c, SowSortOrder__c, ParentCompJFRSNSort__c, JFRSNsortKey__c from Opportunity_Component_Feature__c where Opportunity__c = '" + sf.oppty +"'")
                                    .then(function(result){
                                        // we can manipulate the results of this first query, even assign scope variables with it
                                        $scope.opptyFeatures = result.records;
                                    });
                                }                               

                            },function(error){
                                //$('#blurScreen').hide();
                                isExecuting = false;
                                alert('Error: '+error);
                                console.log(error);
                            });
                        }
                        

                    },function(error){
                        alert('Error: '+error);
                        console.log(error);
                    });
        }  
    }

    $scope.updateAllocations=function(fieldname,allocationsValue){
        
        if($scope.oppty[fieldname] != null) {

            var fields = {};

            fields[fieldname] = $scope.oppty[fieldname];

            //$('#blurScreen').show();
            isExecuting = true;
            vfr.update('Opportunity', sf.oppty, fields)
            .then(function(result){
                //$('#blurScreen').hide();
                isExecuting = false;
                //console.log('UPDATE OPPTY ALLOCATION CALLBACK');

            },function(error){
                //$('#blurScreen').hide();
                isExecuting = false;
                alert('Error: '+error);
                console.log(error);
            });
        }
    }

    $scope.addFeature = function() {

        /*for(var key in $scope.checkedSowGroups) {

            if($scope.checkedSowGroups[key] == true) {

                var newOpptyFeature = JSON.parse(JSON.stringify($scope.newFeature));
                newOpptyFeature.Sow_Group__c = key;
                vfr.create('Opportunity_Component_Feature__c', newOpptyFeature)
                .then(function(result){
                    
                    //append new feature to the list
                    //newOpptyFeature.Id = result.id;
                    $scope.opptyFeatures.push(result.id);
                },
                function(error){
                   console.log(error);
                });
            }
        }

        $scope.newFeature.Description__c = '';
        $scope.newFeature.Product__c = '';
        $scope.checkedSowGroups = [];
        $scope.newFeature.Opportunity_Component__c = '';*/

        var newOpptyFeature = JSON.parse(JSON.stringify($scope.newFeature));
        $scope.newFeature.Description__c = '';
        $scope.newFeature.Product__c = '';
        $scope.newFeature.Sow_Group__c = '';
        $scope.newFeature.Opportunity_Component__c = '';
        $scope.newFeature.Include_In_Tally__c = true;
        $scope.newFeature.JFRSNsortKey__c = $scope.getNextSortKey(false);


        
        //$('#blurScreen').show();
        isExecuting = true;
        vfr.create('Opportunity_Component_Feature__c', newOpptyFeature)
        .then(function(result){

            //$('#blurScreen').hide();
            isExecuting = false;
            //append new feature to the list
            newOpptyFeature.Id = result.id;
            $scope.opptyFeatures.push(newOpptyFeature);
        },
        function(error){
            //$('#blurScreen').hide();
            isExecuting = false;
            alert('Error: '+error);
            console.log(error);
        });
        
    }


    $scope.windowHeight = 0;

    angular.element($window).bind('resize',function(){
      $scope.windowHeight = $window.innerHeight;
      $scope.$apply();

     });

    $scope.$watch('windowHeight', function () {
            console.log('RESIZED');
            $('.gridStyle').height( $window.innetHeight - 50);
    });

    $scope.checkAll = function() {

        $scope.btnUncheckAll_Visible='true';
        $scope.btnCheckAll_Visible='false';
        for(var key in $scope.SowGroups) {

            if(key != 'remove') {
                $scope.checkedSowGroups[$scope.SowGroups[key]] = true;
            }
        }
    };

    $scope.uncheckAll=function(){
      
        $scope.btnUncheckAll_Visible='false';
        $scope.btnCheckAll_Visible='true';
        $scope.checkedSowGroups=[]; 
    }

    $scope.addNewOpptyFeature = function(row) {
        
        var newBlankFeature = 
            {
                Description__c: 'New Feature'
            }

        if($scope.viewMode == 'requirement') {

            newBlankFeature.Opportunity_Component__c = row.children[0].entity.Opportunity_Component__c;
            newBlankFeature.Sow_Group__c = row.label;
            newBlankFeature.Include_In_Tally__c = true;
        }

        if($scope.viewMode == 'phase') {

            newBlankFeature.Opportunity_Component__c = row.label;
            newBlankFeature.Sow_Group__c = row.entity.children[0].entity.Sow_Group__c;
            newBlankFeature.Include_In_Tally__c = true;            
        }

        newBlankFeature.JFRSNsortKey__c = $scope.getNextSortKey(false);

        isExecuting = true;
        vfr.create('Opportunity_Component_Feature__c', newBlankFeature)
        .then(function(result){
            
            isExecuting = false;
            //append new feature to the list
            //newBlankFeature.Id = result.id;
            //result.record.ParentCompJFRSNSort__c = row.entity.Opportunity_Component__r.JFRSNsortKey__c;
            $scope.opptyFeatures.push(result.record);
        },
        function(error){

            isExecuting = false;
            alert('Error: '+error);
            console.log(error);
        });
    }

    $scope.maxOpptyCompSortValue = function(){
        var arr = $scope.opptyFeatures;
        var ceil;
        for(var i = 0; i < arr.length; i++){
                if(ceil != undefined){
                    if(ceil < arr[i].ParentCompJFRSNSort__c){
                        ceil = arr[i].ParentCompJFRSNSort__c;
                    }
                } else {
                    ceil = arr[i].ParentCompJFRSNSort__c;
                }
            }
        return ceil;
    }

    $scope.getNextSortKey = function(isNewComponent) {
		var arr = $filter('orderBy')($filter('filter')($scope.opptyFeatures, {JFRSNsortKey__c:'-'}), 'JFRSNsortKey__c', true) || [];  	
		var strArr;
		if(arr.length > 0)
		{
			strArr = arr[0].JFRSNsortKey__c === undefined ? [] : arr[0].JFRSNsortKey__c.split('-');
			if(strArr.length === 2) 
			{
				if(isNewComponent)
					return (parseInt(strArr[0]) + 1) + '-' + strArr[1];
				else
					return strArr[0] + '-' + (parseInt(strArr[1]) + 1);
			}
		}
		return '0-0';
    }
 
    $scope.maxOpptyFeatSortValue = function(ocid){
        var arr = $scope.opptyFeatures;
        var ceil;
        for(var i = 0; i < arr.length; i++){
            if(arr[i].Opportunity_Component__c == ocid){
                if(ceil != undefined){
                    if(ceil < arr[i].JFRSNsortKey__c){
                        ceil = arr[i].JFRSNsortKey__c;
                    }
                } else {
                    ceil = arr[i].JFRSNsortKey__c;
                }
            }
        }
        return ceil == undefined ? 0 : ceil;
    }

    $scope.addOpptyComponent = function(){
        var newOpptyComp = JSON.parse(JSON.stringify($scope.newOpptyComponent));

        $scope.newOpptyComponent.Description__c = '';
        // newOpptyComp.JFRSNsortKey__c = $scope.maxOpptyCompSortValue() == undefined ? 0 : $scope.maxOpptyCompSortValue() + 1;

        var newBlankFeature = 
            {
                Description__c: 'New Feature'
            }

        isExecuting = true;
        vfr.create('Opportunity_Component__c', newOpptyComp)
        .then(function(result){
            
            //append new record to list
            newOpptyComp.Id = result.id;
            $scope.opptyComponents.push(newOpptyComp);
            
            var arrLength = 0;
            var count = 0;

            //create new feature under this heading
            for(var key in $scope.checkedSowGroups) {
                
                if(typeof $scope.checkedSowGroups[key] == 'boolean' && $scope.checkedSowGroups[key] == true) {
                    
                    arrLength++;
                    newBlankFeature.Opportunity_Component__c = result.id;
                    newBlankFeature.Sow_Group__c = key;
                    newBlankFeature.Include_In_Tally__c = true;
                    newBlankFeature.JFRSNsortKey__c = $scope.getNextSortKey(true);
                    
                    vfr.create('Opportunity_Component_Feature__c', newBlankFeature)
                    .then(function(result){

                        count++;
                        if(arrLength == count) {
                            //$('#blurScreen').hide();
                            isExecuting = false;
                        }
                        //append new feature to the list
                        //newBlankFeature.Id = result.id;
                        $scope.opptyFeatures.push(result.record);
                    },
                    function(error){
                        count++;
                        if(arrLength == count) {
                            //$('#blurScreen').hide();
                            isExecuting = false;
                        }
                        alert('Error: '+error);
                        console.log(error);
                    });
                }
            }
            $scope.checkedSowGroups = [];
        },
        function(error){
            alert('Error: '+error);
            console.log(error);
        });
    }
});

//AY! THAR BE HACKS BEYOND THIS POINT

function getIndexOfObject(myArray, searchTerm, property) {
    for(var i = 0, len = myArray.length; i < len; i++) {
        if (myArray[i][property] == searchTerm) return i;
        }
        return -1;
    }