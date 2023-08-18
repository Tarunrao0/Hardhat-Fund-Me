//Get funds from users
//Withdraw functionality
//Set minimum fund value
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe{

    using PriceConverter for uint256;
    address[] public s_funders;
    mapping(address=>uint256) public s_addressToAmountFunded;

    uint256 public constant MINIMUM_USD = 50*1e18; //minimum amount set
    address public immutable i_owner;

   AggregatorV3Interface public s_priceFeed;

    constructor(address priceFeedAddress){
        s_priceFeed= AggregatorV3Interface(priceFeedAddress);
        i_owner=msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed ) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public {
        for(uint256 funderIndex=0; funderIndex< s_funders.length; funderIndex++){
            address funder= s_funders[funderIndex];
            s_addressToAmountFunded[funder]=0;
        }
    
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}('');
        require(callSuccess, "Call Failed");
    }

    modifier OnlyOwner{
        //require(msg.sender==i_owner, "Access denied!");
        if (msg.sender!= i_owner){
            revert FundMe__NotOwner();
        }
        _;
    }

}