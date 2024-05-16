
import Foundation
import UIKit

class VideoTableViewCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14.0)
        label.textColor = .white
        label.text = "Dummy"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "Video-Placeholder")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(thumbnailImageView)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            thumbnailImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16.0),
            thumbnailImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 300.0),

            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: 16.0),
            titleLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: -16.0),
            titleLabel.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: -8.0)
        ])
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
}
