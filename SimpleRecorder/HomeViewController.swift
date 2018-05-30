//
//  HomeViewController.swift
//  SimpleRecorder
//
//  Created by xuexw on 2/1/18.
//  Copyright © 2018 XiaoweiXue. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController, AVAudioRecorderDelegate {

    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!

    var recordButton: UIButton!
    var playButton: UIButton!

    var recordingSession: AVAudioSession!


    override func viewDidLoad() {
        super.viewDidLoad()

        //stopButton.isEnabled = false
        //playButton.isEnabled = false

        setNavigationBarAndBackground()
        setRecordSession()  // Recorder UI will be loaded here.
        setPlayBackSession()
    }

    func setNavigationBarAndBackground() {

        let homeColor = UIColor.init(red:161, green:211, blue:249)
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        let bar = self.navigationController!.navigationBar
        bar.isTranslucent = false
        bar.barTintColor = homeColor
        bar.barStyle = .black
        navigationItem.title = "Simple Recorder"
        view.backgroundColor = homeColor

    }

    func setRecordSession() {

        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
            session.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordButtonUI()
                    } else {
                        self.loadFailUI()
                    }
                }
            }
        } catch {
            self.loadFailUI()
        }
    }

    /*
        This function gets called in setRecordSession.
        Load UI and configures the record button.
    */
    func loadRecordButtonUI() {
        let recordIcon = UIImage(named: "recordButton")?.withRenderingMode(.alwaysOriginal)
        let stopIcon = UIImage(named: "stopButton")?.withRenderingMode(.alwaysOriginal)
        recordButton = UIButton(frame: CGRect(x: 64, y: 64, width: 250, height: 100))
        //recordButton.setTitle("rec", for: .normal)
        recordButton.setImage(recordIcon, for: .normal)
        recordButton.setImage(stopIcon, for: .highlighted)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(recordButton)
    }
    func loadFailUI() {
        let failLabel = UILabel()
        failLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        failLabel.text = "Recording failed: please ensure the app has access to your microphone."
        failLabel.numberOfLines = 0
    }

    @objc func recordTapped() {
        if recorder == nil {
            startRecording()
        } else if recorder.isRecording {
            finishRecording(success: true)
        }
    }

    func startRecording() {


        print("Recording start")
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        let currentFileName = "recording-\(format.string(from: Date())).m4a"
        print(currentFileName)
        let audioURL = HomeViewController.getDocumentsDirectory().appendingPathComponent(currentFileName)


        if FileManager.default.fileExists(atPath: audioURL.absoluteString) {
            print("audiofile \(audioURL.absoluteString) exists")
        }

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            //AVEncoderBitRateKey: 32000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0
        ]

        do {
            print("Trying avrecorder...")
            recorder = try AVAudioRecorder(url: audioURL, settings: settings)
            recorder.delegate = self
            recorder.prepareToRecord()
            recorder.record()
        } catch {
            recorder = nil
            finishRecording(success: false)
            print("Record interrupted.")
            print(error.localizedDescription)
        }
    }

    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    // Stop recording if button tapped, or system cuts it.
    func finishRecording(success: Bool) {
        recorder?.stop()
        recorder = nil

        print("Recording finished")

        if success {
            print("Recording successful")
        } else {
            print("Recording failed")
            // recording failed :(
        }
    }



    func setPlayBackSession() {


    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Oops")
            finishRecording(success: false)
        }
    }



}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1)
    }
}

