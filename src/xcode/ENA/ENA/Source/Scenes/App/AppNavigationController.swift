//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import Foundation
import UIKit

class AppNavigationController: UINavigationController {
	private var scrollViewObserver: NSKeyValueObservation?

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationBar.isTranslucent = true
		navigationBar.prefersLargeTitles = true

		view.backgroundColor = .enaColor(for: .separator)

		delegate = self
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		scrollViewObserver?.invalidate()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if let opacityDelegate = topViewController as? NavigationBarOpacityDelegate {
			navigationBar.backgroundAlpha = opacityDelegate.backgroundAlpha
		}
	}
}

extension AppNavigationController: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		scrollViewObserver?.invalidate()

		var navigationBackgroundAlpha: CGFloat = 1.0

		if let opacityDelegate = viewController as? NavigationBarOpacityDelegate {
			navigationBackgroundAlpha = opacityDelegate.backgroundAlpha

			if let scrollView = viewController.view as? UIScrollView ?? viewController.view.subviews.first(ofType: UIScrollView.self) {
				scrollViewObserver = scrollView.observe(\.contentOffset) { [weak self] _, _ in
					guard let self = self else { return }
					guard viewController == self.topViewController else { return }
					self.navigationBar.backgroundAlpha = opacityDelegate.backgroundAlpha
				}
			}
		}

		transitionCoordinator?.animate(alongsideTransition: { _ in
			self.navigationBar.backgroundAlpha = navigationBackgroundAlpha
		})
	}
}

extension UINavigationBar {
	var backgroundView: UIView? { subviews.first }
	var shadowView: UIImageView? { backgroundView?.subviews.first(ofType: UIVisualEffectView.self)?.subviews.first(ofType: UIImageView.self) }
	var visualEffectView: UIVisualEffectView? { backgroundView?.subviews.last(ofType: UIVisualEffectView.self) }

	var backgroundAlpha: CGFloat {
		get { backgroundView?.alpha ?? 0 }
		set {
			backgroundView?.alpha = newValue
		}
	}
}

private extension Array {
	func first<T>(ofType _: T.Type) -> T? {
		first(where: { $0 is T }) as? T
	}

	func last<T>(ofType _: T.Type) -> T? {
		last(where: { $0 is T }) as? T
	}
}

protocol NavigationBarOpacityDelegate: class {
	var preferredNavigationBarOpacity: CGFloat { get }
}

private extension NavigationBarOpacityDelegate {
	var backgroundAlpha: CGFloat { max(0, min(preferredNavigationBarOpacity, 1)) }
}
