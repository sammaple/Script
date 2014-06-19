FOR /L %%i IN (1,1,500000) DO call :mYfuction 
goto :eof 
:mYfuction 
CHOICE /T 1 /C ync /CS /D y 
rem 确认键 
adb shell input keyevent 23 

rem 等待7秒 ping本机7次不使用默认的次数,nul是不显示ping信息
@ping -n 7 127.0.0.1 > nul

CHOICE /T 2 /C ync /CS /D y 
rem 返回键 
adb shell input keyevent 4

CHOICE /T 3 /C ync /CS /D y 
rem 确认键 
adb shell input keyevent 23 
