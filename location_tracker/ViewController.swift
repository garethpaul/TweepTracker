//
//  ViewController.swift
//

import UIKit
import CoreLocation
import MapKit
import TwitterKit

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

            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            if pinView == nil {

            }
            else {
                pinView!.annotation = annotation
            }

            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)


            let tweep = annotation as TweepAnnotation

            let url = URL()
            let url_string = tweep.imageURL
            url.downloadImage(NSURL(string: url_string)!, {image, error in
                let newImg = image
                let circle = CircleImage(RBResizeImage(newImg, CGSize(width: 50, height: 50)))
                pinView!.image = circle


            })
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
            // give 3 seconds to load
            sleep(5)
            self.spinner.stopAnimating()
            self.mapView.hidden = false;
            self.spinner.hidden = true;

        }
    }


    func displayLocationInfo(placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            println(locality)
            println(postalCode)
            println(administrativeArea)
            println(country)
                    }

    }
    func locateTweep(handle: String){
        TweepLocation(handle){ (result: [Double]) in
            let location2 = CLLocationCoordinate2D(
                latitude: result[1],
                longitude:result[0]
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

