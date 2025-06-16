@echo off

REM Spustí SuperCollider dokument sound.scd přes sclang
start "" "C:\Program Files\SuperCollider-3.13.0\sclang.exe" "c:\Users\jachi\Documents\GitHub\darkness\sound.scd"

REM Počkej pár sekund, aby se sclang stihl spustit (volitelné)
timeout /t 5

REM Spustí Processing s projektem darkness.pde (nebo celou složku projektu)
REM Spustí Processing sketch přes processing-java (musí být v PATH)
processing-java --sketch="c:\Users\jachi\Documents\GitHub\darkness" --run