# MT5 Didi Bot - Multi-Window System Troubleshooting Guide

## Common Issues and Solutions

### Window Creation Problems

#### Issue: Windows Not Created
**Symptoms**: Only main chart visible, no indicator windows appear
**Causes**: 
- Chart ID invalid
- Insufficient permissions
- MetaTrader 5 window limit reached

**Solutions**:
1. **Check Chart Permissions**:
   ```mql5
   // Verify in EA logs
   if(ChartID() <= 0) {
       Print("Invalid chart ID detected");
   }
   ```

2. **Restart MetaTrader 5**: Close and reopen MT5 completely
3. **Check Window Limit**: MT5 supports maximum 100 windows
4. **Verify EA Installation**: Ensure EA compiled without errors

#### Issue: Partial Window Creation
**Symptoms**: Some windows created, others missing
**Causes**:
- Memory limitations
- Handle creation failures
- Concurrent window operations

**Solutions**:
1. **Memory Check**: Close other EAs and indicators
2. **Sequential Creation**: Remove and reattach EA
3. **Check EA Logs**: Look for specific window creation failures

### Indicator Display Issues

#### Issue: Empty Indicator Windows
**Symptoms**: Windows created but no indicator data shown
**Causes**:
- Indicator initialization failure
- Insufficient price history
- Data feed interruption

**Solutions**:
1. **Check Price History**: Ensure minimum 200 bars available
2. **Restart Data Feed**: Reconnect to broker
3. **Verify Indicator Settings**: Check periods and parameters
4. **Check EA Logs**: Look for indicator handle creation errors

#### Issue: Incorrect Window Scaling
**Symptoms**: Indicators cut off or improperly scaled
**Causes**:
- Auto-scaling disabled
- Manual scale settings
- Window height too small

**Solutions**:
1. **Enable Auto-Scale**: Right-click window → Properties → Auto Scale
2. **Adjust Window Height**: Drag window borders to increase height
3. **Reset Scale**: Right-click → Scale → Fit to Data

### Performance Issues

#### Issue: Slow Chart Updates
**Symptoms**: Delays in window refreshes, lagging indicators
**Causes**:
- Too many windows open
- Insufficient system resources
- Network latency

**Solutions**:
1. **Close Unused Charts**: Limit to essential windows only
2. **Increase System Resources**: Close other applications
3. **Optimize Update Frequency**: Use higher timeframes
4. **Check Network**: Ensure stable broker connection

#### Issue: High CPU Usage
**Symptoms**: Fan noise, system slowdown, MetaTrader freezing
**Causes**:
- Continuous redrawing
- Memory leaks
- Inefficient update cycles

**Solutions**:
1. **Monitor Resource Usage**: Task Manager → MT5 process
2. **Restart EA**: Remove and reattach to chart
3. **Reduce Window Count**: Disable unused indicators
4. **Update MetaTrader**: Use latest MT5 build

### Signal Problems

#### Issue: Missing Trade Signals
**Symptoms**: No entry/exit arrows on main chart
**Causes**:
- Signal coordination failure
- Window synchronization issues
- Indicator calculation problems

**Solutions**:
1. **Check Signal Panel**: Verify individual indicator signals
2. **Verify Window Assignment**: Ensure indicators assigned to correct windows
3. **Review Signal Logic**: Check if all conditions met
4. **Restart EA**: Remove and reattach to reset signal engine

#### Issue: Conflicting Signals
**Symptoms**: Multiple contradictory signals displayed
**Causes**:
- Window desynchronization
- Stale data in buffers
- Calculation timing issues

**Solutions**:
1. **Force Window Refresh**: ChartRedraw() or restart EA
2. **Check Data Synchronization**: Verify all windows use same timeframe
3. **Clear Signal History**: Remove EA and clear chart objects

### Memory and Resource Issues

#### Issue: Memory Leaks
**Symptoms**: Gradual system slowdown, increasing memory usage
**Causes**:
- Improper object cleanup
- Handle leaks
- Buffer memory accumulation

**Solutions**:
1. **Monitor Memory Usage**: Task Manager over time
2. **Restart EA Periodically**: Especially for long-running systems
3. **Check Handle Management**: Verify proper cleanup in logs
4. **Update EA**: Ensure latest version with memory fixes

