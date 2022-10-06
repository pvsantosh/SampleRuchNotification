
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func checkpushBtn(_ sender: UIButton) {
        sendRequestPush()
    }
    
    func sendRequestPush()  {
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("key=\(Constant.fcmServerKey)", forHTTPHeaderField: "authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters = [
            "to":"",
            "notification" : [
                "body" : "Welcome",
                "OrganizationId":"2",
                "content_available" : true,
                "priority" : "high",
                "subtitle":"UttamTech",
                "Title":"UttamTech",
                "image": "https://lh3.googleusercontent.com/a/AItbvmlZgkvvH6L3nr1OZws6yoIhAEn1UBae1YDlVxMZ_g=s100"
            ],
            "image": "https://lh3.googleusercontent.com/a/AItbvmlZgkvvH6L3nr1OZws6yoIhAEn1UBae1YDlVxMZ_g=s100",
            "data" : [
                "priority" : "high",
                "sound":"app_sound.wav",
                "content_available" : true,
                "bodyText" : "New Announcement assigned",
                "organization" :"Elementary school",
                "image": "https://lh3.googleusercontent.com/a/AItbvmlZgkvvH6L3nr1OZws6yoIhAEn1UBae1YDlVxMZ_g=s100"
            ]
        ] as [String : Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let dataTask = session.dataTask(with: request as URLRequest) { data,response,error in
            let httpResponse = response as? HTTPURLResponse
            if (error != nil) {
                print(error!)
            } else {
                print(httpResponse!)
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            do {
                guard let responseDictionary = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
                print("The responseDictionary is: " + responseDictionary.description)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            DispatchQueue.main.async {
                //Update your UI here
            }
        }
        dataTask.resume()
    }
}

