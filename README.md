#StarWarsAnimatedTransitioning

UIViewController animated transitioning mimicking the Star Wars scene transitions using the custom animated transition APIs added in iOS 7.

StarWarsAnimatedTransitioning is suitable for modal presentation of view controllers.

It uses CALayer animations and masks so transitions do not break layout and dynamic/animated content in the view controllers involved.

![out](https://cloud.githubusercontent.com/assets/5302709/6905766/fba2c81c-d732-11e4-9b37-4cf759b18e73.gif)

This is an experimentation with Core Animation during which I learned quite a few tricks 'till deciding the current implementation and APIs to use.
I encourage everyone to familiarize themselves with masks, anchor points and transforms of CALayers!

Feedback is welcome and greatly appreciated!

##Usage

In order to make the system use a custom animated transitioning class you have to set the presented controller's modalPresentationStyle and transitioningDelegate properties:

```swift
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  if segue.identifier == "PresentSecondController" {
    let destinationController = segue.destinationViewController as! UIViewController
    destinationController.modalPresentationStyle = .Custom
    destinationController.transitioningDelegate = self
  }
}
```

In the UIViewControllerTransitioningDelegate methods pass a StarWarsAnimatedTransitioning object and set it's properties to depending on presentation operation and directions.

```swift
func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
  let animator = StarWarsAnimatedTransitioning()
  animator.operation = .Present
  animator.type = .LinearRight
  animator.duration = 0.4

  return animator
}

func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
  let animator = StarWarsAnimatedTransitioning()
  animator.operation = .Dismiss
  animator.type = .CircularCounterclockwise
  animator.duration = 1.0

  return animator
}

```
##System Requirements

iOS 8.0+

Xcode 6.3beta+ (Swift 1.2 is required)

##Future Updates:

* Faded edges

##License
StarWarsAnimatedTransitioning is MIT-licensed.

If you use it please acknowledge it and tell me about it. I would like to hear how you use it in your apps!
