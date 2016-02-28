import UIKit

class DetailViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var url = NSURL(string: "http://qaleido.space/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.delegate = self
        let request = NSURLRequest(URL: url!)
        self.webView.loadRequest(request)
    }
    
}
