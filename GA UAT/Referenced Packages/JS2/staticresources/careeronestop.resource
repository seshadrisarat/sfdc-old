/**
 * This settings is the result of the migration of the configuration file from the previous version of
 * FCK Editor so that the exposed features are the same (@see richtext.config.js).
 */
CKEDITOR.editorConfig = function( config )
{

     /*
      * DEFINITION OF THE TOOLBARS
      *
      * A new toolbar is defined this way: config.toolbar_<tbName> where <tbName> is the name of the toolbar that can
      * be referenced by config.toolbar.
      */

    config.toolbar_SalesforceBasic = [
        ['Undo', 'Redo'],
        ['Bold', 'Italic', 'Underline', 'Strike'],
        ['-', 'Link', 'SfdcImage'],
        ['-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight'],
        ['-', 'BulletedList', 'NumberedList'],
        ['Indent', 'Outdent']
    ];

    config.toolbar_EmailMultiFormat = [
        ['SfdcSwitchToText','Font', 'FontSize'],
        ['Bold','Italic','Underline'],
        ['JustifyLeft','JustifyCenter', 'JustifyRight'],
        ['BulletedList', 'NumberedList', 'Indent', 'Outdent']
    ];

    config.toolbar_Email = [
        ['Font', 'FontSize'],
        ['Bold','Italic','Underline'],
        ['JustifyLeft','JustifyCenter', 'JustifyRight'],
        ['BulletedList', 'NumberedList', 'Indent', 'Outdent']
    ];

    config.toolbar_SalesforceLight = [
        ['Bold', 'Italic'],
        ['Link'],
        ['JustifyLeft', 'JustifyCenter', 'JustifyRight'],
        ['BulletedList'],
        ['FontSize']
    ];

    config.toolbar_Knowledge = [
        ['Source'],
        ['Undo', 'Redo'],
        ['Bold', 'Italic', 'Underline', 'Strike', '-', 'RemoveFormat'],
        ['Table'],
        ['smartLink', 'Link', 'Unlink', 'Anchor'],
        ['SfdcImage', config.allowIframe ? 'MediaEmbed' : ''],
        ['JustifyLeft','JustifyCenter', 'JustifyRight'],
        ['BulletedList', 'NumberedList', 'Indent', 'Outdent'],
        ['Format', 'Font', 'FontSize', 'TextColor', 'BGColor']
    ];

    config.toolbar_Visualforce = [
        ['Undo', 'Redo'],
        ['Bold', 'Italic', 'Underline', 'Strike'],
        ['Link', 'SfdcImage'],
        ['JustifyLeft','JustifyCenter', 'JustifyRight'],
        ['BulletedList', 'NumberedList', 'Indent', 'Outdent'],
    ];

    config.toolbarCanCollapse = false;
    config.resize_enabled = false;
	config.autoParagraph = false;
	config.fillEmptyBlocks = false;
    /*
     * Deactivate:
     * - The Element path component (RTE's "status bar")
     * - Resizing ability (editing area maximization, resizing)
     * - Context menus
     * - Standard image dialog
     * Make sure the list here is in sync with the one mentioned in RichTextAreaEditorFactory and do customization in java code
     */
    config.removePlugins = 'elementspath,maximize,resize,image,contextmenu';
    
    /*
     * 
     * We need to find a way to read this setting from java code.
     * Until then, Make sure the list here is in sync with the one mentioned in RichTextAreaEditorFactory.CKEditor.getRichTextEditorJavascript()
     */
    config.extraPlugins = 'sfdcImage,sfdcImagePaste,sfdcSwitchToText,iframedialog,MediaEmbed,smartLink';


    /*
     * Hide some dialog tabs:
     * - Image dialog: advanced and link tabs.
     * - Link dialog: advanced and target tabs
     */
    config.removeDialogTabs = 'link:advanced;table:advanced;tableProperties:advanced'; //  FCKConfig.ImageDlgHideLink;FCKConfig.ImageDlgHideAdvanced

    config.skin = 'sfdc';

    config.enterMode = CKEDITOR.ENTER_BR;
    config.shiftEnterMode = CKEDITOR.ENTER_P;
    config.forcePasteAsPlainText = false;
    config.forceSimpleAmpersand = true;

    // Salesforce specific entries (non-cke)
    config.imageUploadAllowedExtensions  = ".(jpg|gif|jpeg|png|bmp|jfif|jpe|pjpeg)$" ;
    config.imageUploadDeniedExtensions   = "" ;

    // Preserve formatting when pasting from word W-1709296
    config.pasteFromWordRemoveFontStyles = false;
    config.pasteFromWordRemoveStyles = false;

    // Workaround for ckeditor dialog bug( they are using global var i which screw up the global chain, cause config.plugins to be undefined. we will have to define it here)
    config.plugins = CKEDITOR.config.plugins;
};
