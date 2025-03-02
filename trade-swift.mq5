//+------------------------------------------------------------------+
//|                                              trade swift.mq5 |
//|                        Copyright 2025, chiTheDev. |
//|                                             https://www.x.com/chithedev |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Fair Value Gap Detector Expert Advisor"

input color BullishColor = clrLime;        // Bullish FVG color
input color BearishColor = clrRed;         // Bearish FVG color
input int   FVGWidth = 1;                 // FVG rectangle width
input bool  FillFVG = true;                // Fill FVG areas
input int   MaxBars = 500;                 // Max bars to check
input int   FutureBars = 5;                // Number of future bars for end time
input double LotSize = 0.1;                // Lot size for trades
input int   StopLossPoints = 100;          // Stop loss in points (0 to disable)
input int   TakeProfitPoints = 200;        // Take profit in points (0 to disable)
input int   MagicNumber = 123456;          // Magic number for EA trades
input int   FVGMinPoints = 300;             // Minimum FVG size in points to open a trade
input int   CandleBodyMinPoints = 300;      // Minimum candle body size in points to detect

datetime lastBarTime;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrade trade; // Create an instance of the CTrade class
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("FVG Detector EA initialized.");
   Print("Symbol: ", _Symbol, " | Timeframe: ", EnumToString(_Period));
   Print("Bullish FVG Color: ", BullishColor, " | Bearish FVG Color: ", BearishColor);
   Print("FVG Width: ", FVGWidth, " | Fill FVG: ", FillFVG, " | Max Bars: ", MaxBars, " | Future Bars: ", FutureBars);
   Print("Lot Size: ", LotSize, " | Stop Loss: ", StopLossPoints, " | Take Profit: ", TakeProfitPoints);
   Print("Magic Number: ", MagicNumber);
   Print("Minimum FVG Size: ", FVGMinPoints, " points");
   Print("Minimum Candle Body Size: ", CandleBodyMinPoints, " points");

// Set the magic number for the trade object
   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetAsyncMode(true);

// Initialize with current chart data
   lastBarTime = iTime(_Symbol, _Period, 0);
   Print("Last bar time initialized: ", lastBarTime);

// Scan historical bars
   CheckHistoricalFVG();

   Print("Initialization completed successfully");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// Check for new bar formation
   if(CheckNewBar())
     {
      Print("New bar detected at ", TimeToString(TimeCurrent()));
      CheckCurrentFVG();
     }
   CheckCandleBodySize();
  }


//+------------------------------------------------------------------+
//| Check for new bar function                                       |
//+------------------------------------------------------------------+
bool CheckNewBar()
  {
   datetime currentTime = iTime(_Symbol, _Period, 0);

   if(currentTime != lastBarTime)
     {
      Print("New bar formed. Previous bar time: ", lastBarTime, " | New bar time: ", currentTime);
      lastBarTime = currentTime;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Check historical FVG patterns                                    |
//+------------------------------------------------------------------+
void CheckHistoricalFVG()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, _Period, 0, MaxBars, rates);

   if(copied < 2)
     {
      Print("Not enough historical data to check FVG. Bars available: ", copied);
      return;
     }

   Print("Checking historical FVG patterns on ", copied, " bars");
   for(int i = copied-1; i >= 1; i--)
     {
      if(i >= ArraySize(rates)-1)
         continue;

      CheckFVGCondition(rates[i+1], rates[i]);
     }
   Print("Historical FVG scan completed");
  }

//+------------------------------------------------------------------+
//| Check current FVG formation                                      |
//+------------------------------------------------------------------+
void CheckCurrentFVG()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, _Period, 0, 2, rates);

   if(copied < 2)
     {
      Print("Not enough data to check current FVG. Bars available: ", copied);
      return;
     }

   Print("Checking current FVG formation");
   CheckFVGCondition(rates[1], rates[0]);
  }

//+------------------------------------------------------------------+
//| Check FVG conditions                                             |
//+------------------------------------------------------------------+
void CheckFVGCondition(MqlRates &current, MqlRates &previous)
  {
   datetime endTime = GetFutureBarTime(previous.time, FutureBars);

// Check Bullish FVG (gap up)
   if(previous.high < current.low)
     {
      double fvgSize = (current.low - previous.high) / _Point; // FVG size in points
      if(fvgSize >= FVGMinPoints)
        {
         Print("Bullish FVG detected: ", current.time, " to ", endTime, " | FVG Size: ", fvgSize, " points");
         DrawFVGRectangle(current.time, endTime, previous.high, current.low, BullishColor, "Bullish");
         CloseTradesWithMagicNumber(POSITION_TYPE_SELL); // Close only sell (bearish) trades
         OpenBuyTrade();
        }
      else
        {
         Print("Bullish FVG detected but size is too small: ", fvgSize, " points (Minimum: ", FVGMinPoints, " points)");
        }
     }

// Check Bearish FVG (gap down)
   if(previous.low > current.high)
     {
      double fvgSize = (previous.low - current.high) / _Point; // FVG size in points
      if(fvgSize >= FVGMinPoints)
        {
         Print("Bearish FVG detected: ", current.time, " to ", endTime, " | FVG Size: ", fvgSize, " points");
         DrawFVGRectangle(current.time, endTime, previous.low, current.high, BearishColor, "Bearish");
         CloseTradesWithMagicNumber(POSITION_TYPE_BUY); // Close only buy (bullish) trades
         OpenSellTrade();
        }
      else
        {
         Print("Bearish FVG detected but size is too small: ", fvgSize, " points (Minimum: ", FVGMinPoints, " points)");
        }
     }
  }


