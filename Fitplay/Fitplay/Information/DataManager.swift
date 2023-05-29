//
//  DataManager.swift
//  Fitplay
//
//  Created by Samuel Vulakh on 4/5/23.
//

import FirebaseStorage
import CoreXLSX
import Firebase
import SwiftUI

/// Data Manager Object
class DataManager: ObservableObject {
    
    @Published var isCalendar = false
    
    static var image: URL? { URL(string: "https://firebasestorage.googleapis.com/v0/b/drivn-fbd73.appspot.com/o/Image.png?alt=media&token=08f4355b-992e-41e4-82cd-88b366d36458") }
    
    @Published var currentDraggingPage: Category?
    
    /// Error Handle
    @Published var handle = Handle()
    
    /// Current User
    @Published var user: User?
    
    /// Image For Adding / Editing Image
    @Published var image: UIImage?
    
    /// Opening The Library To Select An Image
    @Published var selectImage = false
    
    /// Search Text
    @Published var searchText = ""
    
    /// Fetch Current User
    public func fetch() {
        
        // Setting Loading
        setLoading(true)
                
        if let current = Firestore.current {
            // Fetching From Firestore
            current.getDocument { snapshot, error in
             
                // Set Error
                if let error { print(error); self.setHandle(.err(error.localizedDescription)); return }
                                
                do {
                    // Converting Data To User Object
                    let data = try snapshot?.data(as: User.self)
                
                    // Set User Data
                    DispatchQueue.main.async { self.user = data }
                } catch {
                    print(error)
                    self.setHandle()
                }
                
                // Setting Loading
                self.setLoading(false)
            }
        } else {
            setLoading(false)
        }
    }
    
