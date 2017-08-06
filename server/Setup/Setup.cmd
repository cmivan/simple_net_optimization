@echo off
@echo ┌────────────────┐
@echo │ 网络优化工具 服务程序 Bate 1.0 │
@echo │ For : 齐翔广告(fly^&idea)       │
@echo │ By  : cm.ivan ^@卡mi伊凡        │
@echo └────────────────┘
@ping -n 2 127.1>nul
@echo 正结束服务进程...
@echo ----------------------------------
@taskkill /f /im NetOptimizationSer.exe
@echo.
@echo.

@ping -n 2 127.1>nul
@echo 正在清除服务...
@echo ----------------------------------
@ping -n 2 127.1>nul
@sc delete NetOptimizationSer
@echo.
@echo.

@ping -n 1 127.1>nul
@echo 正在创建安装目录...
@echo ----------------------------------
@ping -n 1 127.1>nul
mkdir C:\WINDOWS\NetOptimizationSer
@echo.
@echo.

@ping -n 1 127.1>nul
@echo 正在复制文件到安装目录...
@echo ----------------------------------
@ping -n 1 127.1>nul
@copy NetOptimizationSer.exe C:\WINDOWS\NetOptimizationSer\NetOptimizationSer.exe
@echo.
@echo.

@ping -n 1 127.1>nul
@echo 正在安装服务...
@echo ----------------------------------
@ping -n 1 127.1>nul
@C:\WINDOWS\NetOptimizationSer\NetOptimizationSer.exe /install
@echo.
@echo.

@ping -n 1 127.1>nul
@echo 正在启动服务...
@echo ----------------------------------
@ping -n 1 127.1>nul
@net start NetOptimizationSer
@echo.
@echo.

@ping -n 1 127.1>nul
@echo 安装完成!