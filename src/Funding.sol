pragma solidity ^0.4.17;

contract Funding{
    address public manager;
    uint public supportMoney;
    uint public goalMoney;
    address[] public players;
    string public projectName;
    uint public endTime;
    Request[]public requests;

    struct Request {
        string discription;
        uint money ;
        address shopAddress;
        bool complete;
        uint voteCount;
        address[]  voteAddresss;

    }
    function approveRequest(uint index) public  {
        Request storage request = requests[index];
        bool supporter = false;
        for(uint i = 0;i <players.length;i++){
            if(msg.sender==players[i]){
                supporter=true;
            }
        }
        require(supporter);
        bool voted = false;
        for(uint j = 0;j <request.voteAddress.length;i++){
            if(msg.sender==request.voteAddress[j]){
                voted =true;
            }
        }
        require(!voted);
        request.voteCount++;
        request.voteAddress.push(msg.sender);


    }
    function createRequest(string _discription,uint _money,address _shopAddress) public onlyManagetCanCall {
        Request memory request = Request({
            discription:_discription,
            money:_money,
            shopAddress:_shopAddress,
            complete:false,
            voteCount:0,
            voteAddress:new address[](0)
            });
        requests.push(request);
    }
    function Funding(string _projectName,uint _supportMoney,uint _goalMoney) public {
        manager=msg.sender;
        projectName=_projectName;
        supportMoney=_supportMoney;
        goalMoney=_goalMoney;
        endTime=now + 4 weeks;
    }
    function support()public payable{
        require(msg.value==supportMoney);
        players.push(msg.sender);
    }
    function getAccountBalance()public view returns(uint){
        return this.balance;
    }
    function getPlayersCount ()public view returns(uint){
        return players.length;
    }
    function getPlayers()public view returns(address[]){
        return players;
    }
    function getRemainDays()public view returns(uint){
        return (endTime-now)/60/60/24;
    }
    modifier onlyManagetCanCall(){
        require(msg.sender==manager);
        _;
    }

}