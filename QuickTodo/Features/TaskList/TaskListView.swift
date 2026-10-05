//
//  TaskListView.swift
//  QuickTodo
//
//  Created by Udhayanila on 29/01/25.
//

import SwiftUI

// MARK: - Task List View

struct TaskListView: View {
    @Bindable var viewModel: TaskViewModel
    @State private var editorMode: TaskEditorView.Mode?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                GradientBackground()

                VStack(spacing: 0) {
                    filterPicker

                    if viewModel.visibleItems.isEmpty {
                        EmptyStateView()
                    } else {
                        taskList
                    }
                }

                FloatingAddButton { editorMode = .add }
                    .padding(.trailing, 40)
                    .padding(.bottom, 24)
            }
            .navigationTitle("QuickTodo")
            .sheet(item: $editorMode) { mode in
                TaskEditorView(mode: mode) { draft in
                    viewModel.save(draft)
                }
            }
            .alert(
                "Delete Task?",
                isPresented: $viewModel.isConfirmingDeletion,
                presenting: viewModel.itemPendingDeletion
            ) { item in
                Button("Delete", role: .destructive) { viewModel.delete(item) }
                Button("Cancel", role: .cancel) {}
            } message: { item in
                Text("Are you sure you want to delete \"\(item.title)\"?")
            }
            .alert(
                "Something Went Wrong",
                isPresented: $viewModel.isShowingError,
                presenting: viewModel.presentedError
            ) { _ in
                Button("OK", role: .cancel) {}
            } message: { error in
                Text(error.localizedDescription)
            }
        }
    }
}

// MARK: - Task List View - Extension

private extension TaskListView {
    enum Layout {
        static let rowCornerRadius: CGFloat = 16
        static let rowSpacing: CGFloat = 15
        // Keeps the last row clear of the floating add button.
        static let bottomContentInset: CGFloat = 100
    }

    var filterPicker: some View {
        Picker("Filter", selection: $viewModel.selectedFilter) {
            ForEach(TaskFilter.allCases) { filter in
                Text(filter.rawValue)
                    .tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding([.horizontal, .top])
    }

    var taskList: some View {
        List(viewModel.visibleItems) { item in
            TaskRowView(
                item: item,
                onToggle: { viewModel.toggleCompletion(of: item) },
                onEdit: { editorMode = .edit(item) },
                onDelete: { viewModel.requestDeletion(of: item) }
            )
            .listRowBackground(rowBackground(for: item))
        }
        .listStyle(.insetGrouped)
        .listRowSpacing(Layout.rowSpacing)
        .scrollContentBackground(.hidden)
        .contentMargins(.top, 8, for: .scrollContent)
        .contentMargins(.bottom, Layout.bottomContentInset, for: .scrollContent)
        .animation(.default, value: viewModel.visibleItems)
    }

    func rowBackground(for item: TodoItem) -> some View {
        let isOverdue = item.isOverdue()
        let shape = RoundedRectangle(cornerRadius: Layout.rowCornerRadius)

        return shape
            .fill(Color(.secondarySystemGroupedBackground))
            .overlay {
                if item.isCompleted {
                    shape.fill(.gray.opacity(0.2))
                } else if isOverdue {
                    shape.fill(.red.opacity(0.1))
                }
            }
            .overlay {
                shape.stroke(isOverdue ? .red : .clear, lineWidth: 1)
            }
    }
}

// MARK: - Empty State View

private struct EmptyStateView: View {
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 80

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            Image(systemName: "checklist.checked")
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(.green)
                .symbolEffect(.breathe, options: .repeating)
                .padding(.bottom, 28)
                .accessibilityHidden(true)

            Text("No Task Found!")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("Add a new task to get started.")
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
    let store = CoreDataTodoStore(context: CoreDataManager(inMemory: true).viewContext)
    TaskListView(viewModel: TaskViewModel(store: store))
}
