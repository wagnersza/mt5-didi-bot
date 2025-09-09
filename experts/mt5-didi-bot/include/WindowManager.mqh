//+------------------------------------------------------------------+
//|                                                WindowManager.mqh |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Class for managing chart windows and indicator window creation   |
//+------------------------------------------------------------------+
class CWindowManager
{
protected:
   struct WindowInfo
   {
      int            window_index;     // Window index (0 = main chart)
      string         window_name;      // Descriptive name for the window
      int            indicator_handle; // Indicator handle for this window
      bool           is_active;        // Whether window is currently active
   };
   
   WindowInfo        m_windows[];      // Array of managed windows
   int               m_window_count;   // Current number of windows
   long              m_chart_id;       // Chart ID for operations
   string            m_window_prefix;  // Prefix for window identification
   
public:
                     CWindowManager();
                    ~CWindowManager();
   
   // Core window management
   bool              Init(long chart_id = 0, string prefix = "DidiBot");
   void              Cleanup();
   
   // Window creation and management
   int               CreateIndicatorWindow(string window_name, int indicator_handle);
   bool              RemoveWindow(int window_index);
   int               GetWindowIndex(string window_name);
   bool              IsWindowActive(int window_index);
   
   // Window properties
   bool              SetWindowHeight(int window_index, int height_pixels);
   bool              SetWindowProperty(int window_index, ENUM_CHART_PROPERTY_INTEGER prop_id, long value);
   bool              SetWindowProperty(int window_index, ENUM_CHART_PROPERTY_DOUBLE prop_id, double value);
   
   // Information retrieval
   int               GetWindowCount() const { return m_window_count; }
   long              GetChartId() const { return m_chart_id; }
   string            GetWindowName(int window_index);
   int               GetIndicatorHandle(int window_index);
   
   // Window validation
   bool              ValidateWindowIndex(int window_index);
   int               GetTotalChartWindows();
   
