//+------------------------------------------------------------------+
//|               In the Name of Allah, the Originator, the Creative |
//|                                                     Template.mq5 |
//|                                    Copyright © 2024, Amin Zibayi |
//+------------------------------------------------------------------+

// Count all open positions for the current symbol.
int CountPositions()
  {
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
         if(Instrument != Symbol())
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


// Open a position with a buy order.
bool OpenBuy()
  {
   double Ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double Bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double OpenPrice = Ask; // Buy at Ask.
   double StopLossPrice = StopLoss(ORDER_TYPE_BUY, OpenPrice); // Calculate SL based on direction, price, and SL rules.
   double TakeProfitPrice = TakeProfit(ORDER_TYPE_BUY, OpenPrice); // Calculate TP based on direction, price, and TP rules.
   double Size = LotSize(StopLossPrice, OpenPrice); // Calculate position size based on the SL, price, and the given rules.
// Use the standard Trade object to open the position with calculated parameters.
   if(!Trade.Buy(Size, Symbol(), OpenPrice, StopLossPrice, TakeProfitPrice))
     {
      PrintFormat("Unable to open BUY: %s - %d", Trade.ResultRetcodeDescription(), Trade.ResultRetcode());
      return false;
     }
   return true;
  }

// Open a position with a sell order.
bool OpenSell()
  {
   double Ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double Bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double OpenPrice = Bid; // Sell at Bid.
   double StopLossPrice = StopLoss(ORDER_TYPE_SELL, OpenPrice); // Calculate SL based on direction, price, and SL rules.
   double TakeProfitPrice = TakeProfit(ORDER_TYPE_SELL, OpenPrice); // Calculate TP based on direction, price, and TP rules.
   double Size = LotSize(StopLossPrice, OpenPrice); // Calculate position size based on the SL, price, and the given rules.
// Use the standard Trade object to open the position with calculated parameters.
   if(!Trade.Sell(Size, Symbol(), OpenPrice, StopLossPrice, TakeProfitPrice))
     {
      PrintFormat("Unable to open SELL: %s - %d", Trade.ResultRetcodeDescription(), Trade.ResultRetcode());
      return false;
     }
   return true;
  }


// Close the specified position completely.
//!! Unused. Can be uncommented and used to close specific positions.
/* bool ClosePosition(ulong ticket)
{
    if (!Trade.PositionClose(ticket))
    {
        PrintFormat(__FUNCTION__, ": ERROR - Unable to close position: %s - %d", Trade.ResultRetcodeDescription(), Trade.ResultRetcode());
        return false;
    }
    return true;
}*/

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllSell()
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
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue; // Only close current symbol trades.
      if(PositionGetInteger(POSITION_TYPE) != POSITION_TYPE_SELL)
         continue; // Only close Sell positions.
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber)
         continue; // Only close own positions.

      for(int try
             = 0; try
                < 10; try
                   ++)
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
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllBuy()
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
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue; // Only close current symbol trades.
      if(PositionGetInteger(POSITION_TYPE) != POSITION_TYPE_BUY)
         continue; // Only close Buy positions.
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber)
         continue; // Only close own positions.

      for(int try
             = 0; try
                < 10; try
                   ++)
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


// Close all positions opened by this EA.
void CloseAllPositions()
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
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue; // Only close current symbol trades.
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber)
         continue; // Only close own positions.

      for(int try
             = 0; try
                < 10; try
                   ++)
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
   double Size = OriginalSize * percentage / 100;
   double LotStep = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
   double MaxLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
   double MinLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
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


// Partially close all positions opened by this EA.
void PartialCloseAll()
  {
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
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue; // Only close current symbol trades.
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
         if((need_partial_close) && (SymbolInfoDouble(Symbol(), SYMBOL_BID) - PositionGetDouble(POSITION_PRICE_OPEN) > ATR_previous * ATRMultiplierPC))
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
            if((need_partial_close) && (PositionGetDouble(POSITION_PRICE_OPEN) - SymbolInfoDouble(Symbol(), SYMBOL_ASK) > ATR_previous * ATRMultiplierPC))
              {
               PartialClose(position_ticket, PartialClosePerc);
              }
            return;
           }
     }
  }
//+------------------------------------------------------------------+
