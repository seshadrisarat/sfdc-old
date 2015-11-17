public class PrintAddressExtension
{
    public PrintAddressExtension(ApexPages.StandardController controller)
    {
    }

    public class PaObject
    {
        private Contact m_contact;
        public PaObject()
        {
            Id id = System.currentPageReference().getParameters().get('id');
            
            Contact a_contact = id == null ? new Contact() :
                [Select Id, FirstName, LastName, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode FROM Contact WHERE Id = :id];
                
           setContact(a_contact);     
           
        }
        public PaObject(Contact a_contact)
        {
           setContact(a_contact);     
           
        }
        
        public Contact getContact()
        {
            return m_contact;
        }
        
        public void setContact(Contact a_contact)
        {
            m_contact = a_contact;
            printBarcode = 'false';            
            formattedAddress = PrepareFormattedAddress();
        }
                
        
        // contact full name
        public String getContactFullName()
        {
            if (m_contact == null)
            {
                system.Debug(logginglevel.ERROR, 'PaObject.m_contact is null');
                return '';
            }
            
            return m_contact.FirstName + ' ' + m_contact.LastName;
        }
        
        public String printBarcode { get; set; }
             
        private String formattedAddress = '';
        
        public void setFormattedAddress(String value)
        {
            System.debug(logginglevel.INFO, 'Address is updated: ' + value);
            formattedAddress = value;
        }
        
        public String getFormattedAddress()
        {
            return formattedAddress;
        }
 
        private String PrepareFormattedAddress()
        {
            if (m_contact == null)
            {
                system.Debug(logginglevel.ERROR, 'PaObject.m_contact is null');
                return '';
            }

            String state = m_contact.MailingState;
            String city = m_contact.MailingCity;
            String zip = m_contact.MailingPostalCode;
            
            List<String> params = new List<String>();            
        
            // check if zip, state and city meet to some formatting condition
            if (zip != null && zip.length() >= 5 && state != null && state.length() >= 2 && city != null && city.length() > 0)
            {
                // format address from these fields
                params.add(m_contact.FirstName + ' ' + m_contact.LastName);
                params.add(m_contact.MailingStreet.trim());
                params.add(city.trim());
                params.add(state.trim());
                params.add(zip.trim());

                return String.format('{0}\r\n{1}\r\n{2}, {3} {4}', params);
            }
            else
            {
                // make address from MailingStreet field
                params.add(m_contact.LastName + ', ' + m_contact.FirstName);
                params.add(m_contact.MailingStreet.trim());

                return String.format('{0}\r\n{1}', params);
            }
        }
       
        public String getAddressLabelXml()
        {
            String template = '<?xml version="1.0" encoding="utf-8"?>' +
                '<DieCutLabel Version="8.0" Units="twips">' +
                '<PaperOrientation>Landscape</PaperOrientation>' +
                '<Id>Address</Id>' +
                '<PaperName>30252 Address</PaperName>' +
                '<DrawCommands>' +
                    '<RoundRectangle X="0" Y="0" Width="1581" Height="5040" Rx="270" Ry="270" />' +
                '</DrawCommands>' +
                '<ObjectInfo>' +
                '<AddressObject>' +
                    '<Name>Address</Name>' +
                    '<ForeColor Alpha="255" Red="0" Green="0" Blue="0" />' +
                    '<BackColor Alpha="0" Red="255" Green="255" Blue="255" />' +
                    '<LinkedObjectName></LinkedObjectName>' +
                    '<Rotation>Rotation0</Rotation>' +
                    '<IsMirrored>False</IsMirrored>' +
                    '<IsVariable>True</IsVariable>' +
                    '<HorizontalAlignment>Left</HorizontalAlignment>' +
                    '<VerticalAlignment>Middle</VerticalAlignment>' +
                    '<TextFitMode>ShrinkToFit</TextFitMode>' +
                    '<UseFullFontHeight>True</UseFullFontHeight>' +
                    '<Verticalized>False</Verticalized>' +
                    '<StyledText>' +
                        '<Element>' +
                        '<String></String>' +
                        '<Attributes>' +
                            '<Font Family="Arial" Size="12" Bold="False" Italic="False" Underline="False" Strikeout="False" />' +
                            '<ForeColor Alpha="255" Red="0" Green="0" Blue="0" />' +
                        '</Attributes>' +
                        '</Element>' +
                    '</StyledText>' +
                    '<ShowBarcodeFor9DigitZipOnly>False</ShowBarcodeFor9DigitZipOnly>' +
                    '<BarcodePosition>AboveAddress</BarcodePosition>' +
                    '<LineFonts>' +
                        '<Font Family="Arial" Size="12" Bold="False" Italic="False" Underline="False" Strikeout="False" />' +
                        '<Font Family="Arial" Size="12" Bold="False" Italic="False" Underline="False" Strikeout="False" />' +
                        '<Font Family="Arial" Size="12" Bold="False" Italic="False" Underline="False" Strikeout="False" />' +
                    '</LineFonts>' +
                '</AddressObject>' +
                '<Bounds X="332" Y="150" Width="4455" Height="1260" />' +
                '</ObjectInfo>' +
                '</DieCutLabel>';

            return template;        
        }
      
        private String imageSrc = 'data:image/png;base64';
        
        public void setImageSrc(String value)
        {
            imageSrc = value;
        }
        
        public String getImageSrc()
        {
            return imageSrc;
        }

    }

    private paObject m_paObject;
   
    public PaObject getPaObject()
    {
        if (m_paObject == null)
        {
            m_paObject = new PaObject();
            System.debug(logginglevel.INFO, 'singleton PaObject is created');
        }
        return m_paObject;
    }
    public PaObject getPaObject(Contact a_contact)
    {
        if (m_paObject == null)
        {
            m_paObject = new PaObject(a_contact);
            System.debug(logginglevel.INFO, 'singleton PaObject is created');
        }
        return m_paObject;
    }
    
}