import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		setupAppearance()
		
		window = UIWindow(frame: UIScreen.main.bounds)
		let rootViewController = RootViewController()
		let navigationController = UINavigationController(rootViewController: rootViewController)
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
		
		return true
	}
	
	private func setupAppearance() {
		if #available(iOS 13.0, *) {
			let navBarAppearance = UINavigationBarAppearance()
			navBarAppearance.configureWithOpaqueBackground()
			navBarAppearance.backgroundColor = .systemBackground
			navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
			navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
			
			UINavigationBar.appearance().standardAppearance = navBarAppearance
			UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
			UINavigationBar.appearance().compactAppearance = navBarAppearance
			
			window?.overrideUserInterfaceStyle = .light
		}
	}
}
