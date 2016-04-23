import UIKit

// Pocket SDKに https://github.com/Pocket/Pocket-ObjC-SDK/pull/21 の修正が必要
import PocketAPI

// 「Send to Pocket」を出すためのUIActivity(Shareボタン押下時に表示するモーダル画面に表示)
class PocketUIActivity: UIActivity {

    var url: NSURL? = nil
    
    override func activityTitle() -> String? {
        return "Send to Pocket"
    }
    
    override func activityImage() -> UIImage? {
        return nil
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return activityItems.contains({$0.isKindOfClass(NSURL)})
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        url = activityItems.filter({$0.isKindOfClass(NSURL)}).first as? NSURL
    }
    
    override func performActivity() {
        if (!PocketAPI.sharedAPI().loggedIn) {
            PocketAPI.sharedAPI().loginWithHandler({_, error in
                if (error != nil) {
                    return
                }
                self.performActivity()
                return
            })
        } else {
            PocketAPI.sharedAPI().saveURL(url, handler: {_, _, error in
                if (error != nil) {
                    self.activityDidFinish(false)
                } else {
                    self.showSuccessAlert()
                    self.activityDidFinish(true)
                }
            })
        }
    }
    
    func showSuccessAlert() {
        let alert: UIAlertController = UIAlertController(title: "sent!", message: nil, preferredStyle:  UIAlertControllerStyle.Alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            print("OK")
        })
        alert.addAction(defaultAction)
        
        // 親のViewControllerを探しだす
        var baseView: UIViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
        while (baseView.presentedViewController != nil && !baseView.presentedViewController!.isBeingDismissed()) {
            baseView = baseView.presentedViewController!
        }
        baseView.presentViewController(alert, animated: true, completion: nil)
    }

}