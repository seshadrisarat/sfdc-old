/**
 * Inline VisualForce Expander
 * http://www.inetindustry.com/
 * Copyright(c) 2011, Dmitri Sennikov, dmitri@inetindustry.com.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
 
public with sharing class InlineVFExpanderController {
    public List<String> inlineVFPages {
        get {
            List<String> inlineVFPages = new List<String>();
 
            for (InlineVFExpander_Pages__c pageRecord : InlineVFExpander_Pages__c.getAll().values())
                inlineVFPages.add(pageRecord.Page_Id__c);
            return inlineVFPages;
        }
        set;
    }
    
    public static testMethod void testMyController() {
        String testPageName = 'MyCustomPage';
        String testPageID = '066123456789012';
        InlineVFExpander_Pages__c customVFPage = new InlineVFExpander_Pages__c();
        customVFPage.name = testPageName;
        customVFPage.Page_Id__c = testPageID;
        insert customVFPage;
        
        PageReference pageRef = Page.InlineVFExpander;
        Test.setCurrentPage(pageRef);
      
        InlineVFExpanderController controller = new InlineVFExpanderController();
        List<String> pages = controller.inlineVFPages;
        for (String pageID : pages)
        {
            if (pageID == testPageID)
            {
                System.assertEquals(testPageID,pageID,'Test page ID not found');
                return;
            }
        }
        System.assert(false, 'Test page ID not found');
    }
}