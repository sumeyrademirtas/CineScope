import UIKit

class CircularProgressView: UIView {
    private let progressLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private var circleRadius: CGFloat {
        didSet {
            updateViewSize()
        }
    }

    // ✅ UIView’in default initializer'ı
    override init(frame: CGRect) {
        self.circleRadius = 40
        super.init(frame: .zero)
        setupView()
    }

    // ✅ Custom initializer
    convenience init(radius: CGFloat) {
        self.init(frame: .zero)
        self.circleRadius = radius
        updateViewSize()
    }

    required init?(coder: NSCoder) {
        self.circleRadius = 40
        super.init(coder: coder)
        setupView()
    }

    // **Çemberi oluşturma**
    private func setupView() {
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(progressLayer)
        addSubview(ratingLabel)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ratingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            ratingLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        updateViewSize()
    }

    // ✅ **Radius değiştiğinde boyutu güncelle!**
    private func updateViewSize() {
        let size = circleRadius * 2
        frame.size = CGSize(width: size, height: size)
        bounds = CGRect(x: 0, y: 0, width: size, height: size)

        setNeedsLayout()
        setNeedsDisplay()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawCircularPath()
    }

    // ✅ **Çemberi çizme**
    private func drawCircularPath() {
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: circleRadius,
            startAngle: -CGFloat.pi / 2,
            endAngle: 1.5 * CGFloat.pi,
            clockwise: true
        )

        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.strokeColor = UIColor.darkGray.cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = 5

        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 5
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
    }

    // **Progress ayarla**
    func setProgress(voteAverage: CGFloat) {
        let clampedValue = min(max(voteAverage, 0), 10) // 🔹 0 ile 10 arasında sınırla
        let roundedValue = String(format: "%.1f", clampedValue) // 🔹 7.8 formatında gösterecek
        ratingLabel.text = roundedValue

        let progress = clampedValue / 10 // 🔹 10 üzerinden oran hesapla

        // **Renk değiştirme (Düşük puan kırmızı, yüksek puan yeşil)**
        switch clampedValue {
        case 7...10:
            progressLayer.strokeColor = UIColor.systemGreen.cgColor
        case 5..<7:
            progressLayer.strokeColor = UIColor.systemYellow.cgColor
        default:
            progressLayer.strokeColor = UIColor.systemRed.cgColor
        }

        // **Animasyon ekle**
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = progress
        animation.duration = 1.0
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "progressAnim")
    }

    // ✅ **Auto Layout Kullanımı için intrinsicContentSize ekle**
    override var intrinsicContentSize: CGSize {
        return CGSize(width: circleRadius * 2, height: circleRadius * 2)
    }
}
