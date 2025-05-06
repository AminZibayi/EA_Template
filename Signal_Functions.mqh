//+------------------------------------------------------------------+
//|               In the Name of Allah, the Originator, the Creative |
//|                                                     Template.mq5 |
//|                                    Copyright © 2024, Amin Zibayi |
//+------------------------------------------------------------------+


// Initialize handles. Indicator handles have to be initialized at the beginning of the EA's operation.
bool InitializeHandles()
  {
   for(int i = 0; i < symbolsCount; i++)
     {
      string currentSymbol = symbolsData[i].name;
      
      // Setup main indicator handle for each symbol
      /*
      symbolsData[i].IndicatorHandle = iMA(currentSymbol, Period(), MA_Period, MA_Shift, MA_Mode, MA_Price);
      if (symbolsData[i].IndicatorHandle == INVALID_HANDLE)
      {
          PrintFormat("Unable to create main indicator handle for %s - %s - %d.", 
                     currentSymbol, GetLastErrorText(GetLastError()), GetLastError());
          return false;
      }
      */
      
      // Setup ATR handle for each symbol
      symbolsData[i].ATRHandle = iATR(currentSymbol, ATRTimeFrame, ATRPeriod);
      if(symbolsData[i].ATRHandle == INVALID_HANDLE)
        {
         PrintFormat("Unable to create ATR handle for %s - %s - %d.", 
                    currentSymbol, GetLastErrorText(GetLastError()), GetLastError());
         return false;
        }
     }
   return true;
  }


// Retrieve indicator data necessary for entry, update, and exit for a specific symbol.
bool GetIndicatorsData(string symbol)
  {
   // Find symbol index in the array
   int symbolIndex = -1;
   for(int i = 0; i < symbolsCount; i++)
     {
      if(symbolsData[i].name == symbol)
        {
         symbolIndex = i;
         break;
        }
     }
     
   // Symbol not found in our array
   if(symbolIndex == -1)
     {
      Print("Symbol ", symbol, " not found in symbolsData array");
      return false;
     }
     
   double buf[2]; // Needed for CopyBuffer().
   int count; // Will store the number of array elements returned by CopyBuffer().
   bool AllDataAvailable = false;
   int MaxAttemptsForData = 5;
   int DelayBetweenAttempts = 200; // Milliseconds.
   int Attempt = 0;

   while((!AllDataAvailable) && (Attempt < MaxAttemptsForData))
     {
      AllDataAvailable = true;

      count = CopyBuffer(symbolsData[symbolIndex].ATRHandle, 0, 0, 2, buf); // Copy using ATR indicator handle
      if((count < 2) || (buf[0] == NULL) || (buf[0] == EMPTY_VALUE))
        {
         Print("Unable to get ATR values for ", symbol);
         AllDataAvailable = false;
        }
      else
        {
         symbolsData[symbolIndex].ATR_current = buf[1];
         symbolsData[symbolIndex].ATR_previous = buf[0];
        }

      // This is where the main indicator data is read for each symbol
      // !! Uncomment and modify to use indicator values in your entry and exit signals
      /*
      count = CopyBuffer(symbolsData[symbolIndex].IndicatorHandle, 0, 1, 2, buf);
      if (count < 2)
      {
          Print("Main indicator buffer not ready yet for ", symbol);
          AllDataAvailable = false;
      }
      else
      {
          symbolsData[symbolIndex].Indicator_current = buf[1];
          symbolsData[symbolIndex].Indicator_previous = buf[0];
      }
      */

      Attempt++;
      Sleep(DelayBetweenAttempts);
     }

   if(!AllDataAvailable)
     {
      Print("Unable to get some data for the entry signal for ", symbol, ", skipping candle.");
      return false;
     }

   return true;
  }

