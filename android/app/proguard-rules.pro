# 2048 Nova Android release rules.
#
# Flutter and the Android plugins used by this project publish the keep rules
# they require. Keep this file intentionally narrow so R8 can remove unused
# Android resources and bytecode while still giving the project a dedicated
# place for future app-specific rules.
#
# Do not add broad rules such as `-keep class ** { *; }`; those disable most of
# the release shrinking that this project explicitly qualifies in CI.
