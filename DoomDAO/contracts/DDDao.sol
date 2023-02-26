// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DoomsdayDAO is ERC721, Ownable {
    using Counters for Counters.Counter;

    // Define the key roles
    enum KeyRole {
        EmergencyServices,
        SearchAndRescue,
        EngineeringAndConstruction,
        LogisticsAndSupplyChainManagement,
        CommunicationAndInformationTechnology,
        SecurityAndLawEnforcement,
        PsychologicalSupportAndCounseling,
        SocialAndCommunityServices
    }

    // Define the NFT structure
    struct NFT {
        uint256 id;
        address owner;
        KeyRole keyRole;
    }

    // Mapping to store NFTs
    mapping (uint256 => NFT) public nfts;
    uint256 public totalSupply;
    uint256 public constant MAX_NFTS = 100;
    uint256 public constant MIN_MINTING_PRICE = 0.1 ether;
    uint256 public constant MAX_MINTING_PRICE = 1 ether;
    uint256 public mintingPrice = 0.1 ether;
    address payable public daoWallet;

    // Event to track minting of NFTs
    event NFTMinted(address owner, uint256 tokenId, KeyRole keyRole);

    // Constructor to set name and symbol
    constructor() ERC721("DoomsdayDAO", "DDAO") {
        daoWallet = payable(msg.sender);
    }

    function mintNFT(address to, KeyRole keyRole) external payable {
        require(totalSupply < MAX_NFTS, "Maximum NFT limit reached");
        require(msg.value >= mintingPrice, "Insufficient payment");
        uint256 tokenId = totalSupply + 1;
        _safeMint(to, tokenId);
        nfts[tokenId] = NFT(tokenId, to, keyRole);
        totalSupply += 1;
        emit NFTMinted(to, tokenId, keyRole);
        daoWallet.transfer(msg.value);
    }

    function setMintingPrice(uint256 price) external onlyOwner {
        require(price >= MIN_MINTING_PRICE && price <= MAX_MINTING_PRICE, "Invalid price");
        mintingPrice = price;
    }

    function setDaoWallet(address payable wallet) external onlyOwner {
        daoWallet = wallet;
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        daoWallet.transfer(balance);
    }
}
