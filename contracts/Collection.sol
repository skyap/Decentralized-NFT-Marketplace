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


    function createToken(string memory tokenURI,uint256 _price) public onlyOwner returns (uint256) {
        uint256 newTokenId = tokenId.current();
        ListedToken _token = ListedToken(
            newTokenId,
            owner(),
            _price,
            true
        );
        _safeMint(owner(),newTokenId);
        _setTokenURI(newTokenId,tokenURI);

        tokenId.increment();
        approve(owner(),newTokenId);
        return newTokenId;
    }

    function sellToken(uint256 _tokenId)public payable{
        uint256 _price = listedToken[_tokenId].price;
        address _seller = listedToken[_tokenId].currentOwner;
        require(msg.value>=_price,"Please submit the asking price");
        // update the details of the token
        listedToken[_tokenId].currentlyListed = false;
        listedToken[_tokenId].currentOwner = payable(msg.sender);
        _transfer(_seller,msg.sender,_tokenId);
        payable(_seller).transfer(msg.value);
    }

}


