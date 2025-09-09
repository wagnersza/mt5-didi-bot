//+------------------------------------------------------------------+
//|                                           WindowManager_clean.mqh |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Optimized Window Manager with enhanced error handling and performance |
//+------------------------------------------------------------------+
class CWindowManagerOptimized
{
protected:
   struct WindowInfo
   {
      int            window_index;     // Window index (0 = main chart)
      string         window_name;      // Descriptive name for the window
      int            indicator_handle; // Indicator handle for this window
      bool           is_active;        // Whether window is currently active
      datetime       created_time;     // When window was created
      long           memory_usage;     // Estimated memory usage
   };
   
   WindowInfo        m_windows[];      // Array of managed windows
   int               m_window_count;   // Current number of windows
   long              m_chart_id;       // Chart ID for operations
   string            m_window_prefix;  // Prefix for window identification
   
   // Performance tracking
   int               m_error_count;    // Number of errors encountered
   datetime          m_last_cleanup;   // Last cleanup time
   bool              m_debug_mode;     // Enable debug logging
   
   // Configuration
   int               m_max_windows;    // Maximum allowed windows
   int               m_cleanup_interval; // Cleanup interval in seconds
   
public:
                     CWindowManagerOptimized();
                    ~CWindowManagerOptimized();
   
   // Core window management with enhanced error handling
   bool              Init(long chart_id = 0, string prefix = "DidiBot", bool debug = false);
   void              Cleanup();
   bool              PerformMaintenanceCleanup();
   
   // Window creation and management with validation
   int               CreateIndicatorWindow(string window_name, int indicator_handle, int height = 100);
   bool              RemoveWindow(int window_index);
   int               GetWindowIndex(string window_name);
   bool              IsWindowActive(int window_index);
   
   // Enhanced window properties with error checking
   bool              SetWindowHeight(int window_index, int height_pixels);
   bool              SetWindowProperty(int window_index, ENUM_CHART_PROPERTY_INTEGER prop_id, long value);
   bool              SetWindowProperty(int window_index, ENUM_CHART_PROPERTY_DOUBLE prop_id, double value);
   bool              ValidateAllWindows();
   
   // Information retrieval with bounds checking
   int               GetWindowCount() const { return m_window_count; }
   long              GetChartId() const { return m_chart_id; }
   string            GetWindowName(int window_index);
   int               GetIndicatorHandle(int window_index);
   long              GetTotalMemoryUsage();
   
   // Enhanced validation and diagnostics
   bool              ValidateWindowIndex(int window_index);
   int               GetTotalChartWindows();
   bool              CheckSystemHealth();
   
   // Performance monitoring
   int               GetErrorCount() const { return m_error_count; }
   void              ResetErrorCount() { m_error_count = 0; }
   double            GetWindowCreationRate();
   
   // Debug and logging with levels
   void              PrintWindowStatus();
   void              LogWindowInfo(string operation, int window_index, string details = "", int level = 0);
   void              EnableDebugMode(bool enable) { m_debug_mode = enable; }
   
private:
   // Internal helper methods
   bool              ValidateChartId();
   bool              CheckMemoryLimits();
   void              IncrementErrorCount();
   bool              IsMaintenanceRequired();
   void              CompactWindowArray();
};

//+------------------------------------------------------------------+
//| Constructor with enhanced initialization                         |
//+------------------------------------------------------------------+
CWindowManagerOptimized::CWindowManagerOptimized()
{
   m_window_count = 0;
   m_chart_id = 0;
   m_window_prefix = "DidiBot";
   m_error_count = 0;
   m_last_cleanup = TimeCurrent();
   m_debug_mode = false;
   m_max_windows = 10;
   m_cleanup_interval = 300; // 5 minutes
   
   ArrayResize(m_windows, m_max_windows);
}

//+------------------------------------------------------------------+
//| Destructor with comprehensive cleanup                           |
//+------------------------------------------------------------------+
CWindowManagerOptimized::~CWindowManagerOptimized()
{
   if(m_debug_mode)
      LogWindowInfo("DESTRUCTOR", -1, "Starting destructor cleanup");
   
   Cleanup();
   
   if(m_debug_mode)
      LogWindowInfo("DESTRUCTOR", -1, "Destructor cleanup completed");
}

//+------------------------------------------------------------------+
//| Enhanced initialization with validation                         |
//+------------------------------------------------------------------+
bool CWindowManagerOptimized::Init(long chart_id = 0, string prefix = "DidiBot", bool debug = false)
{
   m_debug_mode = debug;
   m_chart_id = (chart_id == 0) ? ChartID() : chart_id;
   m_window_prefix = prefix;
   m_window_count = 0;
   m_error_count = 0;
   m_last_cleanup = TimeCurrent();
   
   // Enhanced chart validation
   if(!ValidateChartId())
   {
      LogWindowInfo("INIT_ERROR", -1, StringFormat("Invalid chart ID: %d", m_chart_id), 2);
      IncrementErrorCount();
      return false;
   }
   
   // Check system resources
   if(!CheckMemoryLimits())
   {
      LogWindowInfo("INIT_WARNING", -1, "Low system memory detected", 1);
   }
   
   // Verify array initialization
   if(ArraySize(m_windows) < m_max_windows)
      ArrayResize(m_windows, m_max_windows);
      
   // Register main chart window (index 0) with enhanced info
   m_windows[0].window_index = 0;
   m_windows[0].window_name = "Main Chart";
   m_windows[0].indicator_handle = INVALID_HANDLE;
   m_windows[0].is_active = true;
   m_windows[0].created_time = TimeCurrent();
   m_windows[0].memory_usage = 0;
   m_window_count = 1;
   
   LogWindowInfo("INIT", 0, StringFormat("Initialized with prefix '%s', debug=%s", 
                m_window_prefix, m_debug_mode ? "true" : "false"));
   return true;
}

