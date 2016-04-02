import UIKit

class DetailViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var url = NSURL(string: "http://qaleido.space/")
    
    // 参考 http://kzy52.com/entry/2015/02/20/000838
    
    var toolBar: UIToolbar?
    var rewindButton = UIBarButtonItem()
    var fastForwardButton = UIBarButtonItem()
    var refreshButton = UIBarButtonItem()
    var shareButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.delegate = self
        self.webView.scalesPageToFit = true
        self.webView.scrollView.directionalLockEnabled = false
        self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
        
        // ビューサイズの自動調整
        self.webView.autoresizingMask = [.FlexibleRightMargin, .FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleWidth, .FlexibleHeight]
        
        // 横幅、高さ、ステータスバーの高さを取得する
        let width: CGFloat! = self.view.bounds.width
        let height: CGFloat! = self.view.bounds.height
        
        // ツールバーを生成する
        self.toolBar = self.createToolBar(frame: CGRectMake(0, height - 44, width, 40.0), position: CGPointMake(width / 2, height - 20.0))
        
        // サブビューを追加する
        self.view.addSubview(self.toolBar!)
        
        let request = NSURLRequest(URL: url!)
        self.webView.loadRequest(request)
        
        // インジケータを表示する
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // 前のページに戻れるかどうか
        self.rewindButton.enabled = self.webView!.canGoBack
        // 次のページに進めるかどうか
        self.fastForwardButton.enabled = self.webView!.canGoForward
        self.refreshButton.enabled = false
        self.shareButton.enabled = false
    }
    
    // ナビゲーションバーの"< Back"ボタンの処理
    @IBAction func onClickBackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // ツールバーを生成する
    func createToolBar(frame frame: CGRect, position: CGPoint) -> UIToolbar {
        // UIWebViewのインスタンスを生成
        let _toolBar = UIToolbar()
        
        // ツールバーのサイズを決める.
        _toolBar.frame = frame
        
        // ツールバーの位置を決める.
        _toolBar.layer.position = position
        
        // 文字色を設定する
        _toolBar.tintColor = UIColor.blueColor()
        // 背景色を設定する
        _toolBar.backgroundColor = UIColor.whiteColor()
        
        // 各ボタンを生成する
        // UIBarButtonItem(style, デリゲートのターゲットを指定, ボタンが押されたときに呼ばれるメソッドを指定)
        let spacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        self.rewindButton = UIBarButtonItem(barButtonSystemItem: .Rewind, target: self, action: #selector(DetailViewController.back(_:)))
        self.fastForwardButton = UIBarButtonItem(barButtonSystemItem: .FastForward, target: self, action: #selector(DetailViewController.forward(_:)))
        self.refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(DetailViewController.refresh(_:)))
        self.shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(DetailViewController.share(_:)))
        
        // ボタンをツールバーに入れる.
        _toolBar.items = [rewindButton, fastForwardButton, refreshButton, spacer, shareButton]
        
        return _toolBar
    }
    
    // WebViewがコンテンツの読み込みを開始した時に呼ばれる
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        self.rewindButton.enabled = self.webView!.canGoBack
        self.fastForwardButton.enabled = self.webView!.canGoForward
        self.refreshButton.enabled = true
        self.shareButton.enabled = true
    }
    
    // WebView がコンテンツの読み込みを完了した後に呼ばれる
    func webViewDidFinishLoad(webView: UIWebView) {
        // インジケータを非表示にする
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        self.rewindButton.enabled = self.webView!.canGoBack
        self.fastForwardButton.enabled = self.webView!.canGoForward
    }
    
    // 戻るボタンの処理
    @IBAction func back(_: AnyObject) {
        self.webView?.goBack()
    }
    
    // 進むボタンの処理
    @IBAction func forward(_: AnyObject) {
        self.webView?.goForward()
    }
    
    // 再読み込みボタンの処理
    @IBAction func refresh(_: AnyObject) {
        self.webView?.reload()
    }
    
    // Shareボタンの処理
    @IBAction func share(sender: UIBarButtonItem) {
        let activityItems = [
            self.webView.request!.URL!
        ]
        let activities = [SafariUIActivity()]
        let excludedActivityTypes = [
            UIActivityTypePrint,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAirDrop,
            UIActivityTypeMail,
            UIActivityTypeMessage
        ]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: activities)
        activityVC.excludedActivityTypes = excludedActivityTypes
        
        // ipad向けの設定
        if let presenter = activityVC.popoverPresentationController {
            presenter.barButtonItem = sender
        }
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
