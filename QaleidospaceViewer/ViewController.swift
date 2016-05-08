import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ApplicationContextSettable {

    var appContext: ApplicationContext!
    
    var apiManager: APIManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        guard let apiManager = APIManager(qaleidospaceAPI: appContext.qaleidospaceAPI) else { return }
        self.apiManager = apiManager
        apiManager.list(true) { [weak self] (error) in
            if let error = error {
                print(error)
            } else {
                self?.tableView.reloadData()
//                self?.searchController.active = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var tableView: UITableView!
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiManager?.results.count ?? 0
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath) as! CustomCell
        
        let item = apiManager!.results[indexPath.row]
        cell.customLabel.text = item.title
        cell.userName.text = item.userIconAlt
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = apiManager!.results[indexPath.row]
        performSegueWithIdentifier("toDetail", sender: item.URL)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toDetail") {
            let viewController : DetailViewController = segue.destinationViewController as! DetailViewController
            viewController.url = sender! as! NSURL
        }
    }
    
    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let apiManager = apiManager where indexPath.row >= apiManager.results.count - 1 {
            apiManager.list(false) { [weak self] (error) in
                if let error = error {
                    print(error)
                } else {
                    self?.tableView.reloadData()
                }
            }
        }
    }

}

