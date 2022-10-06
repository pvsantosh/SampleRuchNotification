
import UserNotifications
import FirebaseMessaging

class NotificationService: UNNotificationServiceExtension {
  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?
  
  override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
      self.contentHandler = contentHandler
      bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
    
    guard let bestAttemptContent = bestAttemptContent,
            let fcmOptions = bestAttemptContent.userInfo["fcm_options"] as? [String: Any],
            let attachmentUrlAsString = fcmOptions["image"] as? String,
            let attachmentUrl = URL(string: attachmentUrlAsString) else {
                return
        }
    
      let mediaInfo = bestAttemptContent.userInfo
      Messaging.serviceExtension().populateNotificationContent(bestAttemptContent, withContentHandler: contentHandler)
      print("media info for push is: \(mediaInfo)")
      downloadImageFrom(url: attachmentUrl) { (attachment) in
          if let attachment = attachment {
              bestAttemptContent.attachments = [attachment]
              contentHandler(bestAttemptContent)
              Messaging.serviceExtension().populateNotificationContent(bestAttemptContent, withContentHandler: contentHandler)
          }
      }
  }

  override func serviceExtensionTimeWillExpire() {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
      print("media info for push is timeout")

    if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }
}



extension NotificationService {
private func downloadImageFrom(url: URL, with completionHandler: @escaping (UNNotificationAttachment?) -> Void){
    let task = URLSession.shared.downloadTask(with: url) { (downloadedUrl, response, error) in
        guard let downloadedUrl = downloadedUrl else {
            completionHandler(nil)
            return
        }
        var urlPath = URL(fileURLWithPath: NSTemporaryDirectory())
        let uniqueUrlEnding = ProcessInfo.processInfo.globallyUniqueString + ".jpg"
        urlPath = urlPath.appendingPathComponent(uniqueUrlEnding)
        
        try? FileManager.default.moveItem(at: downloadedUrl, to: urlPath)
        
        do {
            let attachment = try UNNotificationAttachment(identifier: "picture", url: urlPath, options: nil)
            completionHandler(attachment)
        } catch {
            completionHandler(nil)
        }
    }
    task.resume()
}
}

