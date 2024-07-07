//
//  QRScannerView.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 7/8/24.
//

import SwiftUI
import AVFoundation

struct QRScannerView: UIViewControllerRepresentable {
    var onScanResult: (String) -> Void

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRScannerView
        var captureSession: AVCaptureSession?

        init(parent: QRScannerView, captureSession: AVCaptureSession?) {
            self.parent = parent
            self.captureSession = captureSession
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                      readableObject.type == .qr,
                      let stringValue = readableObject.stringValue else { return }

                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                captureSession?.stopRunning()  // Stop the capture session after a successful scan
                DispatchQueue.main.async {
                    self.parent.onScanResult(stringValue)
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self, captureSession: AVCaptureSession())
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        checkCameraAuthorizationStatus { authorized in
            DispatchQueue.main.async {
                if authorized {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.setupCamera(viewController: viewController, context: context)
                    }
                } else {
                    viewController.dismiss(animated: true, completion: nil)
                }
            }
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    private func checkCameraAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    private func setupCamera(viewController: UIViewController, context: Context) {
        let captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }

        DispatchQueue.main.async {
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = viewController.view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            viewController.view.layer.addSublayer(previewLayer)

            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
        }
    }
}
