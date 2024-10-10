void Main() {
    print("Hello there!");
}

const string WindowTitle = "Campaign Points Calculator";
string resultText = "Result: ";
bool loadingTimes = false;
array<int> inputRanks(25, 1);
array<string> testStrArr(25, "Points:");
array<string> mapTexts = {
    "Map 1 Rank", "Map 2 Rank", "Map 3 Rank", "Map 4 Rank", "Map 5 Rank",
    "Map 6 Rank", "Map 7 Rank", "Map 8 Rank", "Map 9 Rank", "Map 10 Rank",
    "Map 11 Rank", "Map 12 Rank", "Map 13 Rank", "Map 14 Rank", "Map 15 Rank",
    "Map 16 Rank", "Map 17 Rank", "Map 18 Rank", "Map 19 Rank", "Map 20 Rank",
    "Map 21 Rank", "Map 22 Rank", "Map 23 Rank", "Map 24 Rank", "Map 25 Rank"
};

array<int> mapPoints(25, 0);

[Setting hidden]
bool ShowWindow = true;

void RenderMenu() {
    if (UI::MenuItem(WindowTitle, "", ShowWindow)) {
        ShowWindow = !ShowWindow;
    }
}

// Variables for the Set Above and Official Campaign Popups
bool showSetAbovePopup = false;  // Flag for the "Set All Above X to X" popup
int setAboveValue = 0;  // Value entered in the popup
array<int> backupRanks(25, 1);  // Array to store the previous state for undo functionality
bool zerowarning = false;

bool showOfficialCampaignPopup = false;  // Flag for the "Set all to official campaign" popup

// Renders the "Set All Above X" popup
void RenderSetAbovePopup() {
    if (showSetAbovePopup) {
        UI::OpenPopup("Set All Above X");  // Open the popup
        showSetAbovePopup = false;  // Reset the flag
    }

    if (UI::BeginPopup("Set All Above X")) {
        string texttoshow = "Enter the threshold value to set all ranks above:";
        if (zerowarning) {
            texttoshow = "Enter the threshold value to set all ranks above (can't be 0):";
        }
        UI::Text(texttoshow);
        UI::SetNextItemWidth(150);
        setAboveValue = UI::InputInt("Threshold", setAboveValue, 0);  // Input field for the threshold value

        if (UI::Button("Set")) {
            if (setAboveValue == 0) {
                zerowarning = true;
            } else {
                SetValuesAboveThresholdWithUndo(setAboveValue);  // Call the function with undo support
                UI::CloseCurrentPopup();  // Close the popup
            }
        }

        UI::SameLine();

        if (UI::Button("Cancel")) {
            UI::CloseCurrentPopup();  // Close without doing anything
        }
        UI::EndPopup();
    }
}

// Renders the "Set all to official campaign" popup
void RenderOfficialCampaignPopup() {
    if (showOfficialCampaignPopup) {
        UI::OpenPopup("Set All to Official Campaign");  // Open the popup
        showOfficialCampaignPopup = false;  // Reset the flag
    }

    if (UI::BeginPopup("Set All to Official Campaign")) {
        UI::Text("Enter the Region to use for fetching official campaign ranks (leave blank for World, only use regions you are in):");
        UI::SetNextItemWidth(200);  // Set width for input
        API::regionInput = UI::InputText("Region", API::regionInput);  // Input field for region

        if (UI::Button("OK")) {
            startnew(API::FetchCampaignRanksWithRegion);  // Call the function to fetch campaign ranks
            UI::CloseCurrentPopup();  // Close the popup
        }

        UI::SameLine();

        if (UI::Button("Cancel")) {
            UI::CloseCurrentPopup();  // Close without doing anything
            loadingTimes = false;
        }
        UI::EndPopup();
    }
}

// Sets values above a certain threshold and stores the previous state for undo
void SetValuesAboveThresholdWithUndo(int threshold) {
    // Create a backup of the current ranks before making changes
    for (int i = 0; i < inputRanks.Length; i++) {
        backupRanks[i] = inputRanks[i];
    }

    // Set all values above the threshold to the threshold value
    for (int i = 0; i < inputRanks.Length; i++) {
        if (inputRanks[i] > threshold) {
            inputRanks[i] = threshold;
            mapPoints[i] = CalculateResult(inputRanks[i]);
        }
    }

    CalculateTotalPoints();  // Recalculate the total points
}

// Undo function to revert ranks to the previous state
void UndoLastSetAbove() {
    // Restore the ranks from the backup array
    for (int i = 0; i < inputRanks.Length; i++) {
        inputRanks[i] = backupRanks[i];
        mapPoints[i] = CalculateResult(inputRanks[i]);
    }

    CalculateTotalPoints();  // Recalculate the total points
}

// Renders the main UI with new buttons and popup triggers
void RenderInterface() {
    if (!ShowWindow) return;
    if (UI::Begin(WindowTitle, ShowWindow, UI::WindowFlags::NoCollapse | UI::WindowFlags::NoResize)) {
        UI::SetWindowSize(vec2(380, 900));

        for (int i = 0; i < inputRanks.Length; i++) {
            int mapNum = i + 1;
            UI::Text(mapTexts[i] + ":");
            UI::SameLine();
            UI::SetNextItemWidth(65);
            inputRanks[i] = UI::InputInt("Map " + mapNum + " Points:", inputRanks[i], 0);  // Input rank values for each map
            if (inputRanks[i] > 0) {
                mapPoints[i] = CalculateResult(inputRanks[i]);
            } else {
                mapPoints[i] = 0;
            }
            UI::SameLine();
            UI::Text(mapPoints[i] + "");  // Display points for each map
        }

        CalculateTotalPoints();  // Calculate points for display

        // Display result text or loading status
        if (!loadingTimes) {
            UI::Text(resultText);
        } else {
            UI::Text("Loading ranks...");
        }

        // Buttons for different actions
        if (UI::Button("Set All Above X to X")) {
            showSetAbovePopup = true;  // Trigger the "Set All Above X" popup
        }
        if (UI::Button("Undo Last Set Above")) {
            UndoLastSetAbove();  // Undo the last "Set All Above" operation
        }
        if (UI::Button("Set all to official campaign")) {
            showOfficialCampaignPopup = true;  // Trigger the official campaign popup
        }

        UI::End();
    }

    // Render the popups after the main UI
    RenderSetAbovePopup();
    RenderOfficialCampaignPopup();
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

// Function to calculate the points based on rank
int CalculateResult(int rank) {
    if (rank < 11) {
        return 40000 / rank;
    } else {
        return int((4000 / Math::Pow(2, Math::Ceil(Math::Log(rank) / Math::Log(10)) - 1)) * (Math::Pow(10, Math::Ceil(Math::Log(rank) / Math::Log(10)) - 1) / rank + 0.9));
    }
}
