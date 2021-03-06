const { processTransaction } = require("./utils/gnosis_safe_server_interactions")(web3, artifacts)
const { getSafe } = require("./utils/trading_strategy_helpers")(web3, artifacts)
const { defaultWithdrawYargs, prepareWithdrawRequest } = require("./wrapper/withdraw")(web3, artifacts)

const argv = defaultWithdrawYargs.option("noBalanceCheck", {
  type: "boolean",
  default: false,
  describe:
    "Request withdraw for tokens without checking if the token has no balance. Useful to account for trading that might be happening during the withdraw request",
}).argv

module.exports = async (callback) => {
  try {
    const masterSafe = getSafe(argv.masterSafe)

    const transaction = await prepareWithdrawRequest(argv, true)

    await processTransaction(argv.verify, await masterSafe, argv.nonce, transaction, argv.network, argv.executeOnchain, true)

    callback()
  } catch (error) {
    console.log(error.response)
    callback(error)
  }
}
