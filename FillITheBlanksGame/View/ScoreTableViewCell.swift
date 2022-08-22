//
//  ScoreTableViewCell.swift
//  FillITheBlanksGame
//
//  Created by MacBook on 8/21/22.
//

import UIKit

class ScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    //@IBOutlet weak var textViewSentance: UITextView!
    @IBOutlet weak var labelUserAnswer: UILabel!
    @IBOutlet weak var labelResult: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //textViewSentance.text = nil
        labelUserAnswer.text = nil
        labelResult.text = nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        labelUserAnswer.font = UIFont.preferredFont(forTextStyle: .body)
        labelUserAnswer.adjustsFontForContentSizeCategory = true
        labelResult.font = UIFont.preferredFont(forTextStyle: .body)
        labelResult.adjustsFontForContentSizeCategory = true
    }
}
