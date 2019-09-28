# OperationDemo

A macOS application that demostrates `AsyncOperation` and `CompoundOperation`, and shows their correctness compared to a naïve implementation of an asynchronous `NSOperation` subclass.

You can add any type of operation to the queue by pressing the buttons on the left:
- synchronous
- naïve async
- correct async
- compound consisting of 3 [correct] async operations.

Press `►` to set the operation queue to execute, and `◼` to pause execution. Operations may be added whether or not the queue is paused.

The naïve async operation shows why simply starting an async task from within a synchronous operation is a logic error: the completion block executes before the task is finished! This is why you must manually manage the properties of `NSOperation` related to asynchronicity. (Read more in my blog post: [Swift Async Operations at Your Command](https://tworingsoft.com/blog/2018/11/19/swift-async-operations-at-your-command.html).)
