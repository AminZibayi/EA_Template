//+------------------------------------------------------------------+
//|               In the Name of Allah, the Originator, the Creative |
//|                                                     Template.mq5 |
//|                                    Copyright © 2024, Amin Zibayi |
//+------------------------------------------------------------------+

// Count all open positions for a specific symbol
int CountPositions(string symbol = NULL)
  {
   // Use current symbol if no symbol provided
   if(symbol == NULL)
      symbol = Symbol();
      
   int count = 0;
   int TotalPositions = PositionsTotal();
   for(int i = 0; i < TotalPositions; i++)
     {
      string Instrument = PositionGetSymbol(i);
      if(Instrument == "")
        {
         PrintFormat(__FUNCTION__, ": ERROR - Unable to select the position - %s - %d.", GetLastErrorText(GetLastError()), GetLastError());
        }
      else
        {
         // Skip positions in other symbols.
         if(Instrument != symbol)
            continue;
         // Skip counting positions with a different Magic number if the EA has non-zero Magic number set.
         if((MagicNumber != 0) && (PositionGetInteger(POSITION_MAGIC) != MagicNumber))
            continue;
         count++;
        }
     }
   return count;
  }

// Set the basic parameters of the Trade object.
void SetTradeObject()
  {
   // All future trade operations will take into account these parameters - Magic number and deviation/slippage.
   Trade.SetExpertMagicNumber(MagicNumber);
   Trade.SetDeviationInPoints(Slippage);
  }


// Open a position with a buy order for a specific symbol
bool OpenBuy(string symbol = NULL)
  {
   // Use current symbol if no symbol provided
   if(symbol == NULL)
      symbol = Symbol();
      
   double Ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double Bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double OpenPrice = Ask; // Buy at Ask.
   
   // Calculate stop loss and take profit using symbol-specific data from globals
   double StopLossPrice = StopLoss(ORDER_TYPE_BUY, OpenPrice, symbol);
   double TakeProfitPrice = TakeProfit(ORDER_TYPE_BUY, OpenPrice, symbol);
   double Size = LotSize(StopLossPrice, OpenPrice, symbol);

   // Use the standard Trade object to open the position with calculated parameters.
   if(!Trade.Buy(Size, symbol, OpenPrice, StopLossPrice, TakeProfitPrice, OrderNote))
     {
      PrintFormat("Unable to open BUY on %s: %s - %d", symbol, Trade.ResultRetcodeDescription(), Trade.ResultRetcode());
      return false;
     }
   return true;
  }

// Open a position with a sell order for a specific symbol
bool OpenSell(string symbol = NULL)
  {
   // Use current symbol if no symbol provided
   if(symbol == NULL)
      symbol = Symbol();
      
   double Ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double Bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double OpenPrice = Bid; // Sell at Bid.
   
   // Calculate stop loss and take profit using symbol-specific data from globals
   double StopLossPrice = StopLoss(ORDER_TYPE_SELL, OpenPrice, symbol);
   double TakeProfitPrice = TakeProfit(ORDER_TYPE_SELL, OpenPrice, symbol);
   double Size = LotSize(StopLossPrice, OpenPrice, symbol);

   // Use the standard Trade object to open the position with calculated parameters.
   if(!Trade.Sell(Size, symbol, OpenPrice, StopLossPrice, TakeProfitPrice, OrderNote))
     {
      PrintFormat("Unable to open SELL on %s: %s - %d", symbol, Trade.ResultRetcodeDescription(), Trade.ResultRetcode());
      return false;
     }
   return true;
  }


// Close the specified position completely.
bool ClosePosition(ulong ticket)
{
    if (!Trade.PositionClose(ticket))
    {
        PrintFormat(__FUNCTION__, ": ERROR - Unable to close position: %s - %d", Trade.ResultRetcodeDescription(), Trade.ResultRetcode());
        return false;
    }
    return true;
}

