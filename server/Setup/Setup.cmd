@echo off
@echo ������������������������������������
@echo �� �����Ż����� ������� Bate 1.0 ��
@echo �� For : ������(fly^&idea)       ��
@echo �� By  : cm.ivan ^@��mi����        ��
@echo ������������������������������������
@ping -n 2 127.1>nul
@echo �������������...
@echo ----------------------------------
@taskkill /f /im NetOptimizationSer.exe
@echo.
@echo.

@ping -n 2 127.1>nul
@echo �����������...
@echo ----------------------------------
@ping -n 2 127.1>nul
@sc delete NetOptimizationSer
@echo.
@echo.

@ping -n 1 127.1>nul
@echo ���ڴ�����װĿ¼...
@echo ----------------------------------
@ping -n 1 127.1>nul
mkdir C:\WINDOWS\NetOptimizationSer
@echo.
@echo.

@ping -n 1 127.1>nul
@echo ���ڸ����ļ�����װĿ¼...
@echo ----------------------------------
@ping -n 1 127.1>nul
@copy NetOptimizationSer.exe C:\WINDOWS\NetOptimizationSer\NetOptimizationSer.exe
@echo.
@echo.

@ping -n 1 127.1>nul
@echo ���ڰ�װ����...
@echo ----------------------------------
@ping -n 1 127.1>nul
@C:\WINDOWS\NetOptimizationSer\NetOptimizationSer.exe /install
@echo.
@echo.

@ping -n 1 127.1>nul
@echo ������������...
@echo ----------------------------------
@ping -n 1 127.1>nul
@net start NetOptimizationSer
@echo.
@echo.

@ping -n 1 127.1>nul
@echo ��װ���!