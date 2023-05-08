
//HEDGING EA 
#include <Trade\Trade.mqh>
CTrade         trade;
sinput string general = "";//general settings
input string eaname= "Hedge";
input int eamagic = 12345;

sinput string risksettings = "";//risk parameters
input double firtlot = 0.1;
input double firtlotmultiplier = 3;
input double morelotmultipler = 2;

sinput string exitsettings ="";//exit parameters
input int stoploss = 60;//risk parameters
input int takeprofit = 30 ;
input int hedgingdistance =30;

int oldnumbuy = 0,oldnumsell=0,oldnumofbars =0;
double ask,bid,stp,tkp,hd,fpl=0,pendingprice=0,nextlot =0;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   trade.SetExpertMagicNumber(eamagic);
   stp = stoploss *  10 *_Point;
   tkp = takeprofit* 10 *_Point;
   hd = hedgingdistance * 10 * _Point;
   fpl= firtlot * firtlotmultiplier;
   fpl =NormalizeDouble(fpl,2);
      

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
  if(newbarpresent())
    {
     
   ask =SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   bid =SymbolInfoDouble(_Symbol,SYMBOL_BID);
   
   if(PositionsTotal() == 0)
     {
      deletepending();
     }
   
   firstbuy();
   morependingbuy();
   morependingsell(); 
     
    }
   
   
   
  }
//+------------------------------------------------------------------+


void firstbuy()
   {
   
   if(PositionsTotal()==0)
     {
      if(!trade.Buy(firtlot,_Symbol,ask,ask-stp,ask+tkp,"first buy"))
         {
          return;
         }else
            {
             pendingprice = ask- hd;
             nextlot = fpl;
             firstpendingsell();
            }
     }
   }
   
void firstpendingsell(){

   trade.SellStop(nextlot,pendingprice,_Symbol,pendingprice+stp,pendingprice-tkp,ORDER_TIME_GTC,0,"first pendingsell");
   
   pendingprice =pendingprice + hd;
   nextlot = nextlot * morelotmultipler;
}


void morependingbuy(){


if(newsellpresent()&&numbuys() !=0 && numsells() !=0)
  {
   trade.BuyStop(nextlot,pendingprice,_Symbol,pendingprice-stp,pendingprice+tkp,ORDER_TIME_GTC,0,"more pendingbuy");
   pendingprice =pendingprice -hd;
   nextlot = nextlot *morelotmultipler;
  }

   
}


void morependingsell(){


if(newbuypresent()&&numbuys() !=0 && numsells() !=0)
  {
   trade.SellStop(nextlot,pendingprice,_Symbol,pendingprice + stp,pendingprice - tkp,ORDER_TIME_GTC,0,"more pendingsell");
   pendingprice =pendingprice +hd;
   nextlot = nextlot *morelotmultipler;
  }

   
} 


void deletepending()
   {
   for(int i=0;i<OrdersTotal();i++)
     {
     
     ulong orderTicket = OrderGetTicket(i);
     if(orderTicket != 0)
       {
        trade.OrderDelete(orderTicket);
        Print("order deleted");
       }
      
     }
   }
   

int numbuys()
   {
   int numofbuy =0;
   for(int i=0;i<PositionsTotal();i++)
     {
      if(!PositionSelectByTicket(PositionGetTicket(i)))
        continue; 
      if(PositionGetInteger(POSITION_MAGIC)!=eamagic)
         continue;
      if(PositionGetString(POSITION_SYMBOL)!=Symbol())
         continue;
      if(PositionGetInteger(POSITION_TYPE) !=POSITION_TYPE_BUY)
         continue;
         numofbuy++;
         
         }   
          
     return numofbuy;
   }  
   
   

////////////////////////////////////////////////////////////////////////////

int numsells()
   {
   int numofsells =0;
   for(int i=0;i<PositionsTotal();i++)
     {
      if(!PositionSelectByTicket(PositionGetTicket(i)))
        continue; 
      if(PositionGetInteger(POSITION_MAGIC)!=eamagic)
         continue;
      if(PositionGetString(POSITION_SYMBOL)!=Symbol())
         continue;
      if(PositionGetInteger(POSITION_TYPE) !=POSITION_TYPE_SELL)
         continue;
         numofsells++;
         
         }   
         return numofsells; 
     
   }  
   
   bool newbuypresent(){
   
   if(oldnumbuy != numbuys() ){
   oldnumbuy = numbuys();
   
   return true;
   
   }
    return false;
   } 
   
   
   
   
   bool newsellpresent(){
   
   if(oldnumsell != numsells() ){
   oldnumsell = numsells();
   
   return true;
   
   }
    return false;
   }   
   
   
    bool newbarpresent(){
   int bars= Bars(_Symbol,PERIOD_CURRENT);
   if(oldnumofbars != bars ){
   oldnumofbars = bars;
   
   return true;
   
   }
    return false;
   }        