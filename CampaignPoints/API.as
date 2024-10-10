
namespace API {
    string regionInput = "";  // String variable to store the user-inputted region
    bool showRegionPopup = false;  // Flag to control when the popup should appear

    // Function to call when "Set all to official campaign" is clicked
    void GetCurrentCampaignRanks() {
        // Trigger the popup to get the region input
        showRegionPopup = true;
    }

    // Function to run after the region is inputted
    void FetchCampaignRanksWithRegion() {
        if (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
            return;
        }

        auto reqCampaign = NadeoServices::Get("NadeoLiveServices", NadeoServices::BaseURLLive() + "/api/token/campaign/official?length=1&offset=0");
        reqCampaign.Start();
        while (!reqCampaign.Finished()) {
            yield();
        }
        auto resCampaign = Json::Parse(reqCampaign.String());
        auto currentCampaign = resCampaign["campaignList"][0];
        string currentCampaignGroupId = currentCampaign["leaderboardGroupUid"];
        auto mapList = currentCampaign["playlist"];
        for (int i = 0; i < mapList.Length; ++i) {
            auto map = mapList[i];
            int index = map["position"];
            if (index < 0 || index >= inputRanks.Length) {
                continue;
            }
            string mapUid = map["mapUid"];
            int rank = GetRank(currentCampaignGroupId, mapUid, regionInput);  // Use the inputted region
            inputRanks[index] = rank;
        }
        loadingTimes = false;
    }

    // Modified GetRank function to include the region parameter
    int GetRank(string groupUid, string mapUid, string region) {
        if(region=="") {
            region = "World";
        }
        string reqRanksUrl = NadeoServices::BaseURLLive() + "/api/token/leaderboard/group/" + groupUid + "/map/" + mapUid + "?accountId=" + NadeoServices::GetAccountID();
        auto reqRanks = NadeoServices::Get("NadeoLiveServices", reqRanksUrl);
        reqRanks.Start();
        while (!reqRanks.Finished()) {
            yield();
        }

        auto resRanks = Json::Parse(reqRanks.String());
        if (!resRanks.HasKey("zones")) {
            // No rank for this map.
            return 0;
        }

        auto zones = resRanks["zones"];
        for (int i = 0; i < zones.Length; ++i) {
            auto zone = zones[i];
            if (zone["zoneName"] == region) {
                return zone["ranking"]["position"];
            }
        }
        return 0;
    }
}

