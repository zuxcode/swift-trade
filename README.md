# Trade Swift EA - Fair Value Gap Detector

## Overview
Trade Swift EA is an Expert Advisor (EA) for MetaTrader 5 that detects Fair Value Gaps (FVG) and executes trades based on these gaps. The EA analyzes price action, identifies gaps, and places buy/sell orders accordingly. It also manages open trades based on candle body size and other configurable parameters.

## Features
- Detects Bullish and Bearish Fair Value Gaps (FVG)
- Automatically places buy/sell orders based on FVG patterns
- Configurable lot size, stop loss, and take profit
- Closes opposite trades when new signals appear
- Highlights detected FVGs on the chart with configurable colors
- Works on any time frame and symbol

## Installation
1. Download the `trade_swift.mq5` file.
2. Open MetaTrader 5 and navigate to **File > Open Data Folder**.
3. Place `trade_swift.mq5` in the `MQL5/Experts` folder.
4. Restart MetaTrader 5 or refresh the Expert Advisors list.
5. Attach the EA to a chart by dragging it from the **Navigator** panel.

## Inputs & Settings
The EA provides several user-configurable inputs:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `BullishColor` | Color for Bullish FVG | Lime |
| `BearishColor` | Color for Bearish FVG | Red |
| `FVGWidth` | Width of the FVG rectangle | 1 |
| `FillFVG` | Whether to fill the FVG rectangle | true |
| `MaxBars` | Number of historical bars to check | 500 |
| `FutureBars` | Number of future bars for FVG end time | 5 |
| `LotSize` | Lot size for trades | 0.1 |
| `StopLossPoints` | Stop loss in points (0 to disable) | 100 |
| `TakeProfitPoints` | Take profit in points (0 to disable) | 200 |
| `MagicNumber` | Unique identifier for EA trades | 123456 |
| `FVGMinPoints` | Minimum FVG size in points to trigger a trade | 30 |
| `CandleBodyMinPoints` | Minimum candle body size to detect | 30 |

## How It Works
1. **Initialization (`OnInit`)**
   - Sets up EA configurations and checks historical FVG patterns.
   - Prints the EA settings to the terminal.
   
2. **Detecting New Bars (`OnTick`)**
   - Checks if a new bar has formed and updates detection accordingly.
   - Evaluates FVG conditions and manages open trades.
   
3. **FVG Detection (`CheckFVGCondition`)**
   - Identifies bullish/bearish FVGs based on price gaps.
   - Draws FVG rectangles on the chart for visual confirmation.
   
4. **Trade Execution**
   - Opens buy orders on bullish FVGs.
   - Opens sell orders on bearish FVGs.
   - Closes opposite trades when new signals appear.
   
5. **Risk Management**
   - Stop loss and take profit are applied based on input settings.
   - Only one trade per direction is allowed to avoid overtrading.

## Trading Logic
### Bullish FVG Conditions
- Previous candle's **high** is lower than the next candle's **low**.
- The gap size is greater than `FVGMinPoints`.
- Opens a **buy trade** and closes any existing sell trades.

### Bearish FVG Conditions
- Previous candle's **low** is higher than the next candle's **high**.
- The gap size is greater than `FVGMinPoints`.
- Opens a **sell trade** and closes any existing buy trades.

### Candle Body Confirmation
- If a candle's body exceeds `CandleBodyMinPoints`, a trade is opened in the candle's direction.

## Logging & Debugging
- The EA prints important information to the **Experts** tab in MetaTrader 5.
- Messages include detected FVGs, trade executions, and errors.

## Best Practices
- Use this EA on higher time frames (H1, H4, or D1) for better accuracy.
- Optimize settings based on market conditions.
- Backtest on historical data before running on a live account.
- Always use proper risk management.

## Disclaimer
This EA is provided for educational purposes. Trading involves risk, and past performance is not indicative of future results. Use at your own discretion.

## Author
Developed by **chiTheDev** | [Twitter](https://www.x.com/chithedev)

