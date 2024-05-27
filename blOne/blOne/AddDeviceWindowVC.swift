import Web3
import UIKit
import Web3PromiseKit
import Web3ContractABI

class AddDeviceWindowVC: UIViewController, UITextFieldDelegate {
    
    let inputAddress = UITextField(frame: CGRect(x: 60, y: 100, width: 250, height: 50))
    let inputID = UITextField(frame: CGRect(x: 60, y: 200, width: 250, height: 50))
    let inputType = UITextField(frame: CGRect(x: 60, y: 300, width: 250, height: 50))
    
    let inputAddrTitle = UILabel(frame: CGRect(x: 60, y: 50, width: 250, height: 50))
    let inputIDTitle = UILabel(frame: CGRect(x: 60, y: 150, width: 250, height: 50))
    let inputTypeTitle = UILabel(frame: CGRect(x: 60, y: 250, width: 250, height: 50))
    
    let acceptChanges = UIButton(frame: CGRect(x: 60, y: 385, width: 250, height: 50))

    override func viewDidLoad() {
        super.viewDidLoad()
        acceptChanges.setTitle("Add new device", for: .normal)
        acceptChanges.addTarget(self, action: #selector(buttonTextField), for: .touchUpInside)
        acceptChanges.tintColor = .white
        acceptChanges.backgroundColor = .systemBlue
        acceptChanges.layer.cornerRadius = 10
        
        inputAddrTitle.text = "Device's address"
        inputIDTitle.text = "Device's ID"
        inputTypeTitle.text = "Device's type"
        
        inputAddrTitle.textColor = .systemBlue
        inputIDTitle.textColor = .systemBlue
        inputTypeTitle.textColor = .systemBlue
        
        inputAddress.placeholder = "Input address"
        inputAddress.borderStyle = .roundedRect
        inputAddress.backgroundColor = UIColor.white
        
        inputID.placeholder = "Input ID"
        inputID.borderStyle = .roundedRect
        inputID.backgroundColor = UIColor.white
        
        inputType.placeholder = "Input type"
        inputType.borderStyle = .roundedRect
        inputType.backgroundColor = UIColor.white
                
        view.addSubview(inputAddress)
        view.addSubview(inputID)
        view.addSubview(inputType)
        
        view.addSubview(inputAddrTitle)
        view.addSubview(inputIDTitle)
        view.addSubview(inputTypeTitle)
        
        view.addSubview(acceptChanges)
        
        inputAddress.delegate = self
        inputID.delegate = self
        inputType.delegate = self
        
        view.backgroundColor = .systemGray6
    }
    
    
    private func textFieldAddr(_ textField: UITextField) -> String {
         return inputAddress.text!
     }
    
    private func textFieldID(_ textField: UITextField) -> String {
         return inputID.text!
     }
    
    private func textFieldType(_ textField: UITextField) -> String {
         return inputType.text!
     }
    
    func devoceInfo() -> Array<Any>{
        var device: [Any] = []
        device.append(textFieldAddr(inputAddress))
        device.append(textFieldID(inputID))
        device.append(textFieldType(inputType))
        return device
    }
    
    @objc func buttonTextField(sender: UIButton!) {
            if inputAddress.text?.isEmpty == true{
                inputAddress.attributedPlaceholder = NSAttributedString(string: "Enter the address", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
            if inputID.text?.isEmpty == true{
                inputID.attributedPlaceholder = NSAttributedString(string: "Enter the ID", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
            if inputType.text?.isEmpty == true{
                inputType.attributedPlaceholder = NSAttributedString(string: "Enter the type", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
        if inputAddress.text?.isEmpty == false && inputID.text?.isEmpty == false && inputType.text?.isEmpty == false{
//            addDevice(inputAddress.text!, inputType.text!, inputID.text!)
        }
                
    }
    func addDevice(_ deviceAddress: String, _ deviceType: String, _ deviceID: String){
        
        let contract = HomeViewController.contract()
        let deviceAddress = deviceAddress
        let deviceType = deviceType
        let deviceID = deviceID
        let nonce = try! HomeViewController.web3.eth.getTransactionCount(address: HomeViewController.caller, block: HomeViewController.tag).wait()
        let call = callFun(input: "addDevice", contract: contract)!(deviceAddress, deviceType, deviceID)
        let gasPrice = try! HomeViewController.web3.eth.gasPrice().wait()
        guard let transaction = call.createTransaction(nonce: nonce, gasPrice: gasPrice, maxFeePerGas: nil, maxPriorityFeePerGas: nil, gasLimit: 500000, from: HomeViewController.caller, value: 0, accessList: [:], transactionType: .legacy)
        else {
            return
        }
        let signedTx = try! transaction.sign(with: HomeViewController.privateKey, chainId: 11155111).guarantee.wait()
        firstly {
            HomeViewController.web3.eth.sendRawTransaction(transaction: signedTx)
        }.done {
            recipt in HomeViewController.web3.eth.getTransactionByHash(blockHash: recipt){
                txRecipt in print(txRecipt)
            }
        }.catch { error in
            print(error)
        }
    }
    func callFun(input: String, contract: DynamicContract) -> ((ABIEncodable...) -> SolidityInvocation)?{
             let result: ((ABIEncodable...) -> SolidityInvocation)? = contract[input]
             return result
         }
    

}