//+------------------------------------------------------------------+
//| Check candle body size and open trades accordingly               |
//+------------------------------------------------------------------+
void CheckCandleBodySize()
  {
// Retrieve the open, close, high, and low prices of the current candle
   const double openPrice = iOpen(_Symbol, _Period, 0);   // Open price of the current candle
   const double closePrice = iClose(_Symbol, _Period, 0); // Close price of the current candle
   const double lowPrice = iLow(_Symbol, _Period, 0);     // Low price of the current candle
   const double highPrice = iHigh(_Symbol, _Period, 0);   // High price of the current candle

// Check if the prices are valid
   if(openPrice <= 0 || closePrice <= 0 || lowPrice <= 0 || highPrice <= 0)
     {
      Print("Error: Invalid price data for the current candle.");
      return;
     }

// Calculate the candle body size in points
   const double candleBodySize = MathAbs(closePrice - openPrice) / _Point;

// Log the candle body size for debugging
   Print("Candle Body Size: ", candleBodySize, " points | Threshold: ", CandleBodyMinPoints, " points");

// Check if the candle body size meets the threshold
   if(candleBodySize >= CandleBodyMinPoints)
     {
      // Determine if the candle is bullish or bearish
      if(closePrice > openPrice) // Bullish candle
        {
         Print("Bullish candle detected: ", TimeCurrent(), " | Candle Body Size: ", candleBodySize, " points");
         CloseTradesWithMagicNumber(POSITION_TYPE_SELL); // Close only sell (bearish) trades
         OpenBuyTrade();
        }
      else
         if(closePrice < openPrice) // Bearish candle
           {
            Print("Bearish candle detected: ", TimeCurrent(), " | Candle Body Size: ", candleBodySize, " points");
            CloseTradesWithMagicNumber(POSITION_TYPE_BUY); // Close only buy (bullish) trades
            OpenSellTrade();
           }
     }
   else
     {
      Print("Candle body size is too small: ", candleBodySize, " points (Minimum: ", CandleBodyMinPoints, " points)");
     }
  }
//+------------------------------------------------------------------+
//| Draw a marker on the candle with a large body                    |
//+------------------------------------------------------------------+
void DrawCandleMarker(datetime time, double open, double close, double low, double high)
  {
   string name = "CandleMarker_" + IntegerToString(time);
   color markerColor = (close > open) ? clrLime : clrRed; // Green for bullish, Red for bearish

   if(ObjectFind(0, name) >= 0)
     {
      Print("Candle marker already exists: ", name);
      return; // Already exists
     }

   ObjectCreate(0, name, OBJ_ARROW_CHECK, 0, time, (close > open) ? low : high);
   ObjectSetInteger(0, name, OBJPROP_COLOR, markerColor);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);

   Print("Candle marker drawn: ", name, " | Time: ", time, " | Candle Body Size: ", MathAbs(close - open) / _Point, " points");
  }


//+------------------------------------------------------------------+
//| Close trades with the assigned magic number and specific type     |
//+------------------------------------------------------------------+
void CloseTradesWithMagicNumber(ENUM_POSITION_TYPE tradeType)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
         PositionGetInteger(POSITION_TYPE) == tradeType)
        {
         if(trade.PositionClose(ticket))
           {
            Print("Closed trade with ticket: ", ticket);
           }
         else
           {
            Print("Failed to close trade with ticket: ", ticket, ". Error: ", trade.ResultRetcode(), " - ", trade.ResultRetcodeDescription());
           }
        }
     }
   Print("All trades with magic number ", MagicNumber, " and type ", EnumToString(tradeType), " closed.");
  }

//+------------------------------------------------------------------+
//| Open Buy Trade                                                   |
//+------------------------------------------------------------------+
void OpenBuyTrade()
  {
// Check if a buy trade is already open
   if(IsTradeOpen(POSITION_TYPE_BUY))
     {
      Print("Buy trade already open. Skipping new buy trade.");
      return;
     }

   double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK); // Current Ask price
   double sl = 0; // Default stop loss (0 means no stop loss)
   double tp = 0; // Default take profit (0 means no take profit)

// Calculate stop loss if StopLossPoints is not 0
   if(StopLossPoints > 0)
     {
      sl = NormalizeDouble(askPrice - StopLossPoints * _Point, _Digits);
     }

// Calculate take profit if TakeProfitPoints is not 0
   if(TakeProfitPoints > 0)
     {
      tp = NormalizeDouble(askPrice + TakeProfitPoints * _Point, _Digits);
     }

