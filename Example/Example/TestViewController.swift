//
//  TestViewController.swift
//  Example
//
//  Created by gupengling on 2022/2/19.
//

import UIKit
import ACCodeTextLabel

class TestViewController: UIViewController, ACCodeTextLabelDelegate {

    var temTextField: ACCodeTextLabel?

    @objc func backClicked(_ sender: AnyObject) {
        dismiss(animated: true) {

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let btn = UIButton(frame: CGRect(x: 50, y: 50, width: 50, height: 40))
        btn.setTitle("Back", for: .normal)
        btn.addTarget(self, action: #selector(backClicked(_:)), for: .touchUpInside)
        btn.backgroundColor = .brown
        view.addSubview(btn)

        temTextField = ACCodeTextLabel(length: 6,
                                       charSpacing: 5,
                                       validCharacterSet: CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"))
        { index in
            if index % 2 == 0 {
                let label = NormalStyleLabel(size: CGSize(width: 50, height: 50))
                label.style = Style.border(nomal: UIColor.gray, selected: UIColor.orange)
                return label
            } else {
                return NormalStyleLabel(size: CGSize(width: 60, height: 50))
            }
        }
        temTextField!.keyboardType = .asciiCapable
        temTextField!.translatesAutoresizingMaskIntoConstraints = false
        temTextField!.codeDelegate = self
        temTextField!.valueChanged = { value in
            debugPrint(value)
        }
        temTextField!.valueEndChanged = { [weak self] value in
            debugPrint(value)
            self?.temTextField?.resignFirstResponder()
        }
        temTextField!.backgroundColor = .orange
        view.addSubview(temTextField!)
        NSLayoutConstraint.activate([
            temTextField!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            temTextField!.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            temTextField!.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    func codeTextFieldValueChanged(_ sender: ACCodeTextLabel, value: String) {
        debugPrint(value)
    }

    func codeTextFieldValueEndChanged(_ sender: ACCodeTextLabel, value: String) {
        debugPrint(value)
        sender.resignFirstResponder()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.temTextField?.isError = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.temTextField?.isError = false
            }
        }
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
