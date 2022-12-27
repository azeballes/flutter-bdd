Feature: Counter
    
    Scenario: Show initial counter value
        Given counter value is {10}
        Given the app is running
        Then I see {10} value

    Scenario: Tap add button
        Given counter value is {5}
        Given the app is running
        When tap add button
        Then I see {6} value