// Entry signal for a specific symbol
void CheckEntrySignal(string symbol)
  {
   if((UseTradingHours) && (!IsCurrentTimeInInterval(TradingHourStart, TradingHourEnd)))
      return; // Trading hours restrictions for entry.

   bool BuySignal = false;
   bool SellSignal = false;

   // Check if the spread is acceptable for this symbol
   double currentSpread = (double)SymbolInfoInteger(symbol, SYMBOL_SPREAD);
   if(currentSpread > MaxSpread)
      return; // Spread too high, skip trading

   // Find symbol in the array to get its indicator data
   int symbolIndex = -1;
   for(int i = 0; i < symbolsCount; i++)
     {
      if(symbolsData[i].name == symbol)
        {
         symbolIndex = i;
         break;
        }
     }
     
   if(symbolIndex == -1) // Symbol not found in our array
      return;
     
   // Get the symbol's ATR value
   double atr_value = (symbolIndex >= 0) ? symbolsData[symbolIndex].ATR_previous : 0;

   // Buy signal conditions
   // This is where you should insert your entry signal for BUY orders.
   // Include a condition to open a buy order, the condition will have to set BuySignal to true or false.

   //!! Uncomment and modify this buy entry signal check line:
   //if ((symbolsData[symbolIndex].Indicator_current > iClose(symbol, Period(), 1)) && 
   //    (symbolsData[symbolIndex].Indicator_previous <= iClose(symbol, Period(), 2))) 
   //    BuySignal = true; // Check if the indicator's value crossed the Close price level from below.

   if(BuySignal)
     {
      OpenBuy(symbol);
     }

   // Sell signal conditions
   // This is where you should insert your entry signal for SELL orders.
   // Include a condition to open a sell order, the condition will have to set SellSignal to true or false.

   //!! Uncomment and modify this sell entry signal check line:
   //if ((symbolsData[symbolIndex].Indicator_current < iClose(symbol, Period(), 1)) && 
   //    (symbolsData[symbolIndex].Indicator_previous >= iClose(symbol, Period(), 2))) 
   //    SellSignal = true; // Check if the indicator's value crossed the Close price level from above.

   if(SellSignal)
     {
      OpenSell(symbol);
     }
  }

// Exit signal for a specific symbol
void CheckExitSignal(string symbol)
  {
   //!! if ((UseTradingHours) && (!IsCurrentTimeInInterval(TradingHourStart, TradingHourEnd))) return; // Trading hours restrictions for exit. Normally, you don't want to restrict exit by hours. Still, it's a possibility.

   bool SignalExitLong = false;
   bool SignalExitShort = false;
   
   // Find symbol in the array to get its indicator data
   int symbolIndex = -1;
   for(int i = 0; i < symbolsCount; i++)
     {
      if(symbolsData[i].name == symbol)
        {
         symbolIndex = i;
         break;
        }
     }
     
   if(symbolIndex == -1) // Symbol not found in our array
      return;

   //!! Uncomment and modify these exit signal checks:
   //if ((symbolsData[symbolIndex].Indicator_current > iClose(symbol, Period(), 1)) && 
   //    (symbolsData[symbolIndex].Indicator_previous <= iClose(symbol, Period(), 2))) 
   //    SignalExitShort = true; // Check if the indicator's value crossed the Close price level from below.
   //else if ((symbolsData[symbolIndex].Indicator_current < iClose(symbol, Period(), 1)) && 
   //         (symbolsData[symbolIndex].Indicator_previous >= iClose(symbol, Period(), 2))) 
   //    SignalExitLong = true; // Check if the indicator's value crossed the Close price level from above.

   if(SignalExitLong)
      CloseAllBuy(symbol);
   if(SignalExitShort)
      CloseAllSell(symbol);
  }
  
  // Partially close all positions opened by this EA for a specific symbol
