Feature: Counter
    
    Scenario: Show initial counter value
        Given counter value is {10}
        Given the app is running        
        Then I see {10} value