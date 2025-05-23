//+------------------------------------------------------------------+
//|               In the Name of Allah, the Originator, the Creative |
//|                                                     Template.mq5 |
//|                                    Copyright © 2024, Amin Zibayi |
//+------------------------------------------------------------------+

#property copyright     "Amin Zibayi, 2024"
#property link          "https://www.finomics.ir"
#property version       "1.00"
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
SymbolInfo symbolsData[]; // Array to store data for each symbol
string symbolsList[]; // Array of symbols to trade
int symbolsCount = 0; // Number of symbols to trade
datetime lastProcessedTime = 0; // Time of the last tick processing

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
     
   // Parse symbols list
   if(!InitializeSymbols())
     {
      PrintFormat("Error initializing symbols list");
      return INIT_FAILED;
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
   // Clean up indicator handles to prevent memory leaks
   for(int i = 0; i < symbolsCount; i++)
     {
      if(symbolsData[i].ATRHandle != INVALID_HANDLE)
         IndicatorRelease(symbolsData[i].ATRHandle);
      if(symbolsData[i].IndicatorHandle != INVALID_HANDLE)
         IndicatorRelease(symbolsData[i].IndicatorHandle);
     }
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

// Initialize the list of symbols to trade
bool InitializeSymbols()
{
   if(Symbols == "current")
   {
      // Using only the current chart symbol
      ArrayResize(symbolsList, 1);
      symbolsList[0] = Symbol();
      symbolsCount = 1;
   }
   else
   {
      // Parse the comma-separated list of symbols
      string symbolsInput = Symbols;
      StringTrimLeft(symbolsInput); // Trim input string beforehand
      StringTrimRight(symbolsInput);

      int commaPos = StringFind(symbolsInput, ",");
      int startPos = 0;
      int tempCount = 0;
      
      // Count the number of symbols
      if(commaPos == -1 && StringLen(symbolsInput) > 0) // Check if the trimmed string is not empty
      {
         // Only one symbol in the list
         ArrayResize(symbolsList, 1);
         symbolsList[0] = symbolsInput; // Assign the already trimmed input
         symbolsCount = 1;
      }
      else if (commaPos != -1) // Only proceed if there are commas
      {
         // Multiple symbols, count them first
         string temp = symbolsInput;
         int count = 1;
         while(StringFind(temp, ",") != -1)
         {
            temp = StringSubstr(temp, StringFind(temp, ",") + 1);
            count++;
         }
         
         // Allocate the array and parse symbols
         ArrayResize(symbolsList, count);
         string symbol_part; // Temporary variable for substring
         while(commaPos != -1)
         {
            symbol_part = StringSubstr(symbolsInput, startPos, commaPos - startPos);
            StringTrimLeft(symbol_part); // Trim the part
            StringTrimRight(symbol_part);
            if(StringLen(symbol_part) > 0) // Add only if not empty after trimming
               symbolsList[tempCount++] = symbol_part;
            startPos = commaPos + 1;
            commaPos = StringFind(symbolsInput, ",", startPos);
         }
         // Add the last symbol
         symbol_part = StringSubstr(symbolsInput, startPos);
         StringTrimLeft(symbol_part); // Trim the last part
         StringTrimRight(symbol_part);
         if(StringLen(symbol_part) > 0) // Add only if not empty after trimming
            symbolsList[tempCount++] = symbol_part;
            
         // Resize array to actual number of valid symbols found
         ArrayResize(symbolsList, tempCount); 
         symbolsCount = tempCount;
      }
      else // Handle case where input was empty or just commas
      {
         symbolsCount = 0;
         ArrayResize(symbolsList, 0);
         Print("Warning: Symbols input was empty or invalid after trimming.");
      }
   }

   if(symbolsCount == 0)
   {
       Print("Error: No valid symbols to trade were found in the input list.");
       return false;
   }
   
   // Validate all symbols
   for(int i = 0; i < symbolsCount; i++)
   {
      if(!SymbolSelect(symbolsList[i], true))
      {
         PrintFormat("Error selecting symbol %s - not found or not available", symbolsList[i]);
         return false;
      }
   }
   
   // Initialize the symbols data array
   ArrayResize(symbolsData, symbolsCount);
   for(int i = 0; i < symbolsCount; i++)
   {
      symbolsData[i].name = symbolsList[i];
      symbolsData[i].ATRHandle = INVALID_HANDLE;
      symbolsData[i].IndicatorHandle = INVALID_HANDLE;
      symbolsData[i].lastProcessed = 0;
   }
   
   return true;
}

// Entry and exit processing
void ProcessTick()
  {
   // Check each symbol
   for(int s = 0; s < symbolsCount; s++)
     {
      string currentSymbol = symbolsData[s].name;
      
      // Skip if this symbol was processed too recently (avoid excess processing)
      if(TimeCurrent() - symbolsData[s].lastProcessed < 1 && symbolsData[s].lastProcessed > 0) 
         continue;
      
      // Update the last processed time
      symbolsData[s].lastProcessed = TimeCurrent();
      
      if(!GetIndicatorsData(currentSymbol))
         continue;

      int symbolPositions = CountPositions(currentSymbol);
      if(symbolPositions)
        {
         // There is a position open. Manage SL, TP, or close if necessary.
         if(UsePartialClose)
            CheckPartialClose(currentSymbol);
         if(UseBreakeven)
            MoveToBreakeven(currentSymbol);
         CheckExitSignal(currentSymbol);
        }

      // Check if we've reached the maximum total positions across all symbols
      int totalPositions = CountTotalPositions();
      if(totalPositions >= MaxTotalPositions)
         continue;
      
      // Check if we can open more positions on this symbol
      if(symbolPositions < MaxPositions)
         CheckEntrySignal(currentSymbol); // Check entry signals only if there aren't too many positions already.
     }
  }

// Count total positions across all traded symbols
int CountTotalPositions()
{
   int count = 0;
   for(int i = 0; i < symbolsCount; i++)
   {
      count += CountPositions(symbolsData[i].name);
   }
   return count;
}

// Utility functions
// Checks to run at initialization to complete it.
bool Prechecks()
  {
   // Check if the symbols parameter is valid
   if(Symbols == "")
     {
      Print("Symbols parameter cannot be empty");
      return false;
     }
  
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
