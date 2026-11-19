# Math Time

Math Time is a native iOS math practice app built with SwiftUI. It helps children practice arithmetic with vertical equations, a touch drawing canvas, and simple answer entry.

## Features

- Addition, subtraction, multiplication, and division practice, individually or in combined modes.
- Separate 1–4 digit settings for the first and second numbers.
- Division problems displayed with a long-division bracket; answers are entered as quotient and remainder (for example, `3R1`).
- A full-screen canvas for drawing and working through a problem.
- A multiplication table activity with ten answer fields for a selected number from 1 to 10.
- Settings are saved between app launches.
- Confirmation before skipping a question that has not been answered correctly.

## Requirements

- macOS with Xcode installed, including the iOS SDK and an iOS Simulator runtime.
- VS Code is optional; the project can also be opened and run in Xcode.

## Build and run from VS Code

Open this repository folder in VS Code and use its integrated terminal.

1. List available simulator devices and runtimes:

   ```sh
   xcrun simctl list devices available
   xcrun simctl list runtimes
   ```

2. Open Simulator and boot an available iPhone simulator. Replace the device name if needed:

   ```sh
   open -a Simulator
   xcrun simctl boot "iPhone 18 Pro"
   ```

   If the simulator is already booted, you can skip the `boot` command.

3. Build the app for the simulator:

   ```sh
   xcodebuild build \
     -project MathApp.xcodeproj \
     -scheme MathApp \
     -destination 'platform=iOS Simulator,name=iPhone 18 Pro,OS=27.2' \
     -derivedDataPath .build \
     CODE_SIGNING_ALLOWED=NO
   ```

4. Install and launch the app:

   ```sh
   xcrun simctl install booted .build/Build/Products/Debug-iphonesimulator/MathApp.app
   xcrun simctl launch booted com.stevechui.MathApp
   ```

Use the simulator name and iOS version shown on your Mac if they differ from the example destination above.

## Build in Xcode

Open `MathApp.xcodeproj`, select the `MathApp` scheme and an iOS Simulator destination, then choose **Run**.
