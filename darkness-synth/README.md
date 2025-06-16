### Explanation:
1. **SynthDef**: The `polyLayeredSynth` is defined with parameters for frequency, depth, attack, sustain, release, pan, speed, and orientation.
2. **Frequency Envelope**: The frequency envelope is created using an exponential curve to transition between start and end frequencies based on the depth parameters.
3. **Vibrato**: The vibrato effect is controlled by two speed parameters, allowing for dynamic modulation of the pitch.
4. **Orientation Effect**: The orientation parameter is used to control a low-pass filter cutoff frequency, affecting the tonal quality of the sound.
5. **Amplitude**: The amplitude is fixed at 1, ensuring that the output level is consistent.
6. **Pan**: The output is panned based on the pan parameter.
7. **DarknessToolSynth**: An instance of `DarknessToolSynth` is created to control the new synth, allowing for easy manipulation of its parameters.

You can further expand this synth by adding more parameters or effects as needed.