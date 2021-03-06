//+------------------------------------------------------------------+
//|                                                       WILLCO.mq5 |
//|                                                           Volder |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#property copyright "Volder"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   6
#property script_show_inputs

#property indicator_label1 "Commercial Long/OI"
#property indicator_label2 "Commercial Short/OI"
#property indicator_label3 "Commercial All/OI"
#property indicator_label4 "WillCoLong"
#property indicator_label5 "WillCoShort"
#property indicator_label6 "WillCoAll"

#property indicator_color1 clrMaroon
#property indicator_color2 clrMediumSeaGreen
#property indicator_color3 clrOliveDrab
#property indicator_color4 clrFireBrick
#property indicator_color5 clrTeal
#property indicator_color6 clrPurple


#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2

//input Instruments current_instrument = CURRENT;        //Отобразить на графике
input ENUM_DRAW_TYPE styling1 = DRAW_NONE;               //Commercial Long/OI
input ENUM_DRAW_TYPE styling2 = DRAW_NONE;               //Commercial Short/OI
input ENUM_DRAW_TYPE styling3 = DRAW_NONE;               //Commercial All/OI
input ENUM_DRAW_TYPE styling4 = DRAW_NONE;               //WillCoLong
input ENUM_DRAW_TYPE styling5 = DRAW_NONE;               //WillCoShort
input ENUM_DRAW_TYPE styling6 = DRAW_LINE;               //WillCoAll


input int p = 26;
int period = p*5;


//--- indicator buffers
double         COLongBuf[];
double         COShortBuf[];
double         COAllBuf[];
double         COIBuf[];
double         COIndLongBuf[];
double         COIndShortBuf[];
double         COIndAllBuf[];
double         WillCoLongtBuf[];
double         WillCoShortBuf[];
double         WillCoAllBuf[];

int COT_handle;

int OnInit()
{
   Print("Запуск индикатора WILLCO");
   SetIndexBuffer(0, COIndLongBuf, INDICATOR_DATA);
   SetIndexBuffer(1, COIndShortBuf, INDICATOR_DATA);
   SetIndexBuffer(2, COIndAllBuf, INDICATOR_DATA);
   SetIndexBuffer(3, WillCoLongtBuf, INDICATOR_DATA);
   SetIndexBuffer(4, WillCoShortBuf, INDICATOR_DATA);
   SetIndexBuffer(5, WillCoAllBuf, INDICATOR_DATA);
   SetIndexBuffer(6, COLongBuf, INDICATOR_CALCULATIONS);
   SetIndexBuffer(7, COShortBuf, INDICATOR_CALCULATIONS);
   SetIndexBuffer(8, COAllBuf, INDICATOR_CALCULATIONS);
   SetIndexBuffer(9, COIBuf, INDICATOR_CALCULATIONS);
   
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, styling1);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, styling2);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, styling3);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, styling4);
   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, styling5);
   PlotIndexSetInteger(5, PLOT_DRAW_TYPE, styling6);
   
   IndicatorSetString(INDICATOR_SHORTNAME, "WillCo: " + Symbol());
   Print(COT_handle = iCustom(NULL, 0, "COT\\COT"));
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   string started;
   int start = 0;
   int values_to_copy = 0;
   
   
   
   if(prev_calculated == 0) {
      ArrayInitialize(COIndLongBuf, 0);
      ArrayInitialize(COIndShortBuf, 0);
      ArrayInitialize(COIndAllBuf, 0);
      ArrayInitialize(WillCoLongtBuf, 0);
      ArrayInitialize(WillCoShortBuf, 0);
      ArrayInitialize(WillCoAllBuf, 0);
      ArrayInitialize(COLongBuf, 0);
      ArrayInitialize(COShortBuf, 0);
      ArrayInitialize(COAllBuf, 0);
      ArrayInitialize(COIBuf, 0);
      
      CopyBuffer(COT_handle, 0, 0, rates_total, COLongBuf);
      CopyBuffer(COT_handle, 1, 0, rates_total, COShortBuf);
      CopyBuffer(COT_handle, 2, 0, rates_total, COAllBuf);
      CopyBuffer(COT_handle, 3, 0, rates_total, COIBuf);
   
   
      for(int i = start; i < rates_total; ++i) {
         COIndLongBuf[i] = COLongBuf[i]/COIBuf[i]*100;
         COIndShortBuf[i] = COShortBuf[i]/COIBuf[i]*100;
         COIndAllBuf[i] = COAllBuf[i]/COIBuf[i]*100;
      
      }
   
      for(int j = start + period - 1; j < rates_total; ++j) {
        WillCoLongtBuf[j] = 100*(
           (COIndLongBuf[j] - COIndLongBuf[ArrayMinimum(COIndLongBuf, j - period + 1, period)])/
           (COIndLongBuf[ArrayMaximum(COIndLongBuf, j - period + 1, period)] - COIndLongBuf[ArrayMinimum(COIndLongBuf, j - period + 1, period)])
        );
        WillCoShortBuf[j] = 100*(
            (COIndShortBuf[j] - COIndShortBuf[ArrayMinimum(COIndShortBuf, j - period + 1, period)])/
            (COIndShortBuf[ArrayMaximum(COIndShortBuf, j - period + 1, period)] - COIndShortBuf[ArrayMinimum(COIndShortBuf, j - period + 1, period)])
         );
         WillCoAllBuf[j] = 100*(
           (COIndAllBuf[j] - COIndAllBuf[ArrayMinimum(COIndAllBuf, j - period + 1, period)])/
           (COIndAllBuf[ArrayMaximum(COIndAllBuf, j - period + 1, period)] - COIndAllBuf[ArrayMinimum(COIndAllBuf, j - period + 1, period)])
        );
      }
   }
   
   return(rates_total);
}
//+------------------------------------------------------------------+
