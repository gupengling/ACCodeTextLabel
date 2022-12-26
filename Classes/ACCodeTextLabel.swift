//
//  ACCodeTextLabel.swift
//  Pods-Example
//
//  Created by gupengling on 2022/2/19.
//

import UIKit

/// MARK - 组合协议
public typealias LableRenderable = UILabel & CodeProtocol

/// MARK - 验证码文本协议
@objc public protocol CodeProtocol: NSObjectProtocol {
    /// 单个文本框大小
    var itemSize: CGSize { get }

    /// 错误
    var lineHeight: CGFloat { set get }

    /// 错误
    var isError: Bool { set get }

    /// 刷新方法
    ///
    /// - Parameters:
    ///   - character: 字符
    ///   - isFocusingCharacter: 是否焦点
    ///   - isEditing: 是否编辑
    func update(character: String?, isFocusingCharacter: Bool, isEditing: Bool)
}

/// MARK - ACCodeTextLabelDelegate
@objc public protocol ACCodeTextLabelDelegate: NSObjectProtocol {
    /// 值改变
    /// - Parameters:
    ///   - sender: sender
    ///   - value: value
    func codeTextFieldValueChanged(_ sender: ACCodeTextLabel, value: String)
    func codeTextFieldValueEndChanged(_ sender: ACCodeTextLabel, value: String)
}

public class ACCodeTextLabel: UITextField, UITextFieldDelegate {

    @objc public var valueChanged: ((String) -> Void)?
    @objc public var valueEndChanged: ((String) -> Void)?
    @objc public weak var codeDelegate: ACCodeTextLabelDelegate?

    /// 验证码长度
    let length: Int
    /// 字符标签间距
    let charSpacing: CGFloat
    /// 验证字符集
    let validCharacterSet: CharacterSet
    /// 字符标签集合
    let charLabels: [LableRenderable]

    override open var delegate: UITextFieldDelegate? {
        get { return super.delegate }
        set { assertionFailure() }
    }

