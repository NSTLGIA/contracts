# Introduction

In NSTLGIA, the participants of techno events can collect and check their POAP as a proof of attendance. This raffle contract picks winners out of those POAP holders for each event and mint/distribute newly created NFTs to them. Those NFTs are rights to claim promo code for the next event ticket on NSTLGIA app. 

We believe that this raffle functionality not oonly incentivizes more people to claim POAP but entertain them. Minted NFTs can also be anything like NFT art, music and community membership ( being used as a voting right, too). 

POAP has its own off chain raffle function. But on-chain way of picking winner is complex and challengin to implement but more transparent and composable with other on-chain dapps. 

## Deployment
1- install dependencies : npm i
2- compile : npx hardhat compile
3- deploy : npx hardhat run --network localhost scripts_deploy/deploy.js

4- test :
you can test smart contract by runnnig javascript code with expected parameters.

As a preparetion, you need to do:
1- send funds to wallet on Gnosis chain: Testing only can be done on Gnosis chain since poap contract exists there. No worries, it's super cheap and fast than Ethereum mainnet for sure. 
2- create sample POAP on poap.xyz: this raffle contract should interact with real poap contract. 

Issuing POAP: https://app.poap.xyz/admin/events/new/
POAP contract on Gnosis chain: 0x22c1f6050e56d2876009903609a2cc3fef83b415

① createRaffle(eventNum, winnersNum, expiry, participants, tokenURI)
② pickAndMint(raffleNum)

In details, please check out source codes. 