// Open a buy trade using CTrade
   if(trade.Buy(LotSize, _Symbol, askPrice, sl, tp, "Bullish FVG Trade"))
     {
      Print("Buy trade opened successfully. Ticket: ", trade.ResultOrder());
     }
   else
     {
      Print("Failed to open Buy trade. Error: ", trade.ResultRetcode(), " - ", trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
//| Open Sell Trade                                                  |
//+------------------------------------------------------------------+
void OpenSellTrade()
  {
// Check if a sell trade is already open
   if(IsTradeOpen(POSITION_TYPE_SELL))
     {
      Print("Sell trade already open. Skipping new sell trade.");
      return;
     }

   double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID); // Current Bid price
   double sl = 0; // Default stop loss (0 means no stop loss)
   double tp = 0; // Default take profit (0 means no take profit)

// Calculate stop loss if StopLossPoints is not 0
   if(StopLossPoints > 0)
     {
      sl = NormalizeDouble(bidPrice + StopLossPoints * _Point, _Digits);
     }

// Calculate take profit if TakeProfitPoints is not 0
   if(TakeProfitPoints > 0)
     {
      tp = NormalizeDouble(bidPrice - TakeProfitPoints * _Point, _Digits);
     }

// Open a sell trade using CTrade
   if(trade.Sell(LotSize, _Symbol, bidPrice, sl, tp, "Bearish FVG Trade"))
     {
      Print("Sell trade opened successfully. Ticket: ", trade.ResultOrder());
     }
   else
     {
      Print("Failed to open Sell trade. Error: ", trade.ResultRetcode(), " - ", trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
//| Check if a trade of the specified type is already open           |
//+------------------------------------------------------------------+
bool IsTradeOpen(ENUM_POSITION_TYPE tradeType)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
         PositionGetInteger(POSITION_TYPE) == tradeType)
        {
         return true; // Trade of the specified type is already open
        }
     }
   return false; // No trade of the specified type is open
  }

//+------------------------------------------------------------------+
//| Get future bar time                                              |
//+------------------------------------------------------------------+
datetime GetFutureBarTime(datetime currentTime, int futureBars)
  {
   int barIndex = iBarShift(_Symbol, _Period, currentTime);
   int futureIndex = barIndex - futureBars;

   if(futureIndex >= 0)
     {
      return iTime(_Symbol, _Period, futureIndex);
     }

// If future bars are not available, calculate future time based on timeframe
   Print("Warning: Not enough future bars available. Calculating future time based on timeframe.");

// Get the duration of one bar in seconds
   int timeframeSeconds = GetTimeframeSeconds(_Period);

// Calculate future time by adding the duration of future bars
   datetime futureTime = currentTime + (futureBars * timeframeSeconds);

   return futureTime;
  }

//+------------------------------------------------------------------+
//| Get timeframe duration in seconds                                |
//+------------------------------------------------------------------+
int GetTimeframeSeconds(ENUM_TIMEFRAMES timeframe)
  {
   switch(timeframe)
     {
      case PERIOD_M1:
         return 60;          // 1 minute
      case PERIOD_M5:
         return 5 * 60;      // 5 minutes
      case PERIOD_M15:
         return 15 * 60;     // 15 minutes
      case PERIOD_M30:
         return 30 * 60;     // 30 minutes
      case PERIOD_H1:
         return 60 * 60;     // 1 hour
      case PERIOD_H4:
         return 4 * 60 * 60; // 4 hours
      case PERIOD_D1:
         return 24 * 60 * 60;// 1 day
      case PERIOD_W1:
         return 7 * 24 * 60 * 60; // 1 week
      case PERIOD_MN1:
         return 30 * 24 * 60 * 60; // 1 month (approximate)
      default:
         return 60;          // Default to 1 minute
     }
  }

//+------------------------------------------------------------------+
//| Draw FVG rectangle                                               |
//+------------------------------------------------------------------+
void DrawFVGRectangle(datetime startTime, datetime endTime,
                      double price1, double price2,
                      color clr, string type)
  {
   string name = "FVG_"+type+"_"+IntegerToString(startTime);

   if(ObjectFind(0, name) >= 0)
     {
      Print("FVG already exists: ", name);
      return; // Already exists
     }

   ObjectCreate(0, name, OBJ_RECTANGLE, 0, startTime, price1, endTime, price2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, FVGWidth);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_FILL, FillFVG);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);

   Print("FVG rectangle drawn: ", name, " | Start: ", startTime, " | End: ", endTime, " | Price1: ", price1, " | Price2: ", price2);
   Print("FVG rectangle drawn: ", name);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("FVG Detector EA Deinitialized. Reason: ", reason);
   DeleteFVGObjects();
  }

//+------------------------------------------------------------------+
//| Delete FVG objects                                               |
//+------------------------------------------------------------------+
void DeleteFVGObjects()
  {
   int obj_total = ObjectsTotal(0, 0, -1);
   Print("Deleting FVG objects. Total objects found: ", obj_total);

   for(int i = obj_total-1; i >= 0; i--)
     {
      string name = ObjectName(0, i);
      if(StringFind(name, "FVG_") == 0)
        {
         ObjectDelete(0, name);
         Print("Deleted FVG object: ", name);
        }
     }
   Print("FVG objects deletion completed");
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
