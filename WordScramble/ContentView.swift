//
//  ContentView.swift
//  WordScramble
//
//  Created by Toine Riedo on 23.06.2024.
//

import SwiftUI

struct ContentView: View {
	@State private var usedWords = [String]()
	@State private var scoreWord = 0
	@State private var lastScore = [Int]()
	@State private var rootWord = ""
	@State private var newWord = ""
	
	@State private var errorTitle = ""
	@State private var errorMessage = ""
	@State private var showingError = false
	
	var body: some View {
		NavigationStack{
			ZStack{
				LinearGradient(colors: [Color.blue, Color.yellow], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
				
				List{
					Section {
						ZStack {
							RoundedRectangle(cornerRadius: 8, style: .continuous)
								.fill(Color.yellow.opacity(0.95))
							TextField("Enter your word", text: $newWord, prompt: Text("Placeholder").foregroundColor(Color.accentColor))
										.textInputAutocapitalization(.never)
										.autocorrectionDisabled()
										.padding(8)
									
								}
						}
						.listRowBackground(Color.clear) // Optional, if you want to clear the background color of the section
						
						.listRowBackground(Color.clear) // Row background color
						Section {
							ForEach(usedWords, id: \.self) { word in
								HStack(alignment: .center) {
									Image(systemName: "\(word.count).circle")
									Text(word)
										.padding(.leading, 8)
									
									Spacer()
									if let index = usedWords.firstIndex(of: word), index < lastScore.count {
										Text("+ \(lastScore[index])")
											.padding(.trailing, 8)
									}
								}
								.padding(.vertical, 12)
							}
						}
						.listRowSeparator(.hidden)
						.listRowInsets(EdgeInsets())
						.listRowBackground(Color.yellow.opacity(0.65))
						.padding()
						
						
						
						
						Section{
							Text("Score: \(scoreWord)")
								.font(.largeTitle.bold())
						}
						.listRowBackground(Color.clear)
					}
				}
				.navigationBarTitleDisplayMode(.inline)
				.toolbar{
					ToolbarItem(placement: .principal) {
						Text(rootWord)
							.font(.title.bold())
					}
					ToolbarItem( placement: .bottomBar){
						
						Button("New word", action: startGame)
							.padding(.all, 10.0)
							.font(.title.bold())
							.foregroundColor(.yellow)
							.background(.black)
							.clipShape(Capsule())
					}
				}
				.onSubmit(addNewWord)
				.onAppear(perform: startGame)
				
				
				.alert(errorTitle, isPresented: $showingError ){} message:{
					Text(errorMessage)
				}
			}
			.scrollContentBackground(.hidden)
		}
		
		func addNewWord(){
			let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
			guard answer.count > 0 else {return}
			
			guard isOriginal(word: answer) else {
				wordError(title: "Word used already", message: "Be more original")
				return
			}
			
			guard isPossible(word: answer) else {
				wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
				return
			}
			
			guard isReal(word: answer) else {
				wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
				return
			}
			
			guard isStart(word: answer) else{
				wordError(title: "First letter of the word", message: "You can't just take the first letters...")
				return
			}
			withAnimation{
				usedWords.insert(answer, at:0)
				
			}
			
			var points = 0
			if answer.count <= 3 {
				points = 1
			} else if answer.count <= 5 {
				points = 3
			} else {
				points = 5
			}
			
			scoreWord += points
			withAnimation{
				lastScore.insert(points, at: 0)
			}
			newWord = ""
		}
		
		
		func startGame(){
			scoreWord = 0
			lastScore = []
			usedWords = []
			if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
				if let startWords = try? String(contentsOf: startWordsURL){
					let allWords = startWords.components(separatedBy: "\n")
					rootWord = allWords.randomElement() ?? "Silkworm"
					
					return
				}
			}
		}
		
		func isOriginal(word: String) -> Bool{
			!usedWords.contains(word)
		}
		func isPossible(word: String) -> Bool {
			var tempWord = rootWord
			
			for letter in word {
				if let pos = tempWord.firstIndex(of: letter) {
					tempWord.remove(at: pos)
				} else {
					return false
				}
			}
			
			return true
		}
		
		func isReal(word: String) -> Bool{
			let checker = UITextChecker()
			let range  = NSRange(location: 0, length: word.utf16.count)
			let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language:"en")
			
			return misspelledRange.location == NSNotFound
		}
		
		func isStart(word: String) -> Bool{
			let prefixLength = 3
			
			guard rootWord.count >= prefixLength, word.count >= prefixLength else {
				return true
			}
			
			let rootWordPrefix = rootWord.prefix(prefixLength)
			let wordPrefix = word.prefix(prefixLength)
			print(rootWordPrefix == wordPrefix)
			
			return rootWordPrefix != wordPrefix
			
		}
		
		func wordError(title: String, message: String){
			errorTitle = title
			errorMessage = message
			showingError = true
		}
	}
	
	#Preview {
		ContentView()
	}