//+------------------------------------------------------------------+
//| Enhanced cleanup with memory management                         |
//+------------------------------------------------------------------+
void CWindowManagerOptimized::Cleanup()
{
   LogWindowInfo("CLEANUP", -1, StringFormat("Starting cleanup of %d windows", m_window_count));
   
   // Clean up in reverse order to avoid index issues
   for(int i = m_window_count - 1; i >= 0; i--)
   {
      if(m_windows[i].is_active && m_windows[i].window_index > 0)
      {
         if(m_windows[i].indicator_handle != INVALID_HANDLE)
         {
            // Attempt graceful removal
            if(!ChartIndicatorDelete(m_chart_id, m_windows[i].window_index, ""))
            {
               LogWindowInfo("CLEANUP_ERROR", m_windows[i].window_index, 
                           StringFormat("Failed to remove window '%s'", m_windows[i].window_name), 1);
               IncrementErrorCount();
            }
            else
            {
               LogWindowInfo("CLEANUP", m_windows[i].window_index, 
                           StringFormat("Window '%s' removed successfully", m_windows[i].window_name));
            }
         }
         
         // Clear window info
         m_windows[i].is_active = false;
         m_windows[i].indicator_handle = INVALID_HANDLE;
         m_windows[i].memory_usage = 0;
      }
   }
   
   // Reset counters
   m_window_count = 0;
   m_last_cleanup = TimeCurrent();
   
   // Free memory
   ArrayFree(m_windows);
   
   LogWindowInfo("CLEANUP", -1, "Cleanup completed successfully");
}

//+------------------------------------------------------------------+
//| Perform maintenance cleanup                                      |
//+------------------------------------------------------------------+
bool CWindowManagerOptimized::PerformMaintenanceCleanup()
{
   if(!IsMaintenanceRequired())
      return true;
      
   LogWindowInfo("MAINTENANCE", -1, "Starting maintenance cleanup");
   
   int cleaned_count = 0;
   
   // Check for invalid windows
   for(int i = 0; i < m_window_count; i++)
   {
      if(m_windows[i].is_active)
      {
         // Validate window still exists
         if(m_windows[i].window_index > 0)
         {
            string indicator_name = ChartIndicatorName(m_chart_id, m_windows[i].window_index, 0);
            if(indicator_name == "")
            {
               LogWindowInfo("MAINTENANCE", m_windows[i].window_index, 
                           StringFormat("Window '%s' no longer exists, marking inactive", 
                                      m_windows[i].window_name), 1);
               m_windows[i].is_active = false;
               cleaned_count++;
            }
         }
      }
   }
   
   // Compact array if needed
   if(cleaned_count > 0)
   {
      CompactWindowArray();
   }
   
   m_last_cleanup = TimeCurrent();
   LogWindowInfo("MAINTENANCE", -1, StringFormat("Maintenance completed, cleaned %d windows", cleaned_count));
   
   return true;
}

//+------------------------------------------------------------------+
//| Enhanced window creation with validation                        |
//+------------------------------------------------------------------+
int CWindowManagerOptimized::CreateIndicatorWindow(string window_name, int indicator_handle, int height = 100)
{
   // Pre-creation validation
   if(indicator_handle == INVALID_HANDLE)
   {
      LogWindowInfo("CREATE_ERROR", -1, 
                   StringFormat("Invalid indicator handle for window '%s'", window_name), 2);
      IncrementErrorCount();
      return -1;
   }
   
   if(m_window_count >= m_max_windows)
   {
      LogWindowInfo("CREATE_ERROR", -1, 
                   StringFormat("Maximum window limit (%d) reached", m_max_windows), 2);
      IncrementErrorCount();
      return -1;
   }
   
   if(!CheckMemoryLimits())
   {
      LogWindowInfo("CREATE_WARNING", -1, "Low memory warning during window creation", 1);
   }
   
   // Attempt window creation
   int sub_window = ChartIndicatorAdd(m_chart_id, 0, indicator_handle);
   if(sub_window < 0)
   {
      int error_code = GetLastError();
      LogWindowInfo("CREATE_ERROR", -1, 
                   StringFormat("Failed to add indicator for window '%s', Error: %d", 
                              window_name, error_code), 2);
      IncrementErrorCount();
      return -1;
   }
   
   // Set window height if specified
   if(height > 0)
   {
      if(!ChartSetInteger(m_chart_id, CHART_HEIGHT_IN_PIXELS, height, sub_window))
      {
         LogWindowInfo("CREATE_WARNING", sub_window, 
                      StringFormat("Failed to set height %d for window '%s'", height, window_name), 1);
      }
   }
   
   // Expand windows array if needed
   if(m_window_count >= ArraySize(m_windows))
   {
      ArrayResize(m_windows, ArraySize(m_windows) + 5);
   }
   
   // Register the new window with full info
   m_windows[m_window_count].window_index = sub_window;
   m_windows[m_window_count].window_name = window_name;
   m_windows[m_window_count].indicator_handle = indicator_handle;
   m_windows[m_window_count].is_active = true;
   m_windows[m_window_count].created_time = TimeCurrent();
   m_windows[m_window_count].memory_usage = 1024; // Estimated base memory usage
   
   LogWindowInfo("CREATE", sub_window, 
                StringFormat("Window '%s' created successfully with height %d", window_name, height));
   
   m_window_count++;
   return sub_window;
}

