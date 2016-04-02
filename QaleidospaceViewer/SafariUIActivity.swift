import UIKit

// 「Safariで開く」を出すためのUIActivity(Shareボタン押下時に表示するモーダル画面に表示)
class SafariUIActivity: UIActivity {

    var url: NSURL? = nil
    
    override func activityTitle() -> String? {
        return "Safariで開く"
    }
    
    override func activityImage() -> UIImage? {
        return nil
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return activityItems.contains({$0.isKindOfClass(NSURL) && UIApplication.sharedApplication().canOpenURL($0 as! NSURL)})
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        url = activityItems.filter({$0.isKindOfClass(NSURL)}).first as? NSURL
    }
    
    override func performActivity() {
        UIApplication.sharedApplication().openURL(url!)
        self.activityDidFinish(true)
    }

}