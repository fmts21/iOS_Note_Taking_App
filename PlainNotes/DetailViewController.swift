//
//  DetailViewController.swift
//  PlainNotes
//
//  Created by Michael on 2016-02-09.
//  Copyright © 2016 Michael. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import AVFoundation

class DetailViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, segueDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet weak var textView: UITextView!
    
    // location
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var locationManager = CLLocationManager()
    var noteTakenLocation = CLLocationCoordinate2D()
    
    var mapViewProgress: Float = 0.0 {
        didSet {

                self.progressBar.setProgress(self.mapViewProgress, animated:  true)

        }
    }
    
    // Image
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var imageStatusChanged = false
    var imageArray = [Note]()
    var imageLoc = [String]()
    var imageLocations = [String]()
    
    
    // Audio
    var recordButton: UIButton!
    
    var audioRecorder = AVAudioRecorder!()
    var audioPlayer = AVAudioPlayer!()
    
    var audioURL: NSURL?
    var audio = ""
    var audioStatusChanged = false
    
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopPlayingbtn: UIButton!
    
    
    @IBAction func recordTapped(sender: AnyObject) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
        recordBtn.hidden = true
        playButton.hidden = true
        playButton.enabled = true
        stopBtn.hidden = false
    }
    
    @IBAction func playTapped(sender: AnyObject) {
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: audioURL!)
//            try audioPlayer = AVAudioPlayer(data: audio!)
            
            audioPlayer.play()
        } catch {
            
        }
        recordBtn.hidden = true
        playButton.hidden = true
        stopPlayingbtn.hidden = false
    }
    
    @IBAction func stopTapped(sender: AnyObject) {
        audioRecorder.stop()
        audioRecorder = nil
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            
        }
        recordBtn.hidden = false
        playButton.hidden = false
        stopBtn.hidden = true
        stopPlayingbtn.hidden = true
    }
    
    @IBAction func stopPlaying(sender: AnyObject) {
        audioPlayer.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            
        }
        recordBtn.hidden = false
        playButton.hidden = false
        stopBtn.hidden = true
        stopPlayingbtn.hidden = true

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = allNotes[currentNoteIndex].note
        
        
        if !newNote {
            loadImage()
            loadAudio()
            if !audio.isEmpty {
                playButton.enabled = true
            }
            textView.text = allNotes[currentNoteIndex].note
        } else {
            
        }
        textView.becomeFirstResponder()
        
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
        } catch {
            // failed to record!
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(DetailViewController.addPics))
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
//        if textView.text == "" && imageArray.isEmpty {
//            if !newNote {
//                
//                
//                Note.deleteNotes(currentNoteIndex)
//                
//            } else {
//                newNote = false
//            }
//            allNotes.removeAtIndex(currentNoteIndex)
//            
//        } else if textView.text == "" && !imageArray.isEmpty {
//            thingsToSave()
//            Note.saveNotes(currentNoteIndex)
//        } else if allNotes[currentNoteIndex].note != textView.text {
//                thingsToSave()
//                Note.saveNotes(currentNoteIndex)
//        }
        
        if newNote {
            if !imageArray.isEmpty || !audio.isEmpty || textView.text != "" {
                thingsToSave()
                Note.saveNotes(currentNoteIndex)
            } else {
                Note.deleteNotes(currentNoteIndex)
                allNotes.removeAtIndex(currentNoteIndex)
            }
        } else {
            if textView.text == "" && imageArray.isEmpty && audio.isEmpty {
                Note.deleteNotes(currentNoteIndex)
                allNotes.removeAtIndex(currentNoteIndex)
            } else if allNotes[currentNoteIndex].note != textView.text {
                thingsToSave()
                Note.saveNotes(currentNoteIndex)
            } else if allNotes[currentNoteIndex].note == textView.text && (imageStatusChanged || audioStatusChanged) {
                thingsToSave()
                Note.saveNotes(currentNoteIndex)
                imageStatusChanged = false
                audioStatusChanged = false
            }
        }

        noteTable?.reloadData()
        Note.loadNotes()
        
    }
    
    func thingsToSave() {
        allNotes[currentNoteIndex].note = textView.text
        allNotes[currentNoteIndex].lati = noteTakenLocation.latitude
        allNotes[currentNoteIndex].long = noteTakenLocation.longitude
        allNotes[currentNoteIndex].image = imageLoc.map({"\($0)"}).joinWithSeparator(",")
        if (audio != "") {
            allNotes[currentNoteIndex].audio = audio
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if !newNote {
                self.noteTakenLocation.latitude = allNotes[currentNoteIndex].lati
                self.noteTakenLocation.longitude = allNotes[currentNoteIndex].long
                //locationLabel.text = "Note Taken At: \(allNotes[currentNoteIndex].lati), \(allNotes[currentNoteIndex].long)"
            } else {
                self.noteTakenLocation = newLocation.coordinate
                //locationLabel.text = "Note Taken At: \(noteTakenLocation.latitude), \(noteTakenLocation.longitude)"
            }
            
            self.locationManager.stopUpdatingLocation()
            
            let span = MKCoordinateSpanMake(0.02, 0.02)
            let region = MKCoordinateRegion(center: self.noteTakenLocation, span: span)
            
            self.mapViewProgress = 1.0
            dispatch_async(dispatch_get_main_queue()) {
            
            self.mapView.setRegion(region, animated: true)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCell
        
        let image = String(imageArray[indexPath.row].image.characters.suffix(36))
        let imagePath = getDocumentsDirectory().stringByAppendingPathComponent(image)
        
        cell.imageView.image = UIImage(contentsOfFile: imagePath)
        
        cell.imageView.layer.borderWidth = 1
        cell.imageView.layer.cornerRadius = 2
        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showImage", sender: self)
    }
    
    func removeCurrentImage(image: UIImage) {
        imageStatusChanged = true
        let indexPaths = self.collectionView.indexPathsForSelectedItems()
        let indexPath = indexPaths![0] as NSIndexPath
        
        imageArray.removeAtIndex(indexPath.row)
        imageLoc.removeAtIndex(indexPath.row)
        //        collectionView.deleteItemsAtIndexPaths([indexPath])
        collectionView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImage" {
            let indexPaths = self.collectionView.indexPathsForSelectedItems()
            let indexPath = indexPaths![0] as NSIndexPath
            
            let vc:ViewController = segue.destinationViewController as! ViewController
            vc.delegate = self
            
            let image = String(imageArray[indexPath.item].image.characters.suffix(36))
            let imagePath = getDocumentsDirectory().stringByAppendingPathComponent(image)
            
            vc.image = UIImage(contentsOfFile: imagePath)!
            
        }
    }
    
    func addPics() {
        if newNote {
            textView.text = "New Note"
        }
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var newImage = UIImage()
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        let imageName = NSUUID().UUIDString
        let imagePath = getDocumentsDirectory().stringByAppendingPathComponent(imageName)
        
        imageLoc.append(imagePath)  // do i really need this?
        
        if let jpegData = UIImageJPEGRepresentation(newImage, 80) {
            jpegData.writeToFile(imagePath, atomically: true)
        }
        
        let image = Note()
        image.image = imageName
        imageArray.append(image)
        collectionView.reloadData()
        
        dismissViewControllerAnimated(true, completion: nil)
        imageStatusChanged = true
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func loadImage() {
        imageArray.removeAll()
        imageLoc.removeAll()
        if allNotes[currentNoteIndex].image != "" {
            
            imageLocations = allNotes[currentNoteIndex].image.componentsSeparatedByString(",")
            for i in 0 ..< imageLocations.count  {
                let image = Note()
                image.image = imageLocations[i]
                imageLoc.append(imageLocations[i])
                imageArray.append(image)
            }
            
        }
    }
    
    func startRecording() {
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let dateForName = dateFormatter.stringFromDate(date)
        
        let audioFilename = getDocumentsDirectory().stringByAppendingPathComponent(dateForName + ".m4a")
        audioURL = NSURL(fileURLWithPath: audioFilename)
        
        let settings = [
            AVSampleRateKey : NSNumber(float: Float(44100.0)),
            AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),
            AVNumberOfChannelsKey : NSNumber(int: 1),
            AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(URL: audioURL!, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
        }
        
        audio = audioFilename
        audioStatusChanged = true
        
    }
    
    func loadAudio() {
        
        audio = String(allNotes[currentNoteIndex].audio.characters.suffix(19))
        audioURL = NSURL(fileURLWithPath: getDocumentsDirectory().stringByAppendingPathComponent(audio))
    }
    
    func finishRecording(success success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
    }
}

