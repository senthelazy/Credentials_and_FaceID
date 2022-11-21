# Credentials_and_FaceID
iOS FaceID/TouchID Auth and store credentials in KeyChain for FaceID/TouchID Auth in Objective C

1,Provided addCredentials for storing credentials(username & password) to keychain for Face ID or Touch ID.

2,Provided deleteCredentials for removing credentials(username & password) to keychain for Face ID or Touch ID (use when "addCredentials" report  errSecDuplicateItem -25299, means credentials alreay in keychain), then addCredentials again or use the existing credentials(readCredentials).

3,Provided readCredentials, get the credentials from Keychain.

4,verifyFaceID, check if the biometry matched, if matched,get the credentials from keychain.

5,remember to add Privacy - Face ID Usage Description to info.pilst

 Happy coding.
