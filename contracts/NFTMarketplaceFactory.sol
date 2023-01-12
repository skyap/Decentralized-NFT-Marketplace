//SPDX-License-Identifier: Unlicense
// https://github.com/OE-Heart/Cryptoplat/blob/master/contracts/NFTAuction.sol
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Collection.sol";

contract NFTMarketplaceFactory is Ownable{


    constructor(){
    }

    event CollectionCreationSuccess(
        address collectionCreator,
        address collection
    );

    

    function createCollection(
        string memory _name,
        string memory _symbol
        ) public returns (address){

            
            Collection _collectionAddress = new Collection(              
                _name,
                _symbol
            );


        emit CollectionCreationSuccess(msg.sender,address(_collectionAddress));
        return address(_collectionAddress);
    }




}