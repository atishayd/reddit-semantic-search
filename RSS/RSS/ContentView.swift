//
//  ContentView.swift
//  RSS
//
//  Created by Atishay Dikshit on 8/1/25.
//

import SwiftUI
import Charts

struct ContentView: View {
    @StateObject private var apiService = APIService()
    @State private var searchQuery = ""
    @State private var product: Product?
    @State private var isLoading = false
    @State private var error: APIError?
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            VStack {
                searchBar
                
                if isLoading {
                    loadingView
                } else if let product = product {
                    ProductView(product: product)
                } else {
                    welcomeMessage
                }
            }
            .navigationTitle("Reddit Sentiment")
            .alert("Error", isPresented: $showError, presenting: error) { _ in
                Button("OK") { showError = false }
            } message: { error in
                Text(error.localizedDescription)
            }
        }
    }
    
    private var loadingView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Skeleton for Verdict Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Reddit's Verdict")
                        .font(.title2)
                        .bold()
                        .pulsingAnimation()
                    
                    // Skeleton Recommendation
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 40)
                        .pulsingAnimation()
                    
                    // Skeleton Chart
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .pulsingAnimation()
                }
                .padding()
                
                // Skeleton Comments Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Notable Comments")
                        .font(.title2)
                        .bold()
                        .padding(.top)
                        .pulsingAnimation()
                    
                    // Show 3 skeleton comments
                    ForEach(0..<3) { _ in
                        VStack(alignment: .leading, spacing: 12) {