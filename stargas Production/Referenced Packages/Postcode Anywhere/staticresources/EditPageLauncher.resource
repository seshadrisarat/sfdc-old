function pca_Load() {
    var _iframe = document.getElementById("itarget"),
        _document = _iframe ? _iframe.contentDocument || _iframe.contentWindow.document || document : document,
        _null = null,
        _status = document.getElementById("pca_status"),
        _businessSearchPage = "/resource/pca__BusinessSearch",
        _imageLibrary = "/resource/pca__PostcodeAnywhereIcon/",
        _username = Sfdc.UserContext.userId,
        _newTheme = !(Sfdc.UserContext.uiSkin == "Theme2");

    //Test to see if we have permission on this document
    try { !_document.getElementById } catch (e) { _document = document; StatusMessage("Denied Access to Iframe"); };
    
    if (typeof (pca_Settings) == 'undefined') {
        StatusMessage("No Settings Found");
        return;
    }

    var _settings = pca_Settings,
        _addresses = pca_Addresses,
        _businesses = pca_Businesses,
        _payments = pca_Payments,
        _emails = pca_Emails,
        _actions = pca_Actions;

    function StatusMessage(message) {
        if (_status) _status.innerHTML = message;
    }

    function FindField(elem) {
        if (!elem || elem == "")
            return null;

        var _tags = ['input', 'textarea', 'select'],
            _matches = [];

        for (var t = 0; t < _tags.length; t++) {
            var _fields = _document.getElementsByTagName(_tags[t]);

            for (var f in _fields) {
                var _id = _fields[f].id || "",
                    _name = _fields[f].name || "";

                if (_fields[f] == elem)
                    return _fields[f];
                else if (typeof (elem) == 'string' && _id) {
                    if (_id == elem)
                        return _fields[f];

                    if (_id.indexOf(elem) > 0)
                        _matches.push(_fields[f]);
                }
                else if (typeof (elem) == 'string' && _name) {
                    if (_name == elem)
                        return _fields[f];
                }
            }
        }

        if (_matches.length > 0)
            return _matches[0];
        else
            return null;
    }

    function SetElementValue(field, value) {
        var _field = FindField(field);

        if (_field) {
            if (_field.tagName == "INPUT" || _field.tagName == "TEXTAREA") {
                if (_field.type == "text" || _field.type == "textarea")
                    _field.value = value;
                if (_field.type == "checkbox")
                    _field.checked = ((typeof (value) == "boolean" && value) || value == "True");
            }
            if (_field.tagName == "SELECT") {
                for (var s = 0; s < _field.options.length; s++) {
                    if (_field.options[s].value == value || _field.options[s].text == value) {
                        _field.selectedIndex = s;
                        break;
                    }
                }
            }
        }
    }

    function LoadControl(address) {
        StatusMessage("Loading...");

        var _control = new pca_AddressControl(address.Country, address.Postcode, address.Street, address.City, _settings.StandardKey, { document: _document, State: address.State, Area: address.Area, Id: address.Id, Building: address.Building, Validation: address.Validation });
        _control.royalmailkey = _settings.RoyalmailKey;
        _control.teleatlas = _settings.UseInternational;
        _control.royalmail = _settings.UseRoyalmail;
        _control.username = _username;
        _control.company = _control.findField(address.Company);
        _control.usps = _settings.UseUSPS;
        _control.rmcompany = _settings.RoyalmailCompany;
        _control.rmreverse = _settings.RoyalmailReverse;
        _control.usreverse = _settings.USPSReverse;
        _control.disableotheroption = _settings.DisableOtherCountryOption;

        var standardAddress = (address.Street == "acc17street" || address.Street == "acc18street" || address.Street == "con18street" || address.Street == "con19street" || address.Street == "lea16street" || address.Street == "ctrc25street" || address.Street == "PersonMailingAddressstreet");

        switch (_settings.CountryNameStyle) {
            case "Full Country Name (default)":
                _control.style = 1; break;
            case "2 Character ISO Code":
                _control.style = 2; break;
            case "3 Character ISO Code":
                _control.style = 3; break;
        }

        if (!_settings.DisableCountryList) {
            _control.setupCountryList(_settings.CountryList);

            var _container = _document.createElement("div");
            _control.country.parentNode.appendChild(_container);
            _container.appendChild(_control.country);
            _container.appendChild(_control.dropdown);
        }

        if (!_settings.DisableFieldRearrange && standardAddress) {
            var _fields = [_control.country, _control.postcode, _control.street, _control.city],
                _cells = [],
                _base = _control.street.tabIndex;

            if (_control.state) _fields.push(_control.state);
            if (_control.area) _fields.push(_control.area);
            if (_control.udprn) _fields.push(_control.udprn);

            for (var t = 0; t < _fields.length; t++)
                _fields[t].tabIndex = t + _base;

            if (_control.dropdown)
                _control.country.tabIndex = _control.dropdown.tabIndex;

            for (var i = 0; i < _fields.length; i++) {
                if (_fields[i] == _control.street) _fields[i] = _control.autocomplete.anchor;
                if (_fields[i] == _control.country && _container) _fields[i] = _container;
                
                while (_fields[i].parentNode.tagName == "DIV" || _fields[i].parentNode.tagName == "SPAN")
                    _fields[i] = _fields[i].parentNode;
            }

            var _tbl = _fields[0].parentNode.parentNode.parentNode;
            if (_tbl.nodeName == "TR") _tbl = _tbl.parentNode;

            for (var r = 0; r < _tbl.rows.length; r++) {
                for (var c = 0; c < _tbl.rows[r].cells.length; c++) {
                    for (var f = 0; f < _fields.length; f++) {
                        if (_tbl.rows[r].cells[c].firstChild == _fields[f])
                            _cells.push(_tbl.rows[r].cells[c]);
                    }
                }
            }

            for (var m = 0; m < _cells.length; m++) {
                _cells[m].previousSibling.appendChild(_fields[m].parentNode.previousSibling.firstChild);
                _cells[m].appendChild(_fields[m]);
            }
        }

        var _clearlink = _document.createElement("a");
        _clearlink.innerHTML = "Clear";
        _clearlink.href = "javascript:pca_Controls[" + _control.uid + "].clear();";
        (_container || _control.country.parentNode).appendChild(_clearlink);

        if (_settings.UseInternational || _settings.UseRoyalmail || _settings.UseUSPS) {
            var _button = document.createElement("input");

            _button.type = "button";
            _button.className = "btn";
            _button.value = "Find";
            _button.style.cssText = "background-image:url('" + _imageLibrary + "button-slice" + (_newTheme ? "2" : "") + ".png');";
            _button.onclick = function () { if ((_control.street.value == '' && _control.postcode.value) != '' || !_control.canreverse) { _control.street.focus(); _control.street.select(); } else _control.reverse(); };

            _control.postcode.parentNode.appendChild(_button);
        }
        
        if ((_control.postcode.id == "acc18zip" || _control.postcode.id == "con18zip") && !sfdcPage.editMode) {
            var _header = _control.postcode.parentNode.parentNode.parentNode.parentNode.parentNode.previousSibling;
            
            if (_header.innerHTML.indexOf("\">Copy ") >= 0)
                _header.innerHTML = _header.innerHTML.substring(0, _header.innerHTML.indexOf("\">Copy ")) + ";javascript:pca_Controls[" + _control.uid + "].countryFromFreetext();javascript:pca_Controls[" + _control.uid + "].oncopy();" + _header.innerHTML.substring(_header.innerHTML.indexOf("\">Copy "), _header.innerHTML.length);
        }

        for (var a = 0; a < _actions.length; a++) {
            switch (_actions[a].Event) {
                case "Initialise":
                    _control.onload = _actions[a].Code; _control.onload(); break;
                case "Search":
                    _control.onsearch = _actions[a].Code; break;
                case "Select":
                    _control.onselect = _actions[a].Code; break;
                case "Copy":
                    _control.oncopy = _actions[a].Code; break;
                case "Clear":
                    _control.onclear = _actions[a].Code; break;
                case "Change":
                    _control.onchange = _actions[a].Code; break;
                case "Country":
                    _control.oncountrychange = _actions[a].Code; break;
                case "Error":
                    _control.onerror = _actions[a].Code; break;
            }
        }

        StatusMessage("Active");

        return _control;
    }

    function LoadBusiness(business) {
        var _button = document.createElement("input"),
            _params = "Key=" + _settings.StandardKey;

        for (var i in business)
            _params += business[i] ? "&" + i + "=" + business[i] : "";

        _button.type = "button";
        _button.className = "btn";
        _button.value = "Find";
        _button.style.cssText = "background-image:url('" + _imageLibrary + "button-slice" + (_newTheme ? "2" : "") + ".png');";
        _button.onclick = function () { window.open(_businessSearchPage + "?" + _params, "", "height=600,width=800,scrollbars=yes") };

        _companyfield.parentNode.appendChild(_button);
    }

    function LoadPaymentValidation(payment) {
        var _sortcodefield = FindField(payment.SortCode),
            _accountnumberfield = FindField(payment.AccountNumber),
            _button = document.createElement("input"),
            _statusimg = document.createElement("img"),
            _statusmessage = document.createElement("span"),
            _validation = FindField(payment.Validation);

        function BankVerify() {
            var script = document.createElement("script"),
                head = document.getElementsByTagName("head")[0],
                url = "https://services.postcodeanywhere.co.uk/BankAccountValidation/Interactive/Validate/v2.00/json.ws?";

            // Build the query string
            url += "&Key=" + encodeURI(_settings.StandardKey);
            url += "&AccountNumber=" + (!_accountnumberfield || !_accountnumberfield.value ? "00000000" : encodeURI(_accountnumberfield.value));
            url += "&SortCode=" + encodeURI(_sortcodefield.value);
            url += "&CallbackFunction=pca_BankVerifyCallback";

            script.src = url;

            // Make the request
            script.onload = script.onreadystatechange = function () {
                if (!this.readyState || this.readyState === "loaded" || this.readyState === "complete") {
                    script.onload = script.onreadystatechange = null;
                    if (head && script.parentNode)
                        head.removeChild(script);
                }
            }

            head.insertBefore(script, head.firstChild);
        }

        function BankVerifyCallback(response) {
            if (response.length == 1 && typeof (response[0].Error) != "undefined") {
                _statusimg.src = "/img/checkbox_unchecked.gif";
                _statusmessage.innerHTML = "<b>Error:</b> " + response[0].Description;
            }
            else {
                if (response.length) {
                    SetElementValue(payment.BankBIC, response[0].BankBIC);
                    SetElementValue(payment.BankName, response[0].Bank);
                    SetElementValue(payment.BranchBIC, response[0].BranchBIC);
                    SetElementValue(payment.BranchName, response[0].Branch);
                    SetElementValue(payment.ContactAddress, response[0].ContactAddressLine1 + "\n" + response[0].ContactAddressLine2);
                    SetElementValue(payment.ContactCity, response[0].ContactPostTown);
                    SetElementValue(payment.ContactPostcode, response[0].ContactPostcode);
                    SetElementValue(payment.ContactPhone, response[0].ContactPhone);
                    SetElementValue(payment.ContactFax, response[0].ContactFax);

                    SetElementValue(payment.DirectDebit, response[0].IsDirectDebitCapable);
                    SetElementValue(payment.CHAPS, response[0].CHAPSSupported);
                    SetElementValue(payment.FasterPayments, response[0].FasterPaymentsSupported);
                    SetElementValue(payment.Validation, response[0].IsCorrect);

                    if (response[0].IsCorrect == "True") {
                        _statusimg.src = "/img/checkbox_checked.gif";
                        _statusmessage.innerHTML = "";
                    }
                    else {
                        _statusimg.src = "/img/checkbox_unchecked.gif";
                        _statusmessage.innerHTML = "<b>Error:</b> " + response[0].StatusInformation;
                    }
                }
            }
        }

        _button.type = "button";
        _button.className = "btn";
        _button.value = "Find & Validate";
        _button.style.cssText = "background-image:url('" + _imageLibrary + "button-slice" + (_newTheme ? "2" : "") + ".png');";
        _button.onclick = BankVerify;

        _sortcodefield.parentNode.appendChild(_button);

        _statusimg.src = "/img/checkbox_unchecked.gif";
        _statusmessage.innerHTML = "";
        _statusmessage.style.cssText = "color:red;";

        if (_accountnumberfield) {
            if (_validation) {
                _validation.style.display = "none";
                _validation.parentNode.appendChild(_statusimg);
                _validation.parentNode.appendChild(_statusmessage);

                if (_validation.checked)
                    _statusimg.src = "/img/checkbox_checked.gif";
            }
            else {
                _accountnumberfield.parentNode.appendChild(_statusimg);
                _accountnumberfield.parentNode.appendChild(_statusmessage);
                _accountnumberfield.style.cssFloat = "left";
            }
            _accountnumberfield.onkeyup = function () { _statusimg.src = "/img/checkbox_unchecked.gif"; _statusmessage.innerHTML = ""; SetElementValue(payment.Validation, false); };
        }

        window.pca_BankVerifyCallback = BankVerifyCallback;
    }

    function LoadEmailValidation(email) {
        var _emailfield = FindField(email.Email),
            _button = document.createElement("input"),
            _statusimg = document.createElement("img"),
            _statusmessage = document.createElement("span"),
            _validation = FindField(email.Validation);

        function EmailValidate() {
            var script = document.createElement("script"),
                head = document.getElementsByTagName("head")[0],
                url = "https://services.postcodeanywhere.co.uk/EmailValidation/Interactive/Validate/v1.01/json.ws?";

            // Build the query string
            url += "&Key=" + encodeURI(_settings.StandardKey);
            url += "&Email=" + encodeURI(_emailfield.value);
            url += "&CallbackFunction=pca_EmailValidateCallback";

            script.src = url;

            // Make the request
            script.onload = script.onreadystatechange = function () {
                if (!this.readyState || this.readyState === "loaded" || this.readyState === "complete") {
                    script.onload = script.onreadystatechange = null;
                    if (head && script.parentNode)
                        head.removeChild(script);
                }
            }

            head.insertBefore(script, head.firstChild);
        }

        function EmailValidateCallback(response) {
            if (response.length == 1 && typeof (response[0].Error) != "undefined")
                alert(response[0].Description);
            else {
                if (response.length) {
                    SetElementValue(_validation, response[0].FoundServer);

                    if (response[0].FoundServer == "True") {
                        _statusimg.src = "/img/checkbox_checked.gif";
                        _statusmessage.innerHTML = "";
                    }
                    else {
                        _statusimg.src = "/img/checkbox_unchecked.gif";
                        _statusmessage.innerHTML = "Invalid";
                        if (response[0].FoundServer != "True") _statusmessage.innerHTML = "<b>Error:</b> Could not verify server";
                        if (response[0].FoundDnsRecord != "True") _statusmessage.innerHTML = "<b>Error:</b> Could not verify DNS record";
                        if (response[0].ValidFormat != "True") _statusmessage.innerHTML = "<b>Error:</b> Invalid format";
                    }
                }
            }
        }

        _button.type = "button";
        _button.className = "btn";
        _button.value = "Validate";
        _button.style.cssText = "background-image:url('" + _imageLibrary + "button-slice" + (_newTheme ? "2" : "") + ".png');";
        _button.onclick = EmailValidate;

        _emailfield.parentNode.appendChild(_button);

        _statusimg.src = "/img/checkbox_unchecked.gif";
        _statusmessage.innerHTML = "";
        _statusmessage.style.cssText = "color:red;";

        if (_validation) {
            _validation.style.display = "none";
            _validation.parentNode.appendChild(_statusimg);
            _validation.parentNode.appendChild(_statusmessage);

            if (_validation.checked)
                _statusimg.src = "/img/checkbox_checked.gif";
        }
        else {
            _emailfield.parentNode.appendChild(_statusimg);
            _emailfield.parentNode.appendChild(_statusmessage);
            _emailfield.style.cssFloat = "left";
        }
        _emailfield.onkeyup = function () { _statusimg.src = "/img/checkbox_unchecked.gif"; _statusmessage.innerHTML = ""; SetElementValue(email.Validation, false); };

        window.pca_EmailValidateCallback = EmailValidateCallback;
    }

    function SetupInline(prefix) {
        var _element = _document.getElementById(prefix + "_ilecell");

        if (_element) {

            _element.ondblclick = function () {
                var _loaded = false;

                if (!sfdcPage.editMode)
                    sfdcPage.activateInlineEditMode();

                if (!sfdcPage.inlineEditData.isCurrentField(sfdcPage.getFieldById(_element.id)))
                    sfdcPage.inlineEditData.openField(sfdcPage.getFieldById(_element.id));

                for (var i = 0; i < pca_Controls.length; i++) {
                    if (pca_Controls[i].postcode.id == prefix + "zip")
                        _loaded = true;
                }

                if (!_loaded) {
                    for (var address = 0; address < _addresses.length; address++) {
                        if (_addresses[address].Postcode == prefix + "zip" && FindField(_addresses[address].Postcode))
                            LoadControl(_addresses[address]);
                    }
                }
            }
        }
    }

    var pca_ControlRef = window.pca_ControlRef = window.pca_ControlRef || {};

    try {
        for (var i = 0; i < _actions.length; i++) {
            if (_actions[i].Event == "Startup")
                _actions[i].Code();
        }

        for (var i = 0; i < _addresses.length; i++) {
            if (FindField(_addresses[i].Postcode) && !pca_ControlRef[_addresses[i].Postcode])
                pca_ControlRef[_addresses[i].Postcode] = LoadControl(_addresses[i]);
        }

        if (_settings.UseBusiness) {
            for (var i = 0; i < _businesses.length; i++) {
                var _companyfield = FindField(_businesses[i].Name);
                if (_companyfield)
                    LoadBusiness(_businesses[i]);
            }
        }

        if (_settings.UsePayment) {
            for (var i = 0; i < _payments.length; i++) {
                var _sortcodefield = FindField(_payments[i].SortCode);
                if (_sortcodefield)
                    LoadPaymentValidation(_payments[i]);
            }
        }

        if (_settings.UseEmail) {
            for (var i = 0; i < _emails.length; i++) {
                var _emailfield = FindField(_emails[i].Email);
                if (_emailfield)
                    LoadEmailValidation(_emails[i]);
            }
        }

        SetupInline("acc17");
        SetupInline("acc18");
        SetupInline("con18");
        SetupInline("con19");
        SetupInline("lea16");
        SetupInline("ctrc25");
        SetupInline("PersonMailingAddress");

        if (pca_Controls.length == 0)
            StatusMessage("No Address Fields");

        if (_settings.HideSidebarComponent) {
            if (_status) _status.parentNode.parentNode.parentNode.style.display = "none";
        }
    }
    catch (e) {
        StatusMessage("Error: " + e.message);
        throw e;
    }
}