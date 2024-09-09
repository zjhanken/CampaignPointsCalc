
void Main() {
    print("Hello there!");
}

const string WindowTitle = "Campaign Points Calculator";
string resultText = "Result: ";
array<int> inputRanks(25, 1);
array<string> mapTexts = {
    "Map 1 Rank", "Map 2 Rank", "Map 3 Rank", "Map 4 Rank", "Map 5 Rank", 
    "Map 6 Rank", "Map 7 Rank", "Map 8 Rank", "Map 9 Rank", "Map 10 Rank", 
    "Map 11 Rank", "Map 12 Rank", "Map 13 Rank", "Map 14 Rank", "Map 15 Rank", 
    "Map 16 Rank", "Map 17 Rank", "Map 18 Rank", "Map 19 Rank", "Map 20 Rank",
    "Map 21 Rank", "Map 22 Rank", "Map 23 Rank", "Map 24 Rank", "Map 25 Rank"
};

array<string> BasicMapTexts = {
    "Map 1", "Map 2", "Map 3", "Map 4", "Map 5", 
    "Map 6", "Map 7", "Map 8", "Map 9", "Map 10", 
    "Map 11", "Map 12", "Map 13", "Map 14", "Map 15", 
    "Map 16", "Map 17", "Map 18", "Map 19", "Map 20",
    "Map 21", "Map 22", "Map 23", "Map 24", "Map 25"
};

array<int> mapPoints(25, 0);

[Setting hidden]
bool ShowWindow = true;

void RenderMenu() {
    if (UI::MenuItem(WindowTitle, "", ShowWindow)) {
        ShowWindow = !ShowWindow;
    }
}

void RenderInterface() {
    if (!ShowWindow) return;
    if (UI::Begin(WindowTitle, ShowWindow, UI::WindowFlags::NoCollapse | UI::WindowFlags::NoResize)) {
        
        UI::SetWindowSize(vec2(770, 910)); 

        for (int i = 0; i < inputRanks.Length; i++) {
            int mapNum = i+1;
            UI::Text(mapTexts[i]+":");  // Display the map text
            UI::SameLine(); // Adjust this value to align the input fields properly
            inputRanks[i] = UI::InputInt(BasicMapTexts[i], inputRanks[i]); // Empty label to avoid text duplication
            if (inputRanks[i] > 0) {
                mapPoints[i] = CalculateResult(inputRanks[i]);
            } else {
                mapPoints[i] = 0;
            }
            UI::SameLine(); // Adjust this value to align the points properly
            UI::Text("Points: " + mapPoints[i]);  // Display the points next to the input field
            CalculateTotalPoints();
        }
    }
        // Display result text
        UI::Text(resultText);
        // Buttons to set values above thresholds
        if (UI::Button("Set All Above 1000 to 1000")) {
            SetValuesAboveThreshold(1000);
        }
        if (UI::Button("Set All Above 100 to 100")) {
            SetValuesAboveThreshold(100);
        }
        if (UI::Button("Set All Above 10 to 10")) {
            SetValuesAboveThreshold(10);
        }
    
    
    UI::End();
}

void UpdateMapTexts() {
    for (int i = 0; i < mapTexts.Length; i++) {
        mapTexts[i] = "Map " + (i+1) + " Rank (" + mapPoints[i] + " points)";
    }
}

// Function to calculate total points and update the resultText
void CalculateTotalPoints() {
    int resultSum = 0;
    bool validInput = true;

    for (int i = 0; i < inputRanks.Length; i++) {
        if (inputRanks[i] < 1) {
            validInput = false;
            break;
        }
        resultSum += mapPoints[i];
    }

    if (!validInput) {
        resultText = "Improper number inputted - try again";
    } else {
        resultText = "Total Points: " + resultSum;
    }
}

// Function to set values above a certain threshold and then recalculate the total
void SetValuesAboveThreshold(int threshold) {
    for (int i = 0; i < inputRanks.Length; i++) {
        if (inputRanks[i] > threshold) {
            inputRanks[i] = threshold;
            mapPoints[i] = CalculateResult(inputRanks[i]);
        }
    }  // Update map texts after setting values
    CalculateTotalPoints();  // Recalculate the total points
}

int CalculateResult(int rank) {
    if (rank < 11) {
        return 40000 / rank;
    } else {
        return int((4000 / Math::Pow(2, Math::Ceil(Math::Log(rank) / Math::Log(10)) - 1)) * (Math::Pow(10, Math::Ceil(Math::Log(rank) / Math::Log(10)) - 1) / rank + 0.9));
    }
}
