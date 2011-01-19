require 'win32ole'
# -4100 is the value for the Excel constant xl3DColumn.
ChartTypeVal = -4100;
excel = WIN32OLE.new("excel.application")
# Create and rotate the chart
excel['Visible'] = TRUE;
workbook = excel.Workbooks.Add();
excel.Range("a1")['Value'] = 3;
excel.Range("a2")['Value'] = 2;
excel.Range("a3")['Value'] = 1;
excel.Range("a1:a3").Select();
excelchart = workbook.Charts.Add();
excelchart['Type'] = ChartTypeVal;
loop do
  0.step 360 do |rot|
    excelchart['Rotation'] = rot
  end
end