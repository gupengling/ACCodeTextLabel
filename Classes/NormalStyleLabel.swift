//
//  NormalStyleLabel.swift
//  ACCodeTextLabel
//
//  Created by gupengling on 2022/2/19.
//

import Foundation

@objc public enum StyleOC: Int {
    case line
    case border
}
/// 样式
///
/// - line: 下划线
/// - border: 边框
public enum Style {
    case line(nomal: UIColor, selected: UIColor)
    case border(nomal: UIColor, selected: UIColor)

    public var nomal: UIColor {
        switch self {
        case let .line(nomal, _):
            return nomal
        case let .border(nomal, _):
            return nomal
        }
    }

    public var selected: UIColor {
        switch self {
        case let .line(_, selected):
            return selected
        case let .border(_, selected):
            return selected
        }
    }
}

/// 默认横线样式
@objc public class NormalStyleLabel: UILabel, CodeProtocol {
    @objc public var errorColor: UIColor = .red

    @objc public var radius: CGFloat = 2.0 {
        didSet {
            switch style {
            case .border:
                layer.cornerRadius = radius
            default:
                break
            }
        }
    }
    @objc public var lineHeight: CGFloat = 1.0 {
        didSet {
            switch style {
            case .line:
                lineLayer.frame = CGRect(x: 0, y: itemSize.height - lineHeight, width: itemSize.width, height: lineHeight)
            default:
                layer.borderWidth = lineHeight
            }
        }
    }
    /// 大小
    public var itemSize: CGSize

    /// 是否编辑
    private var isEditing = false

    /// 是否焦点
    private var isFocusingCharacter = false

    /// 风格
    public var style = Style.line(nomal: .gray, selected: .red) {
        didSet {
            switch style {
            case .line:
                layer.addSublayer(lineLayer)
                lineLayer.backgroundColor = style.nomal.cgColor
                layer.borderWidth = 0
                layer.borderColor = UIColor.clear.cgColor
            default:
                lineLayer.removeFromSuperlayer()
                layer.borderWidth = lineHeight
                layer.borderColor = style.nomal.cgColor
                layer.cornerRadius = radius
                layer.masksToBounds = true
            }
        }
    }

    public var isError: Bool = false {
        didSet {
            if isError {
                switch style {
                case .line:
                    lineLayer.backgroundColor = errorColor.cgColor
                default:
                    layer.borderColor = errorColor.cgColor
                }
            } else {

            }
        }
    }

    /// OC 专用
    @objc public func setStyle(type: StyleOC, normal: UIColor, selected: UIColor) {
        if type == .line {
            style = Style.line(nomal: normal, selected: selected)
        } else {
            style = Style.border(nomal: normal, selected: selected)
        }
    }

    @objc public init(size: CGSize) {
        self.itemSize = size
        super.init(frame: .zero)
        layer.addSublayer(lineLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 线
    private lazy var lineLayer: CALayer = {
        let temLayer = CALayer()
        temLayer.frame = CGRect(x: 0, y: itemSize.height - lineHeight, width: itemSize.width, height: lineHeight)
        temLayer.backgroundColor = style.nomal.cgColor
        return temLayer
    }()

    /// 刷新文本
    ///
    /// - Parameters:
    ///   - character: character
    ///   - isFocusingCharacter: isFocusingCharacter
    ///   - isEditing: isEditing
    public func update(character: String?, isFocusingCharacter: Bool, isEditing: Bool) {
        text = character.map { String($0) }
        self.isEditing = isEditing
        self.isFocusingCharacter = isFocusingCharacter
        if (text?.isEmpty ?? true) == false || (isEditing && isFocusingCharacter) {
            switch style {
            case .line:
                lineLayer.backgroundColor = style.selected.cgColor
            default:
                layer.borderColor = style.selected.cgColor
            }
        } else {
            switch style {
            case .line:
                lineLayer.backgroundColor = style.nomal.cgColor
            default:
                layer.borderColor = style.nomal.cgColor
            }
        }
    }
}
