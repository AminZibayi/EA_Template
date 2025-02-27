//+------------------------------------------------------------------+
//|               In the Name of Allah, the Originator, the Creative |
//|                                                     Template.mq5 |
//|                                    Copyright © 2024, Amin Zibayi |
//+------------------------------------------------------------------+


// Initialize handles. Indicator handles have to be initialized at the beginning of the EA's operation.
bool InitializeHandles()
  {
// Indicator handle is the main handle for the signal generating indicator.
   /*IndicatorHandle = iMA(Symbol(), Period(), MA_Period, MA_Shift, MA_Mode, MA_Price);
   if (IndicatorHandle == INVALID_HANDLE)
   {
       PrintFormat("Unable to create main indicator handle - %s - %d.", GetLastErrorText(GetLastError()), GetLastError());
       return false;
   }*/
// ATR handle for stop-loss and take-profit.
   ATRHandle = iATR(Symbol(), ATRTimeFrame, ATRPeriod);
   if(ATRHandle == INVALID_HANDLE)
     {
      PrintFormat("Unable to create ATR handle - %s - %d.", GetLastErrorText(GetLastError()), GetLastError());
      return false;
     }
   return true;
  }


// Retrieve indicator data necessary for entry, update, and exit.
// Boolean type, so it can return true if all the data is available or false if it is not.
// Other advantage of this function is to move part of repetitive code into one location to make it leaner.
bool GetIndicatorsData()
  {
   double buf[2]; // Needed for CopyBuffer().
   int count; // Will store the number of array elements returned by CopyBuffer().
   bool AllDataAvailable = false;
   int MaxAttemptsForData = 5;
   int DelayBetweenAttempts = 200; // Milliseconds.
   int Attempt = 0;

   while((!AllDataAvailable) && (Attempt < MaxAttemptsForData))
     {
      AllDataAvailable = true;

      count = CopyBuffer(ATRHandle, 0, 0, 2, buf); // Copy using ATR indicator handle 2 latest values from 0th buffer to the buf array.
      if((count < 2) || (buf[0] == NULL) || (buf[0] == EMPTY_VALUE))
        {
         Print("Unable to get ATR values.");
         AllDataAvailable = false;
        }
      else
        {
         ATR_current = buf[1];
         ATR_previous = buf[0];
        }

      // This is where the main indicator data is read.
      // !! Uncomment and modify to use indicator values in your entry and exit signals
      /*count = CopyBuffer(IndicatorHandle, 0, 1, 2, buf); // Copying using main indicator handle 2 latest completed candles (hence starting from the 1st, and not 0th, candle) from 0th buffer to the buf array.
      if (count < 2)
      {
          Print("Main indicator buffer not ready yet.");
          AllDataAvailable = false;
      }
      else
      {
          Indicator_current = buf[1];
          Indicator_previous = buf[0];
      }*/

      Attempt++;
      Sleep(DelayBetweenAttempts);
     }

   if(!AllDataAvailable)
     {
      Print("Unable to get some data for the entry signal, skipping candle.");
      return false;
     }

   return true;
  }

// Entry signal
void CheckEntrySignal()
  {
   if((UseTradingHours) && (!IsCurrentTimeInInterval(TradingHourStart, TradingHourEnd)))
      return; // Trading hours restrictions for entry.

   bool BuySignal = false;
   bool SellSignal = false;

// Buy signal conditions

// This is where you should insert your entry signal for BUY orders.
// Include a condition to open a buy order, the condition will have to set BuySignal to true or false.

//!! Uncomment and modify this buy entry signal check line:
//if ((Indicator_current > iClose(Symbol(), Period(), 1)) && (Indicator_previous <= iClose(Symbol(), Period(), 2))) BuySignal = true; // Check if the indicator's value crossed the Close price level from below.

   if(BuySignal)
     {
      OpenBuy();
     }

// Sell signal conditions

// This is where you should insert your entry signal for SELL orders.
// Include a condition to open a sell order, the condition will have to set SellSignal to true or false.

//!! Uncomment and modify this sell entry signal check line:
//if ((Indicator_current < iClose(Symbol(), Period(), 1)) && (Indicator_previous >= iClose(Symbol(), Period(), 2))) SellSignal = true; // Check if the indicator's value crossed the Close price level from above.

   if(SellSignal)
     {
      OpenSell();
     }
  }

// Exit signal
void CheckExitSignal()
  {
//!! if ((UseTradingHours) && (!IsCurrentTimeInInterval(TradingHourStart, TradingHourEnd))) return; // Trading hours restrictions for exit. Normally, you don't want to restrict exit by hours. Still, it's a possibility.

   bool SignalExitLong = false;
   bool SignalExitShort = false;

//!! Uncomment and modify these exit signal checks:
//if ((Indicator_current > iClose(Symbol(), Period(), 1)) && (Indicator_previous <= iClose(Symbol(), Period(), 2))) SignalExitShort = true; // Check if the indicator's value crossed the Close price level from below.
//else if ((Indicator_current < iClose(Symbol(), Period(), 1)) && (Indicator_previous >= iClose(Symbol(), Period(), 2))) SignalExitLong = true; // Check if the indicator's value crossed the Close price level from above.

   if(SignalExitLong)
      CloseAllBuy();
   if(SignalExitShort)
      CloseAllSell();
  }
//+------------------------------------------------------------------+
