Global with sharing class buildurl {   

       global static string getpic(string url){  
            
            Http h = new Http();
    
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod('GET');
    
            HttpResponse res = h.send(req);
            string coor = res.getBody().trim();
            
            List<String> parts = coor.split(',',4);
            coor = parts[2] + ',' + parts[3];
            
            string pic = 'http://chart.apis.google.com/chart?cht=qr&chs=200x200&chl=geo:' + coor ;
            
            return pic;
            }
            
}