import SwiftUI
import SimpleToast

struct OutfitDetailView: View {
    @Binding var outfit: Outfit
    var animation: Namespace.ID
    @EnvironmentObject var outfitsVM: OutfitsViewModel
    @Environment(\.dismiss) private var dismissView
    
    private let spacing = SpacingValues()
    
    private let toastOptions = SimpleToastOptions(
        alignment: .top,
        hideAfter: 4,
        animation: .easeInOut,
        modifierType: .slide
    )
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: spacing.large) {
                    OutfitImageView(
                        imageURL: outfit.imageURL,
                        outfitImage: outfitsVM.loadedImages[outfit.imageURL],
                        geometry: geometry,
                        onDismiss: { dismissView() },
                        loadImage: outfitsVM.loadImage
                    )
                    
                    VStack(alignment: .leading, spacing: spacing.medium) {
                        VStack(alignment: .leading, spacing: spacing.small) {
                            Text("Rating")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.black.opacity(0.6))
                            
                            HStack {
                                starRatingDisplay(
                                    rating: 3.5,
                                    ratingCount: 128
                                )
                                
                                Spacer()
                                
                                saveCountDisplay(count: 15)
                            }
                        }
                        
                        Divider().padding(.vertical, spacing.xsmall)
                        
                        VStack(alignment: .leading, spacing: spacing.small) {
                            Text("Style")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.black.opacity(0.6))
                            
                            if outfitsVM.isEditingOutfit && outfitsVM.currentEditingOutfitId == outfit.id {
                                editableStyleSection
                            } else {
                                StyleTagsSection(
                                    styleIds: outfit.styleIds,
                                    availableStyles: outfitsVM.availableStyles
                                )
                            }
                        }
                        
                        Divider().padding(.vertical, spacing.xsmall)
                        
                        VStack(alignment: .leading, spacing: spacing.small) {
                            Text("Visibility")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.black.opacity(0.6))
                            
                            if outfitsVM.isEditingOutfit && outfitsVM.currentEditingOutfitId == outfit.id {
                                editableVisibilitySection
                            } else {
                                visibilityDisplay
                            }
                        }
                        
                        Divider().padding(.vertical, spacing.xsmall)
                        
                        VStack(alignment: .leading, spacing: spacing.small) {
                            Text("Location")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.black.opacity(0.6))
                            
                            locationDisplay
                        }
                        
                        Divider().padding(.vertical, spacing.xsmall)
                        
                        HStack {
                            dateDisplay(date: outfit.createDate)
                            
                            Spacer()
                            
                            HStack {
                                Button(action: {
                                    if outfitsVM.isEditingOutfit {
                                        outfitsVM.cancelOutfitEdit()
                                    } else {
                                        outfitsVM.startOutfitEdit(outfit: outfit)
                                    }
                                }) {
                                    Text(outfitsVM.isEditingOutfit ? "Cancel" : "Edit")
                                        .font(.subheadline)
                                        .foregroundStyle(.black)
                                }
                                
                                if outfitsVM.isEditingOutfit {
                                    Button(action: {
                                        Task {
                                            await outfitsVM.updateOutfit()
                                        }
                                    }) {
                                        Text("Save")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.blue)
                                    }
                                    .padding(.leading, spacing.small)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, spacing.medium)
            }
            .scrollIndicators(.hidden)
        }
        .padding()
        .background(Color.primaryBackground)
        .navigationTransition(.zoom(sourceID: outfit.id, in: animation))
        .simpleToast(isPresented: $outfitsVM.showOutfitUpdatedToast, options: toastOptions) {
            ToastMessage(iconName: "checkmark.circle", message: "Successfully updated outfit")
        }
        .simpleToast(isPresented: $outfitsVM.showOutfitDeletedToast, options: toastOptions) {
            ToastMessage(iconName: "x.circle", message: "Unable to update outfit. Please try again later.")
        }
        .onDisappear {
            if outfitsVM.isEditingOutfit {
                outfitsVM.cancelOutfitEdit()
            }
        }
    }
    
    private var editableStyleSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing.small) {
                ForEach(outfitsVM.availableStyles, id: \.id) { style in
                    styleTagToggle(style: style)
                }
            }
        }
    }
    
    private var editableVisibilitySection: some View {
        Toggle(isOn: Binding(
            get: { outfitsVM.editedIsPublic == true},
            set: { outfitsVM.editedIsPublic = $0 }
        )) {
            HStack(spacing: spacing.small) {
                Image(systemName: outfitsVM.editedIsPublic == true ? "eye.fill" : "eye.slash.fill")
                    .foregroundStyle(.black)
                Text(outfitsVM.editedIsPublic == true ? "Public" : "Private")
                    .font(.subheadline)
                    .foregroundStyle(.black)
            }
        }
        .frame(height: 20)
    }
    
    private var locationDisplay: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
                .foregroundStyle(Color.black)
            Text(outfit.locationString)
                .font(.subheadline)
                .foregroundStyle(Color.black)
        }
    }
    
    private var visibilityDisplay: some View {
        HStack(spacing: spacing.small) {
            Image(systemName: outfit.isPublic == true ? "eye.fill" : "eye.slash.fill")
                .foregroundStyle(Color.black)
            Text(outfit.isPublic == true ? "Public" : "Private")
                .font(.subheadline)
                .foregroundStyle(Color.black)
        }
        .frame(height: 20)
    }
    
    private func dateDisplay(date: Date) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "calendar")
                .font(.caption)
                .foregroundStyle(.gray.opacity(0.8))
            
            Text("Added \(outfitsVM.formatDate(date))")
                .font(.caption)
                .foregroundStyle(.gray.opacity(0.8))
            
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
    
    private func starRatingDisplay(rating: Double, ratingCount: Int) -> some View {
        let maxStars = 4
        let filledColor: Color = .black
        let emptyColor: Color = .black.opacity(0.3)
        
        return HStack(spacing: 4) {
            ForEach(0..<maxStars, id: \.self) { index in
                
                let fillAmount = min(max(rating - Double(index), 0), 1)
                let gradientStops: [Gradient.Stop] = [
                    .init(color: filledColor, location: fillAmount),
                    .init(color: emptyColor, location: fillAmount)
                ]
                
                Image(systemName: "star.fill")
                    .foregroundStyle(
                        LinearGradient(
                            stops: gradientStops,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .font(.system(size: 16))
            }
            
            Text("(\(ratingCount))")
                .font(.caption)
                .foregroundStyle(Color.black.opacity(0.7))
                .padding(.leading, 4)
        }
    }
    
    private func saveCountDisplay(count: Int) -> some View {
        HStack(spacing: spacing.xsmall) {
            Image(systemName: "bookmark.fill")
                .font(.footnote)
                .foregroundStyle(.black.opacity(0.7))
            
            Text("\(count) saves")
                .font(.footnote)
                .foregroundStyle(.black.opacity(0.7))
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
        .background(
            Capsule()
                .fill(.black.opacity(0.05))
        )
    }
    
    private func styleTagToggle(style: Style) -> some View {
        let isSelected = outfitsVM.editedStyleIds.contains(style.id)
        
        return Button(action: {
            outfitsVM.toggleStyleEdits(styleId: style.id)
        }) {
            Text(style.name)
                .font(.footnote)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.black : Color.black.opacity(0.05))
                )
                .foregroundStyle(isSelected ? .white : .black)
        }
    }
}


struct OutfitImageView: View {
    let imageURL: String
    let outfitImage: Image?
    let geometry: GeometryProxy
    let onDismiss: () -> Void
    let loadImage: (String) -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if let outfitImage = outfitImage {
                outfitImage
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.85)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                
                dismissButton(action: onDismiss)
            } else {
                ProgressView()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
                    .onAppear {
                        loadImage(imageURL)
                    }
            }
        }
    }
    
    private func dismissButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .foregroundStyle(.black)
                .padding()
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)
                )
        }
        .padding()
    }
}

struct StyleTagsSection: View {
    let styleIds: [Int64]
    let availableStyles: [Style]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(styleIds, id: \.self) { styleId in
                    if let style = availableStyles.first(where: {$0.id == styleId}) {
                        styleTag(name: style.name)
                    }
                }
            }
        }
    }
    
    private func styleTag(name: String) -> some View {
        Text(name)
            .font(.footnote)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.black .opacity(0.05))
            )
            .foregroundStyle(.black)
    }
}

struct SpacingValues {
    let xsmall: CGFloat = 4
    let small: CGFloat = 8
    let medium: CGFloat = 16
    let large: CGFloat = 24
}