//+------------------------------------------------------------------+
//| Enhanced window validation                                       |
//+------------------------------------------------------------------+
bool CWindowManagerOptimized::ValidateAllWindows()
{
   int invalid_count = 0;
   
   for(int i = 0; i < m_window_count; i++)
   {
      if(m_windows[i].is_active)
      {
         if(!ValidateWindowIndex(m_windows[i].window_index))
         {
            LogWindowInfo("VALIDATE_ERROR", m_windows[i].window_index, 
                         StringFormat("Window '%s' failed validation", m_windows[i].window_name), 1);
            invalid_count++;
         }
      }
   }
   
   LogWindowInfo("VALIDATE", -1, StringFormat("Validation completed: %d invalid windows found", invalid_count));
   return (invalid_count == 0);
}

//+------------------------------------------------------------------+
//| Check system health                                              |
//+------------------------------------------------------------------+
bool CWindowManagerOptimized::CheckSystemHealth()
{
   bool health_ok = true;
   
   // Check chart validity
   if(!ValidateChartId())
   {
      LogWindowInfo("HEALTH_ERROR", -1, "Chart ID validation failed", 2);
      health_ok = false;
   }
   
   // Check memory limits
   if(!CheckMemoryLimits())
   {
      LogWindowInfo("HEALTH_WARNING", -1, "Memory limits approaching", 1);
   }
   
   // Check error rate
   if(m_error_count > 10)
   {
      LogWindowInfo("HEALTH_WARNING", -1, StringFormat("High error count: %d", m_error_count), 1);
   }
   
   // Check window consistency
   if(!ValidateAllWindows())
   {
      LogWindowInfo("HEALTH_WARNING", -1, "Window validation issues detected", 1);
   }
   
   return health_ok;
}

//+------------------------------------------------------------------+
//| Private helper methods                                           |
//+------------------------------------------------------------------+
bool CWindowManagerOptimized::ValidateChartId()
{
   return (m_chart_id > 0 && ChartSymbol(m_chart_id) != "");
}

bool CWindowManagerOptimized::CheckMemoryLimits()
{
   // Simple memory check - in real implementation, could check actual memory usage
   long memory_usage = GetTotalMemoryUsage();
   return (memory_usage < 50 * 1024 * 1024); // 50MB limit
}

void CWindowManagerOptimized::IncrementErrorCount()
{
   m_error_count++;
   if(m_error_count > 100) // Reset counter to prevent overflow
      m_error_count = 50;
}

bool CWindowManagerOptimized::IsMaintenanceRequired()
{
   return (TimeCurrent() - m_last_cleanup > m_cleanup_interval);
}

void CWindowManagerOptimized::CompactWindowArray()
{
   int write_index = 0;
   
   for(int read_index = 0; read_index < m_window_count; read_index++)
   {
      if(m_windows[read_index].is_active)
      {
         if(write_index != read_index)
         {
            m_windows[write_index] = m_windows[read_index];
         }
         write_index++;
      }
   }
   
   m_window_count = write_index;
   LogWindowInfo("COMPACT", -1, StringFormat("Array compacted to %d active windows", m_window_count));
}

long CWindowManagerOptimized::GetTotalMemoryUsage()
{
   long total = 0;
   for(int i = 0; i < m_window_count; i++)
   {
      if(m_windows[i].is_active)
         total += m_windows[i].memory_usage;
   }
   return total;
}

//+------------------------------------------------------------------+
//| Enhanced logging with levels                                    |
//+------------------------------------------------------------------+
void CWindowManagerOptimized::LogWindowInfo(string operation, int window_index, string details = "", int level = 0)
{
   if(!m_debug_mode && level == 0)
      return;
      
   string level_str = "";
   switch(level)
   {
      case 0: level_str = "DEBUG"; break;
      case 1: level_str = "WARNING"; break;
      case 2: level_str = "ERROR"; break;
      default: level_str = "INFO"; break;
   }
   
   string log_message = StringFormat("[%s] WindowManager::%s", level_str, operation);
   
   if(window_index >= 0)
      log_message += StringFormat(" [Window:%d]", window_index);
      
   if(details != "")
      log_message += " - " + details;
      
   Print(log_message);
}
