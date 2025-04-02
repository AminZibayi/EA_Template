# MetaTrader 5 Expert Advisor Template

This template provides a solid foundation for developing Expert Advisors (EAs) on MT5. It includes pre-built modules for trade management, risk settings, and signal generation.

## File Structure

- **Template.mq5**  
  The main EA file that initializes your trading logic and event handlers.

- **Header.mqh**  
  Contains input parameters and global settings like risk management, trading hours, and custom indicators.

- **Trade_Functions.mqh**  
  Provides functions to open, close, and partially close trades.

- **Risk_Functions.mqh**  
  Implements calculations for stop-loss, take-profit, and dynamic lot sizing based on risk.

- **Signal_Functions.mqh**  
  Holds indicator initialization and functions to detect entry/exit signals.

## Features

### Trading Hours Management

- Define specific trading sessions using `TradingHoursStart` and `TradingHoursEnd` inputs in Header.mqh
- Simply set your desired hours using 24-hour format based on broker server time

### Risk Management

- Configure via `RiskMode` input:
  - `FIXED_LOT`: Trade with consistent position size (`FixedLotSize`)
  - `RISK_BASED`: Dynamic sizing based on risk percentage (`RiskPercent`)
- Set `AccountBalanceType` to calculate risk from balance, equity, or free margin
- Control exposure with `MaxPositions` to limit concurrent trades
- Implement `MaximumLotSize` and `MinimumLotSize` as safety boundaries
- Usage: `LotSize()` function automatically calculates optimal position size

### Stop-Loss and Take-Profit Modes

- Set via `StopLossMode` and `TakeProfitMode` inputs:
  - `FIXED`: Use exact point values from `FixedStopLoss` and `FixedTakeProfit`
  - `ATR_BASED`: Dynamic values scaled by `ATRMultiplierSL` and `ATRMultiplierTP`
- Safety limits with `MinStopLoss`/`MaxStopLoss` and `MinTakeProfit`/`MaxTakeProfit`
- Access through `StopLoss()` and `TakeProfit()` functions which handle all calculations

### Partial Close Functionality

- Enable with `UsePartialClose` and set trigger level with `PartialCloseATRMultiplier`
- Configure percentage to close via `PartialClosePercent` (1-99%)
- Called automatically during tick processing or manually with `PartialCloseAll()`
- Tracks positions with built-in logic to prevent multiple partial closes on same position

### Breakeven Functionality

- Enable with `UseBreakeven` parameter to automatically move stop-loss to breakeven
- Two operation modes available via `BreakevenMode` input:
  - `BE_FIXED`: Move to breakeven when profit reaches `FixedBreakevenPips` pips
  - `BE_ATR`: Move to breakeven when profit reaches `BreakevenATRMultiplier` × ATR value
- Configure additional profit buffer with `BreakevenBuffer` in points
- Automatically monitors all positions and applies breakeven when conditions are met
- Called during tick processing via built-in `MoveToBreakeven()` function

### ATR Implementation

- Configurable with `ATRPeriod` and `ATRTimeframe` inputs
- Provides volatility reference for dynamic SL/TP, partial close decisions, and breakeven levels
- Powers volatility-adjusted position sizing when combined with risk-based lot sizing

### Trade Execution & Management

- Control spread conditions with `MaxSpread` to prevent trading during volatile periods
- Set unique `MagicNumber` for position tracking
- Customize `OrderComment` for trade identification
- Configure slippage tolerance with `Slippage` parameter

## Usage Guide

This section provides a step-by-step guide to using and customizing the MT5 EA template.

### Installation and Setup