//+------------------------------------------------------------------+
//| Close all sell positions for a specific symbol                   |
//+------------------------------------------------------------------+
void CloseAllSell(string symbol = NULL)
  {
   // Use current symbol if no symbol provided
   if(symbol == NULL)
      symbol = Symbol();
      
   int total = PositionsTotal();

   // Start a loop to scan all the positions.
   // The loop starts from the last, otherwise it could skip positions.
   for(int i = total - 1; i >= 0; i--)
     {
      // If the position cannot be selected log an error.
      if(PositionGetSymbol(i) == "")
        {
         PrintFormat(__FUNCTION__, ": ERROR - Unable to select the position - %s - %d.", GetLastErrorText(GetLastError()), GetLastError());
         continue;
        }
      if(PositionGetString(POSITION_SYMBOL) != symbol)
         continue; // Only close specified symbol trades.
      if(PositionGetInteger(POSITION_TYPE) != POSITION_TYPE_SELL)
         continue; // Only close Sell positions.
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber)
         continue; // Only close own positions.

      for(int try = 0; try < 10; try++)
        {
         bool result = Trade.PositionClose(PositionGetInteger(POSITION_TICKET));
         if(!result)
           {
            PrintFormat(__FUNCTION__, ": ERROR - Unable to close position: %s - %d", Trade.ResultRetcodeDescription(), Trade.ResultRetcode());
           }
         else
            break;
        }
     }
  }

//+------------------------------------------------------------------+
//| Close all buy positions for a specific symbol                    |
//+------------------------------------------------------------------+
void CloseAllBuy(string symbol = NULL)
  {
   // Use current symbol if no symbol provided
   if(symbol == NULL)
      symbol = Symbol();
      
   int total = PositionsTotal();

   // Start a loop to scan all the positions.
   // The loop starts from the last, otherwise it could skip positions.
   for(int i = total - 1; i >= 0; i--)
     {
      // If the position cannot be selected log an error.
      if(PositionGetSymbol(i) == "")
        {
         PrintFormat(__FUNCTION__, ": ERROR - Unable to select the position - %s - %d.", GetLastErrorText(GetLastError()), GetLastError());
         continue;
        }
      if(PositionGetString(POSITION_SYMBOL) != symbol)
         continue; // Only close specified symbol trades.
      if(PositionGetInteger(POSITION_TYPE) != POSITION_TYPE_BUY)
         continue; // Only close Buy positions.
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber)
         continue; // Only close own positions.

      for(int try = 0; try < 10; try++)
        {
         bool result = Trade.PositionClose(PositionGetInteger(POSITION_TICKET));
         if(!result)
           {
            PrintFormat(__FUNCTION__, ": ERROR - Unable to close position: %s - %d", Trade.ResultRetcodeDescription(), Trade.ResultRetcode());
           }
         else
            break;
        }
     }
  }


// Close all positions opened by this EA for a specific symbol or all symbols
void CloseAllPositions(string symbol = NULL)
  {
   int total = PositionsTotal();

   // Start a loop to scan all the positions.
   // The loop starts from the last, otherwise it could skip positions.
   for(int i = total - 1; i >= 0; i--)
     {
      // If the position cannot be selected log an error.
      if(PositionGetSymbol(i) == "")
        {
         PrintFormat(__FUNCTION__, ": ERROR - Unable to select the position - %s - %d.", GetLastErrorText(GetLastError()), GetLastError());
         continue;
        }
        
      // If symbol is provided, only close positions for that symbol
      if(symbol != NULL && PositionGetString(POSITION_SYMBOL) != symbol)
         continue;
         
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber)
         continue; // Only close own positions.

      for(int try = 0; try < 10; try++)
        {
         bool result = Trade.PositionClose(PositionGetInteger(POSITION_TICKET));
         if(!result)
           {
            PrintFormat(__FUNCTION__, ": ERROR - Unable to close position: %s - %d", Trade.ResultRetcodeDescription(), Trade.ResultRetcode());
           }
         else
            break;
        }
     }
  }

// Partially close a position with a given ticket.
bool PartialClose(ulong ticket, double percentage)
  {
   if(!PositionSelectByTicket(ticket))
     {
      PrintFormat("ERROR - Unable to select position by ticket #%d: %s - %d", ticket, GetLastErrorText(GetLastError()), GetLastError());
      return false;
     }
   double OriginalSize = PositionGetDouble(POSITION_VOLUME);
   string symbol = PositionGetString(POSITION_SYMBOL);
   double Size = OriginalSize * percentage / 100;
   double LotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   double MaxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double MinLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   Size = MathFloor(Size / LotStep) * LotStep;
   if(Size < MinLot)
      return false;
   if(!Trade.PositionClosePartial(ticket, Size))
     {
      PrintFormat("ERROR - Unable to partially close position #%d: %s - %d", ticket, Trade.ResultRetcodeDescription(), Trade.ResultRetcode());
      return false;
     }
   return true;
  }


