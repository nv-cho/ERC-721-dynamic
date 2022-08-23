// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Universe is ERC721, ERC721URIStorage, KeeperCompatibleInterface {
    using Counters for Counters.Counter;

    Counters.Counter private tokenIdCounter;

    string[] s_URIs;
    
    uint size;
    uint lastTimeStamp;
    uint interval;

    constructor(uint _interval, string[] memory _URIs, uint _size) ERC721("Universe", "STR") {
        lastTimeStamp = block.timestamp;
        interval = _interval;
        s_URIs = _URIs;
        size = _size;
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        uint256 tokenId = tokenIdCounter.current() - 1;
        
        bool done;

        if (galaxyStage(tokenId) >= 2) {
            done = true;
        }

        upkeepNeeded = !done && ((block.timestamp - lastTimeStamp) > interval);        
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;            
            
            uint256 tokenId = tokenIdCounter.current() - 1;
            
            growGalaxy(tokenId);
        }
    }

    function safeMint(address to) public {
        uint256 tokenId = tokenIdCounter.current();

        tokenIdCounter.increment();
        
        _safeMint(to, tokenId);
        
        _setTokenURI(tokenId, s_URIs[0]);
    }

    function growGalaxy(uint256 _tokenId) public {
        if(galaxyStage(_tokenId) >= size){return;}

        uint256 newVal = galaxyStage(_tokenId) + 1;

        string memory newUri = s_URIs[newVal];
        
        _setTokenURI(_tokenId, newUri);
    }

    function galaxyStage(uint256 _tokenId) public view returns (uint256) {
        string memory _uri = tokenURI(_tokenId);

        for(uint8 i = 0; i < size; i++){
            if(compareStrings(_uri, s_URIs[i])){
                return i;
            }
        }
    }

    function compareStrings(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}