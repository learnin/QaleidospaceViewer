import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ApplicationContextSettable {

    var appContext: ApplicationContext!
    
    var apiManager: APIManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath)
        
        let item = apiManager!.results[indexPath.row]
        cell.textLabel?.text = item.title.text
//        cell.detailTextLabel?.text = item.title.href.absoluteString
        return cell
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