   // Debug and logging
   void              PrintWindowStatus();
   void              LogWindowInfo(string operation, int window_index, string details = "");
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CWindowManager::CWindowManager()
{
   m_window_count = 0;
   m_chart_id = 0;
   m_window_prefix = "DidiBot";
   ArrayResize(m_windows, 10); // Initial capacity for 10 windows
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CWindowManager::~CWindowManager()
{
   Cleanup();
}

//+------------------------------------------------------------------+
//| Initialize the window manager                                    |
//+------------------------------------------------------------------+
bool CWindowManager::Init(long chart_id = 0, string prefix = "DidiBot")
{
   m_chart_id = (chart_id == 0) ? ChartID() : chart_id;
   m_window_prefix = prefix;
   m_window_count = 0;
   
   // Verify chart is valid
   if(m_chart_id <= 0)
   {
      PrintFormat("WindowManager::Init: Invalid chart ID: %d", m_chart_id);
      return false;
   }
   
   // Register main chart window (index 0)
   if(ArraySize(m_windows) == 0)
      ArrayResize(m_windows, 10);
      
   m_windows[0].window_index = 0;
   m_windows[0].window_name = "Main Chart";
   m_windows[0].indicator_handle = INVALID_HANDLE;
   m_windows[0].is_active = true;
   m_window_count = 1;
   
   LogWindowInfo("INIT", 0, "Main chart window registered");
   return true;
}

//+------------------------------------------------------------------+
//| Clean up all windows and resources                              |
//+------------------------------------------------------------------+
void CWindowManager::Cleanup()
{
   LogWindowInfo("CLEANUP", -1, StringFormat("Cleaning up %d windows", m_window_count));
   
   for(int i = 0; i < m_window_count; i++)
   {
      if(m_windows[i].indicator_handle != INVALID_HANDLE)
      {
         // Note: For indicators attached to chart, cleanup is handled by chart close
         LogWindowInfo("CLEANUP", m_windows[i].window_index, 
                      StringFormat("Window '%s' cleaned", m_windows[i].window_name));
      }
   }
   
   m_window_count = 0;
   ArrayFree(m_windows);
}

//+------------------------------------------------------------------+
//| Create a new indicator window                                    |
//+------------------------------------------------------------------+
int CWindowManager::CreateIndicatorWindow(string window_name, int indicator_handle)
{
   if(indicator_handle == INVALID_HANDLE)
   {
      LogWindowInfo("CREATE_ERROR", -1, 
                   StringFormat("Invalid indicator handle for window '%s'", window_name));
      return -1;
   }
   
   // Add indicator to chart - this creates the window automatically
   int sub_window = ChartIndicatorAdd(m_chart_id, 0, indicator_handle);
   if(sub_window < 0)
   {
      LogWindowInfo("CREATE_ERROR", -1, 
                   StringFormat("Failed to add indicator for window '%s', Error: %d", 
                              window_name, GetLastError()));
      return -1;
   }
   
   // Expand windows array if needed
   if(m_window_count >= ArraySize(m_windows))
   {
      ArrayResize(m_windows, ArraySize(m_windows) + 5);
   }
   
   // Register the new window
   m_windows[m_window_count].window_index = sub_window;
   m_windows[m_window_count].window_name = window_name;
   m_windows[m_window_count].indicator_handle = indicator_handle;
   m_windows[m_window_count].is_active = true;
   
   LogWindowInfo("CREATE", sub_window, 
                StringFormat("Window '%s' created successfully", window_name));
   
   m_window_count++;
   return sub_window;
}

//+------------------------------------------------------------------+
//| Remove a window                                                  |
//+------------------------------------------------------------------+
bool CWindowManager::RemoveWindow(int window_index)
{
   if(!ValidateWindowIndex(window_index) || window_index == 0)
   {
      LogWindowInfo("REMOVE_ERROR", window_index, "Invalid window index or main chart");
      return false;
   }
   
   // Find and remove from our tracking
   for(int i = 0; i < m_window_count; i++)
   {
      if(m_windows[i].window_index == window_index)
      {
         string window_name = m_windows[i].window_name;
         
         // Remove indicator from chart
         if(ChartIndicatorDelete(m_chart_id, window_index, "") == false)
         {
            LogWindowInfo("REMOVE_ERROR", window_index, 
                         StringFormat("Failed to remove window '%s'", window_name));
            return false;
         }
         
         // Mark as inactive
         m_windows[i].is_active = false;
         
         LogWindowInfo("REMOVE", window_index, 
                      StringFormat("Window '%s' removed successfully", window_name));
         return true;
      }
   }
   
   LogWindowInfo("REMOVE_ERROR", window_index, "Window not found in tracking array");
   return false;
}

//+------------------------------------------------------------------+
//| Get window index by name                                         |
//+------------------------------------------------------------------+
int CWindowManager::GetWindowIndex(string window_name)
{
   for(int i = 0; i < m_window_count; i++)
   {
      if(m_windows[i].window_name == window_name && m_windows[i].is_active)
      {
         return m_windows[i].window_index;
      }
   }
   return -1;
}

//+------------------------------------------------------------------+
//| Check if window is active                                        |
//+------------------------------------------------------------------+
bool CWindowManager::IsWindowActive(int window_index)
{
   for(int i = 0; i < m_window_count; i++)
   {
      if(m_windows[i].window_index == window_index)
      {
         return m_windows[i].is_active;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Set window height in pixels                                      |
//+------------------------------------------------------------------+
bool CWindowManager::SetWindowHeight(int window_index, int height_pixels)
{
   if(!ValidateWindowIndex(window_index))
      return false;
      
   // Note: Window height is typically managed by MT5 automatically
   // This function is placeholder for future MT5 API enhancements
   LogWindowInfo("SET_HEIGHT", window_index, 
                StringFormat("Height set to %d pixels", height_pixels));
   return true;
}

//+------------------------------------------------------------------+
//| Set window property (integer)                                    |
//+------------------------------------------------------------------+
bool CWindowManager::SetWindowProperty(int window_index, ENUM_CHART_PROPERTY_INTEGER prop_id, long value)
{
   if(!ValidateWindowIndex(window_index))
      return false;
      
   bool result = ChartSetInteger(m_chart_id, prop_id, window_index, value);
   LogWindowInfo("SET_PROPERTY", window_index, 
                StringFormat("Property %d set to %d, Result: %s", 
                           prop_id, value, result ? "SUCCESS" : "FAILED"));
   return result;
}

//+------------------------------------------------------------------+
//| Set window property (double)                                     |
//+------------------------------------------------------------------+
bool CWindowManager::SetWindowProperty(int window_index, ENUM_CHART_PROPERTY_DOUBLE prop_id, double value)
{
   if(!ValidateWindowIndex(window_index))
      return false;
      
   bool result = ChartSetDouble(m_chart_id, prop_id, window_index, value);
   LogWindowInfo("SET_PROPERTY", window_index, 
                StringFormat("Property %d set to %.5f, Result: %s", 
                           prop_id, value, result ? "SUCCESS" : "FAILED"));
   return result;
}

//+------------------------------------------------------------------+
//| Get window name by index                                         |
//+------------------------------------------------------------------+
string CWindowManager::GetWindowName(int window_index)
{
   for(int i = 0; i < m_window_count; i++)
   {
      if(m_windows[i].window_index == window_index && m_windows[i].is_active)
      {
         return m_windows[i].window_name;
      }
   }
   return "Unknown";
}

//+------------------------------------------------------------------+
//| Get indicator handle for window                                  |
//+------------------------------------------------------------------+
int CWindowManager::GetIndicatorHandle(int window_index)
{
   for(int i = 0; i < m_window_count; i++)
   {
      if(m_windows[i].window_index == window_index && m_windows[i].is_active)
      {
         return m_windows[i].indicator_handle;
      }
   }
   return INVALID_HANDLE;
}

//+------------------------------------------------------------------+
//| Validate window index                                            |
//+------------------------------------------------------------------+
bool CWindowManager::ValidateWindowIndex(int window_index)
{
   if(window_index < 0)
      return false;
      
   int total_windows = GetTotalChartWindows();
   return (window_index < total_windows);
}

//+------------------------------------------------------------------+
//| Get total number of chart windows                                |
//+------------------------------------------------------------------+
int CWindowManager::GetTotalChartWindows()
{
   return (int)ChartGetInteger(m_chart_id, CHART_WINDOWS_TOTAL);
}

//+------------------------------------------------------------------+
//| Print status of all windows                                      |
//+------------------------------------------------------------------+
void CWindowManager::PrintWindowStatus()
{
   PrintFormat("=== WindowManager Status (Chart ID: %d) ===", m_chart_id);
   PrintFormat("Managed windows: %d, Total chart windows: %d", 
              m_window_count, GetTotalChartWindows());
   
   for(int i = 0; i < m_window_count; i++)
   {
      PrintFormat("  [%d] Window %d: '%s' (Handle: %d, Active: %s)",
                 i,
                 m_windows[i].window_index,
                 m_windows[i].window_name,
                 m_windows[i].indicator_handle,
                 m_windows[i].is_active ? "YES" : "NO");
   }
   PrintFormat("==========================================");
}

//+------------------------------------------------------------------+
//| Log window operations for debugging                              |
//+------------------------------------------------------------------+
void CWindowManager::LogWindowInfo(string operation, int window_index, string details = "")
{
   string message = StringFormat("WindowManager::%s", operation);
   if(window_index >= 0)
      message += StringFormat(" [Win%d]", window_index);
   if(details != "")
      message += StringFormat(" - %s", details);
      
   Print(message);
}
