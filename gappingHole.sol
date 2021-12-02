pragma solidity >=0.4.22 <0.6.0;
contract Kickstarter {
    enum State { Started, Completed }

    struct Project {
        address owner;
        string name;
        uint goal;
        uint fundsAvailable; // added
        uint amountContributed; // added
        State state;
        mapping(address => uint) funders; // added
    }

    Project[] public projects;

    constructor() public {
    }
    function createProject(string memory name, uint goal) public {
        projects.length++; 
        Project storage project = projects[projects.length - 1];
        project.name = name;
        project.goal = goal;
        project.owner = msg.sender;
        project.state = State.Started;
    }
    
    // a payable function for adding funds to a project
    function fundProject(uint projectId) payable public {
        Project storage project = projects[projectId];
        project.funders[msg.sender] += msg.value;
        project.amountContributed += msg.value;
        project.fundsAvailable += msg.value;

        if (project.amountContributed >= project.goal) {
            project.state = State.Completed;
        }
    }
    
    // this function is here because we can't use web3 when using the JSVM
    function getContractBalance() public view returns(uint balance){
        return address(this).balance;
    }
    // this function has a major security hole.
    function withdraw(uint projectId, uint amountToWithdraw) public {
        Project storage project = projects[projectId];
        require(msg.sender == project.owner);
        require(project.amountContributed >= project.goal);

        project.fundsAvailable -= amountToWithdraw;
        
        // for demo purposes ONLY - do not send funds like this...
        msg.sender.send(amountToWithdraw);
    }
}
