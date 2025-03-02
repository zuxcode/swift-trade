# **User Guide for Trade Swift EA (Fair Value Gap Detector)**

Welcome to the **Trade Swift EA**, a powerful tool designed to detect **Fair Value Gaps (FVGs)** and execute trades based on these patterns. This guide will walk you through the setup, configuration, and usage of the EA.

---

## **1. Installation**
1. **Download the EA**:
   - Ensure you have the `trade_swift.mq5` file.

2. **Install the EA**:
   - Open your MetaTrader 5 (MT5) platform.
   - Go to `File > Open Data Folder > MQL5 > Experts`.
   - Copy the `trade_swift.mq5` file into the `Experts` folder.

3. **Compile the EA**:
   - Restart MT5 or refresh the `Navigator` panel (press `F7` or right-click and select `Refresh`).
   - Drag and drop the `trade_swift.mq5` file from the `Navigator` panel into the chart where you want to use the EA.
   - The MetaEditor will open. Click `Compile` (or press `F7`) to compile the EA.

4. **Attach the EA to a Chart**:
   - After compilation, close the MetaEditor.
   - Drag and drop the `Trade Swift` EA from the `Navigator` panel onto the desired chart.
   - Configure the input parameters (see **Section 2** below) and click `OK`.

---

## **2. Input Parameters**
The EA comes with customizable input parameters to suit your trading strategy. Below is a description of each parameter:

### **General Settings**
- **BullishColor**: Color for bullish FVG rectangles (default: Lime).
- **BearishColor**: Color for bearish FVG rectangles (default: Red).
- **FVGWidth**: Width of the FVG rectangles (default: 1).
- **FillFVG**: Whether to fill the FVG rectangles (default: true).
- **MaxBars**: Maximum number of historical bars to check for FVGs (default: 500).
- **FutureBars**: Number of future bars to extend the FVG rectangle (default: 5).

### **Trade Settings**
- **LotSize**: Lot size for trades (default: 0.1).
- **StopLossPoints**: Stop loss in points (0 to disable, default: 100).
- **TakeProfitPoints**: Take profit in points (0 to disable, default: 200).
- **MagicNumber**: Unique identifier for trades opened by the EA (default: 123456).

### **FVG Detection Settings**
- **FVGMinPoints**: Minimum FVG size in points to open a trade (default: 30).
- **CandleBodyMinPoints**: Minimum candle body size in points to detect (default: 30).

---

## **3. How It Works**
The EA detects **Fair Value Gaps (FVGs)** and executes trades based on the following logic:

### **Fair Value Gap (FVG) Detection**
- **Bullish FVG**: Occurs when the high of the previous candle is below the low of the current candle.
- **Bearish FVG**: Occurs when the low of the previous candle is above the high of the current candle.

### **Trade Execution**
- When a **Bullish FVG** is detected:
  - The EA closes any open sell trades.
  - Opens a buy trade.
  - Draws a green rectangle on the chart to mark the FVG area.
- When a **Bearish FVG** is detected:
  - The EA closes any open buy trades.
  - Opens a sell trade.
  - Draws a red rectangle on the chart to mark the FVG area.

### **Candle Body Filter**
- The EA only opens trades if the candle body size meets the minimum threshold (`CandleBodyMinPoints`).

---

## **4. Visual Indicators**
- **FVG Rectangles**:
  - Bullish FVGs are marked with green rectangles.
  - Bearish FVGs are marked with red rectangles.
- **Candle Markers**:
  - Large candle bodies are marked with arrows (green for bullish, red for bearish).

---

## **5. Logging and Monitoring**
- The EA logs all actions (e.g., FVG detection, trade execution) in the `Experts` tab of the MT5 terminal.
- Use the logs to monitor the EA's performance and troubleshoot any issues.

---

## **6. Best Practices**
1. **Backtesting**:
   - Test the EA on historical data to evaluate its performance.
   - Use the `Strategy Tester` in MT5 to optimize parameters.

2. **Risk Management**:
   - Adjust the `LotSize`, `StopLossPoints`, and `TakeProfitPoints` to match your risk tolerance.
   - Consider using a risk percentage per trade instead of a fixed lot size.

3. **Market Conditions**:
   - The EA works best in trending markets. Avoid using it in choppy or ranging markets.

4. **Timeframe**:
   - The EA can be used on any timeframe, but higher timeframes (e.g., H1, H4) tend to produce more reliable signals.

---

## **7. Troubleshooting**
- **No Trades Opened**:
  - Ensure the EA is attached to the chart and enabled.
  - Check the `Experts` tab for any error messages.
  - Verify that the `FVGMinPoints` and `CandleBodyMinPoints` are not set too high.

- **Incorrect Trade Execution**:
  - Ensure the `MagicNumber` is unique to avoid conflicts with other EAs or manual trades.
  - Check the `StopLossPoints` and `TakeProfitPoints` settings.

- **Chart Clutter**:
  - If too many FVG rectangles are drawn, reduce the `MaxBars` parameter or manually delete unnecessary objects.

---

## **8. Deinitialization**
- When you remove the EA from the chart, it will delete all FVG rectangles and log the deinitialization reason in the `Experts` tab.

---

## **9. Support**
For questions or support, contact the developer:
- **Twitter**: [@chithedev](https://www.x.com/chithedev)
- **Email**: [Your Email Address]

---

## **10. Disclaimer**
- This EA is provided for educational and informational purposes only.
- Trading forex and CFDs carries a high level of risk and may not be suitable for all investors.
- Always test the EA in a demo account before using it in a live trading environment.

---

Thank you for using **Trade Swift EA**! Happy trading! 🚀