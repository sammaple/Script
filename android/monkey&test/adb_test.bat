FOR /L %%i IN (1,1,500000) DO call :mYfuction 
goto :eof 
:mYfuction 
CHOICE /T 1 /C ync /CS /D y 
rem ȷ�ϼ� 
adb shell input keyevent 23 

rem �ȴ�7�� ping����7�β�ʹ��Ĭ�ϵĴ���,nul�ǲ���ʾping��Ϣ
@ping -n 7 127.0.0.1 > nul

CHOICE /T 2 /C ync /CS /D y 
rem ���ؼ� 
adb shell input keyevent 4

CHOICE /T 3 /C ync /CS /D y 
rem ȷ�ϼ� 
adb shell input keyevent 23 
