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

Create an `AudioSampler` which receives the MIDI messages and synthetizes them.

```swift
// soundbankURL can be a URL to an sf2 soundbank file. 
let sampler = try AudioSampler(soundbank: soundbankURL)

// Attach a MIDIService to the sampler.
sampler.attach(controller)

// Connect the sampler.node to an AVAudioEngine.
audioEngine.attach(sampler.node)
audioEngine.connect(sampler.node, to: audioEngine.mainMixerNode, format: nil)
try engine.start()
``` 

## Advanced

### Decoding MIDIEvent

The `AudioSampler` handles noteOn noteOff and sustain pedal messages.

```swift
enum MIDIEvent {
    case noteOn(note: Note, velocity: Velocity)
    case noteOff(note: Note)
    case sustain(Bool)
}
```

The conversion from `CoreMIDI.MIDIEventPacket` to `MIDIEvent` happanes in a `MIDICodingStrategy` implementation.

```swift
protocol MIDICodingStrategy {
    var verion: MIDIProtocolID { get }
    func decode(event: MIDIEventPacket) -> MIDIEvent?
}
```

Confirming to this protocol you can create your own custom MIDIEvent conversion for your own MIDI controller.

```swift
let controller = MIDIController(decoder: CustomAKAICoder())
```

Or you can use the default MIDI 1.0 coder and add a fallback operator for unhandled MIDI events.

```swift
let controller = MIDIController(decoder: .default_v1.fallback(PadsDecoder()))
```
