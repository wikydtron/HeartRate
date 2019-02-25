//
//  ViewController.swift
//  HeartRateSample
//
//  Created by Francis Bosse on 2019-02-22.
//  Copyright © 2019 bosse. All rights reserved.
//

import UIKit
import HealthKit
import MessageUI

class ViewController: UIViewController, MFMailComposeViewControllerDelegate  {
    
    let healthStore = HKHealthStore()
    
    var heartRateData: [HKSample]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "exercise.jpg")!)
        getHealthKitPermission()
    }
    
    
    @IBOutlet weak var tblHeartRateData: UITableView!
    @IBAction func getHeartRate(_ sender: Any) {
    
        getTodaysHeartRate{ (result) in
            DispatchQueue.main.async {
                
                self.heartRateData = result
                self.tblHeartRateData.reloadData()
            }
        }
    }
    @IBAction func emailResult(_ sender: Any) {
        self.sendEmail()
    }
    
    //Permission
    func getHealthKitPermission() {
        if HKHealthStore.isHealthDataAvailable() {
            let healthkitTypesToRead = NSSet(array: [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
            ])
            let healthkitTypesToWritable = NSSet(array: [
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
                ])
        
            healthStore.requestAuthorization(toShare: healthkitTypesToWritable as? Set<HKSampleType>, read: healthkitTypesToRead as? Set) { (success, error) in
                print(success)
        }
        }
    }
    
    func showNilError() {
        let alert = UIAlertController(title: "No Heart Rate Data Found", message: "There was no heart rate data found. If you expected to see data, it may be that you did not authorised to read you heart rate data. Please go to the settings app (Privacy -> HealthKit) to change this.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Go to settings", style: .default, handler:  { action in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }            }))
        self.present(alert, animated: true, completion: nil)
    }
    var shownWarning : Bool = false
    //Get HealthKit Data
    func getTodaysHeartRate(completion: (@escaping ([HKSample]) -> Void)) {
        print("func")
        
        let heartRateType:HKQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        //predicate
        let startDate = Date() - 1 * 24 * 60 * 60
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        //descriptor
        let sortDescriptors = [
            NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        ]
        
        let heartRateQuery = HKSampleQuery(sampleType: heartRateType,
                                           predicate: predicate,
                                           limit: Int(HKObjectQueryNoLimit),
                                           sortDescriptors: sortDescriptors)
        { (query:HKSampleQuery, results:[HKSample]?, error:Error?) -> Void in
            
            guard error == nil else { print("error"); return }
            guard let results = results else { return }
            if results.count == 0 && !self.shownWarning {
                self.shownWarning = true
                DispatchQueue.main.async {
                    self.showNilError()
                }
            }
            completion(results)
        }
        healthStore.execute(heartRateQuery)
        
    }
    
    //Email Result
    
    func sendEmail() {
        guard let currentHeartRate = heartRateData else {
            return
        }
        
        guard MFMailComposeViewController.canSendMail() else {
            // show alert
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        
        let mail = MFMailComposeViewController()
        
        mail.mailComposeDelegate = self
        mail.setToRecipients([""])
        
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        let quantityStrings = currentHeartRate
            .compactMap { $0 as? HKQuantitySample }
            .map {
                "<p>Your Heart Rate was: \($0.quantity.doubleValue(for: heartRateUnit)) </p> <p> Date: \(formatter.string(from: $0.startDate))</p>"
        }
        
        mail.setMessageBody(quantityStrings.joined(separator: "<br>"), isHTML: true)
        
        present(mail, animated: true)
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}

//TableView
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heartRateData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HeartDataTableViewCell
        
        let heartRateUnit:HKUnit = HKUnit(from: "count/min")
        let heartData = self.heartRateData?[indexPath.row]
        guard let currData:HKQuantitySample = heartData as? HKQuantitySample else { return UITableViewCell()}
        
        
        cell.lblHeartRate.text = "Heart Rate: \(currData.quantity.doubleValue(for: heartRateUnit))"
        let startDateFormatter = DateFormatter()
        startDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        startDateFormatter.timeZone = TimeZone.current
        let startDateSring = startDateFormatter.string(from: currData.startDate)
        cell.lblTimes.text = "Times: \(startDateSring)"
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
}




//Button UI Extension
@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
