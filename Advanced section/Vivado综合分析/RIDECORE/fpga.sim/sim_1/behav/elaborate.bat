@echo off
set xv_path=D:\\software\\vivado\\Vivado\\2016.4\\bin
call %xv_path%/xelab  -wto c629a364bfa94b34bd0457b0fb39c3d8 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot top_behav xil_defaultlib.top xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
