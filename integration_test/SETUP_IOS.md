# iOS Native Setup for Patrol E2E Tests

To run Patrol integration tests on iOS, you need to configure the iOS project for UI testing. Since these steps modify Xcode project files that can't be easily edited via scripts, you must perform them manually in Xcode.

## 1. Create a UI Testing Bundle

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Go to **File > New > Target...**
3. Select **UI Testing Bundle** and click **Next**.
4. Set the following:
   - **Product Name**: `RunnerUITests`
   - **Team**: Select your team
   - **Organization Identifier**: `com.rex9.rexone`
   - **Language**: Objective-C (or Swift, Patrol supports both, but Obj-C is often easier to integrate with Flutter's generated code)
   - **Target to be Tested**: `Runner`
5. Click **Finish**.

## 2. Configure `RunnerUITests` Target

1. Select the `RunnerUITests` target in the project navigator.
2. Go to **Build Settings**.
3. Search for **iOS Deployment Target** and set it to match your `Runner` target (e.g., iOS 13.0 or higher).

## 3. Replace the Test File

1. In the Project Navigator, find `RunnerUITests/RunnerUITests.m` (or `.swift`).
2. Replace its contents with the boilerplate provided by Patrol.

If using Objective-C (`RunnerUITests.m`):

```objc
@import XCTest;
@import patrol;
@import ObjectiveC.runtime;

@interface RunnerUITests : XCTestCase
@end

@implementation RunnerUITests

+ (void)setUp {
  [PatrolIntegrationTestRunner shared].testBundle = [NSBundle bundleForClass:[self class]];
  [super setUp];
}

PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)

@end
```

## 4. Run the tests

Once configured, you can run Patrol tests on iOS using the Patrol CLI:

```bash
patrol test --target integration_test/auth/sign_in_test.dart
```
