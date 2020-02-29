//
//  AudioRecorder.swift
//  BookCore
//
//  Created by Q YiZhong on 2020/2/29.
//

import Foundation
import AVFoundation

class AudioRecorder {
    
    public let recorder: AVAudioRecorder
    
    public var finishClosure: ((_ flag: Bool, _ url: URL) -> Void)? {
        return delegateHandler.finishClosure
    }
    
    private var delegateHandler = EditAudioRecorderDelegateHandler()
    
    let path = FileManager.default.temporaryDirectory
    
    public init() throws {
        let timestamp = String.timestamp()
        let fileURL = path.appendingPathComponent("record\(timestamp).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitDepthHintKey: 16,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        recorder = try AVAudioRecorder(url: fileURL, settings: settings)
        recorder.isMeteringEnabled = true
        recorder.delegate = delegateHandler
        recorder.prepareToRecord()
    }
    
    public func record() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        recorder.record()
    }
    
    public func pause() {
        recorder.pause()
    }
    
    public func stop(_ closure: @escaping (_ flag: Bool, _ url: URL) -> Void) {
        delegateHandler.finishClosure = closure
        recorder.stop()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .defaultToSpeaker)
        } catch {
            print(error)
        }
    }
    
}

fileprivate class EditAudioRecorderDelegateHandler: NSObject {
    
    var finishClosure: ((_ flag: Bool, _ url: URL) -> Void)?
    
}

extension EditAudioRecorderDelegateHandler: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        finishClosure?(flag, recorder.url)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        guard let error = error else { return }
        print(error)
    }
    
}

