//+------------------------------------------------------------------+
//|                                                  RiskManager.mqh |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <Trade/AccountInfo.mqh>

//+------------------------------------------------------------------+
//| Class for managing risk.                                         |
//+------------------------------------------------------------------+
class CRiskManager
  {
protected:
   double            m_risk_percent;   // Risk percentage per trade
   CAccountInfo      m_account_info;   // Account info object

public:
                     CRiskManager();
                    ~CRiskManager();
   void              SetRiskPercent(double risk);
   double            CalculateLotSize(double stop_loss_pips);
   double            CalculateStopLoss(ENUM_ORDER_TYPE order_type,double entry_price,double atr);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CRiskManager::CRiskManager():m_risk_percent(1.0)
  {
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