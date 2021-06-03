// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Burnable.sol";


contract TToken is ERC20Burnable {
    uint256 public constant CAP = 720000000 ether;
    
    uint256 public STARTDATE;
    uint256 public constant LIMITPERMILLION = 4838902;
    uint256 public CURRENTMINTRATEPERMILLION = 1000000;
    uint256 public LASTMINTEDYEAR;
    uint256 public constant BURNRATE = 20;
    uint256 public constant ONEYEAR = 1 minutes;
    
    uint256[22] MINTRATES = [1000000,1606000,2070000,2451000,2771000,3045000,3281000,3485000,3661000,3814000,3947000,4063000,4163000,4251000,4327000,4393000,4451000,4501000,4545000,4583000,4616000,4645000];
    
    constructor () ERC20("TToken", "TTO") {
        STARTDATE = block.timestamp;
        _mint(msg.sender, 148000000 ether); // Genesis mint
    }
    
    
    function calculateMintAmount() internal returns (uint256){
        uint256 elapsed_year = (block.timestamp - STARTDATE) / ONEYEAR;
        
        CURRENTMINTRATEPERMILLION = MINTRATES[elapsed_year];
        uint256 remaining_mint = CAP - totalSupply();
        uint256 mint_amount = remaining_mint * CURRENTMINTRATEPERMILLION / LIMITPERMILLION;
        return mint_amount;
    }
    
    function mint(address account, uint256 amount) internal {
        uint256 elapsed_year = (block.timestamp - STARTDATE) / ONEYEAR;
        require(elapsed_year < 20, "This system is obsolate after 20 years !");
        require(elapsed_year > LASTMINTEDYEAR, "ALREADY MINTED !");
        
        _mint(account, amount);
        LASTMINTEDYEAR = elapsed_year;
    }
    function debugElapsedYear() public view  returns (uint256){
        return (block.timestamp - STARTDATE) / ONEYEAR;
    }
    
    function calculateBurnAmount() internal view returns (uint256) {
        uint256 burn_amount = totalSupply() * BURNRATE / 100;
        return burn_amount;
    }
    
    function passInflationPeriod () public {
        uint256 burn_amount = calculateBurnAmount();
        
        uint256 mint_amount = calculateMintAmount();
        require(mint_amount + totalSupply() < CAP, "TOTAL CAP IS REACHED !");
        
        burn(burn_amount);
        mint(msg.sender, mint_amount);
    }
}
