# Symfonie barev 

(tak nějak se to jmenuje...)

## Instalace a závislosti

- [Processing 4.4.2](https://processing.org/download)
- [UiBooster for Processing](https://github.com/Milchreis/UiBooster)
- [oscP5](https://github.com/sojamo/oscp5)
- [Processing video](https://processing.org/reference/libraries/video/index.html)
- [SuperCollider](https://supercollider.github.io/)

## Konfigurace závislostí
- do PATH přidat cestu k `processing-java` (kvůli `run.bat`)
- v SuperCollideru nastavit složku v projektu `./sc` do `Interpreter Options` 
    - v této složce jsou `.sc` soubory s třídami pro ovládání zvuku
    - `Edit > Preferences > Interpreter > Incerpreter Options > Include > +`

- hodí se přidat do PATH také cestu k `sclang`, ale není to nutné

## Spuštění

```shell
./run.bat
```

## Kalibrace

Klávesa `c` otevře dialogové okno pro kalibraci.

Aktuální stav je vždy uložen do JSONů v `data/_current`, odkud se načte při dalším spuštění.

Kalibrace dále umožňuje:
- uložit stav do `./data/_backup`
- obnovit stav z `./data/_backup`
- obnovit tovární nastavení z `./data/_factory`

## Autor

Jan Jáchim, 2025

[moichim.vercel.app](https://moichim.vercel.app)