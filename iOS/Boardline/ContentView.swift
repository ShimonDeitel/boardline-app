import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: BoardingEntry?

    var body: some View {
        NavigationStack {
            Group {
                if store.entries.isEmpty {
                    ContentUnavailableView("No entries yet", systemImage: "pawprint.fill", description: Text("Tap + to log your first entry."))
                } else {
                    List {
                        ForEach(store.entries) { entry in
                            Button {
                                editingEntry = entry
                            } label: {
                                HStack {
                                    Text(entry.startDate, style: .date)
                                        .font(Theme.headlineFont)
                                    Spacer()
                                    Text(entry.endDate, style: .date)
                                        .foregroundStyle(Theme.accent)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("entryRow_\(entry.id.uuidString)")
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                }
            }
            .navigationTitle("Boardline")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryFormView(mode: .add)
                    .environmentObject(store)
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(mode: .edit(entry))
                    .environmentObject(store)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(purchases)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(purchases)
            }
        }
    }
}

enum FormMode: Equatable {
    case add
    case edit(BoardingEntry)
}

struct EntryFormView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    let mode: FormMode

    @State private var draftStartDate: Date = Date()
    @State private var draftEndDate: Date = Date()
    @State private var draftLocation: String = ""
    @State private var draftSitterContact: String = ""

    init(mode: FormMode) {
        self.mode = mode
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    DatePicker("Startdate", selection: $draftStartDate, displayedComponents: .date)
                    DatePicker("Enddate", selection: $draftEndDate, displayedComponents: .date)
                    TextField("Location", text: $draftLocation)
                        .accessibilityIdentifier("field_location")
                    TextField("Sittercontact", text: $draftSitterContact)
                        .accessibilityIdentifier("field_sitterContact")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onAppear { populateIfEditing() }
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func populateIfEditing() {
        if case .edit(let entry) = mode {
            draftStartDate = entry.startDate
            draftEndDate = entry.endDate
            draftLocation = entry.location
            draftSitterContact = entry.sitterContact
        }
    }

    private func save() {
        switch mode {
        case .add:
            let entry = BoardingEntry(startDate: draftStartDate, endDate: draftEndDate, location: draftLocation, sitterContact: draftSitterContact)
            store.add(entry)
        case .edit(var entry):
            entry.startDate = draftStartDate
            entry.endDate = draftEndDate
            entry.location = draftLocation
            entry.sitterContact = draftSitterContact
            store.update(entry)
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