// Partially close all positions opened by this EA for a specific symbol
void PartialCloseAll(string symbol = NULL)
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
         // Condition for partial close of a long position.
         if((need_partial_close) && (SymbolInfoDouble(symbol, SYMBOL_BID) - PositionGetDouble(POSITION_PRICE_OPEN) > atr_value * ATRMultiplierPC))
           {
            PartialClose(position_ticket, PartialClosePerc);
           }
        }
      // Process partial close for a short position.
      else
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
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
            // Condition for partial close of a short position.
            if((need_partial_close) && (PositionGetDouble(POSITION_PRICE_OPEN) - SymbolInfoDouble(symbol, SYMBOL_ASK) > atr_value * ATRMultiplierPC))
              {
               PartialClose(position_ticket, PartialClosePerc);
              }
            return;
           }
     }
  }

// Move stop loss to breakeven when position is in profit for a specific symbol
void MoveToBreakeven(string symbol = NULL)
  {
   // Use current symbol if no symbol provided
   if(symbol == NULL)
      symbol = Symbol();
      
   if(!UseBreakeven) // Skip if breakeven feature is disabled
      return;
      
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

   int total = PositionsTotal();
   
   // Get point to pip conversion factor
   double pipValue = SymbolInfoDouble(symbol, SYMBOL_POINT) * 10;
   
   // Loop through all positions
   for(int i = 0; i < total; i++)
     {
      // If the position cannot be selected, log an error
      if(PositionGetSymbol(i) == "")
        {
         PrintFormat(__FUNCTION__, ": ERROR - Unable to select the position - %s - %d.", GetLastErrorText(GetLastError()), GetLastError());
         continue;
        }
      
      // Skip positions that are not for the specified symbol
      if(PositionGetString(POSITION_SYMBOL) != symbol)
         continue;
         
      // Skip positions with a different Magic number
      if((MagicNumber != 0) && (PositionGetInteger(POSITION_MAGIC) != MagicNumber))
         continue;
      
      ulong ticket = PositionGetInteger(POSITION_TICKET);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSL = PositionGetDouble(POSITION_SL);
      double breakeven = openPrice; // Basic breakeven level
      bool moveToBreakeven = false;
      
      // If buffer is defined, add it to ensure a small profit (convert pips to points)
      if(BreakevenBuffer > 0)
        {
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            breakeven += BreakevenBuffer * pipValue;
         else
            breakeven -= BreakevenBuffer * pipValue;
        }
      
      // Check if we're in enough profit to move to breakeven based on the selected mode
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         if(BreakevenMode == BE_ATR)
           {
            // ATR-based breakeven for BUY positions
            if(SymbolInfoDouble(symbol, SYMBOL_BID) > openPrice + atr_value * BreakevenATRMultiplier)
               moveToBreakeven = true;
           }
         else
           {
            // Fixed pips breakeven for BUY positions - convert pips to points
            if(SymbolInfoDouble(symbol, SYMBOL_BID) > openPrice + FixedBreakevenPips * pipValue)
               moveToBreakeven = true;
           }
         
         // Apply breakeven if conditions are met
         if(moveToBreakeven && (currentSL < breakeven || currentSL == 0))
           {
            if(!Trade.PositionModify(ticket, breakeven, PositionGetDouble(POSITION_TP)))
               PrintFormat("ERROR - Unable to modify position to breakeven #%d: %s - %d", ticket, Trade.ResultRetcodeDescription(), Trade.ResultRetcode());
            else
               PrintFormat("Moved position #%d to breakeven at %f on %s", ticket, breakeven, symbol);
           }
        }
      else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
         if(BreakevenMode == BE_ATR)
           {
            // ATR-based breakeven for SELL positions
            if(SymbolInfoDouble(symbol, SYMBOL_ASK) < openPrice - atr_value * BreakevenATRMultiplier)
               moveToBreakeven = true;
           }
         else
           {
            // Fixed pips breakeven for SELL positions - convert pips to points
            if(SymbolInfoDouble(symbol, SYMBOL_ASK) < openPrice - FixedBreakevenPips * pipValue)
               moveToBreakeven = true;
           }
         
         // Apply breakeven if conditions are met
         if(moveToBreakeven && (currentSL > breakeven || currentSL == 0))
           {
            if(!Trade.PositionModify(ticket, breakeven, PositionGetDouble(POSITION_TP)))
               PrintFormat("ERROR - Unable to modify position to breakeven #%d: %s - %d", ticket, Trade.ResultRetcodeDescription(), Trade.ResultRetcode());
            else
               PrintFormat("Moved position #%d to breakeven at %f on %s", ticket, breakeven, symbol);
           }
        }
     }
  }
//+------------------------------------------------------------------+

