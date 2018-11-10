//
//  ColorSliderCell.swift
//  Pippin
//
//  Created by Andrew McKnight on 11/1/18.
//  Copyright © 2018 Two Ring Software. All rights reserved.
//

import Foundation

public protocol ColorSliderCellDelegate {
    func colorSliderCell(_ colorSliderCell: ColorSliderCell, choseColor color: UIColor)
}

public final class ColorSliderCell: UITableViewCell {
    fileprivate var preview: UIView!
    fileprivate var slider: UISlider!
    private let gradient = ColorGradientLayer()
    var delegate: ColorSliderCellDelegate!

    class func reuseIdentifier() -> String {
        return "com.tworingsoft.pippin.cell-reuse-identifier.color-picker-cell"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpLabel()
        setUpSlider()

        self.selectionStyle = .none
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = preview.bounds
    }
    
    func configure(chosenHue: Float) {
        slider.value = chosenHue
        setSliderColor(UIColor(hue: CGFloat(chosenHue), saturation: 1, brightness: 1, alpha: 1))
    }
}

// MARK: Private
private extension ColorSliderCell {
    func setUpLabel() {
        let label = UILabel()
        label.text = "Overlay color:"
        label.textColor = UIColor.white

        contentView.addSubview(label)

        [
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ].forEach { $0.isActive = true }
    }

    func setUpSlider() {
        slider = UISlider()
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.addTarget(self, action: #selector(ColorSliderCell.sliderSlid(_:)), for: .valueChanged)

        preview = UIView()
        preview.layer.insertSublayer(gradient, at: 0)

        let stack = UIStackView(arrangedSubviews: [ preview, slider ])
        stack.axis = .vertical
        stack.spacing = 10
        contentView.addSubview(stack)

        [
            stack.heightAnchor.constraint(equalToConstant: 50),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
        ].forEach { $0.isActive = true }
    }

    func setSliderColor(_ color: UIColor) {
        slider.thumbTintColor = color
        slider.maximumTrackTintColor = color
        slider.minimumTrackTintColor = color
    }
    
    @objc func sliderSlid(_ sender: UISlider) {
        let color = UIColor(hue: CGFloat(sender.value), saturation: 1, brightness: 1, alpha: 1)
        setSliderColor(color)
        delegate.colorSliderCell(self, choseColor: color)
    }
}
