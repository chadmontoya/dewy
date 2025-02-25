import SwiftUI

struct AgePreferenceView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var preferencesVM: PreferencesViewModel
    
    var body: some View {
        ZStack {
            Color.primaryBackground.ignoresSafeArea()
            
            VStack {
                AgeRangeSlider(
                    initialMinAge: preferencesVM.minAge,
                    initialMaxAge: preferencesVM.maxAge,
                    onAgeRangeChanged: { minAge, maxAge in
                        preferencesVM.updateAgePreference(minAge: minAge, maxAge: maxAge)
                    }
                )
                .padding(.horizontal)
            }
            .frame(height: 100)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Age Preference")
                    .foregroundStyle(Color.black)
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
        
    }
}

struct AgeRangeSlider: View {
    @State var lowerBound: CGFloat = 0
    @State var upperBound: CGFloat = 15
    @State var totalWidth: CGFloat = 0
    
    private let offsetValue: CGFloat = 40
    private let minAge: CGFloat = 18
    private let maxAge: CGFloat = 65
    
    let initialMinAge: Int
    let initialMaxAge: Int
    let onAgeRangeChanged: (Int, Int) -> Void
    
    private var lowerValue: Int {
        Int(mapValue(lowerBound, from: 0...totalWidth, to: CGFloat(minAge)...CGFloat(maxAge)))
    }
    
    private var upperValue: Int {
        Int(mapValue(upperBound, from: 0...totalWidth, to: CGFloat(minAge)...CGFloat(maxAge)))
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: upperBound - lowerBound, height: 4)
                        .offset(x: lowerBound + 20)
                    
                    HStack(spacing: 0) {
                        SliderHandle(
                            position: $lowerBound,
                            otherPosition: $upperBound,
                            limit: totalWidth,
                            isLeftHandle: true,
                            minValue: CGFloat(minAge),
                            maxValue: CGFloat(maxAge),
                            onValuesChanged: { lower, upper in
                                onAgeRangeChanged(lowerValue, upperValue)
                            }
                        )
                        SliderHandle(
                            position: $upperBound,
                            otherPosition: $lowerBound,
                            limit: totalWidth,
                            isLeftHandle: false,
                            minValue: CGFloat(minAge),
                            maxValue: CGFloat(maxAge),
                            onValuesChanged: { lower, upper in
                                onAgeRangeChanged(lowerValue, upperValue)
                            }
                        )
                    }
                    
                    AgeLabel(value: lowerValue, position: lowerBound, xOffset: 2.5)
                    AgeLabel(value: upperValue, position: upperBound, xOffset: 22.5)
                }
            }
            .frame(width: geometry.size.width)
            .onAppear() {
                totalWidth = geometry.size.width - offsetValue
                
                lowerBound = mapValue(CGFloat(initialMinAge), from: CGFloat(minAge)...CGFloat(maxAge), to: 0...totalWidth)
                upperBound = mapValue(CGFloat(initialMaxAge), from: CGFloat(minAge)...CGFloat(maxAge), to: 0...totalWidth)
            }
        }
    }
}

private extension AgeRangeSlider {
    func mapValue(_ value: CGFloat, from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> CGFloat {
        let fromDelta = from.upperBound - from.lowerBound
        guard fromDelta != 0 else { return 0 }
        let toDelta = to.upperBound - to.lowerBound
        return (value - from.lowerBound) / fromDelta * toDelta + to.lowerBound
    }
}

struct SliderHandle: View {
    @Binding var position: CGFloat
    @Binding var otherPosition: CGFloat
    let limit: CGFloat
    let isLeftHandle: Bool
    let minValue: CGFloat
    let maxValue: CGFloat
    let onValuesChanged: (CGFloat, CGFloat) -> Void
    
    private var stepSize: CGFloat {
        limit / (maxValue - minValue)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 25, height: 25)
                .foregroundStyle(Color.black)
            Circle()
                .frame(width: 15, height: 15)
                .foregroundStyle(Color.white)
        }
        .offset(x: position + (isLeftHandle ? 0 : -5))
        .gesture(
            DragGesture()
                .onChanged(onDragChanged)
                .onEnded(onDragEnded)
        )
    }
}

private extension SliderHandle {
    func onDragChanged(_ value: _ChangedGesture<DragGesture>.Value) {
        let newPosition = value.location.x
        
        if isLeftHandle {
            position = max(0, min(newPosition, otherPosition - stepSize))
        }
        else {
            position = min(limit, max(newPosition, otherPosition + stepSize))
        }
    }
    
    func onDragEnded(_ value: _ChangedGesture<DragGesture>.Value) {
        onValuesChanged(position, otherPosition)
    }
}

struct AgeLabel: View {
    var value: Int
    var position: CGFloat
    var xOffset: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            Text("\(value)")
            if value == 65 {
                Text("+")
            }
        }
        .foregroundStyle(Color.black)
        .offset(x: position + xOffset, y: -35)
    }
}
