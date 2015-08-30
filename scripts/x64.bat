@echo off
setlocal ENABLEEXTENSIONS

set PLATFORM=x64
set REIPATCHER_URL=https://mega.co.nz/#!rsImja6D!Of4s5lsD7y9JylVZ7miWg63Mxt5MVKniLgWqBr0oJl8
set REIPATCHER_7Z=ReiPatcher_0.9.0.7.7z
set UNITYINJECTOR_URL=https://mega.co.nz/#!m1YV1CpI!Knssx6-S1q2q6Qfuq8cFQQ6LKZeA-JiLRm4I7tkQxo8
set UNITYINJECTOR_7Z=UnityInjector_1.0.1.1.7z
set PASSWD=byreisen

set ZIP_URL=https://github.com/neguse11/cm3d2_plugins_okiba/archive/master.zip
set ZIP=master.zip

set _7Z_URL=http://sourceforge.net/projects/sevenzip/files/7-Zip/9.20/7za920.zip
set _7Z_FILE=7za920.zip

set DP0=%~dp0
set ROOT=%DP0:~0,-1%

set REIPATCHER_INI=%ROOT%\ReiPatcher\CM3D2%PLATFORM%.ini
set _7z="%ROOT%\_7z\7za.exe"
set CSC=C:\Windows\Microsoft.NET\Framework\v3.5\csc.exe
set MEGADL="%ROOT%\cm3d2_plugins_okiba-master\scripts\megadl.exe"

set INSTALL_PATH=
set MOD_PATH=
set SAME_PATH=


@rem
@rem INSTALL_PATHにレジストリ内のインストールパスを入れる
@rem
set INSTALL_PATH_REG_KEY="HKCU\Software\KISS\カスタムメイド3D2"
set INSTALL_PATH_REG_VALUE=InstallPath

@rem http://stackoverflow.com/questions/445167/
for /F "usebackq skip=2 tokens=1-2*" %%A in (`REG QUERY %INSTALL_PATH_REG_KEY% /v %INSTALL_PATH_REG_VALUE% 2^>nul`) do (
    set INSTALL_PATH=%%C
)

if not exist "%INSTALL_PATH%\GameData\csv.arc" (
    set INSTALL_PATH=
)

if defined INSTALL_PATH (
    set INSTALL_PATH=%INSTALL_PATH:~0,-1%
)


@rem
@rem MOD_PATHに改造版のパスを入れる
@rem

if not exist "%ROOT%\GameData\csv.arc" (
    goto mod_end
)
set MOD_PATH=%ROOT%

:mod_end


@rem
@rem INSTALL_PATHとMOD_PATHが同一かどうか確認し、結果をSAME_PATHに入れる
@rem
if defined INSTALL_PATH (
  if defined MOD_PATH (
    echo.>"%INSTALL_PATH%\__dummy__test__file__"
    if exist "%ROOT%\__dummy__test__file__" (
      set SAME_PATH=True
    )
    del "%INSTALL_PATH%\__dummy__test__file__"
  )
)


if defined SAME_PATH (
  echo 通常のゲームがインストールされたフォルダーでの実行はできません
  echo 改造版用のフォルダーを別に作り、そこで実行してください
  exit /b 1
)

if not exist "%ROOT%\CM3D2%PLATFORM%_Data" (
  echo 指定されたプラットフォーム「%PLATFORM%」用のデータフォルダーがありません
  echo 適切なプラットフォームを指定してください
  exit /b 1
)


@rem
@rem %ROOT%\_7z\ 下に 7zip を展開する
@rem

mkdir _7z >nul 2>&1
pushd _7z
echo 7zのアーカイブ「%_7Z_URL%」のダウンロード、展開中
powershell -Command "(New-Object Net.WebClient).DownloadFile('%_7Z_URL%', '%_7Z_FILE%')"
if not exist "%_7Z_FILE%" (
  echo 7zのアーカイブ %_7Z_URL% のダウンロードに失敗しました。
  exit /b 1
)
powershell -Command "$s=new-object -com shell.application;$z=$s.NameSpace('%ROOT%\_7z\%_7Z_FILE%');foreach($i in $z.items()){$s.Namespace('%ROOT%\_7z').copyhere($i,0x14)}"
echo 7zのアーカイブの展開完了
popd


@rem
@rem cm3d2_plugins_okibaのアーカイブをダウンロードし、
@rem %ROOT%\cm3d2_plugins_okiba\ 下に展開する
@rem

echo ZIPファイル「%ZIP_URL%」のダウンロード中

@rem http://stackoverflow.com/a/20476904/2132223
powershell -Command "(New-Object Net.WebClient).DownloadFile('%ZIP_URL%', '%ZIP%')"
if not exist "%ZIP%" (
  echo zipファイル %ZIP_URL% のダウンロードに失敗しました。
  exit /b 1
)

rmdir /s /q cm3d2_plugins_okiba-master >nul 2>&1

@rem http://www.howtogeek.com/tips/how-to-extract-zip-files-using-powershell/
@rem http://stackoverflow.com/questions/2359372/
%_7z% -y x "%ZIP%" >nul 2>&1
if not exist cm3d2_plugins_okiba-master\config.bat.txt (
  echo zipファイル %ZIP_URL% の展開に失敗しました
  exit /b 1
)
del %ZIP% >nul 2>&1

echo ZIPファイルをフォルダー「%ROOT%\cm3d2_plugins_okiba-master」に展開しました


@rem
@rem megadl のコンパイル
@rem
del %MEGADL% >nul 2>&1
pushd "%ROOT%\cm3d2_plugins_okiba-master\scripts\"
%CSC% /nologo megadl.cs
popd
if not exist %MEGADL% (
  echo 「%ROOT%\cm3d2_plugins_okiba-master\scripts\megadl.cs」のコンパイルに失敗しました
  exit /b 1
)


