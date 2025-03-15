import SwiftUI
import SimpleToast

struct OutfitsView: View {
    @EnvironmentObject var authController: AuthController
    @Namespace private var animation
    @State private var navigationPath: [String] = []
    @StateObject private var outfitsVM = OutfitsViewModel(
        outfitService: OutfitService(),
        styleService: StyleService()
    )
    
    var columns: [GridItem] {
        let count = outfitsVM.isCompactGrid ? 3 : 2
        return Array(repeating: GridItem(spacing: outfitsVM.isCompactGrid ? 8 : 10), count: count)
    }
    
    private let toastOptions = SimpleToastOptions(
        alignment: .top,
        hideAfter: 4,
        animation: .easeInOut,
        modifierType: .slide
    )
    
    var body: some View {
        Group {
            NavigationStack {
                VStack {
                    header()
                    
                    if !outfitsVM.filteredStyles.isEmpty {
                        activeFiltersView()
                            .padding(.horizontal)
                    }
                    
                    outfitGrid(screenSize: UIScreen.main.bounds.size)
                }
                .background(Color.primaryBackground.ignoresSafeArea())
                .navigationDestination(for: Outfit.self) { outfit in
                    if let index = outfitsVM.outfits.firstIndex(where: { $0.id == outfit.id }) {
                        OutfitDetailView(outfit: $outfitsVM.outfits[index], animation: animation)
                            .toolbarVisibility(.hidden, for: .navigationBar)
                    }
                }
                .navigationDestination(isPresented: $outfitsVM.uploadOutfit) {
                    UploadOutfitView(onComplete: {
                        navigationPath.removeAll()
                    })
                    .toolbarRole(.editor)
                }
                .simpleToast(isPresented: $outfitsVM.showOutfitDeletedToast, options: toastOptions) {
                    ToastMessage(iconName: "checkmark.circle", message: "Successfully deleted outfit")
                }
                .simpleToast(isPresented: $outfitsVM.showOutfitAddedToast, options: toastOptions) {
                    ToastMessage(iconName: "checkmark.circle", message: "Successfully added outfit")
                }
                .sheet(isPresented: $outfitsVM.showFilterMenu) {
                    filterMenu()
                        .presentationDetents([.fraction(0.75)])
                }
            }
            .environmentObject(outfitsVM)
        }
        .onAppear {
            Task {
                if let userId = authController.session?.user.id {
                    await outfitsVM.fetchOutfits(userId: userId)
                }
            }
        }
    }
    
    func activeFiltersView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(outfitsVM.availableStyles.filter { outfitsVM.filteredStyles.contains($0.id) }) { style in
                    activeFilterTag(style: style)
                }
                
                clearFiltersButton()
            }
        }
    }
    
    func activeFilterTag(style: Style) -> some View {
        HStack {
            Text(style.name)
                .font(.caption)
                .padding(.leading, 8)
                .foregroundStyle(.black)
            
            Button {
                outfitsVM.toggleStyleFilter(styleId: style.id)
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
            }
            .padding(.trailing, 8)
        }
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.2))
        .clipShape(Capsule())
    }
    
    func clearFiltersButton() -> some View {
        Button {
            outfitsVM.clearStyleFilters()
        } label: {
            Text("Clear All")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    func doneButton() -> some View {
        Button {
            outfitsVM.showFilterMenu = false
        } label: {
            Text("Done")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.bottom)
    }
    
    func filterMenu() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sort & Filter")
                .font(.headline)
                .padding(.top)
            
            Divider()
            
            sortOptionsSection()
            
            gridLayoutSection()
            
            styleFilterSection()
            
            Spacer()
            
            doneButton()
        }
        .padding()
    }
    
    func gridLayoutSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Grid Layout")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Picker("Grid Layout", selection: $outfitsVM.isCompactGrid) {
                Text("2x2 Grid").tag(false)
                Text("3x3 Grid").tag(true)
            }
            .pickerStyle(.segmented)
        }
    }
    
    func header() -> some View {
        HStack {
            Text("outfits")
                .font(.title3)
                .foregroundStyle(.black)
            
            Spacer()
            
            Button {
                outfitsVM.showFilterMenu = true
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title3)
            }
            .padding(.trailing, 8)
            
            Button {
                outfitsVM.uploadOutfit = true
            } label: {
                Image(systemName: "plus")
                    .font(.title3)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
    }
    
    func outfitGrid(screenSize: CGSize) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: outfitsVM.isCompactGrid ? 8 : 10) {
                ForEach(outfitsVM.filteredAndSortedOutfits) { outfit in
                    NavigationLink(value: outfit) {
                        OutfitCardView(screenSize: screenSize, outfit: outfit)
                            .frame(height: screenSize.height * 0.4)
                            .matchedTransitionSource(id: outfit.id, in: animation) {
                                $0
                                    .background(.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
    
    func sortOptionsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sort By")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Picker("Sort Order", selection: $outfitsVM.sortOrder) {
                ForEach(SortOrder.allCases) { order in
                    Text(order.rawValue).tag(order)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    func styleFilterButton(style: Style) -> some View {
        Button {
            outfitsVM.toggleStyleFilter(styleId: style.id)
        } label: {
            HStack {
                Text(style.name)
                    .font(.caption)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if outfitsVM.filteredStyles.contains(style.id) {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
            }
            .tint(.primary)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(outfitsVM.filteredStyles.contains(style.id) ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            .clipShape(Capsule())
        }
    }
    
    func styleFilterSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Filter by Style")
                .font(.subheadline)
                .fontWeight(.medium)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                    ForEach(outfitsVM.availableStyles) { style in
                        styleFilterButton(style: style)
                    }
                }
            }
            .frame(maxHeight: 150)
        }
    }
}
