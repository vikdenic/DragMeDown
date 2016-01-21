//
//  ViewController.swift
//  DragMeDown
//
//  Created by Vik Denic on 1/21/16.
//  Copyright © 2016 nektar labs. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UIViewControllerTransitioningDelegate {

    let interactor = Interactor()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! OtherVC
        vc.transitioningDelegate = self
        vc.interactor = interactor
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }

    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

class OtherVC: UIViewController {

    var interactor : Interactor? = nil

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func handleGesture(sender: UIPanGestureRecognizer) {

        let percentThreshold:CGFloat = 0.3

        // convert y-position to downward pull progress (percentage)
        let translation = sender.translationInView(view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)

        guard let interactor = interactor else { return }

        switch sender.state {
        case .Began:
            interactor.hasStarted = true
            dismissViewControllerAnimated(true, completion: nil)
        case .Changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.updateInteractiveTransition(progress)
        case .Cancelled:
            interactor.hasStarted = false
            interactor.cancelInteractiveTransition()
        case .Ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finishInteractiveTransition()
                : interactor.cancelInteractiveTransition()
        default:
            break
        }
    }
}