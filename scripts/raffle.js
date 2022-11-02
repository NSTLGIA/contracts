require('dotenv').config();

const ethers = require("ethers");
const provider = new ethers.providers.JsonRpcProvider("https://gnosis-mainnet.public.blastapi.io")
//const provider = new ethers.providers.JsonRpcProvider("https://rpc.gnosischain.com/")
const signer = new ethers.Wallet(process.env.dev_pk, provider)

const dev = process.env.dev;

//const raffle_abi = require("./abi/raffleNFT.json")
const raffle_abi = require("../artifacts/Contracts/POAPRaffle.sol/POAPRaffle.json")
const raffle_address = ""
const raffle = new ethers.Contract(raffle_address, raffle_abi.abi, signer)

async function func() {
    let count = 1;
    //createRaffle() // 1
    //getRaffle(count)
    //pickAndMint(count) // 2
    //getWinners(count)
    //getNFTImage(count)
}

async function createRaffle() {
    const eventNum = "";
    const winnersNum = "";
    const waiting_duration = 10 // 2minutes(test) / days or weeks in prod
    const expiry = (ethers.BigNumber.from(Math.round(Date.now()/1000) + waiting_duration)).toString() // 1667079411
    const participants = [process.env.participant1, process.env.participant2, process.env.participant3]
    const tokenURI = ""

    const raffleSigner = raffle.connect(signer);
    const raffleCount = await raffleSigner.callStatic.createRaffle(eventNum, winnersNum, expiry, participants, tokenURI);
    await raffleSigner.createRaffle(eventNum, winnersNum, expiry, participants, tokenURI);
    console.log("raffleCount: ", raffleCount.toString())
    await getRaffle(raffleCount)
}

async function getRaffle(raffleCount) {
    const raffleSigner = raffle.connect(signer);
    const result = await raffleSigner.raffles(raffleCount)
    console.log("raffleNum: ", (result.raffleNum).toString())
    console.log("eventNum: ", (result.eventNum).toString())
    console.log("winnersNum: ", (result.winnersNum).toString())
    console.log("expiry: ", (result.expiry).toString())
    console.log("tokenURI: ", (result.tokenURI).toString())
}

async function pickAndMint(raffleNum) {
    const raffleSigner = raffle.connect(signer);
    const result = await raffleSigner.pickAndMint(raffleNum)
    console.log("result:", result)
}

async function getWinners(raffleNum) {
    const raffleSigner = raffle.connect(signer);
    const winners = await raffleSigner.getWinners(raffleNum);
    console.log("winners:", winners)
}

async function getNFTImage(raffleNum) {
    const raffleSigner = raffle.connect(signer);
    const NFTImage = await raffleSigner.getNFTImage(raffleNum);
    console.log("NFTImage Link:", NFTImage)
}

async function getTimestamp() {
    const blockNumber = await provider.getBlockNumber();
    const timestamp_onchain = (await provider.getBlock(blockNumber)).timestamp;
    const timestamp_offchain = await (Math.round(Date.now()/1000))

    console.log("timestamp__onchain: ", timestamp_onchain)
    console.log("timestamp_offchain: ", timestamp_offchain)
}

async function getBalance() {
    let xdai_balance = await provider.getBalance(dev)
    console.log("xdai_balance", xdai_balance.toString())
}

async function getName() {
    let name = await raffle.name();
    console.log("name", name.toString())
}

async function getRaffleCount() {
    let lastRaffleCount = await raffle.lastRaffleCount();
    console.log("lastRaffleCount", lastRaffleCount.toString())
}

func()