#### Issue: Handle Limit Exceeded
**Symptoms**: "No more handles" error messages
**Causes**:
- Too many indicators
- Handle creation without cleanup
- System resource exhaustion

**Solutions**:
1. **Close Unused Indicators**: Remove extra EAs/indicators
2. **Restart MetaTrader**: Fresh handle pool
3. **Optimize Handle Usage**: Review EA handle management
4. **System Restart**: If handles remain allocated

### Platform-Specific Issues

#### macOS Specific Problems

**Issue: Window Display Glitches**
**Symptoms**: Garbled window content, missing elements
**Causes**: macOS graphics system differences

**Solutions**:
1. **Update macOS**: Ensure latest system version
2. **Restart MetaTrader**: Close and reopen application
3. **Reset Graphics Settings**: MT5 → View → Toolbars → Reset
4. **Check Graphics Driver**: Update if available

**Issue: Slow Performance on macOS**
**Symptoms**: Laggy window updates, slow rendering
**Causes**: Graphics optimization differences

**Solutions**:
1. **Reduce Window Count**: Use fewer simultaneous windows
2. **Lower Graphics Quality**: MT5 → Tools → Options → Graphics
3. **Close Background Apps**: Free system resources
4. **Use Lower Timeframes**: Reduce calculation load

#### Windows Specific Problems

**Issue: DPI Scaling Issues**
**Symptoms**: Misaligned windows, small text
**Causes**: High DPI display settings

**Solutions**:
1. **Adjust DPI Settings**: Windows Display Settings
2. **MT5 Compatibility Mode**: Right-click → Properties → Compatibility
3. **Scale Override**: System → Display → Scale override
4. **Monitor Native Resolution**: Use recommended settings

### Error Codes and Messages

#### Common Error Messages

**"Window creation failed"**
- Check system resources
- Verify chart permissions
- Restart MetaTrader 5

**"Indicator handle invalid"**
- Verify sufficient price history
- Check broker connection
- Restart data feed

**"Memory allocation error"**
- Close unused applications
- Restart MetaTrader 5
- Check available RAM

**"Window index out of range"**
- EA bug - restart EA
- Check window management code
- Report to developer

### Diagnostic Tools

#### EA Log Analysis
Check MT5 Experts tab for:
- Window creation messages
- Indicator initialization status
- Error codes and descriptions
- Performance timing information

#### System Resource Monitoring
Monitor these metrics:
- **CPU Usage**: Should be < 10% normally
- **Memory Usage**: Should be < 1GB for EA
- **Handle Count**: Monitor for leaks
- **Network Activity**: Check broker connection

#### Debug Mode
Enable debug logging:
1. Add debug prints to EA
2. Monitor real-time log output
3. Correlate errors with actions
4. Track resource usage patterns

### Prevention Best Practices

#### System Maintenance
1. **Regular Restarts**: Weekly MetaTrader restart
2. **Resource Monitoring**: Daily system check
3. **Log Review**: Weekly error log analysis
4. **Backup Settings**: Save workspace templates

#### Performance Optimization
1. **Limit Window Count**: Maximum 6 windows recommended
2. **Use Appropriate Timeframes**: H1+ for best performance
3. **Monitor System Load**: Close unnecessary applications
4. **Regular Updates**: Keep MT5 and EA current

#### Error Prevention
1. **Stable Internet**: Reliable broker connection
2. **Adequate Hardware**: 8GB+ RAM recommended
3. **Clean Installation**: Fresh MT5 installation periodically
4. **Proper Shutdown**: Always close EA before exit

### Getting Help

#### Information to Provide
When reporting issues:
1. **MT5 Build Number**: Help → About MetaTrader 5
2. **Operating System**: Version and architecture
3. **EA Version**: Check compilation date
4. **Error Messages**: Complete text from logs
5. **Steps to Reproduce**: Detailed sequence
6. **System Specifications**: CPU, RAM, graphics

#### Support Channels
- Check documentation first
- Review EA logs for error details
- Contact developer with diagnostic information
- Community forums for common issues

Remember: Most issues are resolved by restarting MetaTrader 5 or the EA itself.
