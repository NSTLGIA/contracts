// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IPOAP.sol";
import "hardhat/console.sol";

// Raffle Contract inherits ERC721
contract POAPRaffle is ERC721, Ownable {
    //to keep track of the total number of NFTs minted
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;

    // poap needs to be called to verify the ownership
    IPOAP public poap;

    string public baseTokenURI;
    uint public lastRaffleCount;

    //sets contract's name and symbol
    constructor(address _poap) ERC721("POAPRaffle", "PRFL") {
        poap = IPOAP(_poap);
        baseTokenURI = "https://assets.poap.xyz/"; // using poap image url just for testing. this could be whatever link
    }

    // Raffle struct that is instanciated for each raffle
    struct Raffle {
        uint raffleNum; // raffle id
        uint eventNum; // poap event number
        uint winnersNum; // the number of winners for each winner
        uint expiry; // timestamp: pickAndWinner function will be unlocked for execution.
        address[] participants; // all poap holders addresses ( should be checked via POAP API)
        address[] winners; // winner addresses
        bool hasWinners; // pickAndWinner function should only get executed once, after that will be locked parmanently
        string tokenURI; // tokenURI for NFTs that are distributed to winners
    }

    mapping(uint => Raffle) public raffles; // raffleNum => Raffle instance

    // after poap is distributed, this function is called to create Raffle
    function createRaffle(
        uint _eventNum,
        uint _winnersNum,
        uint _expiry,
        address[] memory _participants,
        string memory _tokenURI
    ) external onlyOwner returns (uint) {
        // make sure that expiry is set in the future:
        // blcok.timestamp is the current time.
        require(
            _expiry >= block.timestamp,
            "raffle should be happening in the future"
        );
        // checking if the number of winners are lower than that of participants
        require(
            _winnersNum < _participants.length,
            "the number of winners must be lower than that of participants"
        );

        // Raffle id increments every time new Raffle is created
        uint raffleCount = lastRaffleCount += 1;
        Raffle storage raffle = raffles[raffleCount];

        // params are stored into the newly created instance of Raffle struct
        raffle.raffleNum = raffleCount;
        raffle.eventNum = _eventNum;
        raffle.winnersNum = _winnersNum;
        raffle.expiry = _expiry;
        raffle.participants = _participants;
        raffle.hasWinners = false;
        raffle.tokenURI = _tokenURI;

        lastRaffleCount = raffleCount;

        // return raffle number. UI should get and store it to query data for whatever purposes
        return raffle.raffleNum;
    }

    // pickking winners out of participants and distribute newly minted NFTs to them
    // in order for winners to be able to claim rewards such as promo code
    function pickAndMint(uint _raffleNum) public onlyOwner {
        Raffle memory raffle = raffles[_raffleNum];

        // make sure that this function hasn't yet been called before.
        require(!raffle.hasWinners, "raffle only can happen once");
        // make sure that the function has already been unlocked for executing.
        require(
            block.timestamp >= raffle.expiry,
            "waiting time isn't over yet"
        );
        address lastWinner;
        address winner;
        uint index;

        address[] memory participants = raffle.participants;

        // Looping x times to pick winners and mint NFTs
        // x = the number of winners
        for (uint i = 0; i < raffle.winnersNum; i++) {
            (winner, index) = _pickWinners(
                participants.length, // 3
                participants // 3 addr
            );

            // if winner address is the same as winners that has already been picked
            // the next winner will be either the next or previous address in the queue
            // if the winner is in the last in the array, winner will be the previous address
            // otherwise, the next address is the winner.
            if (winner == lastWinner) {
                winner = index == (participants.length - 1)
                    ? participants[index - 1]
                    : participants[index + 1];
            }

            // calling POAP contract through interface
            // check if the poap that the address owns really and its event number match
            require(
                verifyPOAPOwnership(winner, raffle.eventNum),
                "address didn't join the event"
            );

            // mint new NFTs through ERC721 contract imported from openzeppelin template
            _mintNFT(winner);
            // winner addresses are pushed into the winners array
            raffles[_raffleNum].winners.push(winner);
            lastWinner = winner;
        }

        // lock this function forever
        // ! hence, putting wrong parameters should be devastating
        raffles[_raffleNum].hasWinners = true;
    }

    // picking the arbitrary number of winner addresses out of participants
    // by using a random number algorithm
    function _pickWinners(uint length, address[] memory participants)
        internal
        view
        returns (address, uint)
    {
        // random number algorithm
        // its theoritically not impossible to game this algorithm to decide winners
        // hence, some improvements should be implemented ( but using chainlink is costly )
        uint index = uint8(
            uint(
                keccak256(abi.encodePacked(block.difficulty, block.timestamp))
            ) % length
        );
        address winner = participants[index];
        return (winner, index);
    }

    // if the event number of a poap that a winner owns is the same as the eventNum param in Raffle struct
    // it's considered valid.
    function verifyPOAPOwnership(address _winner, uint _eventNum)
        internal
        view
        returns (bool)
    {
        uint balance = poap.balanceOf(_winner);
        uint index;
        bool result;

        // index is the identifier for each poap in a user wallet, which is stored in poap contract.
        // since this fucntion is mostly supposed to be called only a few days/weeks after users claim poap,
        // and it can be presumed that the higher the index is the more recent an address got the poap,
        // j in for loop decsends instead of increasing, which makes it faster to reach and check the poap for an event.
        for (uint j = balance; j >= 0; j--) {
            index = j -= 1;
            (, uint eventId) = poap.tokenDetailsOfOwnerByIndex(_winner, index);
            result = eventId == _eventNum ? true : false;
            if (result) return result;
        }
        return false;
    }

    // calls _safeMint funciton provided by openzeppelin
    function _mintNFT(address recipient) internal returns (uint256) {
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    // baseURI: "https://assets.poap.xyz/" for this test
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    // change baseURI
    function setBaseTokenURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    // Get the object data of Raffle struct
    function getRaffle(uint _raffleNum) public view returns (Raffle memory) {
        return raffles[_raffleNum];
    }

    // get the winners' addresses of given raffle
    function getWinners(uint _raffleNum)
        public
        view
        returns (address[] memory)
    {
        return raffles[_raffleNum].winners;
    }

    // get the NFT image of a given raffle
    function getNFTImage(uint _raffleNum) public view returns (string memory) {
        return
            string(
                abi.encodePacked(baseTokenURI, raffles[_raffleNum].tokenURI)
            );
    }
}
