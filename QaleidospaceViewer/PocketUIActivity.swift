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
                    self.activityDidFinish(true)
                }
            })
        }
    }

}