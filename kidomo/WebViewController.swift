//
//  WebViewController.swift
//  kidomo
//
//  Created by qinqubo on 2024/5/30.
//
import WebKit
import CoreLocation

class WeakScriptMessageDelegate: NSObject {
    private weak var scriptDelegate: WKScriptMessageHandler!
    
    init(scriptDelegate: WKScriptMessageHandler) {
        self.scriptDelegate = scriptDelegate
    }
}

extension WeakScriptMessageDelegate: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.scriptDelegate.userContentController(userContentController, didReceive: message)
    }
}

class WebViewController: UIViewController {
    var coordinator: ViewControllerRepresentable.Coordinator?
    var url: URL!
    
    var locationManager = LocationManager.shared()
    let imagePicker = ImagePicker()
    
    var taskId: Int = 0
    
    internal lazy var wKWebView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.userContentController.add(WeakScriptMessageDelegate(scriptDelegate: self), name: "Callback")
        let preferences = WKPreferences()
        preferences.setValue(true, forKey: "developerExtrasEnabled")
        preferences.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = preferences
        
        let webView = WKWebView(frame: createWKWebViewFrame(size: view.frame.size), configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.isInspectable = true
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(wKWebView)
        
        // url = URL(string: "https://m-saas.opsfast.com/")
        // let request = URLRequest(url: url)
        // wKWebView.load(request)
        
        if let filePath = Bundle.main.path(forResource: "index", ofType: "html") {
            let fileURL = URL(fileURLWithPath: filePath)
            let fileDirectory = fileURL.deletingLastPathComponent()
            wKWebView.loadFileURL(fileURL, allowingReadAccessTo: fileDirectory)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationManager.hostController = self
        
        imagePicker.delegate = self
    }
    
    fileprivate func createWKWebViewFrame(size: CGSize) -> CGRect {
        // let navigationHeight: CGFloat = 60
        // let toolbarHeight: CGFloat = 44
        // let height = size.height - navigationHeight - toolbarHeight
        return CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
    
    deinit {
        wKWebView.configuration.userContentController.removeScriptMessageHandler(forName: "Callback")
    }
}

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // show indicator
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // dismiss indicator
        
        // if url is not valid {
        //    decisionHandler(.cancel)
        // }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // dismiss indicator
        
        // goBackButton.isEnabled = webView.canGoBack
        // goForwardButton.isEnabled = webView.canGoForward
        navigationItem.title = webView.title
        
        
        webView.evaluateJavaScript("callFromSwift('swift:hi javascript!')") { any, _ in
            guard let info = any else {
                return
            }
            print(info)
        }
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // show error dialog
    }
}

extension WebViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: { _ in
                completionHandler()
            }
        )
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension WebViewController: WKScriptMessageHandler {
    
    // Function to convert the dictionary to Data
    func convertToData(_ dictionary: [String: Any]) -> Data? {
        try? JSONSerialization.data(withJSONObject: dictionary, options: [])
    }

    // Function to decode the data to MessageData
    func decodeMessageData(from data: Data) -> MessageData? {
        let decoder = JSONDecoder()
        return try? decoder.decode(MessageData.self, from: data)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("name:\(message.name)")
        print("body:\(message.body)")
        
        guard let msg = message.body as? [String: Any], let action = msg["action"], let callBackFunction = msg["callback"] else { return }
        
        print("action:\(action) and callback:\(callBackFunction)")
        
        if action as! String == "camera" {
            if let messageBody = message.body as? [String: Any] {
                if let data = messageBody["data"] as? [String : Any] {
                    taskId = data["taskId"] as! Int
                    imagePicker.showImagePicker(from: self, allowsEditing: false)
                }
            }
        } else if action as! String == "back" {
            coordinator?.dismiss()
            self.wKWebView.evaluateJavaScript("\(callBackFunction)('swift:hi javascript!')") { any, _ in
                guard let info = any else {
                    return
                }
                print(info)
            }
        } else if action as! String == "location" {
            if let messageBody = message.body as? [String: Any] {
                if let data = messageBody["data"] as? [String : Any] {
                    taskId = data["taskId"] as! Int
                    locationManager.requestLocation()
                }
            }
        } else if action as! String == "set_header" {
            let viewModel = MessageViewModel()
            
            if let messageBody = message.body as? [String: Any] {
                if let jsonData = convertToData(messageBody["auth"] as! [String : Any]) {
                    print("jsonData:\(jsonData)")
                    if let messageData = decodeMessageData(from: jsonData) {
                        // Now you have a MessageData instance
                        print("BladeAuth: \(messageData.BladeAuth)")
                        print("Authorization: \(messageData.Authorization)")
                        viewModel.saveMessage(messageData)
                    } else {
                        print("Failed to decode JSON data to MessageData")
                    }
                } else {
                    print("Failed to convert dictionary to JSON data")
                }
            }
        }
    }
}

extension WebViewController: ImagePickerDelegate {
    
    func imagePicker(_ imagePicker: ImagePicker, didSelect image: UIImage) {
        guard let data = image.pngData() else {
            return
        }
        
        let string = data.base64EncodedString()

        imagePicker.dismiss(animated: true) {
            let complexData: [String: Any] = [
                "image": string,
                "taskId": self.taskId
            ]
            
            // Convert complex data to JSON string
            if let jsonData = try? JSONSerialization.data(withJSONObject: complexData, options: []),
               let jsonString = String(data: jsonData, encoding: .utf8) {

                // Call JavaScript function with the JSON string
                let jsCode = "nativeImageData(\(jsonString));"
                self.wKWebView.evaluateJavaScript(jsCode) { result, error in
                    if let error = error {
                        print("Error calling JavaScript: \(error)")
                    } else {
                        print("JavaScript result: \(String(describing: result))")
                    }
                }
            }

        }
    }
    
    func cancelButtonDidClick(on imagePicker: ImagePicker) {
        print("Image selection/capture was canceled")
        imagePicker.dismiss(animated: true)
    }
}

extension WebViewController: LocationManagerDelegate {
    func locationMananger(_ locationManger: LocationManager, didUpdateLocation location: CLLocation) {
        let complexData: [String: Any] = [
            "taskId": self.taskId,
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude
        ]
        // Convert complex data to JSON string
        if let jsonData = try? JSONSerialization.data(withJSONObject: complexData, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            
            // Call JavaScript function with the JSON string
            let jsCode = "nativeLocationData(\(jsonString));"
            
            self.wKWebView.evaluateJavaScript(jsCode) { result, error in
                if let error = error {
                    print("Error calling JavaScript: \(error)")
                } else {
                    print("JavaScript result: \(String(describing: result))")
                }
            }
        }
    }
}







