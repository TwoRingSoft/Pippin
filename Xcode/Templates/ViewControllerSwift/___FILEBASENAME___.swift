//___FILEHEADER___

import Cocoa

protocol ___FILEBASENAMEASIDENTIFIER___Delegate {
}

class ___FILEBASENAMEASIDENTIFIER___: ___VARIABLE_cocoaSubclass___ {
  
    private var delegate: ___FILEBASENAMEASIDENTIFIER___Delegate!
    
    init(delegate: ___FILEBASENAMEASIDENTIFIER___Delegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
}
