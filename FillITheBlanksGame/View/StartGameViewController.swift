//
//  StartGameViewController.swift
//  FillITheBlanksGame
//
//  Created by MacBook on 8/17/22.
//

import UIKit
import Foundation

class StartGameViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {
    
    private var wikiViewModel: WikiViewModel!
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    var wikiTitle = [String]()
    var partsOfSpeechArray = [String]()
    
    var rawParagraphs = [String]()
    var rawSentances = [String]()
    var fillInTheBlankSentances = [NSMutableAttributedString]()
    var fillWithWords = [String]()
    var quizAnswers = [String]()
    var filledWordsByUser = [String]()
    var isQuizAnswerCorrect = [String]()
    var correctQuizAnswer: String?
    var quizScore: Int = 0
    var quizAnswerCount: Int = 1
    var quizIndex: Int = 0
    var pickedQuizIndex: Int?
    
    var tappedTextRange: UITextRange?
    var pickerViewPickedWord: String?
    
    private lazy var textView: UITextView = {
        let view = UITextView()
        view.tag = 55
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.textDragInteraction?.isEnabled = false
        view.adjustsFontForContentSizeCategory = true
        view.isEditable = false
        return view
    }()
    
    private lazy var fontAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.preferredFont(forTextStyle: .body),
        .foregroundColor: UIColor.black,
    ]
    
    private var picker = UIPickerView()
    
    private lazy var buttonSubmit:UIButton = {
        let buttonSubmit = UIButton()
        buttonSubmit.translatesAutoresizingMaskIntoConstraints = false
        buttonSubmit.isEnabled = false
        buttonSubmit.setTitle("Submit Form", for: .normal)
        buttonSubmit.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        buttonSubmit.titleLabel?.adjustsFontForContentSizeCategory = true
        buttonSubmit.tag = 1
        buttonSubmit.setTitleColor(UIColor.black, for: .normal)
        buttonSubmit.backgroundColor = hexStringToUIColor(hex: "#CCCCCC")
        buttonSubmit.addTarget(self, action: #selector(self.submitAnswer), for: .touchUpInside)
        return buttonSubmit
    }()
    
    private lazy var buttonReplayGame:UIButton = {
        let buttonReplayGame = UIButton()
        buttonReplayGame.translatesAutoresizingMaskIntoConstraints = false
        buttonReplayGame.setTitle("Reload Paragraph", for: .normal)
        buttonReplayGame.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        buttonReplayGame.titleLabel?.adjustsFontForContentSizeCategory = true
        buttonReplayGame.setTitleColor(UIColor.black, for: .normal)
        buttonReplayGame.backgroundColor = UIColor.systemGray6
        buttonReplayGame.addTarget(self, action: #selector(self.replayGame), for: .touchUpInside)
        return buttonReplayGame
    }()
    
    private lazy var stackView:UIStackView = {
        let stackView = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = .fillEqually
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 10.0

        stackView.addArrangedSubview(buttonReplayGame)
        stackView.addArrangedSubview(buttonSubmit)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        indicator.center = view.center
        return indicator
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Reachability.isConnectedToNetwork(){
        
            wikiTitle = WikiTitles.sharedWikiTitles.wikiTitles
            partsOfSpeechArray = PartsOfSpeech.sharedPartsOfSpeech.partsOfSpeech
            
            partsOfSpeechArray.shuffle()
            
            getWikiData(searchString: wikiTitle.randomElement()!)
        }else{
            
            let refreshAlert = UIAlertController(title: "Network status", message: "Internet Connection not available!", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                
                self.buttonSubmit.isEnabled = false
                self.buttonSubmit.backgroundColor = hexStringToUIColor(hex: "#CCCCCC")
              }))

            present(refreshAlert, animated: true, completion: nil)
        }
        
        quizScore = 0
        quizAnswerCount = 1
        quizIndex = 0
        
        setupUI()
        setupConstraints()

        NSLayoutConstraint.activate(sharedConstraints)
        layoutTrait(traitCollection: UIScreen.main.traitCollection)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //let searchStringArray: [String] = ["Lion"]
        
        /*fillInTheBlankSentances.append("World's highest population densed city is _____________")
        quizAnswers.append("Tokio")
        filledWordsByUser.append("Mumbai")
        isQuizAnswerCorrect.append("Wrong")*/
        
        if #available(iOS 13.0, *) {
            view.overrideUserInterfaceStyle = .light;
        }
    }
    
    func setNavigationBar() {
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        titleLabel.text = "Fill In The Blank Game"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .white
        titleLabel.sizeToFit()
        
        self.navigationItem.titleView = titleLabel
    }
    
    @objc func replayGame(sender: UIButton) {
        
        self.textView.attributedText = nil
        self.rawParagraphs.removeAll()
        
        self.picker.delegate = nil
        self.picker.dataSource = nil
        
        if self.view.viewWithTag(66) != nil {
            let view = self.view.viewWithTag(66)
            view!.removeFromSuperview()
        }
        
        self.getWikiData(searchString: wikiTitle.randomElement()!)
    }
    
    @objc func submitAnswer(sender: UIButton) {
        
        self.picker.delegate = nil
        self.picker.dataSource = nil
        
        if self.view.viewWithTag(66) != nil {
            let view = self.view.viewWithTag(66)
            view!.removeFromSuperview()
        }
        
        let refreshAlert = UIAlertController(title: "Confirm submit", message: "Are you sure want to submit answer?", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "vcViewScore") as! ViewScoreViewController
            
            //vc.fillInTheBlankSentances = self.fillInTheBlankSentances
            vc.quizAnswers = self.quizAnswers
            vc.filledWordsByUser = self.filledWordsByUser
            vc.isQuizAnswerCorrect = self.isQuizAnswerCorrect
            vc.score = self.quizScore
            
            self.navigationController?.popViewController(animated: false)
            self.navigationController?.pushViewController(vc, animated: true)
          }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
            return
          }))

        present(refreshAlert, animated: true, completion: nil)
    }
    
    func setupUI() {
        
        setNavigationBar()
        view.addSubview(self.textView)
        view.addSubview(self.stackView)
        view.addSubview(self.indicator)
        
        self.textView.text = ""
        self.textView.isUserInteractionEnabled = true
        self.textView.delegate = self
    }
    
    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        sharedConstraints.append(contentsOf: [
            textView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -70),
            textView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            
            buttonSubmit.heightAnchor.constraint(equalToConstant: 50),
            buttonReplayGame.heightAnchor.constraint(equalToConstant: 50),
            
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10),
            stackView.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        regularConstraints.append(contentsOf: [
            
            textView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -70),
            
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
        ])
        
        compactConstraints.append(contentsOf: [
            
            textView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -70),
            
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
        ])
    }
    
    func layoutTrait(traitCollection:UITraitCollection) {
        if (!sharedConstraints[0].isActive) {
           // activating shared constraints
           NSLayoutConstraint.activate(sharedConstraints)
        }
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            if regularConstraints.count > 0 && regularConstraints[0].isActive {
                NSLayoutConstraint.deactivate(regularConstraints)
            }
            // activating compact constraints
            NSLayoutConstraint.activate(compactConstraints)
        } else {
            if compactConstraints.count > 0 && compactConstraints[0].isActive {
                NSLayoutConstraint.deactivate(compactConstraints)
            }
            // activating regular constraints
            NSLayoutConstraint.activate(regularConstraints)
        }
    }
    
    func getWikiData(searchString: String?) {
        
        self.buttonSubmit.isEnabled = false
        self.buttonSubmit.backgroundColor = hexStringToUIColor(hex: "#CCCCCC")
        
        self.indicator.startAnimating()
        
        self.rawParagraphs.removeAll()
        self.rawSentances.removeAll()
        
        let query = "action=query&format=json&prop=extracts&titles=\(searchString!)&exintro=1"
        
        self.wikiViewModel = WikiViewModel()
        wikiViewModel.getData(with: query) { data, response, error in
            
            if error != nil {
                
                let refreshAlert = UIAlertController(title: "Data Error", message: "Aw, Snap! Can't parse data.\nPlease try again.", preferredStyle: UIAlertController.Style.alert)

                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    
                    return
                  }))
                
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.present(refreshAlert, animated: true, completion: nil)
                }
            }
                
            var keyName: String?
            guard let data = data else { return }
            let result = try? JSONDecoder().decode(WikiDTO.self, from: data)
            
            if result != nil {
                
                let keys = result!.query!.pages! as [String: Any]
                
                for (key, _) in keys {
                    keyName = key
                }
                
                let htmlText = result!.query!.pages![keyName!]!.extract! as String
                let rawText = htmlText.decodingUnicodeCharacters.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).trimmingCharacters(in: .whitespacesAndNewlines)

                print("rawText: \(rawText)")
                if rawText.count > 0 {
                    rawText.enumerateLines { (paragraph, _) in
                        
                        self.rawParagraphs.append(paragraph)
                    }
                    
                    
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
                        self.parseData()
                    }
                } else {
                    
                    let refreshAlert = UIAlertController(title: "Data Error", message: "Aw, Snap! Can't download data.\nPlease try after sometime.", preferredStyle: UIAlertController.Style.alert)

                    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        
                        return
                      }))
                    
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
                        self.present(refreshAlert, animated: true, completion: nil)
                    }
                }
            } else {
                
                let refreshAlert = UIAlertController(title: "Data Error", message: "Aw, Snap! Can't parse data.\nPlease try again.", preferredStyle: UIAlertController.Style.alert)

                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    
                    return
                  }))
                
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.present(refreshAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func parseData() {
        
        self.fillInTheBlankSentances.removeAll()
        self.fillWithWords.removeAll()
        self.quizAnswers.removeAll()
        self.filledWordsByUser.removeAll()
        self.isQuizAnswerCorrect.removeAll()
        self.quizIndex = 0
        
        for i in 0..<rawParagraphs.count {
                
            rawParagraphs[i].enumerateSubstrings(in: rawParagraphs[i].startIndex..., options: .bySentences) { (string, range, enclosingRamge, stop) in
                    
                    self.rawSentances.append(string!)
            }
            self.rawSentances.append("\n")
        }
        
        for j in 0..<self.rawSentances.count {
            
            if fillWithWords.count < 10 {
                
                var rawWordsArray = [String]()
                let rawSentance = self.rawSentances[j]
                if rawSentance != "\n" {
                    rawWordsArray = rawSentance.split(usingRegex: #"\s|\((.*?)\)"#).filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).count > 0}
                    
                    createFinalSentance(rawWordsArray: rawWordsArray)
                    
                } else {
                    
                    self.fillInTheBlankSentances.append(NSMutableAttributedString("\n"))
                }
            }
        }
        
        if fillWithWords.count == 10 {
            
            let textViewString = fillInTheBlankSentances.joined(with: " ")
            self.textView.attributedText = textViewString
            
            self.buttonSubmit.isEnabled = true
            self.buttonSubmit.backgroundColor = hexStringToUIColor(hex: "#CCFFCC")
        } else {
            
            let refreshAlert = UIAlertController(title: "Data Error", message: "Aw, Snap! Can't parse data.\nPlease try again.", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                
                return
              }))
            
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.present(refreshAlert, animated: true, completion: nil)
            }
        }
        
        fillWithWords = fillWithWords.unique().sorted()
        
        fillWithWords.insert("Pick One Word", at: 0)
    }
    
    func createFinalSentance(rawWordsArray: [String]) {
        
        var rawWords = rawWordsArray
        //partsOfSpeechArray.shuffle()
        
    outerLop: for i in 0..<partsOfSpeechArray.count {
            
            for j in 0..<rawWords.count {
                
                if rawWords[j] != "" {
                    
                    let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9].*")
                    if regex.firstMatch(in: rawWords[j], range: NSMakeRange(0, rawWords[j].count)) == nil {
                        
                        let isPartOfSpeech = rawWords[j].checkPartsOfSpeech(partOfSpeech: partsOfSpeechArray[i])
                        
                        if (isPartOfSpeech) {
                            
                            let correctWord = rawWords[j]
                        
                            self.fillWithWords.append(correctWord)
                            rawWords[j] = "_______________"
                            let rawString = rawWords.joined(separator: " ")
                            
                            self.filledWordsByUser.append("Nil")
                            self.quizAnswers.append(correctWord)
                            self.isQuizAnswerCorrect.append("Wrong")
                            
                            let attributedString = NSMutableAttributedString(string: rawString, attributes: fontAttributes)
                            let range = attributedString.mutableString.range(of: "_______________")
                            
                            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                            
                            attributedString.addAttribute(NSAttributedString.Key.link, value: "\(correctWord)-\(self.quizIndex)", range: range)
                            
                            self.fillInTheBlankSentances.append(attributedString)
                            self.quizIndex += 1
                            
                            break outerLop
                        }
                    }
                }
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        super.traitCollectionDidChange(previousTraitCollection)

        layoutTrait(traitCollection: traitCollection)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        let url = URL.absoluteString.components(separatedBy: "-")
        correctQuizAnswer = url[0]
        pickedQuizIndex = Int(url[1])!
        
        print("\(pickedQuizIndex!)-\(correctQuizAnswer!)")
        
        let beginning = self.textView.beginningOfDocument
        let rangeStart = self.textView.position(from: beginning, offset: characterRange.location)
        let rangeEnd = self.textView.position(from: rangeStart!, offset: characterRange.length)!
        
        let textRange: UITextRange = self.textView.textRange(from: rangeStart!, to: rangeEnd)!
        
        tappedTextRange = textRange
        
        let tappedWord: String? = self.textView.text(in: textRange)
        
        self.picker.delegate = nil
        self.picker.dataSource = nil
        
        if self.view.viewWithTag(66) != nil {
            let view = self.view.viewWithTag(66)
            view!.removeFromSuperview()
        }
        
        if tappedWord == "_______________" {
            let rect: CGRect = self.textView.firstRect(for: textRange)
            let safeArea = view.safeAreaLayoutGuide
            
            var pickerViewX = 0.0
            var pickerViewY = 0.0
            
            if rect.minX > 50 {
                
                pickerViewX = rect.minX - 50
            } else {
                
                pickerViewX = rect.minX
            }
            
            if (rect.maxY + 150) > safeArea.layoutFrame.height {
                
                pickerViewY = rect.minY - 150
            } else {
                
                pickerViewY = rect.maxY
            }
            
            self.picker = UIPickerView(frame: CGRect(x: pickerViewX, y: pickerViewY, width: 200, height: 150))
            self.picker.tag = 66
            self.picker.backgroundColor = UIColor.white
            self.picker.delegate = self
            self.picker.dataSource = self
            
            self.textView.addSubview(picker)
        }
        
        return false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return fillWithWords.count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
            pickerLabel?.adjustsFontForContentSizeCategory = true
            pickerLabel?.textColor = UIColor.black
            pickerLabel?.textAlignment = .center
        }
        
        pickerLabel?.text = fillWithWords[row]

        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        if fillWithWords[row] != "Pick One Word" {
            
            pickerViewPickedWord = fillWithWords[row]
            
            let refreshAlert = UIAlertController(title: "Confirm your answer", message: "Are you confirm?", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                
                let tappedWord: String? = self.textView.text(in: self.tappedTextRange!)
                if tappedWord == "_______________" {
                
                    self.textView.replace(self.tappedTextRange!, withText: self.pickerViewPickedWord!)
                    self.quizAnswerCount += 1
                    if self.pickerViewPickedWord == self.correctQuizAnswer {
                    
                        self.quizScore += 1
                        self.isQuizAnswerCorrect[self.pickedQuizIndex!] = "Correct"
                    } else {
                        
                        self.isQuizAnswerCorrect[self.pickedQuizIndex!] = "Wrong"
                    }
                    self.filledWordsByUser[self.pickedQuizIndex!] = self.pickerViewPickedWord!
                }
                if self.view.viewWithTag(66) != nil {
                    let view = self.view.viewWithTag(66)
                    view!.removeFromSuperview()
                }
                
                self.picker.delegate = nil
                self.picker.dataSource = nil
              }))

            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                
                return
              }))

            present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return 40
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension Sequence {
    func joined(with separator: NSAttributedString) -> NSAttributedString {
        return self.reduce(NSMutableAttributedString()) {
            (r, e) in
            if r.length > 0 {
                r.append(separator)
            }
            r.append(e as! NSAttributedString)
            return r
        }
    }

    func joined(with separator: String = "") -> NSAttributedString {
        return self.joined(with: NSAttributedString(string: separator))
    }
}

