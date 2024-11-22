import SwiftUI
import GoogleSignIn

struct SwipeView: View {
    let user: GIDGoogleUser
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(0 ..< 3) { index in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 5)
                        .frame(width: 340, height: 400)
                        .offset(y: -CGFloat(index * 15))
                        .overlay {
                            VStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 300)
                                    .overlay {
                                        VStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 300)
                                                .overlay {
                                                    Text("Profile Photo")
                                                }
                                            
                                            Text("Sample Name, 25")
                                                .font(.title2)
                                            Text("New York, NY")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                    }
                            }
                        }
                }
            }
            
            HStack(spacing: 20) {
                Button {
                    
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 30))
                        .foregroundColor(.red)
                        .padding(20)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 3)
                }
                
                Button {
                    
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.green)
                        .padding(20)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 3)
                }
            }
            .padding(.top, 30)
        }
        .navigationTitle("Discover")
    }
}
