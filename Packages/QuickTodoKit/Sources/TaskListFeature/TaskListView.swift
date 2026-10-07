//
//  TaskListView.swift
//  TaskListFeature
//
//  Created by Udhayanila on 29/01/25.
//

import DesignSystem
import SwiftUI
import TodoDomain

// MARK: - Task List View

/// The main screen. Presenting the editor is left to the caller through `onAddTask` and `onEditTask`.
public struct TaskListView: View {
    @Bindable private var viewModel: TaskListViewModel
    @Environment(\.scenePhase) private var scenePhase

    private let onAddTask: () -> Void
    private let onEditTask: (TodoItem) -> Void

    public init(
        viewModel: TaskListViewModel,
        onAddTask: @escaping () -> Void,
        onEditTask: @escaping (TodoItem) -> Void
    ) {
        self.viewModel = viewModel
        self.onAddTask = onAddTask
        self.onEditTask = onEditTask
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                GradientBackground()

                VStack(spacing: 0) {
                    filterPicker
                    remainingSummary

                    // Nothing until the first load, so launch doesn't flash the empty state.
                    if !viewModel.hasLoaded {
                        Spacer()
                    } else if viewModel.visibleItems.isEmpty {
                        EmptyStateView()
                    } else {
                        taskList
                    }
                }

                FloatingAddButton(accessibilityLabel: Text("Add Task", bundle: .module), action: onAddTask)
                    .accessibilityIdentifier("taskList.add")
                    .padding(.trailing, 40)
                    .padding(.bottom, Spacing.xLarge)
            }
            .navigationTitle(String(localized: "QuickTodo", bundle: .module))
            .task { await viewModel.loadItems() }
            // Tasks can be added from Shortcuts while the app is in the background.
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                Task { await viewModel.loadItems() }
            }
            .alert(
                Text("Delete Task?", bundle: .module),
                isPresented: $viewModel.isConfirmingDeletion,
                presenting: viewModel.itemPendingDeletion
            ) { item in
                Button(String(localized: "Delete", bundle: .module), role: .destructive) {
                    Task { await viewModel.delete(item) }
                }
                Button(String(localized: "Cancel", bundle: .module), role: .cancel) {}
            } message: { item in
                Text("Are you sure you want to delete “\(item.title)”?", bundle: .module)
            }
            .alert(
                Text("Something Went Wrong", bundle: .module),
                isPresented: $viewModel.isShowingError,
                presenting: viewModel.presentedError
            ) { _ in
                Button(String(localized: "OK", bundle: .module), role: .cancel) {}
            } message: { error in
                Text(error.message)
            }
        }
    }
}

// MARK: - Task List View - Extension

private extension TaskListView {
    enum Layout {
        // Keeps the last row clear of the floating add button.
        static let bottomContentInset: CGFloat = 100
        static let rowInsets = EdgeInsets(
            top: Spacing.xSmall,
            leading: Spacing.large,
            bottom: Spacing.xSmall,
            trailing: Spacing.large
        )
    }

    var filterPicker: some View {
        Picker(String(localized: "Filter", bundle: .module), selection: $viewModel.selectedFilter) {
            ForEach(TaskFilter.allCases) { filter in
                Text(filter.title)
                    .tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding([.horizontal, .top])
        .accessibilityIdentifier("taskList.filter")
    }

    @ViewBuilder
    var remainingSummary: some View {
        if !viewModel.items.isEmpty {
            Text("\(viewModel.remainingCount) tasks remaining", bundle: .module)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.xLarge)
                .padding(.top, Spacing.xSmall)
                .accessibilityIdentifier("taskList.remaining")
        }
    }

    var taskList: some View {
        List(viewModel.visibleItems) { item in
            let isOverdue = viewModel.isOverdue(item)

            TaskRowView(
                item: item,
                isOverdue: isOverdue,
                onToggle: { Task { await viewModel.toggleCompletion(of: item) } },
                onEdit: { onEditTask(item) },
                onDelete: { viewModel.requestDeletion(of: item) }
            )
            .padding(.horizontal, Spacing.large)
            .padding(.vertical, Spacing.small)
            .background(cardBackground(for: item, isOverdue: isOverdue))
            .listRowInsets(Layout.rowInsets)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        // The card is drawn by the row itself. Inset grouped rows clip their background
        // to the system corner radius, which cut off the overdue border.
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .contentMargins(.top, Spacing.xSmall, for: .scrollContent)
        .contentMargins(.bottom, Layout.bottomContentInset, for: .scrollContent)
        .animation(.default, value: viewModel.visibleItems)
    }

    func cardBackground(for item: TodoItem, isOverdue: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: CornerRadius.card, style: .continuous)

        return shape
            .fill(Color(.secondarySystemGroupedBackground))
            .overlay {
                if item.isCompleted {
                    shape.fill(.gray.opacity(0.2))
                } else if isOverdue {
                    shape.fill(Color.overdue.opacity(0.1))
                }
            }
            .overlay {
                if isOverdue {
                    shape.strokeBorder(Color.overdue, lineWidth: 1.5)
                }
            }
    }
}

// MARK: - Empty State View

private struct EmptyStateView: View {
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 80

    var body: some View {
        VStack(spacing: Spacing.small) {
            Spacer()

            Image(systemName: "checklist.checked")
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(Color.completed)
                .symbolEffect(.breathe, options: .repeating)
                .padding(.bottom, 28)
                .accessibilityHidden(true)

            Text("No Task Found!", bundle: .module)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("Add a new task to get started.", bundle: .module)
                .font(.body)
                .foregroundStyle(.tertiary)

            Spacer()
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Task List View - Preview

#Preview {
    let store = InMemoryTodoStore(items: [
        TodoItem(title: "Buy groceries", dueDate: .now),
        TodoItem(title: "Pay rent", dueDate: .now.addingTimeInterval(-3 * 86_400)),
        TodoItem(title: "Book dentist", isCompleted: true, dueDate: .now.addingTimeInterval(86_400))
    ])
    TaskListView(viewModel: TaskListViewModel(store: store), onAddTask: {}, onEditTask: { _ in })
}