extension String {
    var decodingUnicodeCharacters: String { applyingTransform(.init("Hex-Any"), reverse: false) ?? "" }
    
    func checkPartsOfSpeech(partOfSpeech: String) -> Bool {
        
        var isFound: Bool = false
        
        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        let schemes = NSLinguisticTagger.availableTagSchemes(forLanguage: "en-in")
        let range = NSRange(location: 0, length: self.count)
        let tagger = NSLinguisticTagger(tagSchemes: schemes, options: Int(options.rawValue))
        tagger.string = self
        tagger.enumerateTags(in: range, scheme: .nameTypeOrLexicalClass, options: options) { (tag, tokenRange, _, _) in
            if let tag = tag {
                
                print("Word: \(self) -> tag.rawValue: \(tag.rawValue)")
                if tag.rawValue == partOfSpeech {
                    
                    isFound = true
                    return
                }
            }
        }
        
        return isFound
    }
    
    func split(usingRegex pattern: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: pattern, options: .allowCommentsAndWhitespace)
        let matches = regex.matches(in: self, range: NSRange(startIndex..., in: self))
        
        let splits = [startIndex]
            + matches
                .map { Range($0.range, in: self)! }
                .flatMap { [ $0.lowerBound, $0.upperBound ] }
            + [endIndex]

        return zip(splits, splits.dropFirst())
            .map {
                String(self[$0 ..< $1])
            }
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