    public func fetchCategories() {
        let path = Bundle.main.path(forResource: "EXERCISE DIRECTORY", ofType: "xlsx")
        
        guard let file = XLSXFile(filepath: path ?? "") else { print("No Excel File"); return }
        
        do {
            for wbk in try file.parseWorkbooks() {
                for (name, path) in try file.parseWorksheetPathsAndNames(workbook: wbk) {
                    
                    let worksheet = try file.parseWorksheet(at: path)
                                        
                    if let sharedStrings = try file.parseSharedStrings() {
                        let columnAWorkouts = worksheet.cells(atColumns: [ColumnReference("A")!])
                            .compactMap { Category.Workout(exercise:  $0.stringValue(sharedStrings) ?? "", equipment: $0.stringValue(sharedStrings) == "Bicycle" ? "Stationary Bike" : "") }
                        DispatchQueue.main.async {
                            self.options.append(Category(title: name ?? "", description: "", options: columnAWorkouts))
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    /// Update The User With An Option Image
    public func update(_ newClassId: String = "") {
        
        // Getting User ID And Making Sure User Exists
        guard let uid = Auth.auth().currentUser?.uid, let user else { return }
        
        // Making User Editable
        var editable = user
        
        // Setting User Boarded Status
        editable.boarded = true
        
        /// Firebase Storage Reference With User ID
        let ref = Storage.storage().reference(withPath: !newClassId.isEmpty ? UUID().uuidString : "\(uid)")
        
        // Getting Image Data As JPEG
        guard let data = self.image?.jpegData(compressionQuality: 0.5) else { self.save(editable); return }
        
        // Putting Image Data In Firebase Storage
        ref.putData(data, metadata: nil) { metadata, error in
            
            // Handling Errors
            if let error {
                print("error here")
                self.handle = Handle(value: .err(error.localizedDescription), loading: false)
                return
            }
            
            // Getting URL From Downloaded Image
            ref.downloadURL { url, err in
                
                // Handling Errors
                if let error {
                    print("error retrieving url")
                    self.handle = Handle(value: .err(error.localizedDescription), loading: false)
                    return
                }
                
                // Resetting Image
                self.image = nil
                
                // Making Sure Image URL Exists
                guard let url else { return }
                
                // Setting URL
                if let index = self.user?.classes.firstIndex(where: { $0.id == newClassId }) {
                    editable.classes[index].image = url
                } else {
                    editable.image = url
                }
                
                // Saving User Data
                self.save(editable)
            }
        }
    }
    
    /// Initializing User Database Document With User ID
    private func save(_ user: User) {
        
        do {
            // Creating User Document
            try Firestore.current?.setData(from: user) { error in
                
                // Handling Errors
                if let error {
                    self.handle = Handle(value: .err(error.localizedDescription), loading: false)
                    return
                } else {
                    DispatchQueue.main.async { withAnimation { self.user = user } }
                }
            }
        } catch(let error) {
            self.handle = Handle(value: .err(error.localizedDescription), loading: false)
            return
        }
    }
    
    // MARK: Classes
    @Published var selected: Category?
    
    /// List Of All Class Options
    @Published var options = [Category]()
    
//    let options = [
//        Category(title: "Abs", description: "Short Description", options: [
//            Category.Workout(exercise: "Alligator Crawl", equipment: ""),
//            Category.Workout(exercise: "Alternating Heel-Touch", equipment: ""),
//            Category.Workout(exercise: "Bear Crawl Shoulder Taps", equipment: ""),
//            Category.Workout(exercise: "Bicycle", equipment: "Stationary Bike"),
//            Category.Workout(exercise: "Bottoms Up", equipment: ""),
//            Category.Workout(exercise: "Cocoons", equipment: ""),
//            Category.Workout(exercise: "Crab Single-Arm Reach", equipment: ""),
//            Category.Workout(exercise: "Crab Toe-Touch", equipment: ""),
//            Category.Workout(exercise: "Cross Crunch", equipment: ""),
//            Category.Workout(exercise: "Cross-Body Crunch", equipment: ""),
//            Category.Workout(exercise: "Crunch-Hands Overhead", equipment: ""),
//            Category.Workout(exercise: "Crunches", equipment: ""),
//            Category.Workout(exercise: "Dead Bug Reach", equipment: ""),
//            Category.Workout(exercise: "Elbow Plank", equipment: ""),
//            Category.Workout(exercise: "Elbow-To-Knee Crunch", equipment: ""),
//            Category.Workout(exercise: "Flutter Kicks", equipment: ""),
//            Category.Workout(exercise: "Full Moon", equipment: ""),
//            Category.Workout(exercise: "Half Bird", equipment: ""),
//            Category.Workout(exercise: "Hollow Hold", equipment: ""),
//            Category.Workout(exercise: "Janda Sit-up", equipment: ""),
//            Category.Workout(exercise: "Knee Tucked Crunch", equipment: ""),
//            Category.Workout(exercise: "Lower Back Curl", equipment: ""),
//            Category.Workout(exercise: "Lying Leg Raise", equipment: ""),
//            Category.Workout(exercise: "Lying Oblique Crunch", equipment: ""),
//            Category.Workout(exercise: "Mountain Climber", equipment: ""),
//            Category.Workout(exercise: "Piller-To-Plank", equipment: ""),
//            Category.Workout(exercise: "Plank Leg Raises", equipment: ""),
//            Category.Workout(exercise: "Plank to Pike", equipment: ""),
//            Category.Workout(exercise: "Reverse Crunch", equipment: ""),
//            Category.Workout(exercise: "Russian Twist", equipment: ""),
//            Category.Workout(exercise: "Scissor Kick", equipment: ""),
//            Category.Workout(exercise: "Shoulder Taps", equipment: ""),
//            Category.Workout(exercise: "Side Jackknife", equipment: ""),
//            Category.Workout(exercise: "Side Kick-Through", equipment: ""),
//            Category.Workout(exercise: "Side Plank Hip Dip", equipment: ""),
//            Category.Workout(exercise: "Single Leg V-Up", equipment: ""),
//            Category.Workout(exercise: "Sit ups", equipment: ""),
//            Category.Workout(exercise: "Spider Crawl", equipment: ""),
//            Category.Workout(exercise: "Spider Plank Jack", equipment: ""),
//            Category.Workout(exercise: "Straight Legged Hip Raises", equipment: ""),
//            Category.Workout(exercise: "Toe Touches", equipment: ""),
//            Category.Workout(exercise: "V- Up", equipment: "")
//        ]),
//        Category(title: "Arms", description: "Short Description", options: [
//            Category.Workout(exercise: "Alt Bicep Curl", equipment: ""),
//            Category.Workout(exercise: "Alt Deltoid Raise", equipment: ""),
//            Category.Workout(exercise: "Alt Hammer Curl", equipment: ""),
//            Category.Workout(exercise: "Alt Tricep Extension", equipment: ""),
//            Category.Workout(exercise: "Arnold Press", equipment: ""),
//            Category.Workout(exercise: "Bench Press", equipment: ""),
//            Category.Workout(exercise: "Bent Over Rear Delt Row", equipment: ""),
//            Category.Workout(exercise: "Bicep Curl", equipment: ""),
//            Category.Workout(exercise: "Bicep Curl to Shoulder Press", equipment: ""),
//            Category.Workout(exercise: "Cross Body Hammer Curl", equipment: ""),
//            Category.Workout(exercise: "Cuban Press", equipment: ""),
//            Category.Workout(exercise: "Dumbbell Flyes", equipment: ""),
//            Category.Workout(exercise: "Dumbbell Pull Over", equipment: ""),
//            Category.Workout(exercise: "Dumbbell Raise", equipment: ""),
//            Category.Workout(exercise: "External Shoulder Rotation ", equipment: ""),
//            Category.Workout(exercise: "Front Raise", equipment: ""),
//            Category.Workout(exercise: "Front Raise to Lateral Raise", equipment: ""),
//            Category.Workout(exercise: "Hammer Curl", equipment: ""),
//            Category.Workout(exercise: "Overhead Front Raise", equipment: ""),
//            Category.Workout(exercise: "Pull Up", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Rear Delt Raise", equipment: ""),
//            Category.Workout(exercise: "Reverse Curl", equipment: ""),
//            Category.Workout(exercise: "See-Saw Press", equipment: ""),
//            Category.Workout(exercise: "Shoulder Press", equipment: ""),
//            Category.Workout(exercise: "Shoulder Raise", equipment: ""),
//            Category.Workout(exercise: "Side Lateral Raise", equipment: ""),
//            Category.Workout(exercise: "Single Arm Lateral Raise", equipment: ""),
//            Category.Workout(exercise: "Single Arm Preacher Curl", equipment: ""),
//            Category.Workout(exercise: "Single Arm Shoulder Press", equipment: ""),
//            Category.Workout(exercise: "Single Dumbell Front Raise", equipment: ""),
//            Category.Workout(exercise: "Skull Crusher", equipment: ""),
//            Category.Workout(exercise: "Standing Concentration Curl", equipment: ""),
//            Category.Workout(exercise: "Tricep Dip", equipment: ""),
//            Category.Workout(exercise: "Tricep Extensions", equipment: ""),
//            Category.Workout(exercise: "Tricep Kickback", equipment: ""),
//            Category.Workout(exercise: "Upright Row", equipment: ""),
//
//        ]),
//        Category(title: "Barre", description: "Short Description", options: [
//            Category.Workout(exercise: "Allongée Propellers", equipment: ""),
//            Category.Workout(exercise: "Allongée Swiveling Glute Burners", equipment: ""),
//            Category.Workout(exercise: "Arabesque Attitude", equipment: ""),
//            Category.Workout(exercise: "Assemblé", equipment: ""),
//            Category.Workout(exercise: "Back Dancing", equipment: ""),
//            Category.Workout(exercise: "Ballerina Assemblés", equipment: ""),
//            Category.Workout(exercise: "First Position / Narrow V/ Athletic V", equipment: ""),
//            Category.Workout(exercise: "Four-Part Arabesque Lunge", equipment: ""),
//            Category.Workout(exercise: "Genie Abs", equipment: ""),
//            Category.Workout(exercise: "Hallow Plank", equipment: ""),
//            Category.Workout(exercise: "Parallel", equipment: ""),
//            Category.Workout(exercise: "Parallel Plié", equipment: ""),
//            Category.Workout(exercise: "Parallel Squat", equipment: ""),
//            Category.Workout(exercise: "Plié / Wide Turn Out", equipment: ""),
//            Category.Workout(exercise: "Plié Oblique Crunch", equipment: ""),
//            Category.Workout(exercise: "Plié Pluse to Passé", equipment: ""),
//            Category.Workout(exercise: "Plié Port de Bras", equipment: ""),
//            Category.Workout(exercise: "Reaching Rond De Jambe", equipment: ""),
//            Category.Workout(exercise: "Rear Fly and Arabesque Lift", equipment: ""),
//            Category.Workout(exercise: "Relevé Plié", equipment: ""),
//            Category.Workout(exercise: "Second Position / Turned Out Squat", equipment: ""),
//            Category.Workout(exercise: "Thigh Super Burner", equipment: "")
//        ]),
//        Category(title: "Boxing", description: "Short Description", options: [
//            Category.Workout(exercise: "Hammerﬁst", equipment: ""),
//            Category.Workout(exercise: "Head Punches", equipment: ""),
//            Category.Workout(exercise: "Hook", equipment: ""),
//            Category.Workout(exercise: "Jab", equipment: ""),
//            Category.Workout(exercise: "Knee Kick", equipment: ""),
//            Category.Workout(exercise: "Lead Backﬁst", equipment: ""),
//            Category.Workout(exercise: "Lead Uppercut", equipment: ""),
//            Category.Workout(exercise: "Overhand", equipment: ""),
//            Category.Workout(exercise: "Rear Backﬁst", equipment: ""),
//            Category.Workout(exercise: "Rear Uppercut", equipment: ""),
//            Category.Workout(exercise: "Round Kick", equipment: ""),
//            Category.Workout(exercise: "Shufﬂe Kick", equipment: ""),
//            Category.Workout(exercise: "Sliding Kick", equipment: ""),
//            Category.Workout(exercise: "Spinning Backﬁst", equipment: ""),
//            Category.Workout(exercise: "Switch Kick", equipment: ""),
//            Category.Workout(exercise: "Twist Kick", equipment: "")
//        ]),
//        Category(title: "Cardio", description: "Short Description", options: [
//            Category.Workout(exercise: "BOXING", equipment: ""),
//            Category.Workout(exercise: "BURPEES", equipment: ""),
//            Category.Workout(exercise: "CRAB WALK BURPEES", equipment: ""),
//            Category.Workout(exercise: "CRISS CROSS JUMPS", equipment: ""),
//            Category.Workout(exercise: "CYCLE", equipment: ""),
//            Category.Workout(exercise: "DUCK & PUNCH", equipment: ""),
//            Category.Workout(exercise: "ELLIPTICAL", equipment: ""),
//            Category.Workout(exercise: "FORWARD & BACKWARD HIGH KNEES", equipment: ""),
//            Category.Workout(exercise: "HEEL TAPS", equipment: ""),
//            Category.Workout(exercise: "HEISMAN JUMPS", equipment: ""),
//            Category.Workout(exercise: "HIGH KNEES", equipment: ""),
//            Category.Workout(exercise: "JOGGING IN PLACE", equipment: ""),
//            Category.Workout(exercise: "JUMP FLOOR TOUCHES", equipment: ""),
//            Category.Workout(exercise: "JUMP ROPE", equipment: ""),
//            Category.Workout(exercise: "JUMPING JACKS", equipment: ""),
//            Category.Workout(exercise: "JUMPS SQUATS", equipment: ""),
//            Category.Workout(exercise: "KNEE REPEATERS", equipment: ""),
//            Category.Workout(exercise: "LATERAL SHUFFLE", equipment: ""),
//            Category.Workout(exercise: "MARCHING", equipment: ""),
//            Category.Workout(exercise: "MOUNTAIN CLIMBERS", equipment: ""),
//            Category.Workout(exercise: "PLANK JACKS", equipment: ""),
//            Category.Workout(exercise: "PUNCH COMBO", equipment: ""),
//            Category.Workout(exercise: "ROW", equipment: ""),
//            Category.Workout(exercise: "RUN", equipment: ""),
//            Category.Workout(exercise: "SCREAMER LUNGES", equipment: ""),
//            Category.Workout(exercise: "SEAL JACKS", equipment: ""),
//            Category.Workout(exercise: "SIDE LATERALS", equipment: ""),
//            Category.Workout(exercise: "SIDE SHUFFLE TAPS", equipment: ""),
//            Category.Workout(exercise: "SINGLE LEG JUMP LUNGES", equipment: ""),
//            Category.Workout(exercise: "SKATER HOPS", equipment: ""),
//            Category.Workout(exercise: "SPRINT", equipment: ""),
//            Category.Workout(exercise: "SQUAT ALT SIDE KICKS", equipment: ""),
//            Category.Workout(exercise: "SQUAT HOLD PUNCHES", equipment: ""),
//            Category.Workout(exercise: "SQUAT TO FRONT KICK", equipment: ""),
//            Category.Workout(exercise: "STAIR CLIMPING", equipment: ""),
//            Category.Workout(exercise: "STANDING TO TAPS", equipment: ""),
//            Category.Workout(exercise: "STAR JUMPS", equipment: ""),
//            Category.Workout(exercise: "TWIST JUMPS", equipment: ""),
//            Category.Workout(exercise: "WALK", equipment: ""),
//
//        ]),
//        Category(title: "Kettlebell", description: "Short Description", options: [
//            Category.Workout(exercise: "KB AROUND THE WORLD", equipment: ""),
//            Category.Workout(exercise: "KB ALTERNATE HAND EXCHANGE", equipment: ""),
//            Category.Workout(exercise: "KB BELL JUMP SQUAT", equipment: ""),
//            Category.Workout(exercise: "KB BRIDGE", equipment: ""),
//            Category.Workout(exercise: "KB BUMP", equipment: ""),
//            Category.Workout(exercise: "KB CLEAN", equipment: ""),
//            Category.Workout(exercise: "KB CURTSY LUNGE", equipment: ""),
//            Category.Workout(exercise: "KB CURTSY LUNGE IN RACK", equipment: ""),
//            Category.Workout(exercise: "KB DEADLIFT", equipment: ""),
//            Category.Workout(exercise: "KB DEADLIFT CATCH", equipment: ""),
//            Category.Workout(exercise: "KB DOUBLE BELL DEADLIFT", equipment: ""),
//            Category.Workout(exercise: "KB DOUBLE BELL SUITCASE DEADLIFT", equipment: ""),
//            Category.Workout(exercise: "KB FLOOR TO PRESS", equipment: ""),
//            Category.Workout(exercise: "KB FORWARD LUNGE", equipment: ""),
//            Category.Workout(exercise: "KB GOBLET SQUAT", equipment: ""),
//            Category.Workout(exercise: "KB GOBLET SQUAT REVERSE LUNGE", equipment: ""),
//            Category.Workout(exercise: "KB SNATCH DOWN", equipment: ""),
//            Category.Workout(exercise: "KB HALF SNATCH UP", equipment: ""),
//            Category.Workout(exercise: "KB HALO", equipment: ""),
//            Category.Workout(exercise: "KB HIGH PULL", equipment: ""),
//            Category.Workout(exercise: "KB JERK", equipment: ""),
//            Category.Workout(exercise: "KB KNEELING CHOP", equipment: ""),
//            Category.Workout(exercise: "KB KNEELING SWING", equipment: ""),
//            Category.Workout(exercise: "KB LATERAL LUNGE", equipment: ""),
//            Category.Workout(exercise: "KB LONG CYCLE", equipment: ""),
//            Category.Workout(exercise: "KB NAKED SWING", equipment: ""),
//            Category.Workout(exercise: "KB ON BACK PRESS", equipment: ""),
//            Category.Workout(exercise: "KB ON BACK PRESS FLUTTER LEGS", equipment: ""),
//            Category.Workout(exercise: "KB ONE ARM SWING", equipment: ""),
//            Category.Workout(exercise: "KB ONE ARM DEADLIFT", equipment: ""),
//            Category.Workout(exercise: "KB OUTSIDE KNEE SWING", equipment: ""),
//            Category.Workout(exercise: "KB OVERHEAD PRESS", equipment: ""),
//            Category.Workout(exercise: "KB PISTOL", equipment: ""),
//            Category.Workout(exercise: "KB PLANK DRAG", equipment: ""),
//            Category.Workout(exercise: "KB PULLOVER TO SQUAT", equipment: ""),
//            Category.Workout(exercise: "KB PUSH PRESS", equipment: ""),
//            Category.Workout(exercise: "KB PUSH UP", equipment: ""),
//            Category.Workout(exercise: "KB QUARTER SWING CATCH", equipment: ""),
//            Category.Workout(exercise: "KB RACK", equipment: ""),
//            Category.Workout(exercise: "KB REVERSE LUNGE", equipment: ""),
//            Category.Workout(exercise: "KB REVERSE LUNGE IN RACK", equipment: ""),
//            Category.Workout(exercise: "KB RIBBON", equipment: ""),
//            Category.Workout(exercise: "KB ROW", equipment: ""),
//            Category.Workout(exercise: "KB SIDE PLANK", equipment: ""),
//            Category.Workout(exercise: "KB SINGLE STRAIGHT LEG DEADLIFT", equipment: ""),
//            Category.Workout(exercise: "KB SIT UP", equipment: ""),
//            Category.Workout(exercise: "KB SNATCH", equipment: ""),
//            Category.Workout(exercise: "KB SPIKE", equipment: ""),
//            Category.Workout(exercise: "KB SWING", equipment: ""),
//            Category.Workout(exercise: "KB SUITCASE DEADLIFT", equipment: ""),
//            Category.Workout(exercise: "KB THRUSTER", equipment: ""),
//            Category.Workout(exercise: "KB TURKISH GET UP BOTTOM UP", equipment: ""),
//            Category.Workout(exercise: "KB TURKISH GET UP TOP DOWN", equipment: ""),
//            Category.Workout(exercise: "KB TWISTED SUITCASE DEADLIFT", equipment: ""),
//            Category.Workout(exercise: "KB TWO-HANDED OVERHEAD HIGH SWING", equipment: ""),
//            Category.Workout(exercise: "KB WINDMILL", equipment: "")
//        ]),
//        Category(title: "Mat Pilates", description: "Short Description", options: [
//            Category.Workout(exercise: "AB CURL", equipment: ""),
//            Category.Workout(exercise: "AB PREP", equipment: ""),
//            Category.Workout(exercise: "ACTIVE REST", equipment: ""),
//            Category.Workout(exercise: "ARMS ARC", equipment: ""),
//            Category.Workout(exercise: "ASSISTED ROLL UP", equipment: ""),
//            Category.Workout(exercise: "BABY SWAN", equipment: ""),
//            Category.Workout(exercise: "BACK CONTROL", equipment: ""),
//            Category.Workout(exercise: "BALANCE CONTROL", equipment: ""),
//            Category.Workout(exercise: "BENT KNEE FALL OUT", equipment: ""),
//            Category.Workout(exercise: "BENT KNEE OPENING", equipment: ""),
//            Category.Workout(exercise: "BICYCLE IN THE AIR", equipment: ""),
//            Category.Workout(exercise: "BIRD DOG", equipment: ""),
//            Category.Workout(exercise: "BOAT CRUNCH", equipment: ""),
//            Category.Workout(exercise: "BOOK OPENING", equipment: ""),
//            Category.Workout(exercise: "BOOMERANG", equipment: ""),
//            Category.Workout(exercise: "BRIDGING", equipment: ""),
//            Category.Workout(exercise: "BUTTERFLY CLAMS", equipment: ""),
//            Category.Workout(exercise: "BUTTERFLY- BENT KNEE OPENING", equipment: ""),
//            Category.Workout(exercise: "C-CURVE", equipment: ""),
//            Category.Workout(exercise: "CALF RAISES", equipment: ""),
//            Category.Workout(exercise: "CAT", equipment: ""),
//            Category.Workout(exercise: "CAT COW", equipment: ""),
//            Category.Workout(exercise: "CHEST LIFT", equipment: ""),
//            Category.Workout(exercise: "CHILDS POSE", equipment: ""),
//            Category.Workout(exercise: "CLEOPATRA", equipment: ""),
//            Category.Workout(exercise: "CLIMB A TREE", equipment: ""),
//            Category.Workout(exercise: "CONSTRUCTIVE REST", equipment: ""),
//            Category.Workout(exercise: "CONTROL BALANCE", equipment: ""),
//            Category.Workout(exercise: "CORKSCREW", equipment: ""),
//            Category.Workout(exercise: "CRAB", equipment: ""),
//            Category.Workout(exercise: "CRISS CROSS", equipment: ""),
//            Category.Workout(exercise: "CROSS-LEGGED", equipment: ""),
//            Category.Workout(exercise: "DART", equipment: ""),
//            Category.Workout(exercise: "DEAD BUG", equipment: ""),
//            Category.Workout(exercise: "DOUBLE LEG KICK", equipment: ""),
//            Category.Workout(exercise: "DOUBLE LEG PULL", equipment: ""),
//            Category.Workout(exercise: "DOUBLE LEG REACH", equipment: ""),
//            Category.Workout(exercise: "DOUBLE LEG STRETCH", equipment: ""),
//            Category.Workout(exercise: "DOUBLE STRAIGHT LEG STRETCH", equipment: ""),
//            Category.Workout(exercise: "DOWN STRETCH", equipment: ""),
//            Category.Workout(exercise: "FEMUR ARCS", equipment: ""),
//            Category.Workout(exercise: "FIGURE 4 STANDING", equipment: ""),
//            Category.Workout(exercise: "FIGURE 4 SUPINE", equipment: ""),
//            Category.Workout(exercise: "FRONT CONTROL", equipment: ""),
//            Category.Workout(exercise: "FRONT SUPPORT", equipment: ""),
//            Category.Workout(exercise: "GRASSHOPPER", equipment: ""),
//            Category.Workout(exercise: "HALF ROLL DOWN", equipment: ""),
//            Category.Workout(exercise: "HEEL BEATS", equipment: ""),
//            Category.Workout(exercise: "HEEL RAISES", equipment: ""),
//            Category.Workout(exercise: "HIGH SWAN", equipment: ""),
//            Category.Workout(exercise: "HIP CIRCLES", equipment: ""),
//            Category.Workout(exercise: "HIP TWIST", equipment: ""),
//            Category.Workout(exercise: "HUNDRED", equipment: ""),
//            Category.Workout(exercise: "INVERTED V", equipment: ""),
//            Category.Workout(exercise: "JACKKNIFE", equipment: ""),
//            Category.Workout(exercise: "KNEE BEND", equipment: ""),
//            Category.Workout(exercise: "KNEE FOLDS", equipment: ""),
//            Category.Workout(exercise: "KNEE STIRS", equipment: ""),
//            Category.Workout(exercise: "KNEELING HAMSTRING STRETCH", equipment: ""),
//            Category.Workout(exercise: "KNEELING LUNGE", equipment: ""),
//            Category.Workout(exercise: "KNEELING OBLIQUES", equipment: ""),
//            Category.Workout(exercise: "KNEELING SIDE KICK", equipment: ""),
//            Category.Workout(exercise: "LEG CIRCLES", equipment: ""),
//            Category.Workout(exercise: "LEG PULL", equipment: ""),
//            Category.Workout(exercise: "LEG PULL BACK", equipment: ""),
//            Category.Workout(exercise: "LEG PULL DOWN", equipment: ""),
//            Category.Workout(exercise: "LEG PULL FRONT", equipment: ""),
//            Category.Workout(exercise: "LEG PULL UP", equipment: ""),
//            Category.Workout(exercise: "LEG RAISES", equipment: ""),
//            Category.Workout(exercise: "LEG SLIDES", equipment: ""),
//            Category.Workout(exercise: "MERMAID", equipment: ""),
//            Category.Workout(exercise: "MODIFIED SWIMMING", equipment: ""),
//            Category.Workout(exercise: "NECK PULL", equipment: ""),
//            Category.Workout(exercise: "OBLIQUE PLANK", equipment: ""),
//            Category.Workout(exercise: "OPEN LEG ROCKER", equipment: ""),
//            Category.Workout(exercise: "OPPOSITE ARM AND LEG REACH", equipment: ""),
//            Category.Workout(exercise: "OVERHEAD REACH", equipment: ""),
//            Category.Workout(exercise: "PELVIC BRIDGE", equipment: ""),
//            Category.Workout(exercise: "PELVIC CLOCK", equipment: ""),
//            Category.Workout(exercise: "PELVIC CURL", equipment: ""),
//            Category.Workout(exercise: "PELVIC ROCKING", equipment: ""),
//            Category.Workout(exercise: "PIRIFORMIS STRETCH", equipment: ""),
//            Category.Workout(exercise: "PLANK", equipment: ""),
//            Category.Workout(exercise: "PRANCING", equipment: ""),
//            Category.Workout(exercise: "PRONE DOUBLE LEG LIFT", equipment: ""),
//            Category.Workout(exercise: "PRONE PREP", equipment: ""),
//            Category.Workout(exercise: "PRONE PRESS UP", equipment: ""),
//            Category.Workout(exercise: "PUSH-UP", equipment: ""),
//            Category.Workout(exercise: "QUADRUPED LEG ABDUCTION", equipment: ""),
//            Category.Workout(exercise: "QUADRUPED SWAN", equipment: ""),
//            Category.Workout(exercise: "REACHING AND SHRUG", equipment: ""),
//            Category.Workout(exercise: "RESTING POSE", equipment: ""),
//            Category.Workout(exercise: "REVERSE PLANK", equipment: ""),
//            Category.Workout(exercise: "RIB CAGE CLOSURE", equipment: ""),
//            Category.Workout(exercise: "ROCKING", equipment: ""),
//            Category.Workout(exercise: "ROLL OVER", equipment: ""),
//            Category.Workout(exercise: "ROLL UP", equipment: ""),
//            Category.Workout(exercise: "ROLL UP ASSISTED", equipment: ""),
//            Category.Workout(exercise: "ROLLING", equipment: ""),
//            Category.Workout(exercise: "ROLLING BACK", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: "")
//        ]),
//        Category(title: "Megaformer", description: "Short Description", options: [
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: "")
//        ]),
//        Category(title: "Pilates Chair", description: "Short Description", options: [
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: "")
//        ]),
//        Category(title: "Reformer", description: "Short Description", options: [
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: "")
//        ]),
//        Category(title: "Spin", description: "Short Description", options: [
//            Category.Workout(exercise: "9 to 3", equipment: ""),
//            Category.Workout(exercise: "Form Sprints", equipment: ""),
//            Category.Workout(exercise: "Isolated Leg Training", equipment: ""),
//            Category.Workout(exercise: "Jumps", equipment: ""),
//            Category.Workout(exercise: "Jumps on a hill", equipment: ""),
//            Category.Workout(exercise: "Kick and Pulls", equipment: ""),
//            Category.Workout(exercise: "Pistons", equipment: ""),
//            Category.Workout(exercise: "Progressive Climbs", equipment: ""),
//            Category.Workout(exercise: "Running on a hill", equipment: ""),
//            Category.Workout(exercise: "Seated Climb", equipment: ""),
//            Category.Workout(exercise: "Seated flat", equipment: ""),
//            Category.Workout(exercise: "Single Leg Focus", equipment: ""),
//            Category.Workout(exercise: "Speed Endurance Interval", equipment: ""),
//            Category.Workout(exercise: "Spin ups", equipment: ""),
//            Category.Workout(exercise: "Sprints on a flat", equipment: ""),
//            Category.Workout(exercise: "Sprints on a hill", equipment: ""),
//            Category.Workout(exercise: "Standing Climb", equipment: ""),
//            Category.Workout(exercise: "Standing Flat", equipment: ""),
//            Category.Workout(exercise: "Steady RPM Tempo", equipment: ""),
//            Category.Workout(exercise: "Strength Sprint", equipment: ""),
//            Category.Workout(exercise: "Surges / Breakways", equipment: ""),
//            Category.Workout(exercise: "Tabata", equipment: ""),
//            Category.Workout(exercise: "Toe touch drill", equipment: ""),
//            Category.Workout(exercise: "Top only", equipment: ""),
//        ]),
//        Category(title: "Lower Srength", description: "Short Description", options: [
//            Category.Workout(exercise: "BACK LUNGE AND LIFT", equipment: ""),
//            Category.Workout(exercise: "BUTT KICKERS", equipment: ""),
//            Category.Workout(exercise: "CALF RAISES", equipment: ""),
//            Category.Workout(exercise: "CAMEL", equipment: ""),
//            Category.Workout(exercise: "CLAMSHELL", equipment: ""),
//            Category.Workout(exercise: "CRAB WALK", equipment: ""),
//            Category.Workout(exercise: "CURTSY LUNGE", equipment: ""),
//            Category.Workout(exercise: "FIRE HYDRANTS", equipment: ""),
//            Category.Workout(exercise: "FORWARD LEG LIFT", equipment: ""),
//            Category.Workout(exercise: "FORWARD LUNGE", equipment: ""),
//            Category.Workout(exercise: "FLUTTER KICKS", equipment: ""),
//            Category.Workout(exercise: "GOBLET SQUAT", equipment: ""),
//            Category.Workout(exercise: "GLUTE BRIDGE", equipment: ""),
//            Category.Workout(exercise: "GLUTE BRIDGE WITH SQUEEZE", equipment: ""),
//            Category.Workout(exercise: "GLUTE KICKBACK", equipment: ""),
//            Category.Workout(exercise: "GOOD MORNINGS", equipment: ""),
//            Category.Workout(exercise: "HAMSTRING CURL", equipment: ""),
//            Category.Workout(exercise: "HIGH KNEES", equipment: ""),
//            Category.Workout(exercise: "JUMPING ROPE", equipment: ""),
//            Category.Workout(exercise: "LYING SIDE LEG RAISES", equipment: ""),
//            Category.Workout(exercise: "MOUNTAIN CLIMBERS", equipment: ""),
//            Category.Workout(exercise: "REVERSE LUNGE", equipment: ""),
//            Category.Workout(exercise: "SIDE LUNGE", equipment: ""),
//            Category.Workout(exercise: "SIDE SHUFFLE", equipment: ""),
//            Category.Workout(exercise: "SINGLE LEG DEADLIFT", equipment: ""),
//            Category.Workout(exercise: "SKATERS", equipment: ""),
//            Category.Workout(exercise: "SQUAT", equipment: ""),
//            Category.Workout(exercise: "SQUAT TO SIDE LEG LIFT", equipment: ""),
//            Category.Workout(exercise: "STATIONARY LUNGE", equipment: ""),
//            Category.Workout(exercise: "STRAIGHT LEG KICKBACK", equipment: ""),
//            Category.Workout(exercise: "SUITCASE SQUAT", equipment: ""),
//            Category.Workout(exercise: "SUMO SQUAT", equipment: ""),
//            Category.Workout(exercise: "WALKING LUNGES", equipment: ""),
//        ]),
//        Category(title: "Stretch", description: "Short Description", options: [
//            Category.Workout(exercise: "90/90 STRETCH", equipment: ""),
//            Category.Workout(exercise: "ALL FOUR QUAD STRETCH", equipment: ""),
//            Category.Workout(exercise: "ANKLE CIRCLES", equipment: ""),
//            Category.Workout(exercise: "BUTTERFLY STRETCH", equipment: ""),
//            Category.Workout(exercise: "CAT DOG STRETCH", equipment: ""),
//            Category.Workout(exercise: "CHEST AND SHOULDER STRETCH", equipment: ""),
//            Category.Workout(exercise: "COBRA", equipment: ""),
//            Category.Workout(exercise: "CROSSBODY SHOULDER STRETCH", equipment: ""),
//            Category.Workout(exercise: "DRAGON LUNGE", equipment: ""),
//            Category.Workout(exercise: "DYNATIC CHEST STRETCH", equipment: ""),
//            Category.Workout(exercise: "EXTENDED PUPPY", equipment: ""),
//            Category.Workout(exercise: "FIGURE 4", equipment: ""),
//            Category.Workout(exercise: "FROG STRETCH", equipment: ""),
//            Category.Workout(exercise: "GLUTE BRIDGE", equipment: ""),
//            Category.Workout(exercise: "HUG KNEES TO CHEST", equipment: ""),
//            Category.Workout(exercise: "KNEE TO CHEST", equipment: ""),
//            Category.Workout(exercise: "KNEELING HIP FLEXOR STRETCH", equipment: ""),
//            Category.Workout(exercise: "LEG UP HAMSTRING STRETCH", equipment: ""),
//            Category.Workout(exercise: "LUNGE WITH SPINAL TWIST", equipment: ""),
//            Category.Workout(exercise: "LUNGING HIP FLEXOR STRETCH", equipment: ""),
//            Category.Workout(exercise: "LYING KNEE TO CHEST STRETCH", equipment: ""),
//            Category.Workout(exercise: "LYING PECTORAL STRETCH", equipment: ""),
//            Category.Workout(exercise: "LYING QUAD STRETCH", equipment: ""),
//            Category.Workout(exercise: "LYING SUPINE TWIST", equipment: ""),
//            Category.Workout(exercise: "PIRIFORMIS STRETCH", equipment: ""),
//            Category.Workout(exercise: "PRETZEL STRETCH", equipment: ""),
//            Category.Workout(exercise: "SEATED SHOULDER SQUEEZE", equipment: ""),
//            Category.Workout(exercise: "SIDE LUNGE STRETCH", equipment: ""),
//            Category.Workout(exercise: "SIDE BEND STRETCH", equipment: ""),
//            Category.Workout(exercise: "STAND QUAD STRETCH", equipment: ""),
//            Category.Workout(exercise: "STANDING BICEP STRETCH", equipment: ""),
//            Category.Workout(exercise: "STANDING HAMSTRING STRETCH", equipment: ""),
//            Category.Workout(exercise: "STANDING HAMSTRING CURL", equipment: ""),
//            Category.Workout(exercise: "STANDING HIP FLEXOR STRETCH", equipment: ""),
//            Category.Workout(exercise: "STANDING LEG SWING", equipment: ""),
//            Category.Workout(exercise: "STANDING TOE TOUCH", equipment: ""),
//            Category.Workout(exercise: "TRICEP STRETCH", equipment: ""),
//            Category.Workout(exercise: "UPWARD STRETCH", equipment: "")
//        ]),
//        Category(title: "TRX", description: "Short Description", options: [
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: "")
//        ]),
//        Category(title: "Yoga", description: "Short Description", options: [
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: ""),
//            Category.Workout(exercise: "Pushups", equipment: "")
//        ]),
//        Category(title: "Yin Yoga", description: "Short Description", options: [
//            Category.Workout(exercise: "Ankle Strech", equipment: ""),
//            Category.Workout(exercise: "Bound Angles", equipment: ""),
//            Category.Workout(exercise: "Bridge", equipment: ""),
//            Category.Workout(exercise: "Broken Wings", equipment: ""),
//            Category.Workout(exercise: "Butterfly", equipment: ""),
//            Category.Workout(exercise: "Camel", equipment: ""),
//            Category.Workout(exercise: "Cat Pulling Its tail", equipment: ""),
//            Category.Workout(exercise: "Caterpillar", equipment: ""),
//            Category.Workout(exercise: "Clam Shell Knees Together Feet Apart", equipment: ""),
//            Category.Workout(exercise: "Crocodile", equipment: ""),
//            Category.Workout(exercise: "Cross Leg Fold", equipment: ""),
//            Category.Workout(exercise: "Dangling", equipment: ""),
//            Category.Workout(exercise: "Deer", equipment: ""),
//            Category.Workout(exercise: "Dragon", equipment: ""),
//            Category.Workout(exercise: "Dragonfly", equipment: ""),
//            Category.Workout(exercise: "Ear Pressure", equipment: ""),
//            Category.Workout(exercise: "Easy Pose Forward Bend", equipment: ""),
//            Category.Workout(exercise: "Firelog", equipment: ""),
//            Category.Workout(exercise: "Forward Bend", equipment: ""),
//            Category.Workout(exercise: "Frog", equipment: ""),
//            Category.Workout(exercise: "Half Butterfly", equipment: ""),
//            Category.Workout(exercise: "Half Lotus", equipment: ""),
//            Category.Workout(exercise: "Half Moon Knee On Floor", equipment: ""),
//            Category.Workout(exercise: "Half pigeon", equipment: ""),
//            Category.Workout(exercise: "Happy baby", equipment: ""),
//            Category.Workout(exercise: "Melting heart", equipment: ""),
//            Category.Workout(exercise: "Prone Arms Extended On Floor One Elbow Bent Close", equipment: ""),
//            Category.Workout(exercise: "Puppy Dog", equipment: ""),
//            Category.Workout(exercise: "Reclining Hero", equipment: ""),
//            Category.Workout(exercise: "Reclining Twist", equipment: ""),
//            Category.Workout(exercise: "Resting Half Frog", equipment: ""),
//            Category.Workout(exercise: "Restortive Bridge", equipment: ""),
//            Category.Workout(exercise: "Revolved Head To Knee", equipment: ""),
//            Category.Workout(exercise: "Saddle", equipment: ""),
//            Category.Workout(exercise: "Seal", equipment: ""),
//            Category.Workout(exercise: "Seated Straddle With Block", equipment: ""),
//            Category.Workout(exercise: "Seated Windshield Wiper", equipment: ""),
//            Category.Workout(exercise: "Shavasana", equipment: ""),
//            Category.Workout(exercise: "Shoelace", equipment: ""),
//            Category.Workout(exercise: "Side Plank Knee On Floor", equipment: ""),
//            Category.Workout(exercise: "Sitting Swan", equipment: ""),
//            Category.Workout(exercise: "Sky Archer", equipment: ""),
//            Category.Workout(exercise: "Sleeping Swan", equipment: ""),
//            Category.Workout(exercise: "Snail", equipment: ""),
//            Category.Workout(exercise: "Sphinx", equipment: ""),
//            Category.Workout(exercise: "Sqaure", equipment: ""),
//            Category.Workout(exercise: "Squat", equipment: ""),
//            Category.Workout(exercise: "Straddle", equipment: ""),
//            Category.Workout(exercise: "Supine Hips", equipment: ""),
//            Category.Workout(exercise: "Swan", equipment: ""),
//            Category.Workout(exercise: "Tail Wagging", equipment: ""),
//            Category.Workout(exercise: "Toe Squat", equipment: "")
//        ]),
//    ]
    
    /// Is The Playing Category Currently Active
    @Published var isPlaying = false
    
    /// Which Category Is Currently Playing
    @Published var playing: Category?
    
    /// Is True If The User Is Currently Adding A Category
    @Published var add = false
    
    /// The Index Of The User Classes Array Of Which Class He Is Editing
    @Published var editIndex: Int?
    
    /// Edit The Workouts
    @Published var editWorkouts = false
    
    /// Currently Playing Duration Progress
    @Published var progressed = 0.0
    @Published var duration = 0.0
    
    @Published var setNewName = false
    @Published var newName = ""
    
    /// Save A Name
    func saveName() {
        
        // Make Sure New Name Is Not Empty
        guard !self.newName.isEmpty else { self.setHandle(.err("User Name Must Not Be Empty")); return }
        
        /// Making User Editable
        var editable = user!
        
        // Setting Name
        editable.name = newName
        
        // Update User Info
        self.save(editable)
        
        // Toggle New Name
        withAnimation { setNewName = false }
    }
    
    @Published var timer: Timer?
    
    func toggleTimer(_ duration: TimeInterval) {
        
        if duration != self.duration { timer = nil }
        
        self.duration = duration
        if timer != nil {
            withAnimation {
                timer?.invalidate()
                timer = nil
            }
        } else {
            self.timer = Timer(timeInterval: 1, repeats: true) { time in
                if self.progressed < self.duration {
                    withAnimation { self.progressed += 1 }
                } else {
                    self.progressed = 0.0
                    self.duration = 0.0
                    self.timer?.invalidate()
                    self.timer = nil
                    withAnimation { self.isPlaying = false }
                }
            }
            RunLoop.main.add(timer!, forMode: .common)
        }
    }
    
    /// Is A Class ID Currently Playing
    public func isCurrentlyPlaying(for id: String) -> Bool {
        guard let current = self.playing?.id else { return false }
        return self.isPlaying && current == id
    }
    
    /// Sets Handle On The Main Thread
    func setHandle(_ value: ErrorHandle) {
        DispatchQueue.main.async { withAnimation { self.handle = Handle(value: value, loading: false) } }
    }
    
    /// Sets Handle On The Main Thread For Errors
    func setHandle(_ error: Error) { setHandle(.err(error.localizedDescription)) }
    
    /// Sets Handle On The Main Thread For Unkown Errors
    func setHandle() { setHandle(.err("An Unkown Error Ocurred")) }
    
    /// Toggles Current Loading Value On The Main Thread
    func setLoading(_ value: Bool?) {
        DispatchQueue.main.async { withAnimation { self.handle.loading = value ?? !self.handle.loading } }
    }
    
    @AppStorage("status") var status = false
    
    func logOut() {
        try! Auth.auth().signOut()
        DispatchQueue.main.async { self.status = false }
    }
}
