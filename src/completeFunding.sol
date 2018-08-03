pragma solidity ^0.4.17;

//创建智能合约工厂,利用智能合约来创建智能合约,将创建人的地址往真正需要创建的合约里面传递
contract FundingFactory{
    //创建数组存放创建出来的智能合约地址
    address [] public  contractAddress;
    //创建智能合约,传递众筹智能合约需要的参数
    function deploy (string _projectName,uint _supportMoney,uint _goalMoney)public {
        address funding = new Funding(_projectName,_supportMoney,_goalMoney,msg.sender);
        //将创建出来的智能合约的地址存入数据里面
        contractAddress.push(funding);
    }
}

contract Funding{
    //定义智能合约的成员变量
    address public manager;
    //每个用户需要投入的钱
    uint public supportMoney;
    //此众筹项目目标募集金额
    uint public goalMoney;
    //存放用户地址
    address[] public players;
    //定义众筹项目名
    string public projectName;
    //定义众筹项目最终截止时间
    uint public endTime;
    //存放资金申请的记录
    Request[]public requests;
    //此map用来存放当前用户对资金流向的投票结果
    mapping(address=>bool) public  playerMap;
//创建用于用户投票资金流向的结构体
    struct Request {
        //众筹发起人对此次资金申请的描述
        string discription;
        //此次用途会使用的金额
        uint money ;
        // 此次资金流向地址
        address shopAddress;
        //是否此次申请的资金已经被发起人使用
        bool complete;
        //投票表决ok的人数
        uint voteCount;
        // map存放表决ok人的地址和表决结果
        mapping(address=>bool) vorteMap;

    }
    function refund ()public {
        
    }
    //用户对众筹发起人的资金申请进行表决
    function approveRequest(uint index) public  {
        Request storage request = requests[index];
        //使用map的数据结构使得手续费大大减少
        //如果此用户未参加此次众筹则抛出异常
        require(playerMap[msg.sender]);
        //如果此用户已经投票了则抛出异常
        require(!request.vorteMap[msg.sender]);
        // 如果满足以上条件满足,则投票成功,总投票人数增加1
        request.voteCount++;
        //把投票成功的结果和用户地址存入map
        request.vorteMap[msg.sender]=true;

    }
    //众筹发起人申请一笔资金用于干某事
    function createRequest(string _discription,uint _money,address _shopAddress) public onlyManagetCanCall {
        //将众筹发起人的资金申请的完整信息初始化
        Request memory request = Request({
            discription:_discription,
            money:_money,
            shopAddress:_shopAddress,
            complete:false,
            voteCount:0
            });
        //将此次的资金申请明细加入到申请数组里
        requests.push(request);
    }
    //众筹发起人使用对应index的申请资金给目标地址(商店)
    function finalizeRequest (uint index) public onlyManagetCanCall{
        //需要对应index的申请的资金处于未被使用状态
        require(!requests[index].complete);
        //需要总投票人数大于总人数的50%
        require(requests[index].voteCount*2>players.length);
        //需要对应index的申请资金大于合约账户内的总资金
        require(this.balance>requests[index].money);
        //对目标账户进行转账,消耗的手续费由合约创建人支付
        requests[index].shopAddress.transfer(requests[index].money);
        //将对应index的申请的资金使用情况变更为已使用
        requests[index].complete=true;
    }
    //构造函数,创建众筹合约的时候需要传入的参数,如众筹项目名,需要筹得的金额,每用户需要支付多少金额,智能合约创建的人地址
    function Funding(string _projectName,uint _supportMoney,uint _goalMoney,address _address) public {
        manager=_address;
        projectName=_projectName;
        supportMoney=_supportMoney;
        goalMoney=_goalMoney;
        endTime=now + 4 weeks;
    }
    //用户对此次众筹进行支付
    function support()public payable{
        //需要用户支付的钱和合约创建的时需要用户支付的金额保持一致
        require(msg.value==supportMoney);
        //将已支付的用户的地址存入数组
        players.push(msg.sender);
        //存储用户的地址和支付状态
        playerMap[msg.sender]=true;
    }
    //拿到合约账户的总金额
    function getAccountBalance()public view returns(uint){
        return this.balance;
    }
    //拿到总参与人数
    function getPlayersCount ()public view returns(uint){
        return players.length;
    }
    //拿到参与的用户的地址
    function getPlayers()public view returns(address[]){
        return players;
    }
    //拿到众筹完成剩余时间
    function getRemainDays()public view returns(uint){
        return (endTime-now)/60/60/24;
    }
    //权限验证,只有合约创建人才有资格调用的对应的方法
    modifier onlyManagetCanCall(){
        require(msg.sender==manager);
        _;
    }

}