# MetaTrader 5 Compilation Fixes for Apple Silicon

## Issues Fixed

### 1. **printf vs PrintFormat**
- **Issue**: The code was using `printf` which is not the standard in MQL5
- **Fix**: Replaced all `printf` calls with `PrintFormat` for consistency
- **Files affected**: `SignalEngine.mqh`

### 2. **iTrix Function Not Available**
- **Issue**: `iTrix` is not a standard MQL5 function and was causing compilation errors
- **Fix**: Implemented a custom TRIX indicator using triple exponential moving averages
- **Files affected**: `SignalEngine.mqh`

### 3. **OrderSend Low-Level Usage**
- **Issue**: Using low-level `OrderSend` function which can be problematic
- **Fix**: Replaced with CTrade class methods (`Buy()` and `Sell()`) for better compatibility
- **Files affected**: `TradeManager.mqh`

### 4. **Missing Includes**
- **Issue**: Missing standard library includes
- **Fix**: Added `#include <Indicators/Indicators.mqh>` and `#property strict`
- **Files affected**: `SignalEngine.mqh`, `DidiBot.mq5`

## MetaTrader 5 on Apple Silicon (M1/M2/M3)

### Compatibility Notes:
1. **Native Support**: MetaTrader 5 now has native Apple Silicon support
2. **Rosetta 2**: If using older versions, they run through Rosetta 2 translation
3. **Performance**: Native versions perform significantly better than Rosetta 2

### Recommended Setup:
1. Download the latest MetaTrader 5 from your broker
2. Ensure you're using the native Apple Silicon version
3. Update to the latest build for best compatibility

### Common Issues on Apple Silicon:
1. **OpenCL**: Some OpenCL functions may not work properly
2. **Legacy Code**: Older MQL5 code may need updates for compatibility
3. **Include Paths**: Some include paths might need adjustment

## Compilation Notes

The fixes ensure:
- ✅ Standard MQL5 function usage
- ✅ Proper error handling
- ✅ Apple Silicon compatibility
- ✅ Modern MQL5 best practices

## Testing

After applying these fixes, the code should compile without errors on:
- MetaTrader 5 on Apple Silicon Macs
- MetaTrader 5 on Intel Macs
- MetaTrader 5 on Windows

## Custom TRIX Implementation

The TRIX indicator is now implemented as a triple exponential moving average:
1. First EMA of price
2. Second EMA of the first EMA
3. Third EMA of the second EMA
4. TRIX = Rate of change of the third EMA

This provides the same functionality as the non-existent `iTrix` function.
