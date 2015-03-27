#StarWarsAnimatedTransitioning

UIViewController animated transitioning mimicking the Star Wars scene transitions using the custom animated transition APIs added in iOS 7.
It uses CALayer animations and masks so transitions do not break layout and dynamic/animated content in the view controllers involved.

![anim](https://cloud.githubusercontent.com/assets/5302709/5523211/09accd16-89ce-11e4-83c9-3009ffcc273a.gif)

This is an experimentation with Core Animation during which I learned quite a few tricks 'till deciding the current implementation and APIs to use.
I encourage everyone to familiarize themselves with masks, anchor points and transforms of CALayers!

Feedback is welcome and greatly appreciated!

##Usage

In order to make the system use a custom animated transitioning class you have to set the presented controller's modalPresentationStyle and transitioningDelegate properties:

```swift
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  if segue.identifier == "PresentSecondController" {
    let secondController = segue.destinationViewController as UIViewController
    secondController.modalPresentationStyle = .Custom
    secondController.transitioningDelegate = self
  }
}
```

In the UIViewControllerTransitioningDelegate implementation pass StarWarsAnimatedTransitioning and set it's properties to depending on presentation operation and directions.

```swift
func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
  let animator = StarWarsAnimatedTransitioning()
  animator.transitionOperation = .Present
  animator.transitionDirection = .LinearRight

  return animator
}

func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
  let animator = StarWarsAnimatedTransitioning()
  animator.transitionOperation = .Dismiss
  animator.transitionDirection = .CircularCounterclockwise

  return animator
}

```

##Objective-C Support

StarWarsAnimatedTransitioning uses Swift 1.2 enums expose in Objective-C. The current version works only with Swift 1.2 and above and Xcode 6.3 and above.

##Future Updates:

* Faded edges

##License
StarWarsAnimatedTransitioning is MIT-licensed.

If you use it please acknowledge it and tell me about it. I would like to hear how you use it in your apps!
