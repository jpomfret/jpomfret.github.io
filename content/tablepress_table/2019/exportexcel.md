---
title: "ExportExcel"
date: "2019-05-28"
---

\[\["Parameter Name","Value","Comments"\],\["Path","$excelFile","The path to export the resulting Excel file to."\],\["WorksheetName","\\u2018OSVersions\\u2019","The name for the worksheet that will contain the data. If the excel file already exists but the worksheet name does not this will be added to that document."\],\["AutoSize","$True","Adjusts the width of the columns in your worksheet to the right size for your data."\],\["TableName ","\\u2018OSVersions\\u2019","Makes your result set into a table within your worksheet and names it."\],\["IncludePivotTable","$True","Adds a second worksheet with a pivot table of your data."\],\["PivotRows","'OSVersions'","The property of your data that will provide the rows for your pivot table."\],\["PivotData","@{OSVersion='Count'}","Fields to use in the body of your pivot table (in this example we are doing a simple count of the data)."\],\["IncludePivotChart","$True","Add the chart with our pivot table."\],\["ChartType","\\u2018ColumnClustered\\u2019","Define the kind of chart you want to display."\]\]
