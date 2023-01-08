//
//  SearchView.swift
//  LocationSearchExmple
//
//  Created by cano on 2023/01/08.
//


import SwiftUI
import MapKit

struct SearchView: View {
    
    @StateObject var locationManager: LocationManager = .init()
    
    // MARK: Navigation Tag to Push View to MapView
    @State var navigationTag: String?
    @State var presentNavigationView: Bool = false
    
    var body: some View {
        VStack{
            HStack(spacing: 15){
                Text("Search Location")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity,alignment: .leading)
            
            HStack(spacing: 10){
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Find locations here", text: $locationManager.searchText)
            }
            .padding(.vertical,12)
            .padding(.horizontal)
            .background{
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(.gray)
            }
            .padding(.vertical,10)
            
            if let places = locationManager.fetchedPlaces, !places.isEmpty {
                
                List{
                    ForEach(places,id: \.self){ place in
                        Button {
                            if let coordinate = place.location?.coordinate{
                                
                                locationManager.pickedLocation = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                locationManager.mapView.region = .init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                                locationManager.addDraggablePin(coordinate: coordinate)
                                locationManager.updatePlacemark(location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
                                
                            }
                            
                            // MARK: Navigating To MapView
                            presentNavigationView.toggle()
                            
                        } label: {
                            HStack(spacing: 15){
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(place.name ?? "")
                                        .font(.title3.bold())
                                        .foregroundColor(.primary)
                                    
                                    Text(place.locality ?? "")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }

                    }
                }
                .listStyle(.plain)
                
            }
            else {
                
                // MARK: Live Location Button
                Button {
                    
                    // MARK: Setting Map Region
                    if let coordinate = locationManager.userLocation?.coordinate{
                        locationManager.mapView.region = .init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                        locationManager.addDraggablePin(coordinate: coordinate)
                        locationManager.updatePlacemark(location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
                        
                        // MARK: Navigating To MapView
                        presentNavigationView.toggle()
                    }
                    
                } label: {
                    Label {
                        Text("Use Current Location")
                            .font(.callout)
                    } icon: {
                        Image(systemName: "location.north.circle.fill")
                    }
                    .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity,alignment: .leading)
            }
        }
        .padding()
        .frame(maxHeight: .infinity,alignment: .top)
        .background{
            Rectangle()
                .foregroundColor(.clear)
                .navigationDestination(isPresented: $presentNavigationView, destination: {
                    MapViewSelection()
                         .environmentObject(locationManager)
                         .toolbar(.hidden, for: .navigationBar)
                })
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: MapView Live Selection
struct MapViewSelection: View {
    
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var scheme
    
    var body: some View{
        ZStack{
            MapViewHelper()
                .environmentObject(locationManager)
                .ignoresSafeArea()
            
            Button {
                locationManager.pickedLocation = nil
                locationManager.pickedPlaceMark = nil
                locationManager.mapView.removeAnnotations(locationManager.mapView.annotations)
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
            }
            .padding()
            .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .topLeading)

            
            // MARK: Displaying Data
            if let place = locationManager.pickedPlaceMark {
                VStack(spacing: 15){
                    Text("Confirm Location")
                        .font(.title2.bold())
                    
                    HStack(spacing: 15) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(place.name ?? "")
                                .font(.title3.bold())
                            
                            Text(place.locality ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        if let lookAroundLoader = locationManager.lookAroundLoader {
                            HStack {
                                LookAroundView()
                                    .environmentObject(lookAroundLoader)
                                    .frame(width: 100).frame(height: 80)
                            }
                            .padding([.top, .trailing], 10)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.vertical,10)
                    
                    Button {
                        print(locationManager.pickedLocation)
                        print(locationManager.pickedPlaceMark)
                    } label: {
                        Text("Confirm Location")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical,12)
                            .background{
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.green)
                            }
                            .foregroundColor(.white)
                    }

                }
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(scheme == .dark ? .black : .white)
                        .ignoresSafeArea()
                }
                .frame(maxHeight: .infinity,alignment: .bottom)
            }
        }
        .onDisappear {
        }
    }
}

// MARK: UIKit MapView
struct MapViewHelper: UIViewRepresentable{
    
    @EnvironmentObject var locationManager: LocationManager
    
    func makeUIView(context: Context) -> MKMapView {
        return locationManager.mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
}

// MARK: UIKit MKLookAroundViewController.view
struct LookAroundView: UIViewRepresentable {
    
    @EnvironmentObject var lookAroundLoader: LookAroundLoader
     
    let view = MKLookAroundViewController()
    
    func makeUIView(context: Context) -> UIView {
        return view.view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let scene = lookAroundLoader.scene {
            view.scene = scene
        }
    }
}

class LookAroundLoader: ObservableObject  {
    @Published var scene: MKLookAroundScene?
}
