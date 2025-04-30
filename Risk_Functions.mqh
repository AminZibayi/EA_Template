//+------------------------------------------------------------------+
//|               In the Name of Allah, the Originator, the Creative |
//|                                                     Template.mq5 |
//|                                    Copyright © 2024, Amin Zibayi |
//+------------------------------------------------------------------+


// Calculate a stop-loss price for an order.
double StopLoss(ENUM_ORDER_TYPE order_type, double open_price, string symbol = NULL)
  {
   // Use current symbol if no symbol provided
   if(symbol == NULL)
      symbol = Symbol();
      
   double StopLossPrice = 0;
   
   // Get the ATR value for this symbol
   double atr_value = GetSymbolATR(symbol);
   
   if(StopLossMode == SL_FIXED)  // Easy way.
     {
      if(DefaultStopLoss == 0)
         return 0;
      if(order_type == ORDER_TYPE_BUY)
        {
         StopLossPrice = open_price - DefaultStopLoss * SymbolInfoDouble(symbol, SYMBOL_POINT);
        }
      if(order_type == ORDER_TYPE_SELL)
        {
         StopLossPrice = open_price + DefaultStopLoss * SymbolInfoDouble(symbol, SYMBOL_POINT);
        }
     }
   else // Special cases.
     {
      if(order_type == ORDER_TYPE_BUY)
        {
         StopLossPrice = open_price - atr_value * ATRMultiplierSL;
        }
      else if(order_type == ORDER_TYPE_SELL)
        {
         StopLossPrice = open_price + atr_value * ATRMultiplierSL;
        }
     }
   return NormalizeDouble(StopLossPrice, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
  }

// Calculate the take-profit price for an order.
double TakeProfit(ENUM_ORDER_TYPE order_type, double open_price, string symbol = NULL)
  {
   // Use current symbol if no symbol provided
   if(symbol == NULL)
      symbol = Symbol();
   
   // Get the ATR value for this symbol
   double atr_value = GetSymbolATR(symbol);
      
   double TakeProfitPrice = 0;
   if(TakeProfitMode == TP_FIXED)  // Easy way.
     {
      if(DefaultTakeProfit == 0)
         return 0;
      if(order_type == ORDER_TYPE_BUY)
        {
         TakeProfitPrice = open_price + DefaultTakeProfit * SymbolInfoDouble(symbol, SYMBOL_POINT);
        }
      if(order_type == ORDER_TYPE_SELL)
        {
         TakeProfitPrice = open_price - DefaultTakeProfit * SymbolInfoDouble(symbol, SYMBOL_POINT);
        }
     }
   else // Special cases.
     {
      if(order_type == ORDER_TYPE_BUY)
        {
         TakeProfitPrice = open_price + atr_value * ATRMultiplierTP;
        }
      else if(order_type == ORDER_TYPE_SELL)
        {
         TakeProfitPrice = open_price - atr_value * ATRMultiplierTP;
        }
     }
   return NormalizeDouble(TakeProfitPrice, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
  }

// Calculate the position size for an order.
double LotSize(double stop_loss, double open_price, string symbol = NULL)
  {
   // Use current symbol if no symbol provided
   if(symbol == NULL)
      symbol = Symbol();
      
   double Size = DefaultLotSize;
   if(RiskDefaultSize == RISK_DEFAULT_AUTO)  // If the position size is dynamic.
     {
      if(stop_loss != 0)  // Calculate position size only if SL is non-zero, otherwise there will be a division by zero error.
        {
         double RiskBaseAmount = 0;
         // TickValue is the value of the individual price increment for 1 lot of the instrument expressed in the account currency.
         double TickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
         // Define the base for the risk calculation depending on the parameter chosen
         if(RiskBase == RISK_BASE_BALANCE)
            RiskBaseAmount = AccountBalance();
         else
            if(RiskBase == RISK_BASE_EQUITY)
               RiskBaseAmount = AccountEquity();
            else
               if(RiskBase == RISK_BASE_FREEMARGIN)
                  RiskBaseAmount = AccountFreeMargin();
                  
         // If we're using unified risk management, adjust risk based on active positions
         double riskMultiplier = 1.0;
         if(UseUnifiedRisk)
         {
            int totalOpenPositions = CountTotalPositions();
            if(totalOpenPositions > 0)
            {
               // Reduce risk as the number of positions increases
               riskMultiplier = 1.0 / (totalOpenPositions + 1);
            }
         }
                     
         double SL = MathAbs(open_price - stop_loss) / SymbolInfoDouble(symbol, SYMBOL_POINT); // SL as a number of points.
         // Calculate the Position Size.
         Size = (RiskBaseAmount * MaxRiskPerTrade / 100 * riskMultiplier) / (SL * TickValue);
        }
      // If the stop loss is zero, then use the default size.
      if(stop_loss == 0)
        {
         Size = DefaultLotSize;
        }
     }

   // Normalize the Lot Size to satisfy the allowed lot increment and minimum and maximum position size.
   double LotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   double MaxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double MinLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   Size = MathFloor(Size / LotStep) * LotStep;
   // Limit the lot size in case it is greater than the maximum allowed by the user.
   if(Size > MaxLotSize)
      Size = MaxLotSize;
   // Limit the lot size in case it is greater than the maximum allowed by the broker.
   if(Size > MaxLot)
      Size = MaxLot;
   // If the lot size is too small, then set it to 0 and don't trade.
   if((Size < MinLotSize) || (Size < MinLot))
      Size = 0;

   return Size;
  }

// Helper function to get the ATR value for a specific symbol
double GetSymbolATR(string symbol)
{
   // Try to find the symbol in the symbolsData array
   for(int i = 0; i < symbolsCount; i++)
   {
      if(symbolsData[i].name == symbol)
      {
         return symbolsData[i].ATR_previous;
      }
   }
   // If symbol not found, return 0 as fallback (no global ATR_previous)
   return 0;
}
