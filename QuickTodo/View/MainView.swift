//
//  MainView.swift
//  QuickTodo
//
//  Created by Udhayanila on 29/01/25.
//

import SwiftUI

// MARK: - Main View

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var taskViewModel = TaskViewModel()
    @State private var selectedFilter: TaskFilter = .all
    @State private var showAddTaskView = false
    @State private var scale1: CGFloat = 0
    @State private var scale2: CGFloat = 0
    @State private var scale3: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    @State private var isEmptyStateAnimating = false
    @State private var showDeleteConfirmation: Bool = false
    @State var taskToEdit: Task? = nil
    @State var taskToDelete: Task? = nil
    
    private let foreverAnimation = Animation.linear.speed(0.2).repeatForever(autoreverses: false)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    filterPicker
                    
                    if taskViewModel.filteredTasks(for: selectedFilter).isEmpty {
                        emptyStateView
                    } else {
                        taskListView
                    }
                }
                
                floatingAddButton
            }
            .navigationTitle("QuickTodo")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddTaskView) {
                AddTaskView(taskViewModel: taskViewModel, taskToEdit: $taskToEdit, dueDate: Date())
            }
            .sheet(isPresented: $showDeleteConfirmation) {
                DeleteConfirmationPopup(isPresented: $showDeleteConfirmation, taskToDelete: $taskToDelete, onDelete: {
                    if let id = taskToDelete?.id {
                        taskViewModel.deleteTask(taskID: id)
                    }
                    taskToDelete = nil // Clear after deletion
                })
            }
            .onAppear {
                taskViewModel.fetchTasks()
            }
        }
    }
}

// MARK: - Main View - Extension

private extension MainView {
    var filterPicker: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(TaskFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .tag(filter)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .padding(.top)
    }
    
    var taskListView: some View {
        List {
            ForEach(taskViewModel.filteredTasks(for: selectedFilter)) { task in
                TaskRowView(showAddTaskView: $showAddTaskView, taskToEdit: $taskToEdit, taskToDelete: $taskToDelete, showDeleteConfirmation: $showDeleteConfirmation, task: taskViewModel.mapToTask(from: task), taskViewModel: taskViewModel)
                    .listRowBackground(rowBackgroundColor(for: taskViewModel.mapToTask(from: task)))
            }
        }
        .listRowSpacing(15)
        .padding(.top, -20)
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
        .padding(.bottom, 16)
    }
    
    var floatingAddButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    showAddTaskView = true
                    taskToEdit = nil
                }) {
                    waveAnimationButton
                }
                .padding()
            }
        }
        .padding(.trailing, 30)
        .padding(.bottom, 15)
    }
    
    @ViewBuilder
    var emptyStateView: some View {
        VStack {
            Spacer()
            ZStack {
                Image(systemName: "checklist.checked")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                    .scaleEffect(scale)
                    .onAppear {
                        startEmptyStateAnimation()
                    }
            }
            .onAppear {
                isEmptyStateAnimating = true
            }
            
            Spacer()
            
            Text("No Task Found!")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .padding(.top, 40)
            
            Text("Add a new task to get started.")
                .font(.body)
                .foregroundColor(.gray.opacity(0.8))
                .padding(.top, 10)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    var waveAnimationButton: some View {
        ZStack {
            createWave(scale: $scale1, delay: 0)
            createWave(scale: $scale2, delay: 0.5)
            createWave(scale: $scale3, delay: 1.0)
            
            Image(systemName: "plus")
                .frame(width: 60, height: 60)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: buttonGradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(30)
        }
    }

    func createWave(scale: Binding<CGFloat>, delay: Double) -> some View {
        Image(systemName: "circle.fill")
            .font(.system(size: 60))
            .foregroundColor(waveColor.opacity(0.3))
            .opacity(1 - scale.wrappedValue)
            .scaleEffect(1 + (scale.wrappedValue * 2))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(foreverAnimation) {
                        scale.wrappedValue = 1
                    }
                }
            }
    }

    // Dynamic Colors for Dark Mode
    private var buttonGradientColors: [Color] {
        colorScheme == .dark
            ? [Color.purple.opacity(0.9), Color.black.opacity(0.8)] // Dark mode colors
            : [Color.blue, Color.purple] // Light mode colors
    }

    private var waveColor: Color {
        colorScheme == .dark ? Color.white : Color.purple
    }
    
    func startEmptyStateAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 0.8)
                .repeatForever(autoreverses: true)
        ) {
            scale = 1.2
        }
    }
    
    func deleteTasks(at offsets: IndexSet) {
        offsets.map { taskViewModel.filteredTasks(for: selectedFilter)[$0] }.forEach { task in
            if let id = task.id {
                taskViewModel.deleteTask(taskID: id)
            }
        }
    }
    
    func rowBackgroundColor(for task: Task) -> some View {
        let hasDueDatePassed = task.dueDate.map { $0 < Date() && !task.isCompleted } ?? false

        return ZStack {
            Color.white
            if task.isCompleted {
                Color.gray.opacity(0.2)
            } else if hasDueDatePassed {
                Color.red.opacity(0.1)
            }
        }
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(hasDueDatePassed ? Color.red : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Main View - Preview

#Preview {
    MainView()
}
