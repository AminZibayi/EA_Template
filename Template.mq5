//+------------------------------------------------------------------+
//|               In the Name of Allah, the Originator, the Creative |
//|                                                     Template.mq5 |
//|                                    Copyright © 2024, Amin Zibayi |
//+------------------------------------------------------------------+

#property copyright     "Amin Zibayi, 2024"
#property link          "https://www.finomics.ir"
#property version       "0.10"
#property description   "A basic expert advisor template for MT5."
#property description   ""
#property description   "WARNING: There is no guarantee that this expert advisor will work as intended. Use at your own risk."
#property description   ""
#property icon          "\\Files\\EF-Icon-64x64px.ico"

#include <Trade\Trade.mqh> // This file is required to easily manage orders and positions.
#include <MQLTA ErrorHandling.mqh> // This file contains useful descriptions for errors.
#include <MQLTA Utils.mqh> // This file contains some useful functions.
#include "Header.mqh"
#include "Risk_Functions.mqh"
#include "Trade_Functions.mqh"
#include "Signal_Functions.mqh"

// Global Variables
CTrade Trade; // Trade object.
int ATRHandle; // Indicator handle for ATR.
int IndicatorHandle = -1; // Global indicator handle for the EA's main signal indicator.
double ATR_current, ATR_previous; // ATR values.
double Indicator_current, Indicator_previous; // Indicator values.

// Here go all the event handling functions. They all run on specific events generated for the expert advisor.
// All event handlers are optional and can be removed if you don't need to process that specific event.

//+-------------------------------------------------------------------+
//| Expert initialization handler                                     |
//+-------------------------------------------------------------------+
int OnInit()
  {
// EventSetTimer(60); // Starting a 60-second timer.
// EventSetMillisecondTimer(500); // Starting a 500-millisecond timer.

   if(!Prechecks())  // Check if everything is OK with input parameters.
     {
      return INIT_FAILED; // Don't initialize the EA if checks fail.
     }

   if(!InitializeHandles())  // Initialize indicator handles.
     {
      PrintFormat("Error initializing indicator handles - %s - %d", GetLastErrorText(GetLastError()), GetLastError());
      return INIT_FAILED;
     }

   SetTradeObject();

   return INIT_SUCCEEDED; // Successful initialization.
  }

//+---------------------------------------------------------------------+
//| Expert deinitialization handler                                     |
//+---------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// Normally, there isn't much stuff you need to do on deinitialization.
  }

//+------------------------------------------------------------------+
//| Expert tick handler                                              |
//+------------------------------------------------------------------+
void OnTick()
  {
   ProcessTick(); // Calling the EA's main processing function here. It's defined farther below.
  }

//+------------------------------------------------------------------+
//| Timer event handler                                              |
//| Here goes the code that runs on timer.                           |
//+------------------------------------------------------------------+
void OnTimer()
  {
// For example, you can update a display timer here if you have one in your EA.
  }

//+------------------------------------------------------------------------------+
//| Trade event handler                                                          |
//| Here goes the code that runs each time something related to trading happens. |
//+------------------------------------------------------------------------------+
void OnTrade()
  {
// For example, if you want to do something when a pending order gets triggered, you can do it here without overloading the OnTick() handler too much.
  }

//+--------------------------------------------------------------------------------+
//| Backtest end handler                                                           |
//| Here goes the code that runs each time a backtest in Strategy Tester finishes. |
//| The goal is to calculate the value of a custom optimization criterion.         |
//+--------------------------------------------------------------------------------+
double OnTester()
  {
   double NetProfit = TesterStatistics(STAT_PROFIT);
   double InitialDeposit = TesterStatistics(STAT_INITIAL_DEPOSIT);
   double MaxDrawDownPerc = TesterStatistics(STAT_EQUITYDD_PERCENT);
   double TotalTrades = TesterStatistics(STAT_TRADES);
   if(InitialDeposit == 0)
      return 0; // Avoiding division by zero.
   if(TotalTrades == 0)
      return -100; // Discard a backtest with zero trades.
   if((TotalTrades > 0) && (MaxDrawDownPerc == 0))
      MaxDrawDownPerc = 0.01; // Avoiding division by zero.

   double NetProfitPerc = NetProfit / InitialDeposit * 100;

   double Max = 0;
   if(NetProfitPerc > 0)
      Max = NetProfitPerc / MaxDrawDownPerc; // Adjust net profit by maximum drawdown.
   if(NetProfitPerc < 0)
      Max = NetProfitPerc;

   return Max; // Return the value as a custom optimization criterion.
  }


// Here go all custom functions. They all are called either from the above-defined event handlers or from other custom functions.

// Entry and exit processing
void ProcessTick()
  {
   if(!GetIndicatorsData())
      return;

   if(CountPositions())
     {
      // There is a position open. Manage SL, TP, or close if necessary.
      if(UsePartialClose)
         PartialCloseAll();
      CheckExitSignal();
     }

// A block of code that lets the subsequent code execute only when a new bar appears on the chart.
// This means that the entry signals will be checked only twice per bar.
   /* static datetime current_bar_time = WRONG_VALUE;
   datetime previous_bar_time = current_bar_time;
   current_bar_time = iTime(Symbol(), Period(), 0);
   static int ticks_of_new_bar = 0; // Process two ticks of each new bar to allow indicator buffers to refresh.
   if (current_bar_time == previous_bar_time)
   {
       ticks_of_new_bar++;
       if (ticks_of_new_bar > 1) return; // Skip after two ticks.
   }
   else ticks_of_new_bar = 0; */

// The number is recalculated after the first call because some trades could have been gotten closed.
   if(CountPositions() < MaxPositions)
      CheckEntrySignal(); // Check entry signals only if there aren't too many positions already.
  }

// Utility functions
// Checks to run at initialization to complete it.
bool Prechecks()
  {
// An example of a check to run here.
   if(MaxLotSize < MinLotSize)
     {
      Print("MaxLotSize cannot be less than MinLotSize");
      return false;
     }
   return true;
  }

// To increase file size
// #include <Dummy.mqh>
//+------------------------------------------------------------------+
