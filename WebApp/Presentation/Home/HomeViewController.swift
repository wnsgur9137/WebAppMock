//
//  HomeViewController.swift
//  WebApp
//
//  Created by JunHyeok Lee on 2023/08/31.
//

import UIKit
import Combine
import WebKit

final class HomeViewController: UIViewController {
    static func create(with viewModel: HomeViewModel, webURL: String) -> HomeViewController {
        let viewController = HomeViewController()
        viewController.viewModel = viewModel
        viewController.webURL = webURL
        return viewController
    }
    
    private let webKitView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private var popupView: WKWebView?
    
    private let paddingBarButtonItem: UIBarButtonItem = {
        let barButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        barButton.width = 24.0
        return barButton
    }()
    
    private let backBarButtonItem: UIBarButtonItem = {
        let barButton = UIBarButtonItem()
        barButton.image = Constants.AssetImage.chevronLeft
        barButton.style = .plain
        return barButton
    }()
    
    private let towardBarButtonItem: UIBarButtonItem = {
        let barButton = UIBarButtonItem()
        barButton.image = Constants.AssetImage.chevronRight
        barButton.style = .plain
        return barButton
    }()
    
    private var viewModel: HomeViewModel?
    private var webURL: String?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        initializeWebKit()
        
        addSubviews()
        setupWebKitViewLayout()
        
        setupBarButtonItem()
        configureBackBarButtonItem()
        configureTowardBarButtonItem()
        configureRefreshControl()
        
        guard let viewModel = viewModel else { return }
        subscribe(with: viewModel.isOffline)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.checkNetworkConnected()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func initializeWebKit() {
        guard let webURL = self.webURL else {
            fatalError("WebURL is null")
        }
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
            modifiedSince: Date(timeIntervalSince1970: 0)) { }
        
        webKitView.allowsBackForwardNavigationGestures = true
        
        if let url = URL(string: webURL) {
            let request = URLRequest(url: url)
            webKitView.load(request)
        } else {
            print("Error")
        }
        
        webKitView.navigationDelegate = self
        webKitView.uiDelegate = self
    }
    
    private func setupBarButtonItem() {
        toolbarItems = [backBarButtonItem, paddingBarButtonItem, towardBarButtonItem]
    }
    
    private func configureBackBarButtonItem() {
        backBarButtonItem.target = self
        backBarButtonItem.action = #selector(didTapToolBarBackButton)
    }
    
    @objc private func didTapToolBarBackButton() {
        webKitView.goBack()
    }
    
    private func configureTowardBarButtonItem() {
        towardBarButtonItem.target = self
        towardBarButtonItem.action = #selector(didTapToolBarTowardButton)
    }
    
    @objc private func didTapToolBarTowardButton() {
        webKitView.goForward()
    }
    
    private func configureRefreshControl() {
        webKitView.scrollView.refreshControl = UIRefreshControl()
        webKitView.scrollView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        webKitView.scrollView.refreshControl?.tintColor = UIColor(red: 187/255, green: 38/255, blue: 73/255, alpha: 1)
        webKitView.scrollView.showsHorizontalScrollIndicator = false
    }
    
    @objc func handleRefreshControl() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.webKitView.reload()
            self.webKitView.scrollView.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - Binding
extension HomeViewController {
    private func subscribe(with isOffline: PassthroughSubject<Bool, Never>) {
        isOffline
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isOffline in
                if isOffline {
                    let alertHandler: ((UIAlertAction) -> Void)? = { _ in
                        exit(0)
                    }
                    self?.showAlert(title: Constants.NetworkError.networkErrorTitle, description: Constants.NetworkError.networkErrorDescription, handler: alertHandler)
                }
            })
            .store(in: &cancellables)
    }
}

// MARK: - WKNavigationDelegate
extension HomeViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        backBarButtonItem.isEnabled = webView.canGoBack
        towardBarButtonItem.isEnabled = webView.canGoForward
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
}

// MARK: - WKUIDelegate Browser Alert
extension HomeViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let actionHandler: ((UIAlertAction) -> Void)? = { (action) in
            completionHandler()
        }
        self.showAlert(title: "", description: message, handler: actionHandler)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let cancelHandler: ((UIAlertAction) -> Void)? = { (action) in
            completionHandler(false)
        }
        let confirmHandler: ((UIAlertAction) -> Void)? = { (action) in
            completionHandler(true)
        }
        self.showAlertWithOK(title: "", description: message, confirmHandler: confirmHandler, cancelHandler: cancelHandler)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: Constants.Alert.confirm, style: .default) { (action) in
            if let text = alert.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - PopupView
extension HomeViewController {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        popupView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        popupView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popupView?.uiDelegate = self
        
        view.addSubview(popupView ?? WKWebView())
        return popupView
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        if webView == popupView {
            popupView?.removeFromSuperview()
            popupView = nil
        }
    }
}

// MARK: - Layout
extension HomeViewController {
    private func addSubviews() {
        self.view.addSubview(webKitView)
    }
    
    private func setupWebKitViewLayout() {
        NSLayoutConstraint.activate([
            webKitView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            webKitView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            webKitView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            webKitView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}