    @objc public init(length: Int,
                      charSpacing: CGFloat,
                      validCharacterSet: CharacterSet,
                      charLabelGenerator: (Int) -> CodeProtocol) {
        self.length = length
        self.charSpacing = charSpacing
        self.validCharacterSet = validCharacterSet
        self.charLabels = (0..<length).map { charLabelGenerator($0) as! LableRenderable }
        super.init(frame: CGRect.zero)
        loadSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 布局子视图
    override open func layoutSubviews() {
        super.layoutSubviews()
        var nextX: CGFloat = 0
        charLabels.forEach { label in
            label.frame = CGRect(x: nextX, y: 0, width: label.itemSize.width, height: label.itemSize.height)
            nextX += (label.itemSize.width + charSpacing)
        }
    }

    /// 加载子视图
    private func loadSubviews() {
        super.textColor = UIColor.clear
        clipsToBounds = true
        super.delegate = self
        addTarget(self, action: #selector(updateLabels), for: .editingChanged)
        clearsOnBeginEditing = false
        clearsOnInsertion = false
        charLabels.forEach {
            $0.textAlignment = .center
            addSubview($0)
        }
    }

    /// 刷新标签
    @objc public func updateLabels() {
        let text = self.text ?? ""
        var chars = text.map { Optional.some($0) }

        while chars.count < length {
            chars.append(nil)
        }

        zip(chars, charLabels).enumerated().forEach { args in
            let (index, (char, charLabel)) = args
            charLabel.update(
                character: char.map { String($0) },
                isFocusingCharacter: index == text.count || (index == text.count - 1 && index == length - 1),
                isEditing: isEditing
            )
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    /// MARK -  public function

    /// 文本颜色
    private var _isError = false
    @objc public var isError: Bool {
        get { return _isError }
        set {
            _isError = newValue
            charLabels.forEach { $0.isError = _isError }
            if _isError == false {
                updateLabels()
            }
        }
    }

    private var _lineHeight: CGFloat = 1.0
    @objc public var lineHeight: CGFloat {
        get { return _lineHeight }
        set {
            _lineHeight = newValue
            charLabels.forEach{ $0.lineHeight = _lineHeight }
        }
    }

    override open var textColor: UIColor? {
        get { return charLabels.first?.textColor }
        set { charLabels.forEach { $0.textColor = newValue } }
    }

    /// 内容大小
    override open var intrinsicContentSize: CGSize {
        var width: CGFloat = charSpacing * CGFloat(length - 1)
        charLabels.forEach {
            width += $0.itemSize.width
        }
        return CGSize(width: width, height: charLabels.first?.itemSize.height ?? 0)
    }

    /// 控制输入光标显示的位置
    ///
    /// - Parameter position: 位置
    /// - Returns: CGRect
    override open func caretRect(for position: UITextPosition) -> CGRect {
        let currentEditingPosition = text?.count ?? 0
        let superRect = super.caretRect(for: position)

        guard currentEditingPosition < length else {
            return CGRect(origin: .zero, size: .zero)
        }

        let width = charLabels[currentEditingPosition].itemSize.width
        var offSet: CGFloat = 0
        (0..<currentEditingPosition).forEach { idx in
            offSet += charLabels[idx].itemSize.width + charSpacing
        }

        let x = offSet + width / 2 - superRect.width / 2
        return CGRect(x: x, y: superRect.minY, width: superRect.width, height: superRect.height)
    }

    /// 控制文本显示
    ///
    /// - Parameter bounds: bounds
    /// - Returns: CGRect
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let origin = super.textRect(forBounds: bounds)
        return CGRect(x: -bounds.width, y: 0, width: 0, height: origin.height)
    }

    /// 隐藏占位文字
    ///
    /// - Parameter bounds: bounds
    /// - Returns: CGRect
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return .zero
    }

    /// 隐藏边框
    ///
    /// - Parameter bounds: bounds
    /// - Returns: CGRect
    override open func borderRect(forBounds bounds: CGRect) -> CGRect {
        return .zero
    }

    /// 文本范围对应的选择矩形数组
    ///
    /// - Parameter range: range
    /// - Returns: [UITextSelectionRect]
    override open func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }

    /// 限制输入的字数和字符集
    ///
    /// - Parameters:
    ///   - textField: textField
    ///   - range: range
    ///   - string: string
    /// - Returns: Bool
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = text
            .map { $0 as NSString }
            .map { $0.replacingCharacters(in: range, with: string) } ?? ""
        let newTextCharacterSet = CharacterSet(charactersIn: newText)
        let isValidLength = newText.count <= length
        let isUsingValidCharacterSet = validCharacterSet.isSuperset(of: newTextCharacterSet)
        if isValidLength, isUsingValidCharacterSet {
            textField.text = newText
            codeDelegate?.codeTextFieldValueChanged(self, value: newText)
            valueChanged?(newText)
            sendActions(for: .editingChanged)
        }

        // 输入完毕后
        if (newText.count == length) {
            codeDelegate?.codeTextFieldValueEndChanged(self, value: newText)
            valueEndChanged?(newText)
            sendActions(for: .editingDidEnd)
        }
        return false
    }

    /// 从显示的文本中删除一个字符
    override open func deleteBackward() {
        super.deleteBackward()
        sendActions(for: .editingChanged)
    }

    /// 第一响应者
    ///
    /// - Returns: Bool
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        defer { updateLabels() }
        return super.becomeFirstResponder()
    }

    /// 移除第一响应者
    ///
    /// - Returns: Bool
    @discardableResult
    override open func resignFirstResponder() -> Bool {
        defer { updateLabels() }
        return super.resignFirstResponder()
    }

    /// 限制文本只处理粘贴
    ///
    /// - Parameters:
    ///   - action: action
    ///   - sender: sender
    /// - Returns: Bool
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let paste = #selector(paste(_:))
        return action == paste
    }

    /// 复制方法
    ///
    /// - Parameter sender: sender description
    override open func paste(_ sender: Any?) {
        super.paste(sender)
        updateLabels()
    }

    /// 任何调整选择范围的行为都会直接把 insert point 调到最后一次
    override open var selectedTextRange: UITextRange? {
        get { return super.selectedTextRange }
        set { super.selectedTextRange = textRange(from: endOfDocument, to: endOfDocument) }
    }
}
