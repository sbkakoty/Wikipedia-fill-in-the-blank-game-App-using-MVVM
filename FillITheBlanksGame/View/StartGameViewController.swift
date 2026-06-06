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
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.isEditable = false
        return view
    }()
    
    private var picker = UIPickerView()
    
    private lazy var buttonSubmit:UIButton = {
        let view = UIButton().shadow()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEnabled = false
        view.setTitle("Submit", for: .normal)
        view.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body).bold()
        view.titleLabel?.adjustsFontForContentSizeCategory = true
        view.setTitleColor(hexStringToUIColor(hex: "#999999"), for: .normal)
        view.backgroundColor = UIColor.systemGray6
        view.addTarget(self, action: #selector(self.submitAnswer), for: .touchUpInside)
        return view
    }()
    
    private lazy var buttonReplayGame:UIButton = {
        let view = UIButton().shadow()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Reload Data", for: .normal)
        view.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body).bold()
        view.titleLabel?.adjustsFontForContentSizeCategory = true
        view.setTitleColor(UIColor.white, for: .normal)
        view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.addTarget(self, action: #selector(self.replayGame), for: .touchUpInside)
        return view
    }()
    
    private lazy var stackView:UIStackView = {
        let stackView = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = .fillEqually
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 15.0

        stackView.addArrangedSubview(buttonReplayGame)
        stackView.addArrangedSubview(buttonSubmit)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
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
                self.buttonSubmit.backgroundColor = hexStringToUIColor(hex: "#DDDDDD")
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
        
        //handle dark mode
        if #available(iOS 13.0, *) {
            view.overrideUserInterfaceStyle = .light;
        }
    }
    
    func setNavigationBar() {
        
        let titleLabel = UILabel()
        titleLabel.text = "Fill In The Blank Game"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2).bold()
        //titleLabel.adjustsFontForContentSizeCategory = false
        titleLabel.minimumScaleFactor = 1
        titleLabel.textColor = .white
        titleLabel.sizeToFit()
        titleLabel.shadowColor = UIColor.gray
        titleLabel.shadowOffset = CGSize(width: 1, height: 1)
        titleLabel.shadowColor = UIColor.gray
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
        let adjustedHeight = (buttonSubmit.titleLabel?.rectForText().height)! * AppConstants.sharedHeightMultiplier.uiControlHeightMultiplier
        
        sharedConstraints.append(contentsOf: [
            textView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            textView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -(adjustedHeight)),
            textView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            
            buttonSubmit.heightAnchor.constraint(equalTo: stackView.heightAnchor),
            buttonReplayGame.heightAnchor.constraint(equalTo: stackView.heightAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),
            stackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -15),
            stackView.heightAnchor.constraint(equalToConstant: adjustedHeight),
            
            self.indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        regularConstraints.append(contentsOf: [
            
            textView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            textView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -(adjustedHeight)),
            
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),
            
            self.indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        compactConstraints.append(contentsOf: [
            
            textView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            textView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -(adjustedHeight)),
            
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),
            
            self.indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func layoutTrait(traitCollection:UITraitCollection) {
        if (!sharedConstraints[0].isActive) {
           NSLayoutConstraint.activate(sharedConstraints)
        }
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            if regularConstraints.count > 0 && regularConstraints[0].isActive {
                NSLayoutConstraint.deactivate(regularConstraints)
            }
            NSLayoutConstraint.activate(compactConstraints)
        } else {
            if compactConstraints.count > 0 && compactConstraints[0].isActive {
                NSLayoutConstraint.deactivate(compactConstraints)
            }
            NSLayoutConstraint.activate(regularConstraints)
        }
    }
    
    func getWikiData(searchString: String?) {
        
        self.buttonSubmit.isEnabled = false
        self.buttonSubmit.backgroundColor = UIColor.systemGray6
        self.buttonSubmit.setTitleColor(hexStringToUIColor(hex: "#999999"), for: .normal)
        
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
                
            guard let data = data else { return }
                
            var decoded: [AnyHashable: Any]?
            
            do {
                decoded = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any]
            } catch {
                let refreshAlert = UIAlertController(title: "Data Error", message: "Aw, Snap! Can't parse data.\nPlease try after sometime.", preferredStyle: UIAlertController.Style.alert)

                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    
                    return
                  }))
                
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.present(refreshAlert, animated: true, completion: nil)
                }
            }
            let parseJSON = ParseJSON()
            
            let htmlText = parseJSON.parse(decoded!)
            
            let rawText = htmlText?.decodingUnicodeCharacters.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).trimmingCharacters(in: .whitespacesAndNewlines)

            if rawText!.count > 0 {
                rawText?.enumerateLines { (paragraph, _) in
                    
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
            self.buttonSubmit.backgroundColor = hexStringToUIColor(hex: "#0099DD")
            self.buttonSubmit.setTitleColor(UIColor.white, for: .normal)
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
        fillWithWords.shuffle()
        fillWithWords.insert("Pick One Word", at: 0)
    }
    
    func createFinalSentance(rawWordsArray: [String]) {
        
        var rawWords = rawWordsArray
        
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
                            
                            let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
                            paragraphStyle.alignment = NSTextAlignment.justified
                            let attributedString = NSMutableAttributedString(string: rawString, attributes: [
                                .font: UIFont.preferredFont(forTextStyle: .body),
                                .foregroundColor: UIColor.black,
                                .paragraphStyle: paragraphStyle]
                            )
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
        
        //print(correctQuizAnswer!)
        
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
            pickerLabel?.font = UIFont.preferredFont(forTextStyle: .body)
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
