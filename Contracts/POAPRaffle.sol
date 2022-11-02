// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IPOAP.sol";
import "hardhat/console.sol";

//This function instantiates the contract and
//classifies ERC721 for storage schema
contract POAPRaffle is ERC721, Ownable {
    //to keep track of the total number of NFTs minted
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;
    IPOAP public poap;

    string public baseTokenURI;
    uint public lastRaffleCount;

    //sets contract's name and symbol
    constructor(address _poap) ERC721("POAPRaffle", "PRFL") {
        poap = IPOAP(_poap);
        baseTokenURI = "https://assets.poap.xyz/";
    }

    struct Raffle {
        uint raffleNum;
        uint eventNum;
        uint winnersNum;
        uint expiry;
        address[] participants;
        address[] winners;
        bool hasWinners;
        string tokenURI;
    }

    mapping(uint => Raffle) public raffles;

    function createRaffle(
        uint _eventNum,
        uint _winnersNum,
        uint _expiry,
        address[] memory _participants,
        string memory _tokenURI
    ) external onlyOwner returns (uint) {
        require(
            _expiry >= block.timestamp,
            "raffle should be happening in the future"
        );
        require(
            _winnersNum < _participants.length,
            "the number of winners must be lower than that of participants"
        );

        uint raffleCount = lastRaffleCount += 1;
        Raffle storage raffle = raffles[raffleCount];

        raffle.raffleNum = raffleCount;
        raffle.eventNum = _eventNum;
        raffle.winnersNum = _winnersNum;
        raffle.expiry = _expiry;
        raffle.participants = _participants;
        raffle.hasWinners = false;
        raffle.tokenURI = _tokenURI;

        lastRaffleCount = raffleCount;
        return raffle.raffleNum;
    }

    function pickAndMint(uint _raffleNum) public onlyOwner {
        Raffle memory raffle = raffles[_raffleNum];
        require(!raffle.hasWinners, "raffle only can happen once");
        require(
            block.timestamp >= raffle.expiry,
            "waiting time isn't over yet"
        );
        address lastWinner;
        address winner;
        uint index;

        address[] memory participants = raffle.participants;
        for (uint i = 0; i < raffle.winnersNum; i++) {
            (winner, index) = _pickWinners(
                participants.length, // 3
                participants // 3 addr
            );

            if (winner == lastWinner) {
                winner = index == (participants.length - 1)
                    ? participants[index - 1]
                    : participants[index + 1];
            }

            require(
                verifyPOAPOwnership(winner, raffle.eventNum),
                "address didn't join the event"
            );

            _mintNFT(winner);
            raffles[_raffleNum].winners.push(winner);
            lastWinner = winner;
        }

        raffles[_raffleNum].hasWinners = true;
    }

    function _pickWinners(uint length, address[] memory participants)
        internal
        view
        returns (address, uint)
    {
        uint index = uint8(
            uint(
                keccak256(abi.encodePacked(block.difficulty, block.timestamp))
            ) % length
        );
        address winner = participants[index];
        return (winner, index);
    }

    function verifyPOAPOwnership(address _winner, uint _eventNum)
        internal
        view
        returns (bool)
    {
        uint balance = poap.balanceOf(_winner);
        uint index;
        bool result;

        for (uint j = balance; j >= 0; j--) {
            index = j -= 1;
            (, uint eventId) = poap.tokenDetailsOfOwnerByIndex(_winner, index);
            result = eventId == _eventNum ? true : false;
            if (result) return result;
        }
        return false;
    }

    function _mintNFT(address recipient) internal returns (uint256) {
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseTokenURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function getRaffle(uint _raffleCount) public view returns (Raffle memory) {
        return raffles[_raffleCount];
    }

    function getWinners(uint _raffleCount)
        public
        view
        returns (address[] memory)
    {
        return raffles[_raffleCount].winners;
    }

    function getNFTImage(uint _raffleCount)
        public
        view
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(baseTokenURI, raffles[_raffleCount].tokenURI)
            );
    }
}
