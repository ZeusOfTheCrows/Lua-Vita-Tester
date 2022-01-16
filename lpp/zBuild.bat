@set "title=VPad Tester & Configurator"
@set id=ZVTC
vita-mksfoex -s TITLE_ID=%id%88888 "%title%" ..\src\sce_sys\param.sfo
7z a -tzip "%title: =-%.vpk" -r ..\src\* ..\src\eboot.bin