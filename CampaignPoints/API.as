namespace API {

    void GetCurrentCampaignRanks() {
        if (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
            return;
        }

        auto reqCampaign = NadeoServices::Get("NadeoLiveServices", NadeoServices::BaseURLLive()+"/api/token/campaign/official?length=1&offset=0");
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
            string mapUid = map["mapUid"];
            int rank = GetRank(currentCampaignGroupId, mapUid);
            int index = map["position"];
            if (rank > 0 && index >= 0 && index < inputRanks.Length) {
                inputRanks[index] = rank;
            }
        }
    }

    int GetRank(string groupUid, string mapUid) {
        string reqRanksUrl = NadeoServices::BaseURLLive()+"/api/token/leaderboard/group/"+groupUid+"/map/"+mapUid+"?accountId="+NadeoServices::GetAccountID();
        auto reqRanks = NadeoServices::Get("NadeoLiveServices", reqRanksUrl);
        reqRanks.Start();
        while (!reqRanks.Finished()) {
            yield();
        }
        auto resRanks = Json::Parse(reqRanks.String());
        auto zones = resRanks["zones"];
        for (int i = 0; i < zones.Length; ++i) {
            auto zone = zones[i];
            if (zone["zoneName"] == "World") {
                return zone["ranking"]["position"];
            }
        }
        return -1;
    }

}