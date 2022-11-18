const { ethers } = require("ethers");
require("dotenv").config();

// How might you mitigate MEV and front-running if you were building your own DAPP?
// - Design with MEV/frontrunning in mind - e.g. the CryptoPunks contract is vulnerable
// to frontrunning bid acceptance because "accept bid" doesn't actually accept a specific bid,
// just the highest bid. Someone can then frontrun the "accept bid" tx with a 1wei higher bid than
// the current highest and be guaranteed to have their bid accepted. This is a design flaw.
// - In cases where MEV/frontrunning is unavoidable, make the user aware and provide
// them with a link to flashbots RPC setup etc.

var main = async function () {
  const wsProvider = new ethers.providers.WebSocketProvider(
    process.env.ALCHEMY_WSS_URL
  );
  console.log;
  wsProvider.on("pending", (rawTx) => {
    wsProvider.getTransaction(rawTx).then((tx) => {
      if (
        tx &&
        (tx.to == "0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45" || // v3 router
          tx.to == "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D") // v2 router
      ) {
        console.log(tx);
      }
    });
  });
};

main().catch((err) => {
  console.error(err);
});
