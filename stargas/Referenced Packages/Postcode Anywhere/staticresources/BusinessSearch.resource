<!doctype html>
<html>
<head>
    <link class="user" href="/sCSS/22.0/sprites/1313619881000/Theme2/default/elements.css" rel="stylesheet" type="text/css" />
    <link class="user" href="/sCSS/22.0/sprites/1313619881000/Theme2/default/common.css" rel="stylesheet" type="text/css" />
    <link class="user" href="/sCSS/22.0/sprites/1316033569000/Theme2/dStandard.css" rel="stylesheet" type="text/css" />
    <link class="user" href="/sCSS/22.0/sprites/1316033569000/Theme2/00D300000006psV/00530000000vvzk/dCustom0.css" rel="stylesheet" type="text/css" />
    <link class="user" href="/sCSS/22.0/sprites/1313619881000/Theme2/default/setup.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <div style="height:53px;width:100%;background-image:url('/resource/pca__PostcodeAnywhereIcon/slice.png');background-repeat:repeat-x;">
        <img src="/resource/pca__PostcodeAnywhereIcon/powered-pca-logo.png" title="" alt="" style="margin:15px;position: absolute;right:0;" />
    </div>

    <table cellspacing="5px" style="margin: 20px;">
        <tr>
            <td><label for="pcaBusinessCountry" style="font-weight: bold;">Country</label></td>
            <td><input type="text" id="pcaBusinessCountryText" onkeydown="if((event && event.which && event.which==13) | event.keyCode==13 ) Search(); return true;" style="display:none" /><select id="pcaBusinessCountry" onchange="SetValue(_countryField, GetValue(this));if(GetValue(this)=='')UseFreeTextCountry()"></select></td>
        </tr>
        <tr>
            <td><label for="pcaBusinessSearch" style="font-weight: bold;">Search</label></td>
            <td><input id="pcaBusinessSearch" style="width: 250px;" type="text" onkeydown="if((event && event.which && event.which==13) | event.keyCode==13 ) Search(); return true;" /><input class="btn" type="button" value="Search" onclick="Search()" style="background-image:url('/resource/pca__PostcodeAnywhereIcon/button-slice.png');" /></td>
        </tr>
        <tr>
            <td colspan="2">You can search for any part or whole company name, postcode or phone number</td>
        </tr>
    </table>
    <div id="pnlResults">
        <div class="apexp">
            <div class="bPageBlock apexDefaultPageBlock secondaryPalette">
                <div class="pbBody">
                    <table class="list" id="pcaBusinessResults" style="width: 100%;">
                        <tr class="headerRow">
                            <th>Business Name</th>
                            <th>Address</th>
                            <th>Location Type</th>
                        </tr>
                        <tr>
                            <td colspan="3">No results. Please amend your search and try again.</td>
                        </tr>
                    </table>
                </div>
                <div class="pbFooter secondaryPalette">
                    <div class="bg"></div>
                </div>
            </div>
        </div>
    </div>
    <div id="pnlCompare" style="display:none">
        <div class="apexp">
            <div class="bPageBlock apexDefaultPageBlock secondaryPalette">
                <div class="pbHeader">
                    <table border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <td class="pbTitle"><h2 class="mainTitle">Compare &amp; Update Data</h2></td>
                            <td class="pbButton">
                                <input class="btn" type="button" value="Update" onclick="UpdateRecord()" />
                                <input class="btn" type="button" value="Cancel" onclick="CancelUpdate()" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="pbBody">
                    <table class="list" id="pcaBusinessCompare" style="width: 100%;">
                        <tr class="headerRow">
                            <th>Field</th>
                            <th>Your Value</th>
                            <th>New Value</th>
                            <th style="width: 10%">Update?</th>
                        </tr>
                    </table>
                </div>
                <div class="pbBottomButtons">
                    <table border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <td class="pbTitle">
                                &nbsp;
                            </td>
                            <td class="pbButtonb">
                                <input class="btn" type="button" value="Update" onclick="UpdateRecord()" />
                                <input class="btn" type="button" value="Cancel" onclick="CancelUpdate()" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="pbFooter secondaryPalette">
                    <div class="bg"></div>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        var FieldMap = {
            Address: {
                Required: false,
                Waiting: false,
                Fields: {
                    Id: null,
                    Name: null,
                    Line1: null,
                    Line2: null,
                    Street: null,
                    City: null,
                    State: null,
                    PostalCode: null,
                    Country: null,
                    CountryCode: null
                }
            },
            Contact: {
                Required: false,
                Waiting: false,
                Fields: {
                    Id: null,
                    Ceo: null,
                    Title: null,
                    Forename: null,
                    Surname: null,
                    CountryAccessCode: null,
                    Phone: null,
                    Fax: null
                }
            },
            Financial: {
                Required: false,
                Waiting: false,
                Fields: {
                    Id: null,
                    Duns: null,
                    SicCode: null,
                    SicDescription: null,
                    EmployeesHere: null,
                    EmployeesTotal: null,
                    ActualSales: null,
                    ModelledSales: null,
                    LocationType: null,
                    YearStarted: null,
                    NaicsCode: null,
                    NaicsDescription: null
                }
            },
            Hierarchy: {
                Required: false,
                Waiting: false,
                Fields: {
                    Duns: null,
                    ParentDuns: null,
                    ParentName: null,
                    DomesticUltimateDuns: null,
                    DomesticUltimateName: null,
                    GlobalUltimateDuns: null,
                    GlobalUltimateName: null,
                    GlobalUltimateCountry: null
                }
            }
        },
        StateData = {
            "USA": { "AL": "Alabama", "AK": "Alaska", "AZ": "Arizona", "AR": "Arkansas",
                "CA": "California", "CO": "Colorado", "CT": "Connecticut", "DE": "Delaware",
                "DC": "District Of Columbia", "FL": "Florida", "GA": "Georgia", "HI": "Hawaii",
                "ID": "Idaho", "IL": "Illinois", "IN": "Indiana", "IA": "Iowa", "KS": "Kansas",
                "KY": "Kentucky", "LA": "Louisiana", "ME": "Maine", "MD": "Maryland",
                "MA": "Massachusetts", "MI": "Michigan", "MN": "Minnesota", "MS": "Mississippi",
                "MO": "Missouri", "MT": "Montana", "NE": "Nebraska", "NV": "Nevada",
                "NH": "New Hampshire", "NJ": "New Jersey", "NM": "New Mexico", "NY": "New York",
                "NC": "North Carolina", "ND": "North Dakota", "OH": "Ohio", "OK": "Oklahoma",
                "OR": "Oregon", "PA": "Pennsylvania", "PR": "Puerto Rico", "RI": "Rhode Island",
                "SC": "South Carolina", "SD": "South Dakota", "TN": "Tennessee", "TX": "Texas",
                "UT": "Utah", "VT": "Vermont", "VI": "Virgin Islands", "VA": "Virginia",
                "WA": "Washington", "WV": "West Virginia", "WI": "Wisconsin", "WY": "Wyoming"
            },
            "CAN": { "AB": "Alberta", "BC": "British Columbia", "MB": "Alabama", "NL": "Newfoundland and Labrador",
                "NB": "New Brunswick", "NS": "Nova Scotia", "NT": "Northwest Territories", "NU": "Nunavut",
                "ON": "Ontario", "PE": "Prince Edward Island", "QC": "Quebec", "SK": "Saskatchewan",
                "YT": "Yukon Territory"
            }
        },
        FieldsToPopulate = [];

        //Find a DOM element
        function GetElement(reference, base) {
            if (!reference || reference == "")
                return null;

            base = base || _document;

            var _tags = ['input', 'textarea', 'select'],
                _matches = [];

            for (var t = 0; t < _tags.length; t++) {
                var _fields = base.getElementsByTagName(_tags[t]);

                for (var f in _fields) {
                    var _id = _fields[f].id || "",
                        _name = _fields[f].name || "";

                    if (_fields[f] == reference)
                        return _fields[f];
                    else if (typeof (reference) == 'string' && _id) {
                        if (_id == reference)
                            return _fields[f];

                        if (_id.indexOf(reference) > 0)
                            _matches.push(_fields[f]);
                    }
                    else if (typeof (reference) == 'string' && _name) {
                        if (_name == reference)
                            return _fields[f];
                    }
                }
            }

            if (_matches.length > 0)
                return _matches[0];
            else
                return null;
        }

        //Get the label of a DOM element
        function GetLabel(element) {
            var _label = "",
                _elem = element;

            if (_elem) {
                //Required salesforce element
                //Country field in salesforce
                while (_elem.parentNode.tagName == "DIV" || _elem.parentNode.tagName == "SPAN")
                    _elem = _elem.parentNode;

                //Street field in salesforce
                if (!_elem.parentNode.previousSibling)
                    _elem = _elem.parentNode.parentNode.parentNode.parentNode;

                _label = _elem.parentNode.previousSibling.firstChild.innerHTML;
            }

            return _label;
        }

        //Get the value of a DOM element
        function GetValue(element) {
            if (element) {
                if (element.tagName == "INPUT" || element.tagName == "TEXTAREA") {
                    if (element.type == "text" || element.type == "textarea")
                        return element.value;
                    if (element.type == "checkbox")
                        return element.checked;
                }
                if (element.tagName == "SELECT")
                    return element.options[element.selectedIndex].value;
            }

            return "";
        }

        //Set the value of a DOM element
        function SetValue(element, value) {
            if (element && (value || value == '')) {
                if (element.tagName == "INPUT" || element.tagName == "TEXTAREA") {
                    if (element.type == "text" || element.type == "textarea")
                        element.value = value;
                    if (element.type == "checkbox")
                        element.checked = ((typeof (value) == "boolean" && value) || value == "True");
                }
                if (element.tagName == "SELECT") {
                    for (var s = 0; s < element.options.length; s++) {
                        if (element.options[s].value == value || element.options[s].text == value) {
                            element.selectedIndex = s;
                            break;
                        }
                    }
                }
            }
        }

        function ReadQueryString() {
            var _pairs = window.parent.location.search.replace("?", "").split("&"),
                _query = {};

            for (var i = 0; i < _pairs.length; i++) {
                var _split = _pairs[i].split("=");
                _query[_split[0]] = _split[1];
            }

            return _query;
        }

        function Fetch(service, params, callback) {
            var _script = _document.createElement("script"),
                _head = _document.getElementsByTagName("head")[0],
                _url = _protocol + "//" + _host + "/" + service + "/" + _endpoint,
                _params = "";

            for (var i in params)
                _params += (_params ? "&" : "?") + i + "=" + encodeURIComponent(params[i]);

            _params += "&CallbackVariable=_serviceResponse";

            _script.src = _url + _params;

            _script.onload = _script.onreadystatechange = function () {
                if (!this.readyState || this.readyState === "loaded" || this.readyState === "complete") {
                    _script.onload = _script.onreadystatechange = null;
                    if (_head && _script.parentNode)
                        _head.removeChild(_script);

                    //Handle the response
                    if (_serviceResponse.length === 1 && _serviceResponse[0].Error !== undefined)
                        alert(_serviceResponse[0].Description);
                    else
                        callback(_serviceResponse);
                }
            }

            _serviceResponse = "";
            _head.insertBefore(_script, _head.firstChild);
        }

        function GetFields() {
            for (var q in _query) {
                for (var i in FieldMap) {
                    var _found = false;

                    for (var f in FieldMap[i].Fields) {
                        if (q == f) {
                            var _field = GetElement(_query[q], _opener.document),
                                _label = GetLabel(_field),
                                _value = GetValue(_field);

                            FieldMap[i].Fields[f] = { Field: _field, Label: _label, Value: _value, NewValue: null };
                            FieldMap[i].Required = FieldMap[i].Required || !!_field;
                            _found = true;
                            break;
                        }
                    }

                    if (_found) break;
                }
            }

            if (_addressIntegrations) {
                if (!FieldMap.Address.Fields.PostalCode) {
                    _addressControl = _opener.pca_Controls[0];

                    FieldMap.Address.Fields.Street = { Field: _addressControl.street, Label: GetLabel(_addressControl.street), Value: GetValue(_addressControl.street), NewValue: null };
                    FieldMap.Address.Fields.City = { Field: _addressControl.city, Label: GetLabel(_addressControl.city), Value: GetValue(_addressControl.city), NewValue: null };
                    FieldMap.Address.Fields.State = { Field: _addressControl.state, Label: GetLabel(_addressControl.state), Value: GetValue(_addressControl.state), NewValue: null };
                    FieldMap.Address.Fields.CountryCode = { Field: _addressControl.country, Label: GetLabel(_addressControl.country), Value: GetValue(_addressControl.CountryCode), NewValue: null };
                    FieldMap.Address.Fields.PostalCode = { Field: _addressControl.postcode, Label: GetLabel(_addressControl.postcode), Value: GetValue(_addressControl.postcode), NewValue: null };
                }
            }
            
            if (FieldMap.Address.Fields.PostalCode) {
                for (var c = 0; c < _opener.pca_Controls.length; c++) {
                    if (_opener.pca_Controls[c].postcode == FieldMap.Address.Fields.PostalCode.Field) {
                        _addressControl = _opener.pca_Controls[c];
                        break;
                    }
                }
            }

            if (_addressControl) {
                if (_addressControl.dropdown)
                    CloneCountryList(_addressControl);
                else {
                    UseFreeTextCountry();
                    SetValue(_countryField, GetValue(_addressControl.country));
                }
            }
            else {
                UseFreeTextCountry();

                if (FieldMap.Address.Fields.CountryCode)
                    SetValue(_countryField, GetValue(FieldMap.Address.Fields.CountryCode.Field));
            }
        }

        function CloneCountryList(control) {
            for (var i = 0; i < control.dropdown.options.length; i++)
                _countrySelect.options.add(new Option(control.dropdown.options[i].text, control.dropdown.options[i].value));

            _countrySelect.selectedIndex = control.dropdown.selectedIndex;
            var _currentCountry = GetValue(_countrySelect);

            if (_currentCountry)
                SetValue(_countryField, _currentCountry);
            else {
                UseFreeTextCountry();
                SetValue(_countryField, GetValue(control.country));
            }
        }

        function UseFreeTextCountry() {
            _freetextCountry = true;
            _countrySelect.style.display = "none";
            _countryField.style.display = "";
        }

        function AutoSearch() {
            var _search = GetValue(FieldMap.Address.Fields.Name.Field) || "";

            if (_search && FieldMap.Address.Fields.PostalCode && FieldMap.Address.Fields.City) {
                var _postcode = GetValue(FieldMap.Address.Fields.PostalCode.Field),
                    _city = GetValue(FieldMap.Address.Fields.City.Field);

                if (_postcode)
                    _search += ", " + _postcode;
                else if (_city)
                    _search += ", " + _city;
            }
            else if (FieldMap.Contact.Fields.Phone) {
                var _phone = GetValue(FieldMap.Contact.Fields.Phone.Field);

                if (_phone)
                    _search = _phone;
            }

            _searchField.value = _search;
            
            if (_search)
                Search();
        }

        function Search() {
            var _country = _freetextCountry ? GetValue(_countryField) : GetValue(_countrySelect),
                _searchTerm = GetValue(_searchField);

            if (!_searchTerm)
                alert("Please enter a search term");
            
            function bindRowEvents(row, id) {
                Listen(row, "mouseover", function () { row.className = "highlight" });
                Listen(row, "mouseout", function () { row.className = "" });
                Listen(row, "click", function () { Retrieve(id); });
            }

            function displaySearchResults(response) {
                CancelUpdate()
                ClearTable(_resultsTable);

                if (!response.length) {
                    var _row = _resultsTable.insertRow(1);
                        _errorCell = _row.insertCell(0);

                    _errorCell.colSpan = 3;
                    _errorCell.innerHTML = "No results. Please amend your search and try again.";
                }
                else {
                    for (var i = 0; i < response.length; i++) {
                        var _row = _resultsTable.insertRow(_resultsTable.rows.length),
                            _nameCell = _row.insertCell(0),
                            _addressCell = _row.insertCell(1),
                            _locationCell = _row.insertCell(2);

                        _nameCell.innerHTML = "<u>" + response[i].Name + "</u>";
                        _addressCell.innerHTML = response[i].Address;
                        _locationCell.innerHTML = response[i].LocationType;

                        _row.style.cssText = "cursor:pointer;";

                        bindRowEvents(_row, response[i].Id);
                    }
                }
            }

            Fetch("WorldwideBusinessData/Interactive/Find/v1.10", { Key: _key, Country: _country, SearchTerm: _searchTerm, Items: 10 }, displaySearchResults);
        }

        function Retrieve(id) {

            function formatPhoneNumber(accessCode, phone) {
                if (accessCode == "1" && phone.length == 10 && _locale == "en_US")
                    return "(" + phone.substring(0, 3) + ") " + phone.substring(3, 6) + "-" + phone.substring(6, 10);
                else
                    return "+" + accessCode + phone;
            }

            function GetStateCode(country, state) {
                var _state = state

                if (StateData[country]) {
                    for (var i in StateData[country]) {
                        if (StateData[country][i] == _state) {
                            _state = i;
                            break;
                        }
                    }
                }

                return _state
            }

            function checkWaiting() {
                if (!FieldMap.Address.Waiting && !FieldMap.Contact.Waiting && !FieldMap.Financial.Waiting && !FieldMap.Hierarchy.Waiting)
                    DrawCompareScreen();
            }

            function loadedAddress(response) {
                if (response.length) {
                    var _data = response[0];

                    _data.Street = _data.Line1 + (_data.Line2 ? "\n" + _data.Line2 : "");
                    if (_data.State) _data.State = GetStateCode(_data.CountryCode, _data.State);

                    for (var f in FieldMap.Address.Fields)
                        if (FieldMap.Address.Fields[f] && _data[f]) FieldMap.Address.Fields[f].NewValue = _data[f];
                }
                else FieldMap.Address.Required = false;

                FieldMap.Address.Waiting = false;
                checkWaiting();
            }

            function loadedContact(response) {
                if (response.length) {
                    var _data = response[0];

                    if (_data.Phone) _data.Phone = formatPhoneNumber(_data.CountryAccessCode, _data.Phone);
                    if (_data.Fax) _data.Fax = formatPhoneNumber(_data.CountryAccessCode, _data.Fax);

                    for (var f in FieldMap.Contact.Fields)
                        if (FieldMap.Contact.Fields[f] && _data[f]) FieldMap.Contact.Fields[f].NewValue = _data[f];
                }
                else FieldMap.Contact.Required = false;

                FieldMap.Contact.Waiting = false;
                checkWaiting();
            }

            function loadedFinancials(response) {
                if (response.length) {
                    var _data = response[0];

                    if (_data.Duns == "0") _record.Duns = "";
                    if (_data.YearStarted == "0") _data.YearStarted = "";
                    if (_data.SicCode == "0") _data.SicCode = "";
                    if (_data.EmployeesTotal == "0") _data.EmployeesTotal = "";
                    if (_data.EmployeesHere == "0") _data.EmployeesHere = "";
                    if (_data.ActualSales == "0") _data.ActualSales = "";
                    if (_data.ModelledSales == "0") _data.ModelledSales = "";

                    switch (_data.LocationType) {
                        case "HeadOffice": _data.LocationType = (_locale == "en_GB" ? "Head Office" : "Headquarters"); break;
                        case "BranchOffice": _data.LocationType = "Branch Office"; break;
                        case "SingleLocation": _data.LocationType = "Single Location"; break;
                    }

                    for (var f in FieldMap.Financial.Fields)
                        if (FieldMap.Financial.Fields[f] && _data[f]) FieldMap.Financial.Fields[f].NewValue = _data[f];
                }
                else FieldMap.Financial.Required = false;

                FieldMap.Financial.Waiting = false;
                checkWaiting();
            }

            function loadedHierarchy(response) {
                if (response.length) {
                    var _data = response[0];

                    if (_data.Duns == "0") _record.Duns = "";
                    if (_data.ParentDuns == "0") _data.ParentDuns = "";
                    if (_data.DomesticUltimateDuns == "0") _data.DomesticUltimateDuns = "";
                    if (_data.GlobalUltimateDuns == "0") _data.GlobalUltimateDuns = "";

                    for (var f in FieldMap.Hierarchy.Fields)
                        if (FieldMap.Hierarchy.Fields[f] && _data[f]) FieldMap.Hierarchy.Fields[f].NewValue = _data[f];
                }
                else FieldMap.Hierarchy.Required = false;

                FieldMap.Hierarchy.Waiting = false;
                checkWaiting();
            }

            for (var i in FieldMap)
                FieldMap[i].Waiting = FieldMap[i].Required;

            if (FieldMap.Address.Waiting)
                Fetch("WorldwideBusinessData/Interactive/RetrieveAddressById/v1.00", { Key: _key, Id: id }, loadedAddress);

            if (FieldMap.Contact.Waiting)
                Fetch("WorldwideBusinessData/Interactive/RetrieveContactById/v1.00", { Key: _key, Id: id }, loadedContact);

            if (FieldMap.Financial.Waiting)
                Fetch("WorldwideBusinessData/Interactive/RetrieveFinancialsById/v1.00", { Key: _key, Id: id }, loadedFinancials);

            if (FieldMap.Hierarchy.Waiting)
                Fetch("WorldwideBusinessData/Interactive/RetrieveHierarchyById/v1.00", { Key: _key, Id: id, HierarchyType: "Single" }, loadedHierarchy);
        }

        function DrawCompareScreen() {

            function drawSectionHeader(title) {
                var _row = _compareTable.insertRow(_compareTable.rows.length),
                    _column = _row.insertCell(0);

                _column.colSpan = 4;
                _column.innerHTML = title;
                _column.style.cssText = "font-weight:bold;background-color:#EEECD1;";
            }

            function bindRowEvents(row, checkbox) {
                row.pcaOverCheckbox = false;
                Listen(row, "mouseover", function () { row.className = "highlight" });
                Listen(row, "mouseout", function () { row.className = "" });
                Listen(row, "click", function () { if (!row.pcaOverCheckbox) checkbox.checked = !checkbox.checked });
                Listen(checkbox, "mouseover", function () { row.pcaOverCheckbox = true; });
                Listen(checkbox, "mouseout", function () { row.pcaOverCheckbox = false; });
            }

            function addCompareField(field) {
                var _row = _compareTable.insertRow(_compareTable.rows.length),
                    _labelCell = _row.insertCell(0),
                    _salesforceValueCell = _row.insertCell(1),
                    _pcaValueCell = _row.insertCell(2),
                    _checkboxCell = _row.insertCell(3),
                    _checkbox = _document.createElement("input");

                _labelCell.innerHTML = "<b>" + field.Label + "</b>";
                _salesforceValueCell.innerHTML = field.Value;
                _pcaValueCell.innerHTML = field.NewValue;

                _checkbox.type = "checkbox";
                _checkbox.checked = !!field.NewValue;
                _checkboxCell.appendChild(_checkbox);

                _row.style.cssText = "cursor:pointer;";
                bindRowEvents(_row, _checkbox);

                FieldsToPopulate.push({ Field: field.Field, Value: field.NewValue, CheckBox: _checkbox });
            }

            ClearTable(_compareTable);
            FieldsToPopulate = [];

            for (var i in FieldMap) {
                if (FieldMap[i].Required) {
                    drawSectionHeader(i);

                    for (var f in FieldMap[i].Fields) {
                        if (FieldMap[i].Fields[f] && FieldMap[i].Fields[f].Field)
                            addCompareField(FieldMap[i].Fields[f]);
                    }

                    //Add additional address controls
                    if (i == "Address" && _addressIntegrations) {
                        for (var c = 0; c < _opener.pca_Controls.length; c++) {
                            if (_opener.pca_Controls[c] != _addressControl) {
                                var _control = _opener.pca_Controls[c];
                                if (FieldMap.Address.Fields.Street) addCompareField({ Field: _control.street, Label: GetLabel(_control.street), Value: GetValue(_control.street), NewValue: FieldMap.Address.Fields.Street.NewValue });
                                if (FieldMap.Address.Fields.City) addCompareField({ Field: _control.city, Label: GetLabel(_control.city), Value: GetValue(_control.city), NewValue: FieldMap.Address.Fields.City.NewValue });
                                if (FieldMap.Address.Fields.State) addCompareField({ Field: _control.state, Label: GetLabel(_control.state), Value: GetValue(_control.state), NewValue: FieldMap.Address.Fields.State.NewValue });
                                if (FieldMap.Address.Fields.PostalCode) addCompareField({ Field: _control.postcode, Label: GetLabel(_control.postcode), Value: GetValue(_control.postcode), NewValue: FieldMap.Address.Fields.PostalCode.NewValue });
                                if (FieldMap.Address.Fields.CountryCode) addCompareField({ Field: _control.country, Label: GetLabel(_control.country), Value: GetValue(_control.country), NewValue: FieldMap.Address.Fields.CountryCode.NewValue });
                            }
                        }
                    }
                }
            }

            _comparePanel.style.display = "";
            _resultsPanel.style.display = "none";
        }

        function UpdateRecord() {
            for (var i = 0; i < FieldsToPopulate.length; i++) {
                if (FieldsToPopulate[i].CheckBox.checked)
                    SetValue(FieldsToPopulate[i].Field, FieldsToPopulate[i].Value);
            }

            if (_opener.pca_Controls) {
                for (var c = 0; c < _opener.pca_Controls.length; c++) {
                    _opener.pca_Controls[c].countryFromFreetext();
                    _opener.pca_Controls[c].setValue(_opener.pca_Controls[c].country, _opener.pca_Controls[c].selectedCountry());
                }
            }

            window.close();
        }
        
        function CancelUpdate() {
            _comparePanel.style.display = "none";
            _resultsPanel.style.display = "";

            for (var m in FieldMap) {
                for (var f in FieldMap[m].Fields) {
                    if (FieldMap[m].Fields[f]) FieldMap[m].Fields[f].NewValue = null;
                }
            }

            FieldsToPopulate = [];
        }

        function ClearTable(table) {
            while (table.rows.length > 1)
                table.deleteRow(1);
        }

        function Listen(target, event, action) {
            if (window.addEventListener)
                target.addEventListener(event, action, false);
            else
                target.attachEvent('on' + event, action);
        }

        var _resultsTable = document.getElementById("pcaBusinessResults"),
            _countrySelect = document.getElementById("pcaBusinessCountry"),
            _countryField = document.getElementById("pcaBusinessCountryText"),
            _searchField = document.getElementById("pcaBusinessSearch"),
            _compareTable = document.getElementById("pcaBusinessCompare"),
            _resultsPanel = document.getElementById("pnlResults"),
            _comparePanel = document.getElementById("pnlCompare"),
            _protocol = "https:",
            _host = "services.postcodeanywhere.co.uk",
            _endpoint = "json2.ws",
            _serviceResponse = null,
            _freetextCountry = false,
            _document = window.document,
            _opener = window.opener,
            _query = ReadQueryString(),
            _key = _query.Key,
            _addressIntegrations = _query.UseAddressIntegrations == "true" && !!_opener.pca_Controls,
            _locale = _opener.UserContext.locale || "en-US",
            _addressControl = null;

        GetFields();
        AutoSearch();
    </script>
</body>
</html>
