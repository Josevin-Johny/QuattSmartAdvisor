//
//  SmartAdvisorView.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

// Presentation/Views/SmartAdvisorView.swift
import SwiftUI
import Charts

@available(iOS 16.0, *)

struct SmartAdvisorView: View {
  @StateObject private var viewModel = SmartAdvisorViewModel()
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
      ZStack {
          Color.black.ignoresSafeArea()
          
          VStack(spacing: 0) {  // CRITICAL: spacing: 0
              // Status bar spacer (manual safe area)
              Color.clear
                  .frame(height: UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44)
              
              // Fixed Header - NO extra padding
              headerView
              
              // Chart Section - IMMEDIATELY after header
              if !viewModel.historicalData.isEmpty {
                  chartSection
                      .padding(.horizontal, 16)
              } else if viewModel.isLoading {
                  loadingChartPlaceholder
                      .padding(.horizontal, 16)
              }
              
              // Scrollable Content
              ScrollView {
                  VStack(spacing: 12) {
                      if let insight = viewModel.currentInsight {
                          summaryCard(insight)
                      }
                      
                      conversationSection
                  }
                  .padding()
              }
              
              // Fixed Voice Button
              voiceInputSection
          }
          .edgesIgnoringSafeArea(.top)  // Ignore default safe area
      }
      .onAppear {
          viewModel.loadInitialData()
      }
  }
  
  // MARK: - Header
  private var headerView: some View {
    HStack {
      Button(action: { dismiss() }) {
        Image(systemName: "xmark.circle.fill")
          .font(.title2)
          .foregroundColor(.white.opacity(0.7))
      }
      Spacer(minLength: 10)
      Text("Smart Advisor")
        .font(.headline)
        .foregroundColor(.white)
      Spacer()
    }
    .padding(.horizontal)
    .padding(.vertical, 12)  
    .background(Color.black)
  }
  // MARK: - Chart Section
  private var chartSection: some View {
    VStack(spacing: 8) {  // Reduced from 12 to 8
      // Chart Title with Picker
      HStack {
        Image(systemName: viewModel.selectedChartMetric.icon)
          .foregroundColor(.cyan)
          .font(.caption)  // Made smaller
        
        Text("\(viewModel.selectedChartMetric.rawValue) (Last 10 Days)")
          .font(.caption)  // Made smaller
          .fontWeight(.medium)
          .foregroundColor(.white)
        
        Spacer()
        
        Picker("Metric", selection: $viewModel.selectedChartMetric) {
          ForEach(ChartMetric.allCases, id: \.self) { metric in
            Text(metric.rawValue).tag(metric)
          }
        }
        .pickerStyle(.menu)
        .tint(.cyan)
      }
      
      // Bar Chart
      barChartView
        .frame(height: 120)  // Reduced from 140 to 120
      
      // Legend
      chartLegend
    }
    .padding(12)  // Reduced from default padding
    .background(Color.white.opacity(0.08))
    .cornerRadius(12)  // Slightly smaller radius
  }
  
  private var barChartView: some View {
    Chart {
      ForEach(viewModel.historicalData.suffix(10)) { data in
        barChartContent(for: data)
      }
    }
    .chartXAxis {
      AxisMarks(values: .automatic) { value in
        if let date = value.as(Date.self) {
          AxisValueLabel {
            VStack(spacing: 2) {
              Text(date, format: .dateTime.day())
                .font(.caption2)
              Text(date, format: .dateTime.month(.abbreviated))
                .font(.caption2)
            }
            .foregroundStyle(.white.opacity(0.7))
          }
        }
        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
          .foregroundStyle(.white.opacity(0.2))
      }
    }
    .chartYAxis {
      AxisMarks(position: .leading) { value in
        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
          .foregroundStyle(.white.opacity(0.2))
        
        AxisValueLabel {
          if let doubleValue = value.as(Double.self) {
            Text(formatYAxisValue(doubleValue))
              .font(.caption2)
              .foregroundStyle(.white.opacity(0.7))
          }
        }
      }
    }
  }
  
  @ChartContentBuilder
  private func barChartContent(for data: HeatingData) -> some ChartContent {
    switch viewModel.selectedChartMetric {
    case .cop:
      BarMark(
        x: .value("Date", data.date),
        y: .value("COP", data.cop)
      )
      .foregroundStyle(copColor(data.cop))
      .annotation(position: .top, alignment: .center) {
        if data.cop >= 3.0 || data.cop <= 2.0 {
          Text(String(format: "%.1f", data.cop))
            .font(.caption2)
            .foregroundColor(.white.opacity(0.6))
        }
      }
      
    case .energy:
      // Heat Pump (Cyan)
      BarMark(
        x: .value("Date", data.date),
        y: .value("Heat Pump", data.heatDelivered),
        stacking: .standard
      )
      .foregroundStyle(.cyan)
      
      // Gas Boiler (Orange)
      BarMark(
        x: .value("Date", data.date),
        y: .value("Gas Boiler", data.gasBoilerUsed),
        stacking: .standard
      )
      .foregroundStyle(.orange)
      
    case .temperature:
      // Room Temperature (Red)
      BarMark(
        x: .value("Date", data.date),
        y: .value("Room", data.roomTemp)
      )
      .foregroundStyle(.red.opacity(0.7))
      
      // Outside Temperature (Blue) - as overlay
      BarMark(
        x: .value("Date", data.date),
        y: .value("Outside", data.outsideTemp)
      )
      .foregroundStyle(.blue.opacity(0.5))
    }
  }
  
  // MARK: - Chart Legend
  private var chartLegend: some View {
    HStack(spacing: 16) {
      switch viewModel.selectedChartMetric {
      case .cop:
        LegendItem(color: .green, label: "Good (≥3.0)")
        LegendItem(color: .yellow, label: "Average (2.5-3.0)")
        LegendItem(color: .red, label: "Poor (<2.5)")
        
      case .energy:
        LegendItem(color: .cyan, label: "Heat Pump (kWh)")
        LegendItem(color: .orange, label: "Gas Boiler (kWh)")
        
      case .temperature:
        LegendItem(color: .red, label: "Room Temp (°C)")
        LegendItem(color: .blue, label: "Outside Temp (°C)")
      }
    }
    .font(.caption2)
  }
  
  // MARK: - Helper Methods
  private func copColor(_ cop: Double) -> Color {
    if cop >= 3.0 {
      return .green
    } else if cop >= 2.5 {
      return .yellow
    } else {
      return .red
    }
  }
  
  private func formatYAxisValue(_ value: Double) -> String {
    switch viewModel.selectedChartMetric {
    case .cop:
      return String(format: "%.1f", value)
    case .energy:
      return String(format: "%.0f", value)
    case .temperature:
      return String(format: "%.0f°", value)
    }
  }
  
  // MARK: - Loading Placeholder
  private var loadingChartPlaceholder: some View {
    VStack(spacing: 8) {
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
      Text("Loading chart...")
        .font(.caption)
        .foregroundColor(.gray)
    }
    .frame(height: 160)  // Reduced from 200
    .frame(maxWidth: .infinity)
    .background(Color.white.opacity(0.05))
    .cornerRadius(12)
  }
  
  // MARK: - Summary Card
  private func summaryCard(_ insight: HeatingInsight) -> some View {
    HStack(spacing: 12) {
      // Emoji + Rating
      VStack(spacing: 2) {  // Reduced from 4
        Text(insight.efficiencyRating.emoji)
          .font(.system(size: 28))  // Reduced from 32
        
        Text(insight.efficiencyRating.rawValue)
          .font(.caption2)  // Made smaller
          .fontWeight(.semibold)
          .foregroundColor(.white)
      }
      
      Divider()
        .background(Color.white.opacity(0.2))
        .frame(height: 40)  // Reduced from 50
      
      // COP Info
      VStack(alignment: .leading, spacing: 2) {  // Reduced from 4
        Text("Avg COP")
          .font(.caption2)
          .foregroundColor(.gray)
        
        Text(String(format: "%.2f", insight.averageCOP))
          .font(.title3)
          .fontWeight(.bold)
          .foregroundColor(.white)
      }
      
      Spacer()
      
      // Savings
      VStack(alignment: .trailing, spacing: 2) {  // Reduced from 4
        Text("Potential")
          .font(.caption2)
          .foregroundColor(.gray)
        
        Text("€\(String(format: "%.0f", insight.potentialSavings))")
          .font(.title3)
          .fontWeight(.bold)
          .foregroundColor(.green)
        
        Text("per week")
          .font(.caption2)
          .foregroundColor(.gray)
      }
    }
    .padding(12)  // Reduced from default
    .background(Color.white.opacity(0.08))
    .cornerRadius(12)
  }
  
  // MARK: - Conversation Section
  private var conversationSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Ask Me Anything")
        .font(.headline)
        .foregroundColor(.white)
      
      if viewModel.recognizedText.isEmpty && viewModel.aiResponse == nil {
        quickQuestions
      } else {
        conversationBubbles
      }
    }
  }
  
  private var quickQuestions: some View {
    VStack(spacing: 12) {
      QuickQuestionButton(
        question: "How efficient is my heating?",
        icon: "gauge.high"
      ) {
        viewModel.processTextCommand("How efficient is my heating?")
      }
      
      QuickQuestionButton(
        question: "What will it cost next week?",
        icon: "dollarsign.circle"
      ) {
        viewModel.processTextCommand("What will it cost next week?")
      }
      
      QuickQuestionButton(
        question: "Should I adjust my settings?",
        icon: "slider.horizontal.3"
      ) {
        viewModel.processTextCommand("Should I adjust my settings?")
      }
    }
  }
  
  private var conversationBubbles: some View {
    VStack(spacing: 12) {
      if !viewModel.recognizedText.isEmpty {
        QuestionBubble(text: viewModel.recognizedText)
      }
      
      if viewModel.isLoading {
        HStack {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
          Text("Analyzing...")
            .foregroundColor(.gray)
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
      }
      
      if let response = viewModel.aiResponse {
        AnswerBubble(text: response)
      }
    }
  }
  
  // MARK: - Voice Input
  private var voiceInputSection: some View {
    VStack(spacing: 6) {  // Reduced from 8
      if let error = viewModel.errorMessage {
        Text(error)
          .font(.caption2)  // Made smaller
          .foregroundColor(.red)
          .padding(.horizontal)
      }
      
      Button(action: {
        if viewModel.isListening {
          viewModel.stopVoiceInput()
        } else {
          viewModel.startVoiceInput()
        }
      }) {
        HStack(spacing: 12) {
          ZStack {
            Circle()
              .fill(viewModel.isListening ? Color.red : Color.cyan)
              .frame(width: 44, height: 44)  // Reduced from 50
              .scaleEffect(viewModel.isListening ? 1.1 : 1.0)
              .animation(
                viewModel.isListening ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default,
                value: viewModel.isListening
              )
            
            Image(systemName: viewModel.isListening ? "stop.fill" : "mic.fill")
              .foregroundColor(.white)
              .font(.body)  // Slightly smaller
          }
          
          Text(viewModel.isListening ? "Stop Recording" : "Tap to Ask")
            .foregroundColor(.white)
            .font(.subheadline)  // Made smaller
          
          Spacer()
        }
        .padding(.vertical, 12)  // Reduced vertical padding
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
      }
      .padding(.horizontal)
    }
    .padding(.vertical, 8)  // Reduced from 12
    .background(Color.black)
  }
}

// MARK: - Legend Item
struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Quick Question Button
struct QuickQuestionButton: View {
    let question: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.cyan)
                    .frame(width: 24)
                
                Text(question)
                    .foregroundColor(.white)
                    .font(.subheadline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
        }
    }
}

// MARK: - Question Bubble
struct QuestionBubble: View {
    let text: String
    
    var body: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 8) {
                Text(text)
                    .foregroundColor(.black)
                    .font(.subheadline)
                
                Image(systemName: "person.fill")
                    .foregroundColor(.black.opacity(0.7))
                    .font(.caption)
            }
            .padding(12)
            .background(Color.cyan)
            .cornerRadius(12)
            .frame(maxWidth: 280, alignment: .trailing)
        }
    }
}

// MARK: - Answer Bubble
struct AnswerBubble: View {
    let text: String
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.cyan)
                    .font(.caption)
                
                Text(text)
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
            .padding(12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .frame(maxWidth: 280, alignment: .leading)
            
            Spacer()
        }
    }
}