void CheckPartialClose(string symbol = NULL)
  {
   // Use current symbol if no symbol provided
   if(symbol == NULL)
      symbol = Symbol();
      
   // Find the symbol index for ATR values
   int symbolIdx = -1;
   for(int i = 0; i < symbolsCount; i++)
     {
      if(symbolsData[i].name == symbol)
        {
         symbolIdx = i;
         break;
        }
     }
   
   // Get the symbol's ATR value
   double atr_value = (symbolIdx >= 0) ? symbolsData[symbolIdx].ATR_previous : 0;
   
   // Get pip value for this symbol
   double pipValue = SymbolInfoDouble(symbol, SYMBOL_POINT) * 10;
      
   int total = PositionsTotal();

   // Start a loop to scan all the positions.
   // The loop starts from the last, otherwise it could skip positions.
   for(int i = total - 1; i >= 0; i--)
     {
      // If the position cannot be selected log an error.
      if(PositionGetSymbol(i) == "")
        {
         Print(__FUNCTION__, ": ERROR - Unable to select the position - ", GetLastError());
         continue;
        }
      if(PositionGetString(POSITION_SYMBOL) != symbol)
         continue; // Only close specified symbol trades.
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber)
         continue; // Only close own positions.

      int position_ticket = (int)PositionGetInteger(POSITION_TICKET);

      // Retrieve the history of deals and orders for that position to check if it hasn't been already partially closed.
      if(!HistorySelectByPosition(PositionGetInteger(POSITION_IDENTIFIER)))
        {
         PrintFormat("ERROR - Unable to get position history for %d - %s - %d", position_ticket, GetLastErrorText(GetLastError()), GetLastError());
         continue;
        }

      bool need_partial_close = true;
      bool condition_met = false;

      // Process partial close for a long position.
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         for(int j = HistoryDealsTotal() - 1; j >= 0; j--)
           {
            long deal_ticket = (int)HistoryDealGetTicket(j);
            if(!deal_ticket)
              {
               PrintFormat("Unable to get deal for %d - %s - %d", position_ticket, GetLastErrorText(GetLastError()), GetLastError());
               break;
              }
            if(HistoryDealGetInteger(deal_ticket, DEAL_TYPE) == DEAL_TYPE_SELL)  // Looks like this long position has already been partially closed at least once.
              {
               need_partial_close = false;
               break; // No need to partially close this position.
              }
           }
           
         // Check partial close condition based on selected mode
         if(PartialCloseMode == PC_ATR)
         {
            // ATR-based partial close for long positions
            if(SymbolInfoDouble(symbol, SYMBOL_BID) - PositionGetDouble(POSITION_PRICE_OPEN) > atr_value * ATRMultiplierPC)
               condition_met = true;
         }
         else
         {
            // Fixed pips partial close for long positions
            if(SymbolInfoDouble(symbol, SYMBOL_BID) - PositionGetDouble(POSITION_PRICE_OPEN) > FixedPipsPC * pipValue)
               condition_met = true;
         }
         
         // Apply partial close if conditions are met
         if(need_partial_close && condition_met)
           {
            if(PartialClose(position_ticket, PartialClosePerc))
               PrintFormat("Partially closed BUY position #%d on %s by %g%%", position_ticket, symbol, PartialClosePerc);
           }
        }
      // Process partial close for a short position.
      else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
         for(int j = HistoryDealsTotal() - 1; j >= 0; j--)
           {
            long deal_ticket = (int)HistoryDealGetTicket(j);
            if(!deal_ticket)
              {
               PrintFormat("Unable to get deal for %d - %s - %d", position_ticket, GetLastErrorText(GetLastError()), GetLastError());
               return;
              }
            if(HistoryDealGetInteger(deal_ticket, DEAL_TYPE) == DEAL_TYPE_BUY)  // Looks like this short position has already been partially closed at least once.
              {
               need_partial_close = false;
               break; // No need to partially close this position.
              }
           }
           
         // Check partial close condition based on selected mode
         if(PartialCloseMode == PC_ATR)
         {
            // ATR-based partial close for short positions
            if(PositionGetDouble(POSITION_PRICE_OPEN) - SymbolInfoDouble(symbol, SYMBOL_ASK) > atr_value * ATRMultiplierPC)
               condition_met = true;
         }
         else
         {
            // Fixed pips partial close for short positions
            if(PositionGetDouble(POSITION_PRICE_OPEN) - SymbolInfoDouble(symbol, SYMBOL_ASK) > FixedPipsPC * pipValue)
               condition_met = true;
         }
           
         // Apply partial close if conditions are met
         if(need_partial_close && condition_met)
           {
            if(PartialClose(position_ticket, PartialClosePerc))
               PrintFormat("Partially closed SELL position #%d on %s by %g%%", position_ticket, symbol, PartialClosePerc);
           }
        }
     }
  }
//+------------------------------------------------------------------+
