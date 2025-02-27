//+------------------------------------------------------------------+
//|               In the Name of Allah, the Originator, the Creative |
//|                                                     Template.mq5 |
//|                                    Copyright © 2024, Amin Zibayi |
//+------------------------------------------------------------------+

enum ENUM_RISK_BASE
  {
   RISK_BASE_EQUITY = 1,     // EQUITY
   RISK_BASE_BALANCE = 2,    // BALANCE
   RISK_BASE_FREEMARGIN = 3, // FREE MARGIN
  };

enum ENUM_RISK_DEFAULT_SIZE
  {
   RISK_DEFAULT_FIXED = 1,   // FIXED SIZE
   RISK_DEFAULT_AUTO = 2,    // AUTOMATIC SIZE BASED ON RISK
  };

enum ENUM_MODE_SL
  {
   SL_FIXED = 0,             // FIXED STOP LOSS
   SL_AUTO = 1,              // AUTOMATIC STOP LOSS
  };

enum ENUM_MODE_TP
  {
   TP_FIXED = 0,             // FIXED TAKE PROFIT
   TP_AUTO = 1,              // AUTOMATIC TAKE PROFIT
  };

input string Comment_0 = "==========";  // EA-Specific Parameters
// !! Declare parameters specific to your EA here.


input string Comment_1 = "==========";  // Trading Hours Settings
input bool UseTradingHours = false;     // Limit trading hours
input ENUM_HOUR TradingHourStart = h07; // Trading start hour (Broker server hour)
input ENUM_HOUR TradingHourEnd = h19;   // Trading end hour (Broker server hour)

input string Comment_2 = "==========";  // ATR Settings
input int ATRPeriod = 100;              // ATR period
input ENUM_TIMEFRAMES ATRTimeFrame = PERIOD_CURRENT; // ATR timeframe
input double ATRMultiplierSL = 2;       // ATR multiplier for stop-loss
input double ATRMultiplierTP = 3;       // ATR multiplier for take-profit

// General input parameters
input string Comment_a = "==========";                             // Risk Management Settings
input ENUM_RISK_DEFAULT_SIZE RiskDefaultSize = RISK_DEFAULT_FIXED; // Position size mode
input double DefaultLotSize = 0.01;                                // Position size (if fixed or if no stop loss defined)
input ENUM_RISK_BASE RiskBase = RISK_BASE_BALANCE;                 // Risk base
input int MaxRiskPerTrade = 2;                                     // Percentage to risk each trade
input double MinLotSize = 0.01;                                    // Minimum position size allowed
input double MaxLotSize = 100;                                     // Maximum position size allowed
input int MaxPositions = 1;                                        // Maximum number of positions for this EA

input string Comment_b = "==========";                             // Stop-Loss and Take-Profit Settings
input ENUM_MODE_SL StopLossMode = SL_FIXED;                        // Stop-loss mode
input int DefaultStopLoss = 0;                                     // Default stop-loss in points (0 = no stop-loss)
input int MinStopLoss = 0;                                         // Minimum allowed stop-loss in points
input int MaxStopLoss = 5000;                                      // Maximum allowed stop-loss in points
input ENUM_MODE_TP TakeProfitMode = TP_FIXED;                      // Take-profit mode
input int DefaultTakeProfit = 0;                                   // Default take-profit in points (0 = no take-profit)
input int MinTakeProfit = 0;                                       // Minimum allowed take-profit in points
input int MaxTakeProfit = 5000;                                    // Maximum allowed take-profit in points

input string Comment_c = "==========";                             // Partial Close Settings
input bool UsePartialClose = false;                                // Use partial close
input double PartialClosePerc = 50;                                // Partial close percentage
input double ATRMultiplierPC = 1;                                  // ATR multiplier for partial close

input string Comment_d = "==========";                             // Additional Settings
input int MagicNumber = 0;                                         // Magic number
input string OrderNote = "";                                       // Comment for orders
input int Slippage = 5;                                            // Slippage in points
input int MaxSpread = 50;                                          // Maximum allowed spread to trade, in points

//+------------------------------------------------------------------+
