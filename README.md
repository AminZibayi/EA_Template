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
- Control exposure with `MaxPositions` (per symbol) and `MaxTotalPositions` (across all symbols)
- Implement `MaximumLotSize` and `MinimumLotSize` as safety boundaries
- Usage: `LotSize()` function automatically calculates optimal position size

### Stop-Loss and Take-Profit Modes

- Set via `StopLossMode` and `TakeProfitMode` inputs:
  - `FIXED`: Use exact point values from `FixedStopLoss` and `FixedTakeProfit`
  - `ATR_BASED`: Dynamic values scaled by `ATRMultiplierSL` and `ATRMultiplierTP`
- Safety limits with `MinStopLoss`/`MaxStopLoss` and `MinTakeProfit`/`MaxTakeProfit`
- Access through `StopLoss()` and `TakeProfit()` functions which handle all calculations

### Partial Close Functionality

- Enable with `UsePartialClose` parameter
- Two operation modes available via `PartialCloseMode` input:
  - `PC_FIXED`: Trigger partial close when profit reaches `FixedPipsPC` pips
  - `PC_ATR`: Trigger partial close when profit reaches `ATRMultiplierPC` × ATR value
- Configure percentage to close via `PartialClosePerc` (1-99%)
- Called automatically during tick processing or manually with `CheckPartialClose()`
- Tracks positions with built-in logic to prevent multiple partial closes on same position

### Breakeven Functionality

- Enable with `UseBreakeven` parameter to automatically move stop-loss to breakeven
- Two operation modes available via `BreakevenMode` input:
  - `BE_FIXED`: Move to breakeven when profit reaches `FixedBreakevenPips` pips
  - `BE_ATR`: Move to breakeven when profit reaches `BreakevenATRMultiplier` × ATR value
- Configure additional profit buffer with `BreakevenBuffer` in points
- Automatically monitors all positions and applies breakeven when conditions are met
- Called during tick processing via built-in `MoveToBreakeven()` function

### Multi-Symbol Trading

- Trade multiple instruments with a single instance of the EA using the `Symbols` parameter
- Three options for configuring symbols:
  - "current": Trade only the current chart symbol
  - A single symbol name: e.g., "EURUSD"
  - A comma-separated list: e.g., "EURUSD,GBPUSD,USDJPY"
- Control position limits with:
  - `MaxPositions`: Maximum positions per symbol
  - `MaxTotalPositions`: Maximum total positions across all symbols
- Each symbol maintains its own:
  - ATR calculation for volatility-based decisions
  - Signal processing
  - Position management
- Independent processing intervals prevent excessive CPU usage
- Automatic market symbol validation during initialization

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

- `int CountPositions(string symbol = NULL)` - Counts open positions for the specified symbol (or current if NULL) with the EA's magic number.
- `bool OpenBuy(string symbol = NULL)` - Opens a buy position on the specified symbol (or current if NULL) with calculated SL/TP based on risk settings.
- `bool OpenSell(string symbol = NULL)` - Opens a sell position on the specified symbol (or current if NULL) with calculated SL/TP based on risk settings.
- `void CloseAllBuy(string symbol = NULL)` - Closes all buy positions for the specified symbol (or current if NULL).
- `void CloseAllSell(string symbol = NULL)` - Closes all sell positions for the specified symbol (or current if NULL).
- `void CloseAllPositions(string symbol = NULL)` - Closes all positions opened by this EA for the specified symbol (or all symbols if NULL).
- `bool PartialClose(ulong ticket, double percentage)` - Partially closes a position with the specified ticket.
- `void MoveToBreakeven(string symbol = NULL)` - Moves stop-loss to breakeven for eligible positions on the specified symbol (or current if NULL) when profit target is reached.
- `int CountTotalPositions()` - Counts total open positions across all symbols managed by the EA.

### Trade Configuration

- `void SetTradeObject()` - Configures trade object with magic number and slippage

### Signal Management

- `bool InitializeHandles()` - Sets up indicator handles (including ATR) for all configured symbols.
- `bool GetIndicatorsData(string symbol)` - Retrieves indicator data (including ATR) for the specified symbol with retry logic.
- `void CheckEntrySignal(string symbol)` - Framework for implementing entry signal logic for the specified symbol.
- `void CheckExitSignal(string symbol)` - Framework for implementing exit signal
  logic for the specified symbol.
- `void CheckPartialClose(string symbol = NULL)` - Partially closes all eligible positions for the specified symbol (or current if NULL) based on ATR conditions.

### Risk Management

- `double StopLoss(ENUM_ORDER_TYPE order_type, double open_price, string symbol)` - Calculates stop-loss price for the specified symbol based on settings.
- `double TakeProfit(ENUM_ORDER_TYPE order_type, double open_price, string symbol)` - Calculates take-profit price for the specified symbol based on settings.
- `double LotSize(double stop_loss, double open_price, string symbol)` - Calculates position size for the specified symbol based on risk parameters.
- `double DynamicStopLossPrice(ENUM_ORDER_TYPE type, double open_price, string symbol)` - Calculates ATR-based dynamic stop-loss for the specified symbol.
- `double DynamicTakeProfitPrice(ENUM_ORDER_TYPE type, double open_price, string symbol)` - Calculates ATR-based dynamic take-profit for the specified symbol.
- `double GetSymbolATR(string symbol)` - Helper function to retrieve the ATR value for a specific symbol.

### Processing Functions

- `void ProcessTick()` - Main tick processing function, iterates through all configured symbols.
- `bool Prechecks()` - Validates input parameters during initialization, including the `Symbols` list.
- `bool InitializeSymbols()` - Parses the `Symbols` input string, validates symbols, and initializes the `symbolsData` array.
- `double OnTester()` - Custom optimization criterion for backtests.

## Roadmap

- [ ] Multi-Timeframe Support

## Disclaimer

Use this template at your own risk. Always test thoroughly in a demo
environment. Past performance is not indicative of future results.
