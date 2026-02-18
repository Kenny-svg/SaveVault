// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract SavingsVault {

    mapping(address => uint256) private ethBalances;

   
    mapping(address => mapping(address => uint256)) private tokenBalances;

   
    uint256 private locked = 1;
    modifier nonReentrant() {
        require(locked == 1, "REENTRANCY");
        locked = 2;
        _;
        locked = 1;
    }

    event EtherDeposited(address indexed user, uint256 amount);
    event EtherWithdrawn(address indexed user, uint256 amount);

    event TokenDeposited(address indexed user, address indexed token, uint256 amount);
    event TokenWithdrawn(address indexed user, address indexed token, uint256 amount);

 

    function ethBalanceOf(address user) external view returns (uint256) {
        return ethBalances[user];
    }

    function tokenBalanceOf(address user, address token) external view returns (uint256) {
        return tokenBalances[user][token];
    }

 

    function depositEther() external payable {
        require(msg.value > 0, "NO_ETH_SENT");
        ethBalances[msg.sender] += msg.value;
        emit EtherDeposited(msg.sender, msg.value);
    }

   
    function withdrawEther(uint256 amount) external nonReentrant {
        require(amount > 0, "AMOUNT_ZERO");
        uint256 bal = ethBalances[msg.sender];
        require(bal >= amount, "INSUFFICIENT_ETH");

   
        ethBalances[msg.sender] = bal - amount;


        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "ETH_TRANSFER_FAILED");

        emit EtherWithdrawn(msg.sender, amount);
    }

 
    function depositToken(address token, uint256 amount) external {
        require(token != address(0), "TOKEN_ZERO");
        require(amount > 0, "AMOUNT_ZERO");

        bool ok = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(ok, "TRANSFERFROM_FAILED");

        tokenBalances[msg.sender][token] += amount;
        emit TokenDeposited(msg.sender, token, amount);
    }


    function withdrawToken(address token, uint256 amount) external nonReentrant {
        require(token != address(0), "TOKEN_ZERO");
        require(amount > 0, "AMOUNT_ZERO");

        uint256 bal = tokenBalances[msg.sender][token];
        require(bal >= amount, "INSUFFICIENT_TOKEN");

        
        tokenBalances[msg.sender][token] = bal - amount;

 
        bool ok = IERC20(token).transfer(msg.sender, amount);
        require(ok, "TRANSFER_FAILED");

        emit TokenWithdrawn(msg.sender, token, amount);
    }

    receive() external payable {
        ethBalances[msg.sender] += msg.value;
        emit EtherDeposited(msg.sender, msg.value);
    }
}