1. Copy the entire template folder into your MT5 Experts directory (typically located at `[MT5 Data Folder]\MQL5\Experts\`)
2. Rename the following files to match your EA's name:
   - Template.mq5 → `YourEAName.mq5`
   - Template.mqproj → `YourEAName.mqproj`
3. Update the metadata in three locations:
   - Edit copyright, description, version, and icon in `YourEAName.mq5` file header
   - Update the project properties in `YourEAName.mqproj` file
   - Update any references to "Template" within the code

### Configuration

1. Open your renamed EA in MetaEditor
2. Configure default trading parameters in Header.mqh:
   - Risk management settings (`MaxRiskPerTrade`, `RiskDefaultSize`, etc.)
   - Trading hours (`TradingHourStart`, `TradingHourEnd`)
   - Stop-loss and take-profit parameters
   - Position sizing options
   - ATR settings for volatility-based decisions

### Implementing Your Strategy

1. Define your entry and exit signals in Signal_Functions.mqh:

   - Uncomment and modify the sample code in `CheckEntrySignal()` and `CheckExitSignal()`
   - The template uses a framework where `OpenBuy()` and `OpenSell()` handle all position sizing and risk calculations automatically

2. To add custom indicators:
   - Declare global variables and handles in your main `.mq5` file
   - Initialize indicators in `InitializeHandles()` function
   - Retrieve indicator data in `GetIndicatorsData()` function

```mq5
// Example of adding a custom indicator
// In your .mq5 file:
int CustomIndicatorHandle;
double CustomIndicator_buffer[];

// In InitializeHandles() function:
CustomIndicatorHandle = iCustom(Symbol(), Period(), "indicator_name", param1, param2);
if(CustomIndicatorHandle == INVALID_HANDLE)
{
   Print("Failed to create custom indicator handle");
   return false;
}
```

3. For advanced customization:
   - Modify risk calculations in Risk_Functions.mqh
   - Adjust trade execution in Trade_Functions.mqh

### Testing and Deployment

1. Compile your EA by pressing F7 in MetaEditor
2. Test in Strategy Tester:

   - Select your EA from the Expert Advisor dropdown
   - Configure testing parameters (symbol, timeframe, date range)
   - Use "Visual mode" for detailed trade visualization
   - Review the custom optimization criterion in `OnTester()` function

3. Deploy to a demo account first:

   - Attach your EA to a chart
   - Enable "Allow Automated Trading" in MT5
   - Monitor performance before considering live deployment

4. For optimization:
   - Use the built-in optimization functionality in Strategy Tester
   - The EA includes a custom optimization criterion in `OnTester()` that balances profit against drawdown

## Functions

### Position Management Functions

- `int CountPositions()` - Counts open positions for current symbol with specified magic number
- `bool OpenBuy()` - Opens a buy position with calculated SL/TP based on risk settings
- `bool OpenSell()` - Opens a sell position with calculated SL/TP based on risk settings
- `void CloseAllBuy()` - Closes all buy positions for current symbol
- `void CloseAllSell()` - Closes all sell positions for current symbol
- `void CloseAllPositions()` - Closes all positions opened by this EA
- `bool PartialClose(ulong ticket, double percentage)` - Partially closes a position with specified ticket
- `void PartialCloseAll()` - Partially closes all positions based on ATR conditions
- `void MoveToBreakeven()` - Moves stop-loss to breakeven when position reaches profit target using either fixed pips or ATR-based calculations

### Trade Configuration

- `void SetTradeObject()` - Configures trade object with magic number and slippage

### Signal Management

- `bool InitializeHandles()` - Sets up indicator handles including ATR
- `bool GetIndicatorsData()` - Retrieves indicator data with retry logic
- `void CheckEntrySignal()` - Framework for implementing entry signal logic
- `void CheckExitSignal()` - Framework for implementing exit signal logic

### Risk Management

- `double StopLoss(ENUM_ORDER_TYPE order_type, double open_price)` - Calculates stop-loss price based on settings
- `double TakeProfit(ENUM_ORDER_TYPE order_type, double open_price)` - Calculates take-profit price based on settings
- `double LotSize(double stop_loss, double open_price)` - Calculates position size based on risk parameters
- `double DynamicStopLossPrice(ENUM_ORDER_TYPE type, double open_price)` - Calculates ATR-based dynamic stop-loss
- `double DynamicTakeProfitPrice(ENUM_ORDER_TYPE type, double open_price)` - Calculates ATR-based dynamic take-profit

### Processing Functions

- `void ProcessTick()` - Main tick processing function
- `bool Prechecks()` - Validates input parameters during initialization
- `double OnTester()` - Custom optimization criterion for backtests

## Disclaimer

Use this template at your own risk. Always test thoroughly in a demo
environment. Past performance is not indicative of future results.
