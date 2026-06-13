//
//  ViewController.swift
//

import UIKit
import CoreLocation
import MapKit
import TwitterKit

private class TweepPinAnnotationView: MKPinAnnotationView {
    var imageTask: NSURLSessionDataTask?

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        image = nil
    }
}

class ViewController: UIViewController, MKMapViewDelegate {

    var logoView: UIImageView!

    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var spinner: UIActivityIndicatorView!

    @IBOutlet var refresh: UIImageView!
    @IBOutlet var search: UIImageView!


    override func viewDidLoad() {
        super.viewDidLoad()
        println("show viewController")
               //locationManager.startUpdatingLocation()
        mapView.delegate = self

        // Add the logo view to the top (not in the navigation bar title in order to position it better).
        logoView = UIImageView(frame: CGRectMake(0, 0, 35, 35))
        logoView.image = UIImage(named: "icon")?.imageWithRenderingMode(.AlwaysTemplate)
        logoView.tintColor = toColor("ffffff")
        logoView.frame.origin.x = (self.view.frame.size.width - logoView.frame.size.width) / 2
        logoView.frame.origin.y = -logoView.frame.size.height - 10
        self.navigationController?.view.addSubview(logoView)
        self.navigationController?.view.bringSubviewToFront(logoView)

        //
        let searchTapRecognizer = UITapGestureRecognizer(target: self, action: Selector("searchTap"))
        self.search.userInteractionEnabled = true
        self.search.addGestureRecognizer(searchTapRecognizer)


        //
        //
        let refreshTapRecognizer = UITapGestureRecognizer(target: self, action: Selector("refreshTap"))
        self.refresh.userInteractionEnabled = true
        self.refresh.addGestureRecognizer(refreshTapRecognizer)

        // Customize the navigation bar.
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: toColor("4DD962")]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.barTintColor = toColor("4DD962")

        setupMap()

    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Animate the logo when the view appears.
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .CurveEaseInOut, animations: { () -> Void in
            // Place the frame at the correct origin position.
            self.logoView.frame.origin.y = 22
            }, completion: nil)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Make sure the navigation bar is translucent.
        self.navigationController?.navigationBar.translucent = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        // Move the logo view off screen if a new controller was pushed.
        if self.navigationController?.viewControllers.count > 1 {
            UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .CurveEaseInOut, animations: { () -> Void in
                // Place the frame at the correct origin position.
                self.logoView.frame.origin.y = -self.logoView.frame.size.height - 10
                }, completion: nil)
        }
    }

    func searchTap(){
        println("search-tap")
    }

    func refreshTap(){
        setupMap()
    }

    func newPin(url: String){

    }
    
    func mapView(mapView: MKMapView!,
        viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {

            //
            if annotation is MKUserLocation {
                //return nil so map view draws "blue dot" for standard user location
                return nil
            }

            let reuseId = "pin"

            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? TweepPinAnnotationView
            if pinView == nil {
                pinView = TweepPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            }
            else {
                pinView!.imageTask?.cancel()
                pinView!.imageTask = nil
                pinView!.annotation = annotation
            }

            pinView!.image = nil

            if let tweep = annotation as? TweepAnnotation {
                let url = URL()
                let url_string = tweep.imageURL
                if let imageURL = NSURL(string: url_string) {
                    pinView!.imageTask = url.downloadImage(imageURL, {image, error in
                        if let newImg = image {
                            if let currentAnnotation = pinView?.annotation {
                                if currentAnnotation === annotation {
                                    let circle = CircleImage(RBResizeImage(newImg, CGSize(width: 50, height: 50)))
                                    pinView!.image = circle
                                }
                            }
                        }
                    })
                }
            }


            pinView?.sizeThatFits(CGSize(width:3, height:3))

            pinView!.canShowCallout = true
            pinView!.animatesDrop = false


            return pinView
    }



    func setupMap(){
        self.spinner.hidden = false
        self.spinner.startAnimating()
        self.mapView.hidden = true

        let location = CLLocationCoordinate2D(
            latitude: 51.48881507,
            longitude:-0.16875179
        )

        let span = MKCoordinateSpanMake(95.75, 95.75)
        let region = MKCoordinateRegion(center: location, span: span)


        FindTweeps(){ (result: [String]) in
            for u in result{
                self.locateTweep(u)
            }



            self.mapView.setRegion(region, animated: true)
            self.refresh.hidden = true
            let mapDelay = 5 * Double(NSEC_PER_SEC)
            let mapTime = dispatch_time(DISPATCH_TIME_NOW, Int64(mapDelay))
            dispatch_after(mapTime, dispatch_get_main_queue()) {
                self.spinner.stopAnimating()
                self.mapView.hidden = false;
                self.spinner.hidden = true;

                let refreshDelay = 60 * Double(NSEC_PER_SEC)
                let refreshTime = dispatch_time(DISPATCH_TIME_NOW, Int64(refreshDelay))
                dispatch_after(refreshTime, dispatch_get_main_queue()) {
                    //call the method which have the steps after delay.
                    self.displayRefresh()
                }
            }


        }
    }

    func displayRefresh(){
        self.refresh.hidden = false
    }

    func locateTweep(handle: String){
        TweepLocation(handle){ (result: [Double]) in
            if result.count < 2 {
                return
            }

            let location2 = CLLocationCoordinate2D(
                latitude: result[0],
                longitude: result[1]
            )

            // we need pictures then we are good
            TweepPicture(handle){ (result: String) in
                var info2 = TweepAnnotation()
                info2.setCoordinate(location2)
                info2.title = "Info1"
                info2.subtitle = "Subtitle"
                info2.imageURL = result
                self.mapView.addAnnotation(info2)
            }



        }
    }

  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
