//SPDX-License-Identifier: Unlicense
// https://github.com/OE-Heart/Cryptoplat/blob/master/contracts/NFTAuction.sol
pragma solidity ^0.8.8;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface INFTMarketplaceFactory{
    function createCollection(string memory _name,string memory _symbol) external returns (address);
}

interface Collection{
    function mintTo(address recipient) external returns (uint256);
    function createToken(address _to, string memory tokenURI) external returns (uint256);
    function owner() external view returns (address);
}

contract NFTMarketplaceRouter is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private collectionId;
    address public factoryAddress;

    constructor(address _factoryAddress){
        factoryAddress = _factoryAddress;
    }

    struct CollectionInfo{
        address payable collectionCreator;
        address collectionAddress;
        uint256 listingFees;
    } 
    mapping(uint256=>Collection) public collections;
    mapping(address=>uint256[]) public collectionAddressToCollectionId;

    uint256 public minListingFees = 1 ether;

    function createCollection(
        uint256 _listingFees,
        string memory _name,
        string memory _symbol
        )public returns(bool){

        require(_listingFees>=minListingFees,"set higher _listingFees");

        uint256 _collectionId = collectionId.current();        

        address _collectionAddress = INFTMarketplaceFactory(factoryAddress).createCollection(
            _name,
            _symbol
        );
        Collection memory _collection = Collection(
            msg.sender,
            _collectionAddress,
            _listingFees
        );

        collections[_collectionId] = _collection;
        collectionAddressToCollectionId[msg.sender].push(_collectionId);

        collectionId.increment();

        return true;

    }


    function createToken(uint256 _collectionId,uint256 _sellingPrice)public payable returns(bool){

        Collection _collection = Collection(collections[_collectionId].collectionAddress);
        uint256 _sellingPrice = _collection.getUnMintSellingPrice(_unMintId);

        Collection(collections[_collectionId].collectionAddress).createToken(msg.sender);
        
        return true;
    }



}