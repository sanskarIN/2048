# Privacy

2048 Nova is designed as an offline-first game. The default codebase does not add analytics, advertising trackers, accounts, cloud synchronization, or background telemetry.

Game state, settings, statistics, and achievements are stored locally through Flutter's SharedPreferences abstraction. External destinations such as GitHub, LinkedIn, email, and Buy Me a Coffee require network or platform handlers only when opened by the user.
