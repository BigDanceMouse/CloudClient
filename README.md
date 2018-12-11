# CloudClient
Unofficial framework for access to mail.ru cloud storage

## Install
### CocoaPods
```
pod 'CloudClient', :git => 'https://github.com/BigDanceMouse/CloudClient.git'
```
### Carthage
```
github "BigDanceMouse/CloudClient"
```

## Usage
```
CloudClient.prepare()
if !CloudClient.isAuthorized {
    /// getting login and pass and making authorization
    if CloudClient.authorize(login: email, password: pass) {
        getRootFolder()
    }
} else {
    getRootFolder()
}

func getRootFolder() {
    /// Get user's root folder
    if let rootFolder = CloudClient.getRootFolder() {
        /// presenting for user root folder
    }
}
```
