// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bet{
    address public owner;
    uint256 public constant betAmount = 2 ether;
    address[] public players;
    mapping(address => bool) public hasBet;

    event BetPlaced(address indexed playe, uint256 amount);
    event WinnerChosen(address indexed winner, uint256 amount);

    constructor(){
        owner  = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender==owner,"Only owner can call this function");
        _;
    }

    function placeBet() public payable{
        require(msg.value == betAmount, "Bet amount must be 2 ETH.");
        require(!hasBet[msg.sender], "The player with this address has already placed a bet.");
        
        players.push(msg.sender);
        hasBet[msg.sender] = true;

        emit BetPlaced(msg.sender,msg.value);
    }

    function pickWinner() public onlyOwner{
        require(players.length > 0, "No players have placed bets.");

        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, players))) % players.length;
        address winner = players[randomIndex];

        uint256 prizeAmount=address(this).balance;
        payable(winner).transfer(prizeAmount);

        emit WinnerChosen(winner, prizeAmount);

        for (uint256 i = 0; i < players.length;i++){
            hasBet[players[i]] = false;
        }
        delete players;
    }

    function getPool() public view returns (uint256){
        return address(this).balance;
    }

    function getPlayers() public view returns (address[] memory){
        return players;
    }
}

