param(
  [ValidateSet('apk', 'appbundle')]
  [string]$Target = 'apk'
)

$debugInfoDir = 'build/obfuscation/symbols'
New-Item -ItemType Directory -Force $debugInfoDir | Out-Null

flutter build $Target --release --obfuscate --split-debug-info=$debugInfoDir
