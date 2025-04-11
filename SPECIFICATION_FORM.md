# Expert Advisor Strategy Specification Form

**Purpose:**  
This form collects detailed information about your trading strategy to develop a custom Expert Advisor (EA) based on our MT5 template.

**Instructions:**  
Complete all relevant sections with specific details. Use “N/A” for inapplicable fields. Examples are provided to guide your responses.

---

## Section 1: General Strategy Information

- **Strategy Name:**  
  _(e.g., "TrendSniper")_

- **Trader Contact:**  
  _(e.g., "John Doe / john@example.com")_

- **Target Symbol(s):**  
  _(e.g., "EURUSD, GBPUSD")_

- **Target Timeframe(s):**  
  _(e.g., "H1, M30")_

- **Overall Strategy Description:**  
  _(e.g., "Trend-following strategy using MA crossovers and RSI confirmation")_

---

## Section 2: Indicators Used

List all indicators with settings for initialization in `InitializeHandles()`. Skip if none are used.

- **Indicator 1:**

  - Name: _(e.g., "Moving Average")_
  - Type: _(e.g., "Exponential")_
  - Period: _(e.g., "50")_
  - Applied to: _(e.g., "Close")_
  - Custom: _(e.g., "Yes/No")_
  - Source/Formula: _(e.g., "Standard MT5 indicator" or "SMA \* 2 + High/Low midpoint")_

- **Indicator 2:**

  - Name: _(Add more as needed)_
  - Type: _()_
  - Period: _()_
  - Applied to: _()_
  - Custom: _()_
  - Source/Formula: _()_

- **ATR Settings (if used):**
  - Period: _(e.g., "14")_
  - Timeframe: _(e.g., "H1")_  
    _(Note: Required for ATR-based SL/TP, partial close, or breakeven)_

---

## Section 3: Trading Hours & Session Management

- **Restrict Trading Hours?**

  - [ ] Yes
  - [ ] No _(Default)_
  - If Yes (Broker Server Time, 24h format):
    - Start Hour: _(e.g., "09")_
    - End Hour: _(e.g., "17")_

- **News Filter:**
  - Avoid high-impact news?
    - [ ] Yes
    - [ ] No _(Default)_
  - If Yes:
    - Minutes Before News: _(e.g., "30")_
    - Minutes After News: _(e.g., "60")_

---

## Section 4: Entry Signals

Define conditions for `CheckEntrySignal()` in `Signal_Functions.mqh`.

- **Buy Entry Conditions:**

  - Indicator 1: _(e.g., "RSI, Period=14, Crosses above 30")_
  - Indicator 2: _(e.g., "EMA, Period=50, Price closes above")_
  - Price Action: _(e.g., "Bullish engulfing")_
  - Other: _(e.g., "Volume > 1000")_
  - Confluence: _(e.g., "All conditions must align")_

- **Sell Entry Conditions:**

  - Indicator 1: _(e.g., "RSI, Period=14, Crosses below 70")_
  - Indicator 2: _(e.g., "EMA, Period=50, Price closes below")_
  - Price Action: _(e.g., "Bearish engulfing")_
  - Other: _(e.g., "Volume > 1000")_
  - Confluence: _(e.g., "All conditions must align")_

- **Re-entry Rules:**
  - Allow multiple positions in same direction?
    - [ ] Yes
    - [ ] No _(Default)_
  - If Yes: _(e.g., "After 20-point pullback")_

---

## Section 5: Exit Signals

For `CheckExitSignal()` in `Signal_Functions.mqh` and `Trade_Functions.mqh`.

- **Take Profit (TP):**

  - Method:
    - [ ] Fixed Points: _(e.g., "50")_
    - [ ] ATR Multiple: _(e.g., "1.5 \* ATR(14)")_
    - [ ] Opposite Signal
    - [ ] Other: _(Specify, e.g., "Target Bollinger Band upper")_
  - Minimum TP (Points): _(e.g., "20")_ _(Optional)_
  - Maximum TP (Points): _(e.g., "100")_ _(Optional)_

- **Stop Loss (SL):**

  - Method:
    - [ ] Fixed Points: _(e.g., "30")_
    - [ ] ATR Multiple: _(e.g., "1.0 \* ATR(14)")_
    - [ ] Indicator Level: _(e.g., "Below Swing Low")_
    - [ ] Other: _(Specify)_
  - Minimum SL (Points): _(e.g., "10")_ _(Optional)_
  - Maximum SL (Points): _(e.g., "50")_ _(Optional)_

- **Additional Exit Conditions:**  
  _(e.g., "Close after 24 hours")_

---

## Section 6: Position Management

- **Breakeven:**

  - Use Breakeven?
    - [ ] Yes
    - [ ] No _(Default)_
  - If Yes:
    - Trigger Method: _(e.g., "20 Points Profit")_
    - Buffer (Points): _(e.g., "5")_

- **Partial Close:**

  - Use Partial Close?
    - [ ] Yes
    - [ ] No _(Default)_
  - If Yes:
    - Trigger Condition: _(e.g., "30 Points Profit")_
    - Percentage to Close: _(e.g., "50%")_

- **Trailing Stop:**  
  _(Note: May require custom coding beyond base template)_
  - Use Trailing Stop?
    - [ ] Yes
    - [ ] No _(Default)_
  - If Yes:
    - Type & Parameters: _(e.g., "Fixed, 20 Points, Step 5")_

---

## Section 7: Risk Management

For `Risk_Functions.mqh`.

- **Position Sizing Method:**

  - [ ] Fixed Lot Size: _(e.g., "0.01")_
  - [ ] Risk Percentage per Trade: _(e.g., "1%")_
    - Calculate Based On:
      - [ ] Account Balance
      - [ ] Account Equity
      - [ ] Free Margin

- **Maximum Concurrent Positions:**  
  _(e.g., "3")_

- **Lot Size Limits:**

  - Minimum Lot Size: _(e.g., "0.01")_ _(Optional)_
  - Maximum Lot Size: _(e.g., "1.0")_ _(Optional)_

- **Maximum Spread Allowed (Points):**  
  _(e.g., "20")_

- **Maximum Slippage Allowed (Points):**  
  _(e.g., "3")_

---

## Section 8: Input Parameters & Customization

List adjustable settings for `Header.mqh`.

- **Parameter 1:**  
  _(e.g., "RSI_Period, Default Value: 14")_

- **Parameter 2:**  
  _(e.g., "Risk_Percent, Default Value: 1.0")_

- **Parameter 3:**  
  _(e.g., "ATR_Multiplier_SL, Default Value: 1.5")_

_(Add more as needed)_

---

## Section 9: Miscellaneous

- **Magic Number Preference:**  
  _(e.g., "123456")_ _(Optional)_

- **Order Comment Preference:**  
  _(e.g., "TrendSniper_v1")_ _(Optional)_

- **Any Other Specific Logic or Rules:**  
  _(e.g., "Avoid trading on Fridays")_

---

**Notes:**

- Default values from the EA template will apply if fields are left blank.
- If using ATR-based features (SL/TP, partial close, breakeven), ensure ATR settings are specified in Section 2.
- Test the resulting EA in a demo environment before live deployment.

**Disclaimer:**  
Trading involves risk. Past performance does not guarantee future results.
