# MIDIPianoSampler

An easy to use CoreMIDI and AudioSampler library.

## Usage

Create a `MIDIController` which handles MIDI devices and receives MIDI messages.

```swift
// Create the MIDISession.
let controller = MIDIController()

// Retreive the devices connected to the system.
let devices = controller.inputDevices

// Set a selected device for the controller as input.
controller.set(device: selectedDevice)
```

Create an `AudioSampler` which receives the MIDI messages and synthetizes it.

```swift
let sampler = try AudioSampler(soundbank: soundbankURL)

// Attach a MIDIService to the sampler.
sampler.attach(controller)

// Connect the sampler.node to an AVAudioEngine.
audioEngine.attach(sampler.node)
audioEngine.connect(sampler.node, to: audioEngine.mainMixerNode, format: nil)
try engine.start()
``` 

