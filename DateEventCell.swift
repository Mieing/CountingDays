import UIKit

class DateEventCell: UITableViewCell {
    static let reuseIdentifier = "DateEventCell"
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.1
        view.layer.masksToBounds = false
        return view
    }()
    
    private let blurEffect: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.alpha = 0.7
        return view
    }()
    
    private let selectionIndicator: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        imageView.alpha = 0
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .left
        return label
    }()
    
    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.alpha = 0
        return label
    }()
    
    private var currentEvent: DateEvent?
    private var isShowingDetails = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(blurEffect)
        containerView.addSubview(selectionIndicator)
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(daysLabel)
        containerView.addSubview(detailsLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            blurEffect.topAnchor.constraint(equalTo: containerView.topAnchor),
            blurEffect.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            blurEffect.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            blurEffect.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            selectionIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            selectionIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            selectionIndicator.widthAnchor.constraint(equalToConstant: 24),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: selectionIndicator.trailingAnchor, constant: 8),
            titleLabel.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor, multiplier: 0.5),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            daysLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            daysLabel.leadingAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 20),
            daysLabel.widthAnchor.constraint(equalToConstant: 120),
            
            detailsLabel.topAnchor.constraint(equalTo: daysLabel.bottomAnchor, constant: 4),
            detailsLabel.leadingAnchor.constraint(equalTo: daysLabel.leadingAnchor),
            detailsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            detailsLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16),
            detailsLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 150)
        ])
    }
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    @objc private func handleTap() {
        guard let event = currentEvent else { return }
        isShowingDetails.toggle()
        
        if isShowingDetails {
            let info = event.detailedDateInfo
            var detailText = ""
            
            // 构建时间详情字符串
            if info.year > 0 { detailText += "\(info.year)年" }
            if info.month > 0 { detailText += "\(info.month)月" }
            if info.day > 0 { detailText += "\(info.day)天" }
            if info.hour > 0 { detailText += "\(info.hour)小时" }
            
            // 如果没有任何时间信息，至少显示天数
            if detailText.isEmpty {
                detailText = "0天"
            }
            
            detailsLabel.text = detailText + "\n总计: \(info.totalDays)天"
        }
        
        UIView.animate(withDuration: 0.3) {
            self.detailsLabel.alpha = self.isShowingDetails ? 1 : 0
        }
        
        // 添加触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func configure(with event: DateEvent) {
        currentEvent = event
        titleLabel.text = event.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月d日"
        dateFormatter.locale = Locale(identifier: "zh_CN")
        dateLabel.text = dateFormatter.string(from: event.date)
        
        let baseColor = UIColor(hex: event.color)
        containerView.backgroundColor = baseColor.withAlphaComponent(0.15)
        
        switch event.type {
        case .countdown:
            let days = event.daysRemaining
            if days == 0 {
                daysLabel.text = "今天"
                daysLabel.textColor = .systemOrange
            } else {
                daysLabel.text = "\(abs(days))天"
                daysLabel.textColor = days >= 0 ? .systemGreen : .systemRed
            }
        case .countup:
            let days = event.daysElapsed
            if days == 0 {
                daysLabel.text = "今天"
                daysLabel.textColor = .systemOrange
            } else {
                daysLabel.text = "\(days)天"
                daysLabel.textColor = .systemBlue
            }
        }
        
        // Reset details view state
        isShowingDetails = false
        detailsLabel.alpha = 0
    }
    
    func setSelected(_ selected: Bool) {
        selectionIndicator.image = UIImage(systemName: selected ? "checkmark.circle.fill" : "circle")
        
        UIView.animate(withDuration: 0.2) {
            self.selectionIndicator.alpha = selected ? 1 : 0.3
            self.containerView.transform = selected ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.containerView.layer.shadowOpacity = selected ? 0.2 : 0.1
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            containerView.layer.shadowColor = UIColor.black.cgColor
            updateBlurEffect()
        }
    }
    
    private func updateBlurEffect() {
        let newStyle: UIBlurEffect.Style = traitCollection.userInterfaceStyle == .dark ? .systemThinMaterial : .systemUltraThinMaterial
        blurEffect.effect = UIBlurEffect(style: newStyle)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurEffect.layer.cornerRadius = containerView.layer.cornerRadius
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
} 