//
//  DetailViewController.swift
//  BugReport
//
//  Created by David M Reed on 4/13/17.
//  Copyright © 2017 David M Reed. All rights reserved.
//

import UIKit
import ReplayKit

class DetailViewController: UIViewController, RPPreviewViewControllerDelegate {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var isRecording = false
    @IBOutlet weak var recordButton: UIButton!

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: NSDate? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    @IBAction func toggleRecord(_ sender: UIButton) {
        print("record pressed")
        if !isRecording {
            let recorder = RPScreenRecorder.shared()
            if recorder.isAvailable {
                recorder.isMicrophoneEnabled = true
                recorder.startRecording { (error: Error?) -> Void in
                    if error == nil {
                        print("recording")
                        self.isRecording = true
                        self.recordButton.setTitle("Stop recording", for: .normal)
                    } else {
                        // handle error
                        let errorMessage: String
                        if let e = error {
                            errorMessage = "Error recording. Please reboot your iOS device and try again.\n\(e.localizedDescription)"
                        } else {
                            errorMessage = "Error recording. Please reboot your iOS device and try again.\n"
                        }
                        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) -> Void in
                        })
                        alertController.addAction(okAction)

                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        } else {
            // already recording
            isRecording = false
            recordButton.setTitle("Start Recording", for: .normal)
            let recorder = RPScreenRecorder.shared()
            recorder.stopRecording { (previewController: RPPreviewViewController?, error: Error?) -> Void in
                if error == nil {
                    previewController?.previewControllerDelegate = self
                    let alertController = UIAlertController(title: "Recording", message: "View your recording?", preferredStyle: .alert)
                    let discardAction = UIAlertAction(title: "Discard", style: .cancel, handler: { (action: UIAlertAction) -> Void in
                        recorder.discardRecording(handler: { () -> Void in
                            // executed once recording has been discarded
                        })
                    })

                    let viewAction = UIAlertAction(title: "View", style: .default, handler: { (action: UIAlertAction) -> Void in
                        // need to specify the presentation style
                        // http://stackoverflow.com/questions/39624816/replaykit-rpbroadcastactivityviewcontroller-ipad
                        previewController?.modalPresentationStyle = .fullScreen
                        self.present(previewController!, animated: true, completion: nil)
                    })

                    alertController.addAction(discardAction)
                    alertController.addAction(viewAction)

                    self.present(alertController, animated: true, completion: nil)

                } else {
                    // handle error
                    let errorMessage: String
                    if let e = error {
                        errorMessage = "Error recording. Please reboot your iOS device and try again.\n\(e.localizedDescription)"
                    } else {
                        errorMessage = "Error recording. Please reboot your iOS device and try again.\n"
                    }
                    let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) -> Void in
                    })
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }

    }

    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }
    func previewController(_ previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        previewController.dismiss(animated: true, completion: nil)
    }
}