@rem
@rem %ROOT%\ 下に ReiPatcher をダウンロード
@rem
echo 「%REIPATCHER_URL%」をダウンロード中
%MEGADL% %REIPATCHER_URL% %REIPATCHER_7Z%
if not exist %REIPATCHER_7Z% (
  echo 「%REIPATCHER_URL%」のダウンロードに失敗しました
  exit /b 1
)


@rem
@rem %ROOT%\ 下に UnityInjector をダウンロード
@rem
echo 「%UNITYINJECTOR_URL%」をダウンロード中
%MEGADL% %UNITYINJECTOR_URL% %UNITYINJECTOR_7Z%
if not exist %UNITYINJECTOR_7Z% (
  echo 「%UNITYINJECTOR_7Z%」のダウンロードに失敗しました
  exit /b 1
)


@rem
@rem %ROOT%\ReiPatcher\ 下に ReiPatcher を展開する
@rem
if not exist "%REIPATCHER_7Z%" (
  echo ReiPatcherのアーカイブファイル「%REIPATCHER_7Z%」がありません
  echo アーカイブをダウンロードして、「%ROOT%」に配置してください
  exit /b 1
)

echo ReiPatcherのアーカイブ「%REIPATCHER_7Z%」の展開中
rmdir /s /q ReiPatcher >nul 2>&1
mkdir ReiPatcher >nul 2>&1
pushd ReiPatcher
%_7z% -y x ..\%REIPATCHER_7Z% -p%PASSWD% >nul 2>&1
mkdir Patches >nul 2>&1
echo ;Configuration file for ReiPatcher>%REIPATCHER_INI%
echo.>>%REIPATCHER_INI%
echo [ReiPatcher]>>%REIPATCHER_INI%
echo PatchesDir=Patches>>%REIPATCHER_INI%
echo ;@cm3d=%ROOT%>>%REIPATCHER_INI%
echo AssembliesDir=%%cm3d%%\CM3D2%PLATFORM%_Data\Managed>>%REIPATCHER_INI%
echo.>>%REIPATCHER_INI%
echo [Assemblies]>>%REIPATCHER_INI%
echo Assembly-CSharp=Assembly-CSharp.dll>>%REIPATCHER_INI%
echo.>>%REIPATCHER_INI%
echo [Launch]>>%REIPATCHER_INI%
echo Executable=>>%REIPATCHER_INI%
echo Arguments=>>%REIPATCHER_INI%
echo Directory=>>%REIPATCHER_INI%
echo.>>%REIPATCHER_INI%
echo [UnityInjector]>>%REIPATCHER_INI%
echo Class=SceneLogo>>%REIPATCHER_INI%
echo Method=Start>>%REIPATCHER_INI%
popd
echo ReiPatcherの展開完了


@rem
@rem %ROOT%\UnityInjector\ 下に UnityInjector を展開する
@rem
if not exist "%UNITYINJECTOR_7Z%" (
  echo ReiPatcherのアーカイブファイル「%UNITYINJECTOR_7Z%」がありません
  echo アーカイブをダウンロードして、「%ROOT%」に配置してください
  exit /b 1
)

echo UnityInjectorのアーカイブ「%UNITYINJECTOR_7Z%」の展開中
rmdir /s /q UnityInjector >nul 2>&1
mkdir UnityInjector >nul 2>&1
pushd UnityInjector
%_7z% -y x ..\%UNITYINJECTOR_7Z% -p%PASSWD% >nul 2>&1
copy /y Managed\*.dll ..\CM3D2%PLATFORM%_Data\Managed\ >nul 2>&1
copy /y ReiPatcher\*.dll ..\ReiPatcher\Patches\ >nul 2>&1
popd
echo UnityInjectorの展開完了


if defined SAME_PATH (
  set INSTALL_PATH=
  set MOD_PATH=
)

set TARGET=%ROOT%\cm3d2_plugins_okiba-master\config.bat

echo.>"%TARGET%"
echo @rem バニラの CM3D2 の位置>>"%TARGET%"
if defined INSTALL_PATH (
  echo set CM3D2_VANILLA_DIR=%INSTALL_PATH%>>"%TARGET%"
) else (
  echo set CM3D2_VANILLA_DIR=C:\KISS\CM3D2>>"%TARGET%"
)
echo.>>"%TARGET%"
echo @rem 改造版の CM3D2 の位置>>"%TARGET%"
if defined MOD_PATH (
  echo set CM3D2_MOD_DIR=%MOD_PATH%>>"%TARGET%"
) else (
  echo set CM3D2_MOD_DIR=C:\KISS\CM3D2_KAIZOU>>"%TARGET%"
)
echo.>>"%TARGET%"
echo @rem 64bit/32bit の選択 (64bitなら「x64」、32bitなら「x86」)>>"%TARGET%"
echo set CM3D2_PLATFORM=%PLATFORM%>>"%TARGET%"
echo.>>"%TARGET%"
echo @rem ReiPatcher の ini ファイル名>>"%TARGET%"
echo set REIPATCHER_INI=CM3D2%PLATFORM%.ini>>"%TARGET%"


echo.
echo あとは以下の操作をすることで、導入が完了します
echo.
echo (1)「%ROOT%\cm3d2_plugins_okiba-master\config.bat」
echo    内の「CM3D2_VANILLA_DIR」と「CM3D2_MOD_DIR」を確認し、
echo    必要なら環境に合わせて書き換えてください
echo.
echo (2)「%ROOT%\cm3d2_plugins_okiba-master\compile-patch-and-go.bat」
echo    を実行すると、コンパイル、パッチ操作が行われた後、ゲームが起動します
echo.
