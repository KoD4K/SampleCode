// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
	func buildLane() {
        desc("Build for testing")
        scan(
            derivedDataPath: "derivedData",
            buildForTesting: .userDefined(true)
        )
	}

    func startUnitTestsLane() {
        desc("Run unit tests")
        scan(
            onlyTesting: "SampleCodeUnitTests",
            derivedDataPath: "derivedData",
            testWithoutBuilding: .userDefined(true)
        )
    }

    func startUITestsLane() {
        desc("Run UI tests")
        scan(
            onlyTesting: "SampleCodeUITests",
            derivedDataPath: "derivedData",
            testWithoutBuilding: .userDefined(true)
        )
    }
}
