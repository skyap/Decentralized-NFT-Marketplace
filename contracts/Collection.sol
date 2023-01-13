// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Collection is ERC721URIStorage, Ownable{
    using Counters for Counters.Counter;

    Counters.Counter private tokenId;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
    }

    struct ListedToken{
        uint256 tokenId;
        address payable currentOwner;
        uint256 price;
        bool currentlyListed;
    }

    mapping(uint256=>ListedToken) public listedToken;


    function createToken(string memory tokenURI,uint256 _price) public onlyOwner returns (bool) {
        uint256 newTokenId = tokenId.current();
        ListedToken memory _token = ListedToken(
            newTokenId,
            payable(owner()),
            _price,
            true
        );
        _safeMint(owner(),newTokenId);
        _setTokenURI(newTokenId,tokenURI);

        tokenId.increment();
        approve(owner(),newTokenId);
        listedToken[newTokenId] = _token;
        return true;
    }

    function purchaseToken(uint256 _tokenId,address _buyer)public payable onlyOwner returns(bool){
        require(listedToken[_tokenId].currentlyListed,"Token is not for sales");
        uint256 _price = listedToken[_tokenId].price;
        address _seller = listedToken[_tokenId].currentOwner;
        require(msg.value>=_price,"Please submit the asking price");
        // update the details of the token
        listedToken[_tokenId].currentlyListed = false;
        listedToken[_tokenId].currentOwner = payable(_buyer);
        _transfer(_seller,_buyer,_tokenId);
        approve(owner(),_tokenId);

        payable(_seller).transfer(msg.value);

        return true;
    }

    function relistToken(uint256 _tokenId,uint256 _price, address _currentOwner)public onlyOwner returns(bool){
        require(ownerOf(_tokenId) == _currentOwner, "You must be the owner of the token");
        listedToken[_tokenId].currentlyListed = true;
        listedToken[_tokenId].price = _price;
        return true;
    }

}


