## General information

2 buttons (request and send money).
**Send money:** person enters amount to send, clicks on send and a URL is generated. When a person clicks the URL claims the money URL not linked to a wallet anyone can claim it.
**Request money:** person enters amount to request, a link is generated.

## Endpoints

`/api/request` request money POST route
`/api/send` send money POST route
`/api/send?claim=TOKEN`
`/` main route
**actions:**
request: amount
send: amount

## Contract

Contract must be created in solidity, for references check the sherry [docs](https://docs.sherry.social/docs/guides/guide-en#1-understanding-the-smart-contract)
You also must get the abi and paste it on `abi.ts`
FOR SEND endpoint we need functions: createGift (holds sent amount with the token) & claimGift (called when person clicks the link, verifies token exist and havent been claimed yet, transfers money to sender, marks token as claimed=true) up to you the names,
Verify the expirationDate of the token pls
creategift: holds the amount, reduces the amount from the sender wallet and validates also that the wallet has enough balance to make the transaction
claimgift: if the gifts wasnt cliaimed its supossed to return to sender wallet money back.

## Important data

TOKEN MUST INCLUDE sender waller addres + timestamp + ?
WE will need a DB to save the token
Avax testnet coupon code for funds: GUILDAPRIL25
database should save token, amount, sender, claimed. timestamp?, expiresAt?

## important links

fuji testnet of avalanche
[fuji testnet docs](https://build.avax.network/docs/quick-start/networks/fuji-testnet)
[fuji testfunds](https://build.avax.network/docs/dapps/smart-contract-dev/get-test-funds)
[fujinetwork](https://subnets-test.avax.network/c-chain)
[sherry guide docs](https://docs.sherry.social/docs/guides/guide-en)
