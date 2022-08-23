//
//  ViewScoreViewController.swift
//  FillITheBlanksGame
//
//  Created by MacBook on 8/21/22.
//

import UIKit

class ViewScoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    var quizAnswers: [String]?
    var filledWordsByUser: [String]?
    var isQuizAnswerCorrect: [String]?
    var score:Int?
    
    private lazy var scoreTableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var scoreLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = hexStringToUIColor(hex: "#33DDFF")
        view.textColor = UIColor.white
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body).bold()
        //view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if #available(iOS 13.0, *) {
            view.overrideUserInterfaceStyle = .light;
        }
        
        setupUI()
        setupConstraints()

        NSLayoutConstraint.activate(sharedConstraints)
        layoutTrait(traitCollection: UIScreen.main.traitCollection)
    }
    
    func setNavigationBar() {
        
        let button = UIButton.init(type: .custom)
        button.setTitle("Replay", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        button.frame = CGRect.init(x: 0, y: 0, width: 20, height: 20)
        button.addTarget(self, action:#selector(back), for:.touchUpInside)
        let doneItem = UIBarButtonItem.init(customView: button)
        self.navigationItem.leftBarButtonItem = doneItem
        
        let titleLabel = UILabel().shadow()
        titleLabel.text = "View Score"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2).bold()
        //titleLabel.adjustsFontForContentSizeCategory = false
        titleLabel.minimumScaleFactor = 1
        titleLabel.textColor = .white
        self.navigationItem.titleView = titleLabel
    }
    
    func setupUI() {
        
        setNavigationBar()
        
        self.scoreTableView.register(UINib(nibName: "ScoreTableViewCell", bundle: nil), forCellReuseIdentifier: "cellViewScore")
        self.scoreTableView.rowHeight = UITableView.automaticDimension;
        self.scoreTableView.separatorStyle = .none
        self.scoreTableView.isAccessibilityElement = false
        
        self.view.addSubview(scoreTableView)
        self.scoreTableView.delegate = self
        self.scoreTableView.dataSource = self
        self.scoreTableView.reloadData()
        
        self.view.addSubview(scoreLabel)
        self.scoreLabel.text = "Thank You! You have secured \(score!) out of 10."
    }
    
    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let adjustedHeight = scoreLabel.rectForText().height * AppConstants.sharedHeightMultiplier.uiControlHeightMultiplier
        
        sharedConstraints.append(contentsOf: [
            scoreTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            scoreTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            scoreTableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -adjustedHeight),
            scoreTableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            
            scoreLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            scoreLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),
            scoreLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            scoreLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -15),
            scoreLabel.heightAnchor.constraint(equalToConstant: adjustedHeight),
        ])
        
        regularConstraints.append(contentsOf: [
            
            scoreTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            scoreTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            scoreTableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -adjustedHeight),
            scoreTableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            
            scoreLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            scoreLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),
            scoreLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -15),
        ])
        
        compactConstraints.append(contentsOf: [
            
            scoreTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            scoreTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            scoreTableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -adjustedHeight),
            scoreTableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            
            scoreLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            scoreLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),
            scoreLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -15),
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
    
    @objc func back() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return quizAnswers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellViewScore") as! ScoreTableViewCell
        
        cell.labelUserAnswer?.text = "Answer \((indexPath.row + 1)). \(filledWordsByUser![indexPath.row])"
        
        if isQuizAnswerCorrect![indexPath.row] == "Wrong" {
            cell.labelResult?.text = "\(isQuizAnswerCorrect![indexPath.row]), Correct Answer: \(quizAnswers![indexPath.row])"
        } else {
            cell.labelResult?.text = "\(isQuizAnswerCorrect![indexPath.row])"
        }
        
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
