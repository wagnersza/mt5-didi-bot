//+------------------------------------------------------------------+
//|                                                  RiskManager.mqh |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <Trade/AccountInfo.mqh>

//--- Stop Loss Configuration Enumerations
enum ENUM_STOP_TYPE
  {
   ATR_BASED,    // ATR-based stop loss
   FIXED_PIPS    // Fixed pip stop loss
  };

//--- Stop Loss Configuration Structure
struct StopLossConfig
  {
   ENUM_STOP_TYPE    type;                  // Stop loss type
   double            atr_multiplier;        // ATR multiplier (0.5-5.0)
   int               fixed_pips;            // Fixed pip distance
   bool              trailing_enabled;      // Trailing stop activation
   int               max_stop_pips;         // Maximum stop loss cap
   int               stop_limit_slippage;   // Slippage for stop limit orders
   int               atr_period;            // ATR calculation period
   int               min_stop_distance;     // Minimum stop distance
  };

//+------------------------------------------------------------------+
//| Class for managing risk.                                         |
//+------------------------------------------------------------------+
class CRiskManager
  {
protected:
   double            m_risk_percent;       // Risk percentage per trade
   CAccountInfo      m_account_info;       // Account info object
   StopLossConfig    m_stop_config;        // Stop loss configuration

public:
                     CRiskManager();
                    ~CRiskManager();
   void              SetRiskPercent(double risk);
   double            CalculateLotSize(double stop_loss_pips);
   double            CalculateStopLoss(ENUM_ORDER_TYPE order_type,double entry_price,double atr);
   
   // Stop Loss Configuration Methods
   void              SetStopLossConfig(const StopLossConfig &config);
   StopLossConfig    GetStopLossConfig() const;
   bool              ValidateStopLossConfig(const StopLossConfig &config);
   void              InitializeDefaultConfig();
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CRiskManager::CRiskManager():m_risk_percent(1.0)
  {
   InitializeDefaultConfig();
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CRiskManager::~CRiskManager()
  {
  }
//+------------------------------------------------------------------+
//| Sets the risk percentage per trade.                              |
//+------------------------------------------------------------------+
void CRiskManager::SetRiskPercent(double risk)
  {
   m_risk_percent=risk;
   PrintFormat("RiskManager: Risk percentage set to %.2f%%", m_risk_percent);
  }
//+------------------------------------------------------------------+
//| Calculates the lot size based on risk percentage and stop loss.  |
//+------------------------------------------------------------------+
double CRiskManager::CalculateLotSize(double stop_loss_pips)
  {
   if(stop_loss_pips<=0)
     {
      Print("RiskManager: Invalid stop loss pips value for lot size calculation.");
      return 0.0;
     }
   double lot_size=0.0;
   double account_balance=m_account_info.Balance();
   double risk_amount=account_balance*(m_risk_percent/100.0);
   double tick_value=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double pips_per_lot=tick_value/tick_size;

   if(pips_per_lot>0)
     {
      lot_size=risk_amount/(stop_loss_pips*pips_per_lot);
      PrintFormat("RiskManager: Calculated lot size: %.2f for %.2f pips SL", lot_size, stop_loss_pips);
     }
   else
     {
      Print("RiskManager: Invalid pips_per_lot for lot size calculation.");
     }

   return(lot_size);
  }
//+------------------------------------------------------------------+
//| Calculates the stop loss level based on ATR.                     |
//+------------------------------------------------------------------+
double CRiskManager::CalculateStopLoss(ENUM_ORDER_TYPE order_type,double entry_price,double atr)
  {
   double stop_loss_price=0.0;
   double atr_pips=atr/SymbolInfoDouble(_Symbol,SYMBOL_POINT);

   if(order_type==ORDER_TYPE_BUY)
     {
      stop_loss_price=entry_price-(atr_pips*1.5*SymbolInfoDouble(_Symbol,SYMBOL_POINT));
      PrintFormat("RiskManager: Calculated BUY SL: %.5f (ATR pips: %.2f)", stop_loss_price, atr_pips);
     }
   else if(order_type==ORDER_TYPE_SELL)
     {
      stop_loss_price=entry_price+(atr_pips*1.5*SymbolInfoDouble(_Symbol,SYMBOL_POINT));
      PrintFormat("RiskManager: Calculated SELL SL: %.5f (ATR pips: %.2f)", stop_loss_price, atr_pips);
     }

   return(stop_loss_price);
  }
//+------------------------------------------------------------------+
//| Sets the stop loss configuration.                                |
//+------------------------------------------------------------------+
void CRiskManager::SetStopLossConfig(const StopLossConfig &config)
  {
   if(ValidateStopLossConfig(config))
     {
      m_stop_config = config;
      PrintFormat("RiskManager: Stop loss configuration updated - Type: %d, ATR Mult: %.2f, Fixed Pips: %d", 
                  config.type, config.atr_multiplier, config.fixed_pips);
     }
   else
     {
      Print("RiskManager: Invalid stop loss configuration rejected");
     }
  }
//+------------------------------------------------------------------+
//| Gets the current stop loss configuration.                        |
//+------------------------------------------------------------------+
StopLossConfig CRiskManager::GetStopLossConfig() const
  {
   return m_stop_config;
  }
//+------------------------------------------------------------------+
//| Validates stop loss configuration parameters.                    |
//+------------------------------------------------------------------+
bool CRiskManager::ValidateStopLossConfig(const StopLossConfig &config)
  {
   // Validate ATR multiplier range
   if(config.atr_multiplier < 0.5 || config.atr_multiplier > 5.0)
     {
      PrintFormat("RiskManager: Invalid ATR multiplier: %.2f (must be 0.5-5.0)", config.atr_multiplier);
      return false;
     }
   
   // Validate fixed pips
   if(config.fixed_pips < 1 || config.fixed_pips > 1000)
     {
      PrintFormat("RiskManager: Invalid fixed pips: %d (must be 1-1000)", config.fixed_pips);
      return false;
     }
   
   // Validate maximum stop pips
   if(config.max_stop_pips < 10 || config.max_stop_pips > 500)
     {
      PrintFormat("RiskManager: Invalid max stop pips: %d (must be 10-500)", config.max_stop_pips);
      return false;
     }
   
   // Validate stop limit slippage
   if(config.stop_limit_slippage < 0 || config.stop_limit_slippage > 50)
     {
      PrintFormat("RiskManager: Invalid stop limit slippage: %d (must be 0-50)", config.stop_limit_slippage);
      return false;
     }
   
   // Validate ATR period
   if(config.atr_period < 5 || config.atr_period > 100)
     {
      PrintFormat("RiskManager: Invalid ATR period: %d (must be 5-100)", config.atr_period);
      return false;
     }
   
   // Validate minimum stop distance
   if(config.min_stop_distance < 1 || config.min_stop_distance > 100)
     {
      PrintFormat("RiskManager: Invalid min stop distance: %d (must be 1-100)", config.min_stop_distance);
      return false;
     }
   
   return true;
  }
//+------------------------------------------------------------------+
//| Initializes default stop loss configuration.                     |
//+------------------------------------------------------------------+
void CRiskManager::InitializeDefaultConfig()
  {
   m_stop_config.type = ATR_BASED;
   m_stop_config.atr_multiplier = 1.5;
   m_stop_config.fixed_pips = 50;
   m_stop_config.trailing_enabled = true;
   m_stop_config.max_stop_pips = 100;
   m_stop_config.stop_limit_slippage = 3;
   m_stop_config.atr_period = 14;
   m_stop_config.min_stop_distance = 10;
   
   Print("RiskManager: Default stop loss configuration initialized");
  }