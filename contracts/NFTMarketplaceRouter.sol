//SPDX-License-Identifier: Unlicense
// https://github.com/OE-Heart/Cryptoplat/blob/master/contracts/NFTAuction.sol
pragma solidity ^0.8.8;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface INFTMarketplaceFactory{
    function createCollection(string memory _name,string memory _symbol) external returns (address);
}

interface Collection{
    function createToken(string memory _tokenURI,uint256 _price) external returns (bool);
    function purchaseToken(uint256 _tokenId,address _buyer)external payable returns(bool);
    function relistToken(uint256 _tokenId,uint256 _price, address _currentOwner)external returns(bool);
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
    mapping(uint256=>CollectionInfo) public collections;
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
        CollectionInfo memory _collection = CollectionInfo(
            payable(msg.sender),
            _collectionAddress,
            _listingFees
        );

        collections[_collectionId] = _collection;
        collectionAddressToCollectionId[msg.sender].push(_collectionId);

        collectionId.increment();

        return true;

    }


    function createToken(uint256 _collectionId,string memory _tokenURI,uint256 _price)public payable returns(bool){


        try Collection(collections[_collectionId].collectionAddress).createToken(_tokenURI,_price){
            return true;
        }catch{
            return false;
        }
        
    }

    function purchaseToken(uint256 _collectionId,uint256 _tokenId)public payable returns(bool){

        try Collection(collections[_collectionId].collectionAddress).purchaseToken(_tokenId,msg.sender){
            return true;
        }catch{
            return false;
        }
    }

    function relistToken(uint256 _collectionId,uint256 _tokenId,uint256 _price)public returns(bool){
        try Collection(collections[_collectionId].collectionAddress).relistToken( _tokenId, _price, msg.sender){
            return true;
        }catch{
            return false;
        }
    }



}