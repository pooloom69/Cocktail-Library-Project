//
//  UserSession.swift.swift
//  Cocktail-Library
//
//  Created by Sola Lhim on 11/3/25.
//

import FirebaseAuth
import FirebaseFirestore

@MainActor
final class UserSession: ObservableObject {
    @Published var currentUser: User?
    @Published var username: String = ""
    
    private var db = Firestore.firestore()

    init() {
//        self.currentUser = Auth.auth().currentUser
//        if currentUser != nil {
//            fetchUserProfile()
//        }


        Auth.auth().addStateDidChangeListener { _, user in
            self.currentUser = user
            if user != nil {
                self.fetchUserProfile()
            } else {
                self.username = ""
            }
        }
    }

    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print(" Failed to fetch profile:", error.localizedDescription)
                return
            }

            if let data = snapshot?.data(),
               let name = data["username"] as? String {
                DispatchQueue.main.async {
                    self.username = name
                    print(" Username loaded:", name)
                }
            } else {
                print(" No username found for user \(uid)")
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            self.username = ""
        } catch {
            print("Sign out error:", error.localizedDescription)
        }
    }
}

