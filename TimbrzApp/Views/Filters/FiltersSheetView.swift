import SwiftUI

struct FiltersSheetView: View {
    @Binding var filters: FilterState
    let allListingsCount: Int
    let onApply: (FilterState) -> Void

    @Environment(\.dismiss) private var dismiss

    // Local copy to allow cancel
    @State private var draft: FilterState

    init(filters: Binding<FilterState>, allListingsCount: Int, onApply: @escaping (FilterState) -> Void) {
        self._filters = filters
        self.allListingsCount = allListingsCount
        self.onApply = onApply
        _draft = State(initialValue: filters.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    priceSection
                    basicsSection
                    acresSection
                    propertyTypeSection
                    waterTerrainSection
                    activitiesSection
                    hoaStrSection
                }
                .padding(.horizontal)
                .padding(.bottom, 100) // room for sticky button
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") { draft.reset() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8) {
                    Button(action: applyAndDismiss) {
                        Text("See \(estimatedResults) results")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                    .accessibilityLabel("See \(estimatedResults) results")
                }
                .background(.ultraThinMaterial)
            }
        }
    }

    private var estimatedResults: Int {
        // Light estimate by applying to the sample set
        draft.apply(to: Listing.samples).count
    }

    private func applyAndDismiss() {
        filters = draft
        onApply(draft)
        dismiss()
    }

    // MARK: Sections
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Price").font(.headline)
            HStack {
                Menu(draft.priceMin?.formatted() ?? "No Min") {
                    Button("No Min") { draft.priceMin = nil }
                    ForEach(FilterState.priceSteps, id: \.self) { val in
                        Button(val.formatted()) { draft.priceMin = val }
                    }
                }
                .buttonStyle(.bordered)
                Spacer()
                Menu(draft.priceMax?.formatted() ?? "No Max") {
                    Button("No Max") { draft.priceMax = nil }
                    ForEach(FilterState.priceSteps, id: \.self) { val in
                        Button(val.formatted()) { draft.priceMax = val }
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var basicsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Basics").font(.headline)
            HStack {
                Menu("Beds: \(draft.bedsMin ?? 0)+") {
                    ForEach(FilterState.bedsSteps, id: \.self) { v in
                        Button("\(v)+") { draft.bedsMin = v }
                    }
                }
                .buttonStyle(.bordered)

                Menu("Baths: \(String(format: "%.1f", draft.bathsMin ?? 0))+") {
                    ForEach(FilterState.bathsSteps, id: \.self) { v in
                        Button("\(String(format: "%.1f", v))+") { draft.bathsMin = v }
                    }
                }
                .buttonStyle(.bordered)
            }
            HStack {
                Menu("Year ≥ \(draft.yearMin?.description ?? "Any")") {
                    Button("Any") { draft.yearMin = nil }
                    ForEach(FilterState.yearSteps, id: \.self) { v in
                        Button("\(v)") { draft.yearMin = v }
                    }
                }
                .buttonStyle(.bordered)
                Spacer()
                Menu("Year ≤ \(draft.yearMax?.description ?? "Any")") {
                    Button("Any") { draft.yearMax = nil }
                    ForEach(FilterState.yearSteps, id: \.self) { v in
                        Button("\(v)") { draft.yearMax = v }
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var acresSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lot acres").font(.headline)
            HStack {
                Menu("Min: \(draft.acresMin?.formatted() ?? "Any")") {
                    Button("Any") { draft.acresMin = nil }
                    ForEach(FilterState.acresSteps, id: \.self) { v in
                        Button("\(v.formatted())") { draft.acresMin = v }
                    }
                }.buttonStyle(.bordered)
                Spacer()
                Menu("Max: \(draft.acresMax?.formatted() ?? "Any")") {
                    Button("Any") { draft.acresMax = nil }
                    ForEach(FilterState.acresSteps, id: \.self) { v in
                        Button("\(v.formatted())") { draft.acresMax = v }
                    }
                }.buttonStyle(.bordered)
            }
        }
    }

    private var propertyTypeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Structure type").font(.headline)
            ChipsGrid(options: FilterState.propertyTypeOptions, selection: $draft.propertyTypes)
        }
    }

    private var waterTerrainSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Environment").font(.headline)
            Text("Water access").font(.subheadline)
            ChipsGrid(options: FilterState.waterOptions, selection: $draft.water)
            Text("Terrain & cover").font(.subheadline)
            ChipsGrid(options: FilterState.terrainOptions, selection: $draft.terrain)
        }
    }

    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Activities nearby").font(.headline)
            ChipsGrid(options: FilterState.activityOptions, selection: $draft.activities)
        }
    }

    private var hoaStrSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Other").font(.headline)
            Toggle("STR permitted", isOn: Binding(
                get: { draft.strAllowed ?? false },
                set: { draft.strAllowed = $0 }
            ))
            Menu("Max HOA: \(draft.hoaMax?.formatted() ?? "Any")") {
                Button("Any") { draft.hoaMax = nil }
                ForEach([50,100,150,250,400,600,800], id: \.self) { v in
                    Button("$\(v)") { draft.hoaMax = v }
                }
            }.buttonStyle(.bordered)
        }
    }
}

private struct ChipsGrid: View {
    let options: [String]
    @Binding var selection: Set<String>

    private let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 8), count: 2)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(options, id: \.self) { opt in
                let isOn = selection.contains(opt)
                Text(opt)
                    .font(.footnote)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(isOn ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.12))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(isOn ? Color.accentColor : Color.clear, lineWidth: 1)
                    )
                    .onTapGesture {
                        if isOn { selection.remove(opt) } else { selection.insert(opt) }
                    }
                    .accessibilityLabel(opt + (isOn ? ", selected" : ""))
            }
        }
    }
}
