//+------------------------------------------------------------------+
//|                                                      Account.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#define LICENSE_AUTHENTICATION_ENDPOINT "http://examples.com/api/login"

#include<json.mqh>

int g_verbose=0;

bool CheckLicense()
{
   string result_text = ReceiveTokenFromServer(LICENSE_AUTHENTICATION_ENDPOINT,AccountNumber());


   JSONParser *parser = new JSONParser();

   JSONValue *jv = parser.parse(result_text);

   if (jv == NULL) {
      Print("error:"+(string)parser.getErrorCode()+parser.getErrorMessage());
      delete jv;
      delete parser;
      return(false);
   }
   else
   {
      if (g_verbose==2) Print("PARSED:"+jv.toString());
      if (g_verbose==2) Print("jv.isObject()=",jv.isObject());
      if (jv.isObject())
      { // check root value is an object. (it can be an array)

         JSONObject *jo = jv;
         string token="";
         if(jo.getString("token",token))
         {
            if (g_verbose==1) Print("toke = "+token);
            delete jo;
            delete jv;
            delete parser;
            return(true);
         }
         else
         {
            delete jo;
            delete jv;
            delete parser;
            return(false);
         }
         // Direct access - will throw null pointer if wrong getter used.
         //Print(jo.getString("token"));
         delete jo;
         delete jv;
         delete parser;
         return(true);
      }
      else
      {
         delete jv;
         delete parser;
         return(false);
      }
      delete jv;
      delete parser;
      return(false);
   }
   delete parser;
}

string ReceiveTokenFromServer(string url,int account_no)
{
   char data[], result[];
   string   cookies        = "";
   string   headers        = "Content-Type: application/json\r\n";
   int      timeout        = 10000;
   string   result_headers = NULL;
   string account_no_str = IntegerToString(AccountNumber());
   string json_text = "{\"account_no\":\"" + account_no_str + "\"}";

   StringToCharArray(json_text, data, 0, StringLen(json_text));

   uint timer = GetTickCount();
   uint elapsed_time = 0;
   int res = WebRequest("POST", url, headers, timeout, data, result, result_headers);
   elapsed_time = GetTickCount() - timer;
   string elapsed_time_text = "Post request takes " + IntegerToString(elapsed_time) + "msec";
   if(res==-1)
   {
      Print("Error in WebRequest. Error code  =",GetLastError());
   }
   else
   {
      string result_text = StringConcatenate(CharArrayToString(result,0,ArraySize(result)));
      int replaced = StringReplace(result_text,"\"","");
      if (g_verbose==2) Print("Res: "+ IntegerToString(res));
      if (g_verbose==2) Print("Server Response: " + CharArrayToString(result,0,ArraySize(result)));
      if (g_verbose==2) Print("Server Response Headers: " + result_headers);
      if (g_verbose==2) Print(elapsed_time_text);
      string notification_text = StringConcatenate(CharArrayToString(data,0,ArraySize(data)),"\r\n",CharArrayToString(result,0,ArraySize(result)),"\r\n",result_headers," Posting request elapsed ",elapsed_time,"ms","\r\n");
      bool a = SendNotification(notification_text);
   }
   return CharArrayToString(result,0,ArraySize(result));
}