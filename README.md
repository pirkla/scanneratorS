# Scannerator S
Get the iOS version on the app store: https://apps.apple.com/app/id1522073545     
Get the latest macOS version: https://github.com/pirkla/scannerators/releases   

The User Guide: https://wiki.pirklator.com/en/ScanneratorS/guide

Note: The barcode and qr code scanning function is currently only available for iOS (I'm working on the macOS version, but the camera isn't as good and not using AVFoundation for metadata is difficult)

Scannerator S is an app designed to simplify management of individual devices enrolled in Jamf School. Devices can be searched for using the search bar, or on iOS devices barcodes or qr codes can be scanned to auto-fill the search bar. Only minimal information and actions are currently available, but each devices' entry's device name can be clicked to open the record directly in Jamf School.

## Getting Started
Once the project has been cloned to your machine navigate to the Scannerator project > Signing and Capabilities > Choose a team with a signing certificate. The team doesn't matter, it just needs a certificate to create the local build.
