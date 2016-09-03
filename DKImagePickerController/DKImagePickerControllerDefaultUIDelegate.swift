//
//  DKImagePickerControllerDefaultUIDelegate.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 16/3/7.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit

@objc
public class DKImagePickerControllerDefaultUIDelegate: NSObject, DKImagePickerControllerUIDelegate {
	
	public weak var imagePickerController: DKImagePickerController!
	public weak var parentNavItem: UINavigationItem!

	public lazy var doneButton: UIBarButtonItem = {
		return self.createDoneButton()
	}()

	public func createCancelButton() -> UIBarButtonItem {
		return UIBarButtonItem(barButtonSystemItem: .Cancel, target: self.imagePickerController, action: #selector(DKImagePickerController.dismiss))
	}

	public func createDoneButton() -> UIBarButtonItem {
		let doneButtonTitle = self.doneButtonTitle()
		let button = UIBarButtonItem(title: doneButtonTitle, style: UIBarButtonItemStyle.Done, target: self.imagePickerController, action: #selector(DKImagePickerController.done))
		return button
	}
	
	// Delegate methods...
	
	public func prepareLayout(imagePickerController: DKImagePickerController, vc: UIViewController) {
		self.imagePickerController = imagePickerController
		self.parentNavItem = vc.navigationItem
		updateDoneButtonTitle(self.doneButton)
	}
	
	public func imagePickerControllerCreateCamera(imagePickerController: DKImagePickerController,
	                                              didCancel: (() -> Void),
	                                              didFinishCapturingImage: ((image: UIImage) -> Void),
	                                              didFinishCapturingVideo: ((videoURL: NSURL) -> Void)) -> UIViewController {
		
		let camera = DKCamera()
		
		camera.didCancel = { () -> Void in
			didCancel()
		}
		
		camera.didFinishCapturingImage = { (image) in
			didFinishCapturingImage(image: image)
		}
		
		self.checkCameraPermission(camera)
	
		return camera
	}
	
	public func layoutForImagePickerController(imagePickerController: DKImagePickerController) -> UICollectionViewLayout.Type {
		return DKAssetGroupGridLayout.self
	}
	
	public func imagePickerController(imagePickerController: DKImagePickerController,
	                                  showsCancelButtonForVC vc: UIViewController) {
		vc.navigationItem.leftBarButtonItem = createCancelButton()
	}
	
	public func imagePickerController(imagePickerController: DKImagePickerController,
	                                  hidesCancelButtonForVC vc: UIViewController) {
		vc.navigationItem.leftBarButtonItem = nil
	}
	
	public func imagePickerController(imagePickerController: DKImagePickerController, didSelectAsset: DKAsset) {
		self.updateDoneButtonTitle(self.doneButton)
	}
    
    public func imagePickerController(imagePickerController: DKImagePickerController, didSelectAssets: [DKAsset]) {
        self.updateDoneButtonTitle(self.doneButton)
    }
	
	public func imagePickerController(imagePickerController: DKImagePickerController, didDeselectAsset: DKAsset) {
		self.updateDoneButtonTitle(self.doneButton)
	}
    
    public func imagePickerController(imagePickerController: DKImagePickerController, didDeselectAssets: [DKAsset]) {
        self.updateDoneButtonTitle(self.doneButton)
    }
	
	public func imagePickerControllerDidReachMaxLimit(imagePickerController: DKImagePickerController) {

		let messageString = imagePickerController.maxSelectedLocalizedMessage ?? String(format: DKImageLocalizedStringWithKey("maxLimitReachedMessage"), imagePickerController.maxSelectableCount)
		UIAlertView(title: DKImageLocalizedStringWithKey("maxLimitReached"),
		            message: messageString,
		            delegate: nil,
		            cancelButtonTitle: DKImageLocalizedStringWithKey("ok"))
			.show()
	}
	
	public func imagePickerControllerFooterView(imagePickerController: DKImagePickerController) -> UIView? {
		return nil
	}
    
    public func imagePickerControllerCameraImage() -> UIImage {
        return DKImageResource.cameraImage()
    }
    
    public func imagePickerControllerCheckedNumberColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    public func imagePickerControllerCheckedNumberFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(14)
    }
    
    public func imagePickerControllerCheckedImageTintColor() -> UIColor? {
        return nil
    }
    
    public func imagePickerControllerCollectionViewBackgroundColor() -> UIColor {
        return UIColor.whiteColor()
    }
	
	// Internal
	
	public func checkCameraPermission(camera: DKCamera) {
		func cameraDenied() {
			dispatch_async(dispatch_get_main_queue()) {
				let permissionView = DKPermissionView.permissionView(.Camera)
				camera.cameraOverlayView = permissionView
			}
		}
		
		func setup() {
			camera.cameraOverlayView = nil
		}
		
		DKCamera.checkCameraPermission { granted in
			granted ? setup() : cameraDenied()
		}
	}

	public func updateDoneButtonTitle(button: UIBarButtonItem) {
		self.parentNavItem?.rightBarButtonItem = self.createDoneButton()
	}

	public func doneButtonTitle() -> String {
		if self.imagePickerController.selectedAssets.count > 0 {
			return String(format: DKImageLocalizedStringWithKey("select"), self.imagePickerController.selectedAssets.count)
		} else {
			return DKImageLocalizedStringWithKey("done")
		}
	}
	
}
