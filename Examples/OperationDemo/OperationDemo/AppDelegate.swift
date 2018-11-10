//
//  AppDelegate.swift
//  OperationDemo
//
//  Created by Andrew McKnight on 11/9/18.
//

import Cocoa
import Pippin

typealias OperationState = (description: String, color: NSColor, font: String)

let colors = [ NSColor.black, NSColor.blue, NSColor.orange, NSColor.red, NSColor.green, NSColor.gray, NSColor.cyan, NSColor.magenta ]
var currentColor = 0
var syncOperationNumber = 1
var asyncOperationNumber = 1
var naiveAsyncOperationNumber = 1
var compoundOperationNumber = 1

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    
    private var output: [OperationState] = []
    private var queue = OperationQueue()
    private var observationContext = 0
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.queue.maxConcurrentOperationCount = 1
        self.queue.isSuspended = true
        self.stopButton.isEnabled = false
    }
    
    // MARK: IBActions
    
    @IBAction func startQueue(sender: AnyObject) {
        queue.isSuspended = false
        playButton.isEnabled = false
        stopButton.isEnabled = true
    }
    
    @IBAction func stopQueue(sender: AnyObject) {
        queue.isSuspended = true
        playButton.isEnabled = true
        stopButton.isEnabled = false
    }
    
    @IBAction func queueConcurrencyChanged(sender: NSSegmentedControl) {
        let opCount = sender.selectedSegment == 0 ? 1 : OperationQueue.defaultMaxConcurrentOperationCount
        self.queue.maxConcurrentOperationCount = opCount
    }
    
    @IBAction func cancelCurrentOperation(sender: NSButton) {
        if let operation = self.queue.operations.first {
            operation.cancel()
        }
    }
    @IBAction func cancelAllOperations(_ sender: Any) {
        self.queue.cancelAllOperations()
    }
    
    @IBAction func clearDisplay(sender: NSButton) {
        syncOperationNumber = 1
        asyncOperationNumber = 1
        compoundOperationNumber = 1
        self.output.removeAll()
        self.tableView.reloadData()
    }
    
    // MARK: adding operations
    
    @IBAction func addSyncOperation(sender: NSButton) {
        DispatchQueue.main.async {
            let syncOperation = DemoSyncOperation(delegate: self)
            self.addState(state: ("\(syncOperation.name!) enqueued", syncOperation.color, "HelveticaNeue-Light"))
            self.queue.addOperation(syncOperation)
        }
    }
    
    @IBAction func addNaiveAsyncOperation(_ sender: Any) {
        DispatchQueue.main.async {
            let naiveAsyncOperation = NaiveAsyncOperation(delegate: self)
            self.addState(state: ("\(naiveAsyncOperation.name!) enqueued", naiveAsyncOperation.color, "HelveticaNeue-Light"))
            self.queue.addOperation(naiveAsyncOperation)
        }
    }
    
    @IBAction func addAsyncOperation(sender: NSButton) {
        DispatchQueue.main.async {
            let asyncOperation = DemoAsyncOperation(delegate: self)
            self.addState(state: ("\(asyncOperation.name!) enqueued", asyncOperation.color, "HelveticaNeue-Light"))
            self.queue.addOperation(asyncOperation)
        }
    }
    
    @IBAction func addCompoundOperation(sender: AnyObject) {
        DispatchQueue.main.async {
            let compoundOperation = DemoCompoundOperation(delegate: self)
            self.addState(state: ("\((compoundOperation.name!)) enqueued", NSColor.black, "HelveticaNeue-Light"))
            self.queue.addOperation(compoundOperation)
        }
    }
    
    // MARK: helpers
    
    private func addState(state: OperationState) {
        DispatchQueue.main.async {
            self.output.append(state)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: NSIndexSet(index: self.output.count - 1) as IndexSet, withAnimation: .slideDown)
            self.tableView.endUpdates()
        }
    }
}

// MARK: NSTableViewDelegate

extension AppDelegate: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "kRowID"), owner: tableView) as? NSTableRowView ?? NSTableRowView(frame: NSZeroRect)
        
        let label = NSTextView(frame: NSMakeRect(0, 0, 300, 24))
        label.textStorage?.append(NSAttributedString(string: self.output[row].description, attributes: [NSAttributedString.Key.foregroundColor: self.output[row].color, NSAttributedString.Key.font: NSFont(name: output[row].font, size: 24)!]))
        
        return view
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 24
    }
    
}

// MARK: NSTableViewDataSource

extension AppDelegate: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.output.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return self.output[row].description
    }
    
    func tableView(_ tableView: NSTableView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, row: Int) {
        let cellObject = cell as? NSCell
        cellObject?.attributedStringValue = NSAttributedString(string: self.output[row].description, attributes: [NSAttributedString.Key.foregroundColor: self.output[row].color, NSAttributedString.Key.font: NSFont(name: output[row].font, size: 18)!])
        
    }
}

// MARK: OperationStateChangeDelegate

extension AppDelegate: OperationStateChangeDelegate {
    func getColor(operation: Operation) -> NSColor {
        if let sync = operation as? DemoSyncOperation {
            return sync.color
        }
        if let async = operation as? DemoAsyncOperation {
            return async.color
        }
        return NSColor.black
    }
    
    func operationBeganExecuting(operation: Operation) {
        self.addState(state: ("\(operation.name!) started", getColor(operation: operation), "HelveticaNeue"))
    }
    
    func operationMainMethodFinished(operation: Operation) {
        self.addState(state: ("\(operation.name!) main method finished", getColor(operation: operation), "HelveticaNeue"))
    }
    
    func operationAsyncWorkFinished(operation: Operation) {
        self.addState(state: ("\(operation.name!) async work finished", getColor(operation: operation), "HelveticaNeue"))
    }
    
    func operationSyncWorkFinished(operation: Operation) {
        self.addState(state: ("\(operation.name!) sync work finished", getColor(operation: operation), "HelveticaNeue"))
    }
    
    func operationAsyncWorkCanceled(operation: Operation) {
        self.addState(state: ("\(operation.name!) async work canceled", getColor(operation: operation), "HelveticaNeue"))
    }
    
    func operationAsyncWorkFailed(operation: Operation) {
        self.addState(state: ("\(operation.name!) async work failed", getColor(operation: operation), "HelveticaNeue"))
    }
    
    func operationAsyncCompletionCalled(operation: Operation) {
        self.addState(state: ("\(operation.name!) async completion", getColor(operation: operation), "HelveticaNeue-BoldItalic"))
    }
    
    func operationSyncCompletionCalled(operation: Operation) {
        self.addState(state: ("\(operation.name!) sync completion", getColor(operation: operation), "HelveticaNeue-Italic"))
    }
    
    func operationAsyncCompletionCalled(operation: Operation, withError error: Error) {
        self.addState(state: ("\(operation.name!) async completion with error: \(error.localizedDescription)", getColor(operation: operation), "HelveticaNeue-BoldItalic"))
    }
}

