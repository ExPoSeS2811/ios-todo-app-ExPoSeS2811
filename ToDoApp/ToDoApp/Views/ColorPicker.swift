import UIKit

protocol ColorPickerDelegate: AnyObject {
    func colorPicker(_ view: ColorPicker, didSelect color: UIColor)
}

class ColorPicker: UIView {
    var viewLayer: CAGradientLayer = .init()
    weak var delegate: ColorPickerDelegate?

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupGradientLayer()
    }

    private func setupGradientLayer() {
        guard viewLayer.superlayer == nil else { return }

        viewLayer.colors = [
            UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 1, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 0, blue: 1, alpha: 1).cgColor,
            UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0.5, green: 1, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 1, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 1, blue: 0.5, alpha: 1).cgColor,
            UIColor(red: 0, green: 1, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0, green: 0.5, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0, green: 0, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0.5, green: 0, blue: 1, alpha: 1).cgColor,
            UIColor(red: 1, green: 0, blue: 1, alpha: 1).cgColor,
            UIColor(red: 1, green: 0, blue: 0.5, alpha: 1).cgColor,
            UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.25, blue: 0, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.5, blue: 0.25, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.75, blue: 0.5, alpha: 1).cgColor,
            UIColor(red: 1, green: 1, blue: 0.75, alpha: 1).cgColor,
            UIColor(red: 0.75, green: 1, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0.5, green: 0.75, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0.25, green: 0.5, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0, green: 0.25, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0, green: 0, blue: 0.75, alpha: 1).cgColor,
            UIColor(red: 0.25, green: 0, blue: 0.5, alpha: 1).cgColor,
            UIColor(red: 0.5, green: 0, blue: 0.25, alpha: 1).cgColor,
            UIColor(red: 0.75, green: 0.5, blue: 0, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.75, blue: 0, alpha: 1).cgColor,
            UIColor(red: 1, green: 1, blue: 0.5, alpha: 1).cgColor,
            UIColor(red: 0.75, green: 1, blue: 0.25, alpha: 1).cgColor,
            UIColor(red: 0.5, green: 1, blue: 0, alpha: 1).cgColor
        ]
        viewLayer.startPoint = CGPoint(x: 0, y: 0.5)
        viewLayer.endPoint = CGPoint(x: 1, y: 0.5)
        viewLayer.frame = self.bounds

        layer.addSublayer(viewLayer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        addGestureRecognizer(panGestureRecognizer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        viewLayer.frame = bounds
        setupGradientLayer()
    }

    @objc func onPan(_ gestureRecognizer: UIGestureRecognizer) {
        let location = gestureRecognizer.location(in: self)

        guard let selectedColor = viewLayer.colorOfPoint(point: location) else { return }
        delegate?.colorPicker(self, didSelect: selectedColor)
    }
}

extension CALayer {
    func colorOfPoint(point: CGPoint) -> UIColor? {
        var pixel: [UInt8] = [0, 0, 0, 0]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let context = CGContext(
            data: &pixel,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }
        context.translateBy(x: -point.x, y: -point.y)

        render(in: context)
        let red = CGFloat(pixel[0]) / 255.0
        let green = CGFloat(pixel[1]) / 255.0
        let blue = CGFloat(pixel[2]) / 255.0
        let alpha = CGFloat(pixel[3]) